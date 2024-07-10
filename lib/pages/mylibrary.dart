import 'package:atbu_pq/controllers/library_controller.dart';
import 'package:atbu_pq/pages/QuestionTabs/tabs.dart';
import 'package:atbu_pq/styles/colors.dart';
import 'package:atbu_pq/styles/fonts.dart';
import 'package:atbu_pq/utils/routers.dart';
import 'package:atbu_pq/utils/show_message.dart';
import 'package:atbu_pq/widgets/card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyLibrary extends StatefulWidget {
  const MyLibrary({Key? key}) : super(key: key);

  @override
  State<MyLibrary> createState() => _MyLibraryState();
}

class _MyLibraryState extends State<MyLibrary> {
  final LibraryController _libraryController = LibraryController();
  List<Map<String, dynamic>>? _libraryCourses;

  @override
  void initState() {
    super.initState();
    fetchLibraryCourses();
  }

  Future<void> fetchLibraryCourses() async {
    try {
      List<Map<String, dynamic>> courses =
          await _libraryController.getUserLibrary();
      setState(() {
        _libraryCourses = courses;
      });
    } catch (error) {
      errorMessage(context, 'Opps', '$error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: whiteColor,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 25.h,
              ),
              Text(
                'My Library',
                style: kbodylargeboldText,
              ),
              SizedBox(
                height: 8.h,
              ),
              Expanded(
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(FirebaseAuth.instance.currentUser!.uid)
                        .collection('library')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text('Something went wrong');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Text('No data available');
                      }

                      return ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: (context, index) {
                          final course = snapshot.data!.docs[index];
                          // print(course);
                          return StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('Faculties')
                                  .doc(course['FacultyName'])
                                  .collection('Departments')
                                  .doc(course['DepartmentName'])
                                  .collection('Courses')
                                  .doc(course['CourseName'])
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Container();
                                }

                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Container();
                                }

                                if (!snapshot.hasData ||
                                    snapshot.data == null) {
                                  return Container();
                                }

                                var courseData = snapshot.data!.data();

                                return Padding(
                                  padding: EdgeInsets.only(bottom: 16.h),
                                  child: LibraryCard(
                                    text: course['CourseName'],
                                    OnTap: () {
                                      PageNavigator(context: context).nextPage(
                                        page: Tabs(
                                          coursedata: courseData,
                                        ),
                                      );
                                    },
                                    delete: () {
                                      _libraryController.deleteFromLibrary(
                                          context, course['CourseName']);
                                    },
                                  ),
                                );
                              });
                        },
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
