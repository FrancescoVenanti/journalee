# Journalee 🚀

A collaborative journaling app built with Flutter and Supabase. Share your thoughts and experiences with friends and family, or keep a private journal for yourself.

## Features ✨

- **Personal & Shared Journals** - Create private journals or collaborate with others
- **Rich Text Editing** - Express yourself with rich formatting
- **Real-time Collaboration** - See updates from journal members instantly  
- **Comments & Reactions** - Engage with entries through comments and emoji reactions
- **Beautiful Design** - Clean, minimal interface with dark/light mode support
- **Cross-platform** - Works on iOS and Android

## Getting Started 🚀

### Prerequisites

- Flutter SDK (>=3.10.0)
- Dart SDK (>=3.0.0)
- A Supabase account and project

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd journalee
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up Supabase**
   - Create a new project at [supabase.com](https://supabase.com)
   - Go to Settings → API to get your project URL and anon key
   - In the SQL Editor, run the database schema (see Database Setup below)

4. **Configure environment variables**
   ```bash
   # Copy the example environment file
   cp .env.example .env
   
   # Edit .env and add your Supabase credentials
   SUPABASE_URL=https://your-project-id.supabase.co
   SUPABASE_ANON_KEY=your-anon-key-here
   ```

5. **Run the app**
   ```bash
   flutter run
   ```

## Database Setup 🗄️

Run this SQL in your Supabase SQL Editor to set up the database schema:

```sql
-- Enable RLS (Row Level Security)
ALTER DATABASE postgres SET "app.jwt_secret" TO 'your-jwt-secret';

-- Create profiles table (extends auth.users)
CREATE TABLE profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create journals table
CREATE TABLE journals (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT,
  is_shared BOOLEAN DEFAULT FALSE,
  created_by UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- [Continue with the rest of the schema from the supabase_schema.sql file]
```

> **Note**: The complete database schema is available in the setup artifacts. Copy and paste the entire schema into your Supabase SQL Editor.

## Environment Variables 🔧

Create a `.env` file in the root directory with the following variables:

| Variable | Description | Required |
|----------|-------------|----------|
| `SUPABASE_URL` | Your Supabase project URL | ✅ |
| `SUPABASE_ANON_KEY` | Your Supabase anon key | ✅ |
| `APP_NAME` | Application name | ❌ |
| `APP_VERSION` | Application version | ❌ |
| `ENVIRONMENT` | Environment (development/staging/production) | ❌ |
| `DEBUG_MODE` | Enable debug logging | ❌ |

## Project Structure 📁

```
lib/
├── core/                    # Core utilities and configuration
│   ├── config/             # App configuration
│   ├── constants/          # Colors, text styles, constants
│   ├── router/             # Navigation and routing
│   ├── theme/              # Theme configuration
│   └── utils/              # Utility functions
├── data/                   # Data layer
│   ├── models/             # Data models
│   ├── repositories/       # Data repositories
│   └── services/           # External services (Supabase)
├── presentation/           # UI layer
│   ├── layouts/            # App layouts
│   ├── providers/          # State management (Riverpod)
│   ├── screens/            # App screens
│   └── widgets/            # Reusable widgets
├── app.dart               # Main app widget
└── main.dart              # App entry point
```

## Architecture 🏗️

This project follows **Clean Architecture** principles:

- **Presentation Layer**: UI components, screens, and state management
- **Data Layer**: Repositories, models, and external service integration
- **Core Layer**: Utilities, constants, and shared functionality

### State Management

We use **Riverpod** for state management, providing:
- Type-safe dependency injection
- Reactive state updates
- Easy testing
- Great developer experience

### Database

**Supabase** provides:
- Real-time PostgreSQL database
- Row Level Security (RLS)
- Built-in authentication
- Real-time subscriptions
- RESTful API

## Contributing 🤝

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Security 🔒

- **Never commit `.env` files** - They contain sensitive credentials
- **Use Row Level Security** - All database tables have RLS enabled
- **Validate user input** - All forms use proper validation
- **Environment-based configuration** - Different settings for dev/staging/production

## Troubleshooting 🔧

### Common Issues

**Configuration Error on Startup**
- Ensure your `.env` file exists and contains valid Supabase credentials
- Check that your Supabase URL format is correct: `https://your-project-id.supabase.co`
- Verify your anon key is complete and copied correctly

**Database Connection Issues**
- Confirm your Supabase project is active
- Check that the database schema has been set up correctly
- Verify RLS policies are in place

**Build Issues**
- Run `flutter clean && flutter pub get`
- Ensure you're using the correct Flutter/Dart versions
- Check for any missing dependencies

## License 📄

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

Built with ❤️ using Flutter and Supabase