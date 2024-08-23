import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:projectacademy/firebaseConfig/firebase_transactionss.dart';
import 'package:projectacademy/myDesign.dart';

class AdminPanel extends ConsumerWidget {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: ref.watch(isAdminProvider) == 1
          ? Container(
              alignment: Alignment.center,
              height: size.height,
              width: size.width,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/1.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  size.width > 1000
                      ? Container(
                          width: 250,
                          padding: const EdgeInsets.only(
                            top: 50,
                            bottom: 50,
                            left: 20,
                            right: 20,
                          ),
                          color: Colors.white.withOpacity(0.5),
                          child: Column(
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.all(20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  showUniAddAlertDialog(context, ref);
                                },
                                icon: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                ),
                                label: size.width < 1000
                                    ? Container()
                                    : Text(
                                        "Üniversite Ekle",
                                        style: Design().poppins(
                                          fw: FontWeight.bold,
                                          color: Colors.white,
                                          size: size.width * 0.007,
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 50),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.all(20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  ref.read(isAdminProvider.notifier).state = 0;
                                  Navigator.pop(context);
                                },
                                icon: const Icon(
                                  Icons.exit_to_app_rounded,
                                  color: Colors.white,
                                ),
                                label: size.width < 1000
                                    ? Container()
                                    : Text(
                                        "Güvenli Çıkış",
                                        style: Design().poppins(
                                          fw: FontWeight.bold,
                                          color: Colors.white,
                                          size: size.width * 0.007,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                  Expanded(
                    child: Column(
                      children: [
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: SearchBar(
                              shape: MaterialStatePropertyAll(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              shadowColor: const MaterialStatePropertyAll(
                                Colors.transparent,
                              ),
                              backgroundColor: const MaterialStatePropertyAll(
                                Colors.white,
                              ),
                              overlayColor: const MaterialStatePropertyAll(
                                Colors.white,
                              ),
                              surfaceTintColor: MaterialStatePropertyAll(
                                Design().grey,
                              ),
                              hintText: "Üniversite Ara",
                              hintStyle: MaterialStatePropertyAll(
                                Design().poppins(
                                  size: 18,
                                  color: Colors.grey.shade500,
                                  fw: FontWeight.w400,
                                ),
                              ),
                              textStyle: MaterialStatePropertyAll(
                                Design().poppins(
                                  size: 18,
                                  color: Colors.grey.shade600,
                                  fw: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const UniListWidget(),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Container(),
    );
  }
}

class UniListWidget extends ConsumerWidget {
  const UniListWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      child: ref.watch(universitiesProvider).when(
            data: (data) {
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final universities = data;
                  return ExpansionTileCard(
                    expandedColor: Colors.white,
                    shadowColor: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    baseColor: Colors.white,
                    expandedTextColor: const Color.fromRGBO(5, 5, 5, 0.9),
                    initialPadding: const EdgeInsets.only(
                      left: 30,
                      right: 30,
                      bottom: 20,
                    ),
                    finalPadding: const EdgeInsets.only(
                      left: 30,
                      right: 30,
                      bottom: 20,
                    ),
                    leading: const CircleAvatar(
                      backgroundColor: Color.fromRGBO(5, 5, 5, 0.9),
                      child: Text(
                        'X',
                        style: TextStyle(
                          color: Colors.white60,
                        ),
                      ),
                    ),
                    title: Text(
                      universities[index].name,
                      style: Design().poppins(fw: FontWeight.bold, size: 18),
                    ),
                    subtitle: Text(
                      universities[index].id,
                      style: Design().poppins(),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton(
                          style: const ButtonStyle(
                            overlayColor: MaterialStatePropertyAll(
                              Colors.transparent,
                            ),
                          ),
                          onPressed: () {
                            ref.read(selectedUniversityId.notifier).state =
                                universities[index].id;
                            showAdminAddAlertDialog(context, ref);
                          },
                          child: Column(
                            children: [
                              const Icon(
                                Icons.person_add_alt_1,
                                color: Color.fromRGBO(5, 5, 5, 0.9),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 2.0,
                                ),
                              ),
                              Text(
                                'Ekle',
                                style: Design().poppins(
                                  color: const Color.fromRGBO(5, 5, 5, 0.9),
                                  fw: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          style: const ButtonStyle(
                            overlayColor: MaterialStatePropertyAll(
                              Colors.transparent,
                            ),
                          ),
                          onLongPress: () async {
                            await FirebaseFirestore.instance
                                .collection('universities')
                                .doc(universities[index].id)
                                .delete();
                          },
                          onPressed: () {},
                          child: Column(
                            children: [
                              const Icon(
                                Icons.folder_delete_rounded,
                                color: Color.fromRGBO(5, 5, 5, 0.9),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 2.0,
                                ),
                              ),
                              Text(
                                'Sil',
                                style: Design().poppins(
                                  color: const Color.fromRGBO(5, 5, 5, 0.9),
                                  fw: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    children: [
                      AdminListWidget(
                        universities: universities,
                        index: index,
                      ),
                    ],
                  );
                },
              );
            },
            loading: () => const Center(
              child: SpinKitFadingCube(
                color: Colors.white,
                size: 50.0,
              ),
            ),
            error: (error, stackTrace) => Text('Hata: $error'),
          ),
    );
  }
}

class AdminListWidget extends ConsumerWidget {
  const AdminListWidget(
      {super.key, required this.universities, required this.index});

  final List<University> universities;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    final universityId = universities[index].id;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 16.0,
      ),
      child: ref.watch(universityAdminsProvider(universityId)).when(
            data: (admins) {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: admins.length,
                itemBuilder: (context, index2) {
                  return size.width < 1200
                      ? Column(
                          children: [
                            IconButton(
                              onPressed: () async {
                                await UniversityService().deleteAdmin(
                                    universities[index].id,
                                    admins[index2]["uid"]);
                              },
                              icon: const Icon(Icons.delete),
                            ),
                            const SizedBox(width: 30),
                            SizedBox(
                              width: 300,
                              child: Text(
                                admins[index2]['uid'],
                                overflow: TextOverflow.ellipsis,
                                style: Design().poppins(),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  width: 130,
                                  child: Text(
                                    "Username: ${admins[index2]['username']}",
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        Design().poppins(fw: FontWeight.w600),
                                  ),
                                ),
                                SizedBox(
                                  width: 130,
                                  child: Text(
                                    "Password: ${admins[index2]['password']}",
                                    overflow: TextOverflow.ellipsis,
                                    style:
                                        Design().poppins(fw: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(
                              color: Colors.black,
                              height: 2,
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () async {
                                await UniversityService().deleteAdmin(
                                    universities[index].id,
                                    admins[index2]["uid"]);
                              },
                              icon: const Icon(Icons.delete),
                            ),
                            const SizedBox(width: 30),
                            SizedBox(
                              width: 300,
                              child: Text(
                                admins[index2]['uid'],
                                overflow: TextOverflow.ellipsis,
                                style: Design().poppins(),
                              ),
                            ),
                            SizedBox(
                              width: 270,
                              child: Text(
                                "Username: ${admins[index2]['username']}",
                                overflow: TextOverflow.ellipsis,
                                style: Design().poppins(fw: FontWeight.w600),
                              ),
                            ),
                            SizedBox(
                              width: 270,
                              child: Text(
                                "Password: ${admins[index2]['password']}",
                                overflow: TextOverflow.ellipsis,
                                style: Design().poppins(fw: FontWeight.w600),
                              ),
                            ),
                          ],
                        );
                },
              );
            },
            loading: () => Container(),
            error: (error, stackTrace) => Text('Hata: $error'),
          ),
    );
  }
}

final uniName = StateProvider((ref) => "");
final adminUsername = StateProvider((ref) => "");
final adminPass = StateProvider((ref) => "");

showUniAddAlertDialog(BuildContext context, WidgetRef ref) {
  Widget okButton = ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color.fromRGBO(5, 5, 5, 0.9),
      padding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    child: const Text("Ekle", style: TextStyle(color: Colors.white)),
    onPressed: () async {
      Navigator.of(context).pop();
      if (ref.watch(uniName).isNotEmpty &&
          ref.watch(adminUsername).isNotEmpty &&
          ref.watch(adminPass).isNotEmpty) {
        String uniNameVal = ref.watch(uniName);
        String adminUsernameVal = ref.watch(adminUsername);
        String adminPassVal = ref.watch(adminPass);

        await UniversityService()
            .addUniversity(uniNameVal, adminUsernameVal, adminPassVal);
      }
    },
  );

  AlertDialog alert = AlertDialog(
    backgroundColor: Colors.white70,
    content: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildRow("Üniversite Adı", uniName, ref),
          buildRow("Yönetici Kullanıcı Adı", adminUsername, ref),
          buildRow("Yönetici Şifresi", adminPass, ref),
          const SizedBox(height: 40),
          okButton,
        ],
      ),
    ),
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

final newAdminUsername = StateProvider((ref) => "");
final newAdminPass = StateProvider((ref) => "");
final selectedUniversityId = StateProvider((ref) => "");

showAdminAddAlertDialog(BuildContext context, WidgetRef ref) {
  Widget okButton = ElevatedButton(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color.fromRGBO(5, 5, 5, 0.9),
      padding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    child: const Text("Ekle", style: TextStyle(color: Colors.white)),
    onPressed: () async {
      Navigator.of(context).pop();
      String newAdminUsernameVal = ref.watch(newAdminUsername);
      String newAdminPassVal = ref.watch(newAdminPass);
      String selectedUniversityIdVal = ref.watch(selectedUniversityId);

      UniversityService().addAdmin(
          selectedUniversityIdVal, newAdminUsernameVal, newAdminPassVal);
    },
  );

  AlertDialog alert = AlertDialog(
    backgroundColor: Colors.white70,
    content: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildRow("Yönetici Kullanıcı Adı", newAdminUsername, ref),
          buildRow("Yönetici Şifresi", newAdminPass, ref),
          const SizedBox(height: 40),
          okButton,
        ],
      ),
    ),
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

Widget buildRow(
    String labelText, StateProvider<String> provider, WidgetRef ref) {
  return Row(
    children: [
      SizedBox(
        width: 300,
        child: TextFormField(
          cursorColor: Colors.black,
          onChanged: (value) {
            ref.read(provider.notifier).state = value;
          },
          decoration: InputDecoration(
            hintText: labelText,
            enabledBorder: const UnderlineInputBorder(),
            focusedBorder: const UnderlineInputBorder(),
          ),
        ),
      ),
    ],
  );
}
