// ignore_for_file: file_names

import 'package:flutter/material.dart';

class EmptyQuestion {
  String point;
  Key key;

  EmptyQuestion({
    required this.point,
    required this.key,
  });
}

class ClassicQuestion {
  String photoUrl;
  String text;
  String answerUrl;
  String answer;
  String point;
  Key key;

  ClassicQuestion({
    required this.photoUrl,
    required this.text,
    this.answerUrl = "",
    this.answer = "",
    required this.point,
    required this.key,
  });
}

class GapFillingQuestion {
  String firstText;
  String lastText;
  String answer;
  String correctAnswer;
  String point;
  Key key;

  GapFillingQuestion({
    required this.firstText,
    required this.lastText,
    this.answer = "",
    required this.correctAnswer,
    required this.point,
    required this.key,
  });
}

class TrueFalseQuestion {
  String text;
  String answer;
  String correctAnswer;
  String point;
  Key key;

  TrueFalseQuestion({
    required this.text,
    this.answer = "",
    required this.correctAnswer,
    required this.point,
    required this.key,
  });
}

class TextQuestion {
  String photoUrl;
  String text;
  String answer;
  String point;
  Key key;

  TextQuestion({
    required this.photoUrl,
    required this.text,
    this.answer = "",
    required this.point,
    required this.key,
  });
}

class TestQuestion {
  String photoUrl;
  String text;
  List<String> options;
  String answer;
  String correctAnswer;
  String point;
  Key key;

  TestQuestion({
    required this.photoUrl,
    required this.text,
    required this.options,
    this.answer = "",
    required this.correctAnswer,
    required this.point,
    required this.key,
  });
}
