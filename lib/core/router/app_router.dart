import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:journalee/presentation/screens/entry/create_entry_screen.dart';
import 'package:journalee/presentation/screens/entry/edit_entry_screen.dart';
import 'package:journalee/presentation/screens/entry/entry_detail_screen.dart';
import 'package:journalee/presentation/screens/journals/create_journal_screen.dart';
import 'package:journalee/presentation/screens/journals/journal_detail_screen.dart';
import 'package:journalee/presentation/screens/journals/journal_list_screen.dart';
import 'package:journalee/presentation/screens/profile/profile_screen.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/signup_screen.dart';
import '../../presentation/screens/auth/forgot_password_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/layouts/main_layout.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = authState.when(
        data: (user) => user != null,
        loading: () => false,
        error: (_, __) => false,
      );

      final isOnAuthScreen = [
        '/login',
        '/signup',
        '/forgot-password',
      ].contains(state.matchedLocation);

      // If user is not authenticated and not on auth screen, redirect to login
      if (!isAuthenticated && !isOnAuthScreen) {
        return '/login';
      }

      // If user is authenticated and on auth screen, redirect to home
      if (isAuthenticated && isOnAuthScreen) {
        return '/';
      }

      return null;
    },
    routes: [
      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Main App Routes with Bottom Navigation
      ShellRoute(
        builder: (context, state, child) => MainLayout(child: child),
        routes: [
          // Home
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),

          // Shared Journals
          GoRoute(
            path: '/shared',
            name: 'shared',
            builder: (context, state) =>
                const JournalListScreen(journalType: JournalType.shared),
            routes: [
              GoRoute(
                path: '/create',
                name: 'create-shared-journal',
                builder: (context, state) =>
                    const CreateJournalScreen(isShared: true),
              ),
            ],
          ),

          // Personal Journals
          GoRoute(
            path: '/personal',
            name: 'personal',
            builder: (context, state) =>
                const JournalListScreen(journalType: JournalType.personal),
            routes: [
              GoRoute(
                path: '/create',
                name: 'create-personal-journal',
                builder: (context, state) =>
                    const CreateJournalScreen(isShared: false),
              ),
            ],
          ),

          // Settings
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Journal Detail Routes (Full Screen)
      GoRoute(
        path: '/journal/:journalId',
        name: 'journal-detail',
        builder: (context, state) {
          final journalId = state.pathParameters['journalId']!;
          return JournalDetailScreen(journalId: journalId);
        },
        routes: [
          // Create Entry
          GoRoute(
            path: '/create-entry',
            name: 'create-entry',
            builder: (context, state) {
              final journalId = state.pathParameters['journalId']!;
              return CreateEntryScreen(journalId: journalId);
            },
          ),
        ],
      ),

      // Entry Detail Routes (Full Screen)
      GoRoute(
        path: '/entry/:entryId',
        name: 'entry-detail',
        builder: (context, state) {
          final entryId = state.pathParameters['entryId']!;
          return EntryDetailScreen(entryId: entryId);
        },
        routes: [
          // Edit Entry
          GoRoute(
            path: '/edit',
            name: 'edit-entry',
            builder: (context, state) {
              final entryId = state.pathParameters['entryId']!;
              return EditEntryScreen(entryId: entryId);
            },
          ),
        ],
      ),
    ],
  );
});

// Navigation Helper
class AppRouter {
  static void goToLogin(BuildContext context) {
    context.go('/login');
  }

  static void goToSignUp(BuildContext context) {
    context.go('/signup');
  }

  static void goToHome(BuildContext context) {
    context.go('/');
  }

  static void goToJournalDetail(BuildContext context, String journalId) {
    context.push('/journal/$journalId');
  }

  static void goToCreateEntry(BuildContext context, String journalId) {
    context.push('/journal/$journalId/create-entry');
  }

  static void goToEntryDetail(BuildContext context, String entryId) {
    context.push('/entry/$entryId');
  }

  static void goToEditEntry(BuildContext context, String entryId) {
    context.push('/entry/$entryId/edit');
  }

  static void goToCreateJournal(
    BuildContext context, {
    required bool isShared,
  }) {
    final path = isShared ? '/shared/create' : '/personal/create';
    context.push(path);
  }

  static void goToSettings(BuildContext context) {
    context.go('/settings');
  }

  static void goToProfile(BuildContext context) {
    context.push('/settings/profile');
  }
}
