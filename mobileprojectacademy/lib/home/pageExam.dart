// ignore_for_file: file_names

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobileprojectacademy/myDesign.dart';

final isClassicQuestProvider = StateProvider((ref) => false);

final photoProvider = StateProvider((ref) => Uint8List(0));

class ExamPage extends ConsumerWidget {
  const ExamPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return ListView(
      children: [
        Container(
          height: 50,
          alignment: Alignment.center,
          color: Colors.white,
          child: Text(
            "Sınav Yardımcısı",
            style: Design().poppins(
              color: Colors.grey.shade800,
              fw: FontWeight.bold,
              size: 16,
            ),
          ),
        ),
        ref.watch(isClassicQuestProvider)
            ? Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20, top: 10),
                      child: Icon(
                        Icons.info_outline,
                        color: Colors.grey.shade800,
                        size: 50,
                      ),
                    ),
                    Text(
                      "Sınavınızda klasik soruya geldiğinizde bu sayfa aktifleşecektir.",
                      style: Design().poppins(
                        color: Colors.grey.shade800,
                        fw: FontWeight.w600,
                        size: 20,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(20),
                    height: size.width,
                    width: size.width,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ref.watch(photoProvider) != Uint8List(0)
                        ? Image(
                            image: Image.memory(ref.watch(photoProvider)).image,
                          )
                        : Container(),
                  ),
                  SizedBox(
                    width: 370,
                    child: ElevatedButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();

                        final XFile? photo =
                            await picker.pickImage(source: ImageSource.camera);

                        if (photo != null) {
                          ref.read(photoProvider.notifier).state =
                              await photo.readAsBytes();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(15),
                        shadowColor: Colors.transparent,
                        backgroundColor:
                            const Color.fromARGB(255, 105, 77, 170),
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
                        "Resim çek",
                        style: Design().poppins(
                          size: 17,
                          color: Colors.white,
                          fw: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(15),
                        shadowColor: Colors.transparent,
                        backgroundColor: const Color.fromARGB(255, 64, 24, 156),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(88),
                          side: const BorderSide(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        "Gönder",
                        style: Design().poppins(
                          size: 17,
                          color: Colors.white,
                          fw: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ],
    );
  }
}
