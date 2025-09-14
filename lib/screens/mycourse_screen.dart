import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datapollex/main.dart';
import 'package:datapollex/models/scheduleslot_model.dart';
import 'package:datapollex/screens/auth_screen.dart';
import 'package:datapollex/widgets/scheduleslotCard.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';


class StudentMyCoursesScreen extends StatefulWidget {
  @override
  _StudentMyCoursesScreenState createState() => _StudentMyCoursesScreenState();
}

class _StudentMyCoursesScreenState extends State<StudentMyCoursesScreen> {
  List<ScheduleSlot> _acceptedCourses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAcceptedCourses();
  }

  Future<void> _loadAcceptedCourses() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user!;
    print('[v0] Loading courses for student ID: ${user.id}');

    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('student_bookings')
              .where('studentId', isEqualTo: user.id)
              .where('status', isEqualTo: 'accepted')
              .get(); // Removed orderBy to avoid index issues

      print('[v0] Found ${querySnapshot.docs.length} accepted courses');

      setState(() {
        _acceptedCourses =
            querySnapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              print('[v0] Course data: ${data}');

              return ScheduleSlot(
                id: doc.id,
                teacherId: data['teacherId'],
                teacherName: data['teacherName'],
                courseName: data['courseName'] ?? 'Course', // Added fallback
                language: data['language'] ?? 'Language', // Added fallback
                dateTime:
                    data['dateTime'] != null
                        ? (data['dateTime'] as Timestamp).toDate()
                        : DateTime.now(), // Added null check
                duration: data['duration'] ?? 60,
                price: data['price'] ?? 0.0,
                status: data['status'],
                studentId: data['studentId'],
                studentName: data['studentName'],
              );
            }).toList();

        _isLoading = false;
      });
    } catch (e) {
      print('[v0] Error loading accepted courses: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Course'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _acceptedCourses.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.school_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No accepted courses yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your accepted courses will appear here',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadAcceptedCourses,
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _acceptedCourses.length,
                  itemBuilder: (context, index) {
                    final course = _acceptedCourses[index];
                    final now = DateTime.now();
                    final courseDate = DateTime(
                      course.dateTime.year,
                      course.dateTime.month,
                      course.dateTime.day,
                    );
                    final today = DateTime(now.year, now.month, now.day);

                    String statusText;
                    Color statusColor;

                    if (courseDate.isAtSameMomentAs(today)) {
                      statusText = 'Ongoing';
                      statusColor = Colors.green;
                    } else if (courseDate.isAfter(today)) {
                      statusText = 'Upcoming';
                      statusColor = Colors.blue;
                    } else {
                      statusText = 'Completed';
                      statusColor = Colors.grey;
                    }

                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [Colors.green[50]!, Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${course.language} Course',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[800],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      statusText,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green[700],
                                      size: 24,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'ACCEPTED',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Icon(
                                    Icons.person,
                                    color: Colors.grey[600],
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Teacher: ${course.teacherName}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    color: Colors.grey[600],
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Date: ${DateFormat('MMM dd, yyyy - hh:mm a').format(course.dateTime)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: Colors.grey[600],
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Duration: ${course.duration} minutes',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Course Modules:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                              SizedBox(height: 8),
                              Column(
                                children:
                                    [
                                          'Module 1: Learn Grammar',
                                          'Module 2: Vocabulary Building',
                                          'Module 3: Conversation Practice',
                                          'Module 4: Reading Comprehension',
                                          'Module 5: Writing Skills',
                                        ]
                                        .map(
                                          (module) => Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 4,
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.check_circle,
                                                  color: Colors.green,
                                                  size: 16,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  module,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                        .toList(),
                              ),
                              if (statusText == 'Today') ...[
                                SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Navigate to class room or start class
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      'Join Class Now',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
