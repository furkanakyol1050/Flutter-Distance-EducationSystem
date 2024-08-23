import 'dart:async';
import 'dart:html';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:projectacademy/Pages/hub/instructorpanel/homepage.dart';
import 'package:projectacademy/Pages/hub/uniadminpanel/homepage.dart';

final levelProvider = StateProvider((ref) => -1);

final isAdminProvider = StateProvider((ref) => 0); //! DEĞİŞECEK

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  singInAdmin(
    String username,
    String password,
    BuildContext context,
    WidgetRef ref,
  ) async {
    CollectionReference collectionReference =
        FirebaseFirestore.instance.collection('admin');

    QuerySnapshot querySnapshot = await collectionReference.get();

    for (var doc in querySnapshot.docs) {
      if (doc['username'] == username && doc["pass"] == password) {
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, "/admin");
        ref.read(isAdminProvider.notifier).state = 1;
      }
    }
  }

  // Sign in with email and password
  Future<User?> signInWithEmailAndPasswordForAdmin(BuildContext context,
      String email, String password, WidgetRef ref) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;
      if (user != null) {
        ref.read(levelProvider.notifier).state = 0;
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, '/uniadmin');
        return user;
      }
      // ignore: empty_catches
    } catch (e) {}
    return null;
  }

  Future<User?> signInWithEmailAndPasswordForInstructor(BuildContext context,
      String email, String password, WidgetRef ref) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        ref.read(levelProvider.notifier).state = 1;
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, '/instructorpanel');
        return user;
      }
      // ignore: empty_catches
    } catch (e) {}
    return null;
  }

  Future<User?> signInWithEmailAndPasswordForStudent(BuildContext context,
      String email, String password, WidgetRef ref) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = result.user;

      if (user != null) {
        ref.read(levelProvider.notifier).state = 2;
        // ignore: use_build_context_synchronously
        Navigator.pushNamed(context, '/studentpanel');
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
}

String generatePassword() {
  final random = Random();
  const characters =
      'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#%^&*()_+';
  String password = '';
  for (int i = 0; i < 12; i++) {
    password += characters[random.nextInt(characters.length)];
  }
  return password;
}

final userPhotoUrlProvider = StreamProvider<String>((ref) {
  return FirebaseAuth.instance.authStateChanges().map((User? user) {
    if (user != null) {
      return user.photoURL ?? ' ';
    } else {
      return '';
    }
  });
});

final universitiesProvider = StreamProvider<List<University>>((ref) {
  return UniversityService().getUniversitiesAsStream();
});

final universityAdminsProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>(
        (ref, universityId) {
  return UniversityService().getUniversityAdminsAsStream(universityId);
});

final instructorsStreamProvider = StreamProvider<List<Instructor>>((ref) {
  final departmentId = ref.watch(departmentIdProvider);
  final facultyId = ref.watch(facultyIdProvider);
  final universityId = ref.watch(userPhotoUrlProvider).asData?.value ?? "";

  return UniversityService()
      .getDepartmentInstructorsAsStream(universityId, facultyId, departmentId);
});

class University {
  final String id;
  final String name;

  University({required this.id, required this.name});
}

class Faculty {
  final String id;
  final String name;

  Faculty({required this.id, required this.name});
}

class Department {
  final String id;
  final String name;

  Department({required this.id, required this.name});
}

class Announcement {
  final String id;
  final String facultyId;
  final String title;
  final String content;
  final String releaseDate;

  Announcement(
      {required this.id,
      required this.facultyId,
      required this.title,
      required this.content,
      required this.releaseDate});
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

class Student {
  final String id;
  final String mail;
  final String name;
  final String sname;
  final String no;
  final String departmentId;
  final String facultyId;
  final List assignedLectures;

  Student({
    required this.id,
    required this.mail,
    required this.name,
    required this.sname,
    required this.no,
    required this.departmentId,
    required this.facultyId,
    required this.assignedLectures,
  });
}

class Course {
  final String id;
  final String name;
  final String instructorId;
  final List<String> startTime;
  final List<String> endTime;
  final List<String> day;
  final List<String> studentIds;
  final String roomInsId;
  final String roomId;

