# Learning & Troubleshooting Log: Spendora AI Integration

This document summarizes the key errors, roadblocks, and solutions encountered during the integration of local AI parsing (Ollama) and the Android build process in the Spendora app.

---

## 1. Network Connectivity: Emulators, Devices & Localhost

**The Goal:** Connect the React Native app running on an Android emulator or a physical device to a local Ollama server running on the Mac.
**The Mistake:** Using `localhost` or `127.0.0.1` inside the app's fetch requests.

**Why it failed:**

- In networking, `localhost` (127.0.0.1) refers to the _current device_.
- When the App (running on the Android Emulator or Phone) calls `http://localhost:11434`, it is looking for an Ollama server running _inside the phone itself_, not the Mac.

**The Solution:**

1. **For Android Emulators:** Used the special alias `10.0.2.2`, which tells the Android Emulator to route the traffic back to the host machine's (the Mac's) localhost.
2. **For Physical Devices:** Used the Mac's actual Local Network IP address (e.g., `192.168.1.100`).
3. **Ollama Config:** Ran Ollama with `OLLAMA_HOST=0.0.0.0 ollama serve` to tell it to listen on _all_ network interfaces, not just the Mac's internal localhost.

---

## 2. HTTP "Cleartext Traffic" on Android

**The Goal:** Send requests to the local Ollama server over standard HTTP.
**The Error:** Android blocked the connection with a `Network request failed` or similar message.

**Why it failed:**

- By default, modern Android versions (Android 9+) enforce HTTPS for all network requests to improve security. They block standard HTTP requests, calling them "Cleartext Traffic".

**The Solution:**

- Added `"usesCleartextTraffic": true` into the `expo.android` section of `app.json`. This tells the Android OS to allow HTTP connections, which is necessary when connecting to local development servers that don't have SSL certificates.

---

## 3. macOS Firewall Blocking Incoming Connections

**The Goal:** Allow the physical Android device to reach the Ollama server on the Mac via the WiFi network.
**The Error:** The connection timed out or was refused.

**Why it failed:**

- The macOS built-in application firewall was silently blocking incoming connections to the `ollama` executable.

**The Solution:**

- Used the macOS `socketfilterfw` command line utility to explicitly add the `/usr/local/bin/ollama` binary to the firewall's allowed list, and unblocked it.

---

## 4. Database Schema Mismatches (Silent Bugs vs. Hard Crashes)

**The Error:** `column receipts.purchase_date does not exist` when fetching dashboard data.
**The TypeScript Error:** `Property 'total_amount' does not exist on type...`

**Why it failed:**

- In the React Native code (`index.tsx`, `history.tsx`), we assumed the database columns were named `purchase_date` and `total_amount`.
- However, the actual Supabase SQL schema defined them as `receipt_date` and `grand_total`.
- The database correctly threw an error (42703) because it was asked to fetch a column that wasn't there.

**The Solution:**

- Always double-check the source of truth (`db/schema.sql`). We updated the React Native components to query `receipt_date` and sum `grand_total`.

**Lessons Learned:**

1. **TypeScript is your friend:** TypeScript caught the `total_amount` error during compilation (`npx tsc`). Having accurate types prevents these runtime bugs from reaching the user.
2. **Naming conventions:** Ensuring consistency between the frontend code, the backend schema, and the AI parser's output is critical for a smooth data pipeline.

---

## 5. React Native UI Components (Web vs. Native)

**The Error:** Attempting to render the app after an update resulted in an immediate, hard crash (often a red screen error).

**Why it failed:**

- Inside a React Native component (`index.tsx`), a standard HTML `<div>` tag was accidentally used instead of a React Native `<View>` tag. React Native has no concept of HTML Document Object Model (DOM) elements like `div`, `span`, or `p`.

**The Solution:**

- Replaced the `<div>` tags with `<View>` components.
- _Golden Rule:_ In React Native, always use the primitive components imported from `react-native` (e.g., View, Text, ScrollView, Image) or your UI library (`react-native-paper`).

---

## 6. Native Android Builds: The Missing Java Requirement

**The Goal:** Run `npx expo run:android` to compile a fresh local build of the Android app so it includes native changes (like the cleartext traffic configuration).
**The Error:** `Unable to locate a Java Runtime.` and `SDK location not found.`

**Why it failed:**

1. **No Java:** Unlike React or standard Node.js projects, compiling an Android app requires the Android build tools (Gradle), which are written in Java. The Mac didn't have the Java Development Kit (JDK 17) installed.
2. **No Android SDK Path:** Even after installing Java, Gradle didn't know where the Android SDK was installed on the machine.

**The Solution:**

1. **Installed Java:** Used Homebrew to install `openjdk@17` and symlinked it so the system recognized it.
2. **Configured SDK:** Set the `ANDROID_HOME` path in the user's terminal profile (`~/.zshrc`) and explicitly set the `sdk.dir` inside the `android/local.properties` file.

**Lessons Learned:**

- **Expo Go vs. Native Builds:** When using Expo Go, you only compile JavaScript. When you add custom native plugins or change `app.json` properties (like cleartext traffic), you must perform a full native build. This shifts the complexity from the "web world" to the complex "mobile/Java/C++ world."
- **Environment Variables:** The terminal's environment variables (`JAVA_HOME`, `ANDROID_HOME`) are the glue that allows all these different tools (Node, Gradle, Android SDK) to talk to each other.

---

## 7. Architecture Decisions: ML Kit OCR vs. AI Parsing

**The Goal:** Build a highly accurate receipt scanner that works globally.

**Phase 1: Pure Regex & ML Kit**

- We initially integrated **Google ML Kit Text Recognition** (`@react-native-ml-kit/text-recognition`) to perform on-device Optical Character Recognition (OCR).
- **The Problem with Regex:** OCR guarantees we get the raw text, but receipt formats vary wildly by country, store, and even printer. Writing a Regular Expression (`regex`) to reliably extract line items, taxes, and merchant names across Finnish, Vietnamese, and US receipts proved to be extremely brittle.

