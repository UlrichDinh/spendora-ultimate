repo/
  apps/
    mobile/                 # Expo React Native app
    api/                    # Backend (Express/Fastify/Nest/FastAPI etc.)
    web/                    # Optional: Next.js admin/dashboard
  packages/
    shared/                 # Shared utils (no platform APIs)
    types/                  # Shared TS types (DTOs, API contracts)
    validators/             # Zod/Yup schemas used by api + clients
    ui/                     # Optional: shared design system (RN + web)
    eslint-config/          # Shared lint rules
    tsconfig/               # Shared TS configs
  package.json              # Workspaces root
  turbo.json                # Optional task runner (Turborepo)
  pnpm-workspace.yaml       # If using pnpm