  Course({
    required this.id,
    required this.name,
    required this.instructorId,
    required this.startTime,
    required this.endTime,
    required this.day,
    required this.studentIds,
    required this.roomInsId,
    required this.roomId,
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

class UniversityService {
  final CollectionReference universities =
      FirebaseFirestore.instance.collection('universities');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addUniversity(
      String universityName, String adminUsername, String adminPassword) async {
    // Üniversite ekleniyor
    DocumentReference<Object?> universityRef = await universities.add({
      'name': universityName,
    });

    String universityId = universityRef.id;

    await _createAdminAndAuthenticate(
        universityId, adminUsername, adminPassword);
  }

  Future<void> addAdmin(
      String universityId, String adminUsername, String adminPassword) async {
    _createAdminAndAuthenticate(universityId, adminUsername, adminPassword);
  }

  Future<void> _createAdminAndAuthenticate(
      String universityId, String adminUsername, String adminPassword) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: '$adminUsername@gmail.com',
        password: adminPassword,
      );

      User? user = userCredential.user;
      await user?.updateDisplayName(adminUsername);
      await user?.updatePhotoURL(universityId);

      await universities
          .doc(universityId)
          .collection('admins')
          .doc(user?.uid)
          .set({'username': adminUsername, 'password': adminPassword});
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> _createInstructorAndAuthenticate(
    String universityId,
    String facultyId,
    String departmentId,
    String instructorMail,
    String instructorPass,
    String instructorId,
  ) async {
    try {
      FirebaseApp app = await Firebase.initializeApp(
          name: 'Secondary', options: Firebase.app().options);
      var userCredential = await FirebaseAuth.instanceFor(app: app)
          .createUserWithEmailAndPassword(
        email: instructorMail,
        password: instructorPass,
      );
      User? user = userCredential.user;
      await user!.updateDisplayName(instructorMail.split('@')[0]);
      await user.updatePhotoURL(
          '$universityId,$facultyId,$departmentId,$instructorId');
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> _createStudentAndAuthenticate(
      String universityId,
      String facultyId,
      String departmentId,
      String studentMail,
      String studentPass,
      String studentId) async {
    try {
      FirebaseApp app = await Firebase.initializeApp(
          name: 'Secondary', options: Firebase.app().options);

      var userCredential = await FirebaseAuth.instanceFor(app: app)
          .createUserWithEmailAndPassword(
        email: studentMail,
        password: studentPass,
      );

      User? user = userCredential.user;
      await user?.updateDisplayName(studentMail.split('@')[0]);
      await user
          ?.updatePhotoURL('$universityId,$facultyId,$departmentId,$studentId');
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> deleteUniversity(String universityId) async {
    try {
      await FirebaseFirestore.instance
          .collection('universities')
          .doc(universityId)
          .delete();
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> deleteAnnouncement(
      String universityId, String announcementId) async {
    try {
      await universities
          .doc(universityId)
          .collection('announcements')
          .doc(announcementId)
          .delete();
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> deleteCourseAnnouncement(String universityId, String facultyId,
      String departmentId, String courseId, String announcementId) async {
    try {
      await universities
          .doc(universityId)
          .collection('faculties')
          .doc(facultyId)
          .collection('departments')
          .doc(departmentId)
          .collection('courses')
          .doc(courseId)
          .collection('announcements')
          .doc(announcementId)
          .delete();
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> deleteHomework(String universityId, String facultyId,
      String departmentId, String courseId, String homeworkId) async {
    try {
      await universities
          .doc(universityId)
          .collection('faculties')
          .doc(facultyId)
          .collection('departments')
          .doc(departmentId)
          .collection('courses')
          .doc(courseId)
          .collection('homeworks')
          .doc(homeworkId)
          .delete();
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> deleteStudent(String universityId, String facultyId,
      String departmentId, String studentId) async {
    try {
      await universities
          .doc(universityId)
          .collection('faculties')
          .doc(facultyId)
          .collection('departments')
          .doc(departmentId)
          .collection('students')
          .doc(studentId)
          .get()
          .then((value) {
        for (var course in value["assignedLectures"]) {
          universities
              .doc(universityId)
              .collection('faculties')
              .doc(facultyId)
              .collection('departments')
              .doc(departmentId)
              .collection('courses')
              .doc(course)
              .get()
              .then((value) {
            value["studentIds"].remove(studentId);
          });
        }

        universities
            .doc(universityId)
            .collection('faculties')
            .doc(facultyId)
            .collection('departments')
            .doc(departmentId)
            .collection('students')
            .doc(studentId)
            .delete();
      });

      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> deleteInstructor(
      String universityId, String instrcutorId) async {
    try {
      await universities
          .doc(universityId)
          .collection('instructors')
          .doc(instrcutorId)
          .delete();
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> deleteAnnouncementFor(
      String universityId, String facultyId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await universities
          .doc(universityId)
          .collection('announcements')
          .get();

      for (var doc in querySnapshot.docs) {
        if (doc['facultyId'] == facultyId) {
          UniversityService().deleteAnnouncement(universityId, doc.id);
        }
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> deleteAdmin(String universityId, String adminId) async {
    try {
      await FirebaseFirestore.instance
          .collection('universities')
          .doc(universityId)
          .collection('admins')
          .doc(adminId)
          .delete();
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<DocumentReference<Map<String, dynamic>>> addFaculty(
      String universityId, String facultyName) async {
    return await universities.doc(universityId).collection('faculties').add({
      'name': facultyName,
    });
  }

  Future<void> addAnnouncement(String universityId, String facultyId,
      String announcementContent, String announcementTitle) async {
    DocumentReference<Object?> universityRef = universities.doc(universityId);

    var date = DateTime.now().toString();

    CollectionReference<Map<String, dynamic>> announcements =
        universityRef.collection('announcements');
    await announcements.add({
      'facultyId': facultyId,
      'content': announcementContent,
      'title': announcementTitle,
      'releaseDate': date,
    });
  }

  Future<void> addCourseAnnouncement(
      String universityId,
      String facultyId,
      String departmentId,
      String courseId,
      String announcementTitle,
      String announcementContent,
      String receiverId,
      List<String> fileNames,
      List<String> fileUrls) async {
    DocumentReference<Object?> courseAnnoRef = universities
        .doc(universityId)
        .collection('faculties')
        .doc(facultyId)
        .collection('departments')
        .doc(departmentId)
        .collection('courses')
        .doc(courseId);

    var date = DateTime.now().toString();

    CollectionReference<Map<String, dynamic>> announcements =
        courseAnnoRef.collection('announcements');
    await announcements.add({
      'content': announcementContent,
      'title': announcementTitle,
      'receiverId': receiverId,
      'releaseDate': date,
      'fileNames': fileNames,
      'fileUrls': fileUrls,
    });
  }

  Future<void> addHomework(
      String universityId,
      String facultyId,
      String departmentId,
      String courseId,
      String title,
      List<String> fileUrls,
      List<String> fileNames,
      String time,
      String deadline) async {
    DocumentReference<Object?> courseRef = universities
        .doc(universityId)
        .collection("faculties")
        .doc(facultyId)
        .collection("departments")
        .doc(departmentId)
        .collection("courses")
        .doc(courseId);

    CollectionReference<Map<String, dynamic>> homeworks =
        courseRef.collection('homeworks');
    await homeworks.add({
      'title': title,
      'fileUrls': fileUrls,
      'fileNames': fileNames,
      'givenTime': time,
      'deadline': deadline,
    });
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

  Future<DocumentReference<Map<String, dynamic>>> addDepartment(
      String universityId, String facultyId, String departmentName) async {
    return await universities
        .doc(universityId)
        .collection('faculties')
        .doc(facultyId)
        .collection('departments')
        .add({
      'name': departmentName,
    });
  }

  Future<DocumentReference<Map<String, dynamic>>> addStudent(
      String universityId,
      String facultyId,
      String departmentId,
      String studentName,
      String studentSname,
      String studentNo,
      String studentMail,
      List<String> assignedLectures) async {
    DocumentReference<Map<String, dynamic>> studentRef = await universities
        .doc(universityId)
        .collection('faculties')
        .doc(facultyId)
        .collection('departments')
        .doc(departmentId)
        .collection('students')
        .add({
      'name': studentName,
      'sname': studentSname,
      'no': studentNo,
      'mail': studentMail,
      'facultyId': facultyId,
      'departmentId': departmentId,
      'universityId': universityId,
      'assignedLectures': assignedLectures
    });

    String studentId = studentRef.id;

    _createStudentAndAuthenticate(universityId, facultyId, departmentId,
        studentMail, generatePassword(), studentId);

    return studentRef;
  }

  Future<bool> courseExist(String uniId, String instructorId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      DocumentSnapshot snapshot = await firestore
          .collection('universities')
          .doc(uniId)
          .collection('instructors')
          .doc(instructorId)
          .get();

      if (snapshot.data() != null) {
        List<String> courseIds = List<String>.from(snapshot['courseIds'] ?? []);
        return courseIds.isNotEmpty;
      } else {
        return false;
      }
    } catch (e) {
      print('Error fetching course data: $e');
      return false;
    }
  }

  Future<DocumentReference<Map<String, dynamic>>> addCourseToDepartment(
    String universityId,
    String facultyId,
    String departmentId,
    String courseName,
    String instructorId,
    List<String> startTime,
    List<String> entTime,
    List<String> day,
    List<String> studentIds,
    String roomInsId,
    String roomId,
  ) async {
    DocumentReference<Map<String, dynamic>> courseRef = await universities
        .doc(universityId)
        .collection('faculties')
        .doc(facultyId)
        .collection('departments')
        .doc(departmentId)
        .collection('courses')
        .add({
      'name': courseName,
      'instructorId': instructorId,
      'studentIds': studentIds,
      'startTime': startTime,
      'day': day,
      'endTime': entTime,
      'roomInsId': roomInsId,
      'roomId': roomId
    });

    String courseId = courseRef.id;

    updateGivenCourses(universityId, instructorId, courseId);

    return courseRef;
  }

  Future<DocumentReference<Map<String, dynamic>>> addInstructorToUniversity(
      String universityId,
      String instructorID,
      String firstName,
      String lastName,
      String branch,
      String title,
      String email,
      String facultyId,
      String departmentId,
      List<String> courseIds) async {
    DocumentReference<Map<String, dynamic>> instructorRef =
        await universities.doc(universityId).collection('instructors').add({
      'instructorID': instructorID,
      'firstName': firstName,
      'lastName': lastName,
      'branch': branch,
      'title': title,
      'email': email,
      'facultyId': facultyId,
      'departmentId': departmentId,
      'courseIds': courseIds,
    });

    String instructorDocId = instructorRef.id;

    _createInstructorAndAuthenticate(universityId, facultyId, departmentId,
        email, generatePassword(), instructorDocId);

    return instructorRef;
  }

  Stream<List<University>> getUniversitiesAsStream() {
    return universities.snapshots().map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) => University(id: doc.id, name: doc['name']))
          .toList();
    });
  }

  Stream<int> getDepartmentCountAsStream(String uniId, String facultyId) {
    return FirebaseFirestore.instance
        .collection('universities')
        .doc(uniId)
        .collection('faculties')
        .doc(facultyId)
        .collection('departments')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<List<Map<String, dynamic>>> getUniversityAdminsAsStream(
      String universityId) {
    return universities
        .doc(universityId)
        .collection('admins')
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) => {
                'uid': doc.id,
                'username': doc['username'],
                'password': doc['password'],
              })
          .toList();
    });
  }

  Stream<List<Faculty>> getFacultiesAsStream(String universityId) {
    return universities
        .doc(universityId)
        .collection('faculties')
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) => Faculty(id: doc.id, name: doc['name']))
          .toList();
    });
  }

  Stream<List<Faculty>> getFaculties(String universityId, String searchTerm) {
    return universities
        .doc(universityId)
        .collection('faculties')
        .snapshots()
        .map((querySnapshot) {
      List<Faculty> faculties = [];
      for (var doc in querySnapshot.docs) {
        if (searchTerm.isEmpty ||
            doc['name']
                .toString()
                .toLowerCase()
                .contains(searchTerm.toLowerCase())) {
          faculties.add(Faculty(id: doc.id, name: doc['name']));
        }
      }
      return faculties;
    });
  }

  Future<List<Announcement>> getAnnouncements(
      String universityId, String facultyId) async {
    var querySnapshot = await universities
        .doc(universityId)
        .collection('announcements')
        .orderBy('releaseDate', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => Announcement(
              id: doc.id,
              facultyId: doc['facultyId'],
              content: doc['content'],
              title: doc['title'],
              releaseDate: doc['releaseDate'],
            ))
        .toList();
  }

  Stream<List<Announcement>> getAnnouncementsStream(
      String universityId, String facultyId) {
    return universities
        .doc(universityId)
        .collection('announcements')
        .orderBy('releaseDate', descending: true)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map((doc) => Announcement(
                  id: doc.id,
                  facultyId: doc['facultyId'],
                  content: doc['content'],
                  title: doc['title'],
                  releaseDate: doc['releaseDate'],
                ))
            .toList());
  }

  Stream<List<Announcement>> getFacultyAnnouncementsStream(
      String universityId, String facultyIdd) {
    return universities
        .doc(universityId)
        .collection('announcements')
        .orderBy('releaseDate', descending: true)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map((doc) => Announcement(
                  id: doc.id,
                  facultyId: doc['facultyId'],
                  content: doc['content'],
                  title: doc['title'],
                  releaseDate: doc['releaseDate'],
                ))
            .where((announcement) => announcement.facultyId == facultyIdd)
            .toList());
  }

  Future<List<CourseAnno>> getCourseAnnouncements(String universityId,
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
          .collection('announcements')
          .orderBy('releaseDate', descending: true)
          .get();

      return snapshot.docs
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

  Stream<List<Homework>> getCourseHomeworksStream(String universityId,
      String facultyId, String departmentId, String courseId) async* {
    try {
      var snapshot = universities
          .doc(universityId)
          .collection('faculties')
          .doc(facultyId)
          .collection('departments')
          .doc(departmentId)
          .collection('courses')
          .doc(courseId)
          .collection('homeworks')
          .snapshots();

      await for (var snap in snapshot) {
        yield snap.docs
            .map((doc) => Homework(
                  id: doc.id,
                  title: doc['title'],
                  fileUrls: List<String>.from(doc['fileUrls']),
                  fileNames: List<String>.from(doc['fileNames']),
                  giventime: doc['givenTime'],
                  deadline: doc['deadline'],
                ))
            .toList();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Homework> getHomeworkDetails(String universityId, String facultyId,
      String departmentId, String courseId, String homeworkId) async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('universities')
          .doc(universityId)
          .collection('faculties')
          .doc(facultyId)
          .collection('departments')
          .doc(departmentId)
          .collection('courses')
          .doc(courseId)
          .collection('homeworks')
          .doc(homeworkId)
          .get();

      if (snapshot.exists) {
        var doc = snapshot.data();
        return Homework(
          id: snapshot.id,
          title: doc?['title'],
          fileUrls: List<String>.from(doc?['fileUrls']),
          fileNames: List<String>.from(doc?['fileNames']),
          giventime: doc?['givenTime'],
          deadline: doc?['deadline'],
        );
      } else {
        throw Exception('Belirtilen ödev bulunamadı');
      }
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<CourseAnno>> getCourseAnnouncementsStream(String universityId,
      String facultyId, String departmentId, String courseId) async* {
    try {
      var snapshots = universities
          .doc(universityId)
          .collection('faculties')
          .doc(facultyId)
          .collection('departments')
          .doc(departmentId)
          .collection('courses')
          .doc(courseId)
          .collection('announcements')
          .orderBy('releaseDate', descending: true)
          .snapshots();

      await for (var snapshot in snapshots) {
        yield snapshot.docs
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
      }
    } catch (e) {
      rethrow;
    }
  }

  Stream<String> getCourseAnnouncementDateStream(String universityId,
      String facultyId, String departmentId, String courseId) {
    return universities
        .doc(universityId)
        .collection('faculties')
        .doc(facultyId)
        .collection('departments')
        .doc(departmentId)
        .collection('courses')
        .doc(courseId)
        .collection('announcements')
        .orderBy('releaseDate', descending: true)
        .limit(1)
        .snapshots()
        .map((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        String a =
            "Son duyuru Tarihi: ${querySnapshot.docs.first['releaseDate'].substring(0, 16)}";
        return a;
      } else {
        return "Geçmiş duyuru bulunamadı";
      }
    });
  }

  Stream<List<Department>> getFacultyDepartmentsAsStream(
      String universityId, String facultyId) {
    return universities
        .doc(universityId)
        .collection('faculties')
        .doc(facultyId)
        .collection('departments')
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return Department(id: doc.id, name: doc['name']);
      }).toList();
    });
  }

  Stream<List<Course>> getCoursesAsStream(
      String universityId, String facultyId, String departmentId) {
    return universities
        .doc(universityId)
        .collection('faculties')
        .doc(facultyId)
        .collection('departments')
        .doc(departmentId)
        .collection('courses')
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return Course(
          id: doc.id,
          name: doc['name'],
          instructorId: doc['instructorId'],
          startTime: List<String>.from(doc['startTime']),
          endTime: List<String>.from(doc['endTime']),
          day: List<String>.from(doc['day']),
          studentIds: List<String>.from(doc['studentIds']),
          roomInsId: doc['roomInsId'],
          roomId: doc["roomId"],
        );
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getCalendarInfos(
      String universityId, String facultyId, String departmentId) {
    return universities
        .doc(universityId)
        .collection('faculties')
        .doc(facultyId)
        .collection('departments')
        .doc(departmentId)
        .collection('courses')
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return {
          'startTime': List<String>.from(doc['startTime']),
          'endTime': List<String>.from(doc['endTime']),
          'day': List<String>.from(doc['day']),
        };
      }).toList();
    });
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

  Future<List<Course>> getCoursesAsFuture(
      String universityId, String facultyId, String departmentId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('universities')
        .doc(universityId)
        .collection('faculties')
        .doc(facultyId)
        .collection('departments')
        .doc(departmentId)
        .collection('courses')
        .get();

    List<Course> coursesList = [];

    for (var doc in querySnapshot.docs) {
      var data = doc.data();
      coursesList.add(
        Course(
          id: doc.id,
          name: data['name'],
          instructorId: data['instructorId'],
          startTime: List<String>.from(data['startTime']),
          endTime: List<String>.from(data['endTime']),
          day: List<String>.from(data['day']),
          studentIds: List<String>.from(data['studentIds']),
          roomInsId: data['roomInsId'],
          roomId: data["roomId"],
        ),
      );
    }
    return coursesList;
  }

  Future<List<Map<String, String>>> getCoursesName(
      String universityId, String facultyId, String departmentId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('universities')
        .doc(universityId)
        .collection('faculties')
        .doc(facultyId)
        .collection('departments')
        .doc(departmentId)
        .collection('courses')
        .get();

    List<Map<String, String>> courseNamesAndIdsList = [];

    for (var doc in querySnapshot.docs) {
      var data = doc.data();
      courseNamesAndIdsList.add({'id': doc.id, 'name': data['name']});
    }
    return courseNamesAndIdsList;
  }

  Future<void> updateCourseSchedule(
      int check,
      int index,
      String universityId,
      String facultyId,
      String departmentId,
      String courseId,
      String newStartTime,
      String newEndTime,
      int newDay) async {
    final courseRef = FirebaseFirestore.instance
        .collection('universities')
        .doc(universityId)
        .collection('faculties')
        .doc(facultyId)
        .collection('departments')
        .doc(departmentId)
        .collection('courses')
        .doc(courseId);

    final courseSnapshot = await courseRef.get();

    if (courseSnapshot.exists) {
      final currentData = courseSnapshot.data();

      List<String> updatedStartTimes = [];
      List<String> updatedEndTimes = [];
      List<String> updatedDays = [];

      if (check == 1) {
        updatedStartTimes = List.from(currentData?['startTime'])
          ..add(newStartTime);
        updatedEndTimes = List.from(currentData?['endTime'])..add(newEndTime);
        updatedDays = List.from(currentData?['day'])..add(newDay.toString());
      } else if (check == 0) {
        updatedStartTimes = List.from(currentData?['startTime']);
        updatedEndTimes = List.from(currentData?['endTime']);
        updatedDays = List.from(currentData?['day']);

        updatedStartTimes.removeAt(index);
        updatedEndTimes.removeAt(index);
        updatedDays.removeAt(index);
      }

      // Güncellenmiş verilerle dersi güncelleyin
      await courseRef.update({
        'startTime': updatedStartTimes,
        'endTime': updatedEndTimes,
        'day': updatedDays,
      });
    } else {}
  }

  Stream<List<Instructor>> getDepartmentInstructorsAsStream(
      String universityId, String facultyId, String departmentId) {
    return universities
        .doc(universityId)
        .collection('instructors')
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs
          .map((doc) => Instructor(
                id: doc.id,
                instructorID: doc['instructorID'],
                firstName: doc['firstName'],
                lastName: doc['lastName'],
                branch: doc['branch'],
                title: doc['title'],
                email: doc['email'],
                facultyId: doc['facultyId'],
                departmentId: doc['departmentId'],
                courseIds: List<String>.from(doc['courseIds']),
              ))
          .where((instructor) => instructor.facultyId == facultyId)
          .toList();
    });
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

  Stream<List<Instructor>?> getInstructorsStream(
      String universityId, String searchTerm) {
    return FirebaseFirestore.instance
        .collection('universities')
        .doc(universityId)
        .collection('instructors')
        .snapshots()
        .map((snapshot) {
      List<Instructor> instructors = [];

      for (var instructorDoc in snapshot.docs) {
        String no = instructorDoc['instructorID'];

        if (searchTerm.isNotEmpty && no.contains(searchTerm)) {
          instructors.add(Instructor(
            id: instructorDoc.id,
            instructorID: instructorDoc['instructorID'],
            departmentId: instructorDoc['departmentId'],
            facultyId: instructorDoc['facultyId'],
            firstName: instructorDoc['firstName'],
            lastName: instructorDoc['lastName'],
            branch: instructorDoc['branch'],
            title: instructorDoc['title'],
            email: instructorDoc['email'],
            courseIds: List.from(instructorDoc['courseIds']),
          ));
        } else if (searchTerm.isEmpty) {
          instructors.add(Instructor(
            id: instructorDoc.id,
            instructorID: instructorDoc['instructorID'],
            departmentId: instructorDoc['departmentId'],
            facultyId: instructorDoc['facultyId'],
            firstName: instructorDoc['firstName'],
            lastName: instructorDoc['lastName'],
            branch: instructorDoc['branch'],
            title: instructorDoc['title'],
            email: instructorDoc['email'],
            courseIds: List.from(instructorDoc['courseIds']),
          ));
        }
      }

      return instructors.isEmpty ? null : instructors;
    });
  }

  Future<List<Instructor>> getFacultyInstructors(
      String universityId, String facultyId) async {
    List<Instructor> instructors = [];
    QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
        .instance
        .collection('universities')
        .doc(universityId)
        .collection('instructors')
        .get();

    for (var instructorDoc in snapshot.docs) {
      if (instructorDoc['facultyId'] == facultyId) {
        instructors.add(Instructor(
          id: instructorDoc.id,
          instructorID: instructorDoc['instructorID'],
          departmentId: instructorDoc['departmentId'],
          facultyId: instructorDoc['facultyId'],
          firstName: instructorDoc['firstName'],
          lastName: instructorDoc['lastName'],
          branch: instructorDoc['branch'],
          title: instructorDoc['title'],
          email: instructorDoc['email'],
          courseIds: List.from(instructorDoc['courseIds']),
        ));
      }
    }
    return instructors;
  }

  Stream<int> getInstructorCountInFaculty(String facultyId, String uniID) {
    StreamController<int> instructorCountController = StreamController<int>();

    universities
        .doc(uniID)
        .collection('instructors')
        .snapshots()
        .listen((instructorsSnapshot) {
      int instructorCount = 0;

      for (QueryDocumentSnapshot<Map<String, dynamic>> instructorDoc
          in instructorsSnapshot.docs) {
        if (instructorDoc['facultyId'] == facultyId) {
          instructorCount++;
        }
      }

      instructorCountController.add(instructorCount);
    });

    return instructorCountController.stream;
  }

  Stream<int> getInstructorsCountInDepartment(
      String universityId, String facultyId, String departmentId) {
    return universities
        .doc(universityId)
        .collection('instructors')
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .where((doc) =>
                doc['facultyId'] == facultyId &&
                doc['departmentId'] == departmentId)
            .length);
  }

  Stream<List<Student>> getStudentsStream(
      String universityId, String searchTerm) {
    StreamController<List<Student>> controller = StreamController();

    FirebaseFirestore.instance
        .collection('universities')
        .doc(universityId)
        .collection('faculties')
        .snapshots()
        .listen((facultySnapshot) async {
      List<Student> students = [];

      for (QueryDocumentSnapshot<Map<String, dynamic>> facultyDoc
          in facultySnapshot.docs) {
        QuerySnapshot<Map<String, dynamic>> departmentsSnapshot =
            await facultyDoc.reference.collection('departments').get();

        for (QueryDocumentSnapshot<Map<String, dynamic>> departmentDoc
            in departmentsSnapshot.docs) {
          departmentDoc.reference
              .collection('students')
              .snapshots()
              .listen((studentsSnapshot) {
            students.clear();
            students.addAll(studentsSnapshot.docs.map((studentDoc) {
              return Student(
                id: studentDoc.id,
                mail: studentDoc['mail'],
                name: studentDoc['name'],
                sname: studentDoc['sname'],
                no: studentDoc['no'],
                departmentId: studentDoc['departmentId'],
                facultyId: studentDoc['facultyId'],
                assignedLectures: List.from(studentDoc['assignedLectures']),
              );
            }).toList());

            if (searchTerm.isEmpty) {
              controller.add(students);
            } else {
              List<Student> filteredStudents = students
                  .where((student) => student.no.contains(searchTerm))
                  .toList();
              controller.add(filteredStudents);
            }
          });
        }
      }
    });

    return controller.stream;
  }

  Future<List<String>> getHomeworkSenderStudents(
      String uniId,
      String facultyId,
      String departmentId,
      String courseId,
      String homeworkId,
      WidgetRef ref) async {
    List<String> senderIds = [];
    List<List<String>> files = [];

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('universities')
        .doc(uniId)
        .collection('faculties')
        .doc(facultyId)
        .collection('departments')
        .doc(departmentId)
        .collection('courses')
        .doc(courseId)
        .collection('homeworks')
        .doc(homeworkId)
        .collection('senders')
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('senderId')) {
          senderIds.add(data['senderId']);
        }
        if (data.containsKey('fileUrls')) {
          List<String> fileUrls = List<String>.from(data['fileUrls']);
          files.addAll(fileUrls.map((url) => [url]));
        }
      }
    }

    ref.read(sendersFilesProvider.notifier).state = files;
    ref.read(senderIdsProvider.notifier).state = senderIds;
    return senderIds;
  }

  Stream<int> getStudentsCountInDepartment(
      String universityId, String facultyId, String departmentId) async* {
    yield* universities
        .doc(universityId)
        .collection('faculties')
        .doc(facultyId)
        .collection('departments')
        .doc(departmentId)
        .collection('students')
        .snapshots()
        .map((querySnapshot) => querySnapshot.size);
  }

  Stream<int> getStudentsCountInFaculty(String facultyId, String uniId) async* {
    int totalStudentsCount = 0;

    await for (QuerySnapshot<Map<String, dynamic>> departmentsSnapshot
        in universities
            .doc(uniId)
            .collection('faculties')
            .doc(facultyId)
            .collection('departments')
            .snapshots()) {
      totalStudentsCount = 0;

      for (QueryDocumentSnapshot<Map<String, dynamic>> departmentDoc
          in departmentsSnapshot.docs) {
        QuerySnapshot<Map<String, dynamic>> studentsSnapshot =
            await departmentDoc.reference.collection('students').get();
        totalStudentsCount += studentsSnapshot.size;
      }

      yield totalStudentsCount;
    }
  }

  Stream<int> getDepartmentCountInFaculty(
      String facultyId, String uniID) async* {
    StreamController<int> departmentCountController = StreamController<int>();

    await universities
        .doc(uniID)
        .collection('faculties')
        .doc(facultyId)
        .collection('departments')
        .snapshots()
        .listen((departmentsSnapshot) {
      departmentCountController.add(departmentsSnapshot.docs.length);
    });

    yield* departmentCountController.stream;
  }

  Stream<String?> getFacultyNameStream(String uniId, String facultyId) {
    return FirebaseFirestore.instance
        .collection('universities')
        .doc(uniId)
        .collection('faculties')
        .doc(facultyId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        if (doc.data()!.containsKey('name')) {
          return doc.get('name') as String;
        } else {
          return null;
        }
      } else {
        return null;
      }
    });
  }

