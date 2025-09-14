import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datapollex/models/notofication_model.dart';
import 'package:datapollex/models/scheduleslot_model.dart';
import 'package:datapollex/models/userMode.dart';
import 'package:datapollex/widgets/scheduleslotCard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppState with ChangeNotifier {
  String _selectedLanguage = '';
  List<UserModel> _teachers = [];
  List<ScheduleSlot> _availableSlots = [];
  bool _isLoading = false;
  List<NotificationModel> _notifications = [];
  List<ScheduleSlot> _studentBookedSlots = [];

  String get selectedLanguage => _selectedLanguage;
  List<UserModel> get teachers => _teachers;
  List<ScheduleSlot> get availableSlots => _availableSlots;
  bool get isLoading => _isLoading;
  List<NotificationModel> get notifications => _notifications;
  List<ScheduleSlot> get studentBookedSlots => _studentBookedSlots;

  final List<String> supportedLanguages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Japanese',
    'Bengali',
  ];

  void selectLanguage(String language) {
    _selectedLanguage = language;
    notifyListeners();
    loadTeachersByLanguage(language);
  }

  Future<bool> acceptBooking(String scheduleId, String notificationId) async {
    try {
      // Get the schedule details first
      final scheduleDoc =
          await FirebaseFirestore.instance
              .collection('schedules')
              .doc(scheduleId)
              .get();

      if (!scheduleDoc.exists) {
        print('Schedule not found');
        return false;
      }

      final scheduleData = scheduleDoc.data()!;

      // Update schedule status to accepted
      await FirebaseFirestore.instance
          .collection('schedules')
          .doc(scheduleId)
          .update({'status': 'accepted'});

      // Remove the notification from teacher's notifications
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .delete();

      // Add the accepted course to student's bookings collection
      await FirebaseFirestore.instance.collection('student_bookings').add({
        'studentId': scheduleData['studentId'],
        'teacherId': scheduleData['teacherId'],
        'teacherName': scheduleData['teacherName'],
        'courseName': scheduleData['courseName'],
        'language': scheduleData['language'],
        'dateTime': scheduleData['dateTime'],
        'status': 'accepted',
        'createdAt': FieldValue.serverTimestamp(),
        'modules': [
          'Module 1: Learn Grammar',
          'Module 2: Vocabulary Building',
          'Module 3: Conversation Practice',
          'Module 4: Reading Comprehension',
          'Module 5: Writing Skills',
        ],
      });

      // Reload notifications to reflect the removal
      final _currentUser = FirebaseAuth.instance.currentUser;
      await loadTeacherNotifications(_currentUser?.uid ?? '');

      return true;
    } catch (e) {
      print('Error accepting booking: $e');
      return false;
    }
  }

  Future<void> loadTeachersByLanguage(String language) async {
    try {
      _isLoading = true;
      notifyListeners();

      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'teacher')
              .where('languages', arrayContains: language)
              .get();

      _teachers =
          querySnapshot.docs
              .map((doc) => UserModel.fromMap(doc.data()))
              .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error loading teachers: $e');
    }
  }

  Future<void> loadAvailableSlots(
    String teacherId,
    String language,
    String currentStudentId,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('schedules')
              .where('teacherId', isEqualTo: teacherId)
              .where('language', isEqualTo: language)
              .get();

      _availableSlots =
          querySnapshot.docs
              .map((doc) {
                final data = doc.data();
                return ScheduleSlot.fromMap(data);
              })
              .where((slot) {
                return slot.dateTime.isAfter(DateTime.now()) &&
                    slot.status == 'available' &&
                    !slot.isBooked &&
                    slot.studentId !=
                        currentStudentId; // This ensures current student doesn't see their own booked slots
              })
              .toList();

      // Sort by date
      _availableSlots.sort((a, b) => a.dateTime.compareTo(b.dateTime));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error loading available slots: $e');
    }
  }

  Future<bool> bookSlot(
    String slotId,
    String studentId,
    String studentName,
  ) async {
    try {
      // Get the slot details first
      final slotDoc =
          await FirebaseFirestore.instance
              .collection('schedules')
              .doc(slotId)
              .get();

      if (!slotDoc.exists) return false;

      final slotData = slotDoc.data()!;
      final slot = ScheduleSlot.fromMap(slotData);

      // Update the schedule with booking info
      await FirebaseFirestore.instance
          .collection('schedules')
          .doc(slotId)
          .update({
            'isBooked': true,
            'studentId': studentId,
            'studentName': studentName,
            'status': 'pending',
          });

      final notificationId = DateTime.now().millisecondsSinceEpoch.toString();
      final notification = NotificationModel(
        id: notificationId,
        teacherId: slot.teacherId,
        studentId: studentId,
        studentName: studentName,
        message:
            '$studentName booked your ${slot.language} class slot at ${_formatDateTime(slot.dateTime)}',
        scheduleId: slotId,
        createdAt: DateTime.now(),
      );

      // Create notification for teacher with better error handling
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .set(notification.toMap());

      print(
        'Notification created for teacher ${slot.teacherId}: ${notification.message}',
      );

      notifyListeners();

      if (_selectedLanguage.isNotEmpty && _availableSlots.isNotEmpty) {
        final teacherId = _availableSlots.first.teacherId;
        await loadAvailableSlots(teacherId, _selectedLanguage, studentId);
      }

      await loadStudentBookedSlots(studentId);

      return true;
    } catch (e) {
      print('Error booking slot: $e');
      return false;
    }
  }

  Future<void> loadTeacherNotifications(String teacherId) async {
    try {
      FirebaseFirestore.instance
          .collection('notifications')
          .where('teacherId', isEqualTo: teacherId)
          .snapshots()
          .listen(
            (snapshot) {
              _notifications =
                  snapshot.docs
                      .map((doc) => NotificationModel.fromMap(doc.data()))
                      .toList();

              _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

              notifyListeners();
              print(
                'Loaded ${_notifications.length} notifications for teacher $teacherId',
              );
            },
            onError: (error) {
              print('Error in notifications stream: $error');
              _notifications = [];
              notifyListeners();
            },
          );
    } catch (e) {
      print('Error loading teacher notifications: $e');
      _notifications = [];
      notifyListeners();
    }
  }

  Future<void> loadStudentBookedSlots(String studentId) async {
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('schedules')
              .where('studentId', isEqualTo: studentId)
              .where('isBooked', isEqualTo: true)
              .get();

      final bookedSlots =
          querySnapshot.docs.map((doc) {
            final data = doc.data();
            return ScheduleSlot.fromMap(data);
          }).toList();

      // You can store these in a separate list if needed
      // _studentBookedSlots = bookedSlots;
      notifyListeners();
    } catch (e) {
      print('Error loading student booked slots: $e');
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

