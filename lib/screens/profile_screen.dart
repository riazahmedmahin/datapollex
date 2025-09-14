import 'package:datapollex/main.dart';
import 'package:datapollex/screens/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body:
          user == null
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.blue[100],
                                  child: Icon(
                                    Icons.person,
                                    size: 30,
                                    color: Colors.blue[600],
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.name,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        user.email,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        user.role == 'teacher'
                                            ? 'Teacher'
                                            : 'Student',
                                        style: TextStyle(
                                          color:
                                              user.role == 'teacher'
                                                  ? Colors.green
                                                  : Colors.blue,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    if (user.role == 'teacher') ...[
                      Card(
                        child: ListTile(
                          leading: Icon(
                            Icons.language,
                            color: Colors.blue[600],
                          ),
                          title: Text('Languages'),
                          subtitle: Text(user.languages.join(', ')),
                        ),
                      ),
                      SizedBox(height: 8),
                    ],
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.settings, color: Colors.grey[600]),
                        title: Text('Settings'),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // Navigate to settings
                        },
                      ),
                    ),
                    SizedBox(height: 8),
                    Card(
                      child: ListTile(
                        leading: Icon(Icons.logout, color: Colors.red),
                        title: Text('Logout'),
                        onTap: () async {
                          await authProvider.signOut();
                          //Navigator.of(context).pushReplacementNamed('/login');
                        },
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}

