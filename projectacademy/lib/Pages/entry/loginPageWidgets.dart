// ignore_for_file: file_names

import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:projectacademy/Pages/entry/loginPage.dart';
import 'package:projectacademy/firebaseConfig/firebase_transactionss.dart';
import 'package:projectacademy/myDesign.dart';

final visibilityProvider = StateProvider((ref) => 1);
final switchProvider = StateProvider((ref) => 1);
final searchProvider = StateProvider((ref) => 0); //! Universite adi

final mailProvider = StateProvider((ref) => "");
final passProvider = StateProvider((ref) => "");
final usernameProvider = StateProvider((ref) => "");
final restoreMailProvider = StateProvider((ref) => "");

class TFFMailWidget extends ConsumerWidget {
  const TFFMailWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Transform.scale(
      scale: 0.95,
      child: SizedBox(
        width: 350,
        child: TextFormField(
          validator: (value) {
            if (!EmailValidator.validate(value!)) {
              return "";
            }
            return null;
          },
          onChanged: (value) {
            ref.read(mailProvider.notifier).state = value;
          },
          style: Design().poppins(
            size: 15,
            fw: FontWeight.w600,
            color: const Color.fromRGBO(55, 55, 55, 1),
          ),
          cursorColor: const Color.fromRGBO(55, 55, 55, 1),
          cursorWidth: 2,
          cursorRadius: const Radius.circular(25),
          decoration: InputDecoration(
            errorStyle: const TextStyle(height: 0),
            contentPadding: const EdgeInsets.only(left: 30, right: 30),
            labelText: "Email",
            labelStyle: Design().poppins(
              size: 15,
              fw: FontWeight.w600,
              color: const Color.fromRGBO(55, 55, 55, 1),
            ),
            focusedBorder: Design().loginPageOIB(
              color: const Color.fromRGBO(55, 55, 55, 1),
            ),
            enabledBorder: Design().loginPageOIB(
              color: const Color.fromRGBO(55, 55, 55, 1),
            ),
            errorBorder: Design().loginPageOIB(
              color: const Color.fromRGBO(220, 49, 49, 1),
            ),
            focusedErrorBorder: Design().loginPageOIB(
              color: const Color.fromRGBO(220, 49, 49, 1),
            ),
          ),
        ),
      ),
    );
  }
}

class TFFUsernameWidget extends ConsumerWidget {
  const TFFUsernameWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Transform.scale(
      scale: 0.95,
      child: SizedBox(
        width: 350,
        child: TextFormField(
          validator: (value) {
            if (value!.length < 5) {
              return "";
            }
            return null;
          },
          onChanged: (value) {
            ref.read(usernameProvider.notifier).state = value;
          },
          style: Design().poppins(
            size: 15,
            fw: FontWeight.w600,
            color: const Color.fromRGBO(55, 55, 55, 1),
          ),
          cursorColor: const Color.fromRGBO(55, 55, 55, 1),
          cursorWidth: 2,
          cursorRadius: const Radius.circular(25),
          decoration: InputDecoration(
            errorStyle: const TextStyle(height: 0),
            contentPadding: const EdgeInsets.only(left: 30, right: 30),
            labelText: "Kullanıcı Adı",
            labelStyle: Design().poppins(
              size: 15,
              fw: FontWeight.w600,
              color: const Color.fromRGBO(55, 55, 55, 1),
            ),
            focusedBorder: Design().loginPageOIB(
              color: const Color.fromRGBO(55, 55, 55, 1),
            ),
            enabledBorder: Design().loginPageOIB(
              color: const Color.fromRGBO(55, 55, 55, 1),
            ),
            errorBorder: Design().loginPageOIB(
              color: const Color.fromRGBO(220, 49, 49, 1),
            ),
            focusedErrorBorder: Design().loginPageOIB(
              color: const Color.fromRGBO(220, 49, 49, 1),
            ),
          ),
        ),
      ),
    );
  }
}

