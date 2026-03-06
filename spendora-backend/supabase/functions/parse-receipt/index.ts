// @ts-ignore - Deno URL import not recognized by Node/React Native TypeScript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req: Request) => {
  // 1. Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { base64_image } = await req.json()

    if (!base64_image) {
      throw new Error('base64_image is required in the request body');
    }

    // @ts-ignore - Deno global not recognized by Node/React Native TypeScript
    const openAiKey = Deno.env.get('OPENAI_API_KEY');
    if (!openAiKey) {
      throw new Error('OPENAI_API_KEY environment variable is not set');
    }

    const prompt = `
Analyze this receipt image and extract a clean, structured JSON object.

JSON Structure:
{
  "storeName": "Merchant name (e.g., store or brand name).",
  "store_category_hint": "One of: groceries, health, dining, transport, electronics, household, other. Infer from the store name in ANY language (e.g., 'Apteekki' = pharmacy → 'health', 'K-Citymarket' → 'groceries', 'McDonald's' → 'dining'). Default to 'other' if unsure.",
  "merchant_domain": "The official website domain for this exact merchant (e.g., 'k-ruoka.fi' for K-Citymarket, 'lidl.fi' for a Finnish Lidl, 'mcdonalds.com'). If unknown, try to guess the most likely local website based on the receipt language/store name. If completely unknown, return null.",
  "date": "YYYY-MM-DD. Return null if not found.",
  "imageQuality": number (0-100, your confidence that the receipt text is clearly readable. 100 = perfectly sharp, 0 = completely unreadable),
  "items": [
    {
      "name": "Full product name including any brand/variant info (e.g. 'Valio Eila Milk 1L', 'Pirkka Organic Eggs 10pcs').",
      "quantity": number (actual quantity purchased — see rules below),
      "unit_type": "One of: kg, g, L, ml, pcs. Default to 'pcs' if no unit is shown.",
      "unit_price": number (price per single unit — e.g., price per kg, per litre, or per piece),
      "total": number (the FINAL printed amount on the RIGHT side of the receipt line for this item)
    }
  ],
  "total": number or null (Final grand total amount paid at checkout. Return null ONLY if the total is not clearly readable on the receipt),
  "tax": number (Total VAT/TAX amount if shown, else null),
  "currency": "string (e.g., 'EUR', 'USD'). Default to 'EUR'.",
  "metadata": {
    "tax_id": "string",
    "phone": "string",
    "website": "string",
    "payment_method": "string",
    "extra": "any other useful info"
  }
}

CRITICAL — READ THE RECEIPT, DO NOT RE-CALCULATE:

1. ONLY return the JSON. No preamble, no markdown fences.

2. TOTAL = THE NUMBER PRINTED ON THE RIGHT SIDE (the final line amount):
   The receipt has already done all the math. For every item, read the FINAL printed amount from the RIGHT column of the receipt line and use it directly as "total".
   - NEVER re-calculate total from quantity × unit_price yourself. The receipt already did that math.
   - The "total" field is ALWAYS the right-side printed number.

3. QUANTITY AND UNIT EXTRACTION — READ THE ACTUAL AMOUNTS:
   Extract the real quantity and unit as printed on the receipt:
   - MULTI-LINE ITEMS (VERY COMMON): Often, the item name and total are on the first line, and the weight/unit price is on the indented line immediately below it. YOU MUST COMBINE THEM into a single item.
     Example receipt text: 
     "Cloetta Irtomakeiset         1.54"
     "   0.182 kg x 8.45 EUR/kg"
     → name="Cloetta Irtomakeiset", quantity=0.182, unit_type="kg", unit_price=8.45, total=1.54
   - If a line says "Tomato 1.406 kg" with "2.79 /kg" and RIGHT-SIDE says "3.92":
     → quantity=1.406, unit_type="kg", unit_price=2.79, total=3.92
   - If a line says "Plastic bag" with "2 x 0.39" and RIGHT-SIDE says "0.78":
     → quantity=2, unit_type="pcs", unit_price=0.39, total=0.78
   - If a line says "Chicken 0.543 kg" with "7.90 /kg" and RIGHT-SIDE "4.29":
     → quantity=0.543, unit_type="kg", unit_price=7.90, total=4.29
   - CRITICAL FOR MEAT/WEIGHTED ITEMS: If the line under the item shows a weight (e.g. "10,730 KG 4,47 €/KG"), YOU MUST USE THAT WEIGHT as the quantity.
     → quantity=10.730, unit_type="kg", unit_price=4.47, total=47.96. NEVER default to quantity=1 if a weight is printed!
   - If no weight/volume/multiplier is shown anywhere near the item, use quantity=1, unit_type="pcs", unit_price=total.

4. EXCLUDE ALL DISCOUNTS, MINUSES, AND NON-PHYSICAL ITEMS:
   - NEVER extract discounts, coupons, loyalty savings, bottle deposits returned, or any line item that has a NEGATIVE value (e.g., -0.54, -0.15). 
   - IGNORE ALL negative values completely. Do not include them in the "items" array.
   - We ONLY want proper items (food, groceries, actual products).

5. ITEMS TO EXCLUDE — NEVER EXTRACT THESE:
   - EVERYTHING printed AFTER the grand total line (e.g., Total / Sum) must be EXCLUDED.
   - This includes but is not limited to: payment method lines (Cash, Card), change given back to customer, rounding adjustments, tax breakdowns (VAT, Net, Gross), savings summaries, barcode lines.
   - Negative values at the bottom of the receipt are usually CHANGE given back to the customer, NOT discounts.
   - Do NOT extract "subtotal", "total", "tax", "change", or "rounding" as item lines.

6. NO HALLUCINATIONS:
   - Extract ONLY physical items that were physically purchased.
   - If the same item appears on multiple separate printed lines, extract each one individually.

7. TOTAL FIELD:
   - Spot the grand total line in ANY language (e.g., "Total", "Grand Total", "YHTEENSÄ", "SUMMA", etc.) and use that exact printed number. DO NOT re-calculate it from items.
   - If the grand total is obscured or unreadable, set "total" to null.

8. TAX AMOUNT — LANGUAGE-AGNOSTIC EXTRACTION:
   Tax / VAT appears under many names depending on language. Actively look for these patterns and extract them as the "tax" field:
   - Finnish:  ALV, Alv, AlvAlv%, Vero
   - German:   MwSt, USt, Mehrwertsteuer
   - Swedish:  Moms, Mervärdesskatt
   - French:   TVA, T.V.A.
   - Spanish:  IVA
   - English:  VAT, Tax, GST, HST, Sales Tax
   - …or any label that represents a government tax added to the price
   The tax amount is typically a subtotal line BEFORE the grand total. Extract it as a decimal number.
   If multiple tax rates are listed (e.g., 14% and 25.5%), sum them into a single "tax" value.
   If no tax is shown on the receipt, return null.

9. DECIMAL SEPARATOR: Convert commas (',') to dots ('.') for all numbers.

10. Use spatial reasoning to connect RIGHT-SIDE prices to their corresponding item lines if columns are misaligned.

11. PAYMENT METHOD NORMALIZATION:
    Normalize the payment_method in metadata to one of these English values: Cash, Credit Card, Debit Card, Mobile Pay, Gift Card, Other.
    Examples: "Käteinen" → "Cash", "Kortti" / "Visa" / "Mastercard" → "Credit Card", "Carte bancaire" → "Credit Card", "Bargeld" → "Cash", "Apple Pay" / "Google Pay" → "Mobile Pay".

EXAMPLES OF CORRECT ITEM EXTRACTION:

Example 1: Single-line item with no weight
Input on receipt: "Maito 1L  1.89"
Output: { "name": "Maito 1L", "quantity": 1, "unit_type": "pcs", "unit_price": 1.89, "total": 1.89 }

Example 2: Multi-line item with weight and EUR/kg (Very Common Finnish Pattern)
Input on receipt:
"Cloetta Irtomakeiset         1.54 B"
"   0.182 kg x 8.45 EUR/kg"
Output: { "name": "Cloetta Irtomakeiset", "quantity": 0.182, "unit_type": "kg", "unit_price": 8.45, "total": 1.54 }

Example 3: Multi-line item with simple multiplier
Input on receipt:
"Muovikassi                   0.78 B"
"   2 x 0.39 EUR"
Output: { "name": "Muovikassi", "quantity": 2, "unit_type": "pcs", "unit_price": 0.39, "total": 0.78 }

Example 4: Heavy weighted meat item
Input on receipt:
"Atria sika etu 1/4             47,96"
"  10,730 KG        4,47 €/KG"
Output: { "name": "Atria sika etu 1/4", "quantity": 10.730, "unit_type": "kg", "unit_price": 4.47, "total": 47.96 }
`;

    // 2. Send image directly to GPT-4o-mini
    const openAiResponse = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${openAiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'gpt-4o-mini',
        messages: [
          {
            role: 'user',
            content: [
              { type: 'text', text: prompt },
              {
                type: 'image_url',
                image_url: {
                  url: `data:image/jpeg;base64,${base64_image}`,
                  detail: "high"
                }
              }
            ]
          }
        ],
        max_tokens: 1500,
        response_format: { type: "json_object" }
      }),
    });

    if (!openAiResponse.ok) {
        const errortext = await openAiResponse.text();
        console.error('OpenAI Error:', errortext);
        throw new Error(`OpenAI API error: ${openAiResponse.statusText}`);
    }

    const data = await openAiResponse.json();
    const resultText = data.choices[0].message.content;

    // 3. Return the exact JSON structure back to the mobile app
    return new Response(
      resultText,
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : String(error);
    // Return 200 so the Supabase client doesn't swallow the error as a generic HttpError
    return new Response(
      JSON.stringify({ _backend_error: true, message }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' }, status: 200 }
    )
  }
})
