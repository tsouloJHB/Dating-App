# JustHookUps

This project was created with [Better-T-Stack](https://github.com/AmanVarshney01/create-better-t-stack), a modern TypeScript stack that combines Hono, and more.

## Features

- **TypeScript** - For type safety and improved developer experience
- **Hono** - Lightweight, performant server framework
- **workers** - Runtime environment
- **Drizzle** - TypeScript-first ORM
- **PostgreSQL** - Database engine
- **Authentication** - Better-Auth
- **Biome** - Linting and formatting
- **Turborepo** - Optimized monorepo build system

## Design References

Use `templets/` as the screen design reference source for implementation and reviews.

- Auth: `templets/sign_in_light_mode/code.html`, `templets/sign_up_light_mode/code.html`
- Discover: `templets/discover_light_mode/code.html`, `templets/discover_profile_card/code.html`
- Activity/Inbox: `templets/who_liked_me_light_mode/code.html`, `templets/profile_visitors_light_mode/code.html`, `templets/matches_grid_light_mode/code.html`, `templets/activity_messages/code.html`
- Profile detail: `templets/profile_detail_view/code.html`
- Theme docs: `templets/midnight_crimson/DESIGN.md`, `templets/obsidian_ember/DESIGN.md`

## Getting Started

First, install the dependencies:

```bash
pnpm install
```

## Database Setup

This project uses PostgreSQL with Drizzle ORM.

1. Make sure you have a PostgreSQL database set up.
2. Update your `apps/server/.env` file with your PostgreSQL connection details.

3. Apply the schema to your database:

```bash
pnpm run db:push
```

Then, run the development server:

```bash
pnpm run dev
```

The API is running at [http://localhost:3000](http://localhost:3000).

## Deployment (Cloudflare via Alchemy)

- Dev: cd apps/server && pnpm run dev
- Deploy: cd apps/server && pnpm run deploy
- Destroy: cd apps/server && pnpm run destroy

For more details, see the guide on [Deploying to Cloudflare with Alchemy](https://www.better-t-stack.dev/docs/guides/cloudflare-alchemy).

## Git Hooks and Formatting

- Format and lint fix: `pnpm run check`

## Project Structure

```
JustHookUps/
├── apps/
│   └── server/      # Backend API (Hono)
├── packages/
│   ├── auth/        # Authentication configuration & logic
│   └── db/          # Database schema & queries
```

## Available Scripts

- `pnpm run dev`: Start all applications in development mode
- `pnpm run build`: Build all applications
- `pnpm run dev:server`: Start only the server
- `pnpm run check-types`: Check TypeScript types across all apps
- `pnpm run db:push`: Push schema changes to database
- `pnpm run db:generate`: Generate database client/types
- `pnpm run db:migrate`: Run database migrations
- `pnpm run db:studio`: Open database studio UI
- `pnpm run check`: Run Biome formatting and linting
