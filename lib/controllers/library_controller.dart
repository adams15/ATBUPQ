import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:atbu_pq/utils/show_message.dart';

class LibraryController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addToLibrary(BuildContext context, String facultyName,
      String departmentName, String courseName) async {
    try {
      // Get the current user
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Retrieve the selected course details from Firestore
      DocumentSnapshot courseSnapshot = await _firestore
          .collection('Faculties')
          .doc(facultyName)
          .collection('Departments')
          .doc(departmentName)
          .collection('Courses')
          .doc(courseName)
          .get();

      // Add the course and its details to the user's library
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('library')
          .doc(courseName)
          .set({
        'FacultyName': facultyName,
        'DepartmentName': departmentName,
        'CourseName': courseName,
      });

      ////

      // Show a snackbar message to indicate that the course was added to the library
      return suceesMessage(context, 'Success', ' Course added succesfully');
    } catch (error) {
      errorMessage(context, 'Opps', '$error');
      throw error;
    }
  }

  Future<void> deleteFromLibrary(BuildContext context, String courseId) async {
    User? user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('library')
        .doc(courseId)
        .delete();
    return suceesMessage(context, 'Success', ' Course deleted succesfully');
  }

  Future<List<Map<String, dynamic>>> getUserLibrary() async {
    try {
      // Get the current user
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      // Retrieve the user's library from Firestore
      QuerySnapshot librarySnapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('library')
          .get();

      // Extract the course names from the library
      List<Map<String, dynamic>> courseNames = librarySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();

      return courseNames;
    } catch (error) {
      print('Error getting user library: $error');
      throw error;
    }
  }
}
