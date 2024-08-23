import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:projectacademy/Pages/hub/instructorpanel/announcementPage.dart';
import 'package:projectacademy/Pages/hub/instructorpanel/homepage.dart';
import 'package:projectacademy/Pages/hub/instructorpanel/instructorPage.dart';
import 'package:projectacademy/firebaseConfig/firebase_transactionss.dart';
import 'package:projectacademy/myDesign.dart';

final selectedCourse2Provider = StateProvider((ref) => 0);

final homeworkTitleProvider = StateProvider((ref) => " ");

final filesNameProvider = StateProvider((ref) => []);
final filesProvider = StateProvider<List<PlatformFile>>((ref) => []);

final pickedDateProvider = StateProvider((ref) => DateTime(2024, 1, 1));
final pickedTimeProvider = StateProvider<TimeOfDay>(
  (ref) => const TimeOfDay(hour: 09, minute: 00),
);

class HomeworkPageWidget extends StatelessWidget {
  const HomeworkPageWidget({super.key});

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
                "Ödev Ekle",
                style: Design().poppins(
                  color: Colors.grey.shade800,
                  fw: FontWeight.bold,
                  size: 14,
                ),
              ),
            ],
          ),
        ),
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
            Container(
              padding: const EdgeInsets.all(10),
              alignment: Alignment.centerLeft,
              child: Text(
                "Dersler",
                style: Design().poppins(
                  size: 16,
                  fw: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<dynamic>>(
                  future: UniversityService().getCourseIds(
                      ref.watch(luniIdProvider).asData!.value,
                      ref.watch(linstructorIdProvider).asData!.value),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
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
                        return Expanded(
                          child: Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: const Color.fromRGBO(50, 50, 50, 1),
                            ),
                            child: Text(
                              "Ders Eklenmedi",
                              style: Design().poppins(
                                  size: 14,
                                  color:
                                      const Color.fromRGBO(205, 205, 205, 1)),
                            ),
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
                                    ref.watch(luniIdProvider).asData!.value,
                                    ref.watch(lfacultyIdProvider).asData!.value,
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
                                    return Card(
                                      color: ref.watch(
                                                  selectedCourse2Provider) ==
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
                                              .read(selectedCourse2Provider
                                                  .notifier)
                                              .state = index;

                                          ref
                                              .read(selectedCourse3Provider
                                                  .notifier)
                                              .state = index;

                                          ref
                                              .read(courseIndexId.notifier)
                                              .state = course.id;
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
                                                      selectedCourse2Provider) ==
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
                                          subtitle: Text(
                                            "Ödev son teslim tarihi : 12.02.2024 / 23:59",
                                            //! Aktif ödev bulunmuyor yazacak yada
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
                                });
                          },
                        ),
                      );
                    }
                  }),
            )
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
        top: size.width > 1300 ? 40 : 20,
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

                var list = ref.watch(filesNameProvider);
                var list2 = ref.watch(filesProvider);

                if (result != null) {
                  for (PlatformFile file in result.files) {
                    list.add(file.name);
                    list2.add(file);
                  }
                }

                // ignore: unused_result
                ref.refresh(filesNameProvider);
                // ignore: unused_result
                ref.refresh(filesProvider);

                ref.read(filesProvider.notifier).state = list2;
                ref.read(filesNameProvider.notifier).state = list;
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
            ref.watch(filesNameProvider).isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                      itemCount: ref.watch(filesNameProvider).length,
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
                              ref.watch(filesNameProvider)[index],
                              style: Design().poppins(
                                color: Colors.grey.shade800,
                                size: 15,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            trailing: IconButton(
                              onPressed: () {
                                var list = ref.watch(filesNameProvider);
                                var list2 = ref.watch(filesProvider);

                                list.removeAt(index);
                                list2.removeAt(index);

                                // ignore: unused_result
                                ref.refresh(filesNameProvider);
                                // ignore: unused_result
                                ref.refresh(filesProvider);

                                ref.read(filesProvider.notifier).state = list2;
                                ref.read(filesNameProvider.notifier).state =
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
        bottom: 20,
        top: 20,
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
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: TextFormField(
                  onChanged: (value) {
                    ref.read(homeworkTitleProvider.notifier).state = value;
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
      height: 230,
      child: Container(
        alignment: Alignment.center,
        child: size.width > 800
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 2,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Flexible(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Tarih:     ",
                                  style: Design().poppins(
                                    fw: FontWeight.bold,
                                    size: 15,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    final DateTime? picked =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2024),
                                      lastDate: DateTime(2050),
                                      initialEntryMode:
                                          DatePickerEntryMode.calendarOnly,
                                      builder: (context, child) {
                                        return SafeArea(
                                          child: MediaQuery(
                                            data:
                                                MediaQuery.of(context).copyWith(
                                              size: const Size(480, 600),
                                            ),
                                            child: MyDatePickerTheme(
                                                child: child!),
                                          ),
                                        );
                                      },
                                    );
                                    if (picked != null) {
                                      ref
                                          .read(pickedDateProvider.notifier)
                                          .state = picked;
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    backgroundColor: const Color.fromARGB(
                                        255, 226, 229, 233),
                                    foregroundColor:
                                        const Color.fromRGBO(246, 153, 92, 1),
                                    shadowColor: Colors.transparent,
                                  ),
                                  child: Text(
                                    DateFormat('dd.MM.yyyy')
                                        .format(ref.watch(pickedDateProvider)),
                                    style: Design().poppins(
                                      color: Colors.grey.shade800,
                                      fw: FontWeight.w500,
                                      size: 15,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Saat:     ",
                                  style: Design().poppins(
                                    fw: FontWeight.bold,
                                    size: 15,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    final TimeOfDay? picked =
                                        await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                      builder: (context, child) {
                                        return MyTimePickerTheme(
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (picked != null) {
                                      ref
                                          .read(pickedTimeProvider.notifier)
                                          .state = picked;
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    backgroundColor: const Color.fromARGB(
                                        255, 226, 229, 233),
                                    foregroundColor:
                                        const Color.fromRGBO(246, 153, 92, 1),
                                    shadowColor: Colors.transparent,
                                  ),
                                  child: Text(
                                    '${ref.watch(pickedTimeProvider).hour}:${ref.watch(pickedTimeProvider).minute.toString().padLeft(2, '0')}',
                                    style: Design().poppins(
                                      color: Colors.grey.shade800,
                                      fw: FontWeight.w500,
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
                  ),
                  Flexible(
                    child: Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 150,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            List<String> tempList = [];
                            List<String> tempList2 = [];

                            String date = DateTime.now().toString();

                            for (var file in ref.watch(filesProvider)) {
                              String fileName = file.name;
                              Reference storageReference =
                                  FirebaseStorage.instance.ref().child(
                                      'uploads/homeworks/${ref.watch(courseIndexId)}/${date.substring(0, 16)}/$fileName');
                              TaskSnapshot taskSnapshot = await storageReference
                                  .putData(file.bytes!)
                                  .whenComplete(() => null);
                              String url =
                                  await taskSnapshot.ref.getDownloadURL();

                              tempList.add(url);
                              tempList2.add(fileName);
                            }

                            String time =
                                "${ref.watch(pickedDateProvider)},${ref.watch(pickedTimeProvider)}";

                            UniversityService().addHomework(
                                ref.watch(luniIdProvider).asData!.value,
                                ref.watch(lfacultyIdProvider).asData!.value,
                                ref.watch(ldepartmentIdProvider).asData!.value,
                                ref.watch(courseIndexId),
                                ref.watch(homeworkTitleProvider),
                                tempList,
                                tempList2,
                                date,
                                time);
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
                            "Ödev Ekle",
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
              )
            : Column(
                children: [
                  Flexible(
                    flex: 2,
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Flexible(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Tarih:     ",
                                  style: Design().poppins(
                                    fw: FontWeight.bold,
                                    size: 15,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    final DateTime? picked =
                                        await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2024),
                                      lastDate: DateTime(2050),
                                      initialEntryMode:
                                          DatePickerEntryMode.calendarOnly,
                                      builder: (context, child) {
                                        return SafeArea(
                                          child: MediaQuery(
                                            data:
                                                MediaQuery.of(context).copyWith(
                                              size: const Size(480, 600),
                                            ),
                                            child: MyDatePickerTheme(
                                                child: child!),
                                          ),
                                        );
                                      },
                                    );
                                    if (picked != null) {
                                      ref
                                          .read(pickedDateProvider.notifier)
                                          .state = picked;
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    backgroundColor: const Color.fromARGB(
                                        255, 226, 229, 233),
                                    foregroundColor:
                                        const Color.fromRGBO(246, 153, 92, 1),
                                    shadowColor: Colors.transparent,
                                  ),
                                  child: Text(
                                    DateFormat('dd.MM.yyyy')
                                        .format(ref.watch(pickedDateProvider)),
                                    style: Design().poppins(
                                      color: Colors.grey.shade800,
                                      fw: FontWeight.w500,
                                      size: 15,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Saat:     ",
                                  style: Design().poppins(
                                    fw: FontWeight.bold,
                                    size: 15,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    final TimeOfDay? picked =
                                        await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                      builder: (context, child) {
                                        return MyTimePickerTheme(
                                          child: child!,
                                        );
                                      },
                                    );
                                    if (picked != null) {
                                      ref
                                          .read(pickedTimeProvider.notifier)
                                          .state = picked;
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.all(20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    backgroundColor: const Color.fromARGB(
                                        255, 226, 229, 233),
                                    foregroundColor:
                                        const Color.fromRGBO(246, 153, 92, 1),
                                    shadowColor: Colors.transparent,
                                  ),
                                  child: Text(
                                    '${ref.watch(pickedTimeProvider).hour}:${ref.watch(pickedTimeProvider).minute.toString().padLeft(2, '0')}',
                                    style: Design().poppins(
                                      color: Colors.grey.shade800,
                                      fw: FontWeight.w500,
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
                  ),
                  const SizedBox(height: 30),
                  Flexible(
                    child: Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 150,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () async {
                            List<String> tempList = [];
                            List<String> tempList2 = [];

                            String date = DateTime.now().toString();

                            for (var file in ref.watch(filesProvider)) {
                              String fileName = file.name;
                              Reference storageReference =
                                  FirebaseStorage.instance.ref().child(
                                      'uploads/homeworks/${ref.watch(courseIndexId)}/${date.substring(0, 16)}/$fileName');
                              TaskSnapshot taskSnapshot = await storageReference
                                  .putData(file.bytes!)
                                  .whenComplete(() => null);
                              String url =
                                  await taskSnapshot.ref.getDownloadURL();

                              tempList.add(url);
                              tempList2.add(fileName);
                            }

                            String time =
                                "${ref.watch(pickedDateProvider)},${ref.watch(pickedTimeProvider)}";

                            UniversityService().addHomework(
                                ref.watch(luniIdProvider).asData!.value,
                                ref.watch(lfacultyIdProvider).asData!.value,
                                ref.watch(ldepartmentIdProvider).asData!.value,
                                ref.watch(courseIndexId),
                                ref.watch(homeworkTitleProvider),
                                tempList,
                                tempList2,
                                date,
                                time);
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
                                const Color.fromRGBO(246, 153, 92, 1),
                            foregroundColor:
                                const Color.fromARGB(255, 226, 229, 233),
                          ),
                          child: Text(
                            "Ödev Ekle",
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
    );
  }
}

// ignore: must_be_immutable
class MyTimePickerTheme extends StatelessWidget {
  MyTimePickerTheme({
    super.key,
    required this.child,
  });

  Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        timePickerTheme: TimePickerThemeData(
          dayPeriodColor: MaterialStateColor.resolveWith(
            (states) => states.contains(MaterialState.selected)
                ? const Color.fromRGBO(246, 153, 92, 1)
                : Colors.white,
          ),
          dayPeriodTextColor: MaterialStateColor.resolveWith(
            (states) => states.contains(MaterialState.selected)
                ? Colors.white
                : const Color.fromRGBO(55, 55, 55, 1),
          ),
          dayPeriodBorderSide: const BorderSide(width: 2, strokeAlign: -40),
          hourMinuteShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          dayPeriodShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          dialTextStyle: Design().poppins(),
          dayPeriodTextStyle: Design().poppins(
            size: 16,
          ),
          hourMinuteTextStyle: Design().poppins(
            size: 25,
          ),
          helpTextStyle: Design().poppins(
            fw: FontWeight.w500,
            size: 14,
          ),
          cancelButtonStyle: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: Design().poppins(
              fw: FontWeight.w500,
              size: 14,
            ),
          ),
          confirmButtonStyle: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: Design().poppins(
              fw: FontWeight.w500,
              size: 14,
            ),
          ),
        ),
        colorScheme: const ColorScheme.light(
          primary: Color.fromRGBO(55, 55, 55, 1),
          onPrimary: Color.fromARGB(255, 226, 229, 233),
          onSurface: Color.fromRGBO(55, 55, 55, 1),
          background: Colors.white,
        ),
      ),
      child: Transform.scale(
        scale: 1.1,
        child: child,
      ),
    );
  }
}

// ignore: must_be_immutable
class MyDatePickerTheme extends StatelessWidget {
  MyDatePickerTheme({
    super.key,
    required this.child,
  });

  Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        datePickerTheme: DatePickerThemeData(
          cancelButtonStyle: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: Design().poppins(
              fw: FontWeight.w500,
              size: 14,
            ),
          ),
          confirmButtonStyle: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: Design().poppins(
              fw: FontWeight.w500,
              size: 14,
            ),
          ),
          headerHelpStyle: Design().poppins(
            fw: FontWeight.w500,
            size: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          yearStyle: Design().poppins(
            fw: FontWeight.w500,
            size: 14,
          ),
          weekdayStyle: Design().poppins(
            fw: FontWeight.w500,
            size: 14,
          ),
          dayStyle: Design().poppins(size: 14),
        ),
        colorScheme: const ColorScheme.light(
          primary: Color.fromRGBO(55, 55, 55, 1),
          onPrimary: Color.fromARGB(255, 226, 229, 233),
          onSurface: Color.fromRGBO(55, 55, 55, 1),
          background: Colors.white,
        ),
      ),
      child: Transform.scale(
        scale: 1.1,
        child: child,
      ),
    );
  }
}
