// ignore_for_file: file_names

import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:projectacademy/Pages/hub/instructorpanel/homepage.dart';
import 'package:projectacademy/Pages/hub/instructorpanel/homeworkPage.dart';
import 'package:projectacademy/Pages/hub/instructorpanel/instructorPage.dart';
import 'package:projectacademy/Pages/hub/uniadminpanel/homepage.dart';
import 'package:projectacademy/firebaseConfig/firebase_transactionss.dart';
import 'package:projectacademy/myDesign.dart';
import 'package:projectacademy/questionTemplates/questionTemplates.dart';

final selectedPlanProvider = StateProvider((ref) => 0);
final silinecekProvider19 = StateProvider((ref) => 0);
final lectureProvider = StateProvider((ref) => 0);
final lectureProvider1 = StateProvider((ref) => 0);
final lectureLeftTopWidgetProvider = StateProvider((ref) => 0);
final lectureLeftTopWidgetProviderId = StateProvider((ref) => " ");
final pickedDate2Provider = StateProvider((ref) => DateTime(2024, 1, 1));
final pickedTime2Provider = StateProvider<TimeOfDay>(
  (ref) => const TimeOfDay(hour: 09, minute: 00),
);
final selectedQuestProvider = StateProvider((ref) => 0);
final planPageProvider = StateProvider((ref) => 0);
final isMixedProvider = StateProvider((ref) => false);
final isMixedProvider1 = StateProvider((ref) => false);
final isReturnProvider = StateProvider((ref) => false);
final isReturnProvider1 = StateProvider((ref) => false);
final isOkeyProvider = StateProvider((ref) => false);
final isOkeyProvider1 = StateProvider((ref) => false);

final timerProvider1 = StateProvider((ref) => "0");
final timerProvider2 = StateProvider((ref) => "0");

//? TOPLAM PUANI TUTAR
final totalCountProvider = StateProvider((ref) => 100);

final planTittleProvider = StateProvider((ref) => "");
final questionPointProvider = StateProvider((ref) => "");
final quistionTypeProvider = StateProvider((ref) => 0);

final classicTextProvider = StateProvider((ref) => "");

final firstGFProvider = StateProvider((ref) => "");
final lastGFProvider = StateProvider((ref) => "");

final tfTextProvider = StateProvider((ref) => "");
final tfAnswerProvider = StateProvider((ref) => 1);

final textTextProvider = StateProvider((ref) => "");

final testTextProvider = StateProvider((ref) => "");
final testListProvider = StateProvider<List<String>>((ref) => []);
final testListProvider2 = StateProvider<List<String>>((ref) => []);
final testListNewProvider = StateProvider((ref) => "");
final testListAnswerProvider = StateProvider((ref) => "");
final selectedTestProvider = StateProvider((ref) => 0);

final answerProvider = StateProvider((ref) => "");

final courseListProvider = StateProvider((ref) => <Map<String, String>>[]);
final examSchemasListProvider = StateProvider((ref) => <Map<String, String>>[]);
final examQsizeListProvider = StateProvider((ref) => <Map<String, String>>[]);

final schemaDetailsProvider = StateProvider((ref) => <String, dynamic>{});
final schemaDetails2Provider = StateProvider((ref) => <String, dynamic>{});

final schemaIdProvider = StateProvider((ref) => " ");
final schemaId2Provider = StateProvider((ref) => " ");

//! SINAV AYARLAMA EKRANI

class CreateQuizPageWidget extends ConsumerWidget {
  const CreateQuizPageWidget({super.key});

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
      child: ref.watch(planPageProvider) == 0
          ? ListView(
              children: [
                Container(
                  height: 50,
                  padding: const EdgeInsets.only(left: 50, right: 20),
                  alignment: Alignment.center,
                  color: Colors.white,
                  child: Row(
                    children: [
                      Text(
                        "Sınav Oluştur",
                        style: Design().poppins(
                          color: Colors.grey.shade800,
                          fw: FontWeight.bold,
                          size: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                size.width > 1800
                    ? const Row(
                        children: [
                          Flexible(
                            flex: 1,
                            child: LeftWidget(),
                          ),
                          Flexible(
                            flex: 2,
                            child: RightWidget(),
                          ),
                        ],
                      )
                    : const Column(
                        children: [
                          LeftWidget(),
                          RightWidget(),
                        ],
                      ),
              ],
            )
          : const PlanPageWidget(),
    );
  }
}

class RightWidget extends StatelessWidget {
  const RightWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RightTopWidget(),
          RightBottomWidget(),
        ],
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
    return Container(
      height: 130,
      padding: const EdgeInsets.only(left: 40, right: 40, top: 32, bottom: 20),
      alignment: Alignment.center,
      child: Container(
        height: 55,
        width: 400,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButton(
            padding: const EdgeInsets.only(left: 13, right: 13),
            isExpanded: true,
            menuMaxHeight: 200,
            style: Design().poppins(
              size: 13,
              color: Colors.grey.shade600,
            ),
            iconEnabledColor: Colors.grey.shade600,
            dropdownColor: Colors.white,
            underline: const Divider(color: Colors.transparent),
            borderRadius: BorderRadius.circular(8),
            value: ref.watch(lectureLeftTopWidgetProvider),
            onChanged: (value) async {
              ref.read(lectureLeftTopWidgetProvider.notifier).state = value!;

              if (value != 0) {
                ref.read(lectureLeftTopWidgetProviderId.notifier).state =
                    ref.watch(courseListProvider)[value - 1].values.first;

                ref.read(examSchemasListProvider.notifier).state =
                    await UniversityService().getExamSchemasFuture(
                        ref.watch(luniIdProvider).asData?.value ?? "",
                        ref.watch(lfacultyIdProvider).asData?.value ?? "",
                        ref.watch(ldepartmentIdProvider).asData?.value ?? "");
              } else {
                ref.read(lectureLeftTopWidgetProviderId.notifier).state = " ";
                ref.read(examSchemasListProvider.notifier).state = [];
                ref.read(lectureProvider.notifier).state = 0;
              }
            },
            items: [
              const DropdownMenuItem(
                value: 0,
                child: Text('Lütfen ders seçiniz'),
              ),
              if (ref.watch(courseListProvider).isNotEmpty)
                ...List.generate(
                  ref.watch(courseListProvider).length,
                  (index) {
                    return DropdownMenuItem(
                      value: index + 1,
                      child: Text(
                          ref.watch(courseListProvider)[index].values.last),
                    );
                  },
                ),
            ]),
      ),
    );
  }
}

class RightBottomWidget extends StatelessWidget {
  const RightBottomWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width > 1800
        ? const Row(
            children: [
              OrganizeExamWidget(direction: 0),
              OrganizeExamWidget(direction: 1),
            ],
          )
        : const Column(
            children: [
              OrganizeExamWidget(direction: 0),
              OrganizeExamWidget(direction: 1),
            ],
          );
  }
}

class OrganizeExamWidget extends ConsumerWidget {
  const OrganizeExamWidget({
    super.key,
    required this.direction,
  });

