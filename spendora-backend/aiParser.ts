// These were frontend dependencies. Since this is now an archived reference script in the backend, we mock or omit them.
// import { logger } from './logger';
// import { ParsedReceipt } from './receiptParser';

// 10.0.2.2 is the shortcut for Android Emulator to reach the Mac's localhost
// 192.168.1.100 is your Mac Mini's actual IP on the WiFi
// We use the local IP as the primary choice so it works on physical phones too
const OLLAMA_HOST = '192.168.1.100'; 
const OLLAMA_ENDPOINT = `http://${OLLAMA_HOST}:11434/api/generate`;

/**
 * AI-powered receipt parser using local Ollama instance.
 * Supports global languages and complex layouts.
 */
export async function parseReceiptWithAI(rawText: string): Promise<any | null> {
  const prompt = `
Analyze this receipt text and extract a clean, structured JSON object.

JSON Structure:
{
  "storeName": "Merchant name (e.g., 'Lidl', 'K-Market', 'Starbucks').",
  "date": "YYYY-MM-DD. Return null if not found.",
  "items": [
    {
      "name": "Product name exactly as written, INCLUDING weights and brands (e.g., 'Black bean boiled 400g Heera')",
      "price": number (unit price),
      "quantity": number (default to 1),
      "total": number (line total before tax)
    }
  ],
  "total": number (Final amount paid),
  "tax": number (Total VAT/TAX amount if shown, else null),
  "currency": "string (e.g., 'EUR'). Default to 'EUR'.",
  "metadata": {
    "tax_id": "string",
    "phone": "string",
    "website": "string",
    "payment_method": "string",
    "extra": "any other useful info"
  }
}

Strict Rules:
1. ONLY return the JSON. No preamble, no markdown.
2. DISCOUNTS: If a line is a discount (e.g., '-0,50' or 'ALE'), include it as an item with a negative price.
3. DECIMAL SEPARATOR: Convert commas (',') to dots ('.') for all numbers.
4. DO NOT STRIP WEIGHTS OR BRANDS: Preserve the full item name.
5. FIX OCR TYPOS: If a weight clearly ends in '9' instead of 'g' (e.g., '2809', '4009', '5359'), correct it to 'g' (e.g., '280g', '400g', '535g'). Also fix 's' to 'g' (e.g. '500s' -> '500g').

Contextual Mapping Guidelines (For Chaotic OCR Layouts):
Because mobile OCR reads in visual columns, it sometimes creates "Split-Block Receipts" (where ALL names are listed, then ALL prices are listed far below) or "Mixed Receipts" (where prices are scattered).
- CRITICAL: Do NOT skip any items. Extract every single product name you see.
- ADAPTIVE MAPPING - Listen to the math and the layout:
  * SPLIT-BLOCK: If there is a massive vertical list of prices at the absolute bottom (e.g., Lidl / Viivoan), map them strictly sequentially. The 1st Item Name's \`total\` = the 1st number in the vertical list at the bottom.
  * MIXED STAGGERED (e.g., K-Supermarket): Prices might appear in a staggered block lower down the page (e.g., "2,98", "4,37", "1,31-"). 
    - Anchor Strategy: First, map the obvious items. If you see "- ALENNUS 30 %", find the negative numbers ("1,31-") and pair them. Next, if you see a product name followed shortly by a weight (e.g., "1,292 KG") and a per-kg price (e.g., "8,61 e/KG"), calculate the rough total to find its match in the scattered numbers (1.292 * 8.61 = ~11.12).
    - Asymmetric Array Fallback: For all remaining unanchored items, treat the remaining positive numbers as a sequence. IMPORTANT: Mobile OCR often completely misses numbers (e.g., 10 item names, but only 9 prices found). Do NOT just blindly map index to index. If the arrays are uneven, use mathematical deduction (Final Total minus sum of known prices) to figure out the value of the "missing OCR price", insert it into the sequence to re-align the arrays, and THEN map sequentially.
- Calculate unit price by dividing the assigned \`total\` by the Quantity found near the item name.

Receipt Text:
"""
${rawText}
"""
`;

  try {
    const response = await fetch(OLLAMA_ENDPOINT, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        model: 'qwen2.5:14b', // Using the 14B model for higher accuracy
        prompt: prompt,
        stream: false,
        format: 'json', // Ollama supports forcing JSON output
      }),
    });

    if (!response.ok) {
      throw new Error(`Ollama API error: ${response.statusText}`);
    }

    const data = await response.json();
    const parsedJson = JSON.parse(data.response);

    return {
      storeName: parsedJson.storeName || 'Unknown Store',
      date: parsedJson.date || null,
      items: (parsedJson.items || []).map((item: any) => ({
        name: item.name,
        price: item.price || 0,
        quantity: item.quantity || 1,
        total: item.total || 0,
      })),
      subtotal: null,
      tax: parsedJson.tax || null,
      total: parsedJson.total || 0,
      currency: parsedJson.currency || 'EUR',
      metadata: parsedJson.metadata || {},
      rawText,
    };
  } catch (error) {
    console.error(`[AI Parser Error] (URL: ${OLLAMA_ENDPOINT}):`, error);
    return null;
  }
}
