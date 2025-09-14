import 'package:datapollex/main.dart';
import 'package:datapollex/notifirer/appstate_notifier.dart';
import 'package:datapollex/widgets/teachercCard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TeachersListScreen extends StatelessWidget {
  final String language;

  const TeachersListScreen({Key? key, required this.language})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$language Teachers'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (appState.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (appState.teachers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No teachers found for $language',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: appState.teachers.length,
            itemBuilder: (context, index) {
              final teacher = appState.teachers[index];
              return TeacherCard(teacher: teacher, language: language);
            },
          );
        },
      ),
    );
  }
}

