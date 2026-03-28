import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/renter/domain/models/listing_model.dart';

import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/renter/presentation/screens/renter_home_screen.dart';
import '../../features/renter/presentation/screens/search_explore_screen.dart';
import '../../features/renter/presentation/screens/house_details_screen.dart';
import '../../features/renter/presentation/screens/favorites_screen.dart';
import '../../features/renter/presentation/screens/inquiries_screen.dart';
import '../../features/renter/presentation/screens/profile_screen.dart';
import '../../features/renter/presentation/screens/payment_methods_screen.dart';
import '../../features/renter/presentation/screens/add_payment_screen.dart';
import '../../features/renter/presentation/screens/chat_screen.dart';
import '../../features/owner/presentation/screens/owner_dashboard_screen.dart';
import '../../features/owner/presentation/screens/add_listing_screen.dart';
import '../../features/owner/presentation/screens/premium_upgrade_screen.dart';
import '../../features/owner/presentation/screens/owner_inquiries_screen.dart';
import '../../features/broker/presentation/screens/broker_dashboard_screen.dart';
import '../../shared/widgets/scaffold_with_nav_bar.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const RenterHomeScreen(),
          ),
          GoRoute(
            path: '/explore',
            builder: (context, state) => const SearchExploreScreen(),
          ),
          GoRoute(
            path: '/favorites',
            builder: (context, state) => const FavoritesScreen(),
          ),
          GoRoute(
            path: '/inquiries',
            builder: (context, state) => const InquiriesScreen(),
            routes: [
              GoRoute(
                path: 'chat/:id',
                builder: (context, state) => ChatScreen(
                  inquiryId: state.pathParameters['id']!,
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'payments',
                builder: (context, state) => const PaymentMethodsScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (context, state) => const AddPaymentScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/details',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final listing = state.extra as ListingModel?;
          if (listing == null) {
            return const Scaffold(
              body: Center(child: Text('Listing details unavailable')),
            );
          }
          return HouseDetailsScreen(listing: listing);
        },
      ),
      GoRoute(
        path: '/owner/dashboard',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OwnerDashboardScreen(),
      ),
      GoRoute(
        path: '/owner/add-listing',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddListingScreen(),
      ),
      GoRoute(
        path: '/owner/premium-payment',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PremiumUpgradeScreen(),
      ),
      GoRoute(
        path: '/owner/inquiries',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OwnerInquiriesScreen(),
      ),
      GoRoute(
        path: '/broker/dashboard',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BrokerDashboardScreen(),
      ),
    ],
  );
});