**Phase 2: Local AI (Qwen2.5 14B)**

- We decided to keep ML Kit for the initial OCR step (extracting text from the image quickly and locally) but replaced the fragile regex parser with a **Local LLM**.
- **Why Ollama & Qwen2.5 14B?**
  - **Privacy:** Receipts contain highly sensitive data (locations, spending habits, names). Using a local LLM means no receipt data is ever sent to OpenAI or Anthropic.
  - **Accuracy & Multilingual Support:** Qwen2.5 is excellent at understanding structure and multiple languages out of the box.
  - **Prompt Engineering:** We built a strict prompt inside `aiParser.ts` that enforces a pure JSON return format, allowing the AI to dynamically separate noisy text (like addresses and phone numbers) from the actual line items and totals.

**The Hybrid Solution:**
The app now uses a hybrid approach:

1. **Camera** captures the receipt.
2. **ML Kit** extracts the text rapidly on-device.
3. The raw text is sent to the local **Qwen2.5 14B** model via Ollama for semantic understanding and JSON structuring.
4. If the AI is offline or fails, the app seamlessly **falls back** to the original Regex parser (`receiptParser.ts`) to ensure the user can still proceed.

### Error: INSTALL_FAILED_UPDATE_INCOMPATIBLE

- **Encountered**: When running Expo on the Android emulator after structural changes or key differences.
- **Solution**: Uninstall the existing app from the emulator via `adb -s <emulator-id> uninstall com.spendora.app` before running the build again.

### Error: Unauthorized Android Device

- **Encountered**: When running `npm run android` or `adb devices` with a physical Android device connected and getting an 'unauthorized' error.
- **Solution**: You must unlock your phone screen and tap **Allow USB debugging** in the prompt that appears. Make sure to check _Always allow from this computer_. If the prompt does not appear, disconnect and reconnect the USB cable, or revoke USB debugging authorizations in Developer Options and try again.

### Architecture: Receipt Scanning Flow & Data Storage

- **Problem**: Users were dropped directly into a deep line-item editor immediately after scanning, which was overwhelming and ergonomically poor (inputs at the very top of the screen).
- **Solution (UI)**: Introduced a midway `scan-overview.tsx` screen that shows high-level metrics (Total, Tax, Store, Date) with a summary button that navigates into `scan-result.tsx` (repurposed as a sub-editor with its inputs pushed to the bottom via `flexGrow: 1` and `justifyContent: flex-end`).
- **Solution (State)**: A multi-screen wizard using React Navigation parameters is brittle for large JSON objects. Created a transient Zustand store (`usePendingReceiptStore`) to cleanly share the parsed `ParsedReceipt` state between the structural overview and the granular line-item lists.
- **Architecture (Free/Premium Tiers)**: To support a free-tier offline-first storage limitation, the image URI obtained from the `DocumentScanner` (`file://...`) is dynamically injected into the Supabase `receipts.metadata.local_image_uri` field instead of attempting a heavy blob upload to Supabase Storage. Premium logic can later hook into this exact spot.

### Error: Text Strings Rendering Crash

- **Encountered**: `ERROR  Text strings must be rendered within a <Text> component.`
- **Cause**: In React Native, unlike React DOM, you cannot place raw text strings or un-wrapped comments (like `{/* Spacer */}`) directly inside a `<View>`. The React Native transpiler occasionally interprets trailing inline JSX comments as literal text nodes if they aren't explicitly wrapped or placed carefully on their own line.
- **Solution**: Remove the comment or ensure absolutely all text content is inside a `<Text>` component from `react-native-paper` or `react-native`.

### Error: Disjointed LLM Receipt Parsing (Split-Block Format)

- **Encountered**: Qwen occasionally misaligned item names with their respective quantities and prices on European/Finnish receipts where names, multipliers, and totals are printed in separate visual column blocks.
- **Cause**: The LLM prompt was demanding a structured JSON output but lacked step-by-step structural reasoning on _how_ to connect a number at line 50 to a grocery item on line 10.
- **Solution**: Updated the system prompt in `aiParser.ts` to enforce a strict "count-and-map" heuristic. (i.e. "count the names, count the multipliers, count the line totals at the bottom, and map the 1st total to the 1st name, doing the math if a multiplier exists").

### Error: Babel Syntax Error (Template Literal Escaping)

