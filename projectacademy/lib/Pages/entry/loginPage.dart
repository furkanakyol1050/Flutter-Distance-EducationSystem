// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projectacademy/Pages/entry/loginPageWidgets.dart';
import 'package:projectacademy/myDesign.dart';

final containerProvider = StateProvider((ref) => 1);

final class LoginPage extends ConsumerWidget {
  LoginPage({super.key});

  final keyG = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            key: keyG,
            child: Container(
              alignment: Alignment.center,
              height: size.height,
              width: size.width,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/1.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: size.height < 660
                  ? Container()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const LogoWidget(),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "TOYGAR ",
                              style: Design().poppins(
                                size: 35,
                                fw: FontWeight.w900,
                                color: const Color.fromRGBO(25, 25, 25, 1),
                              ),
                            ),
                            Text(
                              "Akademi",
                              style: Design().poppins(
                                size: 25,
                                fw: FontWeight.normal,
                                color: const Color.fromRGBO(45, 45, 45, 1),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 50),
                        Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: _buildContainer(
                                ref.watch(containerProvider), context),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            },
                          ),
                        ),
                        const LoginButtonWidget(),
                        const Spacer(),
                        SwitchButtonWidget(keyG: keyG),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContainer(int index, BuildContext context) {
    final size = MediaQuery.of(context).size;
    switch (index) {
      case 0:
        return SizedBox(
          key: UniqueKey(),
          width: size.width,
          height: size.height * 0.4,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TFFUsernameWidget(),
              SizedBox(height: 40),
              TFFPasswordWidget(),
            ],
          ),
        );
      case 1:
        return SizedBox(
          key: UniqueKey(),
          width: size.width,
          height: size.height * 0.4,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SearchWidget(),
              SizedBox(height: 40),
              TFFMailWidget(),
              SizedBox(height: 40),
              TFFPasswordWidget(),
            ],
          ),
        );
      case 2:
        return SizedBox(
          key: UniqueKey(),
          width: size.width,
          height: size.height * 0.4,
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SearchWidget(),
              SizedBox(height: 40),
              TFFMailWidget(),
              SizedBox(height: 40),
              TFFPasswordWidget(),
            ],
          ),
        );
      default:
        return Container();
    }
  }
}
