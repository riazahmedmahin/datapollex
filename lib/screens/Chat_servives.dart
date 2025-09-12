import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Create or get existing chat room
  Future<String> createOrGetChatRoom(String teacherId, String studentId) async {
    // Create a consistent chat room ID
    List<String> participants = [teacherId, studentId];
    participants.sort(); // Ensure consistent ordering
    String chatRoomId = participants.join('_');

    DocumentReference chatRoomRef = _firestore.collection('chat_rooms').doc(chatRoomId);
    DocumentSnapshot chatRoomSnapshot = await chatRoomRef.get();

    if (!chatRoomSnapshot.exists) {
      // Create new chat room
      await chatRoomRef.set({
        'id': chatRoomId,
        'participants': participants,
        'participantNames': {
          teacherId: 'teacher@gmail.com', // You can get actual names from user data
          studentId: 'student@gmail.com',
        },
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastSenderId': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return chatRoomId;
  }

  // Send message
  Future<void> sendMessage(String chatRoomId, String message) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final messageData = {
      'senderId': currentUser.uid,
      'senderEmail': currentUser.email,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
      'type': 'text',
    };

    // Add message to messages subcollection
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(messageData);

    // Update chat room with last message info
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

  // Get chat rooms for current user
  Stream<QuerySnapshot> getChatRooms() {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: currentUser.uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }
}
