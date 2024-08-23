// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:projectacademy/Pages/hub/studentpanel/homepage.dart';
import 'package:projectacademy/Pages/hub/uniadminpanel/announcementPage.dart';
import 'package:projectacademy/Pages/hub/uniadminpanel/studentPage.dart';
import 'package:projectacademy/firebaseConfig/firebase_transactionss.dart';
import 'package:projectacademy/myDesign.dart';

final rigthPanelProvider = StateProvider((ref) => 0);
final rigthMenuStyleProvider = StateProvider((ref) => 0);
final leftPageChangeProvider = StateProvider((ref) => 0);
final facultyName = StateProvider((ref) => "");
final departmentIdProvider = StateProvider((ref) => "");
final annoTitleProvider = StateProvider((ref) => "");
final annoContentProvider = StateProvider((ref) => "");
final noteContentProvider = StateProvider((ref) => "");
final departmentNameProvider = StateProvider((ref) => "");
final facultyIdProvider = StateProvider((ref) => " ");
final facultyNameProvider = StateProvider((ref) => "");
final facultyIndexProvider = StateProvider((ref) => 0);
final courseNameProvider = StateProvider((ref) => "");
final selectedInstructorProvider = StateProvider((ref) => 0);
final selectedInstructorIdProvider = StateProvider((ref) => "");
final vProvider = StateProvider((ref) => 0);

final facultySearchProvider = StateProvider((ref) => "");

final textProvider = StateProvider((ref) => " ");

final totalStudentsCountProvider = StreamProvider<int>((ref) =>
    UniversityService().getStudentsCountInFaculty(ref.watch(facultyIdProvider),
        ref.watch(userPhotoUrlProvider).asData?.value ?? ""));

final totalDepartmentCountProvider = StreamProvider<int>((ref) =>
    UniversityService().getDepartmentCountInFaculty(
        ref.watch(facultyIdProvider),
        ref.watch(userPhotoUrlProvider).asData?.value ?? ""));

final totalinstructorCountProvider = StreamProvider<int>((ref) =>
    UniversityService().getInstructorCountInFaculty(
        ref.watch(facultyIdProvider),
        ref.watch(userPhotoUrlProvider).asData?.value ?? ""));

final departmentStudentsCountProvider = StreamProvider<int>((ref) {
  final universityId = ref.watch(userPhotoUrlProvider).asData?.value ?? "";
  final facultyId = ref.watch(facultyIdProvider);
  final departmentId = ref.watch(departmentIdProvider);

  return UniversityService()
      .getStudentsCountInDepartment(universityId, facultyId, departmentId);
});

final departmentInstructorsCountProvider = StreamProvider<int>((ref) {
  final universityId = ref.watch(userPhotoUrlProvider).asData?.value ?? "";
  final facultyId = ref.watch(facultyIdProvider);
  final departmentId = ref.watch(departmentIdProvider);

  return UniversityService()
      .getInstructorsCountInDepartment(universityId, facultyId, departmentId);
});

TextEditingController _textEditingController = TextEditingController();
TextEditingController _textEditingController2 = TextEditingController();

bool n = true;

void getFacultyId(String uniId, WidgetRef ref) {
  final firestore = FirebaseFirestore.instance;

  firestore.collection('universities').doc(uniId).get().then((universityDoc) {
    if (universityDoc.exists) {
      universityDoc.reference
          .collection('faculties')
          .get()
          .then((facultiesSnapshot) {
        if (facultiesSnapshot.docs.isNotEmpty) {
          ref.read(facultyIdProvider.notifier).state =
              facultiesSnapshot.docs.first.id;
          ref.read(facultyNameProvider.notifier).state =
              facultiesSnapshot.docs.first["name"];
          n = false;
        }
      }).catchError((e) {});
    }
  }).catchError((e) {});
}

class HomePageWidget extends ConsumerWidget {
  const HomePageWidget({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (n == true) {
      getFacultyId(ref.watch(userPhotoUrlProvider).asData?.value ?? " ", ref);
    }
    return Stack(
      children: [
        AnimatedSwitcher(
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          duration: const Duration(milliseconds: 500),
          child: ref.watch(leftPageChangeProvider) == 0
              ? LeftPageWidget(size: size)
              : const DepartmentPageWidget(),
        ),
        size.width > 1300
            ? const Align(
                alignment: Alignment.centerRight,
                child: RightPanelWidget(),
              )
            : Container(),
      ],
    );
  }
}

//! SOL TARAF

class LeftPageWidget extends ConsumerWidget {
  const LeftPageWidget({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uniId = ref.watch(userPhotoUrlProvider).asData?.value ?? " ";
    final facultyStream = UniversityService().getFacultiesAsStream(uniId);
    return Container(
      margin: EdgeInsets.only(left: 65, right: size.width > 1300 ? 56 : 0),
      child: StreamBuilder<List<Faculty>>(
        stream: facultyStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SpinKitPulse(color: Colors.white, size: 50),
            );
          }

          return snapshot.data!.isNotEmpty
              ? ListView(
                  children: [
                    const TopWidget(),
                    size.width > 1300
                        ? const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  LeftTopWidget(),
                                  LeftBottomWidget(),
                                ],
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  RightTopWidget(),
                                  RightBottomWidget(),
                                ],
                              ),
                            ],
                          )
                        : const Column(
                            children: [
                              LeftTopWidget(),
                              LeftBottomWidget(),
                              RightTopWidget(),
                              RightBottomWidget(),
                            ],
                          ),
                  ],
                )
              : Center(
                  child: Container(
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
                            """Fakülte bulunamadı. Sağ tarafta bulunan açılır pencere"""
                            """\nüzerinden fakülte oluşturabilirsiniz.""",
                            style: Design().poppins(size: 15),
                            textAlign: TextAlign.center,
                          ),
                          const Spacer(flex: 4),
                        ],
                      ),
                    ),
                  ),
                );
        },
      ),
    );
  }
}

