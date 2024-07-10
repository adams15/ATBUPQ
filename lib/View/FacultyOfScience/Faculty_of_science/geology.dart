import 'package:atbu_pq/controllers/library_controller.dart';
import 'package:atbu_pq/pages/QuestionTabs/tabs.dart';
import 'package:atbu_pq/styles/colors.dart';
import 'package:atbu_pq/styles/fonts.dart';
import 'package:atbu_pq/utils/routers.dart';
import 'package:atbu_pq/utils/show_message.dart';
import 'package:atbu_pq/widgets/card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GeologyDepartment extends StatefulWidget {
  GeologyDepartment({
    super.key,
  });

  @override
  State<GeologyDepartment> createState() => _GeologyDepartmentState();
}

class _GeologyDepartmentState extends State<GeologyDepartment> {
  final LibraryController _libraryController = LibraryController();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context);

    return SafeArea(
        child: Scaffold(
      backgroundColor: whiteColor,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 16.0.w,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 25.h,
            ),
            GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Image.asset('images/backarrow.png')),
            SizedBox(
              height: 26.h,
            ),
            Text(
              'Department of Geology',
              style: kbodylargeboldText,
            ),
            SizedBox(
              height: 8.h,
            ),
            Text(
              'Gabata welcome to department of geology '
              'past questions and solutions',
              style: kbodysmallgreycolor,
            ),
            SizedBox(
              height: 26.h,
            ),
            Text(
              'All Courses',
              style: kbodylargeboldText,
            ),
            SizedBox(
              height: 26.h,
            ),
            // StreamBuilder for fetching courses
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Faculties')
                  .where('FacultyName', isEqualTo: 'Science')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text("Loading");
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Text('No data available');
                }

                String facultyId = snapshot.data!.docs.first.id;

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Faculties')
                      .doc(facultyId)
                      .collection('Departments')
                      .where('DepartmentName', isEqualTo: 'Geology')
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> departmentSnapshot) {
                    if (departmentSnapshot.hasError) {
                      return Text('Something went wrong');
                    }

                    if (departmentSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Text("Loading");
                    }

                    if (!departmentSnapshot.hasData ||
                        departmentSnapshot.data!.docs.isEmpty) {
                      return Text('No data available');
                    }

                    String departmentId =
                        departmentSnapshot.data!.docs.first.id;

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('Faculties')
                          .doc(facultyId)
                          .collection('Departments')
                          .doc(departmentId)
                          .collection('Courses')
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> courseSnapshot) {
                        if (courseSnapshot.hasError) {
                          return Text('Something went wrong');
                        }

                        if (courseSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text("Loading");
                        }

                        if (!courseSnapshot.hasData ||
                            courseSnapshot.data!.docs.isEmpty) {
                          return Text('No courses available');
                        }

                        return Expanded(
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: courseSnapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              DocumentSnapshot document =
                                  courseSnapshot.data!.docs[index];
                              Map<String, dynamic> courseData =
                                  document.data()! as Map<String, dynamic>;

                              User user = FirebaseAuth.instance.currentUser!;
                              return StreamBuilder(
                                  stream: FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(user.uid)
                                      .collection('library')
                                      .doc(courseData['CourseName'])
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        bottom: 16.h,
                                      ),
                                      child: CourseCard(
                                        exist: (snapshot.data != null &&
                                            snapshot.data!.exists),
                                        AddToLibrary: () async {
                                          if (snapshot.data != null &&
                                              snapshot.data!.exists) {
                                            return errorMessage(context, 'Oops',
                                                ' Course already exist in library');
                                          } else {
                                            try {
                                              // Retrieve the course name from the course data
                                              String courseName =
                                                  courseData['CourseName'];

                                              // Call the addToLibrary function to add the course to the library
                                              await _libraryController
                                                  .addToLibrary(
                                                      context,
                                                      facultyId,
                                                      departmentId,
                                                      courseName);
                                            } catch (error) {
                                              print(
                                                  'Error adding course to library: $error');
                                              // Handle error here
                                            }
                                          }
                                        },
                                        OnTap: () {
                                          PageNavigator(context: context)
                                              .nextPage(
                                                  page: Tabs(
                                            coursedata: courseData,
                                          ));
                                        },
                                        text: courseData['CourseName'] ?? '',
                                      ),
                                    );
                                  });
                            },
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    ));
  }
}


