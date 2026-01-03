# Message Manager - Full-Stack Demo Application

## Overview

Message Manager is a full-stack CRUD application built for QA/DevOps demonstrations. It provides a clean interface for creating, reading, updating, and deleting messages with real-time health monitoring. The application showcases modern web development practices with a focus on type safety, responsive design, and professional user experience.

The application follows a standard three-tier architecture with a React frontend, Express.js backend, and PostgreSQL database, all built with TypeScript for end-to-end type safety.

## User Preferences

Preferred communication style: Simple, everyday language.

## System Architecture

### Frontend Architecture

**Framework**: React 18 with TypeScript and Vite as the build tool

**UI Design System**: Material Design principles implemented through shadcn/ui component library with Tailwind CSS for styling. The design emphasizes utility and clarity over visual complexity, using a card-based layout with consistent spacing (Tailwind units of 4, 6, and 8).

**State Management**: TanStack Query (React Query) handles all server state, data fetching, caching, and synchronization. This eliminates the need for a separate global state management solution for API data.

**Routing**: Wouter provides lightweight client-side routing with minimal bundle impact.

**Form Handling**: React Hook Form with Zod validation ensures type-safe form submissions with declarative validation rules that match the backend schema.

**Theming**: Context-based theme provider supports light/dark mode with localStorage persistence. Theme values are defined using CSS custom properties for consistent styling across components.

**Component Structure**: 
- Page components in `client/src/pages/` (home, not-found)
- Reusable UI components from shadcn/ui in `client/src/components/ui/`
- Custom components like theme-toggle in `client/src/components/`
- Path aliases configured (`@/`, `@shared/`) for clean imports

### Backend Architecture

**Framework**: Express.js with TypeScript running on Node.js 20+

**API Design**: RESTful API with the following endpoints:
- `GET /api/health` - Health check endpoint
- `GET /api/messages` - Retrieve all messages
- `GET /api/messages/:id` - Retrieve single message
- `POST /api/messages` - Create new message
- `PATCH /api/messages/:id` - Update existing message
- `DELETE /api/messages/:id` - Delete message

**Request/Response Handling**: Express middleware stack includes JSON body parsing with raw body preservation for verification scenarios, request logging with timing, and error handling.

**Validation**: Zod schemas defined in shared directory validate all incoming requests, with `zod-validation-error` providing user-friendly error messages.

**Data Access Layer**: Storage abstraction (`IStorage` interface) implemented by `DatabaseStorage` class, allowing for potential alternative storage implementations while keeping route handlers decoupled from database specifics.

**Development Server**: Vite dev server runs in middleware mode for HMR (Hot Module Replacement) during development. Production builds serve static files from the `dist/public` directory.

### Database Layer

**Database**: PostgreSQL accessed via the Neon serverless driver with WebSocket support for serverless environments.

**ORM**: Drizzle ORM provides type-safe database operations with:
- Schema definitions in `shared/schema.ts` using Drizzle's table builders
- Automatic TypeScript type inference from schema
- Migration support via drizzle-kit

**Schema Design**: Single `messages` table with:
- `id` - Auto-incrementing primary key
- `name` - Text field for author name (required)
- `content` - Text field for message content (required)
- `createdAt` - Timestamp with automatic default
- `updatedAt` - Timestamp updated on modifications

**Validation Strategy**: Drizzle-zod integration generates Zod schemas from database schema, ensuring validation rules stay synchronized with database structure. Custom refinements add business logic constraints (character limits, required fields).

### Shared Code

**Type Definitions**: Shared schema file (`shared/schema.ts`) provides single source of truth for:
- Database table structure (Drizzle schema)
- Validation rules (Zod schemas)
- TypeScript types (inferred from schemas)

This approach ensures type safety across the full stack - from database queries through API endpoints to frontend components.

### Build & Deployment

**Development**: 
- Frontend: Vite dev server with HMR on port 5000 (proxied through Express)
- Backend: tsx (TypeScript executor) runs Express server
- Database: Drizzle Kit pushes schema changes directly to database

**Production**:
- Frontend: Vite builds optimized static assets to `dist/public`
- Backend: esbuild bundles server code to `dist/index.js` as ESM
- Execution: Node.js runs bundled server which serves both API and static files

**Database Migrations**: `drizzle-kit push` command applies schema changes directly to PostgreSQL without generating migration files (suitable for development and simple deployments).

## External Dependencies

### Core Services

**PostgreSQL Database**: Required for data persistence. Connection configured via `DATABASE_URL` environment variable. Uses Neon serverless driver for WebSocket-based connections compatible with serverless deployments.

**Replit Platform**: Optional but integrated:
- `@replit/vite-plugin-runtime-error-modal` - Development error overlay
- `@replit/vite-plugin-cartographer` - Code navigation features
- `@replit/vite-plugin-dev-banner` - Development mode indicator
- These plugins only load in development on Replit (`NODE_ENV !== "production" && REPL_ID !== undefined`)

### UI Component Libraries

**Radix UI**: Headless, accessible component primitives for dialogs, dropdowns, forms, tooltips, and other interactive elements. Provides foundation for shadcn/ui components.

**shadcn/ui**: Pre-styled component collection built on Radix UI and Tailwind CSS. Configuration in `components.json` specifies "new-york" style variant with CSS variables for theming.

**Lucide React**: Icon library providing consistent iconography throughout the application.

### Utilities & Tools

**date-fns**: Date formatting and manipulation (e.g., "2 minutes ago" timestamps)

**TanStack Query**: Sophisticated data fetching with automatic caching, background refetching, and optimistic updates

**class-variance-authority & clsx**: Type-safe component variant styling utilities

**Tailwind CSS**: Utility-first CSS framework with custom configuration for design system tokens (colors, spacing, border radius)

### Development Tools

**TypeScript**: Strict mode enabled for maximum type safety

**Vite**: Frontend build tool and development server

**drizzle-kit**: Database schema management and migration tool

**esbuild**: Fast bundler for production server code

**PostCSS & Autoprefixer**: CSS processing for cross-browser compatibility