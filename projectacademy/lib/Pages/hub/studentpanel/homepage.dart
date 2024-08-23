import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:projectacademy/Pages/VideoSDK/api_call.dart';
import 'package:projectacademy/Pages/VideoSDK/meeting_screen.dart';
import 'package:projectacademy/Pages/hub/studentpanel/joincoursepage.dart';
import 'package:projectacademy/Pages/hub/uniadminpanel/homepage.dart';
import 'package:projectacademy/firebaseConfig/firebase_transactionss.dart';
import 'package:projectacademy/myDesign.dart';

final silinecek2Provider = StateProvider((ref) => 0);
final rightPanelProvider = StateProvider((ref) => 0);
final selectedCourseProvider = StateProvider((ref) => 0);
final leftStudentPageProvider = StateProvider((ref) => 0);

final selectedHomeworkIdProvider = StateProvider((ref) => "");
final courseNameProvider = StateProvider((ref) => " ");
final courseIdProvider = StateProvider((ref) => " ");
final instructorIdProvider = StateProvider((ref) => " ");

final descriptionProvider = StateProvider((ref) => "");
int y = 0;

final isChangedProvider = StateProvider((ref) => 0);

final homeworkFilesNameProvider = StateProvider((ref) => []);
final homeworkFilesProvider = StateProvider<List<PlatformFile>>((ref) => []);

final examFeaturesProvider = StateProvider((ref) => <String, dynamic>{});
final questionsListProvider = StateProvider((ref) => <Map<String, dynamic>>[]);

final courselenghtProvider = FutureProvider((ref) async {
  final temp = await UniversityService().getAssignedLecturesCount(
      ref.watch(runiIdProvider).asData?.value ?? " ",
      ref.watch(rfacultyIdProvider).asData?.value ?? " ",
      ref.watch(rdepartmentIdProvider).asData?.value ?? " ",
      ref.watch(rstudentIdProvider).asData?.value ?? " ");

  return temp;
});

class HomePageWidget extends ConsumerWidget {
  const HomePageWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.only(left: 65),
      width: size.width,
      height: size.height,
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: ref.watch(leftStudentPageProvider) == 0
                  ? const LeftHomePageWidget()
                  : const HomeworkPageWidget(),
            ),
          ),
          const RightHomePageWidget(),
        ],
      ),
    );
  }
}

final fileListProvider =
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

