// ignore_for_file: file_names

import 'dart:ui';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:projectacademy/Pages/hub/uniadminpanel/homepage.dart';
import 'package:projectacademy/Pages/hub/uniadminpanel/studentPage.dart';
import 'package:projectacademy/firebaseConfig/firebase_transactionss.dart';
import 'package:projectacademy/myDesign.dart';

final searchInsNameProvider = StateProvider((ref) => "");

final selectInsFaculty = StateProvider((ref) => "");
final selectInsDepart = StateProvider((ref) => "");

final excelInstructorProvider = StateProvider<List<String>>((ref) => []);
final excelInsName = StateProvider((ref) => "");
final excelInsSname = StateProvider((ref) => "");
final excelInsTitle = StateProvider((ref) => "");
final excelInsBranch = StateProvider((ref) => "");
final excelInsId = StateProvider((ref) => "");
final excelInsMail = StateProvider((ref) => "");

final instructorNameProvider = StateProvider((ref) => "");
final instructorSnameProvider = StateProvider((ref) => "");
final instructorBranchProvider = StateProvider((ref) => "");
final instructorTitleProvider = StateProvider((ref) => "");
final instructorMailProvider = StateProvider((ref) => "");
final instructorIDProvider = StateProvider((ref) => "");

final selectedFacultyLecProvider = StateProvider((ref) => 0);
final selectedDepartLecProvider = StateProvider((ref) => 0);
final selectedFacultyLecProvider2 = StateProvider((ref) => 0);
final selectedDepartLecProvider2 = StateProvider((ref) => 0);
//!

final leftLecturerPageChangeProvider = StateProvider((ref) => 0);

final selectedDepartLecIdProvider = StateProvider((ref) => "");
final selectedFacultyLecIdProvider = StateProvider(
  (ref) => ref.watch(facultyIdProvider),
);

final selectedDepartLecIdProvider2 = StateProvider((ref) => "");
final selectedFacultyLecIdProvider2 = StateProvider(
  (ref) => ref.watch(facultyIdProvider),
);

class LecturerPage extends ConsumerWidget {
  const LecturerPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  "Akademisyen Ekle",
                  style: Design().poppins(
                    color: Colors.grey.shade800,
                    fw: FontWeight.bold,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
          size.width > 1600
              ? Column(
                  children: [
                    TopWidget(size: size),
                    const Row(
                      children: [
                        BottomLeftWidget(),
                        BottomRigtWidget(),
                      ],
                    ),
                  ],
                )
              : size.width > 800
                  ? Column(
                      children: [
                        TopWidget(size: size),
                        const BottomLeftWidget(),
                        const BottomRigtWidget(),
                      ],
                    )
                  : Container(),
        ],
      ),
    );
  }
}

