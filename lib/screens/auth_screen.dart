import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datapollex/models/userMode.dart';
import 'package:datapollex/notifirer/appstate_notifier.dart';
import 'package:datapollex/screens/login_screen.dart';
import 'package:datapollex/screens/main_screen.dart';
import 'package:datapollex/screens/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppState()),
      ],
      child: MaterialApp(
        title: 'Language Learning App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: SplashScreen(), // Changed from AuthWrapper to SplashScreen
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}



class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (authProvider.user == null) {
          return LoginScreen();
        }

        return MainScreen();
      },
    );
  }
}

class AuthProvider with ChangeNotifier {
  User? _firebaseUser;
  UserModel? _user;
  bool _isLoading = true;

  User? get firebaseUser => _firebaseUser;
  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  AuthProvider() {
    FirebaseAuth.instance.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    _firebaseUser = firebaseUser;
    if (firebaseUser != null) {
      await _loadUserData(firebaseUser.uid);
    } else {
      _user = null;
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadUserData(String uid) async {
    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists) {
        _user = UserModel.fromMap(doc.data()!);
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return true;
    } catch (e) {
      print('Sign in error: $e');
      return false;
    }
  }

  Future<bool> signUp(
    String email,
    String password,
    String name,
    String role,
    List<String> languages,
    double hourlyRate,
  ) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = UserModel(
        id: credential.user!.uid,
        name: name,
        email: email,
        role: role,
        languages: languages,
        hourlyRate: hourlyRate,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set(user.toMap());

      return true;
    } catch (e) {
      print('Sign up error: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> updateProfile(String bio) async {
    if (_user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_user!.id)
            .update({'bio': bio});

        _user = UserModel(
          id: _user!.id,
          name: _user!.name,
          email: _user!.email,
          role: _user!.role,
          languages: _user!.languages,
          hourlyRate: _user!.hourlyRate,
          bio: bio,
          specializations: _user!.specializations,
        );
        notifyListeners();
      } catch (e) {
        print('Error updating profile: $e');
      }
    }
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
          'Module 2: Learn Speaking',
          'Module 3: Learn Writing',
          'Module 4: Learn Reading',
        ],
      });

      return true;
    } catch (e) {
      print('Error accepting booking: $e');
      return false;
    }
  }
}
