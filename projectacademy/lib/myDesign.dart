// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Design {
  final Color blue = const Color.fromRGBO(170, 212, 242, 1);
  final Color dblue = const Color.fromARGB(255, 121, 186, 233);
  final Color lgreen = const Color.fromRGBO(203, 228, 187, 1);
  final Color green = const Color.fromRGBO(161, 214, 183, 1);
  final Color orange = const Color.fromRGBO(197, 140, 111, 1);
  final Color purple = const Color.fromRGBO(117, 106, 182, 1);

  final Color grey = const Color.fromRGBO(220, 220, 220, 1);

  TextStyle poppins({
    double size = 13,
    FontWeight fw = FontWeight.normal,
    double ls = 0,
    Color color = Colors.black,
  }) {
    return GoogleFonts.poppins(
      color: color,
      fontSize: size,
      fontWeight: fw,
      letterSpacing: ls,
    );
  }

  OutlineInputBorder loginPageOIB({
    Color color = Colors.white,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: color,
        width: 2,
      ),
    );
  }
}

showSnackBarWidget(
  BuildContext context,
  String text, {
  Color color = const Color.fromRGBO(246, 153, 92, 1),
  IconData icon = Icons.warning,
}) {
  return ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 2),
      padding: const EdgeInsets.only(top: 8, bottom: 8, left: 15, right: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
      width: 400,
      backgroundColor: color,
      content: Center(
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const Spacer(),
            Text(
              text,
              style: Design().poppins(
                color: Colors.white,
                size: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
          ],
        ),
      ),
    ),
  );
}