class TFFPasswordWidget extends ConsumerWidget {
  const TFFPasswordWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Transform.scale(
      scale: 0.95,
      child: SizedBox(
        width: 350,
        child: TextFormField(
          onEditingComplete: () {
            if (ref.watch(switchProvider) == 0) {
              AuthService().singInAdmin(ref.watch(usernameProvider),
                  ref.watch(passProvider), context, ref);
              AuthService().signInWithEmailAndPasswordForAdmin(
                context,
                "${ref.watch(usernameProvider)}@gmail.com",
                ref.watch(passProvider),
                ref,
              );
            } else if (ref.watch(switchProvider) == 1) {
              AuthService().signInWithEmailAndPasswordForStudent(
                context,
                ref.watch(mailProvider),
                ref.watch(passProvider),
                ref,
              );
            } else if (ref.watch(switchProvider) == 2) {
              AuthService().signInWithEmailAndPasswordForInstructor(
                context,
                ref.watch(mailProvider),
                ref.watch(passProvider),
                ref,
              );
            }
          },
          validator: (value) {
            if (value!.length < 5) {
              return "";
            }
            return null;
          },
          onChanged: (value) {
            ref.read(passProvider.notifier).state = value;
          },
          obscureText: ref.watch(visibilityProvider) == 1 ? true : false,
          style: Design().poppins(
            size: 15,
            ls: 2,
            fw: FontWeight.w600,
            color: const Color.fromRGBO(55, 55, 55, 1),
          ),
          cursorColor: const Color.fromRGBO(55, 55, 55, 1),
          cursorWidth: 2,
          cursorRadius: const Radius.circular(100),
          decoration: InputDecoration(
            errorStyle: const TextStyle(height: 0),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(
                onPressed: () {
                  ref.read(visibilityProvider.notifier).state =
                      (ref.watch(visibilityProvider) + 1) % 2;
                },
                icon: Icon(
                  ref.watch(visibilityProvider) == 0
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: const Color.fromRGBO(55, 55, 55, 1),
                ),
              ),
            ),
            counter: ref.watch(switchProvider) != 0
                ? TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color.fromRGBO(55, 55, 55, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, "/restore");
                    },
                    child: Text(
                      "Şifremi unuttum",
                      style: Design().poppins(
                        size: 14,
                        fw: FontWeight.w600,
                        color: const Color.fromRGBO(55, 55, 55, 1),
                      ),
                    ),
                  )
                : Container(height: 28),
            contentPadding: const EdgeInsets.only(left: 30),
            labelText: "Şifre",
            labelStyle: Design().poppins(
              size: 15,
              fw: FontWeight.w600,
              color: const Color.fromRGBO(55, 55, 55, 1),
            ),
            focusedBorder: Design().loginPageOIB(
              color: const Color.fromRGBO(55, 55, 55, 1),
            ),
            enabledBorder: Design().loginPageOIB(
              color: const Color.fromRGBO(55, 55, 55, 1),
            ),
            errorBorder: Design().loginPageOIB(
              color: const Color.fromRGBO(220, 49, 49, 1),
            ),
            focusedErrorBorder: Design().loginPageOIB(
              color: const Color.fromRGBO(220, 49, 49, 1),
            ),
          ),
        ),
      ),
    );
  }
}

