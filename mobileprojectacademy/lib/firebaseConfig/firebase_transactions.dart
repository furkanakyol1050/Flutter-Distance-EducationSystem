import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final suniIdProvider = StreamProvider<String>((ref) {
  return FirebaseAuth.instance.authStateChanges().map((User? user) {
    if (user != null) {
      return user.photoURL?.split(",")[0] ?? ' ';
    } else {
      return ' ';
    }
  });
});

final sfacultyIdProvider = StreamProvider<String>((ref) {
  return FirebaseAuth.instance.authStateChanges().map((User? user) {
    if (user != null) {
      return user.photoURL?.split(",")[1] ?? ' ';
    } else {
      return ' ';
    }
  });
});

final sdepartmentIdProvider = StreamProvider<String>((ref) {
  return FirebaseAuth.instance.authStateChanges().map((User? user) {
    if (user != null) {
      return user.photoURL?.split(",")[2] ?? ' ';
    } else {
      return ' ';
    }
  });
});

final sstudentIdProvider = StreamProvider<String>((ref) {
  return FirebaseAuth.instance.authStateChanges().map((User? user) {
    if (user != null) {
      return user.photoURL?.split(",")[3] ?? ' ';
    } else {
      return ' ';
    }
  });
});

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Future<User?> signInWithEmailAndPasswordForStudent(
      BuildContext context, String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, '/home');
        return user;
      }
      // ignore: empty_catches
    } catch (e) {}
    return null;
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> resetPassword(String email) async {
    final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}

final universitiesProvider = StreamProvider<List<University>>((ref) {
  return UniversityService().getUniversitiesAsStream();
});

class University {
  final String id;
  final String name;

  University({required this.id, required this.name});
}

class Course {
  final String id;
  final String name;
  final String instructorId;
  final String startTime;
  final String endTime;
  final List<String> studentIds;

  Course({
    required this.id,
    required this.name,
    required this.instructorId,
    required this.startTime,
    required this.endTime,
    required this.studentIds,
  });
}

class Instructor {
  final String id;
  final String instructorID;
  final String firstName;
  final String lastName;
  final String branch;
  final String title;
  final String email;
  final String facultyId;
  final String departmentId;
  final List<String> courseIds; // Verilen derslerin ID'lerini içeren array

  Instructor({
    required this.id,
    required this.instructorID,
    required this.firstName,
    required this.lastName,
    required this.branch,
    required this.title,
    required this.email,
    required this.facultyId,
    required this.departmentId,
    required this.courseIds,
  });
}

class Homework {
  final String id;
  final String title;
  final List<String> fileUrls;
  final List<String> fileNames;
  final String giventime;
  final String deadline;

  Homework(
      {required this.id,
      required this.title,
      required this.fileUrls,
      required this.fileNames,
      required this.giventime,
      required this.deadline});
}

class CourseAnno {
  final String id;
  final String title;
  final String content;
  final String receiverId;
  final List<String> fileUrls;
  final List<String> fileNames;
  final String releaseDate;

  CourseAnno(
      {required this.id,
      required this.title,
      required this.content,
      required this.receiverId,
      required this.fileUrls,
      required this.fileNames,
      required this.releaseDate});
}

class UniversityService {
  final CollectionReference universities =
      FirebaseFirestore.instance.collection('universities');