- **Encountered**: `SyntaxError: Expecting Unicode escape sequence \uXXXX.` in `aiParser.ts`.
- **Cause**: An improperly escaped backtick (\`) inside a template literal string assignment caused the React Native Babel transpiler to fail parsing the file.
- **Solution**: Avoid nesting template literals with escaped backticks unless absolutely necessary. Use standard quotes or clean concatenation to avoid breaking the bundler.

### Architecture: OCR Scanning Quality vs LLM Correction

- **Problem**: React Native OCR plugins (using Google ML Kit or Apple Vision) parse receipts in visual Column Blocks rather than semantic Line-by-Line rows, resulting in chaotic text blobs that confuse standard regex parsers.
- **Decision**: Pushed the burden of parsing heavily onto Qwen (LLM) using strict Contextual Mapping prompts. This is a tradeoff: It avoids sending sensitive receipt images to cloud Vision APIs (OpenAI/Anthropic) to maintain privacy, but it requires writing extremely fault-tolerant AI prompts to handle the garbled on-device OCR.

### Limitation: On-Device OCR Data Corruption limits LLMs

- **Issue**: For receipts with complex offset layouts (like K-Supermarket), Google ML Kit frequently drops entire numbers from the right-hand column if they are faint or out of alignment.
- **Result**: Even with advanced prompt engineering ("Anchor Strategies" and "Triangulation Fallbacks"), the LLM is forced to guess which remaining prices map to which remaining item names when the arrays are unequal sizes. This causes line-item misalignment, although the Final Total remains correct.
- **Verdict**: A 14B Qwen model can successfully reconstruct Split-Block layouts and match explicit discounts (e.g. `ALENNUS 30 %` -> `1,31-`), but it cannot reliably invent missing rows for Staggered Mixed formats. For perfect accuracy on complex formats, a dedicated VLM (Vision Language Model) API like Google Cloud Document AI or Anthropic Claude 3.5 Sonnet would be required over raw OCR.

### Decision: Transitioning to Local VLM

- **Trigger**: The complex layout of the K-Supermarket receipt triggered OCR text loss that even the most robust Qwen triangulation prompt could not overcome cleanly. The tradeoff of attempting to parse fundamentally corrupted data shifted the decision toward changing the intake mechanism.
- **New Architecture**: Rather than processing corrupted OCR strings, the scanner will capture the raw Base64 image and send it directly to a local Vision Language Model (VLM), specifically `llama3.2-vision`.
- **Justification**: This completely bypasses the fragile nature of Google ML Kit's column-based text block recognition. The VLM maps text contextually as it appears on the image, resulting in substantially higher accuracy for complex data tables (receipts). It preserves the core requirement of maintaining data privacy (processed locally on the Mac Mini) and avoids recurring API costs.
- **Trade-offs Accepted**: The scan processing time will increase from ~3-5 seconds to ~15-30 seconds depending on the Mac Mini's hardware acceleration due to the heavy nature of VLM inference. A loading UI must be implemented to manage user expectations.

### Vision Model Comparison for Direct Image Parsing

- **qwen2.5:latest (Text Only)**: Fast (~3-5s), handles logical deduction well, but completely blind to layout gaps. Requires heavy prompt engineering and manual user correction for OCR-dropped values.
- **minicpm-v (8B Vision)**: Medium speed (~8-12s). Designed specifically for OCR on mobile and edge devices. Excels at extracting text from complex layouts like Mandarin or dense receipts. Requires significant VRAM but offers an excellent balance of speed and structural accuracy.
- **llava:7b (7B Vision)**: Slower (~10-15s) and older generation. Good at general image description ("a picture of a receipt") but notorious for hallucinating specific numbers or struggling to read tiny font sizes compared to minicpm-v.

### Verdict: Local Vision Models (VLMs) vs OCR

- **Test Results**: Both the 8B (`minicpm-v`) and 7B (`llava:7b`) local vision models completely failed to accurately transcribe the 128KB receipt image. Both models exhibited catastrophic hallucinations (inventing items like "Mämmi" and "FISH BONE TONGUE" and fabricating random negative balances).
- **Core issue**: The internal OCR capabilities of sub-15B parameter VLMs are currently insufficient for precise financial document extraction compared to dedicated native OCR binaries (like Google ML Kit).
- **Final Decision (Reversion)**: The project will heavily favor the **Option 1 Architecture**: On-Device Native OCR (`react-native-text-recognition`) -> Local LLM Text Parsing (`qwen2.5`) -> User Manual Correction for OCR edge-cases.
- **Conclusion**: Local VLMs cannot replace the OCR pipeline on edge-devices yet due to latency (~20s) and hallucination constraints. Paid Cloud VLMs (Claude 3.5 Sonnet / GPT-4o) remain the only viable "perfect" AI vision solution, which violates the app's free/offline requirement.

### Re-evaluating VLMs on 24GB RAM Macs

If the Mac Mini has 24GB of Unified Memory, it can run significantly larger quantized Vision Language Models than the 8B class we tested (like minicpm-v). Models in the 30B-40B parameter range have vastly superior structural reasoning capabilities for receipts without the severe hallucinations of smaller models.

### Limitation: Native Document Scanner Flash Control

- **Issue**: Attempted to configure `react-native-document-scanner-plugin` to force the camera flash ON by default to improve OCR contrast.
- **Root Cause**: The React Native plugin is a thin wrapper around iOS `VNDocumentCameraViewController` and Android's `GmsDocumentScanner`. Both Google and Apple strictly control this specific UI. They do not expose a public API property to third-party developers to toggle the device flash programmatically.
- **Workaround**: The user must tap the flash icon manually in the native scanning UI overlay.

### Error: Supabase Edge Function Deno Parsing Error

- **Encountered**: `The module's source code could not be parsed: Expected unicode escape` when running `npx supabase functions deploy`.
- **Cause**: Using an improperly escaped literal backslash before a template literal backtick (e.g., `\\`OpenAI API error\``) inside the `index.ts` file, leading Deno to throw a compilation error during deployment.
- **Solution**: Removed the backslashes and used standard unescaped backticks for string interpolation. Allowed the function to deploy successfully.

### Error: Missing Native Module "ExponentPedometer" on Android

- **Encountered**: `Cannot find native module 'ExponentPedometer'` crashing the app when importing `LightSensor` from `expo-sensors`.
- **Cause**: Importing from the root `expo-sensors` dynamically evaluates all 8 sensors inside the package immediately on start. In custom native builds where the Pedometer module was excluded by Gradle or lacked the `ACTIVITY_RECOGNITION` permission, this evaluation threw a fatal React error.
- **Solution**: Bypassed the main package index completely by importing the explicit internal path: `import LightSensor from 'expo-sensors/build/LightSensor';` which successfully loads only the precise native C++ bindings for the light hardware without triggering the pedometer. Ultimately removed the `LightSensor` dependency entirely to unblock Android builds.

### Architectural Decision: Sunsetting Local ML-Kit OCR + Qwen

- **Context**: Initially attempted to build a completely free, offline-first parsing engine using `react-native-ml-kit/text-recognition` combined with a local Ollama `Qwen2.5-14B` model.
- **Problem**: Physical receipt photos vary wildly in clarity (shadows, faded thermal ink, wrinkles). Pure OCR engines strictly read visible characters. When an OCR engine drops a single price due to a shadow, the local VLM (which only sees the text string, not the photo) loses positional context, causing massive alignment failures between product names and prices.
- **Solution**: Shifted entirely to a **Cloud Vision architecture (GPT-4o-mini via Supabase Edge Functions)**. By sending the actual raw Base64 image directly to the VLM, the AI acts as both the "eyes" and the "brain," allowing it to use spatial and contextual reasoning to deduce prices obscured by shadows or creases. At ~$0.0015 per scan, the dramatic increase in accuracy entirely superseded the need for a local fallback.

### Error: Expo File System Legacy Crash (FilePermissionService)

- **Encountered**: `java.lang.NoClassDefFoundError: Failed resolution of: Lexpo/modules/kotlin/services/FilePermissionService$Permission;` when calling `readAsStringAsync` after picking an image on Android.
- **Cause**: Using the legacy import `import { readAsStringAsync } from 'expo-file-system/legacy'` on newer Expo File System versions (SDK 52/55 level) can cause a crash on native Android because it expects a Kotlin class (`FilePermissionService$Permission`) that has been refactored or removed from the core `expo` package in newer Expo versions.
- **Solution**: Migrated away from the legacy functional API to the new object-oriented File API: `import { File } from 'expo-file-system'; const base64Image = await new File(imageUri).base64();`. This fully bypasses the deprecated Kotlin native methods that throw the NoClassDefFoundError.

### Error: Expo Modules "NoSuchMethodError" on Android (Version Mismatch)

- **Encountered**: `Call to function 'FileSystemFile.constructor' has been rejected. Caused by: java.lang.NoSuchMethodError: ... in class Lexpo/modules/kotlin/sharedobjects/SharedObject;` on Android when calling `new File(imageUri)`.
- **Cause**: The `expo-file-system` package was installed at version `^55.0.10`, which was compiled for a newer `expo-modules-core` runtime, but the main `expo` package in `package.json` was on `~54.0.33`. This version mismatch caused the runtime method signatures for standard Expo Kotlin objects to break.
- **Solution**: Ran `npx expo install --fix` which automatically downgraded `expo-file-system` to the perfectly compatible `~19.0.21` version. **Crucially**, because this changes the native dependencies, the user must run `npx expo run:android` or recompile using Android Studio to rebuild the Android application binary, otherwise the old mismatched code remains cached on the emulator/device.

### Lesson: AI Prompt Engineering for Receipts (Weights & Discounts)

- **Problem**: When moving to the Cloud VLM (GPT-4o-mini), the AI successfully parsed standard items but completely ignored grocery weights (e.g. `1.177 kg Banana`) and skipped store discounts.
- **Solution**: The accuracy of a Language Model is entirely dependent on the strictness of the JSON prompt schema.
- Updated the Edge Function prompt to strictly enforce:
  1. Append the literal weight string (`1.177 kg`) to the item `name` for UI clarity.
  2. Map the weight float (`1.177`) to the item `quantity` (since `1.177 * 1.59/kg = Total Price`).
  3. Explicitly detect `ALE` / `Alennus` discount lines and either subtract them from the item total or return them as negative-price line items.
- Result: Standardized data structures dynamically handled by the model.

### Error: Supabase Edge Function "401 Unauthorized" (JWT)

- **Encountered**: When testing the Cloud Parser, the mobile app threw `[Error: Cloud parsing failed to return data.]`. The Android logcat reported: `[FunctionsHttpError: Edge Function returned a non-2xx status code]` with `status: 401`.
- **Cause**: By default, Supabase Edge Functions require a valid user JWT (`Authorization` header) to be executed. When we redeployed the Edge Function to update the LLM prompt using just `npx supabase functions deploy parse-receipt`, it overwrote the previous deployment configurations and re-enabled the default JWT protection, blocking the unauthenticated mobile app from invoking it.
- **Solution**: The function must be deployed with the explicit flag to bypass token verification for public or system-level endpoints:
  `npx supabase functions deploy parse-receipt --no-verify-jwt`.

### Lesson: AI Prompt Engineering for Pre-Discounted Items (Double Deduction)

- **Problem**: The AI parser successfully found discounts (e.g. `KAMPANJA -0,80`) but incorrectly added them as separate negative line items while the main item's price (e.g. PEPSI `2,19`) was _already_ discounted on the physical receipt. This resulted in the app double-deducting the discount (Final parsed cost: `1.39` instead of `2.19`).
- **Cause**: Our initial prompt instructed the AI to "strictly extract all discounts... list them as a separate item". We failed to account for Finnish retail formats where discounts are printed compositionally beneath an item but the right-hand total is the _final net sum_.
- **Solution**: We removed hardcoded Finnish layout assumptions (like looking for "NORM." or "KAMPANJA") from the AI prompt, as this is brittle and won't safely scale globally. Instead, we instructed GPT-4o-mini to rely strictly on **mathematical consistency**. The prompt now enforces that the sum of the extracted item totals `MUST` equal the receipt's final total, and warns the AI _not_ to extract informational discount text if it breaks the math.

### Error: Deno TypeScript Types vs React Native IDE

- **Encountered**: When writing Supabase Edge Functions in the `supabase/functions` directory, VS Code threw TypeScript errors (e.g. `Cannot find name 'Deno'` or `URL imports are not supported`).
- **Cause**: Edge Functions run on Deno, but the root workspace is configured for React Native and Node.js.
- **Solution**: To avoid complicating the workspace with Deno-specific VS Code extensions that might conflict with React Native, we explicitly suppressed these Deno-specific types with `// @ts-ignore`. The code compiles and deploys perfectly on the Supabase infrastructure.

### Architecture: Supabase Edge Function Error Swallowing

- **Problem**: When an Edge Function throws a hard native error (`throw new Error("Failed connecting")`), the Supabase client library on the mobile app often swallows the exact string message and returns a generic `500 Internal Server Error` or throws an exception that crashes the UI layer.
- **Solution**: Edge Functions were refactored to wrap their entire execution in a `try/catch` block. Rather than throwing, they always return a `200 OK` status, but package the error inside the JSON body: `new Response(JSON.stringify({ error: err.message }), { status: 200 })`. This allows the React Native client to gracefully read the explicit error and display an actionable toast to the user without blowing up the HTTP layer.

### Error: React Native UI Flashing on App Load

- **Encountered**: When launching the app, screens like `index.tsx` or `settings.tsx` would briefly flash default values ("Morning, there" or "Guest") for a split second before the real user data appeared.
- **Cause**: The `useAuth()` hook asynchronously checks the Supabase session on mount. Before that async check finishes, the layout tree renders the screen using the default `null` state of the user object.
- **Solution**: Implemented an explicit bypass guard utilizing `useAuth().isLoading` directly inside the individual screens. Rather than attempting to block the monolithic layout tree (which visually breaks Expo Router navigation), the screens now return a blank `<View>` colored identically to the app's `theme.colors.background` while loading. This seamlessly extends the visual duration of the native splash screen until the auth state is fully hydrated.

### Architecture: "No Hardcoded Repetitive JSX" Rule

- **Problem**: Layout files (`_layout.tsx`) and forms (`auth.tsx`, `settings.tsx`) became bloated with manually copy-pasted `<Tabs.Screen>`, `<TextInput>`, or `<SettingsRow>` components. This made the codebase harder to maintain and prone to copy-paste errors.
- **Solution**: Enforced a strict codebase standard where 3+ repetitive UI elements must be dynamically mapped from a configuration array (`const NAV_SCREENS = [...]` or `const TAX_RULES = [...]`).
  - Static lists (like tab names) are moved completely _outside_ the React component to prevent unnecessary memory reallocation.
  - Dynamic lists (like form inputs needing `onChangeText` state bindings) are configured _inside_ the component but still mapped over returning standardized JSX.
  - Result: The code is substantially DRY-er, self-documenting, and dramatically scales down file line lengths.

---

## 8. 3-Level Item Taxonomy & Analytics Architecture

### Architecture: Super Category → Category → Subcategory Classification

- **Decision**: Instead of a flat single-level category per receipt item, the app uses a 3-level taxonomy (`super_category` → `category` → `subcategory`) stored on `canonical_items`.
- **Why**: Enables drill-down analytics — users can see "Food" → "Dairy" → "Milk" and navigate progressively into their spending, rather than a flat pile of unrelated items.
- **Implementation**: The `normalize-items` Supabase Edge Function handles the classification after a receipt is saved, mapping raw item strings to canonical entries via `item_aliases`. User overrides are stored in `item_classification_overrides` so manual corrections persist.
- **Lesson**: Putting taxonomy ownership in the backend (Edge Function) rather than the client keeps the mobile app lightweight and allows classification logic to be updated without an app release.

### Architecture: Zustand Stores as Data Layer

- **Decision**: Created three purpose-specific stores (`useTrendsStore`, `useItemAnalyticsStore`, `useInsightsStore`) rather than one mega-store.
- **Why**: Each store corresponds to a distinct screen and data source. Merging them would cause unnecessary re-renders and tightly couple unrelated data.
- **Lesson**: Zustand stores should ideally map 1:1 to a screen's data requirements. Cross-screen state (`usePendingReceiptStore`) is the exception, not the rule.

### Error: Category Filter Query Returning All Items

- **Encountered**: The category drill-down screen (e.g. tapping "Dairy") was returning items from every category instead of just the selected one.
- **Cause**: The Supabase query was filtering on `canonical_items.category` but the join alias used in the select path did not correctly propagate the filter to the joined table, effectively making the `WHERE` clause a no-op.
- **Solution**: Rewrote the query to explicitly use the foreign key join path and verified the filter was applied against the correct aliased column. Always test Supabase queries with `supabase.from(...).select(...).eq(...)` in isolation in the Supabase dashboard before wiring into stores.

---

## 9. Neumorphic / Glassmorphic Design System

### Architecture: NeoTheme as Single Source of Design Truth

- **Decision**: Introduced `constants/NeoTheme.ts` as the app-wide design token file replacing ad-hoc `useTheme()` calls from `react-native-paper`.
- **Why**: `react-native-paper`'s theme system is designed for Material You and conflicts stylistically with a custom dark neumorphic visual language. Mixing both creates inconsistency.
- **Lesson**: Once a custom design system exists, commit to it fully. Half-migrations (some screens using `useTheme()`, others using `NeoTheme`) cause visual inconsistency that accumulates over time.

### Architecture: GlassCard as the Structural Primitive

- **Decision**: `GlassCard` is the mandatory card/surface wrapper. `showGradient={false}` is used for list rows and secondary cards; `showGradient={true}` for hero/primary surfaces.
- **Lesson**: Defining these conventions explicitly in the component's props prevents ad-hoc overrides. When someone adds a new screen, they know exactly what variant to use without reading all prior code.

### Error: White Space / Flash Around Merchant Logo

- **Encountered**: `MerchantLogo.tsx` displayed a white border artifact around store logos on the dark neumorphic background.
- **Cause**: The `<Image>` component's default background was white and was visible during the brief period before the image loaded.
- **Solution**: Added `backgroundColor: 'transparent'` to the image container style and ensured the parent card's background matched the app's dark surface color. Always set explicit `backgroundColor` on image containers in dark-theme apps.

### Lesson: Swipe-to-Delete Theming

- **Decision**: Removed the "Delete" text label from swipe actions across `scan-result.tsx` and `history.tsx`. Icon-only with a dark background (`NeoTheme.colors.bgCard`) replaces the default jarring red slab.
- **Why**: The red full-width delete background broke the visual language of the neumorphic design. A subtle dark container with a red trash icon is consistent and less visually aggressive.

---

## 10. Receipt Parsing Refinements

### Lesson: `hasEditedItems` Flag for Total Accuracy

- **Problem**: The `scan-overview.tsx` screen was always recalculating the grand total by summing line items, even when the user had not changed anything. This diverged from the printed receipt total and confused users.
- **Solution**: Added a `hasEditedItems` flag to `usePendingReceiptStore`. The overview screen uses the AI-parsed original total by default, and only switches to the calculated sum when the user actually edits a line item. This preserved the "READ THE RECEIPT, DO NOT RE-CALCULATE" principle.

### Lesson: Discount Line Items as Negative Values

- **Problem**: The AI parser was extracting discounts as separate positive-value items with a "discount" label, which visually looked like an extra purchase rather than a deduction.
- **Solution**: Updated the Edge Function prompt to explicitly return discount/coupon lines as negative `total` values. The UI naturally renders them as subtractions without any special-casing in the component layer.

### Error: Supabase Edge Function Payload Too Large

- **Encountered**: `413 Request Entity Too Large` when sending a high-resolution receipt image to the `parse-receipt` Edge Function.
- **Cause**: The default Supabase Edge Function body size limit is 2MB. Uncompressed Base64 images from modern phone cameras can easily be 4–8MB.
- **Solution**: Compressed images before encoding to Base64 using `expo-image-manipulator` (resized to max 1024px width, quality 0.7 JPEG). This brought payloads consistently under 1MB without meaningfully sacrificing OCR accuracy for the Vision LLM.

---

## 11. Code Quality & Refactoring Standards

### Lesson: Component File Size Enforcement
- **Problem**: Screens like `edit-receipt.tsx` grew to 636 lines as features were added incrementally. Reading, reviewing, and maintaining the file became progressively harder.
- **Solution**: Established a hard rule: screens must stay under 200–300 lines; JSX blocks under 50 lines. Files that exceed this must be refactored before new features are added. Extracted components like `ReceiptImagePreview` and `VatTable` to standalone files.
- **Lesson**: Incremental growth is the enemy of readability. Establish the size limit *before* it becomes painful, not after.

### Lesson: Strict Extraction of Styles
- **Problem**: Long `StyleSheet.create` blocks at the bottom of React Native components artificially bloat file size and mix logic with presentation. A 300-line screen might consist of 100 lines of logic/JSX and 200 lines of styles.
- **Solution**: Extract *all* styles to a dedicated `styles/` folder (e.g., `styles/homeStyles.ts`). This ensures the component file only contains the actual structural logic and UI rendering, dramatically increasing the signal-to-noise ratio when scanning the component logic. This rule strictly applies globally across all files.

### Lesson: TypeScript Check as a Refactor Gate

- **Rule Added**: `npx tsc --noEmit` must return zero errors after every refactor. This is a hard gate — not a recommendation. Catching type errors at the component level prevents subtle runtime bugs that are very hard to trace on a physical device.

### Architecture: Logic vs. Presentation Separation

- **Rule**: Zustand stores hold all data fetching, business logic, and side effects. Screen components are purely presentational. This was enforced after several screens accumulated direct `supabase.from(...)` calls that should have lived in stores.
- **Benefit**: Screens become easier to test and reason about in isolation. Swapping the data source (e.g. local SQLite for offline mode) requires changes only in the store, not in every screen.

### Lesson: Model Selection for Git Operations

- **Rule Added**: When performing git staging, committing, or pushing, switch to a lower-tier model (e.g. Gemini Flash or Claude Haiku). Reserve reasoning-capable models (Sonnet/Opus/Pro) exclusively for architecture decisions, complex debugging, and multi-file refactors where reasoning depth matters.
- **Why**: Git operations are mechanical and deterministic. Using a premium model for `git add` and `git commit -m` is wasteful and adds no value.

### Lesson: Splitting Commits & Git Staging Behavior

- **Problem**: When trying to fix a commit that accidentally included too many files (e.g. 15 files) using `git reset --soft HEAD~1` followed immediately by `git add file1 file2` and a new `git commit`—the new commit still bizarrely contained all 15 original files.
- **Cause**: The `--soft` flag cleanly rolls back the commit, but crucially, it leaves all 15 of those files *already staged* in the git index. Any new `git commit` command simply bundles your explicit `git add` selections alongside everything already waiting in the index queue.
- **Solution**: When splitting a previously large commit into smaller atomic commits, you must explicitly dump the index back into the working directory first using a mixed reset:
  
  ```bash
  # 1. Roll back the commit BUT keep the files in the index (staged)
  git reset --soft HEAD~1
  
  # 2. Dump the index queue back to unstaged working files (CRITICAL STEP)
  git reset
  
  # 3. Now stage and commit in safe <3 file chunks
  git add app/auth.tsx styles/authStyles.ts
  git commit -m "refactor: extract auth screen styles"
  
  # 4. Force push the rewritten history safely
  git push --force origin main
  ```

---

## 12. Codebase Standardization: Utilities & Currency

**Problem:** Utility functions (like date formatting) and currency symbol logic were duplicated across multiple screens (`index.tsx`, `history.tsx`, `trends.tsx`), making the codebase hard to maintain and prone to inconsistent UI.

**Solution:**
- Created `lib/utils.ts` to house shared logic like `normalizeDate` and `formatDisplayDate`.
- Created `lib/currencySymbol.ts` with a centralized `getCurrencySymbol` function.
- Refactored all screens to import these from the library rather than defining them locally.

**Lesson Learned:** As a project grows, centralizing "pure" logic into a `lib/` or `utils/` folder is a mandatory refactoring gate to maintain DRY (Don't Repeat Yourself) principles.

---

## 13. React Native Memory Leak Prevention

**Problem:** Received "Can't perform a React state update on an unmounted component" warnings. These occur when an asynchronous operation (like fetching data or a timer) completes after the user has already navigated away from the screen.

**The Solutions:**

1. **`isMounted` Ref Guard:** 
   ```tsx
   const isMounted = useRef(true);
   useEffect(() => {
     return () => { isMounted.current = false; };
   }, []);

   const handleAsync = async () => {
     const data = await fetch();
     if (isMounted.current) setState(data);
   };
   ```
2. **Animation Cleanup:** Always call `.stop()` on looping animations (like `Animated.loop`) in the `useEffect` cleanup function to prevent background CPU usage and memory leaks.

## 14. Core Database Security: Supabase RLS

**Problem:** The Supabase Security Advisor flagged 15+ public tables as missing Row Level Security (RLS). By default, any authenticated user could potentially read or modify any other user's data.

---

## 15. Advanced React Native Performance Optimizations

### Lesson: The Zustand Re-render Trap
**Problem:** In Zustand, destructuring a whole store (e.g., `const { receipts, loading } = useReceiptStore()`) causes the component to re-render every time *any* property inside `useReceiptStore` changes, even properties it doesn't use.
**Solution:** Wrap the selector function in `useShallow` from `zustand/react/shallow`. This checks for structural equality and completely eliminates "phantom re-renders." This is critical for high-frequency stores like receipts and synchronization states.

### Lesson: FlatList vs. FlashList
**Problem:** Rendering 100+ receipt cards with React Native's core `FlatList` consumed massive amounts of memory and jittered on slow phones because it constantly mounts and unmounts views. Wrapping `renderItem` in `useCallback` only added more memory overhead without solving the underlying native mount cycle.
**Solution:** Extracted the row to a pure component `ReceiptListItem` and migrated the list to Shopify's `@shopify/flash-list`. `FlashList` uses true native cell recycling (it reuses the same 12 UI containers on screen and just swaps the data prop), dramatically dropping steady-state RAM usage and locking the scroll framerate to 60fps.

### Lesson: Image Disk Caching (OOM crashes)
**Problem:** Users scrolling through highly-detailed receipt photos or dozens of merchant logos risk encountering Android "Out of Memory" (OOM) crashes because React Native's default `<Image>` component is notoriously poor at eagerly clearing its memory cache. 
**Solution:** Replaced `<Image>` with `expo-image`. It uses advanced native disk-caching libraries (Glide for Android, SDWebImage for iOS) under the hood. This seamlessly manages aggressive disk caching, freeing up the JS thread and preventing image bloat from crashing the app.

**The Solution:**
1. **Enable RLS** on every public table via migration.
2. **Direct Policies:** For `receipts`, `budgets`, etc., use `(user_id = auth.uid())`.
3. **Indirect Policies:** For child tables like `receipt_items`, use an `EXISTS` check on the parent table:
   ```sql
   USING (EXISTS (SELECT 1 FROM receipts WHERE receipts.id = receipt_items.receipt_id AND receipts.user_id = auth.uid()))
   ```
4. **Function Security:** Set `search_path = ''` on SQL functions (`handle_new_user`, `set_updated_at`) to prevent privilege escalation via malicious search path manipulation.
5. **Auth Security:** Enable **Leaked Password Protection** in the Supabase Dashboard to block compromised passwords.

**Lesson Learned:** Database security should be baked into the initial schema design. Retrofitting RLS requires careful mapping of ownership (Direct vs. Indirect vs. Shared Reference) for every single table.

---

## 16. Receipt Parsing Globalization & AI Categorization

### Lesson: Payment Method Normalization
- **Problem**: Receipts from different countries use localized terms (e.g., "Käteinen", "Kortti", "Tiền mặt"). This makes financial analytics difficult.
- **Solution**: Added Rule 12 to the Edge Function VLM prompt to strictly normalize all payment methods into universal English terms (`Cash`, `Credit Card`, `Debit Card`, `Mobile Payment`). This simplifies the database schema and reporting logic.

### Lesson: Inferring Category from Merchant Names (`store_category_hint`)
- **Problem**: New scans often defaulted to "General" if the specific item taxonomy wasn't yet finalized, which is poor for immediate user feedback.
- **Solution**: Added Rule 13 to the AI prompt to extract a `store_category_hint` (e.g., "groceries" if store name is "Lidl"). This hint is used as a default category in the `usePendingReceiptStore` on scan, significantly improving "out-of-the-box" accuracy for non-English merchants.

---

## 17. Loading UI Orchestration: Splash to Data

### Lesson: Bridging the "Auth Gap"
- **Problem**: App was flashing a blank screen between the Native Splash screen and the Home screen rendering.
- **Solution**: Moved `SplashScreen.hideAsync()` in `app/_layout.tsx` to execute *only* after `!isLoading` (auth check resolves). This stretches the native splash screen until the app's internal Auth state is hydrated.

### Lesson: Hiding Persistent Navigation during Hydration
- **Problem**: Constant elements like the `CustomTabBar` would render immediately, but screens would be empty while waiting for the database (`useReceiptStore.loading`).
- **Solution**: Added an `if (authLoading || receiptsLoading) return null;` early return to the `CustomTabBar`. This ensures a clean data-void UI where the user only sees the full-screen skeleton animation until all layers are ready.

---

## 18. Neumorphic / Glassmorphic Refinements

### Lesson: The Nested "borderRadius" rendering trap
- **Problem**: A subtle "ghost card" or double-layer effect was visible behind the `GlassCard` component.
- **Cause**: The `contentStyle` prop passed an inner `borderRadius: 24` to a child View, while the `GlassCard` wrapper also had `borderRadius: 24`. In React Native (especially Android), two identical nested rounded shapes can create a slight visual offset/artifact where the anti-aliasing pixels don't perfectly overlap.
- **Solution**: Removed the `borderRadius` from the inner `contentStyle` and relied solely on the outer wrapper's `borderRadius` with `overflow: 'hidden'`.

### Lesson: Asymmetric vs Symmetric Borders
- **Problem**: Using `borderTopWidth: 1` but `borderWidth: 0.5` on other sides for a "light sheen" effect resulted in visible size mismatches at the corners.
- **Solution**: Switched to a uniform `borderWidth: 0.5`. Depth is better handled via subtle color transparency (`rgba(255, 255, 255, 0.08)`) and the SVG gradient overlay than by adjusting physical border widths.

---

## 19. Database Maintenance: SQL Backfills

### Lesson: Pattern-matching migrations for taxonomy changes
- **Goal**: Update thousands of existing "General" receipts to correct categories after a taxonomy upgrade.
- **Solution**: Used SQL `ILIKE '%pattern%'` in migrations to retroactively map merchant names to categories (e.g., `%apteekki%` -> `health`). 
- **Learning**: Database backfilling logic should be documented as a migration file rather than run as a manual script. This ensures consistency between local dev and remote production databases.


---

## 20. Analytics Integrity & Edge Function Synchronization

### Lesson: Maintaining Normalization on Receipt Edits
- **Problem**: When a user edited a receipt's line items, the app was deleting and re-inserting the items in the database. However, this process completely bypassed the `normalize-items` Supabase Edge Function.
- **Result**: Edited receipts immediately lost all their analytics tags/categories, causing them to disappear from category drill-down screens.
- **Solution**: Added an explicit invocation of `supabase.functions.invoke('normalize-items', ...)` in `scan-overview.tsx` immediately after saving an edited receipt. This ensures that every time data changes, it is re-processed for analytics.
- **Golden Rule**: Any operation that modifies the "Source of Truth" (receipts or items) must trigger the downstream normalization pipeline.

### Lesson: Global History Filtering vs. 28-Day Cache
- **Problem**: The History screen's category filter was using a `receiptSuperCategoryMap` generated by a backend query limited to the last 28 days.
- **Result**: Receipts older than a month appeared in the "All" list but vanished when the user clicked a filter pill (e.g., "Groceries"), leading to apparent "data loss."
- **Solution**: Refactored the category calculation to be local and global. The `useReceiptStore` now scans the *entire* locally persisted receipts array to determine `availableCategories`. This is faster (prevents a network round-trip), 100% accurate, and works for receipts of any age.

---

## 21. Merchant Branding Architecture (VLM-Driven Logos)

### Lesson: Sunsetting Clearbit for AI-Provided Domains
- **Problem**: Using the Clearbit Autocomplete API to guess merchant logos based on the "first word" of a store name was brittle and led to wrong logos (e.g., "S-Market Kontula" resolved to a betting site `smarkets.com`).
- **Solution**: Shifted entirely to **AI-provided domain resolution**.
  1. The Cloud VLM (GPT-4o) extracts the correct `merchant_domain` (e.g., `s-kaupat.fi` for Finnish S-Market) during the initial scan.
  2. The domain is stored in the receipt's `metadata`.
  3. `MerchantLogo.tsx` uses this domain with the **Google Favicon API** (`https://t3.gstatic.com/faviconV2?...`).
- **Benefit**: This architecture provides perfect global accuracy without needing localized brand maps or external autocomplete APIs. It leverages GPT's contextual understanding of languages and markets.

### Lesson: Logo Rendering Artifiacts (Square in Circle)
- **Problem**: Many favicons from the Google API are square with white backgrounds that leak out of the circular UI containers, even with `resizeMode="cover"`.
- **Solution**: Added `transform: [{ scale: 1.2 }]` to the `<Image>` component inside `MerchantLogo.tsx`. By slightly over-scaling the image relative to its `overflow: 'hidden'` container, the white corner pixels are cleanly clipped away, leaving a perfect bleed-to-edge logo.

---

## 22. UI Fidelity & Input Handling

### Lesson: Numeric Input Enforcement on Android/iOS
- **Problem**: Users were accidentally typing alphabetical characters or invalid symbols into "Qty" and "Price" fields, causing math errors.
- **Solution**: Implemented a two-layered defense:
  1. **Native Keyboard**: Used `keyboardType="numeric"` (dialer-style) instead of `decimal-pad` to completely block alphabet access at the OS level.
  2. **Regex Filtering**: Added a `replace(/[^0-9.,]/g, '')` filter in the `onChangeText` handler to catch invalid paste operations or unsupported characters.
- **Lesson**: Never trust the native keyboard type alone; always sanitize the incoming string in the JS thread.

### Lesson: Local State for Decimal Input Interaction
- **Problem**: When editing prices, users found it impossible to type a dot (`.`) because the state-controlled `value` would immediately parse the trailing dot and strip it if it didn't have a trailing digit yet.
- **Solution**: Maintain a local "raw" string state for the text input during the editing session, and only commit/parse the number to the global store on `blur` or when the user saves. This allows a natural typing experience for decimals.

---

## 23. Caching & Performance Patterns

### Lesson: Multi-Month Caching with `cacheMap`
- **Problem**: In the Trends screen, switching between months required a fresh database query every time, causing the UI to flicker or show spinning loaders even if the user was just navigating back and forth between January and February.
- **Solution**: Implemented a `cacheMap: Record<string, CachedTrendData>` in `useTrendsStore`.
  - When a month is fetched, the results are stored in the map using a key like `monthly-2024-1`.
  - Navigating back to an old month now results in an **instant** UI render using the cached values.
- **Benefit**: Zero-latency navigation for previously viewed data.

### Lesson: Stale-While-Revalidate (SWR) Logic
- **Problem**: Even with a cache, the data might be old (e.g., if the user scanned a new receipt while looking at the Trends screen).
- **Solution**: The `fetchTrends` action uses an SWR approach:
  1. Check if cache exists for the month.
  2. If YES: Populate the UI instantly from cache but set `backgroundRefreshing: true`.
  3. Perform a fresh background query to Supabase.
  4. Once fresh data arrives, update the UI and the cache silently.
- **Benefit**: The UI is always responsive (no blockers) but eventually consistent.

### Lesson: Deep vs. Partial Persistence
- **Problem**: Persisting an entire Zustand store to `AsyncStorage` can lead to performance degradation if the store contains temporary state (like `loading` or large lists that change constantly).
- **Solution**: Used the `partialize` feature of Zustand's `persist` middleware.
  - In `useReceiptStore`, we only persist crucial data like the 14-day chart data and 4-week category breakdown.
  - In `useTrendsStore`, we only persist the `cacheMap`.
- **Benefit**: Drastically reduces disk I/O and app startup time by avoiding serialization of transient UI states.

### Lesson: Image Disk Caching with `expo-image`
- **Problem**: Scrolling through History lists or Category details caused image "flashing" or high memory usage when using standard React Native `<Image>` components.
- **Solution**: Switched to `expo-image`. It handles native disk and memory caching automatically on both Android (Glide) and iOS (SDWebImage).
- **Benefit**: Significantly smoother scroll performance and lower risk of Out-of-Memory (OOM) crashes on low-end devices.

