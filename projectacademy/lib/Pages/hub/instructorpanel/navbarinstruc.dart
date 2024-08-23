import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projectacademy/Pages/hub/instructorpanel/createExamPage.dart';
import 'package:projectacademy/Pages/hub/instructorpanel/homepage.dart';
import 'package:projectacademy/Pages/hub/instructorpanel/instructorPage.dart';
import 'package:projectacademy/firebaseConfig/firebase_transactionss.dart';
import 'package:projectacademy/myDesign.dart';

final sizeInstrucProvider = StateProvider<double>((ref) => 65);
final selectedInstrucPageProvider = StateProvider((ref) => 0);

class NavBarInstrucWidget extends ConsumerWidget {
  const NavBarInstrucWidget({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedContainer(
      height: size.height,
      width: ref.watch(sizeInstrucProvider),
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
                  width: ref.watch(sizeInstrucProvider),
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.all(10),
                  child: IconButton(
                    onPressed: () {
                      ref.read(sizeInstrucProvider.notifier).state =
                          ref.watch(sizeInstrucProvider) == 65 ? 250 : 65;
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
                  icon: Icons.home,
                  label: "Ana sayfa",
                  index: 0,
                ),
                const MenuItemWidget(
                  icon: Icons.note_alt_rounded,
                  label: "Sınav Oluştur",
                  index: 1,
                ),
                const MenuItemWidget(
                  icon: Icons.add_home_work,
                  label: "Ödev Ekle",
                  index: 2,
                ),
                const MenuItemWidget(
                  icon: Icons.announcement_rounded,
                  label: "Duyuru Paylaş",
                  index: 3,
                ),
                const MenuItemWidget(
                  icon: Icons.calendar_month,
                  label: "Takvim",
                  index: 4,
                ),
              ],
            ),
          ),
          const MenuItemWidget(
            icon: Icons.exit_to_app_rounded,
            label: "Güvenli Çıkış",
            index: 5,
          ),
          ref.watch(sizeInstrucProvider) > 100
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

final lCalendarLecInfos = StateProvider((ref) => <Map<String, dynamic>>[]);
final lCalendarHomeworkInfos = StateProvider((ref) => <Map<String, dynamic>>[]);
final lCalendarExamInfos = StateProvider((ref) => <Map<String, dynamic>>[]);

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
            if (index < 5) {
              if (index == 1) {
                ref.read(courseListProvider.notifier).state =
                    await UniversityService().getCoursesName(
                        ref.watch(luniIdProvider).asData?.value ?? " ",
                        ref.watch(lfacultyIdProvider).asData?.value ?? " ",
                        ref.watch(ldepartmentIdProvider).asData?.value ?? " ");
              } else if (index == 4) {
                List<String> asd = await UniversityService().getCourseIds(
                    ref.watch(luniIdProvider).asData?.value ?? " ",
                    ref.watch(linstructorIdProvider).asData?.value ?? " ");

                Future.delayed(const Duration(seconds: 1), () async {
                  ref.read(lCalendarHomeworkInfos.notifier).state =
                      await UniversityService().getHomeworkCalDetails(
                          ref.watch(luniIdProvider).asData?.value ?? "",
                          ref.watch(lfacultyIdProvider).asData?.value ?? "",
                          ref.watch(ldepartmentIdProvider).asData?.value ?? "",
                          asd);

                  ref.read(lCalendarExamInfos.notifier).state =
                      await UniversityService().getExamCalDetails(
                          ref.watch(luniIdProvider).asData?.value ?? "",
                          ref.watch(lfacultyIdProvider).asData?.value ?? "",
                          ref.watch(ldepartmentIdProvider).asData?.value ?? "",
                          asd);

                  ref.read(lCalendarLecInfos.notifier).state =
                      await UniversityService().getLectureDetails(
                          ref.watch(luniIdProvider).asData?.value ?? "",
                          ref.watch(lfacultyIdProvider).asData?.value ?? "",
                          ref.watch(ldepartmentIdProvider).asData?.value ?? "",
                          asd);
                });
              }
              ref.read(planPageProvider.notifier).state = 0;
              ref.read(rightPanelInsProvider.notifier).state = 0;
              ref.read(sizeInstrucProvider.notifier).state = 65;
              ref.read(selectedInstrucPageProvider.notifier).state = index;
            } else {
              ref.read(sizeInstrucProvider.notifier).state = 65;
              ref.read(selectedInstrucPageProvider.notifier).state = 0;
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
              ref.watch(selectedInstrucPageProvider) == index
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
            ref.watch(sizeInstrucProvider) == 65 ? "" : "   $label",
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
