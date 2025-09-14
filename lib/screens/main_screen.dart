import 'package:datapollex/main.dart';
import 'package:datapollex/screens/auth_screen.dart';
import 'package:datapollex/screens/home_screen.dart';
import 'package:datapollex/screens/mycourse_screen.dart';
import 'package:datapollex/screens/notification_screen.dart';
import 'package:datapollex/screens/profile_screen.dart';
import 'package:datapollex/screens/scheduleManagement_screen.dart';
import 'package:datapollex/screens/teacherchatlist_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user!;

    final List<Widget> screens =
        user.role == 'teacher'
            ? [
              ScheduleManagementScreen(),
              TeacherChatListScreen(),
              NotificationsScreen(),
              ProfileScreen(),
            ]
            : [HomeScreen(), StudentMyCoursesScreen(), ProfileScreen()];

    final List<BottomNavigationBarItem> navItems =
        user.role == 'teacher'
            ? [
              BottomNavigationBarItem(
                icon: Icon(Icons.schedule),
                label: 'Schedule',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.chat_bubble),
                label: 'Chat',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications),
                label: 'Notifications',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ]
            : [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Icon(Icons.school),
                label: 'My Courses',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: navItems,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue.shade600,
      ),
    );
  }
}

