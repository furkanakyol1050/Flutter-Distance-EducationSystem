// ignore_for_file: file_names
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobileprojectacademy/firebaseConfig/firebase_transactions.dart';
import 'package:mobileprojectacademy/home/gnav.dart';
import 'package:mobileprojectacademy/myDesign.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

final silinecekProvider = StateProvider((ref) => 0);
final pageChangeProvider = StateProvider((ref) => 0);
final pageHomeworkChangeProvider = StateProvider((ref) => 0);
final courseCodeProvider = StateProvider((ref) => "");
final containerSizeProvider = StateProvider((ref) => 0);

final descriptionProvider = StateProvider((ref) => " ");

final courseIdProvider = StateProvider((ref) => " ");
final instructorIdProvider = StateProvider((ref) => " ");
final homeworkIdProvider = StateProvider((ref) => " ");
final homeworkGivenTimeProvider = StateProvider((ref) => " ");
final homeworkDeadlineProvider = StateProvider((ref) => " ");
final homeworkTitleProvider = StateProvider((ref) => " ");
final homeworkFileNames = StateProvider((ref) => <String>[]);
final homeworkFileUrls = StateProvider((ref) => <String>[]);

final homeworkFileProvider = StateProvider((ref) => <String>[]);
final homeworkFileUrlProvider = StateProvider((ref) => <PlatformFile>[]);