  Stream<List<University>> getUniversitiesAsStream() {
    return universities.snapshots().map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) => University(id: doc.id, name: doc['name']))
          .toList();
    });
  }

  Stream<List<String>> getAssignedLectures(
      String uniId, String facultyId, String departmentId, String studentId) {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    return firestore
        .collection('universities')
        .doc(uniId)
        .collection('faculties')
        .doc(facultyId)
        .collection('departments')
        .doc(departmentId)
        .collection('students')
        .doc(studentId)
        .snapshots()
        .map((doc) => List<String>.from(doc['assignedLectures']));
  }

  Future<Course> getCourseDetails(String uniId, String facultyId,
      String departmentId, String courseId) async {
    try {
      final courseReference = FirebaseFirestore.instance
          .collection('universities')
          .doc(uniId)
          .collection('faculties')
          .doc(facultyId)
          .collection('departments')
          .doc(departmentId)
          .collection('courses')
          .doc(courseId);

      final snapshot = await courseReference.get();
      if (snapshot.exists) {
        final data = snapshot.data();
        return Course(
          id: snapshot.id,
          name: data?['name'] ?? '',
          instructorId: data?['instructorId'] ?? '',
          startTime: data?['startTime'] ?? '',
          endTime: data?['endTime'] ?? '',
          studentIds: List<String>.from(data?['studentIds'] ?? []),
        );
      } else {
        return Course(
          id: '',
          name: '',
          instructorId: '',
          startTime: '',
          endTime: '',
          studentIds: [],
        );
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<Instructor> getInstructor(
      String instructorId, String universityId) async {
    try {
      DocumentSnapshot instructorDoc = await FirebaseFirestore.instance
          .collection('universities')
          .doc(universityId)
          .collection('instructors')
          .doc(instructorId)
          .get();

      if (instructorDoc.exists) {
        return Instructor(
          id: instructorDoc.id,
          instructorID: instructorDoc['instructorID'],
          firstName: instructorDoc['firstName'],
          lastName: instructorDoc['lastName'],
          branch: instructorDoc['branch'],
          title: instructorDoc['title'],
          email: instructorDoc['email'],
          facultyId: instructorDoc['facultyId'],
          departmentId: instructorDoc['departmentId'],
          courseIds: List<String>.from(instructorDoc['courseIds']),
        );
      } else {
        throw Exception('Instructor not found');
      }
    } catch (e) {
      throw Exception('Failed to fetch instructor: $e');
    }
  }

  Future<List<Homework>> getCourseHomeworks(String universityId,
      String facultyId, String departmentId, String courseId) async {
    try {
      var snapshot = await universities
          .doc(universityId)
          .collection('faculties')
          .doc(facultyId)
          .collection('departments')
          .doc(departmentId)
          .collection('courses')
          .doc(courseId)
          .collection('homeworks')
          .get();

      return snapshot.docs
          .map((doc) => Homework(
                id: doc.id,
                title: doc['title'],
                fileUrls: List<String>.from(doc['fileUrls']),
                fileNames: List<String>.from(doc['fileNames']),
                giventime: doc['givenTime'],
                deadline: doc['deadline'],
              ))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendHomework(
      String universityId,
      String facultyId,
      String departmentId,
      String courseId,
      String homeworkId,
      String studentId,
      String title,
      List<String> fileUrls,
      List<String> fileNames,
      String time) async {
    DocumentReference<Object?> homeworkRef = universities
        .doc(universityId)
        .collection("faculties")
        .doc(facultyId)
        .collection("departments")
        .doc(departmentId)
        .collection("courses")
        .doc(courseId)
        .collection("homeworks")
        .doc(homeworkId);

    CollectionReference<Map<String, dynamic>> homeworks =
        homeworkRef.collection('senders');
    await homeworks.add({
      'senderId': studentId,
      'title': title,
      'fileUrls': fileUrls,
      'fileNames': fileNames,
      'givenTime': time,
    });
  }

  Future<bool> isAssigned(String uniId, String facultyId, String departmentId,
      String courseId, String studentId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    DocumentSnapshot snapshot = await firestore
        .collection('universities')
        .doc(uniId)
        .collection('faculties')
        .doc(facultyId)
        .collection('departments')
        .doc(departmentId)
        .collection('students')
        .doc(studentId)
        .get();

    if (snapshot.exists) {
      List<dynamic> assignedLectures = snapshot['assignedLectures'];
      return assignedLectures.contains(courseId);
    } else {
      return false;
    }
  }

  Future<bool> courseExists(String uniId, String facultyId, String departmentId,
      String courseId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    DocumentSnapshot snapshot = await firestore
        .collection('universities')
        .doc(uniId)
        .collection('faculties')
        .doc(facultyId)
        .collection('departments')
        .doc(departmentId)
        .collection('courses')
        .doc(courseId)
        .get();

    return snapshot.exists;
  }

  Future<List<CourseAnno>> getCourseAnnouncements(
      String universityId,
      String facultyId,
      String departmentId,
      String courseId,
      String studentId) async {
    try {
      var snapshot = await universities
          .doc(universityId)
          .collection('faculties')
          .doc(facultyId)
          .collection('departments')
          .doc(departmentId)
          .collection('courses')
          .doc(courseId)
          .collection('announcements')
          .orderBy('releaseDate', descending: true)
          .get();

      return snapshot.docs
          .where((doc) =>
              doc['receiverId'] == studentId || doc['receiverId'] == "")
          .map((doc) => CourseAnno(
                id: doc.id,
                content: doc['content'],
                title: doc['title'],
                receiverId: doc['receiverId'],
                fileUrls: List<String>.from(doc['fileUrls']),
                fileNames: List<String>.from(doc['fileNames']),
                releaseDate: doc['releaseDate'],
              ))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> downloadFile(String filePath) async {
    try {
      Reference ref = FirebaseStorage.instance.ref().child(filePath);
      String? result = await FilePicker.platform.getDirectoryPath();
      if (result != null) {
        File file = File(result);
        await ref.writeToFile(file);
        print('Dosya başarıyla indirildi ve kaydedildi: ${file.path}');
      } else {
        print('Dosya seçilmedi.');
      }
    } catch (e) {
      print('Hata oluştu: $e');
    }
  }

  Future<List<String>> getAssignedLectureIds(
    String universityId,
    String facultyId,
    String departmentId,
    String studentId,
  ) async {
    DocumentSnapshot studentDoc = await FirebaseFirestore.instance
        .collection('universities')
        .doc(universityId)
        .collection('faculties')
        .doc(facultyId)
        .collection('departments')
        .doc(departmentId)
        .collection('students')
        .doc(studentId)
        .get();

    // Get the assignedLectures list
    List<String> assignedLectures =
        List<String>.from(studentDoc['assignedLectures']);

    return assignedLectures;
  }

  Future<List<Map<String, dynamic>>> getLectureDetails(
    String universityId,
    String facultyId,
    String departmentId,
    List<String> lectureIds,
  ) async {
    List<Map<String, dynamic>> lectureDetailsList = [];

    for (String lectureId in lectureIds) {
      DocumentSnapshot courseDoc = await FirebaseFirestore.instance
          .collection('universities')
          .doc(universityId)
          .collection('faculties')
          .doc(facultyId)
          .collection('departments')
          .doc(departmentId)
          .collection('courses')
          .doc(lectureId)
          .get();

      String instructorId = courseDoc['instructorId'];

      String instructorName = "";

      DocumentSnapshot instructorSnapshot = await FirebaseFirestore.instance
          .collection('universities')
          .doc(universityId)
          .collection('instructors')
          .doc(instructorId)
          .get();

      if (instructorSnapshot.exists) {
        Map<String, dynamic> instructorData =
            instructorSnapshot.data() as Map<String, dynamic>;
        instructorName =
            "${instructorData['title']} ${instructorData['firstName']} ${instructorData['lastName']}";
      }

      Map<String, dynamic> courseData = {
        'name': courseDoc['name'],
        'startTime': List<String>.from(courseDoc['startTime']),
        'endTime': List<String>.from(courseDoc['endTime']),
        'day': List<String>.from(courseDoc['day']),
        'instructorName': instructorName
      };

      // Add the course details to the list
      lectureDetailsList.add(courseData);
    }
    return lectureDetailsList;
  }

  Future<List<Map<String, dynamic>>> getHomeworkCalDetails(
    String universityId,
    String facultyId,
    String departmentId,
    List<String> lectureIds,
  ) async {
    List<Map<String, dynamic>> homeworkDetailsList = [];

    for (String lectureId in lectureIds) {
      DocumentSnapshot courseDoc = await FirebaseFirestore.instance
          .collection('universities')
          .doc(universityId)
          .collection('faculties')
          .doc(facultyId)
          .collection('departments')
          .doc(departmentId)
          .collection('courses')
          .doc(lectureId)
          .get();

      String courseName = courseDoc['name'];

      // Ödevler koleksiyonundaki tüm dökümanları al
      QuerySnapshot homeworkDocs = await FirebaseFirestore.instance
          .collection('universities')
          .doc(universityId)
          .collection('faculties')
          .doc(facultyId)
          .collection('departments')
          .doc(departmentId)
          .collection('courses')
          .doc(lectureId)
          .collection('homeworks')
          .get();

      // Her bir ödev dökümanını listeye ekle
      for (var homeworkDoc in homeworkDocs.docs) {
        Map<String, dynamic> homeworkData = {
          'deadline': homeworkDoc['deadline'],
          'title': homeworkDoc['title'],
          'name': courseName,
        };

        homeworkDetailsList.add(homeworkData);
      }
    }

    return homeworkDetailsList;
  }

  Future<List<Map<String, dynamic>>> getExamCalDetails(
    String universityId,
    String facultyId,
    String departmentId,
    List<String> lectureIds,
  ) async {
    List<Map<String, dynamic>> examDetailsList = [];

    for (String lectureId in lectureIds) {
      DocumentSnapshot courseDoc = await FirebaseFirestore.instance
          .collection('universities')
          .doc(universityId)
          .collection('faculties')
          .doc(facultyId)
          .collection('departments')
          .doc(departmentId)
          .collection('courses')
          .doc(lectureId)
          .get();

      String courseName = courseDoc['name'];

      QuerySnapshot examDocs = await FirebaseFirestore.instance
          .collection('universities')
          .doc(universityId)
          .collection('faculties')
          .doc(facultyId)
          .collection('departments')
          .doc(departmentId)
          .collection('courses')
          .doc(lectureId)
          .collection('exams')
          .get();

      for (var examDoc in examDocs.docs) {
        String beginDate = examDoc['beginDate'];
        String beginTime = examDoc['beginTime'];
        int examTime = examDoc['examTime'];

        DateTime startTime = DateTime.parse(beginDate);
        List<String> timeParts = beginTime
            .replaceAll('TimeOfDay(', '')
            .replaceAll(')', '')
            .split(':');
        int hour = int.parse(timeParts[0]);
        int minute = int.parse(timeParts[1]);
        startTime = startTime.add(Duration(hours: hour, minutes: minute));

        DateTime endTime = startTime.add(Duration(minutes: examTime));

        Map<String, dynamic> examData = {
          'startTime': startTime,
          'endTime': endTime,
          'subject': '$courseName Sınavı',
          'notes': examDoc['type'],
        };

        examDetailsList.add(examData);
      }
    }

    return examDetailsList;
  }
}
