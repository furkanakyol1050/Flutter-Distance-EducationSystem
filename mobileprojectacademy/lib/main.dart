import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobileprojectacademy/entry/entry.dart';
import 'package:mobileprojectacademy/firebase_options.dart';
import 'package:mobileprojectacademy/home/pageMain.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        "/": (context) => LoginPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name != '/') {
          return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                switch (settings.name) {
              '/home' => const PageMain(),
              '/restore' => const RestorePage(),
              _ => Container(),
            },
            settings: settings,
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          );
        }
        return null;
      },
    );
  }
}
