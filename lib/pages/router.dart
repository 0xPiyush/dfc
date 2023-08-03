import 'package:dfc/pages/get_started/get_started.dart';
import 'package:dfc/pages/home/home.dart';
import 'package:dfc/pages/sign_up/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum AppRoutes {
  home("/"),
  getStarted("/get-started"),
  signUp("/sign-up");

  const AppRoutes(this.route);
  final String route;
}

final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: AppRoutes.getStarted.route,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const GetStartedPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.signUp.route,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const SignUpPage(),
      ),
    ),
    GoRoute(
      path: AppRoutes.home.route,
      pageBuilder: (context, state) => MaterialPage(
        key: state.pageKey,
        child: const HomePage(),
      ),
    ),
  ],
);
