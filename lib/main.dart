import 'package:dfc/pages/router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const DFC());
}

class DFC extends StatelessWidget {
  const DFC({super.key});
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          appRouter.go(AppRoutes.home.route);
        } else {
          appRouter.go(AppRoutes.getStarted.route);
        }
        return MaterialApp.router(
          title: 'DFC',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.red.shade400,
              primary: Colors.red.shade400,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                textStyle: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                  color: Colors.white,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            textTheme: TextTheme(
              headlineLarge: GoogleFonts.dmSerifText(
                fontSize: 48,
                fontWeight: FontWeight.w600,
                height: 1.2,
                color: Colors.black,
              ),
              headlineMedium: GoogleFonts.dmSerifText(
                fontSize: 32,
                fontWeight: FontWeight.w500,
                height: 1.2,
                color: Colors.black,
              ),
              headlineSmall: GoogleFonts.dmSerifText(
                fontSize: 24,
                fontWeight: FontWeight.w400,
                height: 1.2,
                color: Colors.black,
              ),
              bodyLarge: GoogleFonts.barlow(
                fontSize: 24,
                fontWeight: FontWeight.w400,
                height: 1.2,
                color: Colors.black,
              ),
              bodyMedium: GoogleFonts.barlow(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                height: 1.2,
                color: Colors.black,
              ),
              bodySmall: GoogleFonts.barlow(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.2,
                color: Colors.grey[700],
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 8,
                horizontal: 16,
              ),
            ),
          ),
          routeInformationParser: appRouter.routeInformationParser,
          routeInformationProvider: appRouter.routeInformationProvider,
          routerDelegate: appRouter.routerDelegate,
        );
      },
    );
  }
}
