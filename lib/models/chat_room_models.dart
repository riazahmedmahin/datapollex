// import 'package:cloud_firestore/cloud_firestore.dart';

// class ChatRoomModel {
//   final String id;
//   final List<String> participants;
//   final Map<String, String> participantNames;
//   final String lastMessage;
//   final DateTime? lastMessageTime;
//   final String lastSenderId;

//   ChatRoomModel({
//     required this.id,
//     required this.participants,
//     required this.participantNames,
//     required this.lastMessage,
//     this.lastMessageTime,
//     required this.lastSenderId,
//   });

//   factory ChatRoomModel.fromFirestore(DocumentSnapshot doc) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
//     return ChatRoomModel(
//       id: doc.id,
//       participants: List<String>.from(data['participants'] ?? []),
//       participantNames: Map<String, String>.from(data['participantNames'] ?? {}),
//       lastMessage: data['lastMessage'] ?? '',
//       lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate(),
//       lastSenderId: data['lastSenderId'] ?? '',
//     );
//   }
// }
