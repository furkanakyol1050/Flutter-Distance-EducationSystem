import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:projectacademy/Pages/hub/instructorpanel/homepage.dart';
import 'package:projectacademy/Pages/hub/instructorpanel/homeworkPage.dart';
import 'package:projectacademy/Pages/hub/instructorpanel/instructorPage.dart';
import 'package:projectacademy/Pages/hub/uniadminpanel/homepage.dart';
import 'package:projectacademy/firebaseConfig/firebase_transactionss.dart';
import 'package:projectacademy/myDesign.dart';

final silinecek4Provider = StateProvider((ref) => 0);
final selectedCourse3Provider = StateProvider((ref) => 0);
final selectedStudent3Provider = StateProvider((ref) => 0);
final rightPanel2Provider = StateProvider((ref) => 0);

final annoTitleProvider = StateProvider((ref) => " ");
final annoContentProvider = StateProvider((ref) => " ");
final annoFilesNameProvider = StateProvider((ref) => []);
final annoFilesProvider = StateProvider<List<PlatformFile>>((ref) => []);

final search1Provider = StateProvider((ref) => "");
final selectedStudent3IdProvider = StateProvider((ref) => "");

class AnnouncementPage extends StatelessWidget {
  const AnnouncementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ListView(
      children: [
        Container(
          height: 50,
          padding: const EdgeInsets.only(left: 50, right: 20),
          alignment: Alignment.center,
          color: Colors.white,
          child: Row(
            children: [
              Text(
                "Duyuru Paylaş",
                style: Design().poppins(
                  color: Colors.grey.shade800,
                  fw: FontWeight.bold,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            size.width > 1300
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          LeftTopWidget(),
                          LeftMiddleWidget(),
                          LeftBottomWidget(),
                        ],
                      ),
                      RightWidget(),
                    ],
                  )
                : const Column(
                    children: [
                      RightWidget(),
                      LeftTopWidget(),
                      LeftMiddleWidget(),
                      LeftBottomWidget(),
                    ],
                  ),
          ],
        ),
      ],
    );
  }
}

