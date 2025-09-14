import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datapollex/main.dart';
import 'package:datapollex/queryshapshort/querysnapshort.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create or get existing chat room with proper user names
  Future<String> createOrGetChatRoom(String teacherId, String studentId) async {
    List<String> participants = [teacherId, studentId];
    participants.sort();
    String chatRoomId = participants.join('_');

    DocumentReference chatRoomRef = _firestore
        .collection('chat_rooms')
        .doc(chatRoomId);
    DocumentSnapshot chatRoomSnapshot = await chatRoomRef.get();

    if (!chatRoomSnapshot.exists) {
      // Get actual user names
      DocumentSnapshot teacherDoc =
          await _firestore.collection('users').doc(teacherId).get();
      DocumentSnapshot studentDoc =
          await _firestore.collection('users').doc(studentId).get();

      String teacherName = 'Teacher';
      String studentName = 'Student';

      if (teacherDoc.exists) {
        final teacherData = teacherDoc.data() as Map<String, dynamic>;
        teacherName = teacherData['name'] ?? teacherData['email'] ?? 'Teacher';
      }

      if (studentDoc.exists) {
        final studentData = studentDoc.data() as Map<String, dynamic>;
        studentName = studentData['name'] ?? studentData['email'] ?? 'Student';
      }

      await chatRoomRef.set({
        'id': chatRoomId,
        'participants': participants,
        'participantNames': {teacherId: teacherName, studentId: studentName},
        'lastMessage': '',
        'lastMessageTime': Timestamp.now(),
        'lastSenderId': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return chatRoomId;
  }

  // Send message with sender info
  Future<void> sendMessage(String chatRoomId, String message) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    // Get sender name
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(currentUser.uid).get();
    String senderName = currentUser.email ?? 'Unknown';

    if (userDoc.exists) {
      final userData = userDoc.data() as Map<String, dynamic>;
      senderName = userData['name'] ?? userData['email'] ?? 'Unknown';
    }

    final messageData = {
      'senderId': currentUser.uid,
      'senderEmail': currentUser.email,
      'senderName': senderName,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'text',
    };

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(messageData);

    await _firestore.collection('chat_rooms').doc(chatRoomId).update({
      'lastMessage': message,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastSenderId': currentUser.uid,
    });
  }

  // Get messages stream
  Stream<QuerySnapshot> getMessages(String chatRoomId) {
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Stream<QuerySnapshot> getChatRooms() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return const Stream.empty();
    }

    // First try to get chat rooms with messages (has lastMessageTime)
    return _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: currentUser.uid)
        .snapshots()
        .map((snapshot) {
          // Sort the documents manually to handle null lastMessageTime
          final docs = snapshot.docs.toList();
          docs.sort((a, b) {
            final aData = a.data() as Map<String, dynamic>;
            final bData = b.data() as Map<String, dynamic>;

            final aTime = aData['lastMessageTime'] as Timestamp?;
            final bTime = bData['lastMessageTime'] as Timestamp?;

            // If both have timestamps, compare them
            if (aTime != null && bTime != null) {
              return bTime.compareTo(aTime); // Descending order
            }

            // If only one has timestamp, prioritize it
            if (aTime != null && bTime == null) return -1;
            if (aTime == null && bTime != null) return 1;

            // If both are null, maintain original order
            return 0;
          });

          // Create a new QuerySnapshot with sorted docs
          return MockQuerySnapshot(docs);
        });
  }
}