class LoginButtonWidget extends ConsumerWidget {
  const LoginButtonWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Transform.scale(
      scale: 0.95,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10, right: 10),
        width: 150,
        child: ElevatedButton(
          onPressed: () {
            if (ref.watch(switchProvider) == 0) {
              AuthService().singInAdmin(ref.watch(usernameProvider),
                  ref.watch(passProvider), context, ref);
              AuthService().signInWithEmailAndPasswordForAdmin(
                  context,
                  "${ref.watch(usernameProvider)}@gmail.com",
                  ref.watch(passProvider),
                  ref);
            } else if (ref.watch(switchProvider) == 1) {
              AuthService().signInWithEmailAndPasswordForStudent(context,
                  ref.watch(mailProvider), ref.watch(passProvider), ref);
            } else if (ref.watch(switchProvider) == 2) {
              AuthService().signInWithEmailAndPasswordForInstructor(context,
                  ref.watch(mailProvider), ref.watch(passProvider), ref);
            }
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.only(
              top: 17,
              bottom: 17,
              left: 10,
              right: 10,
            ),
            shadowColor: Colors.transparent,
            foregroundColor: Colors.grey.shade500,
            backgroundColor: const Color.fromRGBO(55, 55, 55, 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            "Giriş Yap",
            style: Design().poppins(
              size: 17,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class RestoreButtonWidget extends ConsumerWidget {
  const RestoreButtonWidget({
    super.key,
  });

  Future<void> resetPassword(String email) async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Transform.scale(
      scale: 0.95,
      child: SizedBox(
        width: 350,
        height: 42,
        child: ElevatedButton(
          onPressed: () {
            resetPassword(ref.watch(mailProvider));
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(15),
            shadowColor: Colors.transparent,
            backgroundColor: const Color.fromRGBO(55, 55, 55, 1),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            "Kurtarma e-postası al",
            style: Design().poppins(
              size: 17,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class SwitchButtonWidget extends ConsumerWidget {
  SwitchButtonWidget({
    super.key,
    required this.keyG,
  });

  GlobalKey<FormState> keyG;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Transform.scale(
      alignment: Alignment.bottomCenter,
      scaleY: 0.95,
      child: Container(
        alignment: Alignment.center,
        child: AnimatedToggleSwitch.size(
          onTap: (props) {
            ref.watch(containerProvider.notifier).state =
                props.tapped?.index ?? 0;
            ref.read(mailProvider.notifier).state = "";
            ref.read(passProvider.notifier).state = "";
            ref.read(usernameProvider.notifier).state = "";
            keyG.currentState?.reset();
            ref.read(searchProvider.notifier).state = 0;
          },
          onChanged: (i) {
            ref.read(switchProvider.notifier).state = i;
            ref.watch(containerProvider.notifier).state = i;
            ref.read(mailProvider.notifier).state = "";
            ref.read(passProvider.notifier).state = "";
            ref.read(usernameProvider.notifier).state = "";
            keyG.currentState?.reset();
            ref.read(searchProvider.notifier).state = 0;
          },
          indicatorSize: Size.fromWidth(size.width * 0.5),
          styleAnimationType: AnimationType.none,
          style: ToggleStyle(
            backgroundColor: const Color.fromRGBO(55, 55, 55, 0.6),
            indicatorColor: const Color.fromRGBO(55, 55, 55, 1),
            borderColor: Colors.transparent,
            borderRadius: BorderRadius.circular(0),
            indicatorBorderRadius: BorderRadius.circular(8),
          ),
          animationCurve: Curves.easeInOut,
          current: ref.watch(switchProvider),
          values: const [0, 1, 2],
          customIconBuilder: (context, local, global) {
            final text = const [
              'Yönetici',
              'Öğrenci',
              'Akademisyen',
            ][local.index];
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Color.lerp(
                      Colors.white,
                      Colors.white,
                      local.animationValue,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class LogoWidget extends StatelessWidget {
  const LogoWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 30, right: 30),
      alignment: Alignment.centerRight,
      child: Image.asset(
        "assets/logo.png",
        width: 80,
        color: const Color.fromRGBO(35, 35, 35, 1),
      ),
    );
  }
}

class SearchWidget extends ConsumerWidget {
  const SearchWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var universities = ref.watch(universitiesProvider).asData?.value ?? [];
    return Container(
      width: 334,
      height: 47,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(
          width: 2,
          color: const Color.fromRGBO(55, 55, 55, 1),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton(
        padding: const EdgeInsets.only(left: 25, right: 25),
        style: Design().poppins(
          size: 15,
          fw: FontWeight.w600,
          color: const Color.fromRGBO(55, 55, 55, 1),
        ),
        dropdownColor: Colors.white,
        underline: const Divider(color: Colors.transparent),
        isExpanded: true,
        borderRadius: BorderRadius.circular(8),
        hint: Text(
          "Üniversite Seç",
          style: Design().poppins(
            fw: FontWeight.bold,
            size: 15,
          ),
        ),
        value: ref.watch(searchProvider),
        onChanged: (value) {
          ref.read(searchProvider.notifier).state = value ?? 0;
        },
        menuMaxHeight: 200,
        items: [
          const DropdownMenuItem(
            value: 0,
            child: Text("Lütfen Üniversite Seçiniz"),
          ),
          if (universities.isNotEmpty)
            ...List.generate(
              universities.length,
              (index) {
                return DropdownMenuItem(
                  value: index + 1,
                  child: Text(universities[index].name),
                );
              },
            ),
        ],
      ),
    );
  }
}
