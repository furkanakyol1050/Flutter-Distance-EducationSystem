// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:projectacademy/Pages/entry/loginPageWidgets.dart';
import 'package:projectacademy/myDesign.dart';

class RestorePage extends StatelessWidget {
  const RestorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Form(
        key: formKey,
        child: Container(
          height: size.height,
          width: size.width,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/1.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(flex: 7),
              Text(
                "Şifre Yenile",
                style: Design().poppins(
                  size: 22,
                  fw: FontWeight.bold,
                  color: const Color.fromRGBO(55, 55, 55, 1),
                ),
              ),
              const Spacer(flex: 1),
              Text(
                "Şifrenizi yenileme e-postası almak için\nmail adresinizi giriniz.",
                textAlign: TextAlign.center,
                style: Design().poppins(
                  size: 17,
                  color: const Color.fromRGBO(55, 55, 55, 1),
                ),
              ),
              const Spacer(flex: 1),
              const TFFMailWidget(),
              const Spacer(flex: 2),
              const RestoreButtonWidget(),
              const Spacer(flex: 7),
            ],
          ),
        ),
      ),
    );
  }
}
