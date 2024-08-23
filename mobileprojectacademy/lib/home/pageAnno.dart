// ignore_for_file: file_names

import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobileprojectacademy/firebaseConfig/firebase_transactions.dart';
import 'package:mobileprojectacademy/home/pageHome.dart';
import 'package:mobileprojectacademy/myDesign.dart';

final silinecel2Provider = StateProvider((ref) => 0);

class AnnoPage extends ConsumerWidget {
  const AnnoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Container(
          height: 50,
          alignment: Alignment.center,
          color: Colors.white,
          child: Text(
            "Tüm Duyurular",
            style: Design().poppins(
              color: Colors.grey.shade800,
              fw: FontWeight.bold,
              size: 16,
            ),
          ),
        ),
        Container(
          padding:
              const EdgeInsets.only(left: 15, top: 15, bottom: 10, right: 10),
          width: size.width,
          height: size.height - 150,
          child: Container(
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: FutureBuilder<List<CourseAnno>>(
                future: UniversityService().getCourseAnnouncements(
                    ref.watch(suniIdProvider).asData?.value ?? " ",
                    ref.watch(sfacultyIdProvider).asData?.value ?? " ",
                    ref.watch(sdepartmentIdProvider).asData?.value ?? " ",
                    ref.watch(courseIdProvider),
                    ref.watch(sstudentIdProvider).asData?.value ?? " "),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container();
                    } else {
                      return Container();
                    }
                  } else {
                    var announcements = snapshot.data!;
                    return ListView.builder(
                      itemCount: announcements.length,
                      itemBuilder: (context, index) {
                        var announcement = announcements[index];
                        return ExpansionTileCard(
                          elevationCurve: Curves.easeInOutQuart,
                          contentPadding: const EdgeInsets.all(10),
                          expandedColor:
                              const Color.fromARGB(255, 226, 229, 233),
                          duration: const Duration(milliseconds: 300),
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
                              fw: FontWeight.bold,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: announcement.receiverId == ""
                              ? Text(
                                  "Genel",
                                  //!  / Özel / Genel / Fakülte  diye yazacak
                                  style: Design().poppins(
                                    size: 13,
                                    color: Colors.grey.shade800,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : Text(
                                  "Özel",
                                  //!  / Özel / Genel / Fakülte  diye yazacak
                                  style: Design().poppins(
                                    size: 13,
                                    color: Colors.grey.shade800,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
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
                            announcement.fileNames.isNotEmpty
                                ? Container(
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.only(
                                      left: 7,
                                      right: 7,
                                    ),
                                    height: announcement.fileNames.length * 73,
                                    child: ListView.builder(
                                      itemCount: announcement.fileNames.length,
                                      itemBuilder: (context, index) {
                                        return Transform.scale(
                                          scale: 0.95,
                                          child: Card(
                                            margin: const EdgeInsets.all(3),
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
                                              contentPadding:
                                                  const EdgeInsets.only(
                                                left: 15,
                                                right: 10,
                                              ),
                                              leading: const Icon(
                                                Icons.file_present_rounded,
                                                size: 20,
                                              ),
                                              title: Text(
                                                announcement.fileNames[index],
                                                style: Design().poppins(
                                                  color: Colors.grey.shade800,
                                                  size: 13,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                              trailing: IconButton(
                                                onPressed: () {
                                                  String filePath =
                                                      "uploads/announcements/${ref.watch(courseIdProvider)}/${ref.watch(homeworkGivenTimeProvider).substring(0, 16)}/${ref.watch(homeworkFileNames)[index]}";
                                                  UniversityService()
                                                      .downloadFile(filePath);
                                                },
                                                icon: const Icon(
                                                  Icons.download,
                                                  color: Color.fromRGBO(
                                                      81, 130, 155, 1),
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : Container(
                                    height: 100,
                                    margin: const EdgeInsets.all(10),
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
                    );
                  }
                }),
          ),
        ),
      ],
    );
  }
}

// if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return Expanded(
//                           child: Container(
//                             alignment: Alignment.center,
//                             decoration: BoxDecoration(
//                               color: const Color.fromARGB(255, 226, 229, 233),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: const Text(""),
//                           ),
//                         );
//                       } else {
//                         return Expanded(
//                           child: Container(
//                             alignment: Alignment.center,
//                             decoration: BoxDecoration(
//                               color: const Color.fromARGB(255, 226, 229, 233),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: Text(
//                               "Duyuru Paylaşılmadı",
//                               style: Design().poppins(
//                                 size: 14,
//                                 color: Colors.grey.shade600,
//                               ),
//                             ),
//                           ),
//                         );
//                       }
//                     }