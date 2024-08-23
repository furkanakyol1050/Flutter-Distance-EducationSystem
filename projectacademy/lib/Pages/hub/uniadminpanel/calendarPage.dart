// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:projectacademy/Pages/hub/studentpanel/joincoursepage.dart';
import 'package:projectacademy/Pages/hub/uniadminpanel/homepage.dart';
import 'package:projectacademy/Pages/hub/instructorpanel/homeworkPage.dart';
import 'package:projectacademy/firebaseConfig/firebase_transactionss.dart';
import 'package:projectacademy/myDesign.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

final courseDayProvider = StateProvider((ref) => <String>[]);
final courseStartTimeProvider = StateProvider((ref) => <String>[]);
final courseEndTimeProvider = StateProvider((ref) => <String>[]);

final selectedCourseCalProvider = StateProvider((ref) => 0);

final selectedFacultyCalProvider = StateProvider((ref) => 0);
final selectedFacultyCalIdProvider =
    StateProvider((ref) => ref.watch(facultyIdProvider));

final selectedDepartCalProvider = StateProvider((ref) => 0);
final selectedDepartCalIdProvider = StateProvider((ref) => " ");

final courseListProvider = FutureProvider((ref) => UniversityService()
    .getCoursesAsFuture(
        ref.watch(userPhotoUrlProvider).asData?.value ?? " ",
        ref.watch(selectedFacultyCalIdProvider),
        ref.watch(selectedDepartCalIdProvider)));

final pickedTimeCalendar1Provider = StateProvider<TimeOfDay>(
  (ref) => const TimeOfDay(hour: 09, minute: 00),
);
final pickedTimeCalendar2Provider = StateProvider<TimeOfDay>(
  (ref) => const TimeOfDay(hour: 09, minute: 00),
);
final dayProvider = StateProvider((ref) => 0);

final courseSchedules = StateProvider((ref) => <Appointment>[]);

// final calendarInfos = StreamProvider((ref) => UniversityService()
//     .getCalendarInfos(
//         ref.watch(userPhotoUrlProvider).asData?.value ?? " ",
//         ref.watch(selectedFacultyCalIdProvider),
//         ref.watch(selectedDepartCalIdProvider)));

