// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobileprojectacademy/home/gnav.dart';
import 'package:mobileprojectacademy/home/pageAnno.dart';
import 'package:mobileprojectacademy/home/pageExam.dart';
import 'package:mobileprojectacademy/home/pageHome.dart';

class PageMain extends ConsumerWidget {
  const PageMain({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.white,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.dark,
        ),
        toolbarHeight: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/2.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: PageView(
            controller: ref.watch(pageControlProvider),
            onPageChanged: (no) {
              ref.read(pageNoProvider.notifier).state = no;
            },
            children: const [
              HomePageWidget(),
              ExamPage(),
              AnnoPage(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const NavBar(),
    );
  }
}
