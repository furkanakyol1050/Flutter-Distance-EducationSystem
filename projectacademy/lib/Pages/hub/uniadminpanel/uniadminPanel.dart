// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projectacademy/Pages/hub/uniadminpanel/announcementPage.dart';
import 'package:projectacademy/Pages/hub/uniadminpanel/calendarPage.dart';
import 'package:projectacademy/Pages/hub/uniadminpanel/homepage.dart';
import 'package:projectacademy/Pages/hub/uniadminpanel/lecturerPage.dart';
import 'package:projectacademy/Pages/hub/uniadminpanel/navbar.dart';
import 'package:projectacademy/Pages/hub/uniadminpanel/studentPage.dart';

class UniAdminPanel extends ConsumerWidget {
  const UniAdminPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/4.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            AnimatedSwitcher(
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              duration: const Duration(milliseconds: 500),
              child: switch (ref.watch(selectedPageProvider)) {
                0 => HomePageWidget(size: size),
                1 => const StudentPageWidget(),
                2 => const LecturerPage(),
                3 => const CalendarPage(),
                4 => const AnnouncementPage(),
                _ => Container(),
              },
            ),
            size.height > 200 ? NavBarWidget(size: size) : Container(),
          ],
        ),
      ),
    );
  }
}
