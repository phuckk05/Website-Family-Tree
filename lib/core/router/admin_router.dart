import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:website_gia_pha/pages/admin_page.dart';
import 'package:website_gia_pha/pages/login_page.dart';

class AppAdminRouter {
  // Route names
  static const String admin = '/';
  static const String login = '/login';

  // GoRouter configuration cho admin subdomain
  static final GoRouter adminRouter = GoRouter(
    initialLocation: admin,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: admin,
        name: 'admin',
        builder: (context, state) => const AdminPage(),
      ),
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginPage(isAdminMode: true),
      ),
    ],
    errorBuilder: (context, state) => const AdminPage(),
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
