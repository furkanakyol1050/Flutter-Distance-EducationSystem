import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projectacademy/Pages/hub/studentpanel/navbarstudent.dart';
import 'package:projectacademy/firebaseConfig/firebase_transactionss.dart';
import 'package:projectacademy/myDesign.dart';

final runiIdProvider = StreamProvider<String>((ref) {
  return FirebaseAuth.instance.authStateChanges().map((User? user) {
    if (user != null) {
      return user.photoURL?.split(",")[0] ?? ' ';
    } else {
      return '';
    }
  });
});

final rfacultyIdProvider = StreamProvider<String>((ref) {
  return FirebaseAuth.instance.authStateChanges().map((User? user) {
    if (user != null) {
      return user.photoURL?.split(",")[1] ?? ' ';
    } else {
      return '';
    }
  });
});

final rdepartmentIdProvider = StreamProvider<String>((ref) {
  return FirebaseAuth.instance.authStateChanges().map((User? user) {
    if (user != null) {
      return user.photoURL?.split(",")[2] ?? ' ';
    } else {
      return '';
    }
  });
});

final rstudentIdProvider = StreamProvider<String>((ref) {
  return FirebaseAuth.instance.authStateChanges().map((User? user) {
    if (user != null) {
      return user.photoURL?.split(",")[3] ?? ' ';
    } else {
      return '';
    }
  });
});

final courseCodeProvider = StateProvider((ref) => "");
final containerSizeProvider = StateProvider((ref) => 0);

class JoinCourseWidget extends ConsumerWidget {
  const JoinCourseWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String uniId = ref.watch(runiIdProvider).asData?.value ?? " ";
    String facultyId = ref.watch(rfacultyIdProvider).asData?.value ?? " ";
    String departmentId = ref.watch(rdepartmentIdProvider).asData?.value ?? " ";
    String studentId = ref.watch(rstudentIdProvider).asData?.value ?? " ";

