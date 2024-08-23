import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobileprojectacademy/firebaseConfig/firebase_transactions.dart';
import 'package:mobileprojectacademy/myDesign.dart';

final visibilityProvider = StateProvider((ref) => 1);
final switchProvider = StateProvider((ref) => 1);
final searchProvider = StateProvider((ref) => 0); //! Universite adi
final mailProvider = StateProvider((ref) => "");
final passProvider = StateProvider((ref) => "");
final usernameProvider = StateProvider((ref) => "");
final containerProvider = StateProvider((ref) => 1);

class LoginPage extends ConsumerWidget {
  LoginPage({super.key});

  final keyG = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        key: keyG,
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/2.png"),
              fit: BoxFit.cover,
            ),
          ),
          alignment: Alignment.center,
          height: size.height,
          width: size.width,
          child: ListView(
            children: [
              const SizedBox(height: 50),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "TOYGAR ",
                    style: Design().poppins(
                      size: 35,
                      fw: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Akademi",
                    style: Design().poppins(
                      size: 25,
                      fw: FontWeight.normal,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              Center(
                child: SizedBox(
                  width: size.width,
                  height: 400,
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
                ),
              ),
              const SizedBox(height: 150),
              const Center(child: LoginButtonWidget()),
            ],
          ),
        ),
      ),
    );
  }
}

class TFFMailWidget extends ConsumerWidget {
  const TFFMailWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Transform.scale(
      scale: 0.95,
      child: Container(
        margin: const EdgeInsets.only(left: 10, right: 10),
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
            color: Colors.white,
          ),
          cursorColor: Colors.white,
          cursorWidth: 2,
          cursorRadius: const Radius.circular(25),
          decoration: InputDecoration(
            errorStyle: const TextStyle(height: 0),
            contentPadding: const EdgeInsets.only(left: 30, right: 30),
            labelText: "Email",
            labelStyle: Design().poppins(
              size: 15,
              fw: FontWeight.w600,
              color: Colors.white,
            ),
            focusedBorder: Design().loginPageOIB(
              color: Colors.white,
            ),
            enabledBorder: Design().loginPageOIB(
              color: Colors.white,
            ),
            errorBorder: Design().loginPageOIB(
              color: const Color.fromRGBO(211, 118, 118, 1),
            ),
            focusedErrorBorder: Design().loginPageOIB(
              color: const Color.fromRGBO(211, 118, 118, 1),
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
      child: Container(
        margin: const EdgeInsets.only(left: 10, right: 10),
        child: TextFormField(
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
            color: Colors.white,
          ),
          cursorColor: Colors.white,
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
                  color: Colors.white,
                ),
              ),
            ),
            counter: ref.watch(switchProvider) != 0
                ? TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
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
                        color: Colors.white,
                      ),
                    ),
                  )
                : Container(height: 28),
            contentPadding: const EdgeInsets.only(left: 30),
            labelText: "Şifre",
            labelStyle: Design().poppins(
              size: 15,
              fw: FontWeight.w600,
              color: Colors.white,
            ),
            focusedBorder: Design().loginPageOIB(
              color: Colors.white,
            ),
            enabledBorder: Design().loginPageOIB(
              color: Colors.white,
            ),
            errorBorder: Design().loginPageOIB(
              color: const Color.fromRGBO(211, 118, 118, 1),
            ),
            focusedErrorBorder: Design().loginPageOIB(
              color: const Color.fromRGBO(211, 118, 118, 1),
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
            AuthService().signInWithEmailAndPasswordForStudent(
              context,
              ref.watch(mailProvider),
              ref.watch(passProvider),
            );
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
            backgroundColor: const Color.fromARGB(255, 105, 77, 170),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(
                color: Colors.white,
                width: 2,
              ),
            ),
          ),
          child: Text(
            "Giriş Yap",
            style: Design().poppins(
              size: 17,
              color: Colors.white,
              fw: FontWeight.bold,
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Transform.scale(
      scale: 0.95,
      child: SizedBox(
        width: 350,
        child: ElevatedButton(
          onPressed: () {
            AuthService().resetPassword(ref.watch(mailProvider));
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(15),
            shadowColor: Colors.transparent,
            backgroundColor: const Color.fromARGB(255, 31, 52, 102),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(
                color: Colors.white,
                width: 2,
              ),
            ),
          ),
          child: Text(
            "Kurtarma e-postası al",
            style: Design().poppins(
              size: 17,
              color: Colors.white,
              fw: FontWeight.bold,
            ),
          ),
        ),
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
    final universities = ref.watch(universitiesProvider).asData?.value ?? [];
    return Transform.scale(
      scale: 0.95,
      child: Container(
        margin: const EdgeInsets.only(left: 10, right: 10),
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(
            width: 3,
            color: Colors.white,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButton(
          iconEnabledColor: Colors.white,
          padding: const EdgeInsets.only(left: 25, right: 25),
          style: Design().poppins(
            size: 15,
            fw: FontWeight.w600,
            color: const Color.fromRGBO(55, 55, 55, 1),
          ),
          dropdownColor: const Color.fromARGB(255, 91, 79, 170),
          underline: const Divider(color: Colors.transparent),
          isExpanded: true,
          borderRadius: BorderRadius.circular(8),
          hint: Text(
            "Üniversite Seç",
            style: Design().poppins(
              fw: FontWeight.bold,
              size: 15,
              color: Colors.white,
            ),
          ),
          value: ref.watch(searchProvider),
          onChanged: (value) {
            ref.read(searchProvider.notifier).state = value ?? 0;
          },
          menuMaxHeight: 250,
          items: [
            const DropdownMenuItem(
              value: 0,
              child: Text(
                "Lütfen Üniversite Seçiniz",
                style: TextStyle(color: Colors.white),
              ),
            ),
            if (universities.isNotEmpty)
              ...List.generate(
                universities.length,
                (index) {
                  return DropdownMenuItem(
                    value: index + 1,
                    child: Text(
                      universities[index].name,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

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
              image: AssetImage("assets/3.png"),
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
                  size: 25,
                  fw: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(flex: 1),
              Text(
                "Şifrenizi yenileme e-postası almak için\nmail adresinizi giriniz.",
                textAlign: TextAlign.center,
                style: Design().poppins(
                  size: 17,
                  color: Colors.white,
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
