import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/application/auth_controller.dart';
import '../features/auth/presentation/screens/account_type_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/categories/presentation/screens/specialties_screen.dart';
import '../features/discovery/presentation/screens/business_list_screen.dart';
import '../features/home/presentation/screens/business_home_screen.dart';
import '../features/home/presentation/screens/customer_home_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';

/// A [Listenable] bridge so GoRouter's `refreshListenable` reacts to Riverpod
/// state changes (GoRouter itself only knows about ChangeNotifier).
class _AuthListenable extends ChangeNotifier {
  _AuthListenable(Ref ref) {
    ref.listen(authControllerProvider, (previous, next) => notifyListeners());
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authListenable = _AuthListenable(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: authListenable,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final atAuthGate =
          state.matchedLocation == '/' ||
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (authState is AuthUnknown) {
        return state.matchedLocation == '/splash' ? null : '/splash';
      }
      if (state.matchedLocation == '/splash') {
        return authState is AuthSignedIn ? '/home' : '/';
      }
      if (authState is AuthSignedOut && !atAuthGate) {
        return '/';
      }
      if (authState is AuthSignedIn && atAuthGate) {
        return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const AccountTypeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) =>
            LoginScreen(accountType: (state.extra as String?) ?? 'client'),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) =>
            RegisterScreen(accountType: (state.extra as String?) ?? 'client'),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) {
          final authState = ref.read(authControllerProvider);
          final isBusiness =
              authState is AuthSignedIn && authState.user.isBusiness;
          return isBusiness
              ? const BusinessHomeScreen()
              : const CustomerHomeScreen();
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/categories/:categoryId/specialties',
        builder: (context, state) => SpecialtiesScreen(
          categoryId: int.parse(state.pathParameters['categoryId']!),
          categoryName: (state.extra as String?) ?? '',
        ),
      ),
      GoRoute(
        path: '/discovery',
        builder: (context, state) {
          final extra = state.extra as Map<String, Object?>;
          return BusinessListScreen(
            childId: extra['childId'] as int,
            title: extra['title'] as String,
          );
        },
      ),
    ],
  );
});
