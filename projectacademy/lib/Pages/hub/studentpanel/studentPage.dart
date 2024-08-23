// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projectacademy/Pages/hub/studentpanel/calendarpage.dart';
import 'package:projectacademy/Pages/hub/studentpanel/homepage.dart';
import 'package:projectacademy/Pages/hub/studentpanel/joincoursepage.dart';
import 'package:projectacademy/Pages/hub/studentpanel/navbarstudent.dart';

int y = 0;

void getStuFirstInfos(String uniId, String facultyId, String departmentId,
    String studentId, ref) async {
  FirebaseFirestore.instance
      .collection('universities')
      .doc(uniId)
      .collection('faculties')
      .doc(facultyId)
      .collection('departments')
      .doc(departmentId)
      .collection('students')
      .doc(studentId)
      .get()
      .then(
    (value) {
      if (value.data()?.containsKey('assignedLectures') == true &&
          value['assignedLectures'].isNotEmpty) {
        ref.read(courseIdProvider.notifier).state =
            value['assignedLectures'].first;

        FirebaseFirestore.instance
            .collection('universities')
            .doc(uniId)
            .collection('faculties')
            .doc(facultyId)
            .collection('departments')
            .doc(departmentId)
            .collection('courses')
            .doc(value['assignedLectures'].first)
            .get()
            .then(
          (value) {
            if (value['instructorId'] != "") {
              ref.read(instructorIdProvider.notifier).state =
                  value['instructorId'];
            }
          },
        );
      }
    },
  );
}

class StudentPage extends ConsumerWidget {
  const StudentPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uniId = ref.watch(runiIdProvider).asData?.value ?? " ";
    final facultyId = ref.watch(rfacultyIdProvider).asData?.value ?? " ";
    final departmentId = ref.watch(rdepartmentIdProvider).asData?.value ?? " ";
    final studentId = ref.watch(rstudentIdProvider).asData?.value ?? " ";
    if (y == 0) {
      getStuFirstInfos(
        uniId,
        facultyId,
        departmentId,
        studentId,
        ref,
      );
      y = 1;
    }
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/3.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            AnimatedSwitcher(
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              duration: const Duration(milliseconds: 500),
              child: switch (ref.watch(selectedStudentPageProvider)) {
                0 => const JoinCourseWidget(),
                1 => const HomePageWidget(),
                2 => const CalendarPage(),
                _ => Container(),
              },
            ),
            (size.width > 1000 ||
                        ref.watch(selectedStudentPageProvider) != 0) &&
                    size.height > 200
                ? NavBarStudentWidget(size: size)
                : Container(),
          ],
        ),
      ),
    );
  }
}
