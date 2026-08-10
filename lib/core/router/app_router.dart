import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/repositories/auth_repository.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/pin_lock_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/history/history_screen.dart';
import '../../features/transaction/add_transaction_screen.dart';
import '../../features/report/report_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../widgets/main_scaffold.dart';

import 'package:shared_preferences/shared_preferences.dart';

final pinUnlockedProvider = StateProvider<bool>((ref) => false);

// Route index mapping
int _indexFromLocation(String location) {
  switch (location) {
    case '/':
      return 0;
    case '/history':
      return 1;
    case '/report':
      return 3;
    case '/profile':
      return 4;
    default:
      return 0;
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final user = ref.watch(currentUserProvider);
  final isUnlocked = ref.watch(pinUnlockedProvider);

  return GoRouter(
    initialLocation: user != null ? '/' : '/login',
    redirect: (context, state) async {
      final loggedIn = user != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';
      final isPinRoute = state.matchedLocation == '/pin-lock';

      if (!loggedIn && !isAuthRoute) return '/login';
      if (loggedIn && isAuthRoute) return '/';

      if (loggedIn && !isUnlocked && !isPinRoute) {
        final prefs = await SharedPreferences.getInstance();
        final pin = prefs.getString('app_pin');
        if (pin != null && pin.isNotEmpty) {
          return '/pin-lock';
        }
      }

      return null;
    },
    routes: [
      // Auth routes
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _slide(state, const LoginScreen()),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => _slide(state, const RegisterScreen()),
      ),
      GoRoute(
        path: '/pin-lock',
        pageBuilder: (context, state) => _slide(state, const PinLockScreen()),
      ),

      // Add transaction (full screen modal)
      GoRoute(
        path: '/add-transaction',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AddTransactionScreen(),
          transitionsBuilder: (context, animation, secondary, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            );
          },
        ),
      ),

      // Shell route (bottom nav)
      ShellRoute(
        builder: (context, state, child) {
          final index = _indexFromLocation(state.matchedLocation);
          return MainShell(currentIndex: index, child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) =>
                _noTransition(state, const DashboardScreen()),
          ),
          GoRoute(
            path: '/history',
            pageBuilder: (context, state) =>
                _noTransition(state, const HistoryScreen()),
          ),
          GoRoute(
            path: '/report',
            pageBuilder: (context, state) =>
                _noTransition(state, const ReportScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) =>
                _noTransition(state, const ProfileScreen()),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.error}'),
      ),
    ),
  );
});

CustomTransitionPage _slide(GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondary, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

NoTransitionPage _noTransition(GoRouterState state, Widget child) {
  return NoTransitionPage(key: state.pageKey, child: child);
}
