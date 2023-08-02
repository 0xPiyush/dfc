import 'package:dfc/pages/get_started.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'DFC',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const DFC());
}

class DFC extends StatelessWidget {
  const DFC({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DFC',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const GetStartedPage(),
    );
  }
}
