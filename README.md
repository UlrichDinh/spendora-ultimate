# Spendora Monorepo

Welcome to the Spendora project! This repository serves as the container for the separate frontend and backend segments of the application. 

This separation ensures that sensitive intellectual property (e.g., AI parsing prompts, database schema, and server-side configurations) is isolated from the UI code. 

## Structure

```text
spendora/
├── spendora/              # React Native UI App (Expo)
└── spendora-backend/      # Supabase Edge Functions, Migrations, and Secrets
```

---

## 👨‍💻 Guidance for Newcomers (Contractors/Frontend Devs)

New developers will **ONLY** be given access to the `spendora` codebase. They do not need (and should not have) access to `spendora-backend`.

### 1. Project Setup
1. Clone the `spendora` repository.
2. Install dependencies:
   ```bash
   cd spendora
   npm install
   ```

### 2. Environment Variables
You will need a `.env` file to connect the UI to the staging backend. 
1. Copy the example file:
   ```bash
   cp .env.example .env
   ```
2. The project owner will provide you with the **Staging Supabase URL** and **Staging Anon Key** to place into this `.env` file. These keys safely point to a sandbox database.

### 3. Running the App
Start the Expo development server:
```bash
npm run dev
# or
npx expo start
```
You can now build UI screens, create components, and bind them to the existing Zustand stores without worrying about breaking the production database or seeing the protected AI logic.

---

## 👑 Guidance for the Owner (You)

As the project owner, you have control over both repositories. You will manage the production keys and the core AI parsing intelligence.

### 1. Developing Full-Stack Features
When you need to adjust database schemas or edit the AI parsing logic:
1. Navigate to `.env` in `spendora-backend` for your production credentials.
2. Modify the SQL migrations in `spendora-backend/supabase/migrations/`.
3. Modify the edge functions in `spendora-backend/supabase/functions/`.
4. Deploy the backend updates using the Supabase CLI from the `spendora-backend` directory:
   ```bash
   cd spendora-backend
   supabase functions deploy parse-receipt --project-ref <your-proj-id>
   ```

### 2. Staging vs Production
- **Staging**: You maintain a separate `spendora-staging` Supabase project. You configure the edge functions and database schema here first. You provide the contractor with keys to *this* project so they can test their UI against real data endpoints.
- **Production**: Your production instances (`spendora-backend/.env`) are kept strictly private on your computer.

### 3. Managing the Repositories
Since they are two separate Git repositories:
- `spendora`: You can freely push this to a shared GitHub repo and invite your contractor.
- `spendora-backend`: You should push this to a **completely separate, private** GitHub repository where you are the sole contributor.