  Stream<String?> getDepartmentNameStream(
      String uniId, String facultyId, String departmentId) {
    return FirebaseFirestore.instance
        .collection('universities')
        .doc(uniId)
        .collection('faculties')
        .doc(facultyId)
        .collection('departments')
        .doc(departmentId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        if (doc.data()!.containsKey('name')) {
          return doc.get('name') as String;
        } else {
          return null;
        }
      } else {
        return null;
      }
    });
  }

  Future<String?> getFacultyName(String uniId, String facultyId) async {
    var docSnapshot = await FirebaseFirestore.instance
        .collection('universities')
        .doc(uniId)
        .collection('faculties')
        .doc(facultyId)
        .get();

    if (docSnapshot.exists) {
      if (docSnapshot.data()!.containsKey('name')) {
        return docSnapshot.get('name') as String?;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Stream<Course?> getCourseInfoStream(String uniId, String facultyId,
      String departmentId, String courseId) async* {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    yield* firestore
        .collection('universities')
        .doc(uniId)
        .collection('faculties')
        .doc(facultyId)
        .collection('departments')
        .doc(departmentId)
        .collection('courses')
        .doc(courseId)
        .snapshots()
        .asyncMap(
      (snapshot) async {
        if (snapshot.exists) {
          Map<String, dynamic> data = snapshot.data()!;
          return Course(
            id: snapshot.id,
            name: data['name'],
            instructorId: data['instructorId'],
            startTime: List<String>.from(data['startTime']),
            endTime: List<String>.from(data['endTime']),
            day: List<String>.from(data['day']),
            studentIds: List<String>.from(data['studentIds']),
            roomInsId: data['roomInsId'],
            roomId: data["roomId"],
          );
        } else {
          return null;
        }
      },
    );
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

  Future<void> updateAssignedLectures(String uniId, String facultyId,
      String departmentId, String studentId, String courseId) async {
    try {
      DocumentReference studentRef = universities
          .doc(uniId)
          .collection('faculties')
          .doc(facultyId)
          .collection('departments')
          .doc(departmentId)
          .collection('students')
          .doc(studentId);

      await studentRef.update({
        'assignedLectures': FieldValue.arrayUnion([courseId]),
      });

      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> updateCourseStudents(String uniId, String facultyId,
      String departmentId, String studentId, String courseId) async {
    try {
      DocumentReference studentRef = universities
          .doc(uniId)
          .collection('faculties')
          .doc(facultyId)
          .collection('departments')
          .doc(departmentId)
          .collection('courses')
          .doc(courseId);

      await studentRef.update({
        'studentIds': FieldValue.arrayUnion([studentId]),
      });

      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> updateGivenCourses(
      String uniId, String instructorId, String courseId) async {
    try {
      DocumentReference instructorRef =
          universities.doc(uniId).collection('instructors').doc(instructorId);

      await instructorRef.update({
        'courseIds': FieldValue.arrayUnion([courseId]),
      });

      // ignore: empty_catches
    } catch (e) {}
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

  Future<int> getAssignedLecturesCount(String uniId, String facultyId,
      String departmentId, String studentId) async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      var doc = await firestore
          .collection('universities')
          .doc(uniId)
          .collection('faculties')
          .doc(facultyId)
          .collection('departments')
          .doc(departmentId)
          .collection('students')
          .doc(studentId)
          .get();

      List<String> assignedLectures =
          List<String>.from(doc['assignedLectures']);

      return assignedLectures.length;
    } catch (e) {
      return 0;
    }
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
          startTime: List<String>.from(data?['startTime'] ?? []),
          endTime: List<String>.from(data?['endTime'] ?? []),
          day: List<String>.from(data?['day'] ?? []),
          studentIds: List<String>.from(data?['studentIds'] ?? []),
          roomInsId: data?['roomInsId'],
          roomId: data?["roomId"],
        );
      } else {
        return Course(
          id: '',
          name: '',
          instructorId: '',
          startTime: [],
          endTime: [],
          day: [],
          studentIds: [],
          roomInsId: '',
          roomId: '',
        );
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<Student> getStudentDetails(String uniId, String facultyId,
      String departmentId, String studentId) async {
    try {
      final studentReference = universities
          .doc(uniId)
          .collection('faculties')
          .doc(facultyId)
          .collection('departments')
          .doc(departmentId)
          .collection('students')
          .doc(studentId);

      final snapshot = await studentReference.get();

      if (snapshot.exists) {
        final data = snapshot.data();
        return Student(
            id: snapshot.id,
            mail: data?['mail'],
            name: data?['name'],
            sname: data?['sname'],
            no: data?['no'],
            departmentId: departmentId,
            facultyId: facultyId,
            assignedLectures:
                List<String>.from(data?['assignedLectures'] ?? []));
      } else {
        return Student(
            id: '',
            mail: '',
            name: '',
            sname: '',
            no: '',
            departmentId: '',
            facultyId: '',
            assignedLectures: []);
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getStudentBasicInfo(String uniId,
      String facultyId, String departmentId, String studentId) async {
    try {
      final studentReference = universities
          .doc(uniId)
          .collection('faculties')
          .doc(facultyId)
          .collection('departments')
          .doc(departmentId)
          .collection('students')
          .doc(studentId);

      final snapshot = await studentReference.get();

      if (snapshot.exists) {
        final data = snapshot.data();
        return {
          'name': data?['name'],
          'sname': data?['sname'],
          'no': data?['no'],
          'mail': data?['mail'],
        };
      } else {
        return {
          'name': '',
          'sname': '',
          'no': '',
          'mail': '',
        };
      }
    } catch (error) {
      rethrow;
    }
  }

  Future<List<String>> getCourseIds(String uniId, String instructorId) async {
    List<String> courseIds = [];
    try {
      CollectionReference instructorsRef =
          universities.doc(uniId).collection('instructors');

      DocumentSnapshot instructorDoc =
          await instructorsRef.doc(instructorId).get();

      List<dynamic>? courses = instructorDoc['courseIds'];

      if (courses != null && courses.isNotEmpty) {
        courseIds.addAll(courses.map((course) => course.toString()));
      }
      // ignore: empty_catches
    } catch (e) {}

    return courseIds;
  }

  Future<List<String>> getAllCourseStudents(String uniId, String facultyId,
      String departmentId, String courseId, String searchTerm) async {
    List<String> studentIds = [];

    try {
      DocumentSnapshot courseSnapshot = await universities
          .doc(uniId)
          .collection('faculties')
          .doc(facultyId)
          .collection('departments')
          .doc(departmentId)
          .collection('courses')
          .doc(courseId)
          .get();

      List<dynamic>? students = courseSnapshot['studentIds'];

      if (students != null && students.isNotEmpty) {
        studentIds.addAll(students.map((course) => course.toString()));

        QuerySnapshot studentSnapshot = await universities
            .doc(uniId)
            .collection('faculties')
            .doc(facultyId)
            .collection('departments')
            .doc(departmentId)
            .collection('students')
            .get();

        if (searchTerm.isNotEmpty) {
          List<String> matchingStudentIds = [];
          for (var studentDoc in studentSnapshot.docs) {
            String studentName = studentDoc['no'].toString();
            String studentId = studentDoc.id;
            if (studentName.contains(searchTerm)) {
              matchingStudentIds.add(studentId);
            }
          }
          studentIds.retainWhere(
              (studentId) => matchingStudentIds.contains(studentId));
        }
      }
    } catch (e) {}

    return studentIds;
  }

  Future<Course> getCourseById(String uniId, String facultyId,
      String departmentId, String courseId) async {
    try {
      DocumentSnapshot courseSnapshot = await FirebaseFirestore.instance
          .collection('universities')
          .doc(uniId)
          .collection('faculties')
          .doc(facultyId)
          .collection('departments')
          .doc(departmentId)
          .collection('courses')
          .doc(courseId)
          .get();

      if (courseSnapshot.exists) {
        Map<String, dynamic> courseData =
            courseSnapshot.data() as Map<String, dynamic>;
        return Course(
          id: courseSnapshot.id,
          name: courseData['name'] ?? '',
          instructorId: courseData['instructorId'] ?? '',
          startTime: List<String>.from(courseData['startTime'] ?? []),
          endTime: List<String>.from(courseData['endTime'] ?? []),
          day: List<String>.from(courseData['day'] ?? []),
          studentIds: List<String>.from(courseData['studentIds'] ?? []),
          roomInsId: courseData['roomInsId'] ?? '',
          roomId: courseData["roomId"] ?? '',
        );
      } else {
        throw Exception('Course not found');
      }
    } catch (e) {
      throw Exception('Error retrieving course: $e');
    }
  }

  Future<void> downloadFile(String url) async {
    try {
      final anchor = AnchorElement(href: url);
      anchor.setAttribute('download', "");
      anchor.click();
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<String?> getRoomId(String uniId, String facultyId, String departmentId,
      String courseId) async {
    final courseRef = FirebaseFirestore.instance
        .collection('universities')
        .doc(uniId)
        .collection('faculties')
        .doc(facultyId)
        .collection('departments')
        .doc(departmentId)
        .collection('courses')
        .doc(courseId);

    try {
      final docSnapshot = await courseRef.get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null && data.containsKey('roomId')) {
          return data['roomId'] as String?;
        }
      }
    } catch (error) {
      print("Failed to get roomId: $error");
    }
    return null;
  }

  Future<String?> getRoomInsId(String uniId, String facultyId,
      String departmentId, String courseId) async {
    final courseRef = FirebaseFirestore.instance
        .collection('universities')
        .doc(uniId)
        .collection('faculties')
        .doc(facultyId)
        .collection('departments')
        .doc(departmentId)
        .collection('courses')
        .doc(courseId);

    try {
      final docSnapshot = await courseRef.get();
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null && data.containsKey('roomInsId')) {
          return data['roomInsId'] as String?;
        }
      }
    } catch (error) {
      print("Failed to get roomId: $error");
    }
    return null;
  }

  Future<String> getInstructorName(
      String universityId, String instructorId) async {
    try {
      DocumentSnapshot instructorDoc = await FirebaseFirestore.instance
          .collection('universities')
          .doc(universityId)
          .collection('instructors')
          .doc(instructorId)
          .get();

      if (instructorDoc.exists) {
        String title = instructorDoc['title'];
        String firstName = instructorDoc['firstName'];
        String lastName = instructorDoc['lastName'];

        return '$title $firstName $lastName';
      } else {
        throw Exception('Instructor not found');
      }
    } catch (e) {
      throw Exception('Failed to fetch instructor: $e');
    }
  }

  Future<String> getStudentName(String uniId, String facultyId,
      String departmentId, String studentId) async {
    try {
      DocumentSnapshot studentDoc = await FirebaseFirestore.instance
          .collection('universities')
          .doc(uniId)
          .collection('faculties')
          .doc(facultyId)
          .collection('departments')
          .doc(departmentId)
          .collection('students')
          .doc(studentId)
          .get();

      if (studentDoc.exists) {
        String firstName = studentDoc['name'];
        String lastName = studentDoc['sname'];

        return '$firstName $lastName';
      } else {
        throw Exception('Student not found');
      }
    } catch (e) {
      throw Exception('Failed to fetch Student: $e');
    }
  }

  Future<List<String>> getStudentIds(String uniId, String facultyId,
      String departmentId, String courseId) async {
    try {
      DocumentSnapshot courseSnapshot = await FirebaseFirestore.instance
          .collection('universities')
          .doc(uniId)
          .collection('faculties')
          .doc(facultyId)
          .collection('departments')
          .doc(departmentId)
          .collection('courses')
          .doc(courseId)
          .get();

      if (courseSnapshot.exists) {
        return List.from(courseSnapshot['studentIds']);
      } else {
        throw Exception('Student not found');
      }
    } catch (e) {
      throw Exception('');
    }
  }

  // Schema

  Future<void> addExamSchema(String uniId, String facultyId,
      String departmentId, String title, List<dynamic> questionList) async {
    DocumentReference<Object?> schemaRef = universities
        .doc(uniId)
        .collection('faculties')
        .doc(facultyId)
        .collection('departments')
        .doc(departmentId);

    CollectionReference<Map<String, dynamic>> schemas =
        schemaRef.collection('schemas');
    DocumentReference<Map<String, dynamic>> uniqueSchemaRef =
        await schemas.add({
      'title': title,
    });

    CollectionReference<Map<String, dynamic>> questionCollection =
        uniqueSchemaRef.collection('questions');

    for (var question in questionList) {
      if (question.runtimeType.toString() == "TrueFalseQuestion") {
        await questionCollection.add({
          'type': "TrueFalseQuestion",
          'text': question.text,
          'answer': question.answer,
          'correctAnswer': question.correctAnswer,
          'point': question.point,
          'key': question.key.toString(),
          'at': false
        });
      }
      if (question.runtimeType.toString() == "ClassicQuestion") {
        await questionCollection.add({
          'type': "ClassicQuestion",
          'text': question.text,
          'answer': question.answer,
          'answerUrl': question.answerUrl,
          'photoUrl': question.photoUrl,
          'point': question.point,
          'key': question.key.toString(),
          'at': false
        });
      }
      if (question.runtimeType.toString() == "GapFillingQuestion") {
        await questionCollection.add({
          'type': "GapFillingQuestion",
          'firstText': question.firstText,
          'lastText': question.lastText,
          'answer': question.answer,
          'correctAnswer': question.correctAnswer,
          'point': question.point,
          'key': question.key.toString(),
          'at': false
        });
      }
      if (question.runtimeType.toString() == "TextQuestion") {
        await questionCollection.add({
          'type': "TextQuestion",
          'text': question.text,
          'answer': question.answer,
          'photoUrl': question.photoUrl,
          'point': question.point,
          'key': question.key.toString(),
          'at': false
        });
      }
      if (question.runtimeType.toString() == "TestQuestion") {
        await questionCollection.add({
          'type': "TestQuestion",
          'text': question.text,
          'answer': question.answer,
          'options': List.from(question.options),
          'photoUrl': question.photoUrl,
          'correctAnswer': question.correctAnswer,
          'point': question.point,
          'key': question.key.toString(),
          'at': false
        });
      }
    }
  }

  Future<void> addExam(
      String uniId,
      String facultyId,
      String departmentId,
      String courseId,
      String schemaId,
      String type,
      TimeOfDay beginTime,
      DateTime beginDate,
      bool shuffle,
      bool qPass,
      String examTime,
      bool at) async {
    DocumentReference<Object?> courseRef = universities
        .doc(uniId)
        .collection('faculties')
        .doc(facultyId)
        .collection('departments')
        .doc(departmentId)
        .collection('courses')
        .doc(courseId);

    CollectionReference<Map<String, dynamic>> exams =
        courseRef.collection('exams');

    DocumentReference<Map<String, dynamic>> uniqueExamRef = await exams.add({
      'type': type,
      'beginTime': beginTime.toString(),
      'beginDate': beginDate.toString(),
      'shuffle': shuffle,
      'qPass': qPass,
      'examTime': int.parse(examTime),
      'courseId': courseId,
    });

    QuerySnapshot<Map<String, dynamic>> snapshot = await universities
        .doc(uniId)
        .collection('faculties')
        .doc(facultyId)
        .collection('departments')
        .doc(departmentId)
        .collection('schemas')
        .doc(schemaId)
        .collection('questions')
        .get();

    CollectionReference<Map<String, dynamic>> questionCollection =
        uniqueExamRef.collection('questions');

    for (var doc in snapshot.docs) {
      await questionCollection.add(doc.data());
    }
  }

  Future<void> addExamtoStudent(
      String uniId,
      String facultyId,
      String departmentId,
      String studentId,
      String courseId,
      String schemaId,
      String type,
      TimeOfDay beginTime,
      DateTime beginDate,
      bool shuffle,
      bool qPass,
      String examTime,
      bool at) async {
    DocumentReference<Object?> studentRef = universities
        .doc(uniId)
        .collection('faculties')
        .doc(facultyId)
        .collection('departments')
        .doc(departmentId)
        .collection('students')
        .doc(studentId);

    CollectionReference<Map<String, dynamic>> exams =
        studentRef.collection('exams');

    DocumentReference<Map<String, dynamic>> uniqueExamRef = await exams.add({
      'type': type,
      'beginTime': beginTime.toString(),
      'beginDate': beginDate.toString(),
      'shuffle': shuffle,
      'qPass': qPass,
      'examTime': int.parse(examTime),
      'courseId': courseId,
    });

    QuerySnapshot<Map<String, dynamic>> snapshot = await universities
        .doc(uniId)
        .collection('faculties')
        .doc(facultyId)
        .collection('departments')
        .doc(departmentId)
        .collection('schemas')
        .doc(schemaId)
        .collection('questions')
        .get();

    CollectionReference<Map<String, dynamic>> questionCollection =
        uniqueExamRef.collection('questions');

    for (var doc in snapshot.docs) {
      await questionCollection.add(doc.data());
    }
  }

  Future<List<Map<String, dynamic>>> getExamQuestions(
    String uniId,
    String facultyId,
    String departmentId,
    String studentId,
    String courseId,
    int examType,
  ) async {
    CollectionReference examRef = universities
        .doc(uniId)
        .collection('faculties')
        .doc(facultyId)
        .collection('departments')
        .doc(departmentId)
        .collection('students')
        .doc(studentId)
        .collection('exams');

    // 'examType' parametresine göre sorguyu ayarla
    String? typeValue =
        examType == 1 ? 'vize' : (examType == 2 ? 'final' : null);
    if (typeValue == null) {
      throw Exception('Invalid exam type specified');
    }

    // İlgili 'type' değerine sahip ilk sınav dokümanını al
    DocumentSnapshot examSnapshot = await examRef
        .where('courseId', isEqualTo: courseId)
        .where('type', isEqualTo: typeValue)
        .limit(1)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs[0];
      } else {
        throw Exception('No exam document found for the specified exam type');
      }
    });

    if (examSnapshot.exists) {
      CollectionReference questionsRef =
          examSnapshot.reference.collection('questions');

      List<Map<String, dynamic>> questionList = [];
      QuerySnapshot questionsSnapshot = await questionsRef.get();
      for (DocumentSnapshot questionSnapshot in questionsSnapshot.docs) {
        Map<String, dynamic> questionData =
            questionSnapshot.data() as Map<String, dynamic>;
        questionList.add(questionData);
      }

      if (questionList.isEmpty) {
        throw Exception('No questions found in the exam');
      }

      return questionList;
    } else {
      throw Exception('No exam document found for the specified exam type');
    }
  }

  Future<Map<String, dynamic>> getExamFeatures(String uniId, String facultyId,
      String departmentId, String studentId) async {
    CollectionReference examRef = universities
        .doc(uniId)
        .collection('faculties')
        .doc(facultyId)
        .collection('departments')
        .doc(departmentId)
        .collection('students')
        .doc(studentId)
        .collection('exams');

    // Get the first exam document where type is 'vize' (midterm)
    DocumentSnapshot examSnapshot = await examRef
        .where('type', isEqualTo: 'vize')
        .limit(1)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs[0];
      } else {
        throw Exception('No exam document found for midterm');
      }
    });

    // Check if exam document exists
    if (examSnapshot.exists) {
      // Get exam data and convert to Map
      return examSnapshot.data() as Map<String, dynamic>;
    } else {
      // Throw an exception if no exam found
      throw Exception('No exam document found for midterm');
    }
  }

  Future<bool> isExamAvailable(String uniId, String facultyId,
      String departmentId, String studentId, String courseId) async {
    // Firebase'den sınav bilgilerini çek
    QuerySnapshot examQuery = await FirebaseFirestore.instance
        .collection('universities')
        .doc(uniId)
        .collection('faculties')
        .doc(facultyId)
        .collection('departments')
        .doc(departmentId)
        .collection('students')
        .doc(studentId)
        .collection('exams')
        .where('courseId', isEqualTo: courseId)
        .get();

    if (examQuery.docs.isEmpty) {
      return false; // Sınav bilgileri bulunamadı
    }

    DocumentSnapshot examDoc = examQuery.docs.first;
    Map<String, dynamic> examData = examDoc.data() as Map<String, dynamic>;

    String beginDate = examData['beginDate'];
    String beginTime = examData['beginTime'];
    int examTime = examData['examTime'];

    DateTime examStartDateTime = DateTime.parse(beginDate);
    TimeOfDay examStartTime = TimeOfDay(
      hour: int.parse(beginTime.split('(')[1].split(':')[0]),
      minute: int.parse(beginTime.split('(')[1].split(':')[1].split(')')[0]),
    );

    DateTime examStartDateTimeWithTime = DateTime(
      examStartDateTime.year,
      examStartDateTime.month,
      examStartDateTime.day,
      examStartTime.hour,
      examStartTime.minute,
    );

    DateTime examEndDateTime =
        examStartDateTimeWithTime.add(Duration(minutes: examTime));
    DateTime currentDateTime = DateTime.now();

    return currentDateTime.isAfter(examStartDateTimeWithTime) &&
        currentDateTime.isBefore(examEndDateTime);
  }

  Future<List<Map<String, String>>> getExamSchemasFuture(
      String uniId, String facultyId, String departmentId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('universities')
        .doc(uniId)
        .collection('faculties')
        .doc(facultyId)
        .collection('departments')
        .doc(departmentId)
        .collection('schemas')
        .get();

    List<Map<String, String>> schemasList = [];
    for (var doc in querySnapshot.docs) {
      var data = doc.data() as Map<String, dynamic>;
      schemasList.add({'id': doc.id, 'title': data['title']});
    }

    return schemasList;
  }

  Future<void> updateExam(String uniId, String facultyId, String departmentId,
      String studentId, String keyy, String newAnswer, bool ch) async {
    CollectionReference examRef = universities
        .doc(uniId)
        .collection('faculties')
        .doc(facultyId)
        .collection('departments')
        .doc(departmentId)
        .collection('students')
        .doc(studentId)
        .collection('exams');

    DocumentSnapshot examSnapshot = await examRef
        .where('type', isEqualTo: 'vize')
        .limit(1)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs[0];
      } else {
        throw Exception('No exam document found for midterm');
      }
    });

    if (examSnapshot.exists) {
      CollectionReference questionsRef =
          examSnapshot.reference.collection('questions');

      QuerySnapshot questionsSnapshot =
          await questionsRef.where('key', isEqualTo: keyy).get();

      if (questionsSnapshot.docs.isNotEmpty) {
        DocumentSnapshot questionToUpdate = questionsSnapshot.docs[0];
        questionToUpdate.reference.update({"answer": newAnswer, "at": ch});

        return;
      } else {
        throw Exception('No question found with the provided key');
      }
    } else {
      throw Exception('No exam document found for midterm');
    }
  }

  Stream<List<Map<String, String>>> getExamSchemas(
      String uniId, String facultyId, String departmentId) {
    return FirebaseFirestore.instance
        .collection('universities')
        .doc(uniId)
        .collection('faculties')
        .doc(facultyId)
        .collection('departments')
        .doc(departmentId)
        .collection('schemas')
        .snapshots()
        .map((querySnapshot) {
      List<Map<String, String>> schemasList = [];
      for (var doc in querySnapshot.docs) {
        var data = doc.data();
        schemasList.add({'id': doc.id, 'title': data['title']});
      }
      return schemasList;
    });
  }

  Future<Map<String, dynamic>> getSchemaDetails(String uniId, String facultyId,
      String departmentId, String schemaId) async {
    // Access the questions collection inside the specified schema
    QuerySnapshot questionsSnapshot = await FirebaseFirestore.instance
        .collection('universities')
        .doc(uniId)
        .collection('faculties')
        .doc(facultyId)
        .collection('departments')
        .doc(departmentId)
        .collection('schemas')
        .doc(schemaId)
        .collection('questions')
        .get();

    Map<String, dynamic> questionTypeCounts = {
      "ClassicQuestion": {'count': 0, 'totalPoints': 0},
      "TestQuestion": {'count': 0, 'totalPoints': 0},
      "GapFillingQuestion": {'count': 0, 'totalPoints': 0},
      "TrueFalseQuestion": {'count': 0, 'totalPoints': 0},
      "TextQuestion": {'count': 0, 'totalPoints': 0},
    };

    // Iterate over each question document
    for (var questionDoc in questionsSnapshot.docs) {
      var questionData = questionDoc.data() as Map<String, dynamic>;

      // Check if questionData is not null
      String? type = questionData['type'] as String?;
      String? pointStr = questionData['point'] as String?;

      // Check if type and point are not null
      if (type != null && pointStr != null) {
        int point = int.tryParse(pointStr) ??
            0; // Convert point from String to int, default to 0 if parsing fails

        // Update count and totalPoints for this type
        questionTypeCounts.update(type, (value) {
          value['count'] = (value['count'] ?? 0) + 1;
          value['totalPoints'] = (value['totalPoints'] ?? 0) + point;
          return value;
        }, ifAbsent: () => {'count': 1, 'totalPoints': point});
      }
    }

    return questionTypeCounts;
  }

  Future<Map<String, String>> getExamSchemaTotalQandP(String uniId,
      String facultyId, String departmentId, String schemaId) async {
    final schemaRef = await universities
        .doc(uniId)
        .collection('faculties')
        .doc(facultyId)
        .collection('departments')
        .doc(departmentId)
        .collection("schemas")
        .doc(schemaId)
        .collection("questions")
        .get();

    Map<String, String> schemaInfo = {};
    var qSize = 0;
    var total = 0;

    for (var doc in schemaRef.docs) {
      total += int.parse(doc['point']);
      qSize++;
    }

    schemaInfo = {'qSize': qSize.toString(), 'total': total.toString()};

    return schemaInfo;
  }

  Future<void> deleteSchemaAndCollection(String universityId, String facultyId,
      String departmentId, String schemaId) async {
    try {
      final schemaRef = universities
          .doc(universityId)
          .collection('faculties')
          .doc(facultyId)
          .collection('departments')
          .doc(departmentId)
          .collection("schemas")
          .doc(schemaId);

      final subcollectionRef = schemaRef.collection('questions');

      await _deleteCollection(subcollectionRef);

      await schemaRef.delete();
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> _deleteCollection(CollectionReference collectionRef) async {
    const batchSize = 10;
    QuerySnapshot snapshot = await collectionRef.limit(batchSize).get();
    while (snapshot.docs.isNotEmpty) {
      for (DocumentSnapshot doc in snapshot.docs) {
        await doc.reference.delete();
      }
      snapshot = await collectionRef.limit(batchSize).get();
    }
  }
}
