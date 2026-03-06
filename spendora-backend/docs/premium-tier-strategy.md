# Spendora Freemium Strategy & Premium Tier Implementation

## Strategy: The "Freemium" Model
The goal of the Free tier is to let users experience the core value of the app locally, but limit expensive AI and cloud costs. The Premium tier offers total automation, deep data mining, and unlimited cloud backup.

### 🟢 Normal User (Free Tier)
*   **Scanning:** **3 to 5 AI Scans per month**. (Giving them a taste of the magic is crucial for conversion. Once they run out, they have to type receipts manually).
*   **Manual Entry:** Unlimited manual receipt creation and item typing.
*   **Analytics:** **Level 1 Analytics only** (Super Categories like `Groceries`, `Transport`, `Housing`). They can see the big picture pie charts, but nothing deeper.
*   **Storage & Sync:** **Local-first only**, or limited to 30 days of cloud backup. Receipt images are stored in low-resolution to save database space.
*   **Device Limit:** Limited to 1 device.

---

### 👑 Premium User (Pro Tier)
*   **Scanning:** **Unlimited AI Receipt Scanning** (or a high fair-use cap like 500/month).
*   **Deep Item Normalization:** The AI automatically categorizes every single line item (`Groceries → Dairy → Milk`) in the background. Free users have to categorize items manually.
*   **Deep Analytics (3-Level):** Full access to drill down into Categories and Subcategories.
*   **Item Price Tracking:** The ability to see month-over-month price changes for specific items (e.g., "You spent 15% more on eggs this month" or tracking the unit price of Lidl Chicken over a year).
*   **Smart Insights:** Access to the AI-generated actionable summaries (e.g., "You buy coffee on Tuesdays, here is how much you could save").
*   **Storage & Sync:** Unlimited, real-time cloud backup. Full original high-resolution receipt images are saved forever.
*   **Export:** Export receipt data to CSV/Excel for accounting or tax purposes.

---

## 7-Day Auto-Trial Implementation Plan

Every new user automatically gets a **7-Day Premium Trial** to experience the full power of the AI and Deep Analytics. After the trial, they drop to the **Free Tier** unless they subscribe. Existing users also get a fresh 7-day trial.

### 1. Database Schema
Add a `trial_ends_at` column to track the free trial period.

```sql
ALTER TABLE public.users 
ADD COLUMN trial_ends_at TIMESTAMP WITH TIME ZONE;
```

Update the `handle_new_user` trigger so every new user gets 7 days free automatically:
```sql
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.users (id, email, is_premium, trial_ends_at)
  VALUES (NEW.id, NEW.email, false, now() + interval '7 days')
  ON CONFLICT (id) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### 2. App State & Auth Logic (`useReceiptStore.ts`)
Update the logic so a user is considered **Active Premium** if they either paid (`is_premium = true`) OR their trial is still active (`trial_ends_at > now()`).

Expose `trialDaysRemaining` to the UI to show a banner.

### 3. UX & UI (The Paywall)
- **`PremiumPaywall.tsx`**: Create a beautiful, reusable Paywall overlay. If a Free user tries to tap on a Level 2/3 Subcategory chart or access Deep Insights, this Paywall modal will slide up, blurring the background and showing the value proposition.
- **Trial Banner**: Add a subtle banner at the top or bottom of the Dashboard for users in their trial:
  > `✨ 6 Days left of Premium Trial. Explore Deep Insights!`

### 4. Edge Function Limits (Future)
Once a payment provider (RevenueCat/Stripe) is integrated, add logic to the `parse-receipt` Edge Function to reject scans from Free users who have exceeded their 5 free monthly scans.
