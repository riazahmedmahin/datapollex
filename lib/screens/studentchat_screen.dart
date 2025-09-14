import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datapollex/main.dart';
import 'package:datapollex/models/chatservices.dart';
import 'package:datapollex/models/messageModel.dart';
import 'package:datapollex/screens/videocall_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class StudentChatScreen extends StatefulWidget {
  final String teacherId;
  final String teacherName;

  const StudentChatScreen({
    Key? key,
    required this.teacherId,
    required this.teacherName,
  }) : super(key: key);

  @override
  _StudentChatScreenState createState() => _StudentChatScreenState();
}

class _StudentChatScreenState extends State<StudentChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _chatRoomId;
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _initializeChatRoom();
  }

  Future<void> _initializeChatRoom() async {
    if (currentUser != null) {
      final chatRoomId = await _chatService.createOrGetChatRoom(
        widget.teacherId,
        currentUser!.uid,
      );
      setState(() {
        _chatRoomId = chatRoomId;
      });
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _chatRoomId == null) return;

    await _chatService.sendMessage(
      _chatRoomId!,
      _messageController.text.trim(),
    );
    _messageController.clear();

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.teacherName}'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VideoCallScreen()),
              );
            },
            icon: Icon(Icons.video_call, size: 32),
          ),
          SizedBox(width: 12),
        ],
      ),

      body:
          _chatRoomId == null
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _chatService.getMessages(_chatRoomId!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                                  'No chat yet',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Start a conversation with ${widget.teacherName}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final messages =
                            snapshot.data!.docs
                                .map((doc) => MessageModel.fromFirestore(doc))
                                .toList();

                        return ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.all(16),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final message = messages[index];
                            final isMe = message.senderId == currentUser?.uid;

                            return Container(
                              margin: EdgeInsets.only(bottom: 12),
                              child: Row(
                                mainAxisAlignment:
                                    isMe
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                children: [
                                  if (!isMe) ...[
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.blue.shade600,
                                      child: Text(
                                        widget.teacherName[0].toUpperCase(),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                  ],
                                  Flexible(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            isMe
                                                ? Colors.blue.shade600
                                                : Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            message.message,
                                            style: TextStyle(
                                              color:
                                                  isMe
                                                      ? Colors.white
                                                      : Colors.black87,
                                              fontSize: 16,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            _formatTime(message.timestamp),
                                            style: TextStyle(
                                              color:
                                                  isMe
                                                      ? Colors.white70
                                                      : Colors.grey.shade600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (isMe) ...[
                                    SizedBox(width: 8),
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: Colors.green.shade600,
                                      child: Text(
                                        'S',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 4,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'Type a message...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(25),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                            ),
                            maxLines: null,
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ),
                        SizedBox(width: 12),
                        FloatingActionButton(
                          onPressed: _sendMessage,
                          backgroundColor: Colors.blue.shade600,
                          mini: true,
                          child: Icon(Icons.send, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
