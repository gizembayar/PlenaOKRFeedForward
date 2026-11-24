import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../features/auth/auth_page.dart';
import '../features/content/content_page.dart';
import '../features/discover/discover_page.dart';
import '../features/landing/landing_page.dart';
import '../features/me/me_page.dart';
import '../features/onboarding/onboarding_page.dart';
import '../features/plan/plan_page.dart';
import '../features/pricing/membership_page.dart';
import '../features/pricing/pricing_page.dart';
import '../features/profile/profile_page.dart';
import '../features/shell/app_shell.dart';
import '../features/today/today_page.dart';
import '../services/session.dart';

/// URL haritası
///
/// Kamusal (web vitrini):   /  ·  /uyelik  ·  /giris  ·  /kayit
/// Kişisel alan (giriş):    /app/bugun · /app/kesfet · /app/kendim
///                          /app/planim · /app/profil
///                          /app/hayatim (onboarding) · /app/uyelik
///                          /app/icerik/:id
GoRouter buildRouter(Session session) {
  const shellPaths = [
    '/app/bugun',
    '/app/kesfet',
    '/app/kendim',
    '/app/planim',
    '/app/profil',
  ];

  return GoRouter(
    initialLocation: '/',
    refreshListenable: session,
    redirect: (context, state) {
      final path = state.uri.path;
      final q = state.uri.queryParameters;
      final isAuth = path == '/giris' || path == '/kayit';

      if (path.startsWith('/app') && !session.signedIn) {
        return '/giris';
      }
      if (isAuth && session.signedIn) {
        final plan = q['plan'];
        if (plan != null && plan != 'free') {
          return '/app/uyelik?plan=$plan&donem=${q['donem'] ?? 'yearly'}';
        }
        return '/app/bugun';
      }
      // Mobil uygulamada giriş yapmış kullanıcı vitrini değil "Bugün"ü görür.
      if (!kIsWeb && path == '/' && session.signedIn) return '/app/bugun';
      if (session.needsOnboarding && shellPaths.contains(path)) {
        return '/app/hayatim';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const LandingPage()),
      GoRoute(
        path: '/uyelik',
        builder: (_, s) =>
            PricingPage(cancelled: s.uri.queryParameters['durum'] == 'iptal'),
      ),
      GoRoute(
        path: '/giris',
        builder: (_, s) => AuthPage(
          signUp: false,
          plan: s.uri.queryParameters['plan'],
          period: s.uri.queryParameters['donem'],
        ),
      ),
      GoRoute(
        path: '/kayit',
        builder: (_, s) => AuthPage(
          signUp: true,
          plan: s.uri.queryParameters['plan'],
          period: s.uri.queryParameters['donem'],
        ),
      ),
      GoRoute(path: '/app', redirect: (_, _) => '/app/bugun'),
      GoRoute(path: '/app/hayatim', builder: (_, _) => const OnboardingPage()),
      GoRoute(
        path: '/app/uyelik',
        builder: (_, s) => MembershipPage(
          plan: s.uri.queryParameters['plan'],
          period: s.uri.queryParameters['donem'],
          status: s.uri.queryParameters['durum'],
        ),
      ),
      GoRoute(
        path: '/app/icerik/:id',
        builder: (_, s) => ContentPage(id: s.pathParameters['id']!),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(shell: shell),
        branches: [
          for (final (path, page) in <(String, Widget)>[
            ('/app/bugun', const TodayPage()),
            ('/app/kesfet', const DiscoverPage()),
            ('/app/kendim', const MePage()),
            ('/app/planim', const PlanPage()),
            ('/app/profil', const ProfilePage()),
          ])
            StatefulShellBranch(
              routes: [GoRoute(path: path, builder: (_, _) => page)],
            ),
        ],
      ),
    ],
  );
}