class RightWidget extends ConsumerWidget {
  const RightWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(
        bottom: size.width > 1300 ? 40 : 20,
        top: 40,
        left: size.width > 1300 ? 20 : 40,
        right: 40,
      ),
      width: size.width > 1300 ? ((size.width - 65) / 5) * 2 : size.width - 65,
      height: size.width > 1300 ? 900 : 500,
      child: Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(35, 35, 35, 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      ref.read(rightPanel2Provider.notifier).state = 0;
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    label: Text(
                      "Dersler",
                      style: Design().poppins(
                        color: ref.watch(rightPanel2Provider) == 0
                            ? const Color.fromRGBO(205, 205, 205, 1)
                            : const Color.fromRGBO(70, 70, 70, 1),
                        size: size.width > 1300 ? 20 : 15,
                      ),
                    ),
                    icon: Icon(
                      Icons.book,
                      color: ref.watch(rightPanel2Provider) == 0
                          ? const Color.fromRGBO(205, 205, 205, 1)
                          : const Color.fromRGBO(70, 70, 70, 1),
                    ),
                  ),
                  const VerticalDivider(
                      width: 50,
                      thickness: 2,
                      color: Color.fromRGBO(205, 205, 205, 1)),
                  TextButton.icon(
                    onPressed: () {
                      ref.read(rightPanel2Provider.notifier).state = 1;
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    label: Text(
                      "Öğrenciler",
                      style: Design().poppins(
                        color: ref.watch(rightPanel2Provider) == 1
                            ? const Color.fromRGBO(205, 205, 205, 1)
                            : const Color.fromRGBO(70, 70, 70, 1),
                        size: size.width > 1300 ? 20 : 15,
                      ),
                    ),
                    icon: Icon(
                      Icons.groups_rounded,
                      color: ref.watch(rightPanel2Provider) == 1
                          ? const Color.fromRGBO(205, 205, 205, 1)
                          : const Color.fromRGBO(70, 70, 70, 1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ref.watch(rightPanel2Provider) == 0
                ? Expanded(
                    child: FutureBuilder<List<dynamic>?>(
                        future: UniversityService().getCourseIds(
                            ref.watch(luniIdProvider).asData!.value,
                            ref.watch(linstructorIdProvider).asData!.value),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
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
                              return Container(
                                alignment: Alignment.center,
                                margin: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: const Color.fromRGBO(50, 50, 50, 1),
                                ),
                                child: Text(
                                  "Ders Eklenmedi",
                                  style: Design().poppins(
                                      size: 15,
                                      color: const Color.fromRGBO(
                                          205, 205, 205, 1)),
                                ),
                              );
                            }
                          } else {
                            final courses = snapshot.data!;
                            return Container(
                              margin: const EdgeInsets.all(20),
                              child: ListView.builder(
                                itemCount: courses.length,
                                itemBuilder: (context, index) {
                                  return FutureBuilder<Course?>(
                                      future: UniversityService().getCourseById(
                                          ref
                                              .watch(luniIdProvider)
                                              .asData!
                                              .value,
                                          ref
                                              .watch(lfacultyIdProvider)
                                              .asData!
                                              .value,
                                          ref
                                              .watch(ldepartmentIdProvider)
                                              .asData!
                                              .value,
                                          courses[index]),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData) {
                                          return Container();
                                        } else {
                                          final course = snapshot.data!;

                                          Stream<String?> lastDate = UniversityService()
                                              .getCourseAnnouncementDateStream(
                                                  ref
                                                      .watch(luniIdProvider)
                                                      .asData!
                                                      .value,
                                                  ref
                                                      .watch(lfacultyIdProvider)
                                                      .asData!
                                                      .value,
                                                  ref
                                                      .watch(
                                                          ldepartmentIdProvider)
                                                      .asData!
                                                      .value,
                                                  course.id);

                                          return Card(
                                            color:
                                                ref.watch(selectedCourse3Provider) ==
                                                        index
                                                    ? const Color.fromRGBO(
                                                        90, 90, 90, 1)
                                                    : const Color.fromRGBO(
                                                        50, 50, 50, 1),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              onTap: () {
                                                ref
                                                    .read(
                                                        selectedCourse3Provider
                                                            .notifier)
                                                    .state = index;

                                                ref
                                                    .read(
                                                        selectedCourse2Provider
                                                            .notifier)
                                                    .state = index;

                                                ref
                                                    .read(
                                                        courseIndexId.notifier)
                                                    .state = course.id;
                                              },
                                              child: ListTile(
                                                contentPadding:
                                                    const EdgeInsets.only(
                                                  top: 10,
                                                  bottom: 10,
                                                  left: 20,
                                                  right: 20,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                tileColor:
                                                    ref.watch(selectedCourse3Provider) ==
                                                            index
                                                        ? const Color.fromRGBO(
                                                            90, 90, 90, 1)
                                                        : const Color.fromRGBO(
                                                            50, 50, 50, 1),
                                                title: Text(
                                                  course.name,
                                                  style: Design().poppins(
                                                    color: const Color.fromRGBO(
                                                        205, 205, 205, 1),
                                                    size: 15,
                                                  ),
                                                ),
                                                subtitle: StreamBuilder<
                                                        String?>(
                                                    stream: lastDate,
                                                    builder:
                                                        (context, snapshot) {
                                                      if (!snapshot.hasData) {
                                                        if (snapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .waiting) {
                                                          return Container();
                                                        } else {
                                                          return Container();
                                                        }
                                                      } else {
                                                        return Text(
                                                          snapshot.data!,
                                                          style:
                                                              Design().poppins(
                                                            color: const Color
                                                                .fromRGBO(205,
                                                                205, 205, 1),
                                                            size: 13,
                                                          ),
                                                        );
                                                      }
                                                    }),
                                                leading: Container(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    right: 10,
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        "${course.studentIds.length}  ",
                                                        style: Design().poppins(
                                                          color: const Color
                                                              .fromRGBO(
                                                              246, 153, 92, 1),
                                                          size: 13,
                                                        ),
                                                      ),
                                                      const Icon(
                                                        Icons.groups_rounded,
                                                        color: Color.fromRGBO(
                                                            246, 153, 92, 1),
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
                              ),
                            );
                          }
                        }))
                : Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CostomSearchBarWidget(
                          function: (String string) {
                            ref.read(search1Provider.notifier).state = string;
                          },
                          hintText: "Öğrenci Ara",
                        ),
                        FutureBuilder<List<String>>(
                            future: UniversityService().getAllCourseStudents(
                                ref.watch(luniIdProvider).asData?.value ?? "",
                                ref.watch(lfacultyIdProvider).asData?.value ??
                                    "",
                                ref
                                        .watch(ldepartmentIdProvider)
                                        .asData
                                        ?.value ??
                                    "",
                                ref.watch(courseIndexId),
                                ref.watch(search1Provider)),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Container();
                                } else {
                                  return Container(
                                    alignment: Alignment.center,
                                    margin: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color:
                                          const Color.fromRGBO(50, 50, 50, 1),
                                    ),
                                    child: Text(
                                      "Ders Eklenmedi",
                                      style: Design().poppins(
                                          size: 15,
                                          color: const Color.fromRGBO(
                                              205, 205, 205, 1)),
                                    ),
                                  );
                                }
                              } else {
                                var students = snapshot.data!;
                                return Expanded(
                                    flex: 27,
                                    child: Container(
                                      margin: const EdgeInsets.all(20),
                                      child: ListView.builder(
                                        itemCount: students.length,
                                        itemBuilder: (context, index) {
                                          return FutureBuilder<Student>(
                                              future: UniversityService()
                                                  .getStudentDetails(
                                                      ref
                                                              .watch(
                                                                  luniIdProvider)
                                                              .asData
                                                              ?.value ??
                                                          "",
                                                      ref
                                                              .watch(
                                                                  lfacultyIdProvider)
                                                              .asData
                                                              ?.value ??
                                                          "",
                                                      ref
                                                              .watch(
                                                                  ldepartmentIdProvider)
                                                              .asData
                                                              ?.value ??
                                                          "",
                                                      students[index]),
                                              builder: (context, snapshot) {
                                                if (!snapshot.hasData) {
                                                  if (snapshot
                                                          .connectionState ==
                                                      ConnectionState.waiting) {
                                                    return Container();
                                                  } else {
                                                    return Container();
                                                  }
                                                } else {
                                                  var student = snapshot.data!;
                                                  return Card(
                                                    color:
                                                        ref.watch(selectedStudent3Provider) ==
                                                                index
                                                            ? const Color
                                                                .fromRGBO(90,
                                                                90, 90, 1)
                                                            : const Color
                                                                .fromRGBO(
                                                                50, 50, 50, 1),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    child: InkWell(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      onTap: () {
                                                        ref
                                                            .read(
                                                                selectedStudent3Provider
                                                                    .notifier)
                                                            .state = index;

                                                        ref
                                                            .read(
                                                                selectedStudent3IdProvider
                                                                    .notifier)
                                                            .state = student.id;
                                                      },
                                                      child: ListTile(
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .only(
                                                          top: 10,
                                                          bottom: 10,
                                                          left: 20,
                                                          right: 20,
                                                        ),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        tileColor: ref.watch(
                                                                    selectedStudent3Provider) ==
                                                                index
                                                            ? const Color
                                                                .fromRGBO(
                                                                90, 90, 90, 1)
                                                            : const Color
                                                                .fromRGBO(
                                                                50, 50, 50, 1),
                                                        title: Text(
                                                          "${student.name} ${student.sname}",
                                                          style:
                                                              Design().poppins(
                                                            color: const Color
                                                                .fromRGBO(205,
                                                                205, 205, 1),
                                                            size: 15,
                                                          ),
                                                        ),
                                                        subtitle: Text(
                                                          student.mail,
                                                          style:
                                                              Design().poppins(
                                                            color: const Color
                                                                .fromRGBO(205,
                                                                205, 205, 1),
                                                            size: 13,
                                                          ),
                                                        ),
                                                        leading: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                            right: 10,
                                                          ),
                                                          child: Text(
                                                            student.no,
                                                            style: Design()
                                                                .poppins(
                                                              color: const Color
                                                                  .fromRGBO(246,
                                                                  153, 92, 1),
                                                              size: 13,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }
                                              });
                                        },
                                      ),
                                    ));
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

class LeftTopWidget extends ConsumerWidget {
  const LeftTopWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(
        left: 40,
        bottom: 20,
        top: size.width > 1300 ? 40 : 20,
        right: size.width > 1300 ? 20 : 40,
      ),
      width: size.width > 1300 ? ((size.width - 65) / 5) * 3 : size.width - 65,
      height: 450,
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
                "Yazı Ekle",
                style: Design().poppins(
                  size: 16,
                  fw: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: TextFormField(
                onChanged: (value) {
                  ref.read(annoTitleProvider.notifier).state = value;
                },
                style: Design().poppins(
                  size: 14,
                  color: Colors.grey.shade700,
                ),
                cursorColor: Colors.grey.shade600,
                cursorWidth: 2,
                minLines: 1,
                maxLines: 1,
                cursorRadius: const Radius.circular(25),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(
                    left: 30,
                    right: 30,
                    top: 40,
                  ),
                  hintText: "Başlık",
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
            ),
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: TextFormField(
                  onChanged: (value) {
                    ref.read(annoContentProvider.notifier).state = value;
                  },
                  style: Design().poppins(
                    size: 14,
                    color: Colors.grey.shade700,
                  ),
                  cursorColor: Colors.grey.shade600,
                  cursorWidth: 2,
                  minLines: 9,
                  maxLines: 20,
                  cursorRadius: const Radius.circular(25),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.only(
                      left: 30,
                      right: 30,
                      top: 40,
                    ),
                    hintText: "Gövde",
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LeftMiddleWidget extends ConsumerWidget {
  const LeftMiddleWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(
        left: 40,
        top: 20,
        bottom: 20,
        right: size.width > 1300 ? 20 : 40,
      ),
      width: size.width > 1300 ? ((size.width - 65) / 5) * 3 : size.width - 65,
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
                FilePickerResult? result =
                    await FilePicker.platform.pickFiles(allowMultiple: true);

                var list = ref.watch(annoFilesNameProvider);
                var list2 = ref.watch(annoFilesProvider);

                if (result != null) {
                  for (PlatformFile file in result.files) {
                    list.add(file.name);
                    list2.add(file);
                  }
                }
                // ignore: unused_result
                ref.refresh(annoFilesNameProvider);
                // ignore: unused_result
                ref.refresh(annoFilesProvider);

                ref.read(annoFilesProvider.notifier).state = list2;
                ref.read(annoFilesNameProvider.notifier).state = list;
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.all(20),
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
            const SizedBox(height: 20),
            ref.watch(annoFilesNameProvider).isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                      itemCount: ref.watch(annoFilesNameProvider).length,
                      itemBuilder: (context, index) {
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          shadowColor: Colors.transparent,
                          child: ListTile(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            tileColor: const Color.fromARGB(255, 226, 229, 233),
                            leading: const Icon(Icons.file_present_rounded),
                            title: Text(
                              ref.watch(annoFilesNameProvider)[index],
                              style: Design().poppins(
                                color: Colors.grey.shade800,
                                size: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            trailing: IconButton(
                              onPressed: () {
                                var list = ref.watch(annoFilesNameProvider);
                                var list2 = ref.watch(annoFilesProvider);

                                list.removeAt(index);
                                list2.removeAt(index);

                                // ignore: unused_result
                                ref.refresh(annoFilesNameProvider);
                                // ignore: unused_result
                                ref.refresh(annoFilesProvider);

                                ref.read(annoFilesProvider.notifier).state =
                                    list2;
                                ref.read(annoFilesNameProvider.notifier).state =
                                    list;
                              },
                              icon: const Icon(
                                Icons.delete,
                                color: Color.fromRGBO(211, 118, 118, 1),
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
    );
  }
}

class LeftBottomWidget extends ConsumerWidget {
  const LeftBottomWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(
        left: 40,
        bottom: 40,
        top: 20,
        right: size.width > 1300 ? 20 : 40,
      ),
      width: size.width > 1300 ? ((size.width - 65) / 5) * 3 : size.width - 65,
      height: 150,
      child: Container(
        alignment: size.width > 1300 ? Alignment.centerRight : Alignment.center,
        padding: const EdgeInsets.only(left: 40, right: 40),
        child: SizedBox(
          width: 150,
          height: 50,
          child: ElevatedButton(
            onPressed: () async {
              List<String> tempList = [];
              List<String> tempList2 = [];

              String date = DateTime.now().toString().substring(0, 16);

              for (var file in ref.watch(annoFilesProvider)) {
                String fileName = file.name;
                Reference storageReference = FirebaseStorage.instance.ref().child(
                    'uploads/announcements/${ref.watch(courseIndexId)}/$date/$fileName');
                TaskSnapshot taskSnapshot = await storageReference
                    .putData(file.bytes!)
                    .whenComplete(() => null);
                String url = await taskSnapshot.ref.getDownloadURL();

                tempList.add(url);
                tempList2.add(fileName);
              }

              if (ref.watch(selectedStudent3IdProvider) != "" &&
                  ref.watch(rightPanel2Provider) == 1) {
                UniversityService().addCourseAnnouncement(
                    ref.watch(luniIdProvider).asData!.value,
                    ref.watch(lfacultyIdProvider).asData!.value,
                    ref.watch(ldepartmentIdProvider).asData!.value,
                    ref.watch(courseIndexId),
                    ref.watch(annoTitleProvider),
                    ref.watch(annoContentProvider),
                    ref.watch(selectedStudent3IdProvider),
                    tempList2,
                    tempList);
              } else {
                UniversityService().addCourseAnnouncement(
                    ref.watch(luniIdProvider).asData!.value,
                    ref.watch(lfacultyIdProvider).asData!.value,
                    ref.watch(ldepartmentIdProvider).asData!.value,
                    ref.watch(courseIndexId),
                    ref.watch(annoTitleProvider),
                    ref.watch(annoContentProvider),
                    "",
                    tempList2,
                    tempList);
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(20),
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
              "Duyuru Paylaş",
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
