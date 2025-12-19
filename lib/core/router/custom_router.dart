import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:website_gia_pha/models/album.dart';
import 'package:website_gia_pha/pages/index.dart';
import 'package:website_gia_pha/pages/home_page.dart';
import 'package:website_gia_pha/pages/family_tree_page.dart';
import 'package:website_gia_pha/pages/events_page.dart';
import 'package:website_gia_pha/pages/documents_page.dart';
import 'package:website_gia_pha/pages/gallery_page.dart';
import 'package:website_gia_pha/pages/gallery_detail_page.dart';
import 'package:website_gia_pha/pages/contact_page.dart';
import 'package:website_gia_pha/pages/login_page.dart';
import 'package:website_gia_pha/pages/setting_page.dart';

class AppRouter {
  // Route names
  static const String home = '/';
  static const String familyTree = '/family-tree';
  static const String events = '/events';
  static const String documents = '/documents';
  static const String gallery = '/gallery';
  static const String galleryDetail = '/gallery/:albumId';
  static const String contact = '/contact';
  static const String login = '/login';
  static const String settings = '/settings';

  // GoRouter configuration
  static final GoRouter router = GoRouter(
    initialLocation: home,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: familyTree,
        name: 'family-tree',
        builder: (context, state) => const FamilyTreePage(),
      ),
      GoRoute(
        path: events,
        name: 'events',
        builder: (context, state) => const EventsPage(),
      ),
      GoRoute(
        path: documents,
        name: 'documents',
        builder: (context, state) => const DocumentsPage(),
      ),
      GoRoute(
        path: gallery,
        name: 'gallery',
        builder: (context, state) => const GalleryPage(),
      ),
      GoRoute(
        path: galleryDetail,
        name: 'gallery-detail',
        builder: (context, state) {
          final albumId = state.pathParameters['albumId'];
          final album = state.extra as Album?;
          if (album == null || albumId == null) {
            return const GalleryPage();
          }
          return GalleryDetailPage(album: album);
        },
      ),
      GoRoute(
        path: contact,
        name: 'contact',
        builder: (context, state) => const ContactPage(),
      ),
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: settings,
        name: 'settings',
        builder: (context, state) => const SettingPage(),
      ),
    ],
    errorBuilder: (context, state) => const HomePage(),
  );

  // Helper methods để navigate
  static void go(BuildContext context, String path) {
    context.go(path);
  }

  static void goNamed(
    BuildContext context,
    String name, {
    Map<String, String>? pathParameters,
    Object? extra,
  }) {
    context.goNamed(name, pathParameters: pathParameters ?? {}, extra: extra);
  }

  static void push(BuildContext context, String path) {
    context.push(path);
  }

  static void pushNamed(
    BuildContext context,
    String name, {
    Map<String, String>? pathParameters,
    Object? extra,
  }) {
    context.pushNamed(name, pathParameters: pathParameters ?? {}, extra: extra);
  }

  static void pop(BuildContext context) {
    context.pop();
  }
}
