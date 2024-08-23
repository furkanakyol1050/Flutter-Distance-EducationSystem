// ignore_for_file: file_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projectacademy/Pages/hub/instructorpanel/announcementPage.dart';
import 'package:projectacademy/Pages/hub/instructorpanel/calendarPage.dart';
import 'package:projectacademy/Pages/hub/instructorpanel/createExamPage.dart';
import 'package:projectacademy/Pages/hub/instructorpanel/homePage.dart';
import 'package:projectacademy/Pages/hub/instructorpanel/homeworkPage.dart';
import 'package:projectacademy/Pages/hub/instructorpanel/navbarinstruc.dart';

final luniIdProvider = StreamProvider<String>((ref) {
  return FirebaseAuth.instance.authStateChanges().map((User? user) {
    if (user != null) {
      return user.photoURL?.split(",")[0] ?? ' ';
    } else {
      return ' ';
    }
  });
});

final lfacultyIdProvider = StreamProvider<String>((ref) {
  return FirebaseAuth.instance.authStateChanges().map((User? user) {
    if (user != null) {
      return user.photoURL?.split(",")[1] ?? ' ';
    } else {
      return ' ';
    }
  });
});

final ldepartmentIdProvider = StreamProvider<String>((ref) {
  return FirebaseAuth.instance.authStateChanges().map((User? user) {
    if (user != null) {
      return user.photoURL?.split(",")[2] ?? ' ';
    } else {
      return ' ';
    }
  });
});

final linstructorIdProvider = StreamProvider<String>((ref) {
  return FirebaseAuth.instance.authStateChanges().map((User? user) {
    if (user != null) {
      return user.photoURL?.split(",")[3] ?? ' ';
    } else {
      return ' ';
    }
  });
});

int x = 0;

class InstructorPage extends ConsumerWidget {
  const InstructorPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uniId = ref.watch(luniIdProvider).asData?.value ?? "";
    final instructorId = ref.watch(linstructorIdProvider).asData?.value ?? "";

    final size = MediaQuery.of(context).size;
    if (x == 0) {
      getFirstCourseId(uniId, instructorId, ref);
      x = 1;
    }
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/2.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            GestureDetector(
              onTap: () {
                ref.read(sizeInstrucProvider.notifier).state = 65;
              },
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  margin: const EdgeInsets.only(left: 65),
                  height: size.height,
                  child: AnimatedSwitcher(
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    duration: const Duration(milliseconds: 500),
                    child: switch (ref.watch(selectedInstrucPageProvider)) {
                      0 => Container(
                          margin: EdgeInsets.only(
                            right: (ref.watch(selectedInstrucPageProvider) ==
                                            0 &&
                                        size.width > 1300) ||
                                    ref.watch(leftPageChangeInsProvider) == 2
                                ? 56
                                : 0,
                          ),
                          child: const HomePageWidget(),
                        ),
                      1 => const CreateQuizPageWidget(),
                      2 => const HomeworkPageWidget(),
                      3 => const AnnouncementPage(),
                      4 => const CalendarPage(),
                      _ => Container(),
                    },
                  ),
                ),
              ),
            ),
            size.height > 200 ? NavBarInstrucWidget(size: size) : Container(),
            (size.height > 100 &&
                        ref.watch(selectedInstrucPageProvider) == 0 &&
                        size.width > 1300) ||
                    (ref.watch(leftPageChangeInsProvider) == 2 &&
                        size.height > 100)
                ? const Align(
                    alignment: Alignment.centerRight,
                    child: RightPanelWidget(),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