  final int direction; // 0 -> LEFT , 1 -> RIGHT

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uniId = ref.watch(luniIdProvider).asData?.value ?? "";
    final facultyId = ref.watch(lfacultyIdProvider).asData?.value ?? "";
    final departmentId = ref.watch(ldepartmentIdProvider).asData?.value ?? "";
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        bottom: direction == 0 && size.width < 1800 ? 20 : 40,
        left: size.width > 1800 ? 20 : 40,
        right: direction == 0 && size.width > 1800 ? 20 : 40,
      ),
      width: size.width > 1800 ? (size.width - 65) / 3 : size.width,
      height: size.width > 1800 ? 850 : 950,
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
                direction == 0 ? "Vize" : "Final",
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
              child: DropdownButton(
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
                value: direction == 0
                    ? ref.watch(lectureProvider)
                    : ref.watch(lectureProvider1),
                onChanged: (value) async {
                  if (direction == 0) {
                    ref.read(lectureProvider.notifier).state = value ?? 0;

                    if (value != 0) {
                      ref.read(schemaIdProvider.notifier).state =
                          ref.watch(examSchemasListProvider)[value! - 1]['id']!;

                      ref.read(schemaDetailsProvider.notifier).state =
                          await UniversityService().getSchemaDetails(
                              ref.watch(luniIdProvider).asData?.value ?? "",
                              ref.watch(lfacultyIdProvider).asData?.value ?? "",
                              ref.watch(ldepartmentIdProvider).asData?.value ??
                                  "",
                              ref.watch(schemaIdProvider));
                    }
                  }
                  if (direction == 1) {
                    ref.read(lectureProvider1.notifier).state = value ?? 0;

                    if (value != 0) {
                      ref.read(schemaId2Provider.notifier).state =
                          ref.watch(examSchemasListProvider)[value! - 1]['id']!;

                      ref.read(schemaDetails2Provider.notifier).state =
                          await UniversityService().getSchemaDetails(
                              ref.watch(luniIdProvider).asData?.value ?? "",
                              ref.watch(lfacultyIdProvider).asData?.value ?? "",
                              ref.watch(ldepartmentIdProvider).asData?.value ??
                                  "",
                              ref.watch(schemaId2Provider));
                    }
                  }
                },
                items: [
                  const DropdownMenuItem(
                    value: 0,
                    child: Text('Lütfen taslak seçiniz'),
                  ),
                  if (ref.watch(examSchemasListProvider).isNotEmpty)
                    ...List.generate(
                      ref.watch(examSchemasListProvider).length,
                      (index) {
                        return DropdownMenuItem(
                          value: index + 1,
                          child: Text(ref.watch(examSchemasListProvider)[index]
                              ['title']!),
                        );
                      },
                    ),
                ],
              ),
            ),
            (direction == 0
                    ? ref.watch(lectureProvider) == 0
                    : ref.watch(lectureProvider1) == 0)
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
                          "Taslak Seçilmedi",
                          style: Design().poppins(
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  )
                : Expanded(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Soru Dağılımı :",
                            style: Design().poppins(
                              size: 13,
                              fw: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 320,
                          child: ListView(
                            children: [
                              QuestionTypeCardWidget(
                                  text: "Klasik Soru",
                                  text2: direction == 0
                                      ? "${ref.watch(schemaDetailsProvider)["ClassicQuestion"]?['count'] ?? 0} Adet"
                                      : "${ref.watch(schemaDetails2Provider)["ClassicQuestion"]?['count'] ?? 0} Adet",
                                  text3: direction == 0
                                      ? "${ref.watch(schemaDetailsProvider)["ClassicQuestion"]?['totalPoints'] ?? 0} Puan"
                                      : "${ref.watch(schemaDetails2Provider)["ClassicQuestion"]?['totalPoints'] ?? 0} Puan"),
                              QuestionTypeCardWidget(
                                  text: "Test Sorusu",
                                  text2: direction == 0
                                      ? "${ref.watch(schemaDetailsProvider)["TestQuestion"]?['count'] ?? 0} Adet"
                                      : "${ref.watch(schemaDetails2Provider)["TestQuestion"]?['count'] ?? 0} Adet",
                                  text3: direction == 0
                                      ? "${ref.watch(schemaDetailsProvider)["TestQuestion"]?['totalPoints'] ?? 0} Puan"
                                      : "${ref.watch(schemaDetails2Provider)["TestQuestion"]?['totalPoints'] ?? 0} Puan"),
                              QuestionTypeCardWidget(
                                  text: "Boşluk Doldurma",
                                  text2: direction == 0
                                      ? "${ref.watch(schemaDetailsProvider)["GapFillingQuestion"]?['count'] ?? 0} Adet"
                                      : "${ref.watch(schemaDetails2Provider)["GapFillingQuestion"]?['count'] ?? 0} Adet",
                                  text3: direction == 0
                                      ? "${ref.watch(schemaDetailsProvider)["GapFillingQuestion"]?['totalPoints'] ?? 0} Puan"
                                      : "${ref.watch(schemaDetails2Provider)["GapFillingQuestion"]?['totalPoints'] ?? 0} Puan"),
                              QuestionTypeCardWidget(
                                  text: "Doğru - Yanlış Sorusu",
                                  text2: direction == 0
                                      ? "${ref.watch(schemaDetailsProvider)["TrueFalseQuestion"]?['count'] ?? 0} Adet"
                                      : "${ref.watch(schemaDetails2Provider)["TrueFalseQuestion"]?['count'] ?? 0} Adet",
                                  text3: direction == 0
                                      ? "${ref.watch(schemaDetailsProvider)["TrueFalseQuestion"]?['totalPoints'] ?? 0} Puan"
                                      : "${ref.watch(schemaDetails2Provider)["TrueFalseQuestion"]?['totalPoints'] ?? 0} Puan"),
                              QuestionTypeCardWidget(
                                  text: "Metin Sorusu",
                                  text2: direction == 0
                                      ? "${ref.watch(schemaDetailsProvider)["TextQuestion"]?['count'] ?? 0} Adet"
                                      : "${ref.watch(schemaDetails2Provider)["TextQuestion"]?['count'] ?? 0} Adet",
                                  text3: direction == 0
                                      ? "${ref.watch(schemaDetailsProvider)["TextQuestion"]?['totalPoints'] ?? 0} Puan"
                                      : "${ref.watch(schemaDetails2Provider)["TextQuestion"]?['totalPoints'] ?? 0} Puan"),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        size.width > 1000
                            ? Row(
                                children: [
                                  const Flexible(child: SelectDateWidget()),
                                  Flexible(
                                    child: SelectTimeWidget(
                                      direction: direction,
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  const SelectDateWidget(),
                                  const SizedBox(height: 10),
                                  SelectTimeWidget(direction: direction),
                                ],
                              ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Transform.scale(
                              scale: 1.2,
                              child: Checkbox(
                                value: direction == 0
                                    ? ref.watch(isMixedProvider)
                                    : ref.watch(isMixedProvider1),
                                onChanged: (value) {
                                  direction == 0
                                      ? ref
                                          .read(isMixedProvider.notifier)
                                          .state = value!
                                      : ref
                                          .read(isMixedProvider1.notifier)
                                          .state = value!;
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                activeColor:
                                    const Color.fromRGBO(83, 145, 101, 1),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Sorular karıştırılsın",
                              style: Design().poppins(
                                size: 13,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Transform.scale(
                              scale: 1.2,
                              child: Checkbox(
                                value: direction == 0
                                    ? ref.watch(isReturnProvider)
                                    : ref.watch(isReturnProvider1),
                                onChanged: (value) {
                                  direction == 0
                                      ? ref
                                          .read(isReturnProvider.notifier)
                                          .state = value!
                                      : ref
                                          .read(isReturnProvider1.notifier)
                                          .state = value!;
                                },
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                activeColor:
                                    const Color.fromRGBO(83, 145, 101, 1),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "Sorular arası geçiş olmasın",
                              style: Design().poppins(
                                size: 13,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: size.width > 1300
                                ? ((size.width - 65) / 3) - 20
                                : size.width - 20,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () async {
                                showTextDialog(
                                  context: context,
                                  ref: ref,
                                  buttonText: "Kesinleştir",
                                  tittleText: "Onaylıyor musunuz?",
                                  centerText:
                                      """Eğer sınavı kesinleştirirseniz"""
                                      """ tekrar değiştirilemez. Kesinleştirme"""
                                      """ işlemini geri almak için lütfen bağlı"""
                                      """ olduğunuz kurumla iletişime geçiniz.""",
                                  icon: Icons.warning,
                                  buttonFunc: () async {
                                    List<String> templist =
                                        await UniversityService().getStudentIds(
                                            ref
                                                    .watch(luniIdProvider)
                                                    .asData
                                                    ?.value ??
                                                "",
                                            ref
                                                    .watch(lfacultyIdProvider)
                                                    .asData
                                                    ?.value ??
                                                "",
                                            ref
                                                    .watch(
                                                        ldepartmentIdProvider)
                                                    .asData
                                                    ?.value ??
                                                "",
                                            ref.watch(
                                                lectureLeftTopWidgetProviderId));
                                    UniversityService().addExam(
                                      ref.watch(luniIdProvider).asData?.value ??
                                          "",
                                      ref
                                              .watch(lfacultyIdProvider)
                                              .asData
                                              ?.value ??
                                          "",
                                      ref
                                              .watch(ldepartmentIdProvider)
                                              .asData
                                              ?.value ??
                                          "",
                                      ref.watch(lectureLeftTopWidgetProviderId),
                                      direction == 0
                                          ? ref.watch(schemaIdProvider)
                                          : ref.watch(schemaId2Provider),
                                      direction == 0 ? "vize" : "final",
                                      ref.watch(pickedTime2Provider),
                                      ref.watch(pickedDate2Provider),
                                      direction == 0
                                          ? ref.watch(isMixedProvider)
                                          : ref.watch(isMixedProvider1),
                                      direction == 0
                                          ? ref.watch(isReturnProvider)
                                          : ref.watch(isReturnProvider1),
                                      direction == 0
                                          ? ref.watch(timerProvider1)
                                          : ref.watch(timerProvider2),
                                      false,
                                    );

                                    for (var i in templist) {
                                      UniversityService().addExamtoStudent(
                                        uniId,
                                        facultyId,
                                        departmentId,
                                        i,
                                        ref.watch(
                                            lectureLeftTopWidgetProviderId),
                                        direction == 0
                                            ? ref.watch(schemaIdProvider)
                                            : ref.watch(schemaId2Provider),
                                        direction == 0 ? "vize" : "final",
                                        ref.watch(pickedTime2Provider),
                                        ref.watch(pickedDate2Provider),
                                        direction == 0
                                            ? ref.watch(isMixedProvider)
                                            : ref.watch(isMixedProvider1),
                                        direction == 0
                                            ? ref.watch(isReturnProvider)
                                            : ref.watch(isReturnProvider1),
                                        direction == 0
                                            ? ref.watch(timerProvider1)
                                            : ref.watch(timerProvider2),
                                        false,
                                      );
                                    }
                                    // ignore: use_build_context_synchronously
                                    Navigator.pop(context);
                                  },
                                  color: const Color.fromRGBO(246, 153, 92, 1),
                                  buttonColor:
                                      const Color.fromRGBO(246, 153, 92, 1),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                backgroundColor:
                                    const Color.fromRGBO(246, 153, 92, 1),
                                foregroundColor:
                                    const Color.fromARGB(255, 226, 229, 233),
                                shadowColor: Colors.transparent,
                              ),
                              child: Text(
                                "Sınavı Kesinleştir",
                                style: Design().poppins(
                                  color: Colors.white,
                                  size: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        direction == 0
                            ? ref.watch(isOkeyProvider)
                                ? Text(
                                    "Kesinleştirildi",
                                    style: Design().poppins(
                                      color:
                                          const Color.fromRGBO(83, 145, 101, 1),
                                      size: 15,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : Text(
                                    "Kesinleştirilmedi",
                                    style: Design().poppins(
                                      color: const Color.fromRGBO(
                                          211, 118, 118, 1),
                                      size: 15,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  )
                            : ref.watch(isOkeyProvider1)
                                ? Text(
                                    "Kesinleştirildi",
                                    style: Design().poppins(
                                      color:
                                          const Color.fromRGBO(83, 145, 101, 1),
                                      size: 15,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : Text(
                                    "Kesinleştirilmedi",
                                    style: Design().poppins(
                                      color: const Color.fromRGBO(
                                          211, 118, 118, 1),
                                      size: 15,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                      ],
                    ),
                  )
          ],
        ),
      ),
    );
  }
}

class SelectTimeWidget extends ConsumerWidget {
  const SelectTimeWidget({
    super.key,
    required this.direction,
  });

  final int direction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Sınav Süresi (dakika) :",
            style: Design().poppins(
              size: 13,
              fw: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 55,
          child: TextFormField(
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
              LimitRangeTextInputFormatter(0, 200),
            ],
            textAlign: TextAlign.center,
            onChanged: (value) {
              direction == 0
                  ? ref.read(timerProvider1.notifier).state = value
                  : ref.read(timerProvider2.notifier).state = value;
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
              hintText: direction == 0
                  ? ref.watch(timerProvider1)
                  : ref.watch(timerProvider2),
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
      ],
    );
  }
}

class SelectDateWidget extends ConsumerWidget {
  const SelectDateWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Sınav Tarihi :",
            style: Design().poppins(
              size: 13,
              fw: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 55,
              padding: const EdgeInsets.only(right: 20),
              child: ElevatedButton(
                onPressed: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2050),
                    initialEntryMode: DatePickerEntryMode.calendarOnly,
                    builder: (context, child) {
                      return SafeArea(
                        child: MediaQuery(
                          data: MediaQuery.of(context).copyWith(
                            size: const Size(480, 600),
                          ),
                          child: MyDatePickerTheme(child: child!),
                        ),
                      );
                    },
                  );
                  if (picked != null) {
                    ref.read(pickedDate2Provider.notifier).state = picked;
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
                  DateFormat('dd.MM.yyyy')
                      .format(ref.watch(pickedDate2Provider)),
                  style: Design().poppins(
                    size: 13,
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Container(
              height: 55,
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
              ),
              child: ElevatedButton(
                onPressed: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                    builder: (context, child) {
                      return MyTimePickerTheme(
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    ref.read(pickedTime2Provider.notifier).state = picked;
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
                  '${ref.watch(pickedTime2Provider).hour}:${ref.watch(pickedTime2Provider).minute.toString().padLeft(2, '0')}',
                  style: Design().poppins(
                    size: 13,
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class QuestionTypeCardWidget extends ConsumerWidget {
  const QuestionTypeCardWidget({
    super.key,
    required this.text,
    required this.text2,
    required this.text3,
  });

  final String text;
  final String text2;
  final String text3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(top: 4),
      child: ListTile(
        tileColor: const Color.fromARGB(255, 226, 229, 233),
        contentPadding: const EdgeInsets.only(
          top: 5,
          bottom: 5,
          left: 20,
          right: 20,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                text,
                style: Design().poppins(
                  size: 13,
                  color: Colors.grey.shade600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: Text(
                text2,
                style: Design().poppins(
                  size: 13,
                  color: Colors.grey.shade600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              child: Text(
                text3,
                style: Design().poppins(
                  size: 13,
                  color: Colors.grey.shade600,
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

class LeftWidget extends StatelessWidget {
  const LeftWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LeftTopWidget(),
        LeftBottomWidget(),
      ],
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
        bottom: 20,
        top: 40,
        left: 40,
        right: size.width > 1800 ? 20 : 40,
      ),
      width: size.width > 1800 ? ((size.width - 65) / 5) * 2 : size.width - 65,
      height: 200,
      child: CardButtonWidget(
        color: const Color.fromRGBO(211, 118, 118, 1),
        func: () {
          ref.read(planPageProvider.notifier).state = 1;
        },
        tittle: "Sınav Taslağı Oluştur",
        subtittle: """Oluşturduğunuz taslaklar ile """
            """vize ve final sınavları başlatabilirsiniz.""",
      ),
    );
  }
}

class LeftBottomWidget extends ConsumerWidget {
  const LeftBottomWidget({
    super.key,
  });

  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(
        bottom: 40,
        top: 20,
        left: 40,
        right: size.width > 1800 ? 20 : 40,
      ),
      width: size.width > 1800 ? ((size.width - 65) / 5) * 2 : size.width - 65,
      height: size.width > 1800 ? 780 : 700,
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
                "Sınav Taslakları",
                style: Design().poppins(
                  size: 16,
                  fw: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const ShemeWidget()
          ],
        ),
      ),
    );
  }
}

class ShemeWidget extends ConsumerWidget {
  const ShemeWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(20),
        child: StreamBuilder<List<Map<String, String>>>(
            stream: UniversityService().getExamSchemas(
              ref.watch(luniIdProvider).asData?.value ?? " ",
              ref.watch(lfacultyIdProvider).asData?.value ?? " ",
              ref.watch(ldepartmentIdProvider).asData?.value ?? " ",
            ),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              } else {
                var examSchemas = snapshot.data!;
                return examSchemas.isNotEmpty
                    ? ListView.builder(
                        itemCount: examSchemas.length,
                        itemBuilder: (context, index) {
                          String schemaName = examSchemas[index].values.last;
                          String schemaId = examSchemas[index].values.first;
                          return FutureBuilder<Map<String, String>>(
                              future: UniversityService()
                                  .getExamSchemaTotalQandP(
                                      ref.watch(luniIdProvider).asData?.value ??
                                          " ",
                                      ref
                                              .watch(lfacultyIdProvider)
                                              .asData
                                              ?.value ??
                                          " ",
                                      ref
                                              .watch(ldepartmentIdProvider)
                                              .asData
                                              ?.value ??
                                          " ",
                                      schemaId),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Container();
                                  } else {
                                    return Container();
                                  }
                                } else {
                                  var qSize = snapshot.data!.values.first;
                                  var total = snapshot.data!.values.last;
                                  return Card(
                                    color: ref.watch(selectedPlanProvider) ==
                                            index
                                        ? const Color.fromRGBO(90, 90, 90, 1)
                                        : const Color.fromRGBO(50, 50, 50, 1),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: () async {
                                        ref
                                            .read(selectedPlanProvider.notifier)
                                            .state = index;
                                        QuerySnapshot querySnapshot =
                                            await FirebaseFirestore.instance
                                                .collection('universities')
                                                .doc(ref
                                                        .watch(luniIdProvider)
                                                        .asData
                                                        ?.value ??
                                                    " ")
                                                .collection('faculties')
                                                .doc(ref
                                                        .watch(
                                                            lfacultyIdProvider)
                                                        .asData
                                                        ?.value ??
                                                    " ")
                                                .collection('departments')
                                                .doc(ref
                                                        .watch(
                                                            ldepartmentIdProvider)
                                                        .asData
                                                        ?.value ??
                                                    " ")
                                                .collection("schemas")
                                                .doc(schemaId)
                                                .collection("questions")
                                                .get();

                                        List<dynamic> questionsList = [];

                                        querySnapshot.docs.forEach((doc) {
                                          Map<String, dynamic> data = doc.data()
                                              as Map<String, dynamic>;
                                          String questionType = data['type'];

                                          switch (questionType) {
                                            case 'EmptyQuestion':
                                              questionsList.add(EmptyQuestion(
                                                point: data['point'] ?? "",
                                                key: Key(doc.id),
                                              ));
                                              break;
                                            case 'ClassicQuestion':
                                              questionsList.add(ClassicQuestion(
                                                photoUrl:
                                                    data['photoUrl'] ?? "",
                                                text: data['text'] ?? "",
                                                answerUrl:
                                                    data['answerUrl'] ?? "",
                                                answer: data['answer'] ?? "",
                                                point: data['point'] ?? "",
                                                key: Key(doc.id),
                                              ));
                                              break;
                                            case 'GapFillingQuestion':
                                              questionsList
                                                  .add(GapFillingQuestion(
                                                firstText:
                                                    data['firstText'] ?? "",
                                                lastText:
                                                    data['lastText'] ?? "",
                                                answer: data['answer'] ?? "",
                                                correctAnswer:
                                                    data['correctAnswer'] ?? "",
                                                point: data['point'] ?? "",
                                                key: Key(doc.id),
                                              ));
                                              break;
                                            case 'TrueFalseQuestion':
                                              questionsList
                                                  .add(TrueFalseQuestion(
                                                text: data['text'] ?? "",
                                                answer: data['answer'] ?? "",
                                                correctAnswer:
                                                    data['correctAnswer'] ?? "",
                                                point: data['point'] ?? "",
                                                key: Key(doc.id),
                                              ));
                                              break;
                                            case 'TextQuestion':
                                              questionsList.add(TextQuestion(
                                                photoUrl:
                                                    data['photoUrl'] ?? "",
                                                text: data['text'] ?? "",
                                                answer: data['answer'] ?? "",
                                                point: data['point'] ?? "",
                                                key: Key(doc.id),
                                              ));
                                              break;
                                            case 'TestQuestion':
                                              questionsList.add(TestQuestion(
                                                photoUrl:
                                                    data['photoUrl'] ?? "",
                                                text: data['text'] ?? "",
                                                options: List<String>.from(
                                                    data['options'] ?? []),
                                                answer: data['answer'] ?? "",
                                                correctAnswer:
                                                    data['correctAnswer'] ?? "",
                                                point: data['point'] ?? "",
                                                key: Key(doc.id),
                                              ));
                                              break;
                                            default:
                                              throw ArgumentError(
                                                  'Unsupported question type: $questionType');
                                          }
                                        });
                                        ref
                                            .read(questListProvider.notifier)
                                            .state = questionsList;
                                        ref
                                            .read(planPageProvider.notifier)
                                            .state = 1;
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
                                        tileColor:
                                            ref.watch(selectedPlanProvider) ==
                                                    index
                                                ? const Color.fromRGBO(
                                                    90, 90, 90, 1)
                                                : const Color.fromRGBO(
                                                    50, 50, 50, 1),
                                        title: Text(
                                          schemaName,
                                          style: Design().poppins(
                                            color: const Color.fromRGBO(
                                                205, 205, 205, 1),
                                            size: 15,
                                          ),
                                        ),
                                        subtitle: Text(
                                          qSize,
                                          style: Design().poppins(
                                            color: const Color.fromRGBO(
                                                205, 205, 205, 1),
                                            size: 13,
                                          ),
                                        ),
                                        leading: total == "100"
                                            ? Container(
                                                padding: const EdgeInsets.only(
                                                  right: 10,
                                                ),
                                                child: const Icon(
                                                  Icons.check,
                                                  color: Color.fromRGBO(
                                                      83, 145, 101, 1),
                                                ),
                                              )
                                            : Container(
                                                padding: const EdgeInsets.only(
                                                  right: 10,
                                                ),
                                                child: const Icon(
                                                  Icons.incomplete_circle,
                                                  color: Color.fromRGBO(
                                                      246, 153, 92, 1),
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
                                                  "Taslak tamamen silinecektir.",
                                              icon: Icons.delete_forever,
                                              buttonFunc: () {
                                                UniversityService()
                                                    .deleteSchemaAndCollection(
                                                        ref
                                                                .watch(
                                                                    luniIdProvider)
                                                                .asData
                                                                ?.value ??
                                                            " ",
                                                        ref
                                                                .watch(
                                                                    lfacultyIdProvider)
                                                                .asData
                                                                ?.value ??
                                                            " ",
                                                        ref
                                                                .watch(
                                                                    ldepartmentIdProvider)
                                                                .asData
                                                                ?.value ??
                                                            " ",
                                                        schemaId);
                                                Navigator.pop(context);
                                                showSnackBarWidget(context,
                                                    "Taslak başarıyla silindi..!");
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
                                }
                              });
                        },
                      )
                    : Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: const Color.fromRGBO(50, 50, 50, 1),
                        ),
                        child: Text(
                          "Taslak Bulunamadı",
                          style: Design().poppins(
                              size: 14,
                              color: const Color.fromRGBO(205, 205, 205, 1)),
                        ),
                      );
              }
            }),
      ),
    );
  }
}

//! TASLAK OLUŞTURMA EKRANI

class PlanPageWidget extends ConsumerWidget {
  const PlanPageWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                "Sınav Taslağı Oluştur",
                style: Design().poppins(
                  color: Colors.grey.shade800,
                  fw: FontWeight.bold,
                  size: 14,
                ),
              ),
              Row(
                children: [
                  Transform.scale(
                    scale: 0.9,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (ref.watch(planTittleProvider).isNotEmpty) {
                          //! BURADA VERİTABANINA TASLAK KAYDEDİLECEK

                          UniversityService().addExamSchema(
                              ref.watch(luniIdProvider).asData?.value ?? "",
                              ref.watch(lfacultyIdProvider).asData?.value ?? "",
                              ref.watch(ldepartmentIdProvider).asData?.value ??
                                  "",
                              ref.watch(planTittleProvider),
                              ref.watch(questListProvider));

                          // ref.read(examQsizeListProvider.notifier).state =
                          //     await UniversityService().getExamSchemaTotalQandP(
                          //   ref.watch(luniIdProvider).asData?.value ?? " ",
                          //   ref.watch(lfacultyIdProvider).asData?.value ?? " ",
                          //   ref.watch(ldepartmentIdProvider).asData?.value ??
                          //       " ",
                          // );

                          ref.read(planPageProvider.notifier).state = 0;
                          ref.read(selectedQuestProvider.notifier).state = 0;
                          ref.read(totalCountProvider.notifier).state = 100;
                          ref.read(planTittleProvider.notifier).state = "";
                          ref.read(questListProvider.notifier).state = [];
                          ref.read(questList2Provider.notifier).state = [];
                          ref.read(testListProvider.notifier).state = [];
                          ref.read(questionPointProvider.notifier).state = "";
                          ref.read(classicTextProvider.notifier).state = "";
                          ref.read(firstGFProvider.notifier).state = "";
                          ref.read(lastGFProvider.notifier).state = "";
                          ref.read(tfTextProvider.notifier).state = "";
                          ref.read(testTextProvider.notifier).state = "";
                          ref.read(testListAnswerProvider.notifier).state = "";
                          ref
                              .read(answerControllerProvider.notifier)
                              .state
                              .text = "";
                          ref
                              .read(question1ControllerProvider.notifier)
                              .state
                              .text = "";
                          ref
                              .read(question2ControllerProvider.notifier)
                              .state
                              .text = "";
                        } else {
                          if (ref.watch(testListProvider).length <= 1) {
                            showSnackBarWidget(
                              context,
                              "Taslağı kaydedebilmek için\nlütfen taslak adı giriniz.",
                            );
                          }
                        }
                      },
                      icon: Icon(
                        Icons.save,
                        size: 30,
                        color: Colors.grey.shade800,
                      ),
                      label: Text(
                        size.width > 1600 ? "Kaydet ve çık" : "",
                        style: Design().poppins(
                          color: Colors.grey.shade800,
                          size: 15,
                          fw: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: const Size(50, 50),
                        backgroundColor:
                            const Color.fromARGB(255, 226, 229, 233),
                        foregroundColor: const Color.fromRGBO(246, 153, 92, 1),
                        shadowColor: Colors.transparent,
                      ),
                    ),
                  ),
                  Transform.scale(
                    scale: 0.8,
                    child: IconButton(
                      onPressed: () {
                        ref.read(planPageProvider.notifier).state = 0;
                        ref.read(selectedQuestProvider.notifier).state = 0;
                        ref.read(totalCountProvider.notifier).state = 100;
                        ref.read(planTittleProvider.notifier).state = "";
                        ref.read(questListProvider.notifier).state = [];
                        ref.read(questList2Provider.notifier).state = [];
                        ref.read(testListProvider.notifier).state = [];
                        ref.read(questionPointProvider.notifier).state = "";
                        ref.read(classicTextProvider.notifier).state = "";
                        ref.read(firstGFProvider.notifier).state = "";
                        ref.read(lastGFProvider.notifier).state = "";
                        ref.read(tfTextProvider.notifier).state = "";
                        ref.read(testTextProvider.notifier).state = "";
                        ref.read(testListAnswerProvider.notifier).state = "";
                        ref.read(answerControllerProvider.notifier).state.text =
                            "";
                        ref
                            .read(question1ControllerProvider.notifier)
                            .state
                            .text = "";
                        ref
                            .read(question2ControllerProvider.notifier)
                            .state
                            .text = "";
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
                        hoverColor: const Color.fromARGB(255, 196, 198, 202),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        size.width > 1600
            ? const Row(
                children: [
                  Column(
                    children: [
                      PlanPageTopLeftWidget(),
                      PlanPageBottomLeftWidget(),
                    ],
                  ),
                  PlanPageRightWidget(),
                ],
              )
            : const Column(
                children: [
                  PlanPageTopLeftWidget(),
                  PlanPageBottomLeftWidget(),
                  PlanPageRightWidget(),
                ],
              ),
      ],
    );
  }
}

class PlanPageTopLeftWidget extends ConsumerWidget {
  const PlanPageTopLeftWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(
        top: 40,
        bottom: 20,
        left: 40,
        right: size.width > 1600 ? 20 : 40,
      ),
      width: size.width > 1600 ? (size.width - 65) / 3 : size.width,
      height: 200,
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
                "Taslak Adı",
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
                  ref.read(planTittleProvider.notifier).state = value;
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
          ],
        ),
      ),
    );
  }
}

class PlanPageBottomLeftWidget extends ConsumerWidget {
  const PlanPageBottomLeftWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        bottom: size.width > 1600 ? 40 : 20,
        left: 40,
        right: size.width > 1600 ? 20 : 40,
      ),
      width: size.width > 1600 ? (size.width - 65) / 3 : size.width,
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Sorular",
                    style: Design().poppins(
                      size: 16,
                      fw: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      if (ref.watch(totalCountProvider) == 0) {
                        showSnackBarWidget(
                          context,
                          "Toplam 100 puanlık soru oluşturdunuz.",
                        );
                      } else {
                        ref.read(questionPointProvider.notifier).state = "0";
                        ref.read(answerProvider.notifier).state = "";
                        ref
                            .read(question1ControllerProvider.notifier)
                            .state
                            .text = "";
                        ref
                            .read(question2ControllerProvider.notifier)
                            .state
                            .text = "";
                        ref.read(questList2Provider.notifier).state =
                            ref.watch(questListProvider);
                        ref.read(questList2Provider.notifier).state.add(
                              EmptyQuestion(
                                point: "0",
                                key: ValueKey(DateTime.now().toString()),
                              ),
                            );
                        // ignore: unused_result
                        ref.invalidate(questListProvider);
                        ref.read(questListProvider.notifier).state =
                            ref.watch(questList2Provider);
                        ref.invalidate(quistionTypeProvider);
                        ref.read(quistionTypeProvider.notifier).state =
                            questionTypeList.keys.toList().indexOf(ref
                                .watch(questListProvider)[
                                    ref.watch(selectedQuestProvider)]
                                .runtimeType);
                      }
                    },
                    icon: const Icon(Icons.add_rounded),
                    color: const Color.fromRGBO(83, 145, 101, 1),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer(
                builder: (context, watch, child) {
                  final questList = ref.watch(questListProvider);
                  return ref.watch(questListProvider).isNotEmpty
                      ? ReorderableListView(
                          proxyDecorator: (child, index, animation) =>
                              proxyDecorator(
                            child,
                            index,
                            animation,
                          ),
                          onReorderStart: (index) {
                            ref.read(questionPointProvider.notifier).state =
                                "0";
                            ref.read(answerProvider.notifier).state = "";
                            ref
                                .read(question1ControllerProvider.notifier)
                                .state
                                .text = "";
                            ref
                                .read(question2ControllerProvider.notifier)
                                .state
                                .text = "";
                            ref.watch(selectedQuestProvider.notifier).state =
                                index;
                            ref.read(questionPointProvider.notifier).state =
                                ref.watch(questListProvider)[index].point;
                            ref.read(questionPointProvider.notifier).state =
                                "0";
                            ref
                                .read(questionPointControllerProvider.notifier)
                                .state
                                .clear();
                            ref.invalidate(quistionTypeProvider);
                            ref.read(quistionTypeProvider.notifier).state =
                                questionTypeList.keys.toList().indexOf(ref
                                    .watch(questListProvider)[
                                        ref.watch(selectedQuestProvider)]
                                    .runtimeType);
                            if (ref.watch(quistionTypeProvider) == 2) {
                              ref
                                      .read(question1ControllerProvider.notifier)
                                      .state
                                      .text =
                                  ref
                                      .watch(questListProvider)[
                                          ref.watch(selectedQuestProvider)]
                                      .firstText;
                              ref
                                      .read(question2ControllerProvider.notifier)
                                      .state
                                      .text =
                                  ref
                                      .watch(questListProvider)[
                                          ref.watch(selectedQuestProvider)]
                                      .lastText;
                              ref.read(answerProvider.notifier).state = ref
                                  .watch(questListProvider)[
                                      ref.watch(selectedQuestProvider)]
                                  .correctAnswer;
                            } else if (ref.watch(quistionTypeProvider) != 0) {
                              ref
                                      .read(question1ControllerProvider.notifier)
                                      .state
                                      .text =
                                  ref
                                      .watch(questListProvider)[
                                          ref.watch(selectedQuestProvider)]
                                      .text;
                              if (ref.watch(quistionTypeProvider) == 3) {
                                ref.read(tfAnswerProvider.notifier).state =
                                    int.tryParse(ref
                                        .watch(questListProvider)[
                                            ref.watch(selectedQuestProvider)]
                                        .correctAnswer)!;
                              } else if (ref.watch(quistionTypeProvider) == 5) {
                                ref.read(testListProvider.notifier).state = ref
                                    .watch(questListProvider)[
                                        ref.watch(selectedQuestProvider)]
                                    .options;
                                ref
                                        .read(testListAnswerProvider.notifier)
                                        .state =
                                    ref
                                        .watch(questListProvider)[
                                            ref.watch(selectedQuestProvider)]
                                        .options
                                        .indexOf(ref
                                            .watch(questListProvider)[ref
                                                .watch(selectedQuestProvider)]
                                            .correctAnswer);
                              }
                            }
                          },
                          children: [
                            for (int index = 0;
                                index < questList.length;
                                index++)
                              QuestListCardWidget(
                                index: index,
                                key: ref.watch(questListProvider)[index].key,
                              )
                          ],
                          onReorder: (oldIndex, newIndex) {
                            if (oldIndex < newIndex) {
                              newIndex--;
                            }
                            final List<dynamic> updatedList = [...questList];
                            final movedItem = updatedList.removeAt(oldIndex);
                            updatedList.insert(newIndex, movedItem);
                            ref.read(questListProvider.notifier).state =
                                updatedList;
                            ref.read(selectedQuestProvider.notifier).state =
                                newIndex;
                          },
                        )
                      : Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: const Color.fromARGB(255, 226, 229, 233),
                          ),
                          child: Text(
                            "Soru Eklenmedi",
                            style: Design().poppins(
                              size: 14,
                              color: Colors.grey.shade600,
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

Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
  return AnimatedBuilder(
    animation: animation,
    builder: (BuildContext context, Widget? child) {
      final double animValue = Curves.easeInOut.transform(animation.value);
      final double elevation = lerpDouble(0, 6, animValue)!;
      return Material(
        elevation: elevation,
        color: Colors.transparent,
        shadowColor: Colors.transparent,
        child: child,
      );
    },
    child: child,
  );
}

final questListProvider = StateProvider<List<dynamic>>((ref) => []);
final questList2Provider = StateProvider<List<dynamic>>((ref) => []);
final questionPointControllerProvider = StateProvider(
  (ref) => TextEditingController(),
);
final answerControllerProvider = StateProvider(
  (ref) => TextEditingController(),
);

final question1ControllerProvider = StateProvider(
  (ref) => TextEditingController(),
);
final question2ControllerProvider = StateProvider(
  (ref) => TextEditingController(),
);

final questionTypeList = {
  EmptyQuestion: "Yeni Soru",
  ClassicQuestion: "Klasik Soru",
  GapFillingQuestion: "Boşluk Doldurma Sorusu",
  TrueFalseQuestion: "Doğru-Yanlış Sorusu",
  TextQuestion: "Metin Cevaplı Soru",
  TestQuestion: "Test Sorusu",
};

class QuestListCardWidget extends ConsumerWidget {
  const QuestListCardWidget({
    super.key,
    required this.index,
  });

  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      color: ref.watch(selectedQuestProvider) == index
          ? const Color.fromARGB(255, 226, 229, 233)
          : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          ref.read(question1ControllerProvider.notifier).state.text = "";
          ref.read(question2ControllerProvider.notifier).state.text = "";
          ref.read(questionPointProvider.notifier).state = "0";
          ref.read(answerProvider.notifier).state = "";
          ref.read(selectedQuestProvider.notifier).state = index;
          ref.invalidate(quistionTypeProvider);
          ref.read(quistionTypeProvider.notifier).state = questionTypeList.keys
              .toList()
              .indexOf(ref
                  .watch(questListProvider)[ref.watch(selectedQuestProvider)]
                  .runtimeType);

          if (ref.watch(quistionTypeProvider) == 2) {
            ref.read(question1ControllerProvider.notifier).state.text = ref
                .watch(questListProvider)[ref.watch(selectedQuestProvider)]
                .firstText;
            ref.read(question2ControllerProvider.notifier).state.text = ref
                .watch(questListProvider)[ref.watch(selectedQuestProvider)]
                .lastText;
            ref.read(answerProvider.notifier).state = ref
                .watch(questListProvider)[ref.watch(selectedQuestProvider)]
                .correctAnswer;
          } else if (ref.watch(quistionTypeProvider) != 0) {
            ref.read(question1ControllerProvider.notifier).state.text = ref
                .watch(questListProvider)[ref.watch(selectedQuestProvider)]
                .text;
            if (ref.watch(quistionTypeProvider) == 3) {
              ref.read(tfAnswerProvider.notifier).state = int.tryParse(ref
                  .watch(questListProvider)[ref.watch(selectedQuestProvider)]
                  .correctAnswer)!;
            } else if (ref.watch(quistionTypeProvider) == 5) {
              ref.read(testListProvider.notifier).state = ref
                  .watch(questListProvider)[ref.watch(selectedQuestProvider)]
                  .options;
              ref.read(testListAnswerProvider.notifier).state = ref
                  .watch(questListProvider)[ref.watch(selectedQuestProvider)]
                  .options
                  .indexOf(ref
                      .watch(
                          questListProvider)[ref.watch(selectedQuestProvider)]
                      .correctAnswer);
            }
          }

          ref.read(questionPointControllerProvider.notifier).state.clear();
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
          tileColor: ref.watch(selectedQuestProvider) == index
              ? const Color.fromARGB(255, 226, 229, 233)
              : Colors.white,
          title: Text(
            questionTypeList[ref.watch(questListProvider)[index].runtimeType]
                .toString(),
            style: Design().poppins(
              color: Colors.grey.shade800,
              fw: FontWeight.bold,
              size: 15,
            ),
          ),
          subtitle: Text(
            ref.watch(questListProvider)[index].point + " Puan",
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
                color: const Color.fromRGBO(246, 153, 92, 1),
                size: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          trailing: Padding(
            padding: const EdgeInsets.only(right: 20),
            child: IconButton(
              onPressed: () {
                showTextDialog(
                  context: context,
                  color: const Color.fromRGBO(211, 118, 118, 1),
                  ref: ref,
                  buttonText: "Sil",
                  tittleText: "Silmek istediğinize emin misiniz?",
                  centerText: "Soru listeden kaldırılacak.",
                  icon: Icons.delete_forever,
                  buttonFunc: () {
                    Navigator.pop(context);
                    ref.read(totalCountProvider.notifier).state +=
                        int.parse(ref.watch(questListProvider)[index].point);
                    ref.invalidate(selectedQuestProvider);
                    ref.read(selectedQuestProvider.notifier).state == 0;
                    ref.read(questList2Provider.notifier).state =
                        ref.watch(questListProvider);
                    ref.read(questList2Provider.notifier).state.removeAt(index);

                    ref.invalidate(questListProvider);
                    ref.read(questListProvider.notifier).state =
                        ref.watch(questList2Provider);
                  },
                );
              },
              icon: const Icon(
                Icons.delete,
                color: Color.fromRGBO(211, 118, 118, 1),
                size: 19,
              ),
              style: IconButton.styleFrom(
                hoverColor: Colors.grey.shade200,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PlanPageRightWidget extends ConsumerWidget {
  const PlanPageRightWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Container(
      padding: EdgeInsets.only(
        top: size.width > 1600 ? 40 : 20,
        bottom: 40,
        left: size.width > 1600 ? 20 : 40,
        right: 40,
      ),
      width: size.width > 1600 ? ((size.width - 65) / 3) * 2 : size.width,
      height: size.width > 1600 ? 900 : 1200,
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
                ref.watch(questListProvider).isNotEmpty
                    ? "${ref.watch(selectedQuestProvider) + 1}. Soru"
                    : "Soru Detayı",
                style: Design().poppins(
                  size: 16,
                  fw: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            ref.watch(questListProvider).isNotEmpty
                ? Expanded(
                    child: Column(
                      children: [
                        size.width > 900
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  const ChangeQuestTypeDBWidget(),
                                  const QuestPointTFFWidget(),
                                  Align(
                                    alignment: Alignment.center,
                                    child: SizedBox(
                                      width: ((size.width - 65) / 3) - 20,
                                      height: 50,
                                      child: const SaveQuestionButton(),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const ChangeQuestTypeDBWidget(),
                                  const SizedBox(height: 10),
                                  const QuestPointTFFWidget(),
                                  const SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: SizedBox(
                                      width: ((size.width - 65) / 2),
                                      height: 50,
                                      child: const SaveQuestionButton(),
                                    ),
                                  ),
                                ],
                              ),
                        const SizedBox(height: 20),
                        Flexible(
                          child: switch (ref.watch(quistionTypeProvider)) {
                            0 => Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color:
                                      const Color.fromARGB(255, 226, 229, 233),
                                ),
                                child: Text(
                                  "Soru Tipi Seçilmedi",
                                  style: Design().poppins(
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            1 => const ClassicQuestionWidget(),
                            2 => const GapFillingQuestionWidget(),
                            3 => const TrueFalseQuestionWidget(),
                            4 => const TextQuestionWidget(),
                            5 => const TestQuestionWidget(),
                            _ => Container(),
                          },
                        )
                      ],
                    ),
                  )
                : Expanded(
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color.fromARGB(255, 226, 229, 233),
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
          ],
        ),
      ),
    );
  }
}

class ChangeQuestTypeDBWidget extends ConsumerWidget {
  const ChangeQuestTypeDBWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 55,
      width: 200,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 226, 229, 233),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton(
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
        value: ref.watch(quistionTypeProvider),
        onChanged: (value) {
          ref.read(quistionTypeProvider.notifier).state = value ?? 0;
        },
        items: const [
          DropdownMenuItem(
            value: 0,
            child: Text('Lütfen soru tipi seçiniz'),
          ),
          DropdownMenuItem(
            value: 1,
            child: Text('Klasik soru'),
          ),
          DropdownMenuItem(
            value: 2,
            child: Text('Boşluk doldurma'),
          ),
          DropdownMenuItem(
            value: 3,
            child: Text('Doğru - Yanlış sorusu'),
          ),
          DropdownMenuItem(
            value: 4,
            child: Text('Metin sorusu'),
          ),
          DropdownMenuItem(
            value: 5,
            child: Text('Test sorusu'),
          ),
        ],
      ),
    );
  }
}

class QuestPointTFFWidget extends ConsumerWidget {
  const QuestPointTFFWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
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
            controller: ref.watch(questionPointControllerProvider),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
              ref.watch(totalCountProvider) > 0
                  ? LimitRangeTextInputFormatter(
                      0,
                      ref.watch(totalCountProvider) +
                          int.parse(ref
                              .read(questListProvider.notifier)
                              .state[ref.watch(selectedQuestProvider)]
                              .point),
                    )
                  : LimitRangeTextInputFormatter(
                      0,
                      int.parse(ref
                          .read(questListProvider.notifier)
                          .state[ref.watch(selectedQuestProvider)]
                          .point)),
            ],
            textAlign: TextAlign.center,
            onChanged: (value) {
              ref.read(questionPointProvider.notifier).state = value;
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
              hintText: ref
                  .watch(questListProvider)[ref.watch(selectedQuestProvider)]
                  .point,
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
      ],
    );
  }
}

class SaveQuestionButton extends ConsumerWidget {
  const SaveQuestionButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () async {
        if (ref.watch(questListProvider).length != 1 &&
            ref.watch(questListProvider).any((element) =>
                int.parse(element.point) == 0 &&
                ref
                        .read(questListProvider.notifier)
                        .state[ref.watch(selectedQuestProvider)] !=
                    element) &&
            ref.watch(totalCountProvider) ==
                int.parse(ref.watch(questionPointProvider))) {
          showSnackBarWidget(
            context,
            """Puanlaması tamamlanmamış sorularınız var."""
            """\nKalan puanları bu soruya veremezsiniz.""",
          );
        } else {
          //? Seçilen soru tipine göre boşluk kontrolü yapılır ve
          //? kabul edilirse listeye eklenir
          int x = 0;
          switch (ref.watch(quistionTypeProvider)) {
            case 1:
              {
                if (ref.watch(classicTextProvider).isNotEmpty) {
                  ref
                          .read(questListProvider.notifier)
                          .state[ref.watch(selectedQuestProvider)] =
                      ClassicQuestion(
                    photoUrl: "", //! BURAYA RESIM URL GELECEK
                    text: ref.watch(classicTextProvider),
                    point: ref
                        .read(questListProvider.notifier)
                        .state[ref.watch(selectedQuestProvider)]
                        .point,
                    key: ref
                        .read(questListProvider.notifier)
                        .state[ref.watch(selectedQuestProvider)]
                        .key,
                  );
                  x = 1;
                }
              }
              break;
            case 2:
              {
                if (ref.watch(firstGFProvider).isNotEmpty &&
                    ref.watch(lastGFProvider).isNotEmpty &&
                    ref.watch(answerProvider).isNotEmpty) {
                  ref
                          .read(questListProvider.notifier)
                          .state[ref.watch(selectedQuestProvider)] =
                      GapFillingQuestion(
                    firstText: ref.watch(firstGFProvider),
                    lastText: ref.watch(lastGFProvider),
                    correctAnswer: ref.watch(answerProvider),
                    point: ref
                        .read(questListProvider.notifier)
                        .state[ref.watch(selectedQuestProvider)]
                        .point,
                    key: ref
                        .read(questListProvider.notifier)
                        .state[ref.watch(selectedQuestProvider)]
                        .key,
                  );
                  x = 1;
                } else {
                  showSnackBarWidget(
                    context,
                    "Doğru cevabı ekleyiniz.",
                  );
                }
              }
              break;
            case 3:
              {
                if (ref.watch(tfTextProvider).isNotEmpty) {
                  ref
                          .read(questListProvider.notifier)
                          .state[ref.watch(selectedQuestProvider)] =
                      TrueFalseQuestion(
                    text: ref.watch(tfTextProvider),
                    correctAnswer: ref.watch(tfAnswerProvider).toString(),
                    point: ref
                        .read(questListProvider.notifier)
                        .state[ref.watch(selectedQuestProvider)]
                        .point,
                    key: ref
                        .read(questListProvider.notifier)
                        .state[ref.watch(selectedQuestProvider)]
                        .key,
                  );
                  x = 1;
                }
              }
              break;
            case 4:
              {
                if (ref.watch(textTextProvider).isNotEmpty) {
                  ref
                      .read(questListProvider.notifier)
                      .state[ref.watch(selectedQuestProvider)] = TextQuestion(
                    photoUrl: "", //! BURAYA RESIM URL GELECEK
                    text: ref.watch(textTextProvider),
                    point: ref
                        .read(questListProvider.notifier)
                        .state[ref.watch(selectedQuestProvider)]
                        .point,
                    key: ref
                        .read(questListProvider.notifier)
                        .state[ref.watch(selectedQuestProvider)]
                        .key,
                  );
                  x = 1;
                }
              }
              break;
            case 5:
              {
                if (ref.watch(testTextProvider).isNotEmpty &&
                    ref.watch(testListProvider).length > 1) {
                  ref
                      .read(questListProvider.notifier)
                      .state[ref.watch(selectedQuestProvider)] = TestQuestion(
                    photoUrl: "",
                    text: ref.watch(testTextProvider),
                    options: ref.watch(testListProvider),
                    correctAnswer: ref.watch(testListAnswerProvider),
                    point: ref
                        .read(questListProvider.notifier)
                        .state[ref.watch(selectedQuestProvider)]
                        .point,
                    key: ref
                        .read(questListProvider.notifier)
                        .state[ref.watch(selectedQuestProvider)]
                        .key,
                  );
                  x = 1;
                }
                if (ref.watch(testListProvider).length <= 1) {
                  showSnackBarWidget(
                    context,
                    "Soruya en az 2 seçenek eklenmeli.",
                  );
                }
              }
              break;
            default:
              {
                x = 1;
              }
          }
          if (x == 1) {
            //? Toplam puan hesaplanır
            ref.read(totalCountProvider.notifier).state -=
                (int.parse(ref.watch(questionPointProvider)) -
                    int.parse(ref
                        .read(questListProvider.notifier)
                        .state[ref.watch(selectedQuestProvider)]
                        .point));
            //? Seçili sorunun puanı tekrar yazılır
            ref
                .read(questListProvider.notifier)
                .state[ref.watch(selectedQuestProvider)]
                .point = ref.watch(questionPointProvider);
            //? Liste yenilenir
            ref.read(questList2Provider.notifier).state =
                ref.watch(questListProvider);

            ref.invalidate(questListProvider);
            ref.read(questListProvider.notifier).state =
                ref.watch(questList2Provider);

            ref.read(questionPointControllerProvider.notifier).state.clear();
            showSnackBarWidget(
              context,
              "Soru Kaydedildi.",
              color: const Color.fromRGBO(83, 145, 101, 1),
              icon: Icons.check,
            );
          } else {
            showSnackBarWidget(
              context,
              "Soru tamamlanmadan kayıt işlemi yapılamaz.",
            );
          }
        }
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
        "Soruyu Kaydet",
        style: Design().poppins(
          color: Colors.white,
          size: 15,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class LimitRangeTextInputFormatter extends TextInputFormatter {
  LimitRangeTextInputFormatter(this.min, this.max,
      {this.defaultIfEmpty = false})
      : assert(min < max);

  final int min;
  final int max;
  final bool defaultIfEmpty;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    int? value = int.tryParse(newValue.text);
    String? enforceValue;
    if (value != null) {
      if (value < min) {
        enforceValue = min.toString();
      } else if (value > max) {
        enforceValue = max.toString();
      }
    } else {
      if (defaultIfEmpty) {
        enforceValue = min.toString();
      }
    }
    // filtered interval result
    if (enforceValue != null) {
      return TextEditingValue(
          text: enforceValue,
          selection: TextSelection.collapsed(offset: enforceValue.length));
    }
    // value that fit requirements
    return newValue;
  }
}

class ClassicQuestionWidget extends ConsumerWidget {
  const ClassicQuestionWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return size.width > 900
        ? Row(
            children: [
              Flexible(
                flex: 1,
                child: Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 226, 229, 233),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Soruya Resim Eklenmedi",
                          style: Design().poppins(
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    Flexible(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {},
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor:
                              const Color.fromRGBO(246, 153, 92, 1),
                          foregroundColor:
                              const Color.fromARGB(255, 226, 229, 233),
                          shadowColor: Colors.transparent,
                        ),
                        child: Text(
                          "Resim Ekle",
                          style: Design().poppins(
                            color: Colors.white,
                            size: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              const SizedBox(width: 30),
              const ClassicQuestTextWidget(),
            ],
          )
        : Column(
            children: [
              Flexible(
                flex: 1,
                child: Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 226, 229, 233),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Soruya Resim Eklenmedi",
                          style: Design().poppins(
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    Flexible(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {},
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor:
                              const Color.fromRGBO(246, 153, 92, 1),
                          foregroundColor:
                              const Color.fromARGB(255, 226, 229, 233),
                          shadowColor: Colors.transparent,
                        ),
                        child: Text(
                          "Resim Ekle",
                          style: Design().poppins(
                            color: Colors.white,
                            size: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              const ClassicQuestTextWidget(),
            ],
          );
  }
}

class ClassicQuestTextWidget extends ConsumerWidget {
  const ClassicQuestTextWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      flex: 2,
      child: TextFormField(
        controller: ref.watch(question1ControllerProvider),
        onChanged: (value) {
          ref.read(classicTextProvider.notifier).state = value;
        },
        style: Design().poppins(
          size: 14,
          color: Colors.grey.shade700,
        ),
        cursorColor: Colors.grey.shade600,
        cursorWidth: 2,
        minLines: 30,
        maxLines: 30,
        cursorRadius: const Radius.circular(25),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(
            left: 30,
            right: 30,
            top: 40,
          ),
          hintText: "Soru Alanı",
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
    );
  }
}

class GapFillingQuestionWidget extends ConsumerWidget {
  const GapFillingQuestionWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    //! EKSİK
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: ref.watch(question1ControllerProvider),
                onChanged: (value) {
                  ref.read(firstGFProvider.notifier).state = value;
                },
                style: Design().poppins(
                  size: 14,
                  color: Colors.grey.shade700,
                ),
                cursorColor: Colors.grey.shade600,
                cursorWidth: 2,
                minLines: 5,
                maxLines: 5,
                cursorRadius: const Radius.circular(25),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(
                    left: 30,
                    right: 30,
                    top: 40,
                  ),
                  hintText: "Boşluk öncesi bölüm",
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
              Container(
                padding: const EdgeInsets.only(
                  left: 40,
                  right: 40,
                  top: 15,
                  bottom: 15,
                ),
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 226, 229, 233),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "...",
                  style: Design().poppins(fw: FontWeight.bold, size: 20, ls: 2),
                ),
              ),
              TextFormField(
                controller: ref.watch(question2ControllerProvider),
                onChanged: (value) {
                  ref.read(lastGFProvider.notifier).state = value;
                },
                style: Design().poppins(
                  size: 14,
                  color: Colors.grey.shade700,
                ),
                cursorColor: Colors.grey.shade600,
                cursorWidth: 2,
                minLines: 5,
                maxLines: 5,
                cursorRadius: const Radius.circular(25),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(
                    left: 30,
                    right: 30,
                    top: 40,
                  ),
                  hintText: "Boşluk sonrası bölüm",
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
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Cevap:   ",
                      style: Design().poppins(
                        size: 16,
                        fw: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Container(
                      width: size.width > 900 ? 300 : 150,
                      height: 55,
                      alignment: Alignment.center,
                      child: TextFormField(
                        controller: ref.watch(answerControllerProvider),
                        textAlign: TextAlign.center,
                        onChanged: (value) {
                          ref.read(answerProvider.notifier).state = value;
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
                          hintText: "",
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TrueFalseQuestionWidget extends ConsumerWidget {
  const TrueFalseQuestionWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    //! EKSİK
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: ref.watch(question1ControllerProvider),
                onChanged: (value) {
                  ref.read(tfTextProvider.notifier).state = value;
                },
                style: Design().poppins(
                  size: 14,
                  color: Colors.grey.shade700,
                ),
                cursorColor: Colors.grey.shade600,
                cursorWidth: 2,
                minLines: 5,
                maxLines: 5,
                cursorRadius: const Radius.circular(25),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.only(
                    left: 30,
                    right: 30,
                    top: 40,
                  ),
                  hintText: "Soru Alanı",
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
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.all(40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Cevap:   ",
                      style: Design().poppins(
                        size: 16,
                        fw: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        left: size.width > 900 ? 40 : 20,
                        right: size.width > 900 ? 40 : 20,
                        top: 15,
                        bottom: 15,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 226, 229, 233),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          TFQuestionAnswerListWidget(
                            func: () {
                              ref.read(tfAnswerProvider.notifier).state = 1;
                            },
                            boolenType: 0,
                            text: "Doğru",
                          ),
                          const SizedBox(height: 10),
                          TFQuestionAnswerListWidget(
                            func: () {
                              ref.read(tfAnswerProvider.notifier).state = 0;
                            },
                            boolenType: 1,
                            text: "Yanlış",
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class TFQuestionAnswerListWidget extends ConsumerWidget {
  const TFQuestionAnswerListWidget({
    super.key,
    required this.func,
    required this.boolenType,
    required this.text,
  });

  final Function() func;
  final int boolenType;
  final String text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: func,
      child: AnimatedContainer(
        padding: const EdgeInsets.only(
          left: 40,
          right: 40,
          top: 15,
          bottom: 15,
        ),
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: ref.watch(tfAnswerProvider) == boolenType
              ? const Color.fromARGB(255, 226, 229, 233)
              : boolenType == 0
                  ? const Color.fromRGBO(83, 145, 101, 1)
                  : const Color.fromRGBO(211, 118, 118, 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: Design().poppins(
            size: 14,
            color: ref.watch(tfAnswerProvider) == boolenType
                ? Colors.black
                : Colors.white,
          ),
        ),
      ),
    );
  }
}

class TextQuestionWidget extends ConsumerWidget {
  const TextQuestionWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return size.width > 900
        ? Row(
            children: [
              Flexible(
                flex: 1,
                child: Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 226, 229, 233),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Soruya Resim Eklenmedi",
                          style: Design().poppins(
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    Flexible(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {},
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor:
                              const Color.fromRGBO(246, 153, 92, 1),
                          foregroundColor:
                              const Color.fromARGB(255, 226, 229, 233),
                          shadowColor: Colors.transparent,
                        ),
                        child: Text(
                          "Resim Ekle",
                          style: Design().poppins(
                            color: Colors.white,
                            size: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              const SizedBox(width: 30),
              const TextQuestTextWidget(),
            ],
          )
        : Column(
            children: [
              Flexible(
                flex: 1,
                child: Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 226, 229, 233),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Soruya Resim Eklenmedi",
                          style: Design().poppins(
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    Flexible(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {},
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor:
                              const Color.fromRGBO(246, 153, 92, 1),
                          foregroundColor:
                              const Color.fromARGB(255, 226, 229, 233),
                          shadowColor: Colors.transparent,
                        ),
                        child: Text(
                          "Resim Ekle",
                          style: Design().poppins(
                            color: Colors.white,
                            size: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              const TextQuestTextWidget(),
            ],
          );
  }
}

class TextQuestTextWidget extends ConsumerWidget {
  const TextQuestTextWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      flex: 2,
      child: TextFormField(
        controller: ref.watch(question1ControllerProvider),
        onChanged: (value) {
          ref.read(textTextProvider.notifier).state = value;
        },
        style: Design().poppins(
          size: 14,
          color: Colors.grey.shade700,
        ),
        cursorColor: Colors.grey.shade600,
        cursorWidth: 2,
        minLines: 30,
        maxLines: 30,
        cursorRadius: const Radius.circular(25),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(
            left: 30,
            right: 30,
            top: 40,
          ),
          hintText: "Soru Alanı",
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
    );
  }
}

class TestQuestionWidget extends ConsumerWidget {
  const TestQuestionWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return size.width > 900
        ? Row(
            children: [
              Flexible(
                flex: 1,
                child: Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 226, 229, 233),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Soruya Resim Eklenmedi",
                          style: Design().poppins(
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    Flexible(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {},
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor:
                              const Color.fromRGBO(246, 153, 92, 1),
                          foregroundColor:
                              const Color.fromARGB(255, 226, 229, 233),
                          shadowColor: Colors.transparent,
                        ),
                        child: Text(
                          "Resim Ekle",
                          style: Design().poppins(
                            color: Colors.white,
                            size: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              const SizedBox(width: 30),
              const TestQuestTextWidget(),
            ],
          )
        : Column(
            children: [
              Flexible(
                flex: 1,
                child: Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 226, 229, 233),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "Soruya Resim Eklenmedi",
                          style: Design().poppins(
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    Flexible(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () async {},
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          backgroundColor:
                              const Color.fromRGBO(246, 153, 92, 1),
                          foregroundColor:
                              const Color.fromARGB(255, 226, 229, 233),
                          shadowColor: Colors.transparent,
                        ),
                        child: Text(
                          "Resim Ekle",
                          style: Design().poppins(
                            color: Colors.white,
                            size: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              const TestQuestTextWidget(),
            ],
          );
  }
}

class TestQuestTextWidget extends ConsumerWidget {
  const TestQuestTextWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      flex: 2,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: TextFormField(
              controller: ref.watch(question1ControllerProvider),
              onChanged: (value) {
                ref.read(testTextProvider.notifier).state = value;
              },
              style: Design().poppins(
                size: 14,
                color: Colors.grey.shade700,
              ),
              cursorColor: Colors.grey.shade600,
              cursorWidth: 2,
              minLines: 15,
              maxLines: 15,
              cursorRadius: const Radius.circular(25),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(
                  left: 30,
                  right: 30,
                  top: 40,
                ),
                hintText: "Soru Alanı",
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
          const SizedBox(height: 50),
          Flexible(
            flex: 2,
            child: Container(
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Seçenekler",
                          style: Design().poppins(
                            size: 16,
                            fw: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            showSurveyDialog(
                              context: context,
                              ref: ref,
                              buttonText: "Oluştur",
                              tittleText: "Seçenek Ekle",
                              children: Material(
                                color: Colors.white,
                                child: DialogTFFWidget(
                                  provider: testListNewProvider,
                                  text: "Seçenek İçeriği",
                                ),
                              ),
                              buttonFunc: () {
                                Navigator.of(context).pop();
                                if (ref.watch(testListNewProvider).isNotEmpty) {
                                  ref
                                      .read(testListProvider.notifier)
                                      .state
                                      .add(ref.watch(testListNewProvider));
                                  ref.read(testListNewProvider.notifier).state =
                                      "";
                                  ref
                                      .read(selectedTestProvider.notifier)
                                      .state = 0;
                                }
                              },
                            );
                          },
                          icon: const Icon(Icons.add_rounded),
                          color: const Color.fromRGBO(83, 145, 101, 1),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Consumer(
                      builder: (context, watch, child) {
                        return ref.watch(testListProvider).isNotEmpty
                            ? ListView.builder(
                                itemCount: ref.watch(testListProvider).length,
                                itemBuilder: (context, index) {
                                  return TextCardWidget(index: index);
                                },
                              )
                            : Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color:
                                      const Color.fromARGB(255, 226, 229, 233),
                                ),
                                child: Text(
                                  "Seçenek Eklenmedi",
                                  style: Design().poppins(
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              );
                      },
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

class TextCardWidget extends ConsumerWidget {
  const TextCardWidget({
    super.key,
    required this.index,
  });

  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      color: ref.watch(selectedTestProvider) == index
          ? const Color.fromARGB(255, 226, 229, 233)
          : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          ref.read(selectedTestProvider.notifier).state = index;
        },
        child: ListTile(
          contentPadding: const EdgeInsets.only(
            top: 10,
            bottom: 10,
            left: 20,
            right: 20,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          tileColor: ref.watch(selectedTestProvider) == index
              ? const Color.fromARGB(255, 226, 229, 233)
              : Colors.white,
          title: Text(
            ref.watch(testListProvider)[index],
            style: Design().poppins(
              color: Colors.grey.shade800,
              size: 15,
            ),
          ),
          leading: Container(
            padding: const EdgeInsets.only(right: 10),
            child: Text(
              String.fromCharCode(65 + index),
              style: Design().poppins(
                color: const Color.fromRGBO(81, 130, 155, 1),
                size: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          trailing: IconButton(
            onPressed: () {
              showTextDialog(
                context: context,
                color: const Color.fromRGBO(211, 118, 118, 1),
                ref: ref,
                buttonText: "Sil",
                tittleText: "Silmek istediğinize emin misiniz?",
                centerText: "Seçenek sorudan kaldırılacak.",
                icon: Icons.delete_forever,
                buttonFunc: () {
                  Navigator.pop(context);
                  ref.read(testListProvider.notifier).state.removeAt(index);
                  ref.read(selectedTestProvider.notifier).state = 0;
                  ref.read(testListProvider2.notifier).state =
                      ref.watch(testListProvider);
                  ref.invalidate(testListProvider);
                  ref.read(testListProvider.notifier).state =
                      ref.watch(testListProvider2);
                },
              );
            },
            icon: const Icon(
              Icons.delete,
              color: Color.fromRGBO(211, 118, 118, 1),
              size: 19,
            ),
            style: IconButton.styleFrom(
              hoverColor: Colors.grey.shade200,
            ),
          ),
        ),
      ),
    );
  }
}