class TopWidget extends ConsumerWidget {
  const TopWidget({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.only(top: 40, bottom: 20, left: 40, right: 40),
      width: size.width - 65,
      height: size.width > 1600 ? 380 : 600,
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
                "Manuel Kayıt",
                style: Design().poppins(
                  size: 16,
                  fw: FontWeight.w600,
                  color: const Color.fromRGBO(205, 205, 205, 1),
                ),
              ),
            ),
            const Spacer(),
            size.width > 1600
                ? Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  width: 250,
                                  height: 55,
                                  child: UniAdminTFFWidget(
                                    text: "Ad",
                                    provider: instructorNameProvider,
                                  ),
                                ),
                                SizedBox(
                                  width: 250,
                                  height: 55,
                                  child: UniAdminTFFWidget(
                                    text: "Soyad",
                                    provider: instructorSnameProvider,
                                  ),
                                ),
                                Container(
                                  width: 250,
                                  height: 55,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color.fromRGBO(50, 50, 50, 1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Consumer(
                                    builder: (context, ref, child) {
                                      final uniId = ref
                                          .watch(userPhotoUrlProvider)
                                          .asData!
                                          .value;
                                      return StreamBuilder<List<Faculty>>(
                                        stream: UniversityService()
                                            .getFacultiesAsStream(uniId),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Container();
                                          } else if (snapshot.hasError) {
                                            return Text(
                                                'Error: ${snapshot.error}');
                                          } else if (!snapshot.hasData ||
                                              snapshot.data!.isEmpty) {
                                            return const Text('');
                                          } else {
                                            var list = snapshot.data!;
                                            return DropdownButtonFacultyWidget(
                                                list);
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  width: 250,
                                  height: 55,
                                  child: UniAdminTFFWidget(
                                    text: "Anabilim Dalı",
                                    provider: instructorBranchProvider,
                                  ),
                                ),
                                SizedBox(
                                  width: 250,
                                  height: 55,
                                  child: UniAdminTFFWidget(
                                    text: "Ünvan",
                                    provider: instructorTitleProvider,
                                  ),
                                ),
                                Container(
                                  width: 250,
                                  height: 55,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color.fromRGBO(50, 50, 50, 1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Consumer(
                                    builder: (context, ref, child) {
                                      final universityId = ref
                                          .watch(userPhotoUrlProvider)
                                          .asData!
                                          .value;
                                      final facultyId = ref
                                          .watch(selectedFacultyLecIdProvider);

                                      return StreamBuilder<List<Department>>(
                                        stream: UniversityService()
                                            .getFacultyDepartmentsAsStream(
                                                universityId, facultyId),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Container();
                                          } else if (snapshot.hasError) {
                                            return Text(
                                                'Error: ${snapshot.error}');
                                          } else if (!snapshot.hasData ||
                                              snapshot.data!.isEmpty) {
                                            return const Text('');
                                          } else {
                                            var list = snapshot.data!;
                                            return DropdownButtonDepartmentWidget(
                                                list);
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(
                                  width: 250,
                                  height: 55,
                                  child: UniAdminTFFWidget(
                                    text: "Akademisyen ID",
                                    provider: instructorIDProvider,
                                  ),
                                ),
                                SizedBox(
                                  width: 250,
                                  height: 55,
                                  child: UniAdminTFFWidget(
                                    text: "Mail",
                                    provider: instructorMailProvider,
                                  ),
                                ),
                                const SizedBox(width: 250, height: 55),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomCenter,
                        width: 300,
                        height: 185,
                        child: SizedBox(
                          height: 50,
                          width: 150,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromRGBO(246, 153, 92, 1),
                              foregroundColor:
                                  const Color.fromRGBO(205, 205, 205, 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
                              if (ref.watch(instructorNameProvider) != "" &&
                                  ref.watch(instructorSnameProvider) != "" &&
                                  ref.watch(instructorBranchProvider) != "" &&
                                  ref.watch(instructorTitleProvider) != "" &&
                                  ref.watch(instructorMailProvider) != "" &&
                                  ref.watch(instructorIDProvider) != "") {
                                UniversityService().addInstructorToUniversity(
                                  ref.read(userPhotoUrlProvider).asData!.value,
                                  ref.read(instructorIDProvider),
                                  ref.watch(instructorNameProvider),
                                  ref.watch(instructorSnameProvider),
                                  ref.watch(instructorBranchProvider),
                                  ref.watch(instructorTitleProvider),
                                  ref.watch(instructorMailProvider),
                                  ref.watch(selectedFacultyLecIdProvider),
                                  ref.watch(selectedDepartLecIdProvider),
                                  [],
                                );
                              } else {
                                showSnackBarWidget(context,
                                    "Lütfen Gerekli alanları doldurunuz.!");
                              }
                            },
                            child: Text(
                              "Ekle",
                              style: Design().poppins(
                                size: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(
                            width: 250,
                            height: 55,
                            child: UniAdminTFFWidget(
                              text: "Ad",
                              provider: instructorNameProvider,
                            ),
                          ),
                          SizedBox(
                            width: 250,
                            height: 55,
                            child: UniAdminTFFWidget(
                              text: "Soyad",
                              provider: instructorSnameProvider,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(
                            width: 250,
                            height: 55,
                            child: UniAdminTFFWidget(
                              text: "Anabilim Dalı",
                              provider: instructorBranchProvider,
                            ),
                          ),
                          SizedBox(
                            width: 250,
                            height: 55,
                            child: UniAdminTFFWidget(
                              text: "Ünvan",
                              provider: instructorTitleProvider,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SizedBox(
                            width: 250,
                            height: 55,
                            child: UniAdminTFFWidget(
                              text: "Akademisyen ID",
                              provider: instructorIDProvider,
                            ),
                          ),
                          SizedBox(
                            width: 250,
                            height: 55,
                            child: UniAdminTFFWidget(
                              text: "Mail",
                              provider: instructorMailProvider,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            width: 250,
                            height: 55,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(50, 50, 50, 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Consumer(
                              builder: (context, ref, child) {
                                final uniId = ref
                                    .watch(userPhotoUrlProvider)
                                    .asData!
                                    .value;
                                return StreamBuilder<List<Faculty>>(
                                  stream: UniversityService()
                                      .getFacultiesAsStream(uniId),
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
                                      return DropdownButtonFacultyWidget(list);
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                          Container(
                            width: 250,
                            height: 55,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(50, 50, 50, 1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Consumer(
                              builder: (context, ref, child) {
                                final universityId = ref
                                    .watch(userPhotoUrlProvider)
                                    .asData!
                                    .value;
                                final facultyId =
                                    ref.watch(selectedFacultyLecIdProvider);

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
                                      return DropdownButtonDepartmentWidget(
                                          list);
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        alignment: Alignment.bottomCenter,
                        width: 300,
                        height: 70,
                        child: SizedBox(
                          height: 50,
                          width: 150,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromRGBO(246, 153, 92, 1),
                              foregroundColor:
                                  const Color.fromRGBO(205, 205, 205, 1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
                              if (ref.watch(instructorNameProvider) != "" &&
                                  ref.watch(instructorSnameProvider) != "" &&
                                  ref.watch(instructorBranchProvider) != "" &&
                                  ref.watch(instructorTitleProvider) != "" &&
                                  ref.watch(instructorMailProvider) != "" &&
                                  ref.watch(instructorIDProvider) != "") {
                                UniversityService().addInstructorToUniversity(
                                  ref.read(userPhotoUrlProvider).asData!.value,
                                  ref.read(instructorIDProvider),
                                  ref.watch(instructorNameProvider),
                                  ref.watch(instructorSnameProvider),
                                  ref.watch(instructorBranchProvider),
                                  ref.watch(instructorTitleProvider),
                                  ref.watch(instructorMailProvider),
                                  ref.watch(selectedFacultyLecIdProvider),
                                  ref.watch(selectedDepartLecIdProvider),
                                  [],
                                );
                              } else {
                                showSnackBarWidget(context,
                                    "Lütfen Gerekli alanları doldurunuz.!");
                              }
                            },
                            child: Text(
                              "Ekle",
                              style: Design().poppins(
                                size: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class BottomLeftWidget extends ConsumerWidget {
  const BottomLeftWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        bottom: size.width > 1250 ? 40 : 20,
        left: 40,
        right: size.width > 1250 ? 20 : 40,
      ),
      width: size.width > 1600 ? (size.width - 65) / 2 : size.width - 65,
      height: 800,
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
                "Kayıtlı Akademisyenler",
                style: Design().poppins(
                  size: 16,
                  fw: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            CostomSearchBarWidget(
              function: (String text) {
                ref.read(searchInsNameProvider.notifier).state = text;
              },
              hintText: "Akademisyen ID ile ara",
              color: 1,
            ),
            Expanded(
              flex: 27,
              child: StreamBuilder<List<Instructor>?>(
                stream: UniversityService().getInstructorsStream(
                    ref.watch(userPhotoUrlProvider).asData?.value ?? "",
                    ref.watch(searchInsNameProvider)),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: SpinKitPulse(color: Colors.grey, size: 250),
                      );
                    } else {
                      return Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 226, 229, 233),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "Akademisyen Bulunamadı",
                              style: Design().poppins(
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                  } else if (snapshot.data!.isEmpty) {
                    return Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 226, 229, 233),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Akademisyen Eklenmedi",
                            style: Design().poppins(
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    );
                  } else {
                    List<Instructor> instructors = snapshot.data ?? [];

                    return ListView.builder(
                      itemCount: instructors.length,
                      itemBuilder: (context, index) {
                        final uniId =
                            ref.watch(userPhotoUrlProvider).asData!.value;
                        Instructor instructor = instructors[index];

                        Stream<String?> facultyNameStream = UniversityService()
                            .getFacultyNameStream(uniId, instructor.facultyId);
                        Stream<String?> departmentNameStream =
                            UniversityService().getDepartmentNameStream(uniId,
                                instructor.facultyId, instructor.departmentId);

                        return Card(
                          color: const Color.fromARGB(255, 226, 229, 233),
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          margin: const EdgeInsets.only(top: 10),
                          child: InkWell(
                            hoverColor:
                                const Color.fromARGB(255, 211, 211, 211),
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              //! Verileri çek ve üstteki providerlara yazdır.
                              //! Sağ üstteki ayarlar butonuna her basıldığında
                              //! o providerlar resetlenecek.
                              ref.read(instructorNameProvider.notifier).state =
                                  "";
                              ref.read(instructorSnameProvider.notifier).state =
                                  "";
                              ref
                                  .read(instructorBranchProvider.notifier)
                                  .state = "";
                              ref.read(instructorTitleProvider.notifier).state =
                                  "";
                              ref.read(instructorMailProvider.notifier).state =
                                  "";

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
                                        provider: instructorNameProvider,
                                        text: instructor.firstName,
                                      ),
                                      const SizedBox(height: 20),
                                      DialogTFFWidget(
                                        provider: instructorSnameProvider,
                                        text: instructor.lastName,
                                      ),
                                      const SizedBox(height: 20),
                                      DialogTFFWidget(
                                        provider: instructorBranchProvider,
                                        text: instructor.branch,
                                      ),
                                      const SizedBox(height: 20),
                                      DialogTFFWidget(
                                        provider: instructorTitleProvider,
                                        text: instructor.title,
                                      ),
                                      const SizedBox(height: 20),
                                      DialogTFFWidget(
                                        provider: instructorMailProvider,
                                        text: instructor.email,
                                      ),
                                      Container(
                                        height: 50,
                                        alignment: Alignment.centerLeft,
                                        padding:
                                            const EdgeInsets.only(left: 30),
                                        margin: const EdgeInsets.only(top: 20),
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              255, 226, 229, 233),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Consumer(
                                          builder: (context, ref, child) {
                                            final universityId = ref
                                                .watch(userPhotoUrlProvider)
                                                .asData!
                                                .value;
                                            return StreamBuilder<List<Faculty>>(
                                              stream: UniversityService()
                                                  .getFacultiesAsStream(
                                                      universityId),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return Container();
                                                } else if (snapshot.hasError) {
                                                  return Text(
                                                      'Error: ${snapshot.error}');
                                                } else if (!snapshot.hasData ||
                                                    snapshot.data!.isEmpty) {
                                                  return Text(
                                                    'Fakülte Bulunamadı',
                                                    style: Design().poppins(
                                                      color:
                                                          Colors.grey.shade800,
                                                    ),
                                                  );
                                                } else {
                                                  return SizedBox(
                                                    width: 270,
                                                    child: DropdownButton(
                                                      menuMaxHeight: 300,
                                                      style: Design().poppins(
                                                        size: 14,
                                                        color: Colors
                                                            .grey.shade800,
                                                      ),
                                                      iconEnabledColor:
                                                          Colors.grey.shade800,
                                                      dropdownColor:
                                                          const Color.fromARGB(
                                                              255,
                                                              226,
                                                              229,
                                                              233),
                                                      underline: const Divider(
                                                          color: Colors
                                                              .transparent),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      value: ref.watch(
                                                          selectedFacultyLecProvider2),
                                                      onChanged: (value) {
                                                        ref
                                                            .read(
                                                                selectedFacultyLecProvider2
                                                                    .notifier)
                                                            .state = value ?? 0;
                                                        ref
                                                            .read(
                                                                selectedDepartLecIdProvider2
                                                                    .notifier)
                                                            .state = "";
                                                        if (value != 0) {
                                                          int selectedIndex =
                                                              value! - 1;
                                                          String
                                                              selectedFacultyId =
                                                              snapshot
                                                                  .data![
                                                                      selectedIndex]
                                                                  .id;
                                                          ref
                                                                  .read(selectedFacultyLecIdProvider2
                                                                      .notifier)
                                                                  .state =
                                                              selectedFacultyId;
                                                        }
                                                      },
                                                      items: [
                                                        const DropdownMenuItem(
                                                          value: 0,
                                                          child: Text(
                                                              'Lütfen fakülte seçiniz'),
                                                        ),
                                                        ...List.generate(
                                                          snapshot.data!.length,
                                                          (index) {
                                                            return DropdownMenuItem(
                                                              value:
                                                                  (index + 1),
                                                              child: Text(
                                                                  snapshot
                                                                      .data![
                                                                          index]
                                                                      .name),
                                                            );
                                                          },
                                                        )
                                                      ],
                                                    ),
                                                  );
                                                }
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                      Container(
                                        height: 50,
                                        alignment: Alignment.centerLeft,
                                        padding:
                                            const EdgeInsets.only(left: 30),
                                        margin: const EdgeInsets.only(top: 20),
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              255, 226, 229, 233),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Consumer(
                                          builder: (context, ref, child) {
                                            final universityId = ref
                                                .watch(userPhotoUrlProvider)
                                                .asData!
                                                .value;
                                            final facultyId = ref.watch(
                                                selectedFacultyLecIdProvider2);

                                            return StreamBuilder<
                                                List<Department>>(
                                              stream: UniversityService()
                                                  .getFacultyDepartmentsAsStream(
                                                      universityId, facultyId),
                                              builder: (context, snapshot) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return Container();
                                                } else if (snapshot.hasError) {
                                                  return Text(
                                                      'Error: ${snapshot.error}');
                                                } else if (!snapshot.hasData ||
                                                    snapshot.data!.isEmpty) {
                                                  return Text(
                                                    ' ',
                                                    style: Design().poppins(
                                                      color:
                                                          Colors.grey.shade800,
                                                    ),
                                                  );
                                                } else {
                                                  return SizedBox(
                                                    width: 270,
                                                    child: DropdownButton(
                                                        menuMaxHeight: 300,
                                                        style: Design().poppins(
                                                          size: 14,
                                                          color: Colors
                                                              .grey.shade800,
                                                        ),
                                                        iconEnabledColor: Colors
                                                            .grey.shade800,
                                                        dropdownColor:
                                                            const Color.fromARGB(
                                                                255,
                                                                226,
                                                                229,
                                                                233),
                                                        underline: const Divider(
                                                            color: Colors
                                                                .transparent),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                        value: ref.watch(
                                                            selectedDepartLecProvider2),
                                                        onChanged: (value) {
                                                          ref
                                                              .read(
                                                                  selectedDepartLecProvider2
                                                                      .notifier)
                                                              .state = value ?? 0;
                                                          if (value != 0) {
                                                            int selectedIndex =
                                                                value! - 1;
                                                            String
                                                                selectedDepartId =
                                                                snapshot
                                                                    .data![
                                                                        selectedIndex]
                                                                    .id;
                                                            ref
                                                                    .read(selectedDepartLecIdProvider2
                                                                        .notifier)
                                                                    .state =
                                                                selectedDepartId;
                                                          }
                                                        },
                                                        items: [
                                                          const DropdownMenuItem(
                                                            value: 0,
                                                            child: Text(
                                                                'Lütfen bölüm seçiniz'),
                                                          ),
                                                          ...List.generate(
                                                              snapshot
                                                                  .data!.length,
                                                              (index) {
                                                            return DropdownMenuItem(
                                                              value:
                                                                  (index + 1),
                                                              child: Text(
                                                                  snapshot
                                                                      .data![
                                                                          index]
                                                                      .name),
                                                            );
                                                          })
                                                        ]),
                                                  );
                                                }
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                buttonFunc: () async {},
                              );
                            },
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              tileColor:
                                  const Color.fromARGB(255, 226, 229, 233),
                              contentPadding: const EdgeInsets.only(
                                left: 25,
                                top: 10,
                                bottom: 10,
                              ),
                              leading: Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: Text(
                                  instructor.instructorID,
                                  style: Design().poppins(size: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              title: Text(
                                "${instructor.title} ${instructor.firstName} ${instructor.lastName}",
                                style: Design().poppins(size: 15),
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 20),
                                child: Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        featureWidget(
                                          instructor.email,
                                          Icons.mail,
                                        ),
                                        featureWidget(
                                          instructor.branch,
                                          Icons.linear_scale_sharp,
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 50),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          StreamBuilder<String?>(
                                              stream: facultyNameStream,
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
                                                  return featureWidget(
                                                      snapshot.data!,
                                                      Icons.apartment_rounded);
                                                }
                                              }),
                                          StreamBuilder<String?>(
                                            stream: departmentNameStream,
                                            builder: (context, snapshot) {
                                              if (!snapshot.hasData) {
                                                if (snapshot.connectionState ==
                                                    ConnectionState.waiting) {
                                                  return Container();
                                                } else {
                                                  return Container();
                                                }
                                              } else {
                                                return featureWidget(
                                                    snapshot.data!,
                                                    Icons.groups_rounded);
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: IconButton(
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
                                          "Ekleme listesinden kaldırılacak.",
                                      icon: Icons.delete_forever,
                                      buttonFunc: () async {
                                        Navigator.pop(context);
                                        bool courseExists =
                                            await UniversityService()
                                                .courseExist(
                                                    uniId, instructor.id);
                                        if (courseExists) {
                                          showSnackBarWidget(
                                              // ignore: use_build_context_synchronously
                                              context,
                                              "Kayıtlı ders mevcut!");
                                        } else {
                                          UniversityService().deleteInstructor(
                                              uniId, instructor.id);
                                        }
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
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Row featureWidget(String text, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: Design().poppins(size: 14),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class BottomRigtWidget extends ConsumerWidget {
  const BottomRigtWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        bottom: 40,
        left: size.width > 1250 ? 20 : 40,
        right: 40,
      ),
      width: size.width > 1600 ? (size.width - 65) / 2 : size.width - 65,
      height: 800,
      child: Column(
        children: [
          Expanded(
            flex: 6,
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
                      "Excel ile Kayıt",
                      style: Design().poppins(
                        size: 16,
                        fw: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                  ref.watch(excelInstructorProvider).isNotEmpty
                      ? Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(
                              bottom: 20,
                            ),
                            child: ListView.builder(
                              itemCount:
                                  ref.watch(excelInstructorProvider).length,
                              itemBuilder: (context, index) {
                                List variable = ref
                                    .watch(excelInstructorProvider)[index]
                                    .split(",");
                                return Card(
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  margin: const EdgeInsets.only(top: 10),
                                  child: ListTile(
                                    tileColor: const Color.fromARGB(
                                        255, 226, 229, 233),
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
                                      "${variable[4]} ${variable[1]} ${variable[2]}",
                                      style: Design().poppins(
                                        size: 15,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 20),
                                        Text(
                                          "${variable[3]}",
                                          style: Design().poppins(
                                            size: 13,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.mail,
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              "${variable[5]}",
                                              style: Design().poppins(
                                                size: 13,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      onPressed: () {
                                        showTextDialog(
                                          context: context,
                                          color: const Color.fromRGBO(
                                              250, 44, 44, 1),
                                          ref: ref,
                                          buttonText: "Sil",
                                          tittleText:
                                              "Silmek istediğinize emin misiniz?",
                                          centerText:
                                              "Ekleme listesinden kaldırılacak.",
                                          icon: Icons.delete_forever,
                                          buttonFunc: () {
                                            Navigator.pop(context);
                                            var list = ref
                                                .watch(excelInstructorProvider);

                                            list.removeAt(index);
                                            // ignore: unused_result
                                            ref.refresh(
                                                excelInstructorProvider);
                                            ref
                                                .read(excelInstructorProvider
                                                    .notifier)
                                                .state = list;
                                          },
                                        );
                                      },
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.grey.shade800,
                                      ),
                                      style: IconButton.styleFrom(
                                        hoverColor: const Color.fromARGB(
                                            255, 196, 198, 202),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        )
                      : Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 226, 229, 233),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "Tablo Yüklenmedi",
                                style: Design().poppins(
                                  size: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ),
                        ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 20),
                        width: 200,
                        height: 55,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 226, 229, 233),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Consumer(
                          builder: (context, ref, child) {
                            final uniId =
                                ref.watch(userPhotoUrlProvider).asData?.value ??
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
                                  var _list = snapshot.data!;
                                  return DropdownButtonFacultyWidget(_list);
                                }
                              },
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 20),
                      Container(
                        margin: const EdgeInsets.only(left: 20),
                        width: 200,
                        height: 55,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 226, 229, 233),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Consumer(
                          builder: (context, ref, child) {
                            final universityId =
                                ref.watch(userPhotoUrlProvider).asData?.value ??
                                    " ";
                            final facultyId =
                                ref.watch(selectedFacultyLecIdProvider);

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
                                  var _list = snapshot.data!;
                                  return DropdownButtonDepartmentWidget(_list);
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Flexible(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    height: 50,
                    width: 250,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(35, 35, 35, 1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(
                            color: Colors.white,
                            width: 4,
                            strokeAlign: BorderSide.strokeAlignOutside,
                          ),
                        ),
                      ),
                      onPressed: () async {
                        if (ref.watch(selectStuFaculty) != "" &&
                            ref.watch(selectStuDepart) != "") {
                          for (String element
                              in ref.watch(excelInstructorProvider)) {
                            List variable = element.split(",");
                            UniversityService().addInstructorToUniversity(
                                ref.watch(userPhotoUrlProvider).asData!.value,
                                ref.watch(variable[0]),
                                ref.watch(variable[1]),
                                ref.watch(variable[2]),
                                ref.watch(variable[3]),
                                ref.watch(variable[4]),
                                ref.watch(variable[5]),
                                ref.watch(selectInsFaculty),
                                ref.watch(selectInsDepart), []);

                            ref.read(excelInstructorProvider.notifier).state =
                                [];
                          }
                        }
                      },
                      child: Text(
                        "Akademisyenleri Ekle",
                        style: Design().poppins(
                          size: 15,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 50,
                    width: 200,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromRGBO(81, 130, 155, 1),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(
                            color: Colors.white,
                            width: 4,
                            strokeAlign: BorderSide.strokeAlignOutside,
                          ),
                        ),
                      ),
                      onPressed: () async {
                        List<String> excelInstructors = [];

                        FilePickerResult? pickedFile =
                            await FilePicker.platform.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['xlsx'],
                          allowMultiple: false,
                        );
                        if (pickedFile != null) {
                          var bytes = pickedFile.files.single.bytes;
                          var excel = Excel.decodeBytes(bytes as List<int>);
                          for (var table in excel.tables.keys) {
                            for (var row in excel.tables[table]!.rows) {
                              excelInstructors.add(
                                  "${row[0]!.value},${row[1]!.value},${row[2]!.value},${row[3]!.value},${row[4]!.value},${row[5]!.value}");
                            }
                          }
                          ref.read(excelInstructorProvider.notifier).state =
                              excelInstructors;
                        }
                      },
                      icon: const Icon(Icons.file_upload_rounded),
                      label: Text(
                        "Tablo Yükle",
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
        ],
      ),
    );
  }
}

class DropdownButtonFacultyWidget extends ConsumerWidget {
  final List<dynamic> list;
  const DropdownButtonFacultyWidget(this.list, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 250,
      height: 55,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(50, 50, 50, 1),
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
              color: const Color.fromRGBO(205, 205, 205, 1),
            ),
            iconEnabledColor: const Color.fromRGBO(205, 205, 205, 1),
            dropdownColor: const Color.fromRGBO(50, 50, 50, 1),
            underline: const Divider(color: Colors.transparent),
            borderRadius: BorderRadius.circular(8),
            value: ref.watch(selectedFacultyLecProvider),
            onChanged: (value) {
              ref.read(selectedFacultyLecProvider.notifier).state = value ?? 0;

              ref.read(selectedDepartLecIdProvider.notifier).state = "";
              ref.read(selectedDepartLecProvider.notifier).state = 0;
              if (value != 0) {
                int selectedIndex = value! - 1;
                String selectedFacultyId = list[selectedIndex].id;
                ref.read(selectedFacultyLecIdProvider.notifier).state =
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
      width: 250,
      height: 55,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(50, 50, 50, 1),
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
              color: const Color.fromRGBO(205, 205, 205, 1),
            ),
            iconEnabledColor: const Color.fromRGBO(205, 205, 205, 1),
            dropdownColor: const Color.fromRGBO(50, 50, 50, 1),
            underline: const Divider(color: Colors.transparent),
            borderRadius: BorderRadius.circular(8),
            value: ref.watch(selectedDepartLecProvider),
            onChanged: (value) {
              ref.read(selectedDepartLecProvider.notifier).state = value ?? 0;
              if (value != 0) {
                int selectedIndex = value! - 1;
                String selectedDepartId = list[selectedIndex].id;
                ref.read(selectedDepartLecIdProvider.notifier).state =
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