class HomePageWidget extends ConsumerWidget {
  const HomePageWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width,
      height: size.height,
      child: Column(
        children: [
          Container(
            width: size.width,
            height: 50,
            alignment: Alignment.center,
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.only(right: 10),
                    alignment: Alignment.bottomRight,
                    child: Transform.scale(
                      scale: 0.7,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: Container(
                          key: UniqueKey(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                onPressed: () {
                                  ref.read(pageChangeProvider.notifier).state =
                                      2;
                                },
                                icon: Icon(
                                  Icons.calendar_month,
                                  color: Colors.grey.shade800,
                                  size: 30,
                                ),
                                style: IconButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  minimumSize: const Size(50, 50),
                                  hoverColor: Design().blue,
                                  highlightColor:
                                      Design().blue.withOpacity(0.3),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: ref.watch(pageChangeProvider) == 0
                        ? Container(
                            alignment: Alignment.center,
                            key: UniqueKey(),
                            child: Text(
                              "Dersler",
                              style: Design().poppins(
                                color: Colors.grey.shade800,
                                fw: FontWeight.bold,
                                size: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        : ref.watch(pageChangeProvider) == 2
                            ? Container(
                                alignment: Alignment.center,
                                key: UniqueKey(),
                                child: Text(
                                  "Takvim",
                                  style: Design().poppins(
                                    color: Colors.grey.shade800,
                                    fw: FontWeight.bold,
                                    size: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              )
                            : ref.watch(pageHomeworkChangeProvider) == 0
                                ? Container(
                                    alignment: Alignment.center,
                                    key: UniqueKey(),
                                    child: Text(
                                      "Algoritma ve Programlama",
                                      style: Design().poppins(
                                        color: Colors.grey.shade800,
                                        fw: FontWeight.bold,
                                        size: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  )
                                : Container(
                                    alignment: Alignment.center,
                                    key: UniqueKey(),
                                    child: Text(
                                      "Ödev Başlığı",
                                      style: Design().poppins(
                                        color: Colors.grey.shade800,
                                        fw: FontWeight.bold,
                                        size: 16,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: const EdgeInsets.only(right: 10),
                    alignment: Alignment.bottomRight,
                    child: Transform.scale(
                      scale: 0.7,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: ref.watch(pageChangeProvider) == 0
                            ? Container(
                                key: UniqueKey(),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        showAdaptiveDialog(
                                          context: context,
                                          builder: (context) {
                                            return const AddCourseDialog();
                                          },
                                        );
                                      },
                                      icon: Icon(
                                        Icons.add,
                                        color: Colors.grey.shade800,
                                        size: 30,
                                      ),
                                      style: IconButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        minimumSize: const Size(50, 50),
                                        hoverColor: Design().green,
                                        highlightColor:
                                            Design().green.withOpacity(0.3),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        await Future.delayed(
                                            const Duration(seconds: 2), () {
                                          FirebaseAuth.instance.signOut();
                                        });
                                      },
                                      icon: Icon(
                                        Icons.exit_to_app,
                                        color: Colors.grey.shade800,
                                        size: 30,
                                      ),
                                      style: IconButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        minimumSize: const Size(50, 50),
                                        hoverColor: Design().red,
                                        highlightColor:
                                            Design().red.withOpacity(0.3),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ref.watch(pageHomeworkChangeProvider) == 0
                                ? Container(
                                    key: UniqueKey(),
                                    child: IconButton(
                                      onPressed: () {
                                        ref
                                            .read(pageChangeProvider.notifier)
                                            .state = 0;
                                        ref
                                            .read(pageHomeworkChangeProvider
                                                .notifier)
                                            .state = 0;
                                      },
                                      icon: Icon(
                                        Icons.arrow_right,
                                        color: Colors.grey.shade800,
                                        size: 30,
                                      ),
                                      style: IconButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        minimumSize: const Size(50, 50),
                                        hoverColor: Colors.grey.shade300,
                                        highlightColor: Colors.grey.shade300,
                                      ),
                                    ),
                                  )
                                : Container(
                                    key: UniqueKey(),
                                    child: IconButton(
                                      onPressed: () {
                                        ref
                                            .read(pageHomeworkChangeProvider
                                                .notifier)
                                            .state = 0;
                                      },
                                      icon: Icon(
                                        Icons.arrow_right,
                                        color: Colors.grey.shade800,
                                        size: 30,
                                      ),
                                      style: IconButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        minimumSize: const Size(50, 50),
                                        hoverColor: Colors.grey.shade300,
                                        highlightColor: Colors.grey.shade300,
                                      ),
                                    ),
                                  ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: ref.watch(pageChangeProvider) == 0
                  ? Container(
                      key: UniqueKey(),
                      child: const CoursesListWidget(),
                    )
                  : ref.watch(pageChangeProvider) == 1
                      ? Container(
                          key: UniqueKey(),
                          child: const SwitchPageWidget(),
                        )
                      : Container(
                          key: UniqueKey(),
                          child: const CalendarPageWidget(),
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

class CoursesListWidget extends ConsumerWidget {
  const CoursesListWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uniId = ref.watch(suniIdProvider).asData?.value ?? " ";
    final facultyId = ref.watch(sfacultyIdProvider).asData?.value ?? " ";
    final departmentId = ref.watch(sdepartmentIdProvider).asData?.value ?? " ";
    final studentId = ref.watch(sstudentIdProvider).asData?.value ?? " ";

    final size = MediaQuery.of(context).size;
    return StreamBuilder<List<String>>(
        stream: UniversityService()
            .getAssignedLectures(uniId, facultyId, departmentId, studentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
          } else {
            var courses = snapshot.data!;
            return snapshot.hasData
                ? ListView.builder(
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      var course = courses[index];
                      return FutureBuilder<Course>(
                          future: UniversityService().getCourseDetails(
                              uniId, facultyId, departmentId, course),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Container();
                              } else {
                                return Container();
                              }
                            } else {
                              var course = snapshot.data!;
                              return Card(
                                color: Colors.white,
                                shadowColor: Colors.transparent,
                                margin: const EdgeInsets.only(
                                    top: 10, left: 15, right: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(8),
                                  splashColor: Design().yellow,
                                  highlightColor: Design().yellow,
                                  onTap: () {
                                    ref
                                        .read(pageChangeProvider.notifier)
                                        .state = 1;

                                    ref.read(courseIdProvider.notifier).state =
                                        course.id;

                                    ref
                                        .read(instructorIdProvider.notifier)
                                        .state = course.instructorId;
                                  },
                                  child: ListTile(
                                    tileColor: Colors.white,
                                    contentPadding: const EdgeInsets.only(
                                      top: 10,
                                      bottom: 10,
                                      left: 20,
                                      right: 20,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    title: Text(
                                      course.name,
                                      style: Design().poppins(
                                        color: Colors.grey.shade800,
                                        size: 15,
                                      ),
                                    ),
                                    subtitle: Text(
                                      course.instructorId,
                                      // ! düzelt
                                      style: Design().poppins(
                                        color: Colors.grey.shade800,
                                        size: 13,
                                      ),
                                    ),
                                    leading: Container(
                                      padding: const EdgeInsets.only(
                                        right: 10,
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "${course.studentIds.length}  ",
                                            style: Design().poppins(
                                              color: const Color.fromRGBO(
                                                  246, 153, 92, 1),
                                              size: 13,
                                            ),
                                          ),
                                          const Icon(
                                            Icons.groups_rounded,
                                            color:
                                                Color.fromRGBO(246, 153, 92, 1),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }
                          });
                    },
                  )
                : Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      width: size.width,
                      height: 200,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            size: 40,
                            color: Color.fromRGBO(211, 118, 118, 1),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            """Ders kaydınız bulunmamaktadır.\nBağlı olduğunuz kurumdan"""
                            """ almış\nolduğunuz kod ile derslere kayıt\nolabilirsiniz.""",
                            style: Design().poppins(
                              color: Colors.grey.shade800,
                              fw: FontWeight.bold,
                              size: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
          }
        });
  }
}

class SwitchPageWidget extends ConsumerWidget {
  const SwitchPageWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Container(
      key: UniqueKey(),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: ref.watch(pageHomeworkChangeProvider) == 0
            ? Container(
                key: UniqueKey(),
                child: CoursePageWidget(size: size),
              )
            : Container(key: UniqueKey(), child: const HomeworkPageWidget()),
      ),
    );
  }
}

class CoursePageWidget extends ConsumerWidget {
  const CoursePageWidget({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        Container(
          margin: const EdgeInsets.only(
            left: 15,
            right: 15,
            top: 15,
            bottom: 15,
          ),
          padding: const EdgeInsets.all(20),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: FutureBuilder<Instructor>(
              future: UniversityService().getInstructor(
                  ref.watch(instructorIdProvider),
                  ref.watch(suniIdProvider).asData?.value ?? " "),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                } else {
                  var instructor = snapshot.data!;
                  return !snapshot.hasData
                      ? Container(
                          height: 90,
                          padding: const EdgeInsets.only(
                            bottom: 10,
                            top: 10,
                            left: 10,
                            right: 10,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                        )
                      : ListTile(
                          title: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.account_circle,
                                color: Color.fromRGBO(211, 118, 118, 1),
                              ),
                              Expanded(
                                child: Text(
                                  "  ${instructor.title} ${instructor.firstName} ${instructor.lastName}",
                                  style: Design().poppins(
                                    color:
                                        const Color.fromRGBO(211, 118, 118, 1),
                                    fw: FontWeight.bold,
                                    size: 15,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Text(
                            "\n${instructor.branch}\n${instructor.email}",
                            style: Design().poppins(
                              color: Colors.grey.shade800,
                              size: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                        );
                }
              }),
        ),
        Container(
          padding: const EdgeInsets.only(
            left: 15,
            right: 15,
            bottom: 15,
          ),
          width: size.width,
          child: Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Ödevler",
                    style: Design().poppins(
                      size: 16,
                      fw: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                FutureBuilder<List<Homework>>(
                    future: UniversityService().getCourseHomeworks(
                        ref.watch(suniIdProvider).asData?.value ?? " ",
                        ref.watch(sfacultyIdProvider).asData?.value ?? " ",
                        ref.watch(sdepartmentIdProvider).asData?.value ?? " ",
                        ref.watch(courseIdProvider)),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container();
                      } else {
                        var homeworks = snapshot.data!;
                        return snapshot.hasData
                            ? GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: homeworks.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 1,
                                  childAspectRatio: 2.8,
                                  mainAxisSpacing: 5,
                                  crossAxisSpacing: 5,
                                ),
                                itemBuilder: (context, index) {
                                  var homework = homeworks[index];
                                  return Card(
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () {
                                        ref
                                            .read(pageHomeworkChangeProvider
                                                .notifier)
                                            .state = 1;

                                        ref
                                            .read(homeworkIdProvider.notifier)
                                            .state = homework.id;

                                        ref
                                            .read(homeworkGivenTimeProvider
                                                .notifier)
                                            .state = homework.giventime;
                                        ref
                                            .read(homeworkDeadlineProvider
                                                .notifier)
                                            .state = homework.deadline;
                                        ref
                                            .read(homeworkFileNames.notifier)
                                            .state = homework.fileNames;
                                        ref
                                            .read(homeworkFileUrls.notifier)
                                            .state = homework.fileUrls;
                                        ref
                                            .read(
                                                homeworkTitleProvider.notifier)
                                            .state = homework.title;
                                      },
                                      splashColor: Colors.white38,
                                      child: ListTile(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        tileColor: const Color.fromRGBO(
                                            211, 118, 118, 1),
                                        contentPadding: const EdgeInsets.only(
                                          left: 15,
                                          bottom: 10,
                                          top: 10,
                                        ),
                                        title: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 15),
                                          child: Text(
                                            homework.title,
                                            style: Design().poppins(
                                              color: Colors.white,
                                              size: 15,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                        subtitle: Column(
                                          children: [
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.timer_sharp,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                                Text(
                                                  " ${homework.giventime.substring(0, 16)}",
                                                  style: Design().poppins(
                                                    color: Colors.white,
                                                    size: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.timer_off_outlined,
                                                  color: Colors.white,
                                                  size: 18,
                                                ),
                                                Text(
                                                  " ${homework.deadline.substring(0, 16)}",
                                                  style: Design().poppins(
                                                    color: Colors.white,
                                                    size: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Container(
                                alignment: Alignment.center,
                                height: 200,
                                decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(255, 226, 229, 233),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  "Ödev Verilmedi",
                                  style: Design().poppins(
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              );
                      }
                    }),
              ],
            ),
          ),
        ),
        Container(
          //! ÜSTTEKİNDE OLDUĞU GİBİ YÜKLENME VE YOK DURUMLARINI AL
          //! STREAM YAPISININ İÇİNDEKİ İF ELSELERDE VAR
          padding: const EdgeInsets.only(
            left: 15,
            right: 15,
          ),
          width: size.width,
          child: Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Ders Tekrarları",
                    style: Design().poppins(
                      size: 16,
                      fw: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                ref.watch(silinecekProvider) == 0
                    ? GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 3,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          childAspectRatio: 2.8,
                          mainAxisSpacing: 5,
                          crossAxisSpacing: 5,
                        ),
                        itemBuilder: (context, index) {
                          return Card(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {},
                              splashColor: Colors.white38,
                              child: ListTile(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                tileColor:
                                    const Color.fromRGBO(81, 130, 155, 1),
                                contentPadding: const EdgeInsets.only(
                                  left: 15,
                                  bottom: 10,
                                  top: 10,
                                ),
                                title: Text(
                                  "İkili Ağaç Yapıları 1",
                                  style: Design().poppins(
                                    color: Colors.white,
                                    size: 15,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                subtitle: Column(
                                  children: [
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.timer_sharp,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        Text(
                                          " 13 Ekim 2024 14:00",
                                          style: Design().poppins(
                                            color: Colors.white,
                                            size: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.ondemand_video_outlined,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        Text(
                                          " 01:23:51",
                                          style: Design().poppins(
                                            color: Colors.white,
                                            size: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        alignment: Alignment.center,
                        height: 200,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 226, 229, 233),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Ders Tekrarı Bulunamadı",
                          style: Design().poppins(
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class HomeworkPageWidget extends ConsumerWidget {
  const HomeworkPageWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(15),
          width: size.width,
          child: Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Ödev Hakkında",
                    style: Design().poppins(
                      size: 16,
                      fw: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: ListTile(
                        title: Text(
                          "Başlangıç Tarihi",
                          style: Design().poppins(
                            color: Colors.grey.shade800,
                            fw: FontWeight.w500,
                            size: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        subtitle: Text(
                          ref.watch(homeworkGivenTimeProvider).substring(0, 16),
                          style: Design().poppins(
                            color: Colors.grey.shade800,
                            size: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        leading: Icon(
                          Icons.timer_sharp,
                          color: Colors.grey.shade800,
                          size: 20,
                        ),
                      ),
                    ),
                    Flexible(
                      child: ListTile(
                        title: Text(
                          "Bitiş Tarihi",
                          style: Design().poppins(
                            color: Colors.grey.shade800,
                            fw: FontWeight.w500,
                            size: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        subtitle: Text(
                          ref.watch(homeworkDeadlineProvider).substring(0, 16),
                          style: Design().poppins(
                            color: Colors.grey.shade800,
                            size: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        leading: Icon(
                          Icons.timer_off_outlined,
                          color: Colors.grey.shade800,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                Flexible(
                  flex: 2,
                  child: InkWell(
                    onTap: () {
                      showCommentDialog(
                        context: context,
                        text: ref.watch(homeworkTitleProvider),
                        size: size,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 10,
                        bottom: 10,
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color.fromARGB(255, 226, 229, 233),
                      ),
                      child: Text(
                        ref.watch(homeworkTitleProvider),
                        style: Design().poppins(
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(left: 15, bottom: 15, right: 15),
          height: 300,
          child: Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Gönderilen Ekler",
                    style: Design().poppins(
                      size: 16,
                      fw: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                ref.watch(homeworkFileNames).isNotEmpty
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: ref.watch(homeworkFileNames).length,
                          itemBuilder: (context, index) {
                            return Transform.scale(
                              scale: 0.95,
                              child: Card(
                                margin: const EdgeInsets.all(3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                shadowColor: Colors.transparent,
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  tileColor:
                                      const Color.fromARGB(255, 226, 229, 233),
                                  contentPadding: const EdgeInsets.only(
                                    left: 15,
                                    right: 10,
                                  ),
                                  leading: const Icon(
                                    Icons.file_present_rounded,
                                    size: 20,
                                  ),
                                  title: Text(
                                    ref.watch(homeworkFileNames)[index],
                                    style: Design().poppins(
                                      color: Colors.grey.shade800,
                                      size: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  trailing: IconButton(
                                    onPressed: () async {
                                      String filePath =
                                          "uploads/homeworks/${ref.watch(courseIdProvider)}/${ref.watch(homeworkGivenTimeProvider).substring(0, 16)}/${ref.watch(homeworkFileNames)[index]}";
                                      UniversityService()
                                          .downloadFile(filePath);
                                    },
                                    icon: const Icon(
                                      Icons.download,
                                      color: Color.fromRGBO(81, 130, 155, 1),
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 226, 229, 233),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Ek Gönderilmedi",
                            style: Design().poppins(
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(left: 15, bottom: 15, right: 15),
          child: Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Açıklama Ekle",
                    style: Design().poppins(
                      size: 16,
                      fw: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                TextFormField(
                  onChanged: (value) {
                    ref.read(descriptionProvider.notifier).state = value;
                  },
                  style: Design().poppins(
                    size: 14,
                    color: Colors.grey.shade700,
                  ),
                  cursorColor: Colors.grey.shade600,
                  cursorWidth: 2,
                  minLines: 8,
                  maxLines: 8,
                  cursorRadius: const Radius.circular(25),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(
                      left: 30,
                      right: 30,
                      top: 40,
                    ),
                    hintText: "Ödev Açıklaması",
                    hintStyle: Design().poppins(
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    fillColor: const Color.fromARGB(255, 226, 229, 233),
                    filled: true,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color.fromRGBO(83, 145, 101, 0.01),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color.fromRGBO(83, 145, 101, 0.01),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(left: 15, bottom: 15, right: 15),
          height: 300,
          child: Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    FilePickerResult? result = await FilePicker.platform
                        .pickFiles(allowMultiple: true);

                    var list = ref.watch(homeworkFileProvider);
                    var list2 = ref.watch(homeworkFileUrlProvider);

                    if (result != null) {
                      for (PlatformFile file in result.files) {
                        list.add(file.name);
                        list2.add(file);
                      }
                    }
                    // ignore: unused_result
                    ref.refresh(homeworkFileProvider);
                    // ignore: unused_result
                    ref.refresh(homeworkFileUrlProvider);

                    ref.read(homeworkFileUrlProvider.notifier).state = list2;
                    ref.read(homeworkFileProvider.notifier).state = list;
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    foregroundColor: Colors.grey.shade800,
                  ),
                  icon: const Icon(
                    Icons.file_open_outlined,
                    color: Color.fromRGBO(83, 145, 101, 1),
                  ),
                  label: Text(
                    "Dosya Yükle",
                    style: Design().poppins(
                      color: Colors.grey.shade800,
                      fw: FontWeight.w500,
                      size: 14,
                    ),
                  ),
                ),
                ref.watch(homeworkFileProvider).isNotEmpty
                    ? Expanded(
                        child: ListView.builder(
                          itemCount: ref.watch(homeworkFileProvider).length,
                          itemBuilder: (context, index) {
                            return Transform.scale(
                              scale: 0.95,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                shadowColor: Colors.transparent,
                                child: ListTile(
                                  tileColor:
                                      const Color.fromARGB(255, 226, 229, 233),
                                  contentPadding: const EdgeInsets.only(
                                    left: 15,
                                    right: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  leading: const Icon(
                                    Icons.file_present_rounded,
                                    size: 20,
                                  ),
                                  title: Text(
                                    ref.watch(homeworkFileProvider)[index],
                                    style: Design().poppins(
                                      color: Colors.grey.shade800,
                                      size: 15,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  trailing: IconButton(
                                    onPressed: () {
                                      var list =
                                          ref.watch(homeworkFileProvider);
                                      var list2 =
                                          ref.watch(homeworkFileUrlProvider);

                                      list.removeAt(index);
                                      list2.removeAt(index);

                                      // ignore: unused_result
                                      ref.refresh(homeworkFileProvider);
                                      // ignore: unused_result
                                      ref.refresh(homeworkFileUrlProvider);

                                      ref
                                          .read(
                                              homeworkFileUrlProvider.notifier)
                                          .state = list2;
                                      ref
                                          .read(homeworkFileProvider.notifier)
                                          .state = list;
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Color.fromRGBO(211, 118, 118, 1),
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 226, 229, 233),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Dosya Seçilmedi",
                            style: Design().poppins(
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
        Container(
          width: size.width,
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: SizedBox(
            width: 200,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                List<String> tempList = [];
                List<String> tempList2 = [];

                String date = DateTime.now().toString();

                for (var file in ref.watch(homeworkFileUrlProvider)) {
                  String fileName = file.name;
                  Reference storageReference = FirebaseStorage.instance.ref().child(
                      'uploads/sendedhomeworks/${ref.watch(courseIdProvider)}/${ref.watch(homeworkGivenTimeProvider)}/${ref.watch(sstudentIdProvider).asData?.value ?? " "}/$fileName');
                  TaskSnapshot taskSnapshot = await storageReference
                      .putData(file.bytes!)
                      .whenComplete(() => null);
                  String url = await taskSnapshot.ref.getDownloadURL();

                  tempList.add(url);
                  tempList2.add(fileName);
                }

                UniversityService().sendHomework(
                    ref.watch(suniIdProvider).asData?.value ?? " ",
                    ref.watch(sfacultyIdProvider).asData?.value ?? " ",
                    ref.watch(sdepartmentIdProvider).asData?.value ?? " ",
                    ref.watch(courseIdProvider),
                    ref.watch(homeworkIdProvider),
                    ref.watch(sstudentIdProvider).asData?.value ?? " ",
                    ref.watch(homeworkTitleProvider),
                    tempList,
                    tempList2,
                    date);
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: const Color.fromRGBO(246, 153, 92, 1),
                foregroundColor: const Color.fromARGB(255, 226, 229, 233),
                shadowColor: Colors.transparent,
              ),
              child: Text(
                "Ödevi Gönder",
                style: Design().poppins(
                  color: Colors.white,
                  size: 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AddCourseDialog extends ConsumerWidget {
  const AddCourseDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return AlertDialog(
      actionsPadding: EdgeInsets.zero,
      iconPadding: EdgeInsets.zero,
      insetPadding: EdgeInsets.zero,
      titlePadding: EdgeInsets.zero,
      buttonPadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      content: ref.watch(containerSizeProvider) == 0
          ? AnimatedContainer(
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeInOutQuart,
              width: 350,
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
                          ref.watch(suniIdProvider).asData?.value ?? " ",
                          ref.watch(sfacultyIdProvider).asData?.value ?? " ",
                          ref.watch(sdepartmentIdProvider).asData?.value ?? " ",
                          ref.watch(courseCodeProvider),
                          ref.watch(sstudentIdProvider).asData?.value ?? " ")) {
                        showSnackBarWidget(
                          // ignore: use_build_context_synchronously
                          context,
                          "Bu derse zaten kayıtlısınız!",
                        );
                      } else if (await UniversityService().courseExists(
                        ref.watch(suniIdProvider).asData?.value ?? " ",
                        ref.watch(sfacultyIdProvider).asData?.value ?? " ",
                        ref.watch(sdepartmentIdProvider).asData?.value ?? " ",
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
              width: 350,
              height: 500,
              decoration: BoxDecoration(
                color: const Color.fromRGBO(35, 35, 35, 1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView(
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
                        "0A3e456dS41",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color.fromRGBO(205, 205, 205, 1),
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
                              text: "Algoritma ve Programlama",
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          child: InfoWidget(
                            size: size,
                            label: "Öğretim elemanı",
                            text: "Muhammed Furkan Akyol",
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          child: InfoWidget(
                            size: size,
                            label: "Kaydolan öğrenci sayısı",
                            text: "100",
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
                          showSnackBarWidget(
                            // ignore: use_build_context_synchronously
                            context,
                            "Derse başarılı bir şekilde kayıt oldunuz.",
                            color: const Color.fromRGBO(83, 145, 101, 1),
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
                          ref.read(containerSizeProvider.notifier).state = 0;
                          ref.read(courseCodeProvider.notifier).state = "";
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
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
      width: 140,
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
  });

  final Size size;
  final String label;
  final String text;

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
            color: const Color.fromRGBO(205, 205, 205, 1),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.only(left: 20, right: 20),
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: const Color.fromRGBO(50, 50, 50, 1),
          ),
          child: Text(
            text,
            style: Design().poppins(
              size: 13,
              color: const Color.fromRGBO(205, 205, 205, 1),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

showCommentDialog({
  required BuildContext context,
  required String text,
  required Size size,
}) {
  showAdaptiveDialog(
    barrierColor: Colors.black26,
    builder: (context) {
      return Center(
        child: Transform.scale(
          scale: 0.9,
          child: Container(
            width: size.height * 0.6,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 25, bottom: 15),
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(83, 145, 101, 1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.document_scanner_rounded,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  height: 450,
                  child: SingleChildScrollView(
                    child: Text(
                      text,
                      style: Design().poppins(size: 15),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.only(top: 30, bottom: 15),
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(83, 145, 101, 1),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
    context: context,
  );
}

//? CALENDAR

class CalendarPageWidget extends ConsumerWidget {
  const CalendarPageWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          width: size.width,
          height: 953,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(35, 35, 35, 1),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                  ),
                ),
                Expanded(
                  child: SfCalendar(
                    backgroundColor: Colors.white,
                    view: CalendarView.month,
                    todayHighlightColor: const Color.fromRGBO(83, 145, 101, 1),
                    cellBorderColor: Colors.white,
                    firstDayOfWeek: 1,
                    appointmentTimeTextFormat: 'HH:mm',
                    dataSource: _getCalendarDataSource(
                        ref.watch(calendarLecInfos),
                        ref.watch(calendarHomeworkInfos),
                        ref.watch(calendarExamInfos)),
                    appointmentBuilder: (context, calendarAppointmentDetails) {
                      final Appointment appointment =
                          calendarAppointmentDetails.appointments.first;
                      return Card(
                        child: ListTile(
                          tileColor: appointment.color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          leading: SizedBox(
                            width: 100,
                            child: Text(
                              """${DateFormat('HH:mm').format(appointment.startTime)}"""
                              """-${DateFormat('HH:mm').format(appointment.endTime)}""",
                              style: Design().poppins(
                                color: Colors.white,
                                size: 15,
                              ),
                            ),
                          ),
                          title: Text(
                            appointment.subject,
                            style: Design().poppins(
                              color: Colors.white,
                              size: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          subtitle: Text(
                            appointment.notes ?? "",
                            style: Design().poppins(
                              color: Colors.white,
                              size: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      );
                    },
                    selectionDecoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromRGBO(83, 145, 101, 1),
                        width: 3,
                      ),
                    ),
                    monthViewSettings: MonthViewSettings(
                      appointmentDisplayCount: 10,
                      showAgenda: true,
                      dayFormat: 'EEE',
                      agendaItemHeight: 80,
                      agendaStyle: AgendaStyle(
                        backgroundColor:
                            const Color.fromARGB(255, 226, 229, 233),
                        placeholderTextStyle: Design().poppins(
                          color: Colors.grey.shade600,
                          size: 18,
                        ),
                        dayTextStyle: Design().poppins(
                          color: Colors.grey.shade600,
                          size: 18,
                        ),
                        dateTextStyle: Design().poppins(
                          color: Colors.grey.shade600,
                          size: 22,
                        ),
                        appointmentTextStyle: Design().poppins(
                          color: Colors.white,
                          size: 13,
                        ),
                      ),
                      monthCellStyle: MonthCellStyle(
                        textStyle: Design().poppins(
                          color: const Color.fromRGBO(50, 50, 50, 1),
                          size: 18,
                        ),
                        leadingDatesTextStyle: Design().poppins(
                          color: const Color.fromRGBO(180, 180, 180, 1),
                          size: 18,
                        ),
                        trailingDatesTextStyle: Design().poppins(
                          color: const Color.fromRGBO(180, 180, 180, 1),
                          size: 18,
                        ),
                      ),
                    ),
                    headerStyle: CalendarHeaderStyle(
                      backgroundColor: const Color.fromRGBO(35, 35, 35, 1),
                      textStyle: Design().poppins(
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    viewHeaderStyle: ViewHeaderStyle(
                      backgroundColor: const Color.fromRGBO(50, 50, 50, 1),
                      dayTextStyle: Design().poppins(
                        color: const Color.fromRGBO(205, 205, 205, 1),
                        size: 16,
                      ),
                      dateTextStyle: Design().poppins(
                        color: const Color.fromRGBO(205, 205, 205, 1),
                        size: 16,
                      ),
                    ),
                    todayTextStyle: Design().poppins(
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                Container(
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 226, 229, 233),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

_AppointmentDataSource _getCalendarDataSource(
    List<Map<String, dynamic>> courselist,
    List<Map<String, dynamic>> homeworkList,
    List<Map<String, dynamic>> examList) {
  List<Appointment> appointments = <Appointment>[];
  //! if else ile bu 3 yapıdan birisine girecekler

  DateTime now = DateTime.now();
  int currentYear = now.year;
  int currentMonth = now.month;

  for (var course in courselist) {
    for (int i = 0; i < course['startTime'].length; i++) {
      List<String> startTimeParts = course['startTime'][i].split(':');
      List<String> endTimeParts = course['endTime'][i].split(':');
      int dayOfWeek = int.parse(course['day'][i]);

      // Iterate through all days of the current month
      for (int day = 1;
          day <= DateTime(currentYear, currentMonth + 1, 0).day;
          day++) {
        DateTime date = DateTime(currentYear, currentMonth, day);

        if (date.weekday == dayOfWeek + 1) {
          // DateTime weekday: 1=Mon, 7=Sun
          DateTime startTime = DateTime(
            date.year,
            date.month,
            date.day,
            int.parse(startTimeParts[0]),
            int.parse(startTimeParts[1]),
          );

          DateTime endTime = DateTime(
            date.year,
            date.month,
            date.day,
            int.parse(endTimeParts[0]),
            int.parse(endTimeParts[1]),
          );

          appointments.add(Appointment(
              startTime: startTime,
              endTime: endTime,
              subject: "${course['name']} Canlı Dersi",
              color: const Color.fromRGBO(211, 118, 118, 1),
              notes: course['instructorName']));
        }
      }
    }
  }

  for (var exam in examList) {
    appointments.add(Appointment(
      startTime: exam['startTime'],
      endTime: exam['endTime'],
      subject: exam['subject'],
      color: const Color.fromRGBO(81, 130, 155, 1),
      notes: exam['notes'],
    ));
  }
  for (var homework in homeworkList) {
    String deadlineString = homework['deadline'];
    List<String> parts = deadlineString.split(',');
    DateTime deadlineDateTime = DateTime.parse(parts[0]);

    if (parts.length > 1) {
      String timeOfDayString =
          parts[1].replaceAll('TimeOfDay(', '').replaceAll(')', '');
      List<String> timeParts = timeOfDayString.split(':');
      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);

      deadlineDateTime = DateTime(deadlineDateTime.year, deadlineDateTime.month,
          deadlineDateTime.day, hour, minute);
    }

    appointments.add(Appointment(
      startTime: deadlineDateTime,
      endTime: deadlineDateTime.add(const Duration(minutes: 1)),
      subject: '${homework['title']} Son Gönderim Tarihi',
      color: const Color.fromRGBO(246, 153, 92, 1),
      notes: homework['name'],
    ));
  }

  return _AppointmentDataSource(appointments);
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
