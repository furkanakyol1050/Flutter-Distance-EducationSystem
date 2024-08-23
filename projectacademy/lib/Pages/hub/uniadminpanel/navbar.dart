import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projectacademy/Pages/hub/uniadminpanel/homepage.dart';
import 'package:projectacademy/Pages/hub/uniadminpanel/lecturerPage.dart';
import 'package:projectacademy/Pages/hub/uniadminpanel/studentPage.dart';
import 'package:projectacademy/firebaseConfig/firebase_transactionss.dart';
import 'package:projectacademy/myDesign.dart';

final sizeProvider = StateProvider<double>((ref) => 65);
final selectedPageProvider = StateProvider((ref) => 0);

class NavBarWidget extends ConsumerWidget {
  const NavBarWidget({
    super.key,
    required this.size,
  });

  final Size size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnimatedContainer(
      height: size.height,
      width: ref.watch(sizeProvider),
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
                  width: ref.watch(sizeProvider),
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.all(10),
                  child: IconButton(
                    onPressed: () {
                      ref.read(sizeProvider.notifier).state =
                          ref.watch(sizeProvider) == 65 ? 250 : 65;
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
                  label: "Ana Sayfa",
                  index: 0,
                ),
                const MenuItemWidget(
                  icon: Icons.account_circle_rounded,
                  label: "Öğrenciler",
                  index: 1,
                ),
                const MenuItemWidget(
                  icon: Icons.work_rounded,
                  label: "Akademisyenler",
                  index: 2,
                ),
                const MenuItemWidget(
                  icon: Icons.calendar_month,
                  label: "Takvim",
                  index: 3,
                ),
              ],
            ),
          ),
          const MenuItemWidget(
            icon: Icons.announcement_rounded,
            label: "Duyurular",
            index: 4,
          ),
          const MenuItemWidget(
            icon: Icons.exit_to_app_rounded,
            label: "Güvenli Çıkış",
            index: 5,
          ),
          ref.watch(sizeProvider) > 100
              ? AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 40,
                  margin: const EdgeInsets.all(15),
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(155),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    ref.watch(userPhotoUrlProvider).asData?.value ?? " ",
                    maxLines: 1,
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
            ref.read(leftLecturerPageChangeProvider.notifier).state = 0;
            ref.read(leftStudentPageChangeProvider.notifier).state = 0;
            ref.read(leftPageChangeProvider.notifier).state = 0;
            if (index < 5) {
              ref.read(sizeProvider.notifier).state = 65;
              ref.read(selectedPageProvider.notifier).state = index;
              if (index == 0) {
              } else {
                await Future.delayed(const Duration(milliseconds: 700), () {
                  ref.read(leftPageChangeProvider.notifier).state = 0;
                });
              }
            } else {
              Navigator.pop(context);
              await Future.delayed(const Duration(seconds: 2), () {
                FirebaseAuth.instance.signOut();
              });
              ref.read(sizeProvider.notifier).state = 65;
              ref.read(selectedPageProvider.notifier).state = 0;
            }
          },
          style: ButtonStyle(
            alignment: Alignment.centerLeft,
            padding:
                const MaterialStatePropertyAll(EdgeInsets.only(left: 12.6)),
            backgroundColor: MaterialStatePropertyAll(
              ref.watch(selectedPageProvider) == index
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
            ref.watch(sizeProvider) == 65 ? "" : "   $label",
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
