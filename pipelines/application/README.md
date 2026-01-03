# Message Manager - Full-Stack Demo Application

A clean, professional message management application demonstrating full-stack development with React, Express, and PostgreSQL. Perfect for QA/DevOps demonstrations.

## Features

- **Create Messages**: Submit new messages with your name and content
- **View Messages**: See all messages in chronological order with timestamps
- **Edit Messages**: Update existing messages with a clean modal interface
- **Delete Messages**: Remove messages with confirmation dialog
- **Health Monitoring**: Real-time backend health status indicator
- **Dark Mode**: Toggle between light and dark themes
- **Responsive Design**: Beautiful UI that works on all devices

## Tech Stack

### Frontend
- **React 18** - Modern UI library with hooks
- **TypeScript** - Type-safe development
- **Tailwind CSS** - Utility-first styling
- **shadcn/ui** - High-quality component library
- **TanStack Query** - Powerful data fetching and caching
- **Wouter** - Lightweight routing
- **React Hook Form** - Form validation with Zod
- **Vite** - Lightning-fast development server

### Backend
- **Express.js** - Fast, minimalist web framework
- **TypeScript** - Type-safe server code
- **PostgreSQL** - Robust relational database
- **Drizzle ORM** - Type-safe database operations
- **Zod** - Schema validation

## Getting Started

### Prerequisites

- Node.js 20+ installed
- PostgreSQL database (automatically provisioned on Replit)

### Installation

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Set up the database:**
   ```bash
   npm run db:push
   ```

3. **Start the development server:**
   ```bash
   npm run dev
   ```

   The application will be available at `http://localhost:5000`

## API Endpoints

### Health Check
- **GET** `/api/health` - Check backend service health
  ```json
  {
    "status": "ok",
    "timestamp": "2025-11-15T09:13:20.500Z"
  }
  ```

### Messages
- **GET** `/api/messages` - Retrieve all messages
- **GET** `/api/messages/:id` - Get a specific message
- **POST** `/api/messages` - Create a new message
  ```json
  {
    "name": "John Doe",
    "content": "Hello, world!"
  }
  ```
- **PUT** `/api/messages/:id` - Update a message
  ```json
  {
    "name": "John Doe",
    "content": "Updated message"
  }
  ```
- **DELETE** `/api/messages/:id` - Delete a message

## Project Structure

```
.
├── client/                 # Frontend React application
│   ├── src/
│   │   ├── components/    # Reusable UI components
│   │   │   ├── ui/       # shadcn/ui components
│   │   │   ├── theme-provider.tsx
│   │   │   └── theme-toggle.tsx
│   │   ├── pages/        # Page components
│   │   │   └── home.tsx  # Main application page
│   │   ├── lib/          # Utilities and configuration
│   │   ├── App.tsx       # App entry point with routing
│   │   └── main.tsx      # React DOM mounting
│   └── index.html        # HTML template
├── server/                # Backend Express application
│   ├── db.ts            # Database connection
│   ├── storage.ts       # Data access layer
│   ├── routes.ts        # API route handlers
│   └── index.ts         # Server entry point
├── shared/               # Shared TypeScript types
│   └── schema.ts        # Database schema and validation
└── README.md            # This file
```

## Development

### Database Management

The project uses Drizzle ORM for type-safe database operations. To make schema changes:

1. Edit `shared/schema.ts`
2. Run `npm run db:push` to sync changes to the database

### Available Scripts

- `npm run dev` - Start development server (frontend + backend)
- `npm run db:push` - Push database schema changes
- `npm run build` - Build for production
- `npm run preview` - Preview production build

## Design System

The application follows a Material Design-inspired system with:

- **Typography**: Inter font family
- **Spacing**: Consistent 4px, 6px, and 8px units
- **Colors**: Professional blue primary color with semantic variants
- **Components**: shadcn/ui components for consistency
- **Dark Mode**: Full dark mode support with theme persistence

## Testing

The application includes comprehensive data-testid attributes for easy E2E testing:

- Form inputs: `input-name`, `input-content`
- Buttons: `button-submit`, `button-edit-{id}`, `button-delete-{id}`
- Display elements: `text-message-name-{id}`, `text-message-content-{id}`
- Status indicators: `badge-health-status`

## Production Deployment

On Replit, use the built-in deployment feature to publish your application:

1. Ensure all changes are saved
2. Click the "Deploy" button in the Replit interface
3. Your app will be live with a custom `.replit.app` domain

## Environment Variables

The following environment variables are automatically configured on Replit:

- `DATABASE_URL` - PostgreSQL connection string
- `NODE_ENV` - Environment mode (development/production)

## License

This project is created for demonstration purposes.

## Support

For issues or questions about this demo application, please refer to the code documentation or contact your development team.
