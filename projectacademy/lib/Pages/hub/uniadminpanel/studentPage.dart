// ignore_for_file: file_names
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:projectacademy/Pages/hub/uniadminpanel/homepage.dart';
import 'package:projectacademy/firebaseConfig/firebase_transactionss.dart';
import 'package:projectacademy/myDesign.dart';
import 'package:uuid/uuid.dart';

final selectStuFaculty = StateProvider((ref) => "");
final selectStuDepart = StateProvider((ref) => "");

final searchStuProvider = StateProvider((ref) => "");

final excelStudentProvider = StateProvider<List<String>>((ref) => []);
final excelStuName = StateProvider((ref) => "");
final excelStuSname = StateProvider((ref) => "");
final excelStuMail = StateProvider((ref) => "");
final excelStuNo = StateProvider((ref) => "");
final excelStuFaculty = StateProvider((ref) => "");
final excelStuDepartment = StateProvider((ref) => "");

final selectedDepartStuIdProvider = StateProvider((ref) => "");
final selectedFacultyStuIdProvider = StateProvider(
  (ref) => ref.watch(facultyIdProvider),
);

final selectedDepartStuIdProvider2 = StateProvider((ref) => "");
final selectedFacultyStuIdProvider2 = StateProvider(
  (ref) => ref.watch(facultyIdProvider),
);

final randomIDProvider = StateProvider((ref) => const Uuid().v4());
final selectedFacultyStuProvider = StateProvider((ref) => 0);
final selectedDepartStuProvider = StateProvider((ref) => 0);
final selectedFacultyStuProvider2 = StateProvider((ref) => 0);
final selectedDepartStuProvider2 = StateProvider((ref) => 0);
final studentNameProvider = StateProvider((ref) => "");
final studentSnameProvider = StateProvider((ref) => "");
final studentPassProvider = StateProvider((ref) => "");
final studentMailProvider = StateProvider((ref) => "");
final studentNoProvider = StateProvider((ref) => "");
final leftStudentPageChangeProvider = StateProvider((ref) => 0);
final selectedFacultyIdProvider = StateProvider(
  (ref) => ref.watch(facultyIdProvider),
);

final selectedFileProvider2 = StateProvider((ref) => 0);
//! Eğer dosya seçme tuşuna basılmış ve bir dosya başarı ile okunup
//! bir değikene kaydedilmiş ise 1 olacak. Gözükmesin diyorsan 0 olması gerek.

