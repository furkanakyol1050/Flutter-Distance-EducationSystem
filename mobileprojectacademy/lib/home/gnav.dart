import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:mobileprojectacademy/firebaseConfig/firebase_transactions.dart';
import 'package:mobileprojectacademy/home/pageAnno.dart';
import 'package:mobileprojectacademy/home/pageExam.dart';
import 'package:mobileprojectacademy/home/pageHome.dart';
import 'package:mobileprojectacademy/myDesign.dart';

final pageNoProvider = StateProvider((ref) => 0);

final calendarLecInfos = StateProvider((ref) => <Map<String, dynamic>>[]);
final calendarHomeworkInfos = StateProvider((ref) => <Map<String, dynamic>>[]);
final calendarExamInfos = StateProvider((ref) => <Map<String, dynamic>>[]);
final assignedCourseList = StateProvider((ref) => <String>[]);

final pageControlProvider = Provider(
  (ref) => PageController(
    initialPage: 0,
    keepPage: true,
  ),
);

final pagesProvider = Provider(
  (ref) => [
    const HomePageWidget(),
    const ExamPage(),
    const AnnoPage(),
  ],
);

class NavBar extends ConsumerWidget {
  const NavBar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(10),
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(.1),
          )
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
          child: GNav(
            tabBorderRadius: 20,
            rippleColor: Colors.grey[300]!,
            hoverColor: Colors.grey[100]!,
            gap: 8,
            activeColor: const Color.fromARGB(255, 17, 14, 14),
            iconSize: 18,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            duration: const Duration(milliseconds: 400),
            tabBackgroundColor: Colors.grey[100]!,
            color: Colors.black,
            tabs: [
              GButton(
                icon: Bootstrap.house,
                iconSize: 20,
                iconColor: Colors.grey.shade800,
                text: 'Ana Sayfa',
                textStyle: Design().poppins(
                  size: 15,
                  color: Colors.grey.shade800,
                ),
              ),
              GButton(
                backgroundGradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 105, 77, 170),
                    Color.fromARGB(255, 74, 0, 158),
                  ],
                ),
                icon: Bootstrap.pencil,
                iconColor: Colors.grey.shade800,
                iconSize: 20,
                iconActiveColor: Colors.white,
                text: 'Sınav',
                textStyle: Design().poppins(
                  size: 15,
                  color: Colors.white,
                ),
              ),
              GButton(
                icon: Bootstrap.chat_text,
                iconColor: Colors.grey.shade800,
                iconSize: 20,
                text: 'Duyurular',
                textStyle: Design().poppins(
                  size: 15,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
            selectedIndex: ref.watch(pageNoProvider),
            onTabChange: (index) async {
              if (index == 0) {
                ref.read(assignedCourseList.notifier).state =
                    await UniversityService().getAssignedLectureIds(
                        ref.watch(suniIdProvider).asData?.value ?? "",
                        ref.watch(sfacultyIdProvider).asData?.value ?? "",
                        ref.watch(sdepartmentIdProvider).asData?.value ?? "",
                        ref.watch(sstudentIdProvider).asData?.value ?? "");

                Future.delayed(const Duration(seconds: 1), () async {
                  ref.read(calendarLecInfos.notifier).state =
                      await UniversityService().getLectureDetails(
                          ref.watch(suniIdProvider).asData?.value ?? "",
                          ref.watch(sfacultyIdProvider).asData?.value ?? "",
                          ref.watch(sdepartmentIdProvider).asData?.value ?? "",
                          ref.watch(assignedCourseList));

                  ref.read(calendarHomeworkInfos.notifier).state =
                      await UniversityService().getHomeworkCalDetails(
                          ref.watch(suniIdProvider).asData?.value ?? "",
                          ref.watch(sfacultyIdProvider).asData?.value ?? "",
                          ref.watch(sdepartmentIdProvider).asData?.value ?? "",
                          ref.watch(assignedCourseList));
                });
                ref.read(calendarExamInfos.notifier).state =
                    await UniversityService().getExamCalDetails(
                        ref.watch(suniIdProvider).asData?.value ?? "",
                        ref.watch(sfacultyIdProvider).asData?.value ?? "",
                        ref.watch(sdepartmentIdProvider).asData?.value ?? "",
                        ref.watch(assignedCourseList));
              }
              ref.read(pageNoProvider.notifier).state = index;
              ref.watch(pageControlProvider).animateToPage(
                    index,
                    duration: const Duration(milliseconds: 10),
                    curve: Curves.ease,
                  );
            },
          ),
        ),
      ),
    );
  }
}