class CalendarPage extends StatelessWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.only(left: 65),
      child: ListView(
        children: [
          Container(
            height: 50,
            padding: const EdgeInsets.only(left: 50, right: 20),
            alignment: Alignment.center,
            color: Colors.white,
            child: Row(
              children: [
                Text(
                  "Takvim",
                  style: Design().poppins(
                    color: Colors.grey.shade800,
                    fw: FontWeight.bold,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
          size.width > 1200
              ? Row(
                  children: [
                    LeftWidget(size: size),
                    CalendarWidget(size: size),
                  ],
                )
              : Column(
                  children: [
                    LeftWidget(size: size),
                    CalendarWidget(size: size),
                  ],
                ),
        ],
      ),
    );
  }
}

class LeftWidget extends ConsumerWidget {
  const LeftWidget({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseList = ref.watch(courseListProvider).asData?.value ?? [];
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(
            top: 40,
            bottom: 20,
            left: size.width > 1300 ? 40 : 30,
            right: size.width > 1300 ? 20 : 30,
          ),
          width: size.width > 1200 ? (size.width - 65) / 2 : size.width,
          height: 953 / 5,
          child: Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: size.width > 1200
                ? Row(
                    children: [
                      Flexible(
                        child: Container(
                          height: 55,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 226, 229, 233),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Consumer(
                            builder: (context, ref, child) {
                              final uniId = ref
                                      .watch(userPhotoUrlProvider)
                                      .asData
                                      ?.value ??
                                  " ";
                              return StreamBuilder<List<Faculty>>(
                                stream: UniversityService()
                                    .getFacultiesAsStream(uniId),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Container();
                                  } else if (!snapshot.hasData ||
                                      snapshot.data!.isEmpty) {
                                    return const Text('');
                                  } else {
                                    var list = snapshot.data!;
                                    return DropdownButtonFacultyWidget(list);
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Flexible(
                        child: Container(
                          height: 55,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 226, 229, 233),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Consumer(
                            builder: (context, ref, child) {
                              final universityId = ref
                                      .watch(userPhotoUrlProvider)
                                      .asData
                                      ?.value ??
                                  " ";
                              final facultyId =
                                  ref.watch(selectedFacultyCalIdProvider);

                              return StreamBuilder<List<Department>>(
                                stream: UniversityService()
                                    .getFacultyDepartmentsAsStream(
                                        universityId, facultyId),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Container();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else if (!snapshot.hasData ||
                                      snapshot.data!.isEmpty) {
                                    return const Text('');
                                  } else {
                                    var list = snapshot.data!;
                                    return DropdownButtonDepartmentWidget(list);
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Flexible(
                        child: Container(
                          height: 55,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 226, 229, 233),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Consumer(
                            builder: (context, ref, child) {
                              final uniId = ref
                                      .watch(userPhotoUrlProvider)
                                      .asData
                                      ?.value ??
                                  " ";
                              return StreamBuilder<List<Faculty>>(
                                stream: UniversityService()
                                    .getFacultiesAsStream(uniId),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Container();
                                    } else {
                                      return Container();
                                    }
                                  } else {
                                    var list = snapshot.data!;
                                    return DropdownButtonFacultyWidget(list);
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Flexible(
                        child: Container(
                          height: 55,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 226, 229, 233),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Consumer(
                            builder: (context, ref, child) {
                              final universityId = ref
                                      .watch(userPhotoUrlProvider)
                                      .asData
                                      ?.value ??
                                  " ";
                              final facultyId =
                                  ref.watch(selectedFacultyCalIdProvider);

                              return StreamBuilder<List<Department>>(
                                stream: UniversityService()
                                    .getFacultyDepartmentsAsStream(
                                        universityId, facultyId),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Container();
                                  } else if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  } else if (!snapshot.hasData ||
                                      snapshot.data!.isEmpty) {
                                    return const Text('');
                                  } else {
                                    var list = snapshot.data!;
                                    return DropdownButtonDepartmentWidget(list);
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(
            top: 20,
            bottom: 20,
            left: size.width > 1300 ? 40 : 30,
            right: size.width > 1300 ? 20 : 30,
          ),
          width: size.width > 1200 ? (size.width - 65) / 2 : size.width,
          height: (953 / 5) * 2.85,
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
                    "Ders Bilgileri",
                    style: Design().poppins(
                      size: 16,
                      fw: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ),
                Container(
                  height: 55,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 226, 229, 233),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Consumer(builder: (context, ref, child) {
                    final courseList =
                        ref.watch(courseListProvider).asData?.value ?? [];
                    return DropdownButton(
                      padding: const EdgeInsets.only(left: 13, right: 13),
                      isExpanded: true,
                      menuMaxHeight: 200,
                      style: Design().poppins(
                        size: 13,
                        color: Colors.grey.shade600,
                      ),
                      iconEnabledColor: Colors.grey.shade600,
                      dropdownColor: const Color.fromARGB(255, 226, 229, 233),
                      underline: const Divider(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(8),
                      value: ref.watch(selectedCourseCalProvider),
                      onChanged: (value) {
                        ref.read(selectedCourseCalProvider.notifier).state =
                            value ?? 0;
                      },
                      items: [
                        const DropdownMenuItem(
                          value: 0,
                          child: Text('Lütfen ders seçiniz'),
                        ),
                        ...List.generate(courseList.length, (index) {
                          return DropdownMenuItem(
                            value: (index + 1),
                            child: Text(courseList[index].name),
                          );
                        })
                      ],
                    );
                  }),
                ),
                ref.watch(selectedCourseCalProvider) == 0
                    ? Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 226, 229, 233),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Ders Seçilmedi",
                              style: Design().poppins(
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                      )
                    : StreamBuilder<Course?>(
                        stream: UniversityService().getCourseInfoStream(
                            ref.watch(userPhotoUrlProvider).asData?.value ?? "",
                            ref.watch(selectedFacultyCalIdProvider),
                            ref.watch(selectedDepartCalIdProvider),
                            courseList[ref.watch(selectedCourseCalProvider) - 1]
                                .id),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: SpinKitPulse(
                                  color: Color.fromARGB(255, 226, 229, 233),
                                  size: 50,
                                ),
                              );
                            } else {
                              return const Center(
                                child: SpinKitPulse(
                                  color: Color.fromARGB(255, 226, 229, 233),
                                  size: 50,
                                ),
                              );
                            }
                          } else {
                            var courseData = snapshot.data!;
                            return Expanded(
                              child: Column(
                                children: [
                                  const SizedBox(height: 20),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: InfoWidget(
                                          size: size,
                                          label: "Akademisyen ID ",
                                          text: courseData.instructorId,
                                          containerColor: const Color.fromARGB(
                                              255, 226, 229, 233),
                                          textColor: Colors.grey.shade600,
                                          labelColor: Colors.grey.shade800,
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Flexible(
                                        child: InfoWidget(
                                          size: size,
                                          label: "Akademisyen Adı ",
                                          text: courseData.instructorId,
                                          // ! akademisyen adı
                                          containerColor: const Color.fromARGB(
                                              255, 226, 229, 233),
                                          textColor: Colors.grey.shade600,
                                          labelColor: Colors.grey.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: InfoWidget(
                                          size: size,
                                          label: "Ders ID ",
                                          text: courseData.id,
                                          containerColor: const Color.fromARGB(
                                              255, 226, 229, 233),
                                          textColor: Colors.grey.shade600,
                                          labelColor: Colors.grey.shade800,
                                        ),
                                      ),
                                      const SizedBox(width: 20),
                                      Flexible(
                                        child: InfoWidget(
                                          size: size,
                                          label: "Toplam Öğrenci Sayısı ",
                                          text: courseData.studentIds.length
                                              .toString(),
                                          containerColor: const Color.fromARGB(
                                              255, 226, 229, 233),
                                          textColor: Colors.grey.shade600,
                                          labelColor: Colors.grey.shade800,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Ders Saatleri :",
                                      style: Design().poppins(
                                        size: 13,
                                        fw: FontWeight.bold,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: courseData.startTime.length,
                                      itemBuilder: (context, index) {
                                        var temp = "";

                                        if (courseData.day[index] == "0") {
                                          temp = "Pazartesi";
                                        }
                                        if (courseData.day[index] == "1") {
                                          temp = "Salı";
                                        }
                                        if (courseData.day[index] == "2") {
                                          temp = "Çarşamba";
                                        }
                                        if (courseData.day[index] == "3") {
                                          temp = "Perşembe";
                                        }
                                        if (courseData.day[index] == "4") {
                                          temp = "Cuma";
                                        }
                                        if (courseData.day[index] == "5") {
                                          temp = "Cumartesi";
                                        }
                                        if (courseData.day[index] == "6") {
                                          temp = "Pazar";
                                        }

                                        if (courseData.day[index] == 0) {}
                                        return Card(
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          margin: const EdgeInsets.only(top: 4),
                                          child: ListTile(
                                            tileColor: const Color.fromARGB(
                                                255, 226, 229, 233),
                                            contentPadding:
                                                const EdgeInsets.only(
                                              top: 5,
                                              bottom: 5,
                                              left: 20,
                                              right: 20,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            title: Text(
                                              "$temp | Başlangıç Saati : ${courseData.startTime[index]} | Bitiş Saati : ${courseData.endTime[index]}",
                                              style: Design().poppins(
                                                size: 13,
                                                color: Colors.grey.shade600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
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
                                                      "Ders saati iptal edilecektir.",
                                                  icon: Icons.delete_forever,
                                                  buttonFunc: () {
                                                    UniversityService().updateCourseSchedule(
                                                        0,
                                                        index,
                                                        ref
                                                                .watch(
                                                                    userPhotoUrlProvider)
                                                                .asData
                                                                ?.value ??
                                                            "",
                                                        ref.watch(
                                                            selectedFacultyCalIdProvider),
                                                        ref.watch(
                                                            selectedDepartCalIdProvider),
                                                        courseList[ref.watch(
                                                                    selectedCourseCalProvider) -
                                                                1]
                                                            .id,
                                                        '${ref.watch(pickedTimeCalendar1Provider).hour}:${ref.watch(pickedTimeCalendar1Provider).minute.toString().padLeft(2, '0')}',
                                                        '${ref.watch(pickedTimeCalendar2Provider).hour}:${ref.watch(pickedTimeCalendar2Provider).minute.toString().padLeft(2, '0')}',
                                                        ref.watch(dayProvider));
                                                    Navigator.pop(context);
                                                    showSnackBarWidget(context,
                                                        "Ders Saati Başarıyla silindi..");
                                                  },
                                                );
                                              },
                                              icon: Icon(
                                                Icons.delete,
                                                color: Colors.grey.shade800,
                                              ),
                                              style: IconButton.styleFrom(
                                                hoverColor:
                                                    const Color.fromARGB(
                                                        255, 196, 198, 202),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                ],
                              ),
                            );
                          }
                        }),
              ],
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.only(
            top: 20,
            bottom: 40,
            left: size.width > 1300 ? 40 : 30,
            right: size.width > 1300 ? 20 : 30,
          ),
          width: size.width > 1200 ? (size.width - 65) / 2 : size.width,
          height: size.width > 1500
              ? (953 / 5) * 1.15
              : size.width > 800
                  ? (953 / 5) * 1.15 + 90
                  : (953 / 5) * 1.15 + 325,
          child: size.width > 800
              ? Row(
                  children: [
                    AddCourseTimeWidget(size: size),
                    const AddCourseTimeButtonWidget(),
                  ],
                )
              : Column(
                  children: [
                    AddCourseTimeWidget(size: size),
                    const AddCourseTimeButtonWidget(),
                  ],
                ),
        )
      ],
    );
  }
}

class AddCourseTimeButtonWidget extends ConsumerWidget {
  const AddCourseTimeButtonWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseList = ref.watch(courseListProvider).asData?.value ?? [];
    return Flexible(
      child: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: 200,
          height: 50,
          child: ElevatedButton(
            onPressed: () async {
              UniversityService().updateCourseSchedule(
                  1,
                  0, // rastgele sayı
                  ref.watch(userPhotoUrlProvider).asData?.value ?? "",
                  ref.watch(selectedFacultyCalIdProvider),
                  ref.watch(selectedDepartCalIdProvider),
                  courseList[ref.watch(selectedCourseCalProvider) - 1].id,
                  '${ref.watch(pickedTimeCalendar1Provider).hour}:${ref.watch(pickedTimeCalendar1Provider).minute.toString().padLeft(2, '0')}',
                  '${ref.watch(pickedTimeCalendar2Provider).hour}:${ref.watch(pickedTimeCalendar2Provider).minute.toString().padLeft(2, '0')}',
                  ref.watch(dayProvider));
              showSnackBarWidget(context, "Ders Saati Başarıyla eklendi..");

              final now = DateTime.now();
              final startTime = DateTime(
                  now.year,
                  now.month,
                  ref.watch(dayProvider) - 1,
                  ref.watch(pickedTimeCalendar1Provider).hour,
                  ref.watch(pickedTimeCalendar1Provider).minute);
              final endTime = DateTime(
                  now.year,
                  now.month,
                  ref.watch(dayProvider) - 1,
                  ref.watch(pickedTimeCalendar2Provider).hour,
                  ref.watch(pickedTimeCalendar2Provider).minute);

              var temp = ref.watch(courseSchedules);
              temp.add(Appointment(
                startTime: startTime,
                endTime: endTime,
                subject: "asdasd",
                color: Colors.black,
                notes: "asda",
              ));

              ref.read(courseSchedules.notifier).state = temp;
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(
                  color: Colors.white,
                  width: 4,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
              ),
              backgroundColor: const Color.fromRGBO(246, 153, 92, 1),
              foregroundColor: const Color.fromARGB(255, 226, 229, 233),
            ),
            child: Text(
              "Ders Saati Ekle",
              style: Design().poppins(
                color: Colors.white,
                size: 15,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }
}

class AddCourseTimeWidget extends StatelessWidget {
  const AddCourseTimeWidget({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: size.width > 1500 ? 2 : 1,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(20),
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
                "Ders Ekle",
                style: Design().poppins(
                  size: 16,
                  fw: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            size.width > 1500
                ? const Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StartTimeWidget(),
                      SizedBox(width: 30),
                      EndTimeWidget(),
                      SizedBox(width: 30),
                      DayWidget(),
                    ],
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          StartTimeWidget(),
                          SizedBox(width: 30),
                          EndTimeWidget(),
                        ],
                      ),
                      SizedBox(height: 10),
                      Center(child: DayWidget()),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}

class DayWidget extends ConsumerWidget {
  const DayWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Ders Günü :",
            style: Design().poppins(
              size: 13,
              fw: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 45,
          width: 150,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 226, 229, 233),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton(
            padding: const EdgeInsets.only(
              left: 13,
              right: 13,
            ),
            isExpanded: true,
            menuMaxHeight: 200,
            style: Design().poppins(
              size: 13,
              color: Colors.grey.shade800,
            ),
            iconEnabledColor: Colors.grey.shade800,
            dropdownColor: const Color.fromARGB(255, 226, 229, 233),
            underline: const Divider(color: Colors.transparent),
            borderRadius: BorderRadius.circular(8),
            value: ref.watch(dayProvider),
            onChanged: (value) {
              ref.read(dayProvider.notifier).state = value ?? 0;
            },
            items: const [
              DropdownMenuItem(
                value: 0,
                child: Text('Pazartesi'),
              ),
              DropdownMenuItem(
                value: 1,
                child: Text('Salı'),
              ),
              DropdownMenuItem(
                value: 2,
                child: Text('Çarşamba'),
              ),
              DropdownMenuItem(
                value: 3,
                child: Text('Perşembe'),
              ),
              DropdownMenuItem(
                value: 4,
                child: Text('Cuma'),
              ),
              DropdownMenuItem(
                value: 5,
                child: Text('Cumartesi'),
              ),
              DropdownMenuItem(
                value: 6,
                child: Text('Pazar'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class EndTimeWidget extends ConsumerWidget {
  const EndTimeWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Bitiş :",
            style: Design().poppins(
              size: 13,
              fw: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
              builder: (context, child) {
                return MyTimePickerTheme(child: child!);
              },
            );
            if (picked != null) {
              ref.read(pickedTimeCalendar2Provider.notifier).state = picked;
            }
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: const Color.fromARGB(255, 226, 229, 233),
            foregroundColor: const Color.fromRGBO(246, 153, 92, 1),
            shadowColor: Colors.transparent,
          ),
          child: Text(
            '${ref.watch(pickedTimeCalendar2Provider).hour}:${ref.watch(pickedTimeCalendar2Provider).minute.toString().padLeft(2, '0')}',
            style: Design().poppins(
              color: Colors.grey.shade800,
              fw: FontWeight.w500,
              size: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class StartTimeWidget extends ConsumerWidget {
  const StartTimeWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Başlangıç :",
            style: Design().poppins(
              size: 13,
              fw: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            final TimeOfDay? picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
              builder: (context, child) {
                return MyTimePickerTheme(child: child!);
              },
            );
            if (picked != null) {
              ref.read(pickedTimeCalendar1Provider.notifier).state = picked;
            }
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: const Color.fromARGB(255, 226, 229, 233),
            foregroundColor: const Color.fromRGBO(246, 153, 92, 1),
            shadowColor: Colors.transparent,
          ),
          child: Text(
            '${ref.watch(pickedTimeCalendar1Provider).hour}:${ref.watch(pickedTimeCalendar1Provider).minute.toString().padLeft(2, '0')}',
            style: Design().poppins(
              color: Colors.grey.shade800,
              fw: FontWeight.w500,
              size: 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class CalendarWidget extends ConsumerWidget {
  const CalendarWidget({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.only(
        top: size.width > 1300 ? 40 : 20,
        bottom: 40,
        left: size.width > 1300 ? 20 : 30,
        right: size.width > 1300 ? 40 : 30,
      ),
      width: size.width > 1200 ? (size.width - 65) / 2 : size.width,
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
                dataSource: _getCalendarDataSource(ref.watch(courseSchedules)),
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
                    backgroundColor: const Color.fromARGB(255, 226, 229, 233),
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
    );
  }
}

_AppointmentDataSource _getCalendarDataSource(appointments) {
  return _AppointmentDataSource(appointments);
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}

class DropdownButtonFacultyWidget extends ConsumerWidget {
  final List<dynamic> list;
  const DropdownButtonFacultyWidget(this.list, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 55,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 226, 229, 233),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          return DropdownButton(
            isExpanded: true,
            menuMaxHeight: 200,
            padding: const EdgeInsets.only(left: 13, right: 13),
            style: Design().poppins(
              size: 13,
              color: Colors.grey.shade600,
            ),
            iconEnabledColor: Colors.grey.shade600,
            dropdownColor: const Color.fromARGB(255, 226, 229, 233),
            underline: const Divider(color: Colors.transparent),
            borderRadius: BorderRadius.circular(8),
            value: ref.watch(selectedFacultyCalProvider),
            onChanged: (value) {
              ref.read(selectedFacultyCalProvider.notifier).state = value ?? 0;

              ref.read(selectedDepartCalIdProvider.notifier).state = "";
              ref.read(selectedDepartCalProvider.notifier).state = 0;
              if (value != 0) {
                int selectedIndex = value! - 1;
                String selectedFacultyId = list[selectedIndex].id;
                ref.read(selectedFacultyCalIdProvider.notifier).state =
                    selectedFacultyId;
              }
            },
            items: [
              const DropdownMenuItem(
                value: 0,
                child: Text('Lütfen fakülte seçiniz'),
              ),
              ...List.generate(
                list.length,
                (index) {
                  return DropdownMenuItem(
                    value: (index + 1),
                    child: Text(list[index].name),
                  );
                },
              )
            ],
          );
        },
      ),
    );
  }
}

class DropdownButtonDepartmentWidget extends StatelessWidget {
  final List<dynamic> list;
  const DropdownButtonDepartmentWidget(this.list, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 226, 229, 233),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          return DropdownButton(
            isExpanded: true,
            menuMaxHeight: 200,
            padding: const EdgeInsets.only(left: 13, right: 13),
            style: Design().poppins(
              size: 13,
              color: Colors.grey.shade600,
            ),
            iconEnabledColor: Colors.grey.shade600,
            dropdownColor: const Color.fromARGB(255, 226, 229, 233),
            underline: const Divider(color: Colors.transparent),
            borderRadius: BorderRadius.circular(8),
            value: ref.watch(selectedDepartCalProvider),
            onChanged: (value) {
              ref.read(selectedDepartCalProvider.notifier).state = value ?? 0;
              if (value != 0) {
                int selectedIndex = value! - 1;
                String selectedDepartId = list[selectedIndex].id;
                ref.read(selectedDepartCalIdProvider.notifier).state =
                    selectedDepartId;
              }
            },
            items: [
              const DropdownMenuItem(
                value: 0,
                child: Text('Lütfen bölüm seçiniz'),
              ),
              ...List.generate(
                list.length,
                (index) {
                  return DropdownMenuItem(
                    value: (index + 1),
                    child: Text(list[index].name),
                  );
                },
              )
            ],
          );
        },
      ),
    );
  }
}