class StudentPageWidget extends ConsumerWidget {
  const StudentPageWidget({super.key});

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
                  "Öğrenci Ekle",
                  style: Design().poppins(
                    color: Colors.grey.shade800,
                    fw: FontWeight.bold,
                    size: 14,
                  ),
                ),
              ],
            ),
          ),
          size.width > 1250
              ? Column(
                  children: [
                    TopWidget(size: size),
                    const Row(
                      children: [
                        BottomLeftWidget(),
                        BottomRigtWidget(),
                      ],
                    )
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
      height: size.width > 1250 ? 300 : 500,
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
            size.width > 1250
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
                                    provider: studentNameProvider,
                                  ),
                                ),
                                SizedBox(
                                  width: 250,
                                  height: 55,
                                  child: UniAdminTFFWidget(
                                    provider: studentSnameProvider,
                                    text: "Soyad",
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
                                    text: "Öğrenci Numarası",
                                    provider: studentNoProvider,
                                  ),
                                ),
                                SizedBox(
                                  width: 250,
                                  height: 55,
                                  child: UniAdminTFFWidget(
                                    text: "Mail",
                                    provider: studentMailProvider,
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
                                          .watch(selectedFacultyStuIdProvider);

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
                          ],
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomCenter,
                        width: 300,
                        height: 125,
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
                              if (ref.watch(studentNameProvider) != "" &&
                                  ref.watch(studentSnameProvider) != "" &&
                                  ref.watch(studentNoProvider) != "" &&
                                  ref.watch(studentMailProvider) != "") {
                                UniversityService().addStudent(
                                    ref
                                        .watch(userPhotoUrlProvider)
                                        .asData!
                                        .value,
                                    ref.watch(selectedFacultyStuIdProvider),
                                    ref.watch(selectedDepartStuIdProvider),
                                    ref.watch(studentNameProvider),
                                    ref.watch(studentSnameProvider),
                                    ref.watch(studentNoProvider),
                                    ref.watch(studentMailProvider),
                                    []);
                              } else {
                                showSnackBarWidget(
                                    context, "Gerekli Alanları doldurunuz!");
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
                              provider: studentNameProvider,
                            ),
                          ),
                          SizedBox(
                            width: 250,
                            height: 55,
                            child: UniAdminTFFWidget(
                              provider: studentSnameProvider,
                              text: "Soyad",
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
                              text: "Öğrenci Numarası",
                              provider: studentNoProvider,
                            ),
                          ),
                          SizedBox(
                            width: 250,
                            height: 55,
                            child: UniAdminTFFWidget(
                              text: "Mail",
                              provider: studentMailProvider,
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
                                    ref.watch(selectedFacultyStuIdProvider);

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
                              if (ref.watch(studentNameProvider) != "" &&
                                  ref.watch(studentSnameProvider) != "" &&
                                  ref.watch(studentNoProvider) != "" &&
                                  ref.watch(studentMailProvider) != "") {
                                UniversityService().addStudent(
                                    ref
                                        .watch(userPhotoUrlProvider)
                                        .asData!
                                        .value,
                                    ref.watch(selectedFacultyStuIdProvider),
                                    ref.watch(selectedDepartStuIdProvider),
                                    ref.watch(studentNameProvider),
                                    ref.watch(studentSnameProvider),
                                    ref.watch(studentNoProvider),
                                    ref.watch(studentMailProvider),
                                    []);
                              } else {
                                showSnackBarWidget(
                                    context, "Gerekli Alanları doldurunuz!");
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
      width: size.width > 1250 ? (size.width - 65) / 2 : size.width - 65,
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
                "Kayıtlı Öğrenciler",
                style: Design().poppins(
                  size: 16,
                  fw: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            CostomSearchBarWidget(
              function: (String text) {
                ref.read(searchStuProvider.notifier).state = text;
              },
              hintText: "Öğrenci numarası ile ara",
              color: 1,
            ),
            Expanded(
              flex: 27,
              child: StreamBuilder<List<Student>>(
                stream: UniversityService().getStudentsStream(
                    ref.watch(userPhotoUrlProvider).asData!.value,
                    ref.watch(searchStuProvider)),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: SpinKitPulse(color: Colors.grey, size: 250),
                      );
                    } else {
                      return Container(
                        padding: const EdgeInsets.all(20),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 226, 229, 233),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "Öğrenci Bulunamadı",
                            style: Design().poppins(
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      );
                    }
                  } else if (snapshot.data!.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 226, 229, 233),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Öğrenci Eklenmedi",
                          style: Design().poppins(
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    );
                  } else {
                    List<Student>? students = snapshot.data;

                    return ListView.builder(
                      itemCount: students?.length,
                      itemBuilder: (context, index) {
                        Student student = students![index];

                        final uniId =
                            ref.watch(userPhotoUrlProvider).asData!.value;

                        Stream<String?> facultyNameStream = UniversityService()
                            .getFacultyNameStream(uniId, student.facultyId);
                        Stream<String?> departmentNameStream =
                            UniversityService().getDepartmentNameStream(
                                uniId, student.facultyId, student.departmentId);

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
                              ref.read(studentNameProvider.notifier).state = "";
                              ref.read(studentSnameProvider.notifier).state =
                                  "";
                              ref.read(studentNoProvider.notifier).state = "";
                              ref.read(studentMailProvider.notifier).state = "";
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
                                        provider: studentNameProvider,
                                        text: student.name,
                                      ),
                                      const SizedBox(height: 20),
                                      DialogTFFWidget(
                                        provider: studentSnameProvider,
                                        text: student.sname,
                                      ),
                                      const SizedBox(height: 20),
                                      DialogTFFWidget(
                                        provider: studentMailProvider,
                                        text: student.mail,
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
                                                          selectedFacultyStuProvider2),
                                                      onChanged: (value) {
                                                        ref
                                                            .read(
                                                                selectedFacultyStuProvider2
                                                                    .notifier)
                                                            .state = value ?? 0;
                                                        ref
                                                            .read(
                                                                selectedDepartStuIdProvider2
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
                                                                  .read(selectedFacultyStuIdProvider2
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
                                                selectedFacultyStuIdProvider2);

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
                                                            selectedDepartStuProvider2),
                                                        onChanged: (value) {
                                                          ref
                                                              .read(
                                                                  selectedDepartStuProvider2
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
                                                                    .read(selectedDepartStuIdProvider2
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
                                buttonFunc: () {
                                  // !! unutma?
                                },
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
                                  student.no,
                                  style: Design().poppins(size: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              title: Text(
                                "${student.name} ${student.sname}",
                                style: Design().poppins(size: 15),
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Column(
                                children: [
                                  const Text(""),
                                  featureWidget(student.mail, Icons.mail),
                                  StreamBuilder<String?>(
                                    stream: facultyNameStream,
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        if (snapshot.connectionState ==
                                            ConnectionState.waiting) {
                                          return Container();
                                        } else {
                                          return Container();
                                        }
                                      } else {
                                        return featureWidget(snapshot.data!,
                                            Icons.apartment_rounded);
                                      }
                                    },
                                  ),
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
                                          Icons.groups_rounded,
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                              trailing: Padding(
                                padding: const EdgeInsets.only(right: 10),
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
                                      buttonFunc: () {
                                        UniversityService().deleteStudent(
                                            ref
                                                    .watch(userPhotoUrlProvider)
                                                    .asData
                                                    ?.value ??
                                                "",
                                            student.facultyId,
                                            student.departmentId,
                                            student.id);
                                        Navigator.pop(context);

                                        showSnackBarWidget(context,
                                            "Öğrenci başarıyla silindi!");
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
            ),
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
      width: size.width > 1250 ? (size.width - 65) / 2 : size.width - 65,
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
                  ref.watch(excelStudentProvider).isNotEmpty
                      ? Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(
                              bottom: 20,
                            ),
                            child: ListView.builder(
                              itemCount: ref.watch(excelStudentProvider).length,
                              itemBuilder: (context, index) {
                                List variable = ref
                                    .watch(excelStudentProvider)[index]
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
                                    leading: Padding(
                                      padding: const EdgeInsets.only(right: 20),
                                      child: Text(
                                        variable[0],
                                        style: Design().poppins(
                                          size: 13,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    title: Text(
                                      "${variable[1]} ${variable[2]}",
                                      style: Design().poppins(
                                        size: 15,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Row(
                                      children: [
                                        const Icon(
                                          Icons.mail,
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          "${variable[3]}",
                                          style: Design().poppins(
                                            size: 13,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
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
                                              "Ekleme listesinden kaldırılacak.",
                                          icon: Icons.delete_forever,
                                          buttonFunc: () {
                                            Navigator.pop(context);
                                            var list =
                                                ref.watch(excelStudentProvider);
                                            list.removeAt(index);
                                            // ignore: unused_result
                                            ref.refresh(excelStudentProvider);
                                            ref
                                                .read(excelStudentProvider
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
                                        hoverColor: Colors.grey.shade700,
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
                                ref.watch(userPhotoUrlProvider).asData!.value;
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
                      const SizedBox(width: 20),
                      Container(
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
                                ref.watch(userPhotoUrlProvider).asData!.value;
                            final facultyId =
                                ref.watch(selectedFacultyStuIdProvider);

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
                    width: 200,
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
                              in ref.watch(excelStudentProvider)) {
                            List variable = element.split(",");
                            UniversityService().addStudent(
                                ref.watch(userPhotoUrlProvider).asData!.value,
                                ref.watch(selectStuFaculty),
                                ref.watch(selectStuDepart),
                                variable[1],
                                variable[2],
                                variable[0],
                                variable[3], []);

                            ref.read(excelStudentProvider.notifier).state = [];
                          }
                        }
                        showSnackBarWidget(
                            context, "Öğrenciler Başarıyla Eklendi");
                      },
                      child: Text(
                        "Öğrencileri Ekle",
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
                        List<String> excelStudents = [];

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
                              excelStudents.add(
                                  "${row[0]!.value},${row[1]!.value},${row[2]!.value},${row[3]!.value}");
                            }
                          }
                          ref.read(excelStudentProvider.notifier).state =
                              excelStudents;
                        }

                        if (excelStudents.isNotEmpty) {
                          showSnackBarWidget(
                              // ignore: use_build_context_synchronously
                              context,
                              "Öğrenciler başarıyla Listelendi..!");
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

// ignore: must_be_immutable
class UniAdminTFFWidget extends ConsumerWidget {
  UniAdminTFFWidget({
    super.key,
    required this.text,
    required this.provider,
  });

  String text;
  StateProvider<String> provider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextFormField(
      style: Design().poppins(
        size: 13,
        color: const Color.fromRGBO(205, 205, 205, 1),
      ),
      decoration: InputDecoration(
        hintText: text,
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
        ref.read(provider.notifier).state = value;
      },
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
            padding: const EdgeInsets.only(left: 13, right: 13),
            isExpanded: true,
            menuMaxHeight: 200,
            style: Design().poppins(
              size: 13,
              color: const Color.fromRGBO(205, 205, 205, 1),
            ),
            iconEnabledColor: const Color.fromRGBO(205, 205, 205, 1),
            dropdownColor: const Color.fromRGBO(50, 50, 50, 1),
            underline: const Divider(color: Colors.transparent),
            borderRadius: BorderRadius.circular(8),
            value: ref.watch(selectedFacultyStuProvider),
            onChanged: (value) {
              ref.read(selectedFacultyStuProvider.notifier).state = value ?? 0;

              ref.read(selectedDepartStuIdProvider.notifier).state = "";
              ref.read(selectedDepartStuProvider.notifier).state = 0;
              if (value != 0) {
                int selectedIndex = value! - 1;
                String selectedFacultyId = list[selectedIndex].id;
                ref.read(selectedFacultyStuIdProvider.notifier).state =
                    selectedFacultyId;
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
            value: ref.watch(selectedDepartStuProvider),
            onChanged: (value) {
              ref.read(selectedDepartStuProvider.notifier).state = value ?? 0;
              if (value != 0) {
                int selectedIndex = value! - 1;
                String selectedDepartId = list[selectedIndex].id;
                ref.read(selectedDepartStuIdProvider.notifier).state =
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
