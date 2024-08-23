import 'dart:ui';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projectacademy/Pages/hub/studentpanel/homepage.dart';
import 'package:projectacademy/Pages/hub/studentpanel/joincoursepage.dart';
import 'package:projectacademy/firebaseConfig/firebase_transactionss.dart';
import 'package:projectacademy/myDesign.dart';

final quest1ControllerProvider = StateProvider(
  (ref) => TextEditingController(),
);

final quest1Provider = StateProvider((ref) => "");
final tfAnswerProvider = StateProvider((ref) => 1);
final selectedTestProvider = StateProvider((ref) => -1);

final widgetsProvider = StateProvider((ref) => <Widget>[]);
final selectedWidgetProvider = StateProvider((ref) => 0);

final answeredQuestionsProvider =
    StateProvider((ref) => <Map<String, dynamic>>[]);

class ExamSolvingPageWidget extends ConsumerWidget {
  const ExamSolvingPageWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(examFeaturesProvider)['shuffle'] == true) {
      ref.read(questionsListProvider).shuffle();
    }

    for (var i in ref.watch(questionsListProvider)) {
      if (i['type'] == "TextQuestion") {
        ref.read(widgetsProvider).add(TextQuestScreenWidget(i['answer'],
            i['key'], i['photoUrl'], i['point'], i['text'], i['type']));
      }
      if (i['type'] == "TrueFalseQuestion") {
        ref.read(widgetsProvider).add(TrueFalseQuestScreenWidget(i['answer'],
            i['correctAnswer'], i['key'], i['point'], i['text'], i['type']));
      }
      if (i['type'] == "TestQuestion") {
        ref.read(widgetsProvider).add(TestQuestScreenWidget(
            i['answer'],
            i['correctAnswer'],
            i['key'],
            List.from(i['options']),
            i['photoUrl'],
            i['point'],
            i['text'],
            i['type']));
      }
      if (i['type'] == "GapFillingQuestion") {
        ref.read(widgetsProvider).add(GapFillingQuestScreenWidget(
            i['answer'],
            i['correctAnswer'],
            i['firstText'],
            i['key'],
            i['lastText'],
            i['point'],
            i['type']));
      }
      if (i['type'] == "ClassicQuestion") {
        ref.read(widgetsProvider).add(ClassicQuestScreenWidget(
            i['answer'],
            i['answerUrl'],
            i['key'],
            i['photoUrl'],
            i['point'],
            i['text'],
            i['type']));
      }
    }

    final size = MediaQuery.of(context).size;
    return Scaffold(
      // ignore: deprecated_member_use
      body: (ui.window.display.size.height / ui.window.devicePixelRatio !=
                  MediaQuery.of(context).size.height) &&
              // ignore: deprecated_member_use
              (ui.window.display.size.width / ui.window.devicePixelRatio !=
                  MediaQuery.of(context).size.width)
          ? Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: ExactAssetImage("assets/2.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.white.withOpacity(0.5),
                    child: Container(
                      alignment: Alignment.center,
                      child: const Row(
                        children: [
                          LeftPageWidget(),
                          RightPageWidget(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          : size.height > 300
              ? Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: ExactAssetImage("assets/2.png"),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: ClipRRect(
                    // make sure we apply clip it properly
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: Colors.white.withOpacity(0.6),
                        child: Container(
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.warning_amber,
                                size: 70,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                """Sınava devam edemiyorsunuz.\n"""
                                """Lütfen tarayıcınızı tam ekran moduna alınız.""",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 18,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),
    );
  }
}

class RightPageWidget extends ConsumerWidget {
  const RightPageWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Flexible(
      flex: 1,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.only(left: 40, top: 40, bottom: 40, right: 40),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
                child: ListView.builder(
              itemCount: ref.watch(questionsListProvider).length,
              itemBuilder: (context, index) {
                var question = ref.watch(questionsListProvider)[index];
                return Card(
                  shadowColor: Colors.transparent,
                  color: ref.watch(selectedWidgetProvider) == index
                      ? const Color.fromRGBO(220, 220, 220, 1)
                      : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      if (ref.watch(examFeaturesProvider)['qPass'] == false) {
                        ref.read(selectedWidgetProvider.notifier).state = index;
                      }
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
                      tileColor: ref.watch(selectedWidgetProvider) == index
                          ? const Color.fromRGBO(220, 220, 220, 1)
                          : Colors.white,
                      title: Text(
                        question['type'],
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
                            color: const Color.fromRGBO(246, 153, 92, 1),
                            size: 18,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      trailing: Text(
                        question['point'],
                        style: Design().poppins(
                          color: Colors.grey.shade800,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                );
              },
            )),
            Container(
              height: 55,
              margin: const EdgeInsets.only(top: 20),
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color.fromRGBO(81, 130, 155, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  showSnackBarWidget(context,
                      "Sınavı başarıyla bitirdiniz.\n Cevaplarınız kaydedilmiştir.");
                },
                child: Text(
                  "Sınavı Bitir",
                  style: Design().poppins(
                    color: const Color.fromRGBO(205, 205, 205, 1),
                    fw: FontWeight.w500,
                    size: 15,
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

class LeftPageWidget extends ConsumerWidget {
  const LeftPageWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uniId = ref.watch(runiIdProvider).asData?.value ?? "";
    final facultyId = ref.watch(rfacultyIdProvider).asData?.value ?? "";
    final departmentId = ref.watch(rdepartmentIdProvider).asData?.value ?? "";
    final studentId = ref.watch(rstudentIdProvider).asData?.value ?? "";

    return Flexible(
      flex: 3,
      child: Column(
        children: [
          Flexible(
            flex: 3,
            child: Container(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.only(
                  left: 40,
                  bottom: 40,
                  top: 40,
                ),
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 10,
                  bottom: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "32:59",
                  style: Design().poppins(
                    color: Colors.grey.shade800,
                    size: 25,
                    fw: FontWeight.bold,
                    ls: 2,
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            flex: 15,
            child: Container(
              margin: const EdgeInsets.only(
                left: 40,
                bottom: 40,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  ref.watch(widgetsProvider)[ref.watch(selectedWidgetProvider)],
            ),
          ),
          Flexible(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.only(
                left: 40,
                bottom: 40,
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(60, 60, 60, 1),
                  foregroundColor: const Color.fromRGBO(83, 145, 101, 1),
                  minimumSize: const Size(
                    double.infinity,
                    double.infinity,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Colors.white, width: 4),
                  ),
                  shadowColor: Colors.transparent,
                ),
                onPressed: () {
                  if (ref.watch(questionsListProvider)[
                          ref.watch(selectedWidgetProvider)]['type'] ==
                      "TrueFalseQuestion") {
                    UniversityService().updateExam(
                        uniId,
                        facultyId,
                        departmentId,
                        studentId,
                        ref.watch(questionsListProvider)[
                            ref.watch(selectedWidgetProvider)]['key'],
                        ref.watch(tfAnswerProvider).toString(),
                        false);
                  } else if (ref.watch(questionsListProvider)[
                          ref.watch(selectedWidgetProvider)]['type'] ==
                      "TestQuestion") {
                    UniversityService().updateExam(
                        uniId,
                        facultyId,
                        departmentId,
                        studentId,
                        ref.watch(questionsListProvider)[
                            ref.watch(selectedWidgetProvider)]['key'],
                        ref.watch(selectedTestProvider).toString(),
                        false);
                  } else {
                    UniversityService().updateExam(
                        uniId,
                        facultyId,
                        departmentId,
                        studentId,
                        ref.watch(questionsListProvider)[
                            ref.watch(selectedWidgetProvider)]['key'],
                        ref.watch(quest1Provider),
                        false);
                  }

                  ref.read(quest1Provider.notifier).state = "";
                  ref.read(tfAnswerProvider.notifier).state = 0;
                  ref.read(selectedTestProvider.notifier).state = -1;

                  // tüm bilgileri questionListdeki[selectedwidgetProvider] bu şekilde çekicez çünkü quesitonList ve widgetList aynı sırada
                  // questionListdeki[selectedwidgetProvider] sorunun type'ına kontrol ettir ve ona göre fotoğraf çektir
                  // sınav ekranında listelenenleri öğrenci veritabanındaki sınav bölümünden yansıtılabilir.
                  // bilgi çekme fonksiyonları da one göre düzenlencek

                  if (ref.watch(widgetsProvider).length !=
                      ref.watch(selectedWidgetProvider) + 1) {
                    ref.read(selectedWidgetProvider.notifier).state++;
                  } else {
                    if (ref.watch(examFeaturesProvider)['qPass'] == false) {
                      ref.read(selectedWidgetProvider.notifier).state = 0;
                    }
                  }

                  // at değeri güncelle
                  UniversityService().updateExam(
                      uniId,
                      facultyId,
                      departmentId,
                      studentId,
                      ref.watch(questionsListProvider)[
                          ref.watch(selectedWidgetProvider)]['key'],
                      ref.watch(quest1Provider),
                      true);
                },
                child: Text(
                  "Cevabı Kaydet ve Sonraki Soruya Geç",
                  style: Design().poppins(
                    color: const Color.fromRGBO(205, 205, 205, 1),
                    fw: FontWeight.w500,
                    size: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//! SORU SAYFALARI

class ClassicQuestScreenWidget extends ConsumerWidget {
  final String answer;
  final String answerUrl;
  final String uniqKey;
  final String photoURL;
  final String point;
  final String text;
  final String type;
  const ClassicQuestScreenWidget(
    this.answer,
    this.answerUrl,
    this.uniqKey,
    this.photoURL,
    this.point,
    this.text,
    this.type, {
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return ListView(
      children: [
        Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(240, 240, 240, 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: photoURL == ""
                ? Image.network(
                    "https://media.istockphoto.com/id/517188688/tr/foto%C4%9Fraf/mountain-landscape.jpg?s=612x612&w=0&k=20&c=KpANCuD2dFxKw6Qy6XfMXpTHiZcsprOf0LRm2t4K9kM=",
                  )
                : Image.network(photoURL)),
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(20),
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(240, 240, 240, 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "$text?",
            style: Design().poppins(color: Colors.grey.shade800, size: 15),
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          margin: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Cevap:   ",
                style: Design().poppins(
                  size: 16,
                  fw: FontWeight.w600,
                  color: const Color.fromRGBO(60, 60, 60, 1),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: (size.width * 0.75 - 120) / 3.1,
                    height: (size.width * 0.75 - 120) / 3.1,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(right: 20),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(240, 240, 240, 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Resim Eklenmedi",
                      style: Design().poppins(
                        color: Colors.grey.shade800,
                        fw: FontWeight.bold,
                        size: 15,
                      ),
                    ),
                  ),
                  Container(
                    width: (size.width * 0.75 - 120) / 1.5,
                    height: (size.width * 0.75 - 120) / 3.1,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(240, 240, 240, 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextFormField(
                      controller: ref.watch(quest1ControllerProvider),
                      onChanged: (value) {
                        ref.read(quest1Provider.notifier).state = value;
                      },
                      style: Design().poppins(
                        size: 14,
                        color: Colors.grey.shade800,
                      ),
                      cursorColor: Colors.grey.shade800,
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
                        hintText: "Cevap Alanı",
                        hintStyle: Design().poppins(
                          size: 14,
                          color: Colors.grey.shade800,
                        ),
                        fillColor: const Color.fromRGBO(240, 240, 240, 1),
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
            ],
          ),
        ),
      ],
    );
  }
}

class TextQuestScreenWidget extends ConsumerWidget {
  final String answer;
  final String uniqKey;
  final String photoUrl;
  final String point;
  final String text;
  final String type;
  const TextQuestScreenWidget(
    this.answer,
    this.uniqKey,
    this.photoUrl,
    this.point,
    this.text,
    this.type, {
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return ListView(
      children: [
        Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(240, 240, 240, 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: photoUrl == ""
                ? Image.network(
                    "https://media.istockphoto.com/id/517188688/tr/foto%C4%9Fraf/mountain-landscape.jpg?s=612x612&w=0&k=20&c=KpANCuD2dFxKw6Qy6XfMXpTHiZcsprOf0LRm2t4K9kM=",
                  )
                : Image.network(photoUrl)),
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(20),
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(240, 240, 240, 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            style: Design().poppins(color: Colors.grey.shade800, size: 15),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(20),
          alignment: Alignment.centerLeft,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Cevap:   ",
                style: Design().poppins(
                  size: 16,
                  fw: FontWeight.w600,
                  color: const Color.fromRGBO(60, 60, 60, 1),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: (size.width * 0.75 - 120) / 3.5,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(240, 240, 240, 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextFormField(
                  controller: ref.watch(quest1ControllerProvider),
                  onChanged: (value) {
                    ref.read(quest1Provider.notifier).state = value;
                  },
                  style: Design().poppins(
                    size: 14,
                    color: Colors.grey.shade800,
                  ),
                  cursorColor: Colors.grey.shade800,
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
                    hintText: "Cevap Alanı",
                    hintStyle: Design().poppins(
                      size: 14,
                      color: Colors.grey.shade800,
                    ),
                    fillColor: const Color.fromRGBO(240, 240, 240, 1),
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
    );
  }
}

class TestQuestScreenWidget extends ConsumerWidget {
  final String answer;
  final String correctAnswer;
  final String uniqKey;
  final List<String> options;
  final String photoUrl;
  final String point;
  final String text;
  final String type;
  const TestQuestScreenWidget(
    this.answer,
    this.correctAnswer,
    this.uniqKey,
    this.options,
    this.photoUrl,
    this.point,
    this.text,
    this.type, {
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(20),
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(240, 240, 240, 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "$text?",
            style: Design().poppins(color: Colors.grey.shade800, size: 15),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(20),
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (context, index) {
              return TextCardWidget(index: index, options: options);
            },
          ),
        )
      ],
    );
  }
}

class TextCardWidget extends ConsumerWidget {
  const TextCardWidget({super.key, required this.index, required this.options});

  final int index;
  final List<String> options;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      color: ref.watch(selectedTestProvider) == index
          ? const Color.fromRGBO(240, 240, 240, 1)
          : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          ref.read(selectedTestProvider.notifier).state = index;
        },
        child: ListTile(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          tileColor: ref.watch(selectedTestProvider) == index
              ? const Color.fromRGBO(240, 240, 240, 1)
              : Colors.white,
          title: Text(
            options[index],
            style: Design().poppins(
              color: const Color.fromRGBO(60, 60, 60, 1),
              size: 15,
            ),
          ),
          leading: Container(
            padding: const EdgeInsets.only(right: 10),
            child: Text(
              String.fromCharCode(65 + index),
              style: Design().poppins(
                color: ref.watch(selectedTestProvider) == index
                    ? const Color.fromRGBO(211, 118, 118, 1)
                    : const Color.fromRGBO(60, 60, 60, 1),
                size: 18,
                fw: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class GapFillingQuestScreenWidget extends ConsumerWidget {
  final String answer;
  final String correctAnswer;
  final String firstText;
  final String uniqKey;
  final String lastText;
  final String point;
  final String type;
  const GapFillingQuestScreenWidget(
    this.answer,
    this.correctAnswer,
    this.firstText,
    this.uniqKey,
    this.lastText,
    this.point,
    this.type, {
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(20),
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(220, 220, 220, 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            "$firstText  ......  $lastText",
            style: Design().poppins(color: Colors.grey.shade800, size: 15),
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Cevap:   ",
                style: Design().poppins(
                  size: 16,
                  fw: FontWeight.w600,
                  color: const Color.fromRGBO(60, 60, 60, 1),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: (size.width * 0.75 - 120) / 3,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(220, 220, 220, 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextFormField(
                  controller: ref.watch(quest1ControllerProvider),
                  onChanged: (value) {
                    ref.read(quest1Provider.notifier).state = value;
                  },
                  style: Design().poppins(
                    size: 14,
                    color: Colors.grey.shade800,
                  ),
                  cursorColor: Colors.grey.shade800,
                  cursorWidth: 2,
                  minLines: 1,
                  maxLines: 1,
                  cursorRadius: const Radius.circular(25),
                  decoration: InputDecoration(
                    hintText: "Cevap Alanı",
                    hintStyle: Design().poppins(
                      size: 14,
                      color: Colors.grey.shade800,
                    ),
                    fillColor: const Color.fromRGBO(220, 220, 220, 1),
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
    );
  }
}

class TrueFalseQuestScreenWidget extends ConsumerWidget {
  final String answer;
  final String correctAnswer;
  final String uniqKey;
  final String point;
  final String text;
  final String type;
  const TrueFalseQuestScreenWidget(
    this.answer,
    this.correctAnswer,
    this.uniqKey,
    this.point,
    this.text,
    this.type, {
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(20),
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(240, 240, 240, 1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            text,
            style: Design().poppins(color: Colors.grey.shade800, size: 15),
          ),
        ),
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Cevap:   ",
                style: Design().poppins(
                  size: 16,
                  fw: FontWeight.w600,
                  color: const Color.fromRGBO(60, 60, 60, 1),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.only(
                  left: 40,
                  right: 40,
                  top: 15,
                  bottom: 15,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(240, 240, 240, 1),
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
              ? Colors.white
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
                ? const Color.fromRGBO(60, 60, 60, 1)
                : Colors.white,
            fw: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
