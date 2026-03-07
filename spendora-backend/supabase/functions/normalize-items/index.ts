// @ts-ignore - Deno URL import not recognized by Node/React Native TypeScript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
// @ts-ignore - Deno URL import not recognized by Node/React Native TypeScript
import { createClient, SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

/** Valid super categories */
const VALID_SUPER_CATEGORIES = [
  'groceries', 'household', 'transport', 'electronics', 'health', 'dining', 'other',
] as const;

/** Valid categories (flat list across all super categories) */
const VALID_CATEGORIES = [
  'meat', 'dairy', 'fruits_vegetables', 'bakery', 'frozen', 'snack', 'beverage', 'condiment', 'grains',
  'bills', 'cleaning', 'furniture', 'tools',
  'fuel', 'insurance', 'maintenance', 'public_transport',
  'devices', 'accessories', 'software',
  'pharmacy', 'fitness', 'personal_care',
  'restaurant', 'cafe', 'delivery',
  'uncategorized',
] as const;

/** Map category → super_category for validation */
const CATEGORY_TO_SUPER: Record<string, string> = {
  meat: 'groceries', dairy: 'groceries', fruits_vegetables: 'groceries', bakery: 'groceries',
  frozen: 'groceries', snack: 'groceries', beverage: 'groceries', condiment: 'groceries', grains: 'groceries',
  bills: 'household', cleaning: 'household', furniture: 'household', tools: 'household',
  fuel: 'transport', insurance: 'transport', maintenance: 'transport', public_transport: 'transport',
  devices: 'electronics', accessories: 'electronics', software: 'electronics',
  pharmacy: 'health', fitness: 'health', personal_care: 'health',
  restaurant: 'dining', cafe: 'dining', delivery: 'dining',
  uncategorized: 'other',
};

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { receipt_id, user_id, store_name } = await req.json();

    if (!receipt_id || !user_id) {
      throw new Error('receipt_id and user_id are required');
    }

    // @ts-ignore - Deno global not recognized by Node/React Native TypeScript
    const openAiKey = Deno.env.get('OPENAI_API_KEY');
    if (!openAiKey) throw new Error('OPENAI_API_KEY not set');

    const supabase = createClient(
      // @ts-ignore - Deno global not recognized by Node/React Native TypeScript
      Deno.env.get('SUPABASE_URL')!,
      // @ts-ignore - Deno global not recognized by Node/React Native TypeScript
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
    );

    // ─── 1. Upsert merchant + store ─────────────────────────────
    let storeId: string | null = null;
    let storeName: string = '';
    if (store_name) {
      storeName = store_name.trim();

      let { data: merchant } = await supabase
        .from('merchants')
        .select('id')
        .eq('name', storeName)
        .maybeSingle();

      if (!merchant) {
        const { data: newMerchant } = await supabase
          .from('merchants')
          .insert({ name: storeName })
          .select('id')
          .single();
        merchant = newMerchant;
      }

      if (merchant) {
        let { data: store } = await supabase
          .from('stores')
          .select('id')
          .eq('merchant_id', merchant.id)
          .eq('store_name', storeName)
          .maybeSingle();

        if (!store) {
          const { data: newStore } = await supabase
            .from('stores')
            .insert({ merchant_id: merchant.id, store_name: storeName })
            .select('id')
            .single();
          store = newStore;
        }

        storeId = store?.id ?? null;

        if (storeId) {
          await supabase
            .from('receipts')
            .update({ store_id: storeId })
            .eq('id', receipt_id);
        }
      }
    }

    // ─── 2. Fetch unclassified receipt items ────────────────────
    const { data: items, error: itemsErr } = await supabase
      .from('receipt_items')
      .select('id, name_raw, unit_price, line_total, qty')
      .eq('receipt_id', receipt_id)
      .is('canonical_item_id', null);

    if (itemsErr) throw itemsErr;
    if (!items || items.length === 0) {
      return new Response(
        JSON.stringify({ message: 'No items to normalize', classified: 0 }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // ─── 3. Fetch receipt date for denormalization ───────────────
    const receiptDate = await getReceiptDate(supabase, receipt_id);

    // ─── 4. Check user overrides first (user preferences win) ───
    const rawNames = items.map((i: { name_raw: string }) => i.name_raw);

    // Get any existing canonical names for these raw names from past classifications
    const { data: existingItems } = await supabase
      .from('receipt_items')
      .select('name_raw, canonical_item_id, canonical_items!inner(name)')
      .eq('user_id', user_id)
      .in('name_raw', rawNames)
      .not('canonical_item_id', 'is', null)
      .limit(100);

    // Build raw_name → canonical_name mapping
    const rawToCanonicalName = new Map<string, string>();
    if (existingItems) {
      for (const ei of existingItems) {
        if (ei.canonical_items && typeof ei.canonical_items === 'object' && 'name' in ei.canonical_items) {
          const ciName = (ei.canonical_items as { name: string }).name;
          if (typeof ei.name_raw === 'string') {
            rawToCanonicalName.set(ei.name_raw, ciName);
          }
        }
      }
    }

    // Check overrides for known canonical names
    const knownCanonicalNames = [...new Set(rawToCanonicalName.values())];
    const overrideMap = new Map<string, { super_category: string; category: string; subcategory: string }>();

    if (knownCanonicalNames.length > 0) {
      const { data: overrides } = await supabase
        .from('item_classification_overrides')
        .select('canonical_name, super_category, category, subcategory')
        .eq('user_id', user_id)
        .in('canonical_name', knownCanonicalNames);

      if (overrides) {
        for (const o of overrides) {
          overrideMap.set(o.canonical_name, {
            super_category: o.super_category,
            category: o.category,
            subcategory: o.subcategory,
          });
        }
      }
    }

    // ─── 5. Check alias cache ───────────────────────────────────
    const { data: existingAliases } = await supabase
      .from('item_aliases')
      .select('raw_name, canonical_item_id, canonical_items(id, name, category, subcategory, super_category)')
      .eq('user_id', user_id)
      .in('raw_name', rawNames);

    const aliasMap = new Map<string, { canonical_item_id: string; canonical_name: string; super_category: string; category: string; subcategory: string | null }>();
    if (existingAliases) {
      for (const alias of existingAliases) {
        if (
          alias &&
          typeof alias === 'object' &&
          'canonical_items' in alias &&
          alias.canonical_items &&
          typeof alias.canonical_items === 'object' &&
          'id' in alias.canonical_items
        ) {
          const ci = alias.canonical_items as { id: string; name: string; category: string; subcategory: string | null; super_category: string | null };
          if (typeof alias.raw_name === 'string') {
            // Check if user has an override for this canonical name
            const override = overrideMap.get(ci.name);
            aliasMap.set(alias.raw_name, {
              canonical_item_id: ci.id,
              canonical_name: ci.name,
              super_category: override?.super_category ?? ci.super_category ?? CATEGORY_TO_SUPER[ci.category] ?? 'other',
              category: override?.category ?? ci.category,
              subcategory: override?.subcategory ?? ci.subcategory,
            });
          }
        }
      }
    }

    const cachedItems = items.filter((i: { name_raw: string }) => aliasMap.has(i.name_raw));
    const uncachedItems = items.filter((i: { name_raw: string }) => !aliasMap.has(i.name_raw));

    console.log(`[Normalize] ${cachedItems.length} cached, ${uncachedItems.length} need GPT classification`);

    // ─── 6. GPT classification for uncached items (3-level) ─────
    let classifiedMap = new Map<string, { canonical: string; super_category: string; category: string; subcategory: string | null }>();

    if (uncachedItems.length > 0) {
      const prompt = `Classify these receipt items into a 3-level taxonomy. For each raw item name:
- "canonical": Clean English product name (e.g., "Chicken Fillet", "Organic Eggs", "Chocolate Bar")
- "super_category": One of: ${VALID_SUPER_CATEGORIES.join(', ')}
- "category": One of: ${VALID_CATEGORIES.join(', ')}
- "subcategory": A granular sub-group (e.g., "poultry", "leafy_greens", "gasoline")

CRITICAL RULES:
1. You MUST return exactly ${uncachedItems.length} objects. Do not skip ANY items, even if you are unsure what they are.
2. If an item is ambiguous or appears to be a brand name or localized abbreviation, make your best educated guess based on common grocery store items and global brands (e.g., classifying a local chocolate brand as "Chocolate").
3. The "raw" field MUST match the input string exactly.

Super category mapping:
- groceries: meat, dairy, fruits_vegetables, bakery, frozen, snack, beverage, condiment, grains
- household: bills, cleaning, furniture, tools
- transport: fuel, insurance, maintenance, public_transport
- electronics: devices, accessories, software
- health: pharmacy, fitness, personal_care
- dining: restaurant, cafe, delivery
- other: uncategorized

Items to classify:
${uncachedItems.map((i: { name_raw: string }, idx: number) => `${idx + 1}. "${i.name_raw}"`).join('\n')}

Return ONLY a JSON array, no markdown:
[{ "raw": "exact original name", "canonical": "Clean Name", "super_category": "groceries", "category": "fruits_vegetables", "subcategory": "fruits" }]`;

      const gptRes = await fetch('https://api.openai.com/v1/chat/completions', {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${openAiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          model: 'gpt-4o-mini',
          messages: [{ role: 'user', content: prompt }],
          max_tokens: 2000,
          response_format: { type: 'json_object' },
        }),
      });

      if (!gptRes.ok) {
        const errText = await gptRes.text();
        console.error('[Normalize] GPT error:', errText);
        throw new Error(`GPT classification failed: ${gptRes.statusText}`);
      }

      const gptData = await gptRes.json();
      const rawContent = gptData.choices[0].message.content;
      let classifications: Array<{ raw?: string; canonical?: string; super_category?: string; category?: string; subcategory?: string }> = [];

      try {
        const parsed = JSON.parse(rawContent);
        classifications = Array.isArray(parsed) ? parsed : (parsed.items || parsed.classifications || []);
      } catch {
        console.error('[Normalize] Failed to parse GPT response:', rawContent);
        classifications = [];
      }

      for (const c of classifications) {
        if (c.raw && c.canonical && c.category) {
          const cat = (VALID_CATEGORIES as readonly string[]).includes(c.category) ? c.category : 'uncategorized';
          const superCat = c.super_category && (VALID_SUPER_CATEGORIES as readonly string[]).includes(c.super_category)
            ? c.super_category
            : CATEGORY_TO_SUPER[cat] ?? 'other';

          // Check if user has an override for this canonical name
          const override = overrideMap.get(c.canonical);

          classifiedMap.set(c.raw, {
            canonical: c.canonical,
            super_category: override?.super_category ?? superCat,
            category: override?.category ?? cat,
            subcategory: override?.subcategory ?? (c.subcategory || null),
          });
        }
      }

      console.log(`[Normalize] GPT classified ${classifiedMap.size}/${uncachedItems.length} items`);
    }

    // ─── 7. Process cached items ────────────────────────────────
    for (const item of cachedItems) {
      const cached = aliasMap.get(item.name_raw)!;
      await supabase
        .from('receipt_items')
        .update({
          canonical_item_id: cached.canonical_item_id,
          super_category: cached.super_category,
          category: cached.category,
          store_name: storeName,
          receipt_date: receiptDate,
        })
        .eq('id', item.id);

      if (storeId) {
        await supabase.from('price_history').insert({
          canonical_item_id: cached.canonical_item_id,
          store_id: storeId,
          unit_price: item.unit_price ?? item.line_total,
          observed_date: receiptDate,
          receipt_item_id: item.id,
        });
      }
    }

    // ─── 8. Process newly classified items ──────────────────────
    let newClassifications = 0;
    for (const item of uncachedItems) {
      const classified = classifiedMap.get(item.name_raw);
      if (!classified) continue;

      // Upsert canonical_item
      let { data: canonicalItem } = await supabase
        .from('canonical_items')
        .select('id')
        .eq('name', classified.canonical)
        .eq('category', classified.category)
        .maybeSingle();

      if (!canonicalItem) {
        const { data: newItem } = await supabase
          .from('canonical_items')
          .insert({
            name: classified.canonical,
            super_category: classified.super_category,
            category: classified.category,
            subcategory: classified.subcategory,
          })
          .select('id')
          .single();
        canonicalItem = newItem;
      } else {
        // Update super_category on existing canonical item if missing
        await supabase
          .from('canonical_items')
          .update({ super_category: classified.super_category })
          .eq('id', canonicalItem.id)
          .is('super_category', null);
      }

      if (!canonicalItem) continue;

      // Create alias
      const merchantId = storeId
        ? (await supabase.from('stores').select('merchant_id').eq('id', storeId).single()).data?.merchant_id
        : null;

      if (merchantId) {
        await supabase.from('item_aliases').upsert({
          raw_name: item.name_raw,
          canonical_item_id: canonicalItem.id,
          merchant_id: merchantId,
          user_id: user_id,
          confidence_score: 0.9,
          last_used_at: new Date().toISOString(),
          times_used: 1,
        }, { onConflict: 'raw_name,merchant_id,user_id' });
      }

      // Update receipt_item with 3-level taxonomy + denormalized fields
      await supabase
        .from('receipt_items')
        .update({
          canonical_item_id: canonicalItem.id,
          super_category: classified.super_category,
          category: classified.category,
          store_name: storeName,
          receipt_date: receiptDate,
        })
        .eq('id', item.id);

      // Price history
      if (storeId) {
        await supabase.from('price_history').insert({
          canonical_item_id: canonicalItem.id,
          store_id: storeId,
          unit_price: item.unit_price ?? item.line_total,
          observed_date: receiptDate,
          receipt_item_id: item.id,
        });
      }

      newClassifications++;
    }

    // ─── 9. Update receipt-level category from dominant item super_category ──
    const allSuperCategories: string[] = [];
    for (const item of cachedItems) {
      const cached = aliasMap.get(item.name_raw);
      if (cached?.super_category) allSuperCategories.push(cached.super_category);
    }
    for (const item of uncachedItems) {
      const classified = classifiedMap.get(item.name_raw);
      if (classified?.super_category) allSuperCategories.push(classified.super_category);
    }

    if (allSuperCategories.length > 0) {
      // Find the most frequent super_category
      const freq: Record<string, number> = {};
      for (const sc of allSuperCategories) {
        freq[sc] = (freq[sc] || 0) + 1;
      }
      const dominantCategory = Object.entries(freq).sort((a, b) => b[1] - a[1])[0][0];

      // Only update if receipt has no category or still has a placeholder
      const { data: currentReceipt } = await supabase
        .from('receipts')
        .select('category')
        .eq('id', receipt_id)
        .single();

      const currentCat = currentReceipt?.category;
      if (!currentCat || currentCat === 'General' || currentCat === 'uncategorized') {
        await supabase
          .from('receipts')
          .update({ category: dominantCategory })
          .eq('id', receipt_id);
        console.log(`[Normalize] Updated receipt category to: ${dominantCategory}`);
      }
    }

    const result = {
      message: 'Normalization complete',
      classified: newClassifications,
      cached: cachedItems.length,
      total: items.length,
    };
    console.log('[Normalize] Result:', result);

    return new Response(
      JSON.stringify(result),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    );
  } catch (error: unknown) {
    const errorMsg = error instanceof Error ? error.message : String(error);
    console.error('[Normalize] Error:', errorMsg);
    return new Response(
      JSON.stringify({ error: errorMsg }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 }
    );
  }
});

/** Helper: get receipt date for price_history */
async function getReceiptDate(supabase: SupabaseClient, receiptId: string): Promise<string> {
  const { data } = await supabase
    .from('receipts')
    .select('receipt_date')
    .eq('id', receiptId)
    .single();
  return data?.receipt_date || new Date().toISOString().split('T')[0];
}
