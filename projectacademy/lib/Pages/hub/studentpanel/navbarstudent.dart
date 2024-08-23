import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projectacademy/Pages/hub/studentpanel/joincoursepage.dart';
import 'package:projectacademy/firebaseConfig/firebase_transactionss.dart';
import 'package:projectacademy/myDesign.dart';

final sizeStudentProvider = StateProvider<double>((ref) => 65);
final selectedStudentPageProvider = StateProvider((ref) => 1);

final calendarLecInfos = StateProvider((ref) => <Map<String, dynamic>>[]);
final calendarHomeworkInfos = StateProvider((ref) => <Map<String, dynamic>>[]);
final calendarExamInfos = StateProvider((ref) => <Map<String, dynamic>>[]);
final assignedCourseList = StateProvider((ref) => <String>[]);

class NavBarStudentWidget extends ConsumerWidget {
  const NavBarStudentWidget({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedContainer(
      height: size.height,
      width: ref.watch(sizeStudentProvider),
      color: const Color.fromRGBO(35, 35, 35, 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutQuart,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: ListView(
              children: [
                Container(
                  width: ref.watch(sizeStudentProvider),
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.all(10),
                  child: IconButton(
                    onPressed: () {
                      ref.read(sizeStudentProvider.notifier).state =
                          ref.watch(sizeStudentProvider) == 65 ? 250 : 65;
                    },
                    style: IconButton.styleFrom(
                      maximumSize: const Size(45, 45),
                      minimumSize: const Size(45, 45),
                      backgroundColor: Colors.grey.shade800,
                      highlightColor: Colors.grey.shade700,
                      hoverColor: Colors.grey.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(
                      Icons.menu_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                const MenuItemWidget(
                  icon: Icons.add_circle,
                  label: "Derse Katıl",
                  index: 0,
                ),
                const MenuItemWidget(
                  icon: Icons.home,
                  label: "Ana Sayfa",
                  index: 1,
                ),
                const MenuItemWidget(
                  icon: Icons.calendar_month,
                  label: "Takvim",
                  index: 2,
                ),
              ],
            ),
          ),
          const MenuItemWidget(
            icon: Icons.exit_to_app_rounded,
            label: "Güvenli Çıkış",
            index: 3,
          ),
          ref.watch(sizeStudentProvider) > 100
              ? AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 100,
                  margin: const EdgeInsets.all(15),
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    """21100011002"""
                    """\nMuhammed Furkan Akyol"""
                    """\nMühendislik Fakültesi"""
                    """\nBilgisayar Mühendisliği Bölümü""",
                    maxLines: 4,
                    overflow: TextOverflow.fade,
                    style: Design().poppins(
                      color: Colors.white,
                      size: 11,
                      fw: FontWeight.w500,
                    ),
                  ),
                )
              : AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 0,
                ),
        ],
      ),
    );
  }
}

class MenuItemWidget extends ConsumerWidget {
  const MenuItemWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.index,
  });

  final IconData icon;
  final String label;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      height: 45,
      width: 230,
      child: ClipRect(
        clipBehavior: Clip.hardEdge,
        child: TextButton.icon(
          onPressed: () async {
            ref.read(containerSizeProvider.notifier).state = 0;
            if (index < 3) {
              ref.read(sizeStudentProvider.notifier).state = 65;
              ref.read(selectedStudentPageProvider.notifier).state = index;
              if (index == 2) {
                ref.read(assignedCourseList.notifier).state =
                    await UniversityService().getAssignedLectureIds(
                        ref.watch(runiIdProvider).asData?.value ?? "",
                        ref.watch(rfacultyIdProvider).asData?.value ?? "",
                        ref.watch(rdepartmentIdProvider).asData?.value ?? "",
                        ref.watch(rstudentIdProvider).asData?.value ?? "");

                Future.delayed(const Duration(seconds: 1), () async {
                  ref.read(calendarLecInfos.notifier).state =
                      await UniversityService().getLectureDetails(
                          ref.watch(runiIdProvider).asData?.value ?? "",
                          ref.watch(rfacultyIdProvider).asData?.value ?? "",
                          ref.watch(rdepartmentIdProvider).asData?.value ?? "",
                          ref.watch(assignedCourseList));

                  ref.read(calendarHomeworkInfos.notifier).state =
                      await UniversityService().getHomeworkCalDetails(
                          ref.watch(runiIdProvider).asData?.value ?? "",
                          ref.watch(rfacultyIdProvider).asData?.value ?? "",
                          ref.watch(rdepartmentIdProvider).asData?.value ?? "",
                          ref.watch(assignedCourseList));
                });
                ref.read(calendarExamInfos.notifier).state =
                    await UniversityService().getExamCalDetails(
                        ref.watch(runiIdProvider).asData?.value ?? "",
                        ref.watch(rfacultyIdProvider).asData?.value ?? "",
                        ref.watch(rdepartmentIdProvider).asData?.value ?? "",
                        ref.watch(assignedCourseList));
              }
            } else {
              ref.read(sizeStudentProvider.notifier).state = 65;
              ref.read(selectedStudentPageProvider.notifier).state = 0;
              Navigator.pop(context);
              await Future.delayed(const Duration(seconds: 2), () {
                FirebaseAuth.instance.signOut();
              });
            }
          },
          style: ButtonStyle(
            alignment: Alignment.centerLeft,
            padding:
                const MaterialStatePropertyAll(EdgeInsets.only(left: 12.6)),
            backgroundColor: MaterialStatePropertyAll(
              ref.watch(selectedStudentPageProvider) == index
                  ? Colors.grey.shade800
                  : const Color.fromRGBO(35, 35, 35, 1),
            ),
            foregroundColor: MaterialStatePropertyAll(Colors.grey.shade500),
            shape: MaterialStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(155)),
            ),
            overlayColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.hovered)) {
                  return Colors.grey.shade700;
                }
                return Colors.grey.shade700;
              },
            ),
          ),
          icon: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
          label: Text(
            ref.watch(sizeStudentProvider) == 65 ? "" : "   $label",
            maxLines: 1,
            style: Design().poppins(
              color: Colors.white,
              size: 13,
              fw: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
