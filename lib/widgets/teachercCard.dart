import 'package:datapollex/main.dart';
import 'package:datapollex/models/userMode.dart';
import 'package:datapollex/screens/studentchat_screen.dart';
import 'package:datapollex/screens/teacherprofile_screen.dart';
import 'package:flutter/material.dart';

class TeacherCard extends StatelessWidget {
  final UserModel teacher;
  final String language;

  const TeacherCard({Key? key, required this.teacher, required this.language})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => TeacherProfileScreen(
                    teacher: teacher,
                    selectedLanguage: language,
                  ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blue.shade600,
                child: Text(
                  teacher.name.isNotEmpty ? teacher.name[0].toUpperCase() : 'T',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          teacher.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black, // background color
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 2,
                                offset: Offset(1, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => StudentChatScreen(
                                        teacherId: teacher.id,
                                        teacherName: teacher.name,
                                      ),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.chat,
                              size: 20,
                              color: Colors.white, // icon color
                            ),
                          ),
                        ),
                      ],
                    ),
                    //SizedBox(height: 4),
                    Text(
                      'Languages: ${teacher.languages.join(', ')}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),

                    // Text(
                    //   '\$${teacher.hourlyRate.toStringAsFixed(0)}/hour',
                    //   style: TextStyle(
                    //     color: Colors.green.shade600,
                    //     fontSize: 16,
                    //     fontWeight: FontWeight.w600,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
