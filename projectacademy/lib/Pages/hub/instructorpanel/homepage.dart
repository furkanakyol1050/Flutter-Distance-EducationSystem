import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:projectacademy/Pages/VideoSDK/api_call.dart';
import 'package:projectacademy/Pages/VideoSDK/meeting_screen.dart';
import 'package:projectacademy/Pages/hub/instructorpanel/announcementPage.dart';
import 'package:projectacademy/Pages/hub/instructorpanel/createExamPage.dart';
import 'package:projectacademy/Pages/hub/instructorpanel/homeworkPage.dart';
import 'package:projectacademy/Pages/hub/instructorpanel/instructorPage.dart';
import 'package:projectacademy/Pages/hub/instructorpanel/navbarinstruc.dart';
import 'package:projectacademy/Pages/hub/studentpanel/homepage.dart';
import 'package:projectacademy/Pages/hub/studentpanel/joincoursepage.dart';
import 'package:projectacademy/Pages/hub/uniadminpanel/homepage.dart';
import 'package:projectacademy/firebaseConfig/firebase_transactionss.dart';
import 'package:projectacademy/myDesign.dart';

final assignedStudentCount = StateProvider((ref) => 0);
final silinecek5Provider = StateProvider((ref) => 0);
final selectedStudent4Provider = StateProvider((ref) => 0);

final announcFileCountProvider = StateProvider((ref) => 1);
final videoCountProvider = StateProvider((ref) => 6);
final rightPanelInsProvider = StateProvider((ref) => 0);
final selectedCourseProvider = StateProvider((ref) => 0);
final leftPageChangeInsProvider = StateProvider((ref) => 0);
final selectedHomeworkProvider = StateProvider((ref) => 0);
final searchStudentProvider = StateProvider((ref) => "");

final searchUnsendedStudentsProvider = StateProvider((ref) => "");

final senderIdsProvider = StateProvider((ref) => <String>[]);
final sendersFilesProvider = StateProvider((ref) => <List<String>>[]);
final temp = StateProvider((ref) => <String>[]);

final selectedHomeworkIdProvider = StateProvider((ref) => "");
final courseIndexId = StateProvider((ref) => "");
int x = 0;

final coursesNames = StateProvider((ref) => <String>[]);
final courseIdsProvider = StateProvider((ref) => <String>[]);
final examQuestionsList = StateProvider((ref) => <Map<String, dynamic>>[]);
final updatedQuestionsList = StateProvider((ref) => <Map<String, dynamic>>[]);
final questionsProvider = StateProvider((ref) => <String, dynamic>{});

final allPointsExcel = StateProvider((ref) => <Map<String, dynamic>>[]);

void getFirstCourseId(String uniId, String instructorId, ref) {
  FirebaseFirestore.instance
      .collection('universities')
      .doc(uniId)
      .collection('instructors')
      .doc(instructorId)
      .get()
      .then(
    (value) {
      if (value['courseIds'].isNotEmpty) {
        ref.read(courseIndexId.notifier).state = value['courseIds'].first;
      }
    },
  );
}

void getFirstSelectedHomework(
    String uniId, String facultyId, String departmentId, String courseId, ref) {
  FirebaseFirestore.instance
      .collection('universities')
      .doc(uniId)
      .collection('faculties')
      .doc(facultyId)
      .collection('departments')
      .doc(departmentId)
      .collection('courses')
      .doc(courseId)
      .collection('homeworks')
      .limit(1)
      .get()
      .then(
    (QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        ref.read(selectedHomeworkIdProvider.notifier).state =
            querySnapshot.docs.first.id;
        ref.read(selectedHomeworkProvider.notifier).state = 0;
      }
    },
  );
}

final insCourseNameProvider = StateProvider((ref) => " ");
final insCourseCodeProvider = StateProvider((ref) => " ");

class HomePageWidget extends ConsumerWidget {
  const HomePageWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return AnimatedSwitcher(
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      duration: const Duration(milliseconds: 500),
      child: ref.watch(leftPageChangeInsProvider) == 0
          ? ListView(
              children: [
                Container(
                  height: 50,
                  padding: const EdgeInsets.only(left: 50, right: 20),
                  alignment: Alignment.center,
                  color: Colors.white,
                  child: FutureBuilder<Course?>(
                      future: UniversityService().getCourseById(
                        ref.watch(luniIdProvider).asData!.value,
                        ref.watch(lfacultyIdProvider).asData!.value,
                        ref.watch(ldepartmentIdProvider).asData!.value,
                        ref.watch(courseIndexId),
                      ),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Container();
                        } else if (snapshot.hasError) {
                          return Container();
                        } else {
                          final course = snapshot.data!;
                          return Row(
                            children: [
                              Text(
                                "${course.name} \\ ",
                                style: Design().poppins(
                                  color: Colors.grey.shade800,
                                  fw: FontWeight.bold,
                                  size: 14,
                                ),
                              ),
                              Text(
                                course.id,
                                style: Design().poppins(
                                  color: Colors.grey.shade800,
                                  size: 13,
                                ),
                              ),
                            ],
                          );
                        }
                      }),
                ),
                size.width > 1300
                    ? const Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  LeftTopWidget(),
                                  LeftMiddleWidget(),
                                ],
                              ),
                              RightWidget(),
                            ],
                          ),
                          BottomWidget(),
                        ],
                      )
                    : Column(
                        children: [
                          const LeftTopWidget(),
                          const LeftMiddleWidget(),
                          size.width > 900 ? const RightWidget() : Container(),
                          const BottomWidget(),
                        ],
                      ),
              ],
            )
          : ref.watch(leftPageChangeInsProvider) == 1
              ? const CheckHomeworkWidget()
              : const CheckExamWidget(),
    );
  }
}

//! ORTA EKRAN

