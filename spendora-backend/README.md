# spendora-backend

This repository contains all infrastructure and backend logic for the Spendora project.
It is isolated from the main `spendora` (React Native app) repository to protect sensitive intellectual property and credentials.

## Contents
- `supabase/`: Contains Edge Functions (including AI parsing logic), database migrations, and Supabase config.
- `.env`: Contains production API keys and secrets (not committed to git).

## Deployment
Any updates to the edge functions or database schema should be pushed to the staging or production Supabase projects using the Supabase CLI.
