import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datapollex/models/chatservices.dart';
import 'package:datapollex/screens/teacherchat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TeacherChatListScreen extends StatefulWidget {
  @override
  _TeacherChatListScreenState createState() => _TeacherChatListScreenState();
}

class _TeacherChatListScreenState extends State<TeacherChatListScreen> {
  final ChatService _chatService = ChatService();
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Messages'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _chatService.getChatRooms(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Students will appear here when they send you messages',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final chatRoom = snapshot.data!.docs[index];
              final chatRoomData = chatRoom.data() as Map<String, dynamic>;

              // Get the other participant (student) ID
              final participants = List<String>.from(
                chatRoomData['participants'],
              );
              final studentId = participants.firstWhere(
                (id) => id != currentUser?.uid,
                orElse: () => '',
              );

              final lastMessage = chatRoomData['lastMessage'] ?? '';
              final lastMessageTime =
                  chatRoomData['lastMessageTime'] as Timestamp?;
              final lastSenderId = chatRoomData['lastSenderId'] ?? '';

              // Show if there's a new message from student
              final hasNewMessage =
                  lastSenderId == studentId && lastMessage.isNotEmpty;

              return Card(
                elevation: 2,
                margin: EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.blue.shade600,
                        child: FutureBuilder<DocumentSnapshot>(
                          future:
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(studentId)
                                  .get(),
                          builder: (context, userSnapshot) {
                            if (userSnapshot.hasData &&
                                userSnapshot.data!.exists) {
                              final userData =
                                  userSnapshot.data!.data()
                                      as Map<String, dynamic>;
                              final studentName =
                                  userData['name'] ??
                                  userData['email'] ??
                                  'Student';
                              return Text(
                                studentName[0].toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }
                            return Text(
                              'S',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),
                      if (hasNewMessage)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: FutureBuilder<DocumentSnapshot>(
                    future:
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(studentId)
                            .get(),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.hasData && userSnapshot.data!.exists) {
                        final userData =
                            userSnapshot.data!.data() as Map<String, dynamic>;
                        final studentName =
                            userData['name'] ??
                            userData['email'] ??
                            'Unknown Student';
                        return Text(
                          studentName,
                          style: TextStyle(
                            fontWeight:
                                hasNewMessage
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                            fontSize: 16,
                          ),
                        );
                      }
                      return Text(
                        'S',
                        style: TextStyle(
                          fontWeight:
                              hasNewMessage
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                          fontSize: 16,
                        ),
                      );
                    },
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (lastMessage.isNotEmpty) ...[
                        SizedBox(height: 4),
                        Text(
                          lastMessage,
                          style: TextStyle(
                            color:
                                hasNewMessage
                                    ? Colors.black87
                                    : Colors.grey.shade600,
                            fontWeight:
                                hasNewMessage
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (lastMessageTime != null) ...[
                        SizedBox(height: 4),
                        Text(
                          _formatChatTime(lastMessageTime),
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                  trailing:
                      hasNewMessage
                          ? Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'New',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                          : Icon(
                            Icons.chevron_right,
                            color: Colors.grey.shade400,
                          ),
                  onTap: () async {
                    // Get student info and navigate to chat
                    final userDoc =
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(studentId)
                            .get();

                    String studentName = 'Unknown Student';
                    if (userDoc.exists) {
                      final userData = userDoc.data() as Map<String, dynamic>;
                      studentName =
                          userData['name'] ??
                          userData['email'] ??
                          'Unknown Student';
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => TeacherChatScreen(
                              studentId: studentId,
                              studentName: studentName,
                              //teacherId: currentUser!.uid,
                              //teacherName: 'Teacher',
                            ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatChatTime(Timestamp timestamp) {
    final now = DateTime.now();
    final messageTime = timestamp.toDate();
    final difference = now.difference(messageTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