class RightWidget extends ConsumerWidget {
  const RightWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(
        bottom: 20,
        top: 40,
        left: size.width > 1300 ? 20 : 40,
        right: 40,
      ),
      width:
          size.width > 1300 ? ((size.width - 121) / 5) * 2 : size.width - 121,
      height: size.width > 1300 ? 750 : 500,
      child: Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(35, 35, 35, 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              alignment: Alignment.centerLeft,
              child: Text(
                "Dersi Alan Öğrenciler",
                style: Design().poppins(
                  size: 16,
                  fw: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 42,
                    child: CostomSearchBarWidget(
                      function: (String search) {
                        ref.read(searchStudentProvider.notifier).state = search;
                      },
                      hintText: "Öğrenci Ara",
                    ),
                  ),
                  FutureBuilder<List<String>>(
                    future: UniversityService().getAllCourseStudents(
                        ref.watch(luniIdProvider).asData?.value ?? " ",
                        ref.watch(lfacultyIdProvider).asData?.value ?? " ",
                        ref.watch(ldepartmentIdProvider).asData?.value ?? " ",
                        ref.watch(courseIndexId),
                        ref.watch(searchStudentProvider)),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting ||
                          snapshot.data!.isEmpty) {
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(20),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(50, 50, 50, 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const SpinKitPulse(
                              color: Colors.white,
                              size: 50,
                            ),
                          ),
                        );
                      } else {
                        var students = snapshot.data!;
                        return Expanded(
                          flex: 27,
                          child: students.isNotEmpty
                              ? Container(
                                  margin: const EdgeInsets.all(20),
                                  child: RightPanelListWidget(
                                    studentsList: students,
                                    provider: selectedStudent4Provider,
                                  ),
                                )
                              : Container(
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: const Color.fromRGBO(50, 50, 50, 1),
                                  ),
                                  child: Text(
                                    "Öğrenci Bulunamadı",
                                    style: Design().poppins(
                                      size: 15,
                                      color: const Color.fromRGBO(
                                          205, 205, 205, 1),
                                    ),
                                  ),
                                ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RightPanelListWidget extends ConsumerWidget {
  final List<String> studentsList;
  const RightPanelListWidget({
    super.key,
    required this.studentsList,
    required this.provider,
  });

  final StateProvider<int> provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: studentsList.length,
      itemBuilder: (context, index) {
        return Card(
          color: ref.watch(provider) == index
              ? const Color.fromRGBO(90, 90, 90, 1)
              : const Color.fromARGB(255, 75, 71, 71),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () async {
              if (provider == selectedStudent5Provider) {
                ref.read(examSelectedStuProvider.notifier).state =
                    studentsList[index];

                ref.read(examQuestionsList.notifier).state =
                    await UniversityService().getExamQuestions(
                        ref.watch(luniIdProvider).asData?.value ?? "",
                        ref.watch(lfacultyIdProvider).asData?.value ?? "",
                        ref.watch(ldepartmentIdProvider).asData?.value ?? "",
                        ref.watch(examSelectedStuProvider),
                        ref.watch(courseSelectedProvider),
                        ref.watch(lectureExProvider));

                ref.read(updatedQuestionsList.notifier).state = [];
                for (var i in ref.watch(examQuestionsList)) {
                  if (i['type'] == "TextQuestion" ||
                      i['type'] == "ClassicQuestion") {
                    ref.read(updatedQuestionsList).add(i);
                  } else {
                    if (i['answer'] == i['correctAnswer']) {
                      ref.read(totalPointProvider.notifier).state +=
                          int.parse(i['point']);
                    }
                  }
                }

                ref.read(provider.notifier).state = index;

                final student = await UniversityService().getStudentBasicInfo(
                    ref.watch(luniIdProvider).asData?.value ?? "",
                    ref.watch(lfacultyIdProvider).asData?.value ?? "",
                    ref.watch(ldepartmentIdProvider).asData?.value ?? "",
                    studentsList[index]);

                ref.read(examSelectedStuNameProvider.notifier).state =
                    student['name'];
                ref.read(examSelectedStuSnameProvider.notifier).state =
                    student['sname'];
                ref.read(examSelectedStuNoProvider.notifier).state =
                    student['no'];
                ref.read(examSelectedStuMailProvider.notifier).state =
                    student['mail'];
              }
            },
            child: FutureBuilder<Student>(
              future: UniversityService().getStudentDetails(
                  ref.watch(luniIdProvider).asData?.value ?? " ",
                  ref.watch(lfacultyIdProvider).asData?.value ?? " ",
                  ref.watch(ldepartmentIdProvider).asData?.value ?? " ",
                  studentsList[index]),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container();
                  } else {
                    return Container();
                  }
                } else {
                  final student = snapshot.data!;
                  return ListTile(
                    contentPadding: const EdgeInsets.only(
                      top: 10,
                      bottom: 10,
                      left: 20,
                      right: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    tileColor: ref.watch(provider) == index
                        ? const Color.fromRGBO(90, 90, 90, 1)
                        : const Color.fromRGBO(50, 50, 50, 1),
                    title: Text(
                      "${student.name} ${student.sname}",
                      style: Design().poppins(
                        color: const Color.fromRGBO(205, 205, 205, 1),
                        size: 15,
                      ),
                    ),
                    subtitle: Text(
                      student.mail,
                      style: Design().poppins(
                        color: const Color.fromRGBO(205, 205, 205, 1),
                        size: 13,
                      ),
                    ),
                    leading: Container(
                      padding: const EdgeInsets.only(
                        right: 10,
                      ),
                      child: Text(
                        student.no,
                        style: Design().poppins(
                          color: const Color.fromRGBO(246, 153, 92, 1),
                          size: 13,
                        ),
                      ),
                    ),
                    trailing: selectedStudent4Provider == provider
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  ref
                                      .read(
                                          selectedInstrucPageProvider.notifier)
                                      .state = 3;
                                  ref.read(rightPanel2Provider.notifier).state =
                                      1;
                                  ref
                                      .read(selectedStudent3Provider.notifier)
                                      .state = index;

                                  ref
                                      .read(selectedStudent3IdProvider.notifier)
                                      .state = student.id;
                                },
                                icon: const Icon(
                                  Icons.comment_rounded,
                                  color: Color.fromRGBO(205, 205, 205, 1),
                                  size: 19,
                                ),
                                style: IconButton.styleFrom(
                                  hoverColor: Colors.grey.shade700,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  showTextDialog(
                                    context: context,
                                    color:
                                        const Color.fromRGBO(211, 118, 118, 1),
                                    ref: ref,
                                    buttonText: "Çıkart",
                                    tittleText:
                                        "Çıkartmak istediğinize emin misiniz?",
                                    centerText: "Öğrenci dersten çıkartılacak.",
                                    icon: Icons.delete_forever,
                                    buttonFunc: () {
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  color: Color.fromRGBO(211, 118, 118, 1),
                                  size: 19,
                                ),
                                style: IconButton.styleFrom(
                                  hoverColor: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          )
                        : const SizedBox(),
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}

void onStartButtonPressed(BuildContext context, String uniId, String facultyId,
    String departmentId, String personName, String courseId) async {
  // call api to create meeting and then navigate to MeetingScreen with meetingId,token
  var a = 1;
  await createMeeting().then(
    (meetingId) {
      if (!context.mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => MeetingScreen(
            meetingId,
            token,
            uniId: uniId,
            facultyId: facultyId,
            departmentId: departmentId,
            personName: personName,
            courseId: courseId,
            insId: "",
            isCreater: a,
          ),
        ),
      );
    },
  );
}

class LeftTopWidget extends ConsumerWidget {
  const LeftTopWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uniId = ref.watch(luniIdProvider).asData?.value ?? "";
    final facultyId = ref.watch(lfacultyIdProvider).asData?.value ?? "";
    final departmentId = ref.watch(ldepartmentIdProvider).asData?.value ?? "";
    final instructorId = ref.watch(linstructorIdProvider).asData?.value ?? "";
    final courseId = ref.watch(courseIndexId);
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(
        left: 40,
        top: size.width > 1300 ? 40 : 20,
        bottom: 20,
        right: size.width > 1300 ? 20 : 40,
      ),
      width:
          size.width > 1300 ? ((size.width - 121) / 5) * 3 : size.width - 121,
      child: size.width > 900
          ? Row(
              children: [
                CardButtonWidget(
                  color: const Color.fromRGBO(81, 130, 155, 1),
                  func: () async {
                    var instructorName = await UniversityService()
                        .getInstructorName(uniId, instructorId);
                    // ignore: use_build_context_synchronously
                    onStartButtonPressed(context, uniId, facultyId,
                        departmentId, instructorName, courseId);
                  },
                  tittle: "Canlı Ders Başlat",
                  subtittle: "\nPazartesi 13:00 - 15:00\nPerşembe 9:00 - 12:00",
                ),
                const SizedBox(width: 10),
                CardButtonWidget(
                  color: const Color.fromRGBO(211, 118, 118, 1),
                  func: () async {
                    ref.read(coursesNames.notifier).state = [];
                    var courseIds = await UniversityService()
                        .getCourseIds(uniId, instructorId);
                    for (var id in courseIds) {
                      var details = await UniversityService()
                          .getCourseDetails(uniId, facultyId, departmentId, id);
                      ref.read(coursesNames).add(details.name);
                      ref.read(courseIdsProvider).add(id);
                    }
                    ref.read(leftPageChangeInsProvider.notifier).state = 2;
                  },
                  tittle: "Sınav Sonuçları",
                  subtittle:
                      "\nVize Pazertesi 13:00 - 15:00\nFinal Belirlenmemiş",
                ),
                const SizedBox(width: 10),
                CardButtonWidget(
                  color: const Color.fromRGBO(246, 153, 92, 1),
                  func: () {
                    ref.read(leftPageChangeInsProvider.notifier).state = 1;
                  },
                  tittle: "Ödev Gönderileri",
                  subtittle: "\nSon Teslim Tarihi Geçmiş\nÖdevler : 5",
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CardButtonWidget(
                  color: const Color.fromRGBO(81, 130, 155, 1),
                  func: () {},
                  tittle: "Canlı Ders Başlat",
                  subtittle: "\nPazartesi 13:00 - 15:00\nPerşembe 9:00 - 12:00",
                ),
                const SizedBox(width: 10),
                CardButtonWidget(
                  color: const Color.fromRGBO(211, 118, 118, 1),
                  func: () {
                    ref.read(leftPageChangeInsProvider.notifier).state = 2;
                  },
                  tittle: "Sınav Sonuçları",
                  subtittle:
                      "\nVize Pazertesi 13:00 - 15:00\nFinal Belirlenmemiş",
                ),
                const SizedBox(width: 10),
                CardButtonWidget(
                  color: const Color.fromRGBO(246, 153, 92, 1),
                  func: () {
                    ref.read(leftPageChangeInsProvider.notifier).state = 1;
                  },
                  tittle: "Ödev Gönderileri",
                  subtittle: "\nSon Teslim Tarihi Geçmiş\nÖdevler : 5",
                ),
              ],
            ),
    );
  }
}

class CardButtonWidget extends ConsumerWidget {
  const CardButtonWidget({
    super.key,
    required this.color,
    required this.func,
    required this.tittle,
    required this.subtittle,
  });

  final Color color;
  final Function() func;
  final String tittle;
  final String subtittle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Flexible(
      child: SizedBox(
        height: 150,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(
              color: Colors.white,
              width: 4,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: func,
            splashColor: Colors.white38,
            child: ListTile(
              tileColor: color,
              contentPadding: const EdgeInsets.only(
                bottom: 10,
                top: 10,
                left: 20,
                right: 20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(
                  color: Colors.white,
                  width: 4,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
              ),
              title: Text(
                tittle,
                style: Design().poppins(
                  color: Colors.white,
                  fw: FontWeight.bold,
                  size: 20,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                subtittle,
                style: Design().poppins(
                  color: Colors.white,
                  size: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LeftMiddleWidget extends ConsumerWidget {
  const LeftMiddleWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uniId = ref.watch(luniIdProvider).asData?.value ?? " ";
    final facultyId = ref.watch(lfacultyIdProvider).asData?.value ?? " ";
    final departmentId = ref.watch(ldepartmentIdProvider).asData?.value ?? " ";
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(
        left: 40,
        top: 20,
        bottom: 20,
        right: size.width > 1300 ? 20 : 40,
      ),
      width:
          size.width > 1300 ? ((size.width - 121) / 5) * 3 : size.width - 121,
      height: 540,
      child: StreamBuilder<List<CourseAnno>>(
          stream: UniversityService().getCourseAnnouncementsStream(
              uniId, facultyId, departmentId, ref.watch(courseIndexId)),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Container(
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  height: double.infinity,
                  width: double.infinity,
                  child: const Center(
                    child: SpinKitPulse(
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                );
              } else {
                return Container(
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  height: double.infinity,
                  width: double.infinity,
                );
              }
            } else {
              final announcements = snapshot.data!;
              return announcements.isNotEmpty
                  ? Container(
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
                              "Ders Duyuruları",
                              style: Design().poppins(
                                size: 16,
                                fw: FontWeight.w600,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: announcements.length,
                              itemBuilder: (context, index) {
                                final announcement = announcements[index];
                                return ExpansionTileCard(
                                  contentPadding: const EdgeInsets.all(10),
                                  expandedColor:
                                      const Color.fromARGB(255, 226, 229, 233),
                                  colorCurve: Curves.linear,
                                  shadowColor: Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                  baseColor:
                                      const Color.fromARGB(255, 226, 229, 233),
                                  expandedTextColor: Colors.black,
                                  initialPadding:
                                      const EdgeInsets.only(top: 10),
                                  finalPadding: const EdgeInsets.only(top: 10),
                                  leading: SizedBox(
                                    width: 100,
                                    child: Text(
                                      announcement.releaseDate.substring(0, 16),
                                      textAlign: TextAlign.center,
                                      style: Design().poppins(
                                        size: 12,
                                        fw: FontWeight.bold,
                                        color: Colors.grey.shade800,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.fade,
                                    ),
                                  ),
                                  title: Text(
                                    announcement.title,
                                    style: Design().poppins(
                                      size: 14,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  trailing: IconButton(
                                    onPressed: () {
                                      showTextDialog(
                                        context: context,
                                        color: const Color.fromRGBO(
                                            211, 118, 118, 1),
                                        ref: ref,
                                        buttonText: "Sil",
                                        tittleText:
                                            "Silmek istediğinize emin misiniz?",
                                        centerText:
                                            "Duyuru tamamen kaldırılacak.",
                                        icon: Icons.delete_forever,
                                        buttonFunc: () {
                                          Navigator.pop(context);
                                          UniversityService()
                                              .deleteCourseAnnouncement(
                                                  uniId,
                                                  facultyId,
                                                  departmentId,
                                                  ref.watch(courseIndexId),
                                                  announcement.id);
                                        },
                                      );
                                    },
                                    icon: Icon(
                                      Icons.delete,
                                      color: Colors.grey.shade800,
                                    ),
                                    style: IconButton.styleFrom(
                                      minimumSize: const Size(55, 55),
                                      hoverColor: const Color.fromARGB(
                                          255, 196, 198, 202),
                                    ),
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(20),
                                      child: Text(
                                        announcement.content,
                                        style: Design().poppins(
                                          size: 14,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    ),
                                    announcement.fileUrls.isNotEmpty
                                        ? Container(
                                            alignment: Alignment.center,
                                            margin: const EdgeInsets.only(
                                              left: 40,
                                              right: 40,
                                            ),
                                            padding: const EdgeInsets.only(
                                              left: 20,
                                              right: 20,
                                            ),
                                            height:
                                                announcement.fileUrls.length *
                                                    77,
                                            child: ListView.builder(
                                              itemCount:
                                                  announcement.fileUrls.length,
                                              itemBuilder: (context, index) {
                                                return Card(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  shadowColor:
                                                      Colors.transparent,
                                                  child: ListTile(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    tileColor: Colors.white,
                                                    leading: const Icon(Icons
                                                        .file_present_rounded),
                                                    title: Text(
                                                      announcement
                                                          .fileNames[index],
                                                      style: Design().poppins(
                                                        color: Colors
                                                            .grey.shade800,
                                                        size: 15,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                    trailing: IconButton(
                                                      onPressed: () {
                                                        for (var file
                                                            in announcement
                                                                .fileUrls) {
                                                          UniversityService()
                                                              .downloadFile(
                                                                  file);
                                                        }
                                                      },
                                                      icon: const Icon(
                                                        Icons.download,
                                                        color: Color.fromRGBO(
                                                            81, 130, 155, 1),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          )
                                        : Container(
                                            height: 100,
                                            margin: const EdgeInsets.all(30),
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              "Ek Bulunamadı",
                                              style: Design().poppins(
                                                size: 14,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      height: MediaQuery.of(context).size.height / 1.84,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 226, 229, 233),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Duyuru Paylaşılmadı",
                          style: Design().poppins(
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    );
            }
          }),
    );
  }
}

final fileListtProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, path) async {
  final ListResult result = await FirebaseStorage.instance.ref(path).listAll();
  final List<Map<String, dynamic>> allFiles = [];

  for (var ref in result.items) {
    final String url = await ref.getDownloadURL();
    final FullMetadata metadata = await ref.getMetadata();

    allFiles.add({
      'name': ref.name,
      'url': url,
      'path': ref.fullPath,
      'timeCreated': metadata.timeCreated,
    });
  }
  return allFiles;
});

class BottomWidget extends ConsumerWidget {
  const BottomWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncFileList =
        ref.watch(fileListtProvider(ref.watch(courseIndexId)));
    final size = MediaQuery.of(context).size;
    return Container(
      padding: const EdgeInsets.only(
        left: 40,
        top: 20,
        bottom: 40,
        right: 40,
      ),
      width: size.width - 121,
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
            asyncFileList.when(
              data: (files) {
                if (files.isEmpty) {
                  return Container(
                    alignment: Alignment.center,
                    height: 180,
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
                  );
                }
                return GridView.builder(
                  shrinkWrap: true,
                  itemCount: files.length, // Use the length of the files list
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: MediaQuery.of(context).size.width > 1800
                        ? 4
                        : MediaQuery.of(context).size.width > 1000
                            ? 3
                            : MediaQuery.of(context).size.width > 700
                                ? 2
                                : 1,
                    childAspectRatio: 2.2,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                  ),
                  itemBuilder: (context, index) {
                    final file = files[index];
                    return Card(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () async {
                          final downloadUrl = await FirebaseStorage.instance
                              .ref(file['path'])
                              .getDownloadURL();

                          UniversityService().downloadFile(downloadUrl);
                        },
                        splashColor: Colors.white38,
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          tileColor: const Color.fromRGBO(81, 130, 155, 1),
                          contentPadding: const EdgeInsets.only(
                            left: 15,
                            bottom: 10,
                            top: 10,
                          ),
                          title: Text(
                            file['name'],
                            style: Design().poppins(
                              color: Colors.white,
                              size: 15,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                    file['timeCreated']
                                        .toString()
                                        .substring(0, 16),
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
                );
              },
              error: (error, stack) => Container(
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
              loading: () => Center(
                child: SizedBox(
                  height: 180,
                  child: SpinKitPulse(
                    color: Colors.grey.shade800,
                    size: 50.0,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

//! ODEV EKRANI
bool r = true;

class CheckHomeworkWidget extends ConsumerWidget {
  const CheckHomeworkWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (r) {
      getFirstSelectedHomework(
          ref.watch(runiIdProvider).asData?.value ?? "",
          ref.watch(rfacultyIdProvider).asData?.value ?? "",
          ref.watch(rdepartmentIdProvider).asData?.value ?? "",
          ref.watch(courseIndexId),
          ref);
      r = false;
    }
    final size = MediaQuery.of(context).size;
    return ListView(
      children: [
        Container(
          height: 50,
          padding: const EdgeInsets.only(left: 50, right: 20),
          alignment: Alignment.center,
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Ödev Gönderileri",
                style: Design().poppins(
                  color: Colors.grey.shade800,
                  fw: FontWeight.bold,
                  size: 14,
                ),
              ),
              Transform.scale(
                scale: 0.8,
                child: IconButton(
                  onPressed: () {
                    ref.read(leftPageChangeInsProvider.notifier).state = 0;
                  },
                  icon: Icon(
                    Icons.arrow_right_rounded,
                    size: 35,
                    color: Colors.grey.shade800,
                  ),
                  style: IconButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    minimumSize: const Size(50, 50),
                    backgroundColor: const Color.fromARGB(255, 226, 229, 233),
                    hoverColor: const Color.fromARGB(255, 196, 198, 202),
                  ),
                ),
              ),
            ],
          ),
        ),
        size.width > 1600
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      SizedBox(
                        height: 400,
                        width: ((size.width - 121) / 6) * 4,
                        child: const Row(
                          children: [
                            TopLeftHomeworkWidget(),
                            TopRightHomeworkWidget(),
                          ],
                        ),
                      ),
                      const Row(
                        children: [
                          BottomLeftHomeworkWidget(),
                          BottomRightHomeworkWidget()
                        ],
                      ),
                    ],
                  ),
                  const RightCheckHomeworkWidget(),
                ],
              )
            : size.width > 700
                ? Column(
                    children: [
                      SizedBox(
                        height: 850,
                        width: size.width - 121,
                        child: const Column(
                          children: [
                            TopLeftHomeworkWidget(),
                            TopRightHomeworkWidget(),
                          ],
                        ),
                      ),
                      const BottomLeftHomeworkWidget(),
                      const BottomRightHomeworkWidget(),
                      const RightCheckHomeworkWidget(),
                    ],
                  )
                : Container(),
      ],
    );
  }
}

class TopLeftHomeworkWidget extends ConsumerWidget {
  const TopLeftHomeworkWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Flexible(
      flex: 5,
      child: Container(
        padding: EdgeInsets.only(
          left: 40,
          top: 40,
          bottom: 20,
          right: size.width > 1600 ? 20 : 40,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
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
              FutureBuilder<Homework>(
                  future: UniversityService().getHomeworkDetails(
                      ref.watch(runiIdProvider).asData?.value ?? "",
                      ref.watch(rfacultyIdProvider).asData?.value ?? "",
                      ref.watch(rdepartmentIdProvider).asData?.value ?? "",
                      ref.watch(courseIndexId),
                      ref.watch(selectedHomeworkIdProvider)),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container();
                      } else {
                        return Container();
                      }
                    } else {
                      var homework = snapshot.data!;
                      return Expanded(
                        child: size.width > 800
                            ? Row(
                                children: [
                                  Flexible(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
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
                                            homework.giventime,
                                            style: Design().poppins(
                                              color: Colors.grey.shade800,
                                              size: 13,
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
                                        ListTile(
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
                                            homework.deadline,
                                            style: Design().poppins(
                                              color: Colors.grey.shade800,
                                              size: 13,
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
                                        const Spacer(flex: 2),
                                      ],
                                    ),
                                  ),
                                  Flexible(
                                    flex: 2,
                                    child: InkWell(
                                      onTap: () {
                                        showCommentDialog(
                                          context: context,
                                          text: homework.title,
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                            left: 20, right: 20),
                                        margin: const EdgeInsets.only(
                                          bottom: 20,
                                        ),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: const Color.fromARGB(
                                              255, 226, 229, 233),
                                        ),
                                        child: Text(
                                          homework.title,
                                          style: Design().poppins(
                                            size: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  Flexible(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
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
                                            homework.giventime,
                                            style: Design().poppins(
                                              color: Colors.grey.shade800,
                                              size: 13,
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
                                        ListTile(
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
                                            homework.deadline,
                                            style: Design().poppins(
                                              color: Colors.grey.shade800,
                                              size: 13,
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
                                        const Spacer(flex: 2),
                                      ],
                                    ),
                                  ),
                                  Flexible(
                                    flex: 2,
                                    child: InkWell(
                                      onTap: () {
                                        showCommentDialog(
                                          context: context,
                                          text: homework.title,
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                            left: 20, right: 20),
                                        margin: const EdgeInsets.only(
                                          bottom: 20,
                                        ),
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: const Color.fromARGB(
                                              255, 226, 229, 233),
                                        ),
                                        child: Text(
                                          homework.title,
                                          style: Design().poppins(
                                            size: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      );
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

class TopRightHomeworkWidget extends ConsumerWidget {
  const TopRightHomeworkWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Flexible(
      flex: 3,
      child: Container(
        padding: EdgeInsets.only(
          left: size.width > 1600 ? 20 : 40,
          top: size.width > 1600 ? 40 : 20,
          bottom: 20,
          right: 40,
        ),
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
              FutureBuilder<Homework>(
                  future: UniversityService().getHomeworkDetails(
                      ref.watch(luniIdProvider).asData?.value ?? "",
                      ref.watch(lfacultyIdProvider).asData?.value ?? "",
                      ref.watch(ldepartmentIdProvider).asData?.value ?? "",
                      ref.watch(courseIndexId),
                      ref.watch(selectedHomeworkIdProvider)),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container();
                      } else {
                        return Container();
                      }
                    } else {
                      var homework = snapshot.data!;
                      var files = homework.fileNames;
                      return files.isNotEmpty
                          ? Expanded(
                              child: ListView.builder(
                                itemCount: files.length,
                                itemBuilder: (context, index) {
                                  var file = files[index];
                                  return Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    shadowColor: Colors.transparent,
                                    child: ListTile(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      tileColor: const Color.fromARGB(
                                          255, 226, 229, 233),
                                      leading: const Icon(
                                          Icons.file_present_rounded),
                                      title: Text(
                                        file,
                                        style: Design().poppins(
                                          color: Colors.grey.shade800,
                                          size: 15,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      trailing: IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                          Icons.download,
                                          color:
                                              Color.fromRGBO(81, 130, 155, 1),
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
                                  color:
                                      const Color.fromARGB(255, 226, 229, 233),
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
                            );
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}

class RightCheckHomeworkWidget extends ConsumerWidget {
  const RightCheckHomeworkWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uniId = ref.watch(luniIdProvider).asData?.value ?? "";
    final facultyId = ref.watch(lfacultyIdProvider).asData?.value ?? "";
    final departmentId = ref.watch(ldepartmentIdProvider).asData?.value ?? "";
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(
        bottom: size.width > 1600 ? 40 : 20,
        top: 40,
        left: size.width > 1600 ? 20 : 40,
        right: 40,
      ),
      width:
          size.width > 1600 ? ((size.width - 121) / 6) * 2 : size.width - 121,
      height: size.width > 1600 ? 1000 : 500,
      child: Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(35, 35, 35, 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: FutureBuilder<List<Homework>>(
            future: UniversityService().getCourseHomeworks(
                uniId, facultyId, departmentId, ref.watch(courseIndexId)),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                } else {
                  return Container();
                }
              } else {
                var homeworks = snapshot.data!;
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Ödevler",
                        style: Design().poppins(
                          size: 16,
                          fw: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Expanded(
                      child: homeworks.isNotEmpty
                          ? Container(
                              margin: const EdgeInsets.all(20),
                              child: ListView.builder(
                                itemCount: homeworks.length,
                                itemBuilder: (context, index) {
                                  var homework = homeworks[index];
                                  return Card(
                                    color: ref.watch(
                                                selectedHomeworkProvider) ==
                                            index
                                        ? const Color.fromRGBO(90, 90, 90, 1)
                                        : const Color.fromRGBO(50, 50, 50, 1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () {
                                        ref
                                            .read(selectedHomeworkProvider
                                                .notifier)
                                            .state = index;

                                        ref
                                            .read(selectedHomeworkIdProvider
                                                .notifier)
                                            .state = homework.id;
                                      },
                                      child: ListTile(
                                        contentPadding: const EdgeInsets.only(
                                          top: 10,
                                          bottom: 10,
                                          left: 20,
                                          right: 20,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        tileColor: ref.watch(
                                                    selectedHomeworkProvider) ==
                                                index
                                            ? const Color.fromRGBO(
                                                90, 90, 90, 1)
                                            : const Color.fromRGBO(
                                                50, 50, 50, 1),
                                        title: Text(
                                          homework.title,
                                          style: Design().poppins(
                                            color: const Color.fromRGBO(
                                                205, 205, 205, 1),
                                            size: 15,
                                          ),
                                        ),
                                        subtitle: Text(
                                          homework.deadline.substring(0, 16),
                                          style: Design().poppins(
                                            color: const Color.fromRGBO(
                                                205, 205, 205, 1),
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
                                                "20  ",
                                                style: Design().poppins(
                                                  color: const Color.fromRGBO(
                                                      83, 145, 101, 1),
                                                  size: 13,
                                                ),
                                              ),
                                              const Icon(
                                                Icons.send_rounded,
                                                color: Color.fromRGBO(
                                                    83, 145, 101, 1),
                                              )
                                            ],
                                          ),
                                        ),
                                        trailing: IconButton(
                                          onPressed: () {
                                            showTextDialog(
                                              context: context,
                                              color: const Color.fromRGBO(
                                                  211, 118, 118, 1),
                                              ref: ref,
                                              buttonText: "İptal Et",
                                              tittleText:
                                                  "Silmek istediğinize emin misiniz? \n Tüm ödev gönderileri de silinecektir!",
                                              centerText:
                                                  "Ödev iptal edilecek.",
                                              icon: Icons.delete_forever,
                                              buttonFunc: () {
                                                Navigator.pop(context);
                                                UniversityService()
                                                    .deleteHomework(
                                                        uniId,
                                                        facultyId,
                                                        departmentId,
                                                        ref.watch(
                                                            courseIndexId),
                                                        ref.watch(
                                                            selectedHomeworkIdProvider))
                                                    .then((value) =>
                                                        getFirstSelectedHomework(
                                                            uniId,
                                                            facultyId,
                                                            departmentId,
                                                            ref.watch(
                                                                courseIndexId),
                                                            ref));
                                              },
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Color.fromRGBO(
                                                211, 118, 118, 1),
                                            size: 19,
                                          ),
                                          style: IconButton.styleFrom(
                                            hoverColor: Colors.grey.shade700,
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
                                margin: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: const Color.fromRGBO(50, 50, 50, 1),
                                ),
                                child: Text(
                                  "Bu Derse Ödev\nEklenmedi",
                                  style: Design().poppins(
                                      size: 14,
                                      color: const Color.fromRGBO(
                                          205, 205, 205, 1)),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                    )
                  ],
                );
              }
            }),
      ),
    );
  }
}

class BottomLeftHomeworkWidget extends ConsumerWidget {
  const BottomLeftHomeworkWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(
        bottom: 40,
        top: 20,
        left: 40,
        right: size.width > 1600 ? 20 : 40,
      ),
      width:
          size.width > 1600 ? ((size.width - 121) / 6) * 2 : size.width - 121,
      height: 600,
      child: Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(35, 35, 35, 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Teslim Eden Öğrenciler",
                    style: Design().poppins(
                      size: 16,
                      fw: FontWeight.w600,
                      color: const Color.fromRGBO(83, 145, 101, 1),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    for (var doc in ref.watch(sendersFilesProvider)) {
                      for (var file in doc) {
                        UniversityService().downloadFile(file);
                      }
                    }
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    foregroundColor: const Color.fromRGBO(205, 205, 205, 1),
                  ),
                  icon: const Icon(
                    Icons.download,
                    color: Colors.white,
                  ),
                  label: Text(
                    "Tümünü İndir",
                    style: Design().poppins(
                      color: Colors.white,
                      fw: FontWeight.w500,
                      size: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 42,
                    child: CostomSearchBarWidget(
                      function: (String string) {},
                      hintText: "Öğrenci Ara",
                    ),
                  ),
                  FutureBuilder<List<String>>(
                      future: UniversityService().getHomeworkSenderStudents(
                          ref.watch(luniIdProvider).asData?.value ?? "",
                          ref.watch(lfacultyIdProvider).asData?.value ?? "",
                          ref.watch(ldepartmentIdProvider).asData?.value ?? "",
                          ref.watch(courseIndexId),
                          ref.watch(selectedHomeworkIdProvider),
                          ref),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container();
                          } else {
                            return Container();
                          }
                        } else {
                          var students = snapshot.data!;
                          return Expanded(
                            flex: 27,
                            child: students.isNotEmpty
                                ? Container(
                                    margin: const EdgeInsets.all(20),
                                    child: BottomListWidget(students: students),
                                  )
                                : Container(
                                    alignment: Alignment.center,
                                    margin: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color:
                                          const Color.fromRGBO(50, 50, 50, 1),
                                    ),
                                    child: Text(
                                      "Öğrenci Bulunamadı",
                                      style: Design().poppins(
                                        size: 15,
                                        color: const Color.fromRGBO(
                                            205, 205, 205, 1),
                                      ),
                                    ),
                                  ),
                          );
                        }
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomRightHomeworkWidget extends ConsumerWidget {
  const BottomRightHomeworkWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(
        bottom: size.width > 1600 ? 40 : 20,
        top: 20,
        left: size.width > 1600 ? 20 : 40,
        right: size.width > 1600 ? 20 : 40,
      ),
      width:
          size.width > 1600 ? ((size.width - 121) / 6) * 2 : size.width - 121,
      height: 600,
      child: Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(35, 35, 35, 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Teslim Etmeyen Öğrenciler",
                    style: Design().poppins(
                      size: 16,
                      fw: FontWeight.w600,
                      color: const Color.fromRGBO(211, 118, 118, 1),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 42,
                    child: CostomSearchBarWidget(
                      function: (String string) {
                        ref
                            .read(searchUnsendedStudentsProvider.notifier)
                            .state = string;
                      },
                      hintText: "Öğrenci Ara",
                    ),
                  ),
                  FutureBuilder<List<String>>(
                      future: UniversityService().getAllCourseStudents(
                          ref.watch(luniIdProvider).asData?.value ?? "",
                          ref.watch(lfacultyIdProvider).asData?.value ?? "",
                          ref.watch(ldepartmentIdProvider).asData?.value ?? "",
                          ref.watch(courseIndexId),
                          ref.watch(searchUnsendedStudentsProvider)),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container();
                          } else {
                            return Container();
                          }
                        } else {
                          ref.read(temp.notifier).state.clear();
                          var allStudents = snapshot.data!;

                          for (String element in ref.watch(senderIdsProvider)) {
                            if (!allStudents.contains(element)) {
                              ref.watch(temp).add(element);
                            }
                          }

                          return Expanded(
                            flex: 27,
                            child: ref.watch(temp).isNotEmpty
                                ? Container(
                                    margin: const EdgeInsets.all(20),
                                    child: BottomListWidget(
                                      students: ref.watch(temp),
                                    ),
                                  )
                                : Container(
                                    alignment: Alignment.center,
                                    margin: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color:
                                          const Color.fromRGBO(50, 50, 50, 1),
                                    ),
                                    child: Text(
                                      "Öğrenci Bulunamadı",
                                      style: Design().poppins(
                                        size: 15,
                                        color: const Color.fromRGBO(
                                            205, 205, 205, 1),
                                      ),
                                    ),
                                  ),
                          );
                        }
                      }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BottomListWidget extends ConsumerWidget {
  final List<String> students;
  const BottomListWidget({super.key, required this.students});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: students.length,
      itemBuilder: (context, index) {
        var student = students[index];
        return FutureBuilder<Student>(
            future: UniversityService().getStudentDetails(
                ref.watch(luniIdProvider).asData?.value ?? "",
                ref.watch(lfacultyIdProvider).asData?.value ?? "",
                ref.watch(ldepartmentIdProvider).asData?.value ?? "",
                student),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                } else {
                  return Container();
                }
              } else {
                var student = snapshot.data!;
                return Card(
                  color: const Color.fromARGB(255, 75, 71, 71),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {},
                    child: ListTile(
                      contentPadding: const EdgeInsets.only(
                        top: 10,
                        bottom: 10,
                        left: 20,
                        right: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      tileColor: const Color.fromRGBO(50, 50, 50, 1),
                      title: Text(
                        "${student.name} ${student.sname}",
                        style: Design().poppins(
                          color: const Color.fromRGBO(205, 205, 205, 1),
                          size: 15,
                        ),
                      ),
                      subtitle: Text(
                        student.mail,
                        style: Design().poppins(
                          color: const Color.fromRGBO(205, 205, 205, 1),
                          size: 13,
                        ),
                      ),
                      leading: Container(
                        padding: const EdgeInsets.only(
                          right: 10,
                        ),
                        child: Text(
                          student.no,
                          style: Design().poppins(
                            color: const Color.fromRGBO(246, 153, 92, 1),
                            size: 13,
                          ),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: () {
                              ref
                                  .read(selectedInstrucPageProvider.notifier)
                                  .state = 3;
                              ref.read(rightPanel2Provider.notifier).state = 1;
                              ref
                                  .read(selectedStudent3Provider.notifier)
                                  .state = 4;

                              //! BURADA SADECE SON PROVİDER DEĞİŞECEK
                              //! ÖĞRENCİ PROVİDER
                            },
                            icon: const Icon(
                              Icons.comment_rounded,
                              color: Color.fromRGBO(205, 205, 205, 1),
                              size: 19,
                            ),
                            style: IconButton.styleFrom(
                              hoverColor: Colors.grey.shade700,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              for (var file
                                  in ref.watch(sendersFilesProvider)[index]) {
                                UniversityService().downloadFile(file);
                              }
                            },
                            icon: const Icon(
                              Icons.download,
                              color: Color.fromRGBO(81, 130, 155, 1),
                            ),
                            style: IconButton.styleFrom(
                              hoverColor: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            });
      },
    );
  }
}

//! SAG ACILIR PANEL

class RightPanelWidget extends ConsumerWidget {
  const RightPanelWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return AnimatedCrossFade(
      alignment: Alignment.centerRight,
      sizeCurve: Curves.easeInOutQuart,
      firstCurve: Curves.easeInOutQuart,
      secondCurve: Curves.easeInOutQuart,
      duration: const Duration(milliseconds: 700),
      crossFadeState: ref.watch(rightPanelInsProvider) == 1
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      firstChild: Container(
        height: size.height,
        width: 56,
        color: const Color.fromRGBO(35, 35, 35, 1),
        child: const RightPanelButtonWidget(),
      ),
      secondChild: Container(
        height: size.height,
        width: 500,
        color: const Color.fromRGBO(35, 35, 35, 1),
        child: Column(
          children: [
            const SizedBox(height: 15),
            ref.watch(rightPanelInsProvider) == 1
                ? const CourseListWidget()
                : Container(),
            const SizedBox(height: 10),
            ref.watch(rightPanelInsProvider) == 1
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const RightPanelButtonWidget(),
                      Row(
                        children: [
                          RightMenuStyleButtonsWidget(
                            icon: Icons.grid_view_rounded,
                            funtcion: () {
                              ref.read(rigthMenuStyleProvider.notifier).state =
                                  0;
                            },
                          ),
                          RightMenuStyleButtonsWidget(
                            icon: Icons.view_list_rounded,
                            funtcion: () {
                              ref.read(rigthMenuStyleProvider.notifier).state =
                                  1;
                            },
                          ),
                        ],
                      ),
                    ],
                  )
                : const Flexible(child: RightPanelButtonWidget())
          ],
        ),
      ),
    );
  }
}

class CourseListWidget extends ConsumerWidget {
  const CourseListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
        child: FutureBuilder<List>(
            future: UniversityService().getCourseIds(
                ref.watch(luniIdProvider).asData!.value,
                ref.watch(linstructorIdProvider).asData!.value),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                } else {
                  return Container();
                }
              } else {
                List courses = snapshot.data!;
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  child: ref.watch(silinecek5Provider) == 1
                      ? const SizedBox()
                      : ref.watch(rigthMenuStyleProvider) == 0
                          ? Container(
                              key: UniqueKey(),
                              child: GridView.builder(
                                itemCount: courses.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                ),
                                itemBuilder: (context, index) {
                                  return GridViewContainerWidget(
                                    index: index,
                                    courses: courses,
                                  );
                                },
                              ),
                            )
                          : Container(
                              key: UniqueKey(),
                              child: GridView.builder(
                                itemCount: courses.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 1,
                                  childAspectRatio: 2.5,
                                ),
                                itemBuilder: (context, index) {
                                  return GridViewContainerWidget(
                                      index: index, courses: courses);
                                },
                              ),
                            ),
                );
              }
            }));
  }
}

class GridViewContainerWidget extends ConsumerWidget {
  final int index;
  final List courses;

  const GridViewContainerWidget(
      {super.key, required this.index, required this.courses});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Transform.scale(
      scale: 0.93,
      child: Card(
        color: ref.watch(selectedCourseProvider) == index
            ? const Color.fromRGBO(211, 118, 118, 1)
            : const Color.fromRGBO(50, 50, 50, 1),
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            ref.read(leftPageChangeInsProvider.notifier).state = 0;
            ref.read(courseIndexId.notifier).state = courses[index];
            ref.read(selectedCourse2Provider.notifier).state = index;
            ref.read(selectedCourseProvider.notifier).state = index;
            ref.read(selectedCourse3Provider.notifier).state = index;
          },
          child: FutureBuilder<Course>(
              future: UniversityService().getCourseDetails(
                  ref.watch(luniIdProvider).asData!.value,
                  ref.watch(lfacultyIdProvider).asData!.value,
                  ref.watch(ldepartmentIdProvider).asData!.value,
                  courses[index]),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container();
                  } else {
                    return Container();
                  }
                } else {
                  final course = snapshot.data!;
                  return ListTile(
                    contentPadding: const EdgeInsets.all(20),
                    title: Text(
                      course.name,
                      style: Design().poppins(
                        size: 18,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    subtitleTextStyle:
                        Design().poppins(color: Colors.white, size: 15),
                    subtitle: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          "0 Ödev",
                          style: Design().poppins(
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "0 Öğrenci",
                          style: Design().poppins(
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "0 Duyuru",
                          style: Design().poppins(
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }),
        ),
      ),
    );
  }
}

class RightPanelButtonWidget extends ConsumerWidget {
  const RightPanelButtonWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.only(left: 10, bottom: 15),
      alignment: Alignment.bottomLeft,
      child: IconButton(
        onPressed: () {
          ref.watch(rightPanelInsProvider.notifier).state =
              ref.watch(rightPanelInsProvider) == 0 ? 1 : 0;
        },
        style: IconButton.styleFrom(
          backgroundColor: const Color.fromRGBO(55, 55, 55, 1),
          hoverColor: const Color.fromRGBO(75, 75, 75, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(55),
          ),
        ),
        icon: Icon(
          ref.watch(rightPanelInsProvider) == 1
              ? Icons.arrow_right
              : Icons.arrow_left,
          color: const Color.fromRGBO(244, 246, 249, 1),
        ),
      ),
    );
  }
}

//! SINAV KONTROL EKRANI

final lectureExCheProvider = StateProvider((ref) => 0);
final lectureExProvider = StateProvider((ref) => 0);

final selectedStudent5Provider = StateProvider((ref) => 0);

final isStudentCheProvider = StateProvider((ref) => 0);

final selectedQuestionCheProvider = StateProvider((ref) => -1);

final isClassicQuestProvider = StateProvider((ref) => true);

//! PUANLAMA PROVIDERI

final selectedQuestTotalPointProvider = StateProvider((ref) => 20);
final totalPointProvider = StateProvider((ref) => 0);

final studentsExamPoints = StateProvider((ref) => <Map<String, dynamic>>[]);

//! Hocanın o soruya verdiği puan
final selectedQuestPointProvider = StateProvider((ref) => "");

final questionPointControllerProvider = StateProvider(
  (ref) => TextEditingController(),
);

class CheckExamWidget extends ConsumerWidget {
  const CheckExamWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ScrollController scrollController = ScrollController();
    final ScrollController scrollController2 = ScrollController();
    final size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width - 121,
      child: Scrollbar(
        controller: scrollController2,
        thumbVisibility: true,
        trackVisibility: true,
        child: SingleChildScrollView(
          controller: scrollController2,
          scrollDirection: Axis.horizontal,
          child: Scrollbar(
            controller: scrollController,
            thumbVisibility: true,
            trackVisibility: true,
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 50,
                    width: 1800,
                    padding: const EdgeInsets.only(left: 50, right: 20),
                    alignment: Alignment.center,
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Sınav Sonuçları",
                          style: Design().poppins(
                            color: Colors.grey.shade800,
                            fw: FontWeight.bold,
                            size: 14,
                          ),
                        ),
                        Transform.scale(
                          scale: 0.8,
                          child: IconButton(
                            onPressed: () {
                              ref
                                  .read(leftPageChangeInsProvider.notifier)
                                  .state = 0;
                            },
                            icon: Icon(
                              Icons.arrow_right_rounded,
                              size: 35,
                              color: Colors.grey.shade800,
                            ),
                            style: IconButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              minimumSize: const Size(50, 50),
                              backgroundColor:
                                  const Color.fromARGB(255, 226, 229, 233),
                              hoverColor:
                                  const Color.fromARGB(255, 196, 198, 202),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LeftCheckExamPageWidget(size: size),
                      RightCheckExamPageWidget(size: size),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RightCheckExamPageWidget extends ConsumerWidget {
  const RightCheckExamPageWidget({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.only(bottom: 40, top: 40, left: 20, right: 40),
      width: 1200,
      height: 960,
      child: Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: ref.watch(examSelectedStuProvider) == ""
            ? Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 226, 229, 233),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Öğrenci Seçilmedi",
                      style: Design().poppins(
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ),
              )
            : Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: ListView.builder(
                        itemCount: ref.watch(updatedQuestionsList).length,
                        itemBuilder: (context, index) {
                          return Card(
                            shadowColor: Colors.transparent,
                            color:
                                ref.watch(selectedQuestionCheProvider) == index
                                    ? const Color.fromRGBO(220, 220, 220, 1)
                                    : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                ref
                                    .read(selectedQuestionCheProvider.notifier)
                                    .state = index;

                                ref.read(questionsProvider.notifier).state =
                                    ref.watch(updatedQuestionsList)[index];
                              },
                              child: ListTile(
                                contentPadding: const EdgeInsets.only(
                                  top: 10,
                                  bottom: 10,
                                  left: 20,
                                  right: 20,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                tileColor:
                                    ref.watch(selectedQuestionCheProvider) ==
                                            index
                                        ? const Color.fromRGBO(220, 220, 220, 1)
                                        : Colors.white,
                                title: Text(
                                  ref.watch(updatedQuestionsList)[index]
                                              ['type'] ==
                                          "ClassicQuestion"
                                      ? "Klasik Soru"
                                      : "Yazı Sorusu",
                                  style: Design().poppins(
                                    color: Colors.grey.shade800,
                                    size: 15,
                                  ),
                                ),
                                subtitle: Text(
                                  "Cevaplandı / Cevaplanmadı",
                                  style: Design().poppins(
                                    color: Colors.grey.shade800,
                                    size: 13,
                                  ),
                                ),
                                leading: Container(
                                  padding: const EdgeInsets.only(
                                    right: 10,
                                  ),
                                  child: Text(
                                    (index + 1).toString(),
                                    style: Design().poppins(
                                      color:
                                          const Color.fromRGBO(246, 153, 92, 1),
                                      size: 18,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                trailing: Text(
                                  ref.watch(updatedQuestionsList)[index]
                                      ['point'],
                                  style: Design().poppins(
                                    color: Colors.grey.shade800,
                                    size: 14,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  ref.watch(questionsProvider).isNotEmpty
                      ? Flexible(
                          flex: 7,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(220, 220, 220, 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListView(
                              children: [
                                Container(
                                  margin: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Soru",
                                        style: Design().poppins(
                                          color: Colors.grey.shade500,
                                          size: 18,
                                          fw: FontWeight.bold,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          ref.watch(questionsProvider)['text'],
                                          style: Design().poppins(
                                            color: Colors.grey.shade800,
                                            size: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Cevap",
                                        style: Design().poppins(
                                          color: Colors.grey.shade500,
                                          size: 18,
                                          fw: FontWeight.bold,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          ref.watch(
                                              questionsProvider)['answer'],
                                          style: Design().poppins(
                                            color: Colors.grey.shade800,
                                            size: 15,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ref.watch(questionsProvider)['type'] ==
                                        "ClassicQuestion"
                                    ? Container(
                                        margin: const EdgeInsets.all(20),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Cevap Resmi",
                                              style: Design().poppins(
                                                color: Colors.grey.shade500,
                                                size: 18,
                                                fw: FontWeight.bold,
                                              ),
                                            ),
                                            Container(
                                                padding:
                                                    const EdgeInsets.all(20),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: ref.watch(
                                                                questionsProvider)[
                                                            'answerUrl'] !=
                                                        ""
                                                    ? Image.network(
                                                        "https://t3.ftcdn.net/jpg/06/24/52/34/360_F_624523450_NbFfAibNsbxFDjGKueOukV4ijNGFIuQ1.jpg")
                                                    : const Center(
                                                        child: Text(
                                                            "Fotoğraf gönderilmemiş"),
                                                      )),
                                          ],
                                        ),
                                      )
                                    : Container(),
                                Container(
                                  margin: const EdgeInsets.all(20),
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "Puan:   ",
                                            style: Design().poppins(
                                              size: 16,
                                              fw: FontWeight.w600,
                                              color: Colors.grey.shade800,
                                            ),
                                          ),
                                          Container(
                                            width: 100,
                                            height: 55,
                                            alignment: Alignment.center,
                                            child: TextFormField(
                                              controller: ref.watch(
                                                  questionPointControllerProvider),
                                              inputFormatters: [
                                                FilteringTextInputFormatter
                                                    .digitsOnly,
                                                LengthLimitingTextInputFormatter(
                                                    3),
                                                LimitRangeTextInputFormatter(
                                                  0,
                                                  ref.watch(
                                                      selectedQuestTotalPointProvider),
                                                ),
                                              ],
                                              textAlign: TextAlign.center,
                                              onChanged: (value) {
                                                ref
                                                    .read(
                                                        selectedQuestPointProvider
                                                            .notifier)
                                                    .state = value;
                                              },
                                              style: Design().poppins(
                                                size: 14,
                                                color: Colors.grey.shade700,
                                              ),
                                              cursorColor: Colors.grey.shade600,
                                              cursorWidth: 2,
                                              minLines: 1,
                                              maxLines: 1,
                                              cursorRadius:
                                                  const Radius.circular(25),
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    const EdgeInsets.only(
                                                  left: 30,
                                                  right: 30,
                                                  top: 40,
                                                ),
                                                hintText: ref.watch(
                                                    selectedQuestPointProvider),
                                                hintStyle: Design().poppins(
                                                  size: 14,
                                                  color: Colors.grey.shade600,
                                                ),
                                                fillColor: const Color.fromARGB(
                                                    255, 226, 229, 233),
                                                filled: true,
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: const BorderSide(
                                                    color: Color.fromRGBO(
                                                        83, 145, 101, 0.01),
                                                  ),
                                                ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  borderSide: const BorderSide(
                                                    color: Color.fromRGBO(
                                                        83, 145, 101, 0.01),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          Map<String, dynamic> myMap = {};
                                          ref
                                                  .read(totalPointProvider.notifier)
                                                  .state +=
                                              int.parse(ref.watch(
                                                  selectedQuestPointProvider));
                                          if (ref
                                                  .watch(updatedQuestionsList)
                                                  .last['key'] ==
                                              ref.watch(
                                                  questionsProvider)['key']) {
                                            myMap['name'] = ref.watch(
                                                examSelectedStuNameProvider);
                                            myMap['sname'] = ref.watch(
                                                examSelectedStuSnameProvider);
                                            myMap['no'] = ref.watch(
                                                examSelectedStuNoProvider);
                                            myMap['mail'] = ref.watch(
                                                examSelectedStuMailProvider);
                                            myMap['point'] =
                                                ref.watch(totalPointProvider);

                                            ref
                                                .read(allPointsExcel.notifier)
                                                .state
                                                .add(myMap);
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.all(20),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          backgroundColor: const Color.fromRGBO(
                                              246, 153, 92, 1),
                                          foregroundColor: const Color.fromARGB(
                                              255, 226, 229, 233),
                                        ),
                                        child: Text(
                                          "Duyuru Paylaş",
                                          style: Design().poppins(
                                            color: Colors.white,
                                            size: 15,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 226, 229, 233),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Soru Seçilmedi",
                                style: Design().poppins(
                                  size: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ),
                        )
                ],
              ),
      ),
    );
  }
}

final examSelectedStuNameProvider = StateProvider((ref) => "");
final examSelectedStuSnameProvider = StateProvider((ref) => "");
final examSelectedStuNoProvider = StateProvider((ref) => "");
final examSelectedStuMailProvider = StateProvider((ref) => "");
final examSelectedStuProvider = StateProvider((ref) => "");
final courseSelectedProvider = StateProvider((ref) => "");

class LeftCheckExamPageWidget extends ConsumerWidget {
  const LeftCheckExamPageWidget({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(
            bottom: 20,
            top: 40,
            left: 40,
            right: 20,
          ),
          width: 600,
          height: 260,
          child: Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(35, 35, 35, 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Sınav Seçimi",
                    style: Design().poppins(
                      size: 16,
                      fw: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(221, 54, 54, 54),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton(
                    padding: const EdgeInsets.only(left: 13, right: 13),
                    isExpanded: true,
                    menuMaxHeight: 200,
                    style: Design().poppins(
                      size: 13,
                      color: Colors.white,
                    ),
                    iconEnabledColor: Colors.white,
                    dropdownColor: const Color.fromARGB(221, 54, 54, 54),
                    underline: const Divider(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(8),
                    value: ref.watch(lectureExCheProvider),
                    onChanged: (value) {
                      ref.read(lectureExCheProvider.notifier).state =
                          value ?? 0;

                      if (value == 0) {
                        ref.read(lectureExProvider.notifier).state = 0;
                      } else {
                        ref.read(courseSelectedProvider.notifier).state =
                            ref.watch(courseIdsProvider)[value! - 1];
                      }
                    },
                    items: [
                      const DropdownMenuItem(
                        value: 0,
                        child: Text('Lütfen ders seçiniz'),
                      ),
                      if (ref.watch(coursesNames).isNotEmpty)
                        ...List.generate(
                          ref.watch(coursesNames).length,
                          (index) {
                            return DropdownMenuItem(
                                value: index + 1,
                                child: Text(ref.watch(coursesNames)[index]));
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(221, 54, 54, 54),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton(
                    padding: const EdgeInsets.only(left: 13, right: 13),
                    isExpanded: true,
                    menuMaxHeight: 200,
                    style: Design().poppins(
                      size: 13,
                      color: Colors.white,
                    ),
                    iconEnabledColor: Colors.white,
                    dropdownColor: const Color.fromARGB(221, 54, 54, 54),
                    underline: const Divider(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(8),
                    value: ref.watch(lectureExProvider),
                    onChanged: (value) {
                      ref.read(lectureExProvider.notifier).state = value ?? 0;
                    },
                    items: const [
                      DropdownMenuItem(
                        value: 0,
                        child: Text('Lütfen sınav seçiniz'),
                      ),
                      DropdownMenuItem(
                        value: 1,
                        child: Text('Vize'),
                      ),
                      DropdownMenuItem(
                        value: 2,
                        child: Text('Final'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(
            bottom: 40,
            top: 20,
            left: 40,
            right: 20,
          ),
          width: 600,
          height: 700,
          child: Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(35, 35, 35, 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Öğrenciler",
                        style: Design().poppins(
                          size: 16,
                          fw: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        final excel = Excel.createExcel();
                        final sheetObject = excel['Sheet1'];

                        sheetObject.appendRow([
                          TextCellValue('No'),
                          TextCellValue('Mail'),
                          TextCellValue('Adı'),
                          TextCellValue('Soyadı'),
                          TextCellValue('Aldığı not')
                        ]);

                        for (var i in ref.watch(allPointsExcel)) {
                          sheetObject.appendRow([
                            TextCellValue(i['no']),
                            TextCellValue(i['mail']),
                            TextCellValue(i['name']),
                            TextCellValue(i['sname']),
                            TextCellValue((i['point']).toString())
                          ]);
                        }
                        excel.save(fileName: 'Puanlar.xlsx');
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.all(20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        foregroundColor: const Color.fromRGBO(205, 205, 205, 1),
                      ),
                      icon: const Icon(
                        Icons.download,
                        color: Colors.white,
                      ),
                      label: Text(
                        "Tümünü İndir",
                        style: Design().poppins(
                          color: Colors.white,
                          fw: FontWeight.w500,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                ref.watch(lectureExProvider) != 0 &&
                        ref.watch(lectureExCheProvider) != 0
                    ? Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 42,
                              child: CostomSearchBarWidget(
                                function: (String search) {
                                  ref
                                      .read(searchStudentProvider.notifier)
                                      .state = search;
                                },
                                hintText: "Öğrenci Ara",
                              ),
                            ),
                            FutureBuilder<List<String>>(
                              future: UniversityService().getAllCourseStudents(
                                  ref.watch(luniIdProvider).asData?.value ??
                                      " ",
                                  ref.watch(lfacultyIdProvider).asData?.value ??
                                      " ",
                                  ref
                                          .watch(ldepartmentIdProvider)
                                          .asData
                                          ?.value ??
                                      " ",
                                  ref.watch(courseSelectedProvider),
                                  ref.watch(searchStudentProvider)),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                        ConnectionState.waiting ||
                                    snapshot.data!.isEmpty) {
                                  return Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.all(20),
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color:
                                            const Color.fromRGBO(50, 50, 50, 1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const SpinKitPulse(
                                        color: Colors.white,
                                        size: 50,
                                      ),
                                    ),
                                  );
                                } else {
                                  var students = snapshot.data!;
                                  return Expanded(
                                    flex: 27,
                                    child: students.isNotEmpty
                                        ? Container(
                                            margin: const EdgeInsets.all(20),
                                            child: RightPanelListWidget(
                                              studentsList: students,
                                              provider:
                                                  selectedStudent5Provider,
                                            ),
                                          )
                                        : Container(
                                            alignment: Alignment.center,
                                            margin: const EdgeInsets.all(20),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: const Color.fromRGBO(
                                                  50, 50, 50, 1),
                                            ),
                                            child: Text(
                                              "Öğrenci Bulunamadı",
                                              style: Design().poppins(
                                                size: 15,
                                                color: const Color.fromRGBO(
                                                    205, 205, 205, 1),
                                              ),
                                            ),
                                          ),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      )
                    : Expanded(
                        flex: 27,
                        child: Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: const Color.fromRGBO(50, 50, 50, 1),
                          ),
                          child: Text(
                            "Sınav Seçilmedi",
                            style: Design().poppins(
                              size: 15,
                              color: const Color.fromRGBO(205, 205, 205, 1),
                            ),
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
