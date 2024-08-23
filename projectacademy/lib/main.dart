import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projectacademy/Pages/entry/loginPage.dart';
import 'package:projectacademy/Pages/hub/adminPanel.dart';
import 'package:projectacademy/Pages/entry/restorePage.dart';
import 'package:projectacademy/Pages/hub/instructorpanel/instructorPage.dart';
import 'package:projectacademy/Pages/hub/studentpanel/examSolvingPage.dart';
import 'package:projectacademy/Pages/hub/studentpanel/studentPage.dart';
import 'package:projectacademy/firebaseConfig/firebase_options.dart';
import 'package:projectacademy/Pages/hub/uniadminpanel/uniadminPanel.dart';

void main() async {
  //await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: Colors.grey.shade500.withOpacity(0.5),
          cursorColor: Colors.grey.shade500,
        ),
      ),
      routes: {
        "/": (context) => LoginPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name != '/') {
          return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                switch (settings.name) {
              '/restore' => const RestorePage(),
              '/admin' => const AdminPanel(),
              '/uniadmin' => const UniAdminPanel(),
              '/instructorpanel' => const InstructorPage(),
              '/studentpanel' => const StudentPage(),
              '/examsolving' => const ExamSolvingPageWidget(),
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