    final size = MediaQuery.of(context).size;
    return ListView(
      children: [
        const SizedBox(height: 200),
        Center(
          child: Text(
            "Derse Katıl",
            style: Design().poppins(
              size: 20,
              fw: FontWeight.bold,
              color: const Color.fromRGBO(55, 55, 55, 1),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            "Almış olduğun kodu gir ve eğitime başla.",
            style: Design().poppins(
              size: 15,
              color: const Color.fromRGBO(55, 55, 55, 1),
            ),
          ),
        ),
        const SizedBox(height: 50),
        Center(
          child: ref.watch(containerSizeProvider) == 0
              ? AnimatedContainer(
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeInOutQuart,
                  width: 480,
                  height: 200,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(35, 35, 35, 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 55,
                        width: 300,
                        child: TextFormField(
                          cursorColor: const Color.fromRGBO(205, 205, 205, 1),
                          cursorWidth: 2,
                          cursorRadius: const Radius.circular(555),
                          textAlign: TextAlign.center,
                          style: Design().poppins(
                            size: 13,
                            color: const Color.fromRGBO(205, 205, 205, 1),
                            ls: 2,
                          ),
                          decoration: InputDecoration(
                            hintText: "Ders Kodu",
                            hintStyle: Design().poppins(
                              size: 13,
                              color: const Color.fromRGBO(205, 205, 205, 1),
                            ),
                            fillColor: const Color.fromRGBO(50, 50, 50, 1),
                            filled: true,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color.fromRGBO(50, 50, 50, 1),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color.fromRGBO(50, 50, 50, 1),
                              ),
                            ),
                          ),
                          onChanged: (value) {
                            ref.read(courseCodeProvider.notifier).state = value;
                          },
                        ),
                      ),
                      const SizedBox(height: 40),
                      JoinCourseButtonsWidget(
                        color: const Color.fromRGBO(83, 145, 101, 1),
                        text: "Ders Ara",
                        icon: Icons.search,
                        function: () async {
                          if (ref.watch(courseCodeProvider) == "" ||
                              ref.watch(courseCodeProvider).isEmpty) {
                            showSnackBarWidget(
                              // ignore: use_build_context_synchronously
                              context,
                              "Lütfen ders kodu giriniz.",
                            );
                          } else if (await UniversityService().isAssigned(
                              uniId,
                              facultyId,
                              departmentId,
                              ref.watch(courseCodeProvider),
                              ref.watch(rstudentIdProvider).asData?.value ??
                                  " ")) {
                            showSnackBarWidget(
                              // ignore: use_build_context_synchronously
                              context,
                              "Bu derse zaten kayıtlısınız!",
                            );
                          } else if (await UniversityService().courseExists(
                            uniId,
                            facultyId,
                            departmentId,
                            ref.watch(courseCodeProvider),
                          )) {
                            ref.read(containerSizeProvider.notifier).state = 1;
                          } else {
                            showSnackBarWidget(
                              // ignore: use_build_context_synchronously
                              context,
                              "Lütfen geçerli ders kodu giriniz.",
                            );
                          }
                        },
                      ),
                    ],
                  ),
                )
              : AnimatedContainer(
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeInOutQuart,
                  width: 480,
                  height: 570,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(35, 35, 35, 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: StreamBuilder<Course?>(
                    stream: UniversityService().getCourseInfoStream(uniId,
                        facultyId, departmentId, ref.watch(courseCodeProvider)),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        ref.read(containerSizeProvider.notifier).state = 0;
                        return Container();
                      } else if (snapshot.hasData) {
                        ref.read(containerSizeProvider.notifier).state = 1;
                        var course = snapshot.data;
                        return ListView(
                          children: [
                            const SizedBox(height: 50),
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: 300,
                                height: 55,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color.fromRGBO(50, 50, 50, 1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  course!.id,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color:
                                        const Color.fromRGBO(205, 205, 205, 1),
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 20,
                                right: 20,
                              ),
                              child: Column(
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: SizedBox(
                                      child: InfoWidget(
                                        size: size,
                                        label: "Ders adı",
                                        text: course.name,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    child: InfoWidget(
                                      size: size,
                                      label: "Öğretim elemanı",
                                      text: course.instructorId,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    child: InfoWidget(
                                      size: size,
                                      label: "Kaydolan öğrenci sayısı",
                                      text: course.studentIds.length.toString(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 50),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                JoinCourseButtonsWidget(
                                  color: const Color.fromRGBO(81, 130, 155, 1),
                                  text: "Kaydol",
                                  icon: Icons.check,
                                  function: () {
                                    UniversityService().updateAssignedLectures(
                                        uniId,
                                        facultyId,
                                        departmentId,
                                        studentId,
                                        course.id);
                                    UniversityService().updateCourseStudents(
                                        uniId,
                                        facultyId,
                                        departmentId,
                                        studentId,
                                        course.id);

                                    ref
                                        .read(containerSizeProvider.notifier)
                                        .state = 0;
                                    ref
                                        .read(containerSizeProvider.notifier)
                                        .state = 0;

                                    ref
                                        .read(courseCodeProvider.notifier)
                                        .state = "";
                                    ref
                                        .read(selectedStudentPageProvider
                                            .notifier)
                                        .state = 1;
                                    showSnackBarWidget(
                                      // ignore: use_build_context_synchronously
                                      context,
                                      "Derse başarılı bir şekilde kayıt oldunuz.",
                                      color:
                                          const Color.fromRGBO(83, 145, 101, 1),
                                      icon: Icons.check,
                                    );
                                  },
                                ),
                                const SizedBox(width: 20),
                                JoinCourseButtonsWidget(
                                  color: const Color.fromRGBO(211, 118, 118, 1),
                                  text: "İptal",
                                  icon: Icons.cancel,
                                  function: () {
                                    ref
                                        .read(containerSizeProvider.notifier)
                                        .state = 0;
                                    ref
                                        .read(courseCodeProvider.notifier)
                                        .state = "";
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 50),
                          ],
                        );
                      } else {
                        return Container();
                      }
                    },
                  ),
                ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class JoinCourseButtonsWidget extends ConsumerWidget {
  const JoinCourseButtonsWidget({
    super.key,
    required this.function,
    required this.color,
    required this.text,
    required this.icon,
  });

  final Function() function;
  final Color color;
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 40,
      width: 200,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: const Color.fromRGBO(205, 205, 205, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: function,
        icon: Icon(
          icon,
          color: Colors.white,
          size: 18,
        ),
        label: Text(
          text,
          style: Design().poppins(
            size: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class InfoWidget extends StatelessWidget {
  const InfoWidget({
    super.key,
    required this.size,
    required this.label,
    required this.text,
    this.labelColor = const Color.fromRGBO(205, 205, 205, 1),
    this.containerColor = const Color.fromRGBO(50, 50, 50, 1),
    this.textColor = const Color.fromRGBO(205, 205, 205, 1),
  });

  final Size size;
  final String label;
  final String text;
  final Color labelColor;
  final Color containerColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          " $label :",
          style: Design().poppins(
            size: 13,
            fw: FontWeight.bold,
            color: labelColor,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.only(left: 20, right: 20),
          height: 55,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: containerColor,
          ),
          child: Text(
            text,
            style: Design().poppins(size: 13, color: textColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