class TopWidget extends ConsumerWidget {
  const TopWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 50,
      color: Colors.white,
      alignment: Alignment.center,
      padding: const EdgeInsets.only(left: 50, right: 20),
      child: Row(
        children: [
          Expanded(
            child: Transform.scale(
              scale: 0.7,
              child: TextFormField(
                style: Design().poppins(
                  color: Colors.grey.shade800,
                  fw: FontWeight.w600,
                  size: 18,
                ),
                cursorColor: const Color.fromRGBO(35, 35, 35, 1),
                cursorWidth: 2,
                controller: _textEditingController,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintStyle: Design().poppins(
                    color: Colors.grey.shade800,
                    fw: FontWeight.w600,
                    size: 18,
                  ),
                  hintText: ref.watch(facultyNameProvider) ?? "",
                  fillColor: const Color.fromARGB(255, 226, 229, 233),
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 226, 229, 233),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 226, 229, 233),
                    ),
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: IconButton(
                      onPressed: () async {
                        if (_textEditingController.text.isNotEmpty) {
                          String universityId =
                              ref.watch(userPhotoUrlProvider).asData!.value;
                          String facultyId = ref.watch(facultyIdProvider);

                          DocumentReference<Map<String, dynamic>> facultyRef =
                              FirebaseFirestore.instance
                                  .collection('universities')
                                  .doc(universityId)
                                  .collection('faculties')
                                  .doc(facultyId);

                          await facultyRef.update({
                            'name': _textEditingController.text,
                          });

                          ref.read(facultyNameProvider.notifier).state =
                              _textEditingController.text;

                          _textEditingController.clear();
                        }
                      },
                      style: IconButton.styleFrom(
                          hoverColor: const Color.fromARGB(255, 196, 198, 202)),
                      icon: const Icon(
                        Icons.check,
                        color: Color.fromRGBO(35, 35, 35, 1),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: IconButton(
              onPressed: () {
                showTextDialog(
                  context: context,
                  color: const Color.fromRGBO(211, 118, 118, 1),
                  ref: ref,
                  icon: Icons.delete_forever,
                  buttonText: "Fakülteyi Sil",
                  centerText: """Kabul ederseniz fakülte içinde bulunan """
                      """tüm bölüm ve dersler silinir ancak öğrenci """
                      """ve akademisyenler tekrardan bir fakülte """
                      """ve bölüme atanabilir.""",
                  tittleText: "Silmek istediğinize emin misiniz?",
                  buttonFunc: () {
                    Navigator.pop(context);
                    String universityId =
                        ref.watch(userPhotoUrlProvider).asData!.value;
                    String facultyId = ref.watch(facultyIdProvider);

                    CollectionReference universitiesCollection =
                        FirebaseFirestore.instance.collection('universities');

                    universitiesCollection
                        .doc(universityId)
                        .collection('faculties')
                        .doc(facultyId)
                        .delete()
                        .then((value) => getFacultyId(universityId, ref));

                    UniversityService().deleteAnnouncementFor(
                        ref.watch(userPhotoUrlProvider).asData!.value,
                        facultyId);

                    showSnackBarWidget(context, "Fakülte başarıyla silindi..!");
                  },
                );
              },
              icon: const Icon(
                Icons.delete,
                color: Color.fromRGBO(211, 118, 118, 1),
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
          )
        ],
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
        top: size.width > 1300 ? 40 : 20,
        bottom: 20,
        left: size.width > 1300 ? 40 : 0,
        right: size.width > 1300 ? 20 : 0,
      ),
      width: size.width > 1300 ? (size.width - 121) / 2 : size.width - 121,
      height: 200,
      child: Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            LeftTopContainerWidget(
              size: size,
              topText: ref
                      .watch(totalDepartmentCountProvider)
                      .asData
                      ?.value
                      .toString() ??
                  "",
              bottomText: "Bölüm",
              color: const Color.fromRGBO(81, 130, 155, 1),
            ),
            LeftTopContainerWidget(
              size: size,
              topText: ref
                      .watch(totalStudentsCountProvider)
                      .asData
                      ?.value
                      .toString() ??
                  "",
              bottomText: "Öğrenci",
              color: const Color.fromRGBO(246, 153, 92, 1),
            ),
            LeftTopContainerWidget(
              size: size,
              topText: ref
                      .watch(totalinstructorCountProvider)
                      .asData
                      ?.value
                      .toString() ??
                  "",
              bottomText: "Akademisyen",
              color: const Color.fromRGBO(211, 118, 118, 1),
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
        top: 20,
        bottom: size.width > 1300 ? 40 : 20,
        left: size.width > 1300 ? 40 : 0,
        right: size.width > 1300 ? 20 : 0,
      ),
      width: size.width > 1300 ? (size.width - 121) / 2 : size.width - 121,
      height: 700,
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
                "Bölümler",
                style: Design().poppins(
                  size: 16,
                  fw: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Department>>(
                stream: UniversityService().getFacultyDepartmentsAsStream(
                  ref.watch(userPhotoUrlProvider).asData?.value ?? " ",
                  ref.watch(facultyIdProvider),
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text("Veri yüklenirken bir hata oluştu."),
                    );
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: SpinKitPulse(color: Colors.white, size: 250),
                    );
                  }
                  var departments = snapshot.data ?? [];

                  return departments.isNotEmpty
                      ? ListView.builder(
                          itemCount: departments.length,
                          itemBuilder: (context, index) {
                            var depName = departments[index].name;
                            var depId = departments[index].id;
                            return Card(
                              margin: const EdgeInsets.all(0),
                              shadowColor: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.only(
                                  topRight: index == 0
                                      ? const Radius.circular(8)
                                      : const Radius.circular(0),
                                  topLeft: index == 0
                                      ? const Radius.circular(8)
                                      : const Radius.circular(0),
                                  bottomRight: index == departments.length - 1
                                      ? const Radius.circular(8)
                                      : const Radius.circular(0),
                                  bottomLeft: index == departments.length - 1
                                      ? const Radius.circular(8)
                                      : const Radius.circular(0),
                                ),
                                onTap: () {
                                  ref
                                      .read(leftPageChangeProvider.notifier)
                                      .state = 1;
                                  ref
                                      .read(departmentNameProvider.notifier)
                                      .state = depName;
                                  ref
                                      .read(departmentIdProvider.notifier)
                                      .state = depId;
                                },
                                hoverColor:
                                    const Color.fromARGB(255, 211, 211, 211),
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topRight: index == 0
                                          ? const Radius.circular(8)
                                          : const Radius.circular(0),
                                      topLeft: index == 0
                                          ? const Radius.circular(8)
                                          : const Radius.circular(0),
                                      bottomRight:
                                          index == departments.length - 1
                                              ? const Radius.circular(8)
                                              : const Radius.circular(0),
                                      bottomLeft:
                                          index == departments.length - 1
                                              ? const Radius.circular(8)
                                              : const Radius.circular(0),
                                    ),
                                  ),
                                  tileColor:
                                      const Color.fromARGB(255, 226, 229, 233),
                                  contentPadding: const EdgeInsets.only(
                                    left: 25,
                                    right: 25,
                                  ),
                                  subtitle: Row(
                                    children: [
                                      Text(
                                        "0",
                                        style: Design().poppins(
                                          size: 14,
                                          color: const Color.fromRGBO(
                                              246, 153, 92, 1),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Icon(
                                        Icons.groups_rounded,
                                        color: Color.fromRGBO(246, 153, 92, 1),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 30),
                                      Text(
                                        "0",
                                        style: Design().poppins(
                                          size: 14,
                                          color: const Color.fromRGBO(
                                              211, 118, 118, 1),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Icon(
                                        Icons.book,
                                        color: Color.fromRGBO(211, 118, 118, 1),
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                  title: Text(
                                    depName,
                                    style: Design().poppins(size: 15),
                                  ),
                                  trailing: IconButton(
                                    onPressed: () {
                                      showTextDialog(
                                        context: context,
                                        color: const Color.fromRGBO(
                                            211, 118, 118, 1),
                                        ref: ref,
                                        icon: Icons.delete_forever,
                                        buttonText: "Bölümü Sil",
                                        centerText:
                                            """Bölüm içinde bulunan tüm """
                                            """dersler silinir ancak öğrenci """
                                            """ve ders veren akademisyenler """
                                            """tekrardan bir  bölüme atanabilir.""",
                                        tittleText:
                                            "Silmek istediğinize emin misiniz?",
                                        buttonFunc: () {
                                          ref
                                              .read(
                                                  departmentIdProvider.notifier)
                                              .state = depId;
                                          String universityId = ref
                                              .watch(userPhotoUrlProvider)
                                              .asData!
                                              .value;
                                          String facultyId =
                                              ref.watch(facultyIdProvider);
                                          String departmentId =
                                              ref.watch(departmentIdProvider);

                                          CollectionReference
                                              universitiesCollection =
                                              FirebaseFirestore.instance
                                                  .collection('universities');

                                          universitiesCollection
                                              .doc(universityId)
                                              .collection('faculties')
                                              .doc(facultyId)
                                              .collection("departments")
                                              .doc(departmentId)
                                              .delete();
                                        },
                                      );
                                    },
                                    icon: Icon(
                                      Icons.folder_delete,
                                      color: Colors.grey.shade800,
                                    ),
                                    style: IconButton.styleFrom(
                                      hoverColor: const Color.fromARGB(
                                          255, 196, 198, 202),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          padding: const EdgeInsets.all(20),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 226, 229, 233),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Bölüm Eklenmedi",
                              style: Design().poppins(
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RightTopWidget extends ConsumerWidget {
  const RightTopWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(
        bottom: 20,
        top: size.width > 1300 ? 40 : 20,
        left: size.width > 1300 ? 20 : 0,
        right: size.width > 1300 ? 40 : 0,
      ),
      width: size.width > 1300 ? (size.width - 121) / 2 : size.width - 121,
      height: size.width > 1300 ? 600 : 500,
      child: Container(
        padding: const EdgeInsets.all(20),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: StreamBuilder<List<Announcement>>(
            stream: UniversityService().getFacultyAnnouncementsStream(
                ref.watch(userPhotoUrlProvider).asData!.value,
                ref.watch(facultyIdProvider)),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text("Veri yüklenirken bir hata oluştu."),
                );
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: SpinKitPulse(color: Colors.white, size: 250),
                );
              }
              var announcements = snapshot.data!;
              return announcements.isNotEmpty
                  ? Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Fakülte Duyuruları",
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
                              var announcement = announcements[index];
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
                                        Navigator.of(context).pop();
                                        UniversityService().deleteAnnouncement(
                                            ref
                                                .watch(userPhotoUrlProvider)
                                                .asData!
                                                .value,
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
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  : Container(
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
            }),
      ),
    );
  }
}

class RightBottomWidget extends ConsumerWidget {
  const RightBottomWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(
        bottom: size.width > 1300 ? 40 : 20,
        top: 20,
        left: size.width > 1300 ? 20 : 0,
        right: size.width > 1300 ? 40 : 0,
      ),
      width: size.width > 1300 ? (size.width - 121) / 2 : size.width - 121,
      height: size.width > 1300 ? 300 : 400,
      child: size.width > 1300
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            height: 80,
                            width: 200,
                            child: ElevatedButton(
                              onPressed: () {
                                showSurveyDialog(
                                  context: context,
                                  ref: ref,
                                  buttonText: "Paylaş",
                                  tittleText: "Fakülte Duyurusu",
                                  children: Material(
                                    color: Colors.white,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        DialogTFFWidget(
                                          provider: annoTitleProvider,
                                          text: "Başlık",
                                        ),
                                        const SizedBox(height: 20),
                                        TextFormField(
                                          onChanged: (value) => ref
                                              .read(
                                                  annoContentProvider.notifier)
                                              .state = value,
                                          style: Design().poppins(
                                            size: 15,
                                            color: Colors.grey.shade800,
                                          ),
                                          cursorColor: Colors.grey.shade800,
                                          cursorWidth: 2,
                                          cursorRadius:
                                              const Radius.circular(25),
                                          minLines: 10,
                                          maxLines: 20,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.only(
                                              left: 30,
                                              right: 30,
                                              top: 40,
                                            ),
                                            hintText: "Gövde",
                                            hintStyle: Design().poppins(
                                              size: 14,
                                              color: Colors.grey.shade800,
                                            ),
                                            fillColor: const Color.fromARGB(
                                                255, 226, 229, 233),
                                            filled: true,
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: Color.fromARGB(
                                                    255, 226, 229, 233),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: Color.fromARGB(
                                                    255, 226, 229, 233),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  buttonFunc: () {
                                    ref.read(isPublicProvider.notifier).state =
                                        0;
                                    Navigator.of(context).pop();
                                    if (ref
                                            .watch(annoContentProvider)
                                            .isNotEmpty &&
                                        ref
                                            .watch(annoTitleProvider)
                                            .isNotEmpty) {
                                      UniversityService().addAnnouncement(
                                          ref
                                              .watch(userPhotoUrlProvider)
                                              .asData!
                                              .value,
                                          ref.watch(facultyIdProvider),
                                          ref.watch(annoContentProvider),
                                          ref.watch(annoTitleProvider));
                                    }
                                  },
                                );
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
                                backgroundColor:
                                    const Color.fromRGBO(211, 118, 118, 1),
                                foregroundColor:
                                    const Color.fromARGB(255, 226, 229, 233),
                              ),
                              child: Text(
                                "Fakülte Duyurusu\nEkle",
                                style: Design().poppins(
                                  color: Colors.white,
                                  size: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            height: 50,
                            width: 200,
                            child: ElevatedButton(
                              onPressed: () {
                                showSurveyDialog(
                                  context: context,
                                  ref: ref,
                                  buttonText: "Oluştur",
                                  tittleText: "Bölüm Ekle",
                                  children: Material(
                                    color: Colors.white,
                                    child: DialogTFFWidget(
                                      provider: departmentNameProvider,
                                      text: "Bölüm adı",
                                    ),
                                  ),
                                  buttonFunc: () {
                                    Navigator.of(context).pop();
                                    if (ref
                                        .watch(departmentNameProvider)
                                        .isNotEmpty) {
                                      final String uniID = ref
                                          .watch(userPhotoUrlProvider)
                                          .asData!
                                          .value;
                                      final String facultyId =
                                          ref.watch(facultyIdProvider);

                                      UniversityService().addDepartment(
                                          uniID,
                                          facultyId,
                                          ref.watch(departmentNameProvider));
                                    }
                                  },
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.only(
                                  top: 20,
                                  bottom: 20,
                                  left: 44,
                                  right: 44,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: const BorderSide(
                                    color: Colors.white,
                                    width: 4,
                                    strokeAlign: BorderSide.strokeAlignOutside,
                                  ),
                                ),
                                backgroundColor:
                                    const Color.fromRGBO(246, 153, 92, 1),
                                foregroundColor:
                                    const Color.fromARGB(255, 226, 229, 233),
                              ),
                              child: Text(
                                "Bölüm Ekle",
                                style: Design().poppins(
                                  color: Colors.white,
                                  size: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Flexible(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(left: 20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color.fromRGBO(35, 35, 35, 1),
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
                                "Not",
                                style: Design().poppins(
                                  size: 16,
                                  fw: FontWeight.w600,
                                  color: const Color.fromRGBO(205, 205, 205, 1),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                showSurveyDialog(
                                  context: context,
                                  ref: ref,
                                  buttonText: "Kaydet",
                                  tittleText: "Düzenle",
                                  children: Material(
                                    color: Colors.white,
                                    child: TextFormField(
                                      onChanged: (value) => ref
                                          .read(noteContentProvider.notifier)
                                          .state = value,
                                      style: Design().poppins(
                                        size: 15,
                                        color: Colors.grey.shade800,
                                      ),
                                      cursorColor: Colors.grey.shade800,
                                      cursorWidth: 2,
                                      cursorRadius: const Radius.circular(25),
                                      minLines: 10,
                                      maxLines: 20,
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(
                                          left: 30,
                                          right: 30,
                                          top: 40,
                                        ),
                                        hintText: "Gövde",
                                        hintStyle: Design().poppins(
                                          size: 14,
                                          color: Colors.grey.shade800,
                                        ),
                                        fillColor: const Color.fromARGB(
                                            255, 226, 229, 233),
                                        filled: true,
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                            color: Color.fromARGB(
                                                255, 226, 229, 233),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                            color: Color.fromARGB(
                                                255, 226, 229, 233),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  buttonFunc: () {},
                                );
                              },
                              style: IconButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                foregroundColor: Colors.grey.shade400,
                              ),
                              icon: const Icon(
                                Icons.edit_note_rounded,
                                color: Color.fromRGBO(205, 205, 205, 1),
                              ),
                            )
                          ],
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              showCommentDialog(
                                context: context,
                                text: ref.watch(noteContentProvider),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.only(
                                left: 20,
                                right: 20,
                                top: 10,
                                bottom: 10,
                              ),
                              margin:
                                  const EdgeInsets.only(bottom: 10, top: 10),
                              width: double.infinity,
                              height: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: const Color.fromRGBO(50, 50, 50, 1),
                              ),
                              child: Text(
                                ref.watch(noteContentProvider),
                                style: Design().poppins(
                                  size: 14,
                                  color: const Color.fromRGBO(205, 205, 205, 1),
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : Column(
              children: [
                Flexible(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color.fromRGBO(35, 35, 35, 1),
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
                                "Not",
                                style: Design().poppins(
                                  size: 16,
                                  fw: FontWeight.w600,
                                  color: const Color.fromRGBO(205, 205, 205, 1),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                showSurveyDialog(
                                  context: context,
                                  ref: ref,
                                  buttonText: "Kaydet",
                                  tittleText: "Düzenle",
                                  children: Material(
                                    color: Colors.white,
                                    child: TextFormField(
                                      onChanged: (value) => ref
                                          .read(annoContentProvider.notifier)
                                          .state = value,
                                      style: Design().poppins(
                                        size: 15,
                                        color: Colors.grey.shade800,
                                      ),
                                      cursorColor: Colors.grey.shade800,
                                      cursorWidth: 2,
                                      cursorRadius: const Radius.circular(25),
                                      minLines: 10,
                                      maxLines: 20,
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.only(
                                          left: 30,
                                          right: 30,
                                          top: 40,
                                        ),
                                        hintText: "Gövde",
                                        hintStyle: Design().poppins(
                                          size: 14,
                                          color: Colors.grey.shade800,
                                        ),
                                        fillColor: const Color.fromARGB(
                                            255, 226, 229, 233),
                                        filled: true,
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                            color: Color.fromARGB(
                                                255, 226, 229, 233),
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: const BorderSide(
                                            color: Color.fromARGB(
                                                255, 226, 229, 233),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  buttonFunc: () {},
                                );
                              },
                              style: IconButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                foregroundColor: Colors.grey.shade400,
                              ),
                              icon: const Icon(
                                Icons.edit_note_rounded,
                                color: Color.fromRGBO(205, 205, 205, 1),
                              ),
                            )
                          ],
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              showCommentDialog(
                                context: context,
                                text: ref.watch(noteContentProvider),
                              );
                            },
                            child: Container(
                              padding:
                                  const EdgeInsets.only(left: 20, right: 20),
                              margin:
                                  const EdgeInsets.only(bottom: 10, top: 10),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: const Color.fromRGBO(50, 50, 50, 1),
                              ),
                              child: Text(
                                ref.watch(noteContentProvider),
                                style: Design().poppins(
                                  size: 14,
                                  color: const Color.fromRGBO(205, 205, 205, 1),
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            height: 80,
                            width: 180,
                            child: ElevatedButton(
                              onPressed: () {
                                showSurveyDialog(
                                  context: context,
                                  ref: ref,
                                  buttonText: "Paylaş",
                                  tittleText: "Fakülte Duyurusu",
                                  children: Material(
                                    color: Colors.white,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        DialogTFFWidget(
                                          provider: annoTitleProvider,
                                          text: "Başlık",
                                        ),
                                        const SizedBox(height: 20),
                                        TextFormField(
                                          onChanged: (value) => ref
                                              .read(
                                                  annoContentProvider.notifier)
                                              .state = value,
                                          style: Design().poppins(
                                            size: 15,
                                            color: Colors.grey.shade800,
                                          ),
                                          cursorColor: Colors.grey.shade800,
                                          cursorWidth: 2,
                                          cursorRadius:
                                              const Radius.circular(25),
                                          minLines: 10,
                                          maxLines: 20,
                                          decoration: InputDecoration(
                                            contentPadding:
                                                const EdgeInsets.only(
                                              left: 30,
                                              right: 30,
                                              top: 40,
                                            ),
                                            hintText: "Gövde",
                                            hintStyle: Design().poppins(
                                              size: 14,
                                              color: Colors.grey.shade800,
                                            ),
                                            fillColor: const Color.fromARGB(
                                                255, 226, 229, 233),
                                            filled: true,
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: Color.fromARGB(
                                                    255, 226, 229, 233),
                                              ),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: const BorderSide(
                                                color: Color.fromARGB(
                                                    255, 226, 229, 233),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  buttonFunc: () {
                                    ref.read(isPublicProvider.notifier).state =
                                        0;
                                    Navigator.of(context).pop();
                                    if (ref
                                            .watch(annoContentProvider)
                                            .isNotEmpty &&
                                        ref
                                            .watch(annoTitleProvider)
                                            .isNotEmpty) {
                                      UniversityService().addAnnouncement(
                                          ref
                                              .watch(userPhotoUrlProvider)
                                              .asData!
                                              .value,
                                          ref.watch(facultyIdProvider),
                                          ref.watch(annoContentProvider),
                                          ref.watch(annoTitleProvider));
                                    }
                                    showSnackBarWidget(
                                        context, "Duyuru başarıyla eklendi..!");
                                  },
                                );
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
                                backgroundColor:
                                    const Color.fromRGBO(211, 118, 118, 1),
                                foregroundColor:
                                    const Color.fromARGB(255, 226, 229, 233),
                              ),
                              child: Text(
                                "Fakülte Duyurusu\nEkle",
                                style: Design().poppins(
                                  color: Colors.white,
                                  size: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Flexible(
                        child: Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            height: 50,
                            width: 180,
                            child: ElevatedButton(
                              onPressed: () {
                                showSurveyDialog(
                                  context: context,
                                  ref: ref,
                                  buttonText: "Oluştur",
                                  tittleText: "Bölüm Ekle",
                                  children: Material(
                                    color: Colors.white,
                                    child: DialogTFFWidget(
                                      provider: departmentNameProvider,
                                      text: "Bölüm adı",
                                    ),
                                  ),
                                  buttonFunc: () {
                                    Navigator.of(context).pop();
                                    if (ref
                                        .watch(departmentNameProvider)
                                        .isNotEmpty) {
                                      final String uniID = ref
                                          .watch(userPhotoUrlProvider)
                                          .asData!
                                          .value;
                                      final String facultyId =
                                          ref.watch(facultyIdProvider);

                                      UniversityService().addDepartment(
                                          uniID,
                                          facultyId,
                                          ref.watch(departmentNameProvider));
                                    }
                                    showSnackBarWidget(context,
                                        "Bölüm başarıyla oluşturuldu..!");
                                  },
                                );
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
                                backgroundColor:
                                    const Color.fromRGBO(246, 153, 92, 1),
                                foregroundColor:
                                    const Color.fromARGB(255, 226, 229, 233),
                              ),
                              child: Text(
                                "Bölüm Ekle",
                                style: Design().poppins(
                                  color: Colors.white,
                                  size: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// ignore: must_be_immutable
class LeftTopContainerWidget extends ConsumerWidget {
  LeftTopContainerWidget({
    super.key,
    required this.size,
    required this.topText,
    required this.bottomText,
    required this.color,
  });

  final Size size;
  String topText;
  String bottomText;
  Color color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Flexible(
      flex: 10,
      child: SizedBox(
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                topText,
                style: Design().poppins(
                  size: 30,
                  fw: FontWeight.bold,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Center(
              child: Text(
                bottomText,
                style: Design().poppins(
                  fw: FontWeight.normal,
                  size: 20,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//! SAG PANEL

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
      crossFadeState: ref.watch(rigthPanelProvider) == 1
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
            ref.watch(rigthPanelProvider) == 1
                ? Container(
                    margin: const EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        CostomSearchBarWidget(
                          function: (String text) {
                            ref.read(facultySearchProvider.notifier).state =
                                text;
                          },
                          hintText: "Fakülte Ara",
                        ),
                        const AddFacultyButtonWidget(),
                      ],
                    ),
                  )
                : const SizedBox(),
            const SizedBox(height: 20),
            ref.watch(rigthPanelProvider) == 1
                ? const FacultyListWidget()
                : Container(),
            const SizedBox(height: 10),
            ref.watch(rigthPanelProvider) == 1
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

class FacultyListWidget extends ConsumerWidget {
  const FacultyListWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uniId = ref.watch(userPhotoUrlProvider).asData?.value ?? " ";
    final facultyStream = UniversityService()
        .getFaculties(uniId, ref.watch(facultySearchProvider));

    return Expanded(
      child: StreamBuilder<List<Faculty>>(
        stream: facultyStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Container();
          }
          if (!snapshot.hasData) {
            return Container();
          }
          final List<Faculty> facultyData = snapshot.data ?? [];

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: facultyData.isEmpty
                ? const SizedBox()
                : ref.watch(rigthMenuStyleProvider) == 0
                    ? Container(
                        key: UniqueKey(),
                        child: GridView.builder(
                          itemCount: facultyData.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                          ),
                          itemBuilder: (context, index) {
                            final faculty = facultyData[index];
                            return GridViewContainerWidget(
                              faculty: faculty,
                              index: index,
                            );
                          },
                        ),
                      )
                    : Container(
                        key: UniqueKey(),
                        child: GridView.builder(
                          itemCount: facultyData.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 1,
                            childAspectRatio: 2.5,
                          ),
                          itemBuilder: (context, index) {
                            final faculty = facultyData[index];
                            return GridViewContainerWidget(
                              faculty: faculty,
                              index: index,
                            );
                          },
                        ),
                      ),
          );
        },
      ),
    );
  }
}

class AddFacultyButtonWidget extends ConsumerWidget {
  const AddFacultyButtonWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Transform.scale(
      scale: 0.92,
      child: Container(
        padding: const EdgeInsets.only(left: 20),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(24),
            backgroundColor: const Color.fromRGBO(81, 130, 155, 1),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            showSurveyDialog(
              context: context,
              ref: ref,
              buttonText: "Oluştur",
              tittleText: "Fakülte Ekle",
              children: Material(
                color: Colors.white,
                child: DialogTFFWidget(
                  provider: facultyName,
                  text: "Fakülte adı",
                ),
              ),
              buttonFunc: () {
                Navigator.of(context).pop();
                if (ref.watch(facultyName).isNotEmpty) {
                  final uniId = ref.watch(userPhotoUrlProvider).asData!.value;
                  final faculId = ref.watch(facultyName);

                  UniversityService().addFaculty(uniId, faculId);

                  getFacultyId(uniId, ref);

                  showSnackBarWidget(context, "Fakülte başarıyla eklendi..!");
                }
              },
            );
          },
          label: Text(
            "Fakülte Ekle",
            maxLines: 1,
            style: Design().poppins(
              size: size.width * 0.008,
              color: Colors.white,
            ),
          ),
          icon: const Icon(
            Icons.add_to_photos_rounded,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class CostomSearchBarWidget extends ConsumerWidget {
  CostomSearchBarWidget({
    super.key,
    required this.function,
    required this.hintText,
    this.color = 0,
  });

  String hintText;
  Function(String) function;
  int color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Flexible(
      flex: 2,
      child: Transform.scale(
        scale: 0.915,
        child: SearchBar(
          onChanged: function,
          shape: MaterialStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          shadowColor: const MaterialStatePropertyAll(
            Colors.transparent,
          ),
          backgroundColor: MaterialStatePropertyAll(
            color == 0
                ? const Color.fromARGB(221, 29, 29, 29)
                : const Color.fromARGB(255, 226, 229, 233),
          ),
          overlayColor: MaterialStatePropertyAll(
            color == 0
                ? const Color.fromARGB(221, 29, 29, 29)
                : const Color.fromARGB(255, 226, 229, 233),
          ),
          surfaceTintColor: MaterialStatePropertyAll(
            Design().grey,
          ),
          hintText: hintText,
          hintStyle: MaterialStatePropertyAll(
            Design().poppins(
              size: 16,
              color: color == 0 ? Colors.white : Colors.grey.shade800,
              fw: FontWeight.w500,
            ),
          ),
          textStyle: MaterialStatePropertyAll(
            Design().poppins(
              size: 16,
              color: color == 0 ? Colors.white : Colors.grey.shade800,
              fw: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class GridViewContainerWidget extends ConsumerWidget {
  final Faculty faculty;
  final int index;

  const GridViewContainerWidget({
    super.key,
    required this.faculty,
    required this.index,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Transform.scale(
      scale: 0.93,
      child: Card(
        color: ref.watch(facultyIdProvider) == faculty.id
            ? const Color.fromRGBO(211, 118, 118, 1)
            : const Color.fromRGBO(50, 50, 50, 1),
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            ref.read(facultyIdProvider.notifier).state = faculty.id;
            ref.read(facultyNameProvider.notifier).state = faculty.name;
            ref.read(leftPageChangeProvider.notifier).state = 0;
          },
          splashColor: const Color.fromRGBO(211, 118, 118, 1),
          child: ListTile(
            contentPadding: const EdgeInsets.all(20),
            title: Text(
              faculty.name,
              style: Design().poppins(
                size: 18,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            subtitleTextStyle: Design().poppins(color: Colors.white, size: 15),
            subtitle: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  "0 Bölüm",
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
                  "0 Akademisyen",
                  style: Design().poppins(
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
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
          ref.watch(rigthPanelProvider.notifier).state =
              ref.watch(rigthPanelProvider) == 0 ? 1 : 0;
        },
        style: IconButton.styleFrom(
          backgroundColor: const Color.fromRGBO(55, 55, 55, 1),
          hoverColor: const Color.fromRGBO(75, 75, 75, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(55),
          ),
        ),
        icon: Icon(
          ref.watch(rigthPanelProvider) == 1
              ? Icons.arrow_right
              : Icons.arrow_left,
          color: const Color.fromRGBO(244, 246, 249, 1),
        ),
      ),
    );
  }
}

class RightMenuStyleButtonsWidget extends StatelessWidget {
  const RightMenuStyleButtonsWidget({
    super.key,
    required this.funtcion,
    required this.icon,
  });

  final Function() funtcion;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 15, right: 10),
      child: IconButton(
        onPressed: funtcion,
        style: IconButton.styleFrom(
          backgroundColor: const Color.fromRGBO(55, 55, 55, 1),
          hoverColor: const Color.fromRGBO(75, 75, 75, 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        icon: Icon(
          icon,
          color: const Color.fromRGBO(244, 246, 249, 1),
        ),
      ),
    );
  }
}

//! BOLUM SAYFASI

class DepartmentPageWidget extends ConsumerWidget {
  const DepartmentPageWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.only(left: 65, right: size.width > 1300 ? 56 : 0),
      child: ListView(
        children: [
          const DepartmentTopWidget(),
          DepartmentBottomWidget(size: size),
        ],
      ),
    );
  }
}

class DepartmentTopWidget extends ConsumerWidget {
  const DepartmentTopWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 50,
      color: Colors.white,
      alignment: Alignment.center,
      padding: const EdgeInsets.only(left: 50, right: 20),
      child: Row(
        children: [
          Expanded(
            child: Transform.scale(
              scale: 0.7,
              child: TextFormField(
                controller: _textEditingController2,
                textAlign: TextAlign.center,
                style: Design().poppins(
                  color: Colors.grey.shade800,
                  fw: FontWeight.w600,
                  size: 18,
                ),
                cursorColor: const Color.fromRGBO(35, 35, 35, 1),
                cursorWidth: 2,
                decoration: InputDecoration(
                  hintStyle: Design().poppins(
                    color: Colors.grey.shade800,
                    fw: FontWeight.w600,
                    size: 18,
                  ),
                  hintText: ref.watch(departmentNameProvider) ?? "",
                  fillColor: const Color.fromARGB(255, 226, 229, 233),
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 226, 229, 233),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 226, 229, 233),
                    ),
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: IconButton(
                      onPressed: () async {
                        if (_textEditingController2.text.isNotEmpty) {
                          String universityId =
                              ref.watch(userPhotoUrlProvider).asData!.value;
                          String facultyId = ref.watch(facultyIdProvider);
                          String departmentId = ref.watch(departmentIdProvider);

                          DocumentReference<Map<String, dynamic>>
                              departmentRef = FirebaseFirestore.instance
                                  .collection('universities')
                                  .doc(universityId)
                                  .collection('faculties')
                                  .doc(facultyId)
                                  .collection("departments")
                                  .doc(departmentId);

                          await departmentRef.update({
                            'name': _textEditingController2.text,
                          });

                          ref.read(departmentNameProvider.notifier).state =
                              _textEditingController2.text;

                          _textEditingController2.clear();
                        }
                      },
                      style: IconButton.styleFrom(
                          hoverColor: const Color.fromARGB(255, 196, 198, 202)),
                      icon: const Icon(
                        Icons.check,
                        color: Color.fromRGBO(35, 35, 35, 1),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: IconButton(
              onPressed: () {
                ref.read(leftPageChangeProvider.notifier).state = 0;
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
    );
  }
}

class DepartmentBottomWidget extends ConsumerWidget {
  const DepartmentBottomWidget({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var universityId = ref.watch(userPhotoUrlProvider).asData?.value ?? " ";
    var facultyId = ref.watch(facultyIdProvider);
    var departmentId = ref.watch(departmentIdProvider);

    return size.width > 1300
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DepartmentLeftWidget(
                  size: size,
                  universityId: universityId,
                  facultyId: facultyId,
                  departmentId: departmentId),
              DepartmentRightWidget(size: size),
            ],
          )
        : Column(
            children: [
              DepartmentLeftWidget(
                  size: size,
                  universityId: universityId,
                  facultyId: facultyId,
                  departmentId: departmentId),
              DepartmentRightWidget(size: size),
            ],
          );
  }
}

class DepartmentRightWidget extends ConsumerWidget {
  const DepartmentRightWidget({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.only(
        bottom: 20,
        top: size.width > 1300 ? 40 : 20,
        left: size.width > 1300 ? 20 : 0,
        right: size.width > 1300 ? 40 : 0,
      ),
      width: size.width > 1300 ? 250 : size.width - 121,
      height: size.width > 1300 ? 600 : 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Flexible(
            child: Align(
              alignment: Alignment.center,
              child: AddCourseButtonWidget(size: size),
            ),
          ),
          Flexible(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  LeftTopContainerWidget(
                    size: size,
                    topText: ref
                            .watch(departmentStudentsCountProvider)
                            .asData
                            ?.value
                            .toString() ??
                        "",
                    bottomText: "Öğrenci",
                    color: const Color.fromRGBO(246, 153, 92, 1),
                  ),
                  LeftTopContainerWidget(
                    size: size,
                    topText: ref
                            .watch(departmentInstructorsCountProvider)
                            .asData
                            ?.value
                            .toString() ??
                        "",
                    bottomText: "Akademisyen",
                    color: const Color.fromRGBO(211, 118, 118, 1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DepartmentLeftWidget extends StatelessWidget {
  const DepartmentLeftWidget({
    super.key,
    required this.size,
    required this.universityId,
    required this.facultyId,
    required this.departmentId,
  });

  final Size size;
  final String universityId;
  final String facultyId;
  final String departmentId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 40,
        bottom: size.width > 1300 ? 40 : 20,
        left: size.width > 1300 ? 40 : 0,
        right: size.width > 1300 ? 20 : 0,
      ),
      width: size.width > 1300 ? (size.width - 121) / 2 : size.width - 121,
      height: 900,
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
                "Dersler",
                style: Design().poppins(
                  size: 16,
                  fw: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Course>>(
                stream: UniversityService().getCoursesAsStream(
                  universityId,
                  facultyId,
                  departmentId,
                ),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container();
                  }
                  List<Course> courses = snapshot.data!;
                  return courses.isNotEmpty
                      ? ListView.builder(
                          itemCount: courses.length,
                          itemBuilder: (context, index) {
                            Course course = courses[index];
                            return DepartmentCardWidget(
                              course: course,
                              universityId: universityId,
                            );
                          },
                        )
                      : Container(
                          padding: const EdgeInsets.all(20),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 226, 229, 233),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Ders Eklenmedi",
                              style: Design().poppins(
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddCourseButtonWidget extends ConsumerWidget {
  const AddCourseButtonWidget({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
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
      onPressed: () {
        showSurveyDialog(
          context: context,
          ref: ref,
          buttonText: "Oluştur",
          tittleText: "Ders Ekle",
          children: Material(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTFFWidget(
                  provider: courseNameProvider,
                  text: "Ders adı",
                ),
                Container(
                  height: 50,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 30),
                  margin: const EdgeInsets.only(top: 20, bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 226, 229, 233),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SizedBox(
                    width: 270,
                    child: Consumer(
                      builder: (context, ref, child) {
                        final universityId =
                            ref.watch(userPhotoUrlProvider).asData!.value;
                        final facultyId = ref.watch(selectedFacultyIdProvider);

                        return StreamBuilder<List<Instructor>>(
                          stream: UniversityService()
                              .getFacultyInstructors(universityId, facultyId)
                              .asStream(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Text(
                                'Akademisyen Bulunamadı',
                                style: Design().poppins(
                                  color: Colors.grey.shade800,
                                ),
                              );
                            } else {
                              return DropdownButton(
                                menuMaxHeight: 300,
                                style: Design().poppins(
                                  size: 14,
                                  color: Colors.grey.shade800,
                                ),
                                iconEnabledColor: Colors.grey.shade800,
                                dropdownColor:
                                    const Color.fromARGB(255, 226, 229, 233),
                                underline:
                                    const Divider(color: Colors.transparent),
                                borderRadius: BorderRadius.circular(8),
                                value: 0,
                                items: List.generate(
                                  snapshot.data!.length,
                                  (index) {
                                    return DropdownMenuItem(
                                      value: index,
                                      child: Text(
                                          "${snapshot.data![index].title} ${snapshot.data![index].firstName} ${snapshot.data![index].lastName}"),
                                    );
                                  },
                                ),
                                onChanged: (value) {
                                  ref
                                      .read(selectedInstructorProvider.notifier)
                                      .state = value ?? 0;

                                  int selectedIndex = value ?? 0;
                                  String selectedInstructorId =
                                      snapshot.data![selectedIndex].id;
                                  ref
                                      .read(
                                          selectedInstructorIdProvider.notifier)
                                      .state = selectedInstructorId;
                                },
                              );
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
          buttonFunc: () {
            Navigator.of(context).pop();
            if (ref.watch(departmentNameProvider).isNotEmpty) {
              final String uniID =
                  ref.watch(userPhotoUrlProvider).asData!.value;
              final String facultyId = ref.watch(facultyIdProvider);
              final String departmentId = ref.watch(departmentIdProvider);

              UniversityService().addCourseToDepartment(
                  uniID,
                  facultyId,
                  departmentId,
                  ref.watch(courseNameProvider),
                  ref.watch(selectedInstructorIdProvider),
                  [],
                  [],
                  [],
                  [],
                  '',
                  '');
            }
          },
        );
      },
      icon: const Icon(Icons.add),
      label: Text(
        "Ders Ekle",
        style: Design().poppins(
          size: 15,
          color: Colors.white,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class DepartmentCardWidget extends ConsumerWidget {
  const DepartmentCardWidget({
    super.key,
    required this.course,
    required this.universityId,
  });

  final Course course;
  final String universityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: const Color.fromARGB(255, 226, 229, 233),
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.only(
          left: 25,
          top: 10,
          bottom: 10,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${course.id.substring(0, 10)}\n",
              style: Design().poppins(size: 12),
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                Text(
                  course.studentIds.length.toString(),
                  style: Design().poppins(
                    size: 14,
                    color: const Color.fromRGBO(246, 153, 92, 1),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.groups_rounded,
                  color: Color.fromRGBO(246, 153, 92, 1),
                  size: 20,
                ),
                const SizedBox(width: 30),
                FutureBuilder<Instructor>(
                  future: UniversityService().getInstructor(
                    course.instructorId,
                    universityId,
                  ),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Container();
                    }
                    Instructor instructor = snapshot.data!;
                    return Text(
                      "${instructor.title} ${instructor.firstName} ${instructor.lastName}",
                      style: Design().poppins(size: 14),
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        title: Text(
          course.name,
          style: Design().poppins(size: 15),
          overflow: TextOverflow.ellipsis,
        ),
        tileColor: const Color.fromARGB(255, 226, 229, 233),
        trailing: Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () {
                  showTextDialog(
                    context: context,
                    color: const Color.fromRGBO(246, 153, 92, 1),
                    ref: ref,
                    icon: Icons.restart_alt_outlined,
                    buttonText: "Sıfırla",
                    centerText: """Kesinleştirilmiş sınavlar"""
                        """ sıfırlanır ve akademisyen yeniden"""
                        """ sınav atayabilir.""",
                    tittleText:
                        "Sınavları sıfırlamak istediğinize emin misiniz?",
                    buttonFunc: () {},
                    buttonColor: const Color.fromRGBO(246, 153, 92, 1),
                  );
                },
                icon: Icon(
                  Icons.restart_alt_outlined,
                  color: Colors.grey.shade800,
                ),
                style: IconButton.styleFrom(
                  hoverColor: const Color.fromARGB(255, 196, 198, 202),
                ),
              ),
              const CourseSettingsButtonWidget(),
              IconButton(
                onPressed: () {
                  showTextDialog(
                    context: context,
                    color: const Color.fromRGBO(211, 118, 118, 1),
                    ref: ref,
                    icon: Icons.delete_forever,
                    buttonText: "Dersi Sil",
                    centerText: """Dersteki tüm içerikler silinir"""
                        """ ancak öğrenci ve akademisyenlerde"""
                        """ bir değişiklik olmaz.""",
                    tittleText: "Silmek istediğinize emin misiniz?",
                    buttonFunc: () {},
                  );
                },
                icon: Icon(
                  Icons.delete,
                  color: Colors.grey.shade800,
                ),
                style: IconButton.styleFrom(
                  hoverColor: const Color.fromARGB(255, 196, 198, 202),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CourseSettingsButtonWidget extends ConsumerWidget {
  const CourseSettingsButtonWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      onPressed: () {
        showSurveyDialog(
          context: context,
          ref: ref,
          buttonText: "Kaydet",
          tittleText: "Bilgileri Güncelle",
          children: Material(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DialogTFFWidget(
                  provider: courseNameProvider,
                  text: "Ders adı",
                ),
                Container(
                  height: 50,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 30),
                  margin: const EdgeInsets.only(top: 20, bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 226, 229, 233),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SizedBox(
                    width: 270,
                    child: Consumer(
                      builder: (context, ref, child) {
                        final universityId =
                            ref.watch(userPhotoUrlProvider).asData!.value;
                        final facultyId = ref.watch(selectedFacultyIdProvider);
                        final departmentId = ref.watch(departmentIdProvider);

                        return StreamBuilder<List<Instructor>>(
                          stream: UniversityService()
                              .getDepartmentInstructorsAsStream(
                                  universityId, facultyId, departmentId),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else if (!snapshot.hasData ||
                                snapshot.data!.isEmpty) {
                              return Text(
                                'Ders Bulunamadı',
                                style: Design().poppins(
                                  color: Colors.white,
                                ),
                              );
                            } else {
                              return DropdownButton(
                                menuMaxHeight: 300,
                                style: Design().poppins(
                                  size: 14,
                                  color: Colors.grey.shade800,
                                ),
                                iconEnabledColor: Colors.grey.shade800,
                                dropdownColor:
                                    const Color.fromARGB(255, 226, 229, 233),
                                underline:
                                    const Divider(color: Colors.transparent),
                                borderRadius: BorderRadius.circular(8),
                                value: ref.watch(selectedInstructorProvider),
                                items: List.generate(
                                  snapshot.data!.length,
                                  (index) {
                                    return DropdownMenuItem(
                                      value: index,
                                      child: Text(
                                        "${snapshot.data![index].title} ${snapshot.data![index].firstName} ${snapshot.data![index].lastName}",
                                      ),
                                    );
                                  },
                                ),
                                onChanged: (value) {
                                  ref
                                      .read(selectedInstructorProvider.notifier)
                                      .state = value ?? 0;

                                  int selectedIndex = value ?? 0;
                                  String selectedInstructorId =
                                      snapshot.data![selectedIndex].id;
                                  ref
                                      .read(
                                          selectedInstructorIdProvider.notifier)
                                      .state = selectedInstructorId;
                                },
                              );
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
          buttonFunc: () {
            Navigator.of(context).pop();
            if (ref.watch(departmentNameProvider).isNotEmpty) {
              final String uniID =
                  ref.watch(userPhotoUrlProvider).asData!.value;
              final String facultyId = ref.watch(facultyIdProvider);
              final String departmentId = ref.watch(departmentIdProvider);

              UniversityService().addCourseToDepartment(
                  uniID,
                  facultyId,
                  departmentId,
                  ref.watch(courseNameProvider),
                  ref.watch(selectedInstructorIdProvider),
                  [],
                  [],
                  [],
                  [],
                  '',
                  '');
            }
          },
        );
      },
      icon: Icon(
        Icons.settings,
        color: Colors.grey.shade800,
      ),
      style: IconButton.styleFrom(
        hoverColor: const Color.fromARGB(255, 196, 198, 202),
      ),
    );
  }
}

//! DIALOGLAR

showTextDialog({
  required BuildContext context,
  required WidgetRef ref,
  required String buttonText,
  required String tittleText,
  required String centerText,
  required IconData icon,
  required Function() buttonFunc,
  required Color color,
  Color buttonColor = const Color.fromRGBO(211, 118, 118, 1),
}) {
  showAdaptiveDialog(
    barrierColor: Colors.black26,
    builder: (context) {
      return Center(
        child: Transform.scale(
          scale: 0.9,
          child: Container(
            width: 340,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 40, bottom: 20),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  tittleText,
                  style: Design().poppins(
                    size: 16,
                    fw: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Text(
                  centerText,
                  style: Design().poppins(size: 15),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: buttonFunc,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: buttonColor,
                    padding: const EdgeInsets.only(
                      top: 18,
                      bottom: 18,
                      left: 25,
                      right: 25,
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style: Design().poppins(
                      size: 15,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.only(top: 40, bottom: 20),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: const BorderRadius.only(
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

showSurveyDialog({
  required BuildContext context,
  required WidgetRef ref,
  required String buttonText,
  required String tittleText,
  required Widget children,
  required Function() buttonFunc,
}) {
  showAdaptiveDialog(
    barrierColor: Colors.black26,
    builder: (context) {
      return Center(
        child: Transform.scale(
          scale: 0.9,
          child: Container(
            width: 440,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(top: 20, bottom: 20),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    tittleText,
                    style: Design().poppins(
                      size: 16,
                      fw: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 15),
                children,
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: buttonFunc,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.grey.shade800,
                      padding: const EdgeInsets.only(
                        top: 18,
                        bottom: 18,
                        left: 25,
                        right: 25,
                      ),
                    ),
                    child: Text(
                      buttonText,
                      style: Design().poppins(
                        size: 15,
                        color: Colors.white,
                      ),
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

// ignore: must_be_immutable
class DialogTFFWidget extends ConsumerWidget {
  DialogTFFWidget({
    super.key,
    required this.provider,
    required this.text,
  });

  StateProvider<String> provider;
  String text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextFormField(
      onChanged: (value) => ref.read(provider.notifier).state = value,
      style: Design().poppins(size: 15, color: Colors.grey.shade800),
      cursorColor: Colors.grey.shade800,
      cursorWidth: 2,
      cursorRadius: const Radius.circular(25),
      decoration: InputDecoration(
        fillColor: const Color.fromARGB(255, 226, 229, 233),
        filled: true,
        errorStyle: const TextStyle(height: 0),
        contentPadding: const EdgeInsets.only(left: 30, right: 30),
        hintText: text,
        hintStyle: Design().poppins(
          size: 14,
          color: Colors.grey.shade800,
        ),
        focusedBorder: Design().loginPageOIB(
          color: const Color.fromARGB(255, 226, 229, 233),
        ),
        enabledBorder: Design().loginPageOIB(
          color: const Color.fromARGB(255, 226, 229, 233),
        ),
      ),
    );
  }
}
