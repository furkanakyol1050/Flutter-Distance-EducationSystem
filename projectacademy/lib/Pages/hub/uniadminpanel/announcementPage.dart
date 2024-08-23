// ignore_for_file: file_names

import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:projectacademy/Pages/hub/uniadminpanel/homepage.dart';
import 'package:projectacademy/firebaseConfig/firebase_transactionss.dart';
import 'package:projectacademy/myDesign.dart';

final isPublicProvider = StateProvider((ref) => 0);

final contentProvider = StateProvider((ref) => "");
final titleProvider = StateProvider((ref) => "");

class AnnouncementPage extends ConsumerWidget {
  const AnnouncementPage({super.key});

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
                  "Üniversite Duyurusu Paylaş",
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
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        LeftTopWidget(),
                        LeftBottomWidget(),
                      ],
                    ),
                    RightWidget(),
                  ],
                )
              : const Column(
                  children: [
                    LeftTopWidget(),
                    LeftBottomWidget(),
                    RightWidget(),
                  ],
                ),
        ],
      ),
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
        bottom: 40,
        top: size.width > 1300 ? 40 : 20,
        left: size.width > 1300 ? 20 : 40,
        right: size.width > 1300 ? 40 : 40,
      ),
      width: size.width > 1300 ? (size.width - 65) / 2 : size.width - 65,
      height: size.width > 1300 ? 800 : 500,
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
                "Genel Duyurular",
                style: Design().poppins(
                  size: 16,
                  fw: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<Announcement>>(
                stream: UniversityService().getAnnouncementsStream(
                  ref.watch(userPhotoUrlProvider).asData?.value ?? "",
                  ref.watch(facultyIdProvider),
                ),
                builder: (context, snapshot) {
                  List<Announcement> announcements = snapshot.data ?? [];
                  if (!snapshot.hasData) {
                    return const Center(
                      child: SpinKitPulse(
                        color: Colors.grey,
                        size: 150,
                      ),
                    );
                  }
                  return snapshot.data!.isNotEmpty
                      ? ListView.builder(
                          itemCount: announcements.length,
                          itemBuilder: (context, index) {
                            Announcement announcement = announcements[index];
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
                                    color:
                                        const Color.fromRGBO(211, 118, 118, 1),
                                    ref: ref,
                                    buttonText: "Sil",
                                    tittleText:
                                        "Silmek istediğinize emin misiniz?",
                                    centerText: "Duyuru tamamen kaldırılacak.",
                                    icon: Icons.delete_forever,
                                    buttonFunc: () {
                                      UniversityService().deleteAnnouncement(
                                          ref
                                              .watch(userPhotoUrlProvider)
                                              .asData!
                                              .value,
                                          announcement.id);
                                      Navigator.pop(context);
                                      showSnackBarWidget(context,
                                          "Duyuru başarıyla silindi..!");
                                    },
                                  );
                                },
                                icon: Icon(
                                  Icons.delete,
                                  color: Colors.grey.shade800,
                                ),
                                style: IconButton.styleFrom(
                                  minimumSize: const Size(55, 55),
                                  hoverColor:
                                      const Color.fromARGB(255, 196, 198, 202),
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
                },
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
        top: 40,
        right: size.width > 1300 ? 20 : 40,
      ),
      width: size.width > 1300 ? ((size.width - 65) / 2) : size.width - 65,
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
                "Duyuru Ekle",
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
                  ref.read(titleProvider.notifier).state = value;
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
                    ref.read(contentProvider.notifier).state = value;
                  },
                  style: Design().poppins(
                    size: 14,
                    color: Colors.grey.shade700,
                  ),
                  cursorColor: Colors.grey.shade600,
                  cursorWidth: 2,
                  minLines: 17,
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
        bottom: size.width > 1300 ? 40 : 20,
        top: 20,
        right: size.width > 1300 ? 20 : 40,
      ),
      width: size.width > 1300 ? ((size.width - 65) / 2) : size.width - 65,
      height: 150,
      child: Container(
        alignment: size.width > 1300 ? Alignment.centerRight : Alignment.center,
        padding: const EdgeInsets.only(left: 40, right: 40),
        child: SizedBox(
          width: 150,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              ref.read(isPublicProvider.notifier).state = 1;
              if (ref.watch(titleProvider) != "" &&
                  ref.watch(contentProvider) != "") {
                UniversityService().addAnnouncement(
                  ref.watch(userPhotoUrlProvider).asData!.value,
                  "",
                  ref.watch(titleProvider),
                  ref.watch(contentProvider),
                );
                showSnackBarWidget(context, "Duyuru başarıyla eklendi..!");
              } else {
                showSnackBarWidget(
                    context, "Lütfen Gerekli Alanları Doldurunuz..!");
              }

              ref.read(contentProvider.notifier).state = "";
              ref.read(titleProvider.notifier).state = "";
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