class LeftHomePageWidget extends ConsumerWidget {
  const LeftHomePageWidget({
    super.key,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncFileList =
        ref.watch(fileListProvider(ref.watch(courseIdProvider)));
    final lectureCount = ref.watch(courselenghtProvider).asData?.value;
    final size = MediaQuery.of(context).size;
    return ListView(
      children: [
        lectureCount != 0
            ? ref.watch(isChangedProvider) != 0
                ? Column(
                    children: [
                      Container(
                        height: 50,
                        padding: const EdgeInsets.only(left: 50, right: 20),
                        alignment: Alignment.center,
                        color: Colors.white,
                        child: FutureBuilder<Course>(
                            future: UniversityService().getCourseById(
                                ref.watch(runiIdProvider).asData!.value,
                                ref.watch(rfacultyIdProvider).asData!.value,
                                ref.watch(rdepartmentIdProvider).asData!.value,
                                ref.watch(courseIdProvider)),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Container();
                              } else if (!snapshot.hasData) {
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
                                      course.id.isEmpty
                                          ? course.id
                                          : course.id.substring(0, 13),
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
                      size.width > 1000
                          ? Row(
                              children: [
                                TopLeftWidget(size: size),
                                TopRightWidget(size: size),
                              ],
                            )
                          : Column(
                              children: [
                                TopLeftWidget(size: size),
                                TopRightWidget(size: size),
                              ],
                            ),
                      Container(
                        padding: const EdgeInsets.only(
                          left: 40,
                          top: 20,
                          bottom: 20,
                          right: 40,
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
                                    ref.watch(runiIdProvider).asData!.value,
                                    ref.watch(rfacultyIdProvider).asData!.value,
                                    ref
                                        .watch(rdepartmentIdProvider)
                                        .asData!
                                        .value,
                                    ref.watch(courseIdProvider)),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Container(
                                      alignment: Alignment.center,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 226, 229, 233),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text(""),
                                    );
                                  } else if (!snapshot.hasData ||
                                      snapshot.data!.isEmpty) {
                                    return Container(
                                      alignment: Alignment.center,
                                      height: 150,
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 226, 229, 233),
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
                                  } else {
                                    final homeworks = snapshot.data!;
                                    return snapshot.hasData
                                        ? GridView.builder(
                                            shrinkWrap: true,
                                            itemCount: homeworks.length,
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: size.width > 1800
                                                  ? 5
                                                  : size.width > 1000
                                                      ? 3
                                                      : size.width > 800
                                                          ? 2
                                                          : 1,
                                              childAspectRatio:
                                                  MediaQuery.of(context)
                                                              .size
                                                              .width <
                                                          1800
                                                      ? 1.4
                                                      : 1.3,
                                              mainAxisSpacing: 5,
                                              crossAxisSpacing: 5,
                                            ),
                                            itemBuilder: (context, index) {
                                              final homework = homeworks[index];
                                              return Card(
                                                child: InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  onTap: () {
                                                    ref
                                                        .read(
                                                            leftStudentPageProvider
                                                                .notifier)
                                                        .state = 1;

                                                    ref
                                                        .read(
                                                            selectedHomeworkIdProvider
                                                                .notifier)
                                                        .state = homework.id;
                                                  },
                                                  splashColor: Colors.white38,
                                                  child: ListTile(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    tileColor:
                                                        const Color.fromRGBO(
                                                            211, 118, 118, 1),
                                                    contentPadding:
                                                        const EdgeInsets.only(
                                                      left: 15,
                                                      bottom: 10,
                                                      top: 10,
                                                    ),
                                                    title: Text(
                                                      homework.title,
                                                      style: Design().poppins(
                                                        color: Colors.white,
                                                        size: 15,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      maxLines: 2,
                                                    ),
                                                    subtitle: Column(
                                                      children: [
                                                        const SizedBox(
                                                            height: 10),
                                                        Row(
                                                          children: [
                                                            const Icon(
                                                              Icons.timer_sharp,
                                                              color:
                                                                  Colors.white,
                                                              size: 18,
                                                            ),
                                                            Text(
                                                              " 13 Ekim 2024 14:00",
                                                              style: Design()
                                                                  .poppins(
                                                                color: Colors
                                                                    .white,
                                                                size: 13,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Row(
                                                          children: [
                                                            const Icon(
                                                              Icons
                                                                  .timer_off_outlined,
                                                              color:
                                                                  Colors.white,
                                                              size: 18,
                                                            ),
                                                            Text(
                                                              " 15 Ekim 2024 23:59",
                                                              style: Design()
                                                                  .poppins(
                                                                color: Colors
                                                                    .white,
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
                                              color: const Color.fromARGB(
                                                  255, 226, 229, 233),
                                              borderRadius:
                                                  BorderRadius.circular(8),
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
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(
                          left: 40,
                          top: 20,
                          bottom: 40,
                          right: 40,
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
                              asyncFileList.when(
                                data: (files) {
                                  if (files.isEmpty) {
                                    return Container(
                                      alignment: Alignment.center,
                                      height: 200,
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 226, 229, 233),
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
                                    itemCount: files
                                        .length, // Use the length of the files list
                                    gridDelegate:
                                        SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: MediaQuery.of(context)
                                                  .size
                                                  .width >
                                              1800
                                          ? 4
                                          : MediaQuery.of(context).size.width >
                                                  1000
                                              ? 3
                                              : MediaQuery.of(context)
                                                          .size
                                                          .width >
                                                      700
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
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          onTap: () async {
                                            final downloadUrl =
                                                await FirebaseStorage.instance
                                                    .ref(file['path'])
                                                    .getDownloadURL();

                                            UniversityService()
                                                .downloadFile(downloadUrl);
                                          },
                                          splashColor: Colors.white38,
                                          child: ListTile(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            tileColor: const Color.fromRGBO(
                                                81, 130, 155, 1),
                                            contentPadding:
                                                const EdgeInsets.only(
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
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
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
                                    color: const Color.fromARGB(
                                        255, 226, 229, 233),
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
                      ),
                    ],
                  )
                : Container(
                    padding:
                        const EdgeInsets.only(left: 40, top: 40, right: 40),
                    width: size.width > 1300
                        ? ((size.width - 65) / 5) * 3
                        : size.width - 65,
                    height: 300,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Spacer(flex: 4),
                          const Icon(
                            Icons.warning_amber_rounded,
                            size: 60,
                            color: Color.fromRGBO(211, 118, 118, 1),
                          ),
                          const Spacer(),
                          Text(
                            """Sağ panelden ders seçiniz.""",
                            style: Design().poppins(size: 15),
                            textAlign: TextAlign.center,
                          ),
                          const Spacer(flex: 4),
                        ],
                      ),
                    ),
                  )
            : Container(
                padding: const EdgeInsets.only(left: 40, top: 40, right: 40),
                width: size.width > 1300
                    ? ((size.width - 65) / 5) * 3
                    : size.width - 65,
                height: 300,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Spacer(flex: 4),
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 60,
                        color: Color.fromRGBO(211, 118, 118, 1),
                      ),
                      const Spacer(),
                      Text(
                        """Ders kaydınız bulunmamaktadır. Bağlı olduğunuz kurumdan"""
                        """\nalmış olduğunuz kod ile derslere kayıt olabilirsiniz.""",
                        style: Design().poppins(size: 15),
                        textAlign: TextAlign.center,
                      ),
                      const Spacer(flex: 4),
                    ],
                  ),
                ),
              ),
      ],
    );
  }
}

class TopRightWidget extends ConsumerWidget {
  const TopRightWidget({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.only(
        left: size.width > 1000 ? 20 : 40,
        top: size.width > 1000 ? 40 : 20,
        bottom: 20,
        right: 40,
      ),
      width: size.width > 1400
          ? (size.width - 565) / 2
          : size.width > 1000
              ? (size.width - 65) / 2
              : (size.width - 65),
      height: 650,
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
                "Ders Duyuruları",
                style: Design().poppins(
                  size: 16,
                  fw: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            FutureBuilder<List<CourseAnno>>(
              future: UniversityService().getCourseAnnouncements(
                  ref.watch(runiIdProvider).asData!.value,
                  ref.watch(rfacultyIdProvider).asData!.value,
                  ref.watch(rdepartmentIdProvider).asData!.value,
                  ref.watch(courseIdProvider)),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 226, 229, 233),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(""),
                      ),
                    );
                  } else {
                    return Expanded(
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
                } else {
                  final announcements = snapshot.data!;
                  return Expanded(
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
                          baseColor: const Color.fromARGB(255, 226, 229, 233),
                          expandedTextColor: Colors.black,
                          initialPadding: const EdgeInsets.only(top: 10),
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
                                    height: announcement.fileUrls.length * 77,
                                    child: ListView.builder(
                                      itemCount: announcement.fileUrls.length,
                                      itemBuilder: (context, index) {
                                        return Card(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          shadowColor: Colors.transparent,
                                          child: ListTile(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            tileColor: Colors.white,
                                            leading: const Icon(
                                                Icons.file_present_rounded),
                                            title: Text(
                                              announcement.fileNames[index],
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
                                      borderRadius: BorderRadius.circular(8),
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
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

void onJoinButtonPressed(
    BuildContext context,
    String uniId,
    String facultyId,
    String departmentId,
    String personId,
    String courseId,
    String meetingId,
    String insId) {
  String meetId = meetingId;
  var re = RegExp("\\w{4}\\-\\w{4}\\-\\w{4}");
  var a = 0;
  if (meetId.isNotEmpty && re.hasMatch(meetId)) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MeetingScreen(
          meetId,
          token,
          uniId: uniId,
          facultyId: facultyId,
          departmentId: departmentId,
          personName: personId,
          courseId: courseId,
          insId: insId,
          isCreater: a,
        ),
      ),
    );
  } else {
    showSnackBarWidget(context, "Aktif canlı ders bulunmuyor.");
  }
}

class TopLeftWidget extends ConsumerWidget {
  const TopLeftWidget({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uniId = ref.watch(runiIdProvider).asData?.value ?? "";
    final facultyId = ref.watch(rfacultyIdProvider).asData?.value ?? "";
    final departmentId = ref.watch(rdepartmentIdProvider).asData?.value ?? "";
    final studentId = ref.watch(rstudentIdProvider).asData?.value ?? "";
    final courseId = ref.watch(courseIdProvider);
    return Container(
      padding: EdgeInsets.only(
        left: 40,
        top: 40,
        bottom: 20,
        right: size.width > 1000 ? 20 : 40,
      ),
      width: size.width > 1400
          ? (size.width - 565) / 2
          : size.width > 1000
              ? (size.width - 65) / 2
              : (size.width - 65),
      height: 650,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: FutureBuilder<Instructor>(
                future: UniversityService().getInstructor(
                    ref.watch(instructorIdProvider),
                    ref.watch(runiIdProvider).asData!.value),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                      height: 100,
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
                    );
                  } else if (!snapshot.hasData) {
                    return Container(
                      height: 100,
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
                    );
                  } else {
                    var instructor = snapshot.data!;
                    return ListTile(
                      title: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.account_circle,
                            color: Color.fromRGBO(211, 118, 118, 1),
                          ),
                          Text(
                            "  ${instructor.title} ${instructor.firstName} ${instructor.lastName}",
                            style: Design().poppins(
                              color: const Color.fromRGBO(211, 118, 118, 1),
                              fw: FontWeight.bold,
                              size: 15,
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
                      ),
                    );
                  }
                },
              ),
            ),
            const Spacer(flex: 15),
            Card(
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
                onTap: () async {
                  var meetingId = await UniversityService().getRoomId(
                          uniId, facultyId, departmentId, courseId) ??
                      "";
                  var insId = await UniversityService().getRoomInsId(
                          uniId, facultyId, departmentId, courseId) ??
                      "";
                  var studentName = await UniversityService().getStudentName(
                      uniId, facultyId, departmentId, studentId);
                  // ignore: use_build_context_synchronously
                  onJoinButtonPressed(context, uniId, facultyId, departmentId,
                      studentName, courseId, meetingId, insId);
                },
                splashColor: Colors.white38,
                child: ListTile(
                  tileColor: const Color.fromRGBO(81, 130, 155, 1),
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
                    "Canlı Derse Katıl",
                    style: Design().poppins(
                      color: Colors.white,
                      fw: FontWeight.bold,
                      size: 20,
                    ),
                  ),
                  subtitle: Text(
                    "\nPazartesi 13:00 - 15:00\nPerşembe 9:00 - 12:00",
                    style: Design().poppins(
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const Spacer(),
            Card(
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
                onTap: () {
                  showTextDialog(
                    context: context,
                    ref: ref,
                    buttonText: "Sınava Başla",
                    tittleText: "Sınava şimdi başlamak istiyor musunuz?",
                    centerText: """Eğer sınava girerseniz"""
                        """ başka hakkınız olmayacaktır. İnternet"""
                        """ bağlantınızı kontrol edin ve hazır olduğunuzda"""
                        """ butona basarak sınava başlayın.""",
                    icon: Icons.warning,
                    buttonFunc: () async {
                      Navigator.pop(context);

                      bool isAvailable = await UniversityService()
                          .isExamAvailable(uniId, facultyId, departmentId,
                              studentId, courseId);

                      if (isAvailable) {
                        ref.read(examFeaturesProvider.notifier).state =
                            await UniversityService().getExamFeatures(
                                uniId, facultyId, departmentId, studentId);

                        ref.read(questionsListProvider.notifier).state =
                            await UniversityService().getExamQuestions(
                                uniId,
                                facultyId,
                                departmentId,
                                studentId,
                                courseId,
                                1);
                        // ignore: use_build_context_synchronously
                        Navigator.pushNamed(context, "/examsolving");
                      } else {
                        showSnackBarWidget(
                            // ignore: use_build_context_synchronously
                            context,
                            "Sınav şu anda erişilebilir değil!");
                      }
                    },
                    color: const Color.fromRGBO(246, 153, 92, 1),
                    buttonColor: const Color.fromRGBO(246, 153, 92, 1),
                  );
                },
                splashColor: Colors.white38,
                child: ListTile(
                  tileColor: const Color.fromRGBO(246, 153, 92, 1),
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
                    "Sınava Başla",
                    style: Design().poppins(
                      color: Colors.white,
                      fw: FontWeight.bold,
                      size: 20,
                    ),
                  ),
                  subtitle: Text(
                    "\nVize Pazertesi 13:00 - 15:00\nFinal Belirlenmemiş",
                    style: Design().poppins(
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
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

class RightHomePageWidget extends ConsumerWidget {
  const RightHomePageWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String uniId = ref.watch(runiIdProvider).asData?.value ?? " ";
    String facultyId = ref.watch(rfacultyIdProvider).asData?.value ?? " ";
    String departmentId = ref.watch(rdepartmentIdProvider).asData?.value ?? " ";
    String studentId = ref.watch(rstudentIdProvider).asData?.value ?? " ";

    final size = MediaQuery.of(context).size;
    return size.width > 1400 && size.height > 200
        ? Container(
            width: 500,
            padding: const EdgeInsets.only(top: 30),
            alignment: Alignment.center,
            color: const Color.fromRGBO(35, 35, 35, 1),
            child: Column(
              children: [
                IntrinsicHeight(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          ref.read(rightPanelProvider.notifier).state = 0;
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
                            color: ref.watch(rightPanelProvider) == 0
                                ? const Color.fromRGBO(205, 205, 205, 1)
                                : const Color.fromRGBO(70, 70, 70, 1),
                            size: 20,
                          ),
                        ),
                        icon: Icon(
                          Icons.book,
                          color: ref.watch(rightPanelProvider) == 0
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
                          ref.read(rightPanelProvider.notifier).state = 1;
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        label: Text(
                          "Duyurular",
                          style: Design().poppins(
                            color: ref.watch(rightPanelProvider) == 1
                                ? const Color.fromRGBO(205, 205, 205, 1)
                                : const Color.fromRGBO(70, 70, 70, 1),
                            size: 20,
                          ),
                        ),
                        icon: Icon(
                          Icons.announcement_rounded,
                          color: ref.watch(rightPanelProvider) == 1
                              ? const Color.fromRGBO(205, 205, 205, 1)
                              : const Color.fromRGBO(70, 70, 70, 1),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                ref.watch(rightPanelProvider) == 0
                    ? CoursePanelWidget(
                        uniId: uniId,
                        facultyId: facultyId,
                        departmentId: departmentId,
                        studentId: studentId,
                      )
                    : AnnoPanelWidget(uniId: uniId, facultyId: facultyId),
                const SizedBox(height: 20),
              ],
            ),
          )
        : Container();
  }
}

class CoursePanelWidget extends ConsumerWidget {
  const CoursePanelWidget({
    super.key,
    required this.uniId,
    required this.facultyId,
    required this.departmentId,
    required this.studentId,
  });

  final String uniId;
  final String facultyId;
  final String departmentId;
  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StreamBuilder<List<String>?>(
        stream: UniversityService()
            .getAssignedLectures(uniId, facultyId, departmentId, studentId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Expanded(
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color.fromRGBO(50, 50, 50, 1),
                ),
                child: const SpinKitPulse(
                  color: Color.fromRGBO(205, 205, 205, 1),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Container();
          } else {
            var courses = snapshot.data ?? [];
            return Expanded(
              child: courses.isNotEmpty
                  ? Container(
                      margin: const EdgeInsets.all(20),
                      child: ListView.builder(
                        itemCount: courses.length,
                        itemBuilder: (context, index) {
                          String courseId = courses[index];
                          return FutureBuilder<Course?>(
                            future: UniversityService().getCourseDetails(
                                uniId, facultyId, departmentId, courseId),
                            builder: (context, courseSnapshot) {
                              if (courseSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Container();
                              } else {
                                Course course = courseSnapshot.data!;
                                return Card(
                                  color:
                                      ref.watch(selectedCourseProvider) == index
                                          ? const Color.fromRGBO(90, 90, 90, 1)
                                          : const Color.fromRGBO(50, 50, 50, 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(8),
                                    onTap: () {
                                      ref
                                          .read(isChangedProvider.notifier)
                                          .state = 1;
                                      ref
                                          .read(instructorIdProvider.notifier)
                                          .state = course.instructorId;
                                      ref
                                          .read(courseNameProvider.notifier)
                                          .state = course.name;
                                      ref
                                          .read(courseIdProvider.notifier)
                                          .state = course.id;
                                      ref
                                          .read(selectedCourseProvider.notifier)
                                          .state = index;
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
                                      tileColor: ref.watch(
                                                  selectedCourseProvider) ==
                                              index
                                          ? const Color.fromRGBO(90, 90, 90, 1)
                                          : const Color.fromRGBO(50, 50, 50, 1),
                                      title: Text(
                                        course.name,
                                        style: Design().poppins(
                                          color: const Color.fromRGBO(
                                              205, 205, 205, 1),
                                          size: 15,
                                        ),
                                      ),
                                      subtitle: Text(
                                        course.instructorId,
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
                                              "${course.studentIds.length}  ",
                                              style: Design().poppins(
                                                color: const Color.fromRGBO(
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
                            },
                          );
                        },
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
                        "Ders Eklenmedi",
                        style: Design().poppins(
                            size: 15,
                            color: const Color.fromRGBO(205, 205, 205, 1)),
                      ),
                    ),
            );
          }
        });
  }
}

class AnnoPanelWidget extends ConsumerWidget {
  const AnnoPanelWidget({
    super.key,
    required this.uniId,
    required this.facultyId,
  });

  final String uniId;
  final String facultyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<Announcement>>(
      future: UniversityService().getAnnouncements(uniId, facultyId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Expanded(
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color.fromRGBO(50, 50, 50, 1),
              ),
              child: const SpinKitPulse(
                color: Color.fromRGBO(205, 205, 205, 1),
              ),
            ),
          );
        } else {
          final announcements = snapshot.data!;
          return Expanded(
            child: announcements.isNotEmpty
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color.fromRGBO(50, 50, 50, 1),
                    ),
                    margin: const EdgeInsets.all(20),
                    padding: const EdgeInsets.all(10),
                    child: ListView.builder(
                      itemCount: announcements.length,
                      itemBuilder: (context, index) {
                        final announcement = announcements[index];
                        return ExpansionTileCard(
                          shadowColor: Colors.transparent,
                          contentPadding: const EdgeInsets.all(10),
                          expandedColor: const Color.fromRGBO(40, 40, 40, 1),
                          colorCurve: Curves.linear,
                          borderRadius: BorderRadius.circular(8),
                          baseColor: const Color.fromRGBO(50, 50, 50, 1),
                          trailing: const Icon(
                            Icons.arrow_drop_down_rounded,
                            color: Color.fromRGBO(205, 205, 205, 1),
                          ),
                          expandedTextColor:
                              const Color.fromRGBO(205, 205, 205, 1),
                          leading: SizedBox(
                            width: 100,
                            child: Text(
                              announcement.releaseDate.substring(0, 16),
                              textAlign: TextAlign.center,
                              style: Design().poppins(
                                size: 12,
                                fw: FontWeight.bold,
                                color: const Color.fromRGBO(205, 205, 205, 1),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                          title: Text(
                            announcement.title,
                            style: Design().poppins(
                              size: 14,
                              color: const Color.fromRGBO(205, 205, 205, 1),
                            ),
                          ),
                          //! burayı builder olarak değil de provider ile yapcam unutma!
                          subtitle: announcement.facultyId == ""
                              ? Text(
                                  "Üniversite Duyurusu",
                                  style: Design().poppins(
                                    size: 13,
                                    color:
                                        const Color.fromRGBO(205, 205, 205, 1),
                                  ),
                                )
                              : FutureBuilder(
                                  future: UniversityService().getFacultyName(
                                    ref.watch(runiIdProvider).asData?.value ??
                                        " ",
                                    announcement.facultyId,
                                  ),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Container();
                                    }
                                    return Text(
                                      snapshot.data!,
                                      style: Design().poppins(
                                        color: const Color.fromRGBO(
                                            205, 205, 205, 1),
                                      ),
                                    );
                                  },
                                ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                announcement.content,
                                style: Design().poppins(
                                  size: 14,
                                  color: const Color.fromRGBO(205, 205, 205, 1),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
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
                      "Duyuru Paylaşılmadı",
                      style: Design().poppins(
                        size: 15,
                        color: const Color.fromRGBO(205, 205, 205, 1),
                      ),
                    ),
                  ),
          );
        }
      },
    );
  }
}

class HomeworkPageWidget extends ConsumerWidget {
  const HomeworkPageWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uniId = ref.watch(runiIdProvider).asData?.value ?? " ";
    final facultyId = ref.watch(rfacultyIdProvider).asData?.value ?? " ";
    final departmentId = ref.watch(rdepartmentIdProvider).asData?.value ?? " ";
    final studentId = ref.watch(rstudentIdProvider).asData?.value ?? " ";

    final size = MediaQuery.of(context).size;
    return FutureBuilder<Homework>(
        future: UniversityService().getHomeworkDetails(
            uniId,
            facultyId,
            departmentId,
            ref.watch(courseIdProvider),
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
            return ListView(
              children: [
                Container(
                  height: 55,
                  padding: const EdgeInsets.only(left: 50, right: 20),
                  alignment: Alignment.center,
                  color: Colors.white,
                  child: Row(
                    children: [
                      Text(
                        "Ödev" " \\ ",
                        style: Design().poppins(
                          color: Colors.grey.shade800,
                          fw: FontWeight.bold,
                          size: 14,
                        ),
                      ),
                      Text(
                        homework.title,
                        style: Design().poppins(
                          color: Colors.grey.shade800,
                          size: 13,
                        ),
                      ),
                      const Spacer(),
                      Transform.scale(
                        scale: 0.8,
                        child: IconButton(
                          onPressed: () {
                            ref.read(leftStudentPageProvider.notifier).state =
                                0;
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
                SizedBox(
                  height: size.width > 1300 ? 400 : 850,
                  child: size.width > 1300
                      ? Row(
                          children: [
                            HomeworkTopLeftWidget(homework: homework),
                            HomeworkTopRightWidget(
                              homework: homework,
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            HomeworkTopLeftWidget(homework: homework),
                            HomeworkTopRightWidget(
                              homework: homework,
                            ),
                          ],
                        ),
                ),
                SizedBox(
                  height: size.width > 1300 ? 330 : 850,
                  child: size.width > 1300
                      ? const Row(
                          children: [
                            HomeworkMiddleLeftWidget(),
                            HomeworkMiddleRightWidget(),
                          ],
                        )
                      : const Column(
                          children: [
                            HomeworkMiddleLeftWidget(),
                            HomeworkMiddleRightWidget(),
                          ],
                        ),
                ),
                Container(
                  width: size.width > 1300 ? size.width - 565 : size.width - 65,
                  padding: const EdgeInsets.only(
                    left: 40,
                    top: 20,
                    bottom: 40,
                    right: 40,
                  ),
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        List<String> tempList = [];
                        List<String> tempList2 = [];

                        String date = DateTime.now().toString();

                        for (var file in ref.watch(homeworkFilesProvider)) {
                          String fileName = file.name;
                          Reference storageReference = FirebaseStorage.instance
                              .ref()
                              .child(
                                  'uploads/sendedhomeworks/${ref.watch(courseIdProvider)}/${homework.giventime}/$studentId/$fileName');
                          TaskSnapshot taskSnapshot = await storageReference
                              .putData(file.bytes!)
                              .whenComplete(() => null);
                          String url = await taskSnapshot.ref.getDownloadURL();

                          tempList.add(url);
                          tempList2.add(fileName);
                        }

                        UniversityService().sendHomework(
                            uniId,
                            facultyId,
                            departmentId,
                            ref.watch(courseIdProvider),
                            homework.id,
                            studentId,
                            homework.title,
                            tempList,
                            tempList2,
                            date);
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        backgroundColor: const Color.fromRGBO(246, 153, 92, 1),
                        foregroundColor:
                            const Color.fromARGB(255, 226, 229, 233),
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
        });
  }
}

class HomeworkTopLeftWidget extends ConsumerWidget {
  final Homework homework;
  const HomeworkTopLeftWidget({
    super.key,
    required this.homework,
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
          right: size.width > 1300 ? 20 : 40,
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
              Expanded(
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
                                  left: 20,
                                  right: 20,
                                  top: 10,
                                  bottom: 10,
                                ),
                                margin: const EdgeInsets.only(
                                  bottom: 20,
                                ),
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color:
                                      const Color.fromARGB(255, 226, 229, 233),
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
                                  left: 20,
                                  right: 20,
                                  top: 10,
                                  bottom: 10,
                                ),
                                margin: const EdgeInsets.only(
                                  bottom: 20,
                                ),
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color:
                                      const Color.fromARGB(255, 226, 229, 233),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeworkTopRightWidget extends ConsumerWidget {
  final Homework homework;
  const HomeworkTopRightWidget({super.key, required this.homework});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Flexible(
      flex: 3,
      child: Container(
        padding: EdgeInsets.only(
          left: size.width > 1300 ? 20 : 40,
          top: size.width > 1300 ? 40 : 20,
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
              homework.fileNames.isNotEmpty
                  ? Expanded(
                      child: ListView.builder(
                        itemCount: homework.fileNames.length,
                        itemBuilder: (context, index) {
                          var fileName = homework.fileNames[index];
                          return Card(
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
                              leading: const Icon(Icons.file_present_rounded),
                              title: Text(
                                fileName,
                                style: Design().poppins(
                                  color: Colors.grey.shade800,
                                  size: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              trailing: IconButton(
                                onPressed: () async {
                                  UniversityService()
                                      .downloadFile(homework.fileUrls[index]);
                                },
                                icon: const Icon(
                                  Icons.download,
                                  color: Color.fromRGBO(81, 130, 155, 1),
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
    );
  }
}

class HomeworkMiddleLeftWidget extends ConsumerWidget {
  const HomeworkMiddleLeftWidget({
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
          top: 20,
          bottom: 20,
          right: size.width > 1300 ? 20 : 40,
        ),
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
    );
  }
}

class HomeworkMiddleRightWidget extends ConsumerWidget {
  const HomeworkMiddleRightWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Flexible(
      flex: 4,
      child: Container(
        padding: EdgeInsets.only(
          left: size.width > 1300 ? 20 : 40,
          top: 20,
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
              TextButton.icon(
                onPressed: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(allowMultiple: true);

                  var list = ref.watch(homeworkFilesNameProvider);
                  var list2 = ref.watch(homeworkFilesProvider);

                  if (result != null) {
                    for (PlatformFile file in result.files) {
                      list.add(file.name);
                      list2.add(file);
                    }
                  }

                  // ignore: unused_result
                  ref.refresh(homeworkFilesNameProvider);
                  // ignore: unused_result
                  ref.refresh(homeworkFilesProvider);

                  ref.read(homeworkFilesProvider.notifier).state = list2;
                  ref.read(homeworkFilesNameProvider.notifier).state = list;
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
              ref.watch(homeworkFilesNameProvider).isNotEmpty
                  ? Expanded(
                      child: ListView.builder(
                        itemCount: ref.watch(homeworkFilesNameProvider).length,
                        itemBuilder: (context, index) {
                          var file =
                              ref.watch(homeworkFilesNameProvider)[index];
                          return Card(
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
                              leading: const Icon(Icons.file_present_rounded),
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
                                onPressed: () {
                                  var list =
                                      ref.watch(homeworkFilesNameProvider);
                                  var list2 = ref.watch(homeworkFilesProvider);

                                  list.removeAt(index);
                                  list2.removeAt(index);

                                  // ignore: unused_result
                                  ref.refresh(homeworkFilesNameProvider);
                                  // ignore: unused_result
                                  ref.refresh(homeworkFilesProvider);

                                  ref
                                      .read(homeworkFilesProvider.notifier)
                                      .state = list2;
                                  ref
                                      .read(homeworkFilesNameProvider.notifier)
                                      .state = list;
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
      ),
    );
  }
}

showCommentDialog({
  required BuildContext context,
  required String text,
}) {
  showAdaptiveDialog(
    barrierColor: Colors.black26,
    builder: (context) {
      return Center(
        child: Transform.scale(
          scale: 0.9,
          child: Container(
            width: 480,
            height: 500,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 30, bottom: 20),
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
                  height: 250,
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
                  padding: const EdgeInsets.only(top: 30, bottom: 20),
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
