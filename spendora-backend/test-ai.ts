import { parseReceiptWithAI } from './lib/aiParser';

const rawText = `Pikka j aätee 1,5l nango
Pirkka nlfilee pintamau SIOM
1,292 KG
Atria Wilhe Im 350g (Carolina Re
Snellman rapeat filsitvut 300g
- ALENNUS 30 %
Snellman rapeat filsfivut 300g
- ALENNUS 30 %
K-Meru vihreå rypäle 500g
Tomaatt i Suomi 21k kg
0,821 KG
YHTELNSA
KÄNTA-ASTAKAS
KORITI: 4012
8,61 e/KG
KATEINEN
PLUSSAA KERRYTTAVÄT OSTOT
TAKAISIN
ALV
2 13,50%
3 25,50%
YHTEENSA
1,95 €/KG
VEROTON
31,46
8,59
40,05
VERO
4,23
2,19
6,42
11,12
Www.k-supermarket.fi
2,98
4,37
1,31-
4,37
1,31-
1,95
1,60
46,47
46,47
AfRK 7-22 LA 7-22 SU 9-22
ksmkuntumarket@k -supermarket.fi
47,00
0,55-
VEROLLINEN
35,69
10,78
46,47
KONIUL AN 0STOSKESKUS P. 09 3409 010`;

async function test() {
  console.log("Testing AI Parser with K-Supermarket...");
  await parseReceiptWithAI(rawText);
}

test();
