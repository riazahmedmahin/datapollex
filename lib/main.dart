import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

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

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: Duration(milliseconds: 1200),
      vsync: this,
    );

    _rotationController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.easeInOut),
    );

    // Start animations
    _startAnimations();

    // Navigate after splash
    _navigateAfterSplash();
  }

  void _startAnimations() async {
    await Future.delayed(Duration(milliseconds: 300));
    _fadeController.forward();

    await Future.delayed(Duration(milliseconds: 200));
    _scaleController.forward();

    await Future.delayed(Duration(milliseconds: 100));
    _rotationController.repeat();
  }

  void _navigateAfterSplash() async {
    // Wait for animations and auth check
    await Future.delayed(Duration(milliseconds: 4000));

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder:
              (context, animation, secondaryAnimation) => AuthWrapper(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade600,
              Colors.purple.shade400,
              Colors.blue.shade800,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated Logo
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child:  Lottie.asset(
                        "assets/Learn.json",
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
              // Lottie.asset(
              //           "assets/Learn.json",
              //           fit: BoxFit.cover,
              //         ),

              SizedBox(height: 30),

              // App Title
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Language Learning',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 10),

              // Subtitle
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Connect • Learn • Grow',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        letterSpacing: 0.8,
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 60),

              // Loading Animation
              AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: RotationTransition(
                      turns: _rotationAnimation,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white, width: 3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          margin: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 20),

              // Loading Text
              AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: Text(
                      'Loading...',
                      style: TextStyle(fontSize: 16, color: Colors.white70),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
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

class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final List<String> languages;
  final double hourlyRate;
  final String bio;
  final List<String> specializations;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.languages,
    this.hourlyRate = 0.0,
    this.bio = '',
    this.specializations = const [],
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? 'student',
      languages: List<String>.from(map['languages'] ?? []),
      hourlyRate: (map['hourlyRate'] ?? 0.0).toDouble(),
      bio: map['bio'] ?? '',
      specializations: List<String>.from(map['specializations'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'languages': languages,
      'hourlyRate': hourlyRate,
      'bio': bio,
      'specializations': specializations,
    };
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

class ScheduleSlot {
  final String id;
  final String teacherId;
  final String teacherName;
  final DateTime dateTime;
  final int duration;
  final String language;
  final double price;
  final bool isBooked;
  final String? studentId;
  final String? studentName;
  final String status;
  final String? courseName;

  ScheduleSlot({
    required this.id,
    required this.teacherId,
    required this.teacherName,
    required this.dateTime,
    required this.duration,
    required this.language,
    required this.price,
    this.isBooked = false,
    this.studentId,
    this.studentName,
    this.status = 'accepted',
    this.courseName,
  });

  factory ScheduleSlot.fromMap(Map<String, dynamic> map) {
    return ScheduleSlot(
      id: map['id'] ?? '',
      teacherId: map['teacherId'] ?? '',
      teacherName: map['teacherName'] ?? '',
      dateTime:
          map['dateTime'] is String
              ? DateTime.parse(map['dateTime'])
              : (map['dateTime'] as Timestamp).toDate(),
      duration: map['duration'] ?? 60,
      language: map['language'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      isBooked: map['isBooked'] ?? false,
      studentId: map['studentId'],
      studentName: map['studentName'],
      status: map['status'] ?? 'available',
      courseName: map['courseName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'dateTime': Timestamp.fromDate(dateTime),
      'duration': duration,
      'language': language,
      'price': price,
      'isBooked': isBooked,
      'studentId': studentId,
      'studentName': studentName,
      'status': status,
      'courseName': courseName,
    };
  }
}

class NotificationModel {
  final String id;
  final String teacherId;
  final String studentId;
  final String studentName;
  final String message;
  final String scheduleId;
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.teacherId,
    required this.studentId,
    required this.studentName,
    required this.message,
    required this.scheduleId,
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'] ?? '',
      teacherId: map['teacherId'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      message: map['message'] ?? '',
      scheduleId: map['scheduleId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teacherId': teacherId,
      'studentId': studentId,
      'studentName': studentName,
      'message': message,
      'scheduleId': scheduleId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
    };
  }
}

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

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  // Registration fields
  final _nameController = TextEditingController();
  final _rateController = TextEditingController();
  String _selectedRole = 'student';
  List<String> _selectedLanguages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade400, Colors.purple.shade300],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.school,
                          size: 64,
                          color: Colors.blue.shade600,
                        ),
                        SizedBox(height: 16),
                        Text(
                          _isLogin ? 'Welcome Back!' : 'Join Us!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _isLogin
                              ? 'Sign in to continue learning'
                              : 'Create your account',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 32),

                        // Name field (only for registration)
                        if (!_isLogin) ...[
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: Icon(Icons.person),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 16),

                          // Role selection
                          DropdownButtonFormField<String>(
                            value: _selectedRole,
                            decoration: InputDecoration(
                              labelText: 'I am a',
                              prefixIcon: Icon(Icons.work),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: 'student',
                                child: Text('Student'),
                              ),
                              DropdownMenuItem(
                                value: 'teacher',
                                child: Text('Teacher'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedRole = value!;
                                _selectedLanguages.clear();
                              });
                            },
                          ),
                          SizedBox(height: 16),

                          if (_selectedRole == 'teacher') ...[
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade400),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Languages I can teach:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Wrap(
                                    spacing: 8,
                                    children:
                                        [
                                              'English',
                                              'Spanish',
                                              'French',
                                              'German',
                                              'Japanese',
                                              'Bengali',
                                            ]
                                            .map(
                                              (language) => FilterChip(
                                                label: Text(language),
                                                selected: _selectedLanguages
                                                    .contains(language),
                                                onSelected: (selected) {
                                                  setState(() {
                                                    if (selected) {
                                                      _selectedLanguages.add(
                                                        language,
                                                      );
                                                    } else {
                                                      _selectedLanguages.remove(
                                                        language,
                                                      );
                                                    }
                                                  });
                                                },
                                              ),
                                            )
                                            .toList(),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),
                          ],

                          // // Hourly rate (only for teachers)
                          // if (_selectedRole == 'teacher') ...[
                          //   TextFormField(
                          //     controller: _rateController,
                          //     decoration: InputDecoration(
                          //       labelText: 'Hourly Rate (\$)',
                          //       prefixIcon: Icon(Icons.attach_money),
                          //       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          //     ),
                          //     keyboardType: TextInputType.number,
                          //     validator: (value) {
                          //       if (value == null || value.isEmpty) {
                          //         return 'Please enter your hourly rate';
                          //       }
                          //       if (double.tryParse(value) == null) {
                          //         return 'Please enter a valid number';
                          //       }
                          //       return null;
                          //     },
                          //   ),
                          //   SizedBox(height: 16),
                          // ],
                        ],

                        // Email field
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),

                        // Password field
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 24),

                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade600,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child:
                                _isLoading
                                    ? CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : Text(
                                      _isLogin ? 'Sign In' : 'Sign Up',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                          ),
                        ),
                        SizedBox(height: 16),

                        // Toggle between login and signup
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          },
                          child: Text(
                            _isLogin
                                ? "Don't have an account? Sign Up"
                                : "Already have an account? Sign In",
                            style: TextStyle(color: Colors.blue.shade600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isLogin && _selectedRole == 'teacher' && _selectedLanguages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one language you can teach'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool success;

    if (_isLogin) {
      success = await authProvider.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } else {
      final hourlyRate =
          _selectedRole == 'teacher'
              ? double.tryParse(_rateController.text) ?? 0.0
              : 0.0;

      final languages =
          _selectedRole == 'student' ? <String>[] : _selectedLanguages;

      success = await authProvider.signUp(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
        _selectedRole,
        languages,
        hourlyRate,
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isLogin
                ? 'Login failed. Please try again.'
                : 'Registration failed. Please try again.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

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

class StudentHomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        return Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose a Language to Learn',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 16),

              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: appState.supportedLanguages.length,
                  itemBuilder: (context, index) {
                    final language = appState.supportedLanguages[index];
                    return LanguageCard(
                      language: language,
                      onTap: () {
                        appState.selectLanguage(language);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) =>
                                    TeachersListScreen(language: language),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class TeacherHomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.message, size: 48, color: Colors.green.shade600),
                  SizedBox(height: 16),
                  Text(
                    'Student Messages',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'View and respond to messages from your students',
                    style: TextStyle(color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TeacherChatListScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'View Messages',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.schedule, size: 48, color: Colors.blue.shade600),
                  SizedBox(height: 16),
                  Text(
                    'Manage Your Teaching Schedule',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add available time slots for students to book',
                    style: TextStyle(color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScheduleManagementScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Manage Schedule',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.blue.shade600,
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${user.name}!',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user.role == 'teacher'
                                ? 'Ready to teach today?'
                                : 'Ready to learn something new?',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content based on user role
              Expanded(
                child:
                    user.role == 'teacher'
                        ? TeacherHomeContent()
                        : StudentHomeContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LanguageCard extends StatelessWidget {
  final String language;
  final VoidCallback onTap;

  const LanguageCard({Key? key, required this.language, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade400, Colors.blue.shade600],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.language, size: 40, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  language,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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

class TeacherCard extends StatelessWidget {
  final UserModel teacher;
  final String language;

  const TeacherCard({Key? key, required this.teacher, required this.language})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => TeacherProfileScreen(
                    teacher: teacher,
                    selectedLanguage: language,
                  ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blue.shade600,
                child: Text(
                  teacher.name.isNotEmpty ? teacher.name[0].toUpperCase() : 'T',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          teacher.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black, // background color
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 2,
                                offset: Offset(1, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => StudentChatScreen(
                                        teacherId: teacher.id,
                                        teacherName: teacher.name,
                                      ),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.chat,
                              size: 20,
                              color: Colors.white, // icon color
                            ),
                          ),
                        ),
                      ],
                    ),
                    //SizedBox(height: 4),
                    Text(
                      'Languages: ${teacher.languages.join(', ')}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),

                    // Text(
                    //   '\$${teacher.hourlyRate.toStringAsFixed(0)}/hour',
                    //   style: TextStyle(
                    //     color: Colors.green.shade600,
                    //     fontSize: 16,
                    //     fontWeight: FontWeight.w600,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TeacherProfileScreen extends StatefulWidget {
  final UserModel teacher;
  final String selectedLanguage;

  const TeacherProfileScreen({
    Key? key,
    required this.teacher,
    required this.selectedLanguage,
  }) : super(key: key);

  @override
  _TeacherProfileScreenState createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      final currentUser =
          Provider.of<AuthProvider>(context, listen: false).user!;
      appState.loadAvailableSlots(
        widget.teacher.id,
        widget.selectedLanguage,
        currentUser.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.teacher.name),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Teacher Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade400],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Text(
                      widget.teacher.name.isNotEmpty
                          ? widget.teacher.name[0].toUpperCase()
                          : 'T',
                      style: TextStyle(
                        color: Colors.blue.shade600,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.teacher.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            /// Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// About Section
                  if (widget.teacher.bio.isNotEmpty) ...[
                    Text(
                      'About',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.teacher.bio,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  /// Languages Section
                  Text(
                    'Languages',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        widget.teacher.languages.map((language) {
                          final isSelected =
                              language == widget.selectedLanguage;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? Colors.blue.shade600
                                      : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              language,
                              style: TextStyle(
                                color:
                                    isSelected
                                        ? Colors.white
                                        : Colors.grey.shade700,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 24),

                  /// Available Slots Section
                  Consumer<AppState>(
                    builder: (context, appState, child) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Available Slots',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (appState.availableSlots.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${appState.availableSlots.length} available',
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          if (appState.isLoading)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (appState.availableSlots.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.schedule_outlined,
                                    size: 48,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No available slots',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Check back later for new availability',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            Column(
                              children:
                                  appState.availableSlots.map((slot) {
                                    return SlotCard(
                                      slot: slot,
                                      onBook: () => _bookSlot(context, slot),
                                    );
                                  }).toList(),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _bookSlot(BuildContext context, ScheduleSlot slot) async {
    final currentUser = Provider.of<AuthProvider>(context, listen: false).user!;
    final appState = Provider.of<AppState>(context, listen: false);

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Booking'),
            content: Text(
              'Book this ${slot.language} lesson for ${_formatDateTime(slot.dateTime)}?\n\nPrice: \$${slot.price.toStringAsFixed(2)}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                ),
                child: const Text(
                  'Book Now',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final success = await appState.bookSlot(
        slot.id,
        currentUser.id,
        currentUser.name,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Lesson booked successfully! Waiting for teacher confirmation.'
                : 'Failed to book lesson. Please try again.',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class SlotCard extends StatelessWidget {
  final ScheduleSlot slot;
  final VoidCallback onBook;

  const SlotCard({Key? key, required this.slot, required this.onBook})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade600,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.schedule, color: Colors.white, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatDateTime(slot.dateTime),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${slot.duration} minutes • ${slot.language}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '\$${slot.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: onBook,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Book', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class ScheduleManagementScreen extends StatefulWidget {
  @override
  _ScheduleManagementScreenState createState() =>
      _ScheduleManagementScreenState();
}

class _ScheduleManagementScreenState extends State<ScheduleManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedLanguage = '';
  int _duration = 60;
  double _price = 25.0;
  List<ScheduleSlot> _mySlots = [];

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).user!;
    if (user.languages.isNotEmpty) {
      _selectedLanguage = user.languages.first;
    }
    _loadMySlots();
  }

  Future<void> _loadMySlots() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user!;
    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('schedules')
              .where('teacherId', isEqualTo: user.id)
              .orderBy('dateTime')
              .get();

      setState(() {
        _mySlots =
            querySnapshot.docs
                .map((doc) => ScheduleSlot.fromMap(doc.data()))
                .toList();
      });
    } catch (e) {
      print('Error loading slots: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Schedule'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add New Slot Form
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Add New Time Slot',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),

                      // Language Selection
                      DropdownButtonFormField<String>(
                        value:
                            _selectedLanguage.isEmpty
                                ? null
                                : _selectedLanguage,
                        decoration: InputDecoration(
                          labelText: 'Language',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items:
                            user.languages
                                .map(
                                  (lang) => DropdownMenuItem(
                                    value: lang,
                                    child: Text(lang),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (value) =>
                                setState(() => _selectedLanguage = value!),
                        validator:
                            (value) =>
                                value?.isEmpty ?? true
                                    ? 'Please select a language'
                                    : null,
                      ),
                      SizedBox(height: 16),

                      // Date Selection
                      InkWell(
                        onTap: _selectDate,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Date',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Time Selection
                      InkWell(
                        onTap: _selectTime,
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Time',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                          ),
                        ),
                      ),
                      SizedBox(height: 16),

                      // Duration Selection
                      DropdownButtonFormField<int>(
                        value: _duration,
                        decoration: InputDecoration(
                          labelText: 'Duration (minutes)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        items:
                            [30, 45, 60, 90, 120]
                                .map(
                                  (duration) => DropdownMenuItem(
                                    value: duration,
                                    child: Text('$duration minutes'),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (value) => setState(() => _duration = value!),
                      ),
                      SizedBox(height: 16),

                      // Price Input
                      TextFormField(
                        initialValue: _price.toString(),
                        decoration: InputDecoration(
                          labelText: 'Price (\$)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged:
                            (value) =>
                                _price = double.tryParse(value) ?? _price,
                        validator:
                            (value) =>
                                double.tryParse(value ?? '') == null
                                    ? 'Please enter a valid price'
                                    : null,
                      ),
                      SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _addSlot,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue.shade600,
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            'Add Time Slot',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(height: 24),

            // My Slots List
            Text(
              'My Available Slots',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            if (_mySlots.isEmpty)
              Card(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No slots added yet',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                ),
              )
            else
              ..._mySlots.map(
                (slot) => Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          slot.isBooked
                              ? Colors.red.shade100
                              : Colors.green.shade100,
                      child: Icon(
                        slot.isBooked
                            ? Icons.event_busy
                            : Icons.event_available,
                        color: slot.isBooked ? Colors.red : Colors.green,
                      ),
                    ),
                    title: Text(
                      '${slot.language} - ${slot.dateTime.day}/${slot.dateTime.month}/${slot.dateTime.year}',
                    ),
                    subtitle: Text(
                      '${slot.dateTime.hour}:${slot.dateTime.minute.toString().padLeft(2, '0')} - ${slot.duration} min - \$${slot.price.toStringAsFixed(2)}',
                    ),
                    trailing:
                        slot.isBooked
                            ? Chip(
                              label: Text('Booked'),
                              backgroundColor: Colors.red.shade100,
                            )
                            : IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteSlot(slot.id),
                            ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _addSlot() async {
    if (!_formKey.currentState!.validate()) return;

    final user = Provider.of<AuthProvider>(context, listen: false).user!;
    final dateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final slot = ScheduleSlot(
      id: '',
      teacherId: user.id,
      teacherName: user.name,
      dateTime: dateTime,
      duration: _duration,
      language: _selectedLanguage,
      price: _price,
      status: 'available',
    );

    try {
      final docRef = await FirebaseFirestore.instance
          .collection('schedules')
          .add(slot.toMap());
      await docRef.update({'id': docRef.id});

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Time slot added successfully!')));

      _loadMySlots();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding slot: $e')));
    }
  }

  Future<void> _deleteSlot(String slotId) async {
    try {
      await FirebaseFirestore.instance
          .collection('schedules')
          .doc(slotId)
          .delete();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Slot deleted successfully!')));
      _loadMySlots();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting slot: $e')));
    }
  }
}

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  Timer? _timer; // Added timer variable to properly manage it

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });

    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadNotifications();
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (authProvider.user == null) {
        print('User is null, cannot load notifications');
        return;
      }

      final appState = Provider.of<AppState>(context, listen: false);
      await appState.loadTeacherNotifications(authProvider.user!.id);
    } catch (e) {
      print('Error loading notifications: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading notifications: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadNotifications),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (appState.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (appState.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadNotifications,
            child: ListView.separated(
              padding: EdgeInsets.all(16),
              physics: AlwaysScrollableScrollPhysics(),
              itemCount: appState.notifications.length,
              separatorBuilder: (context, index) => SizedBox(height: 8),
              itemBuilder: (context, index) {
                final notification = appState.notifications[index];
                return NotificationCard(
                  notification: notification,
                  onAccept: () => _acceptBooking(notification),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _acceptBooking(NotificationModel notification) async {
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final success = await appState.acceptBooking(
        notification.scheduleId,
        notification.id,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Booking accepted successfully!'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          _loadNotifications(); // Refresh notifications
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 8),
                  Text('Failed to accept booking. Please try again.'),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      print('Error accepting booking: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

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

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onAccept;

  const NotificationCard({
    Key? key,
    required this.notification,
    required this.onAccept,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications, color: Colors.blue[600], size: 20),
                SizedBox(width: 8),
                Text(
                  'New Booking Request',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[600],
                  ),
                ),
                Spacer(),
                Text(
                  _formatTime(notification.createdAt),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(notification.message, style: TextStyle(fontSize: 14)),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // TextButton(
                //   onPressed: () {
                //     // Decline functionality can be added here
                //   },
                //   child: Text(
                //     'Decline',
                //     style: TextStyle(color: Colors.grey[600]),
                //   ),
                // ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Accept'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class StudentMyCoursesScreen extends StatefulWidget {
  @override
  _StudentMyCoursesScreenState createState() => _StudentMyCoursesScreenState();
}

class _StudentMyCoursesScreenState extends State<StudentMyCoursesScreen> {
  List<ScheduleSlot> _acceptedCourses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAcceptedCourses();
  }

  Future<void> _loadAcceptedCourses() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user!;
    print('[v0] Loading courses for student ID: ${user.id}');

    try {
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('student_bookings')
              .where('studentId', isEqualTo: user.id)
              .where('status', isEqualTo: 'accepted')
              .get(); // Removed orderBy to avoid index issues

      print('[v0] Found ${querySnapshot.docs.length} accepted courses');

      setState(() {
        _acceptedCourses =
            querySnapshot.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              print('[v0] Course data: ${data}');

              return ScheduleSlot(
                id: doc.id,
                teacherId: data['teacherId'],
                teacherName: data['teacherName'],
                courseName: data['courseName'] ?? 'Course', // Added fallback
                language: data['language'] ?? 'Language', // Added fallback
                dateTime:
                    data['dateTime'] != null
                        ? (data['dateTime'] as Timestamp).toDate()
                        : DateTime.now(), // Added null check
                duration: data['duration'] ?? 60,
                price: data['price'] ?? 0.0,
                status: data['status'],
                studentId: data['studentId'],
                studentName: data['studentName'],
              );
            }).toList();

        _isLoading = false;
      });
    } catch (e) {
      print('[v0] Error loading accepted courses: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Course'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : _acceptedCourses.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.school_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No accepted courses yet',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Your accepted courses will appear here',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadAcceptedCourses,
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _acceptedCourses.length,
                  itemBuilder: (context, index) {
                    final course = _acceptedCourses[index];
                    final now = DateTime.now();
                    final courseDate = DateTime(
                      course.dateTime.year,
                      course.dateTime.month,
                      course.dateTime.day,
                    );
                    final today = DateTime(now.year, now.month, now.day);

                    String statusText;
                    Color statusColor;

                    if (courseDate.isAtSameMomentAs(today)) {
                      statusText = 'Ongoing';
                      statusColor = Colors.green;
                    } else if (courseDate.isAfter(today)) {
                      statusText = 'Upcoming';
                      statusColor = Colors.blue;
                    } else {
                      statusText = 'Completed';
                      statusColor = Colors.grey;
                    }

                    return Card(
                      margin: EdgeInsets.only(bottom: 16),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            colors: [Colors.green[50]!, Colors.white],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${course.language} Course',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[800],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      statusText,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green[700],
                                      size: 24,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'ACCEPTED',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Icon(
                                    Icons.person,
                                    color: Colors.grey[600],
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Teacher: ${course.teacherName}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    color: Colors.grey[600],
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Date: ${DateFormat('MMM dd, yyyy - hh:mm a').format(course.dateTime)}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: Colors.grey[600],
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Duration: ${course.duration} minutes',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Course Modules:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                              SizedBox(height: 8),
                              Column(
                                children:
                                    [
                                          'Module 1: Learn Grammar',
                                          'Module 2: Vocabulary Building',
                                          'Module 3: Conversation Practice',
                                          'Module 4: Reading Comprehension',
                                          'Module 5: Writing Skills',
                                        ]
                                        .map(
                                          (module) => Padding(
                                            padding: EdgeInsets.symmetric(
                                              vertical: 4,
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.check_circle,
                                                  color: Colors.green,
                                                  size: 16,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  module,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                        .toList(),
                              ),
                              if (statusText == 'Today') ...[
                                SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Navigate to class room or start class
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      'Join Class Now',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}

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

//
/// chat related code ///

class ChatRoomModel {
  final String id;
  final List<String> participants;
  final Map<String, String> participantNames;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final String lastSenderId;

  ChatRoomModel({
    required this.id,
    required this.participants,
    required this.participantNames,
    required this.lastMessage,
    this.lastMessageTime,
    required this.lastSenderId,
  });

  factory ChatRoomModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ChatRoomModel(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      participantNames: Map<String, String>.from(
        data['participantNames'] ?? {},
      ),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: (data['lastMessageTime'] as Timestamp?)?.toDate(),
      lastSenderId: data['lastSenderId'] ?? '',
    );
  }
}

class MessageModel {
  final String id;
  final String senderId;
  final String senderEmail;
  final String message;
  final DateTime timestamp;
  final String type;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.senderEmail,
    required this.message,
    required this.timestamp,
    required this.type,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      senderEmail: data['senderEmail'] ?? '',
      message: data['message'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: data['type'] ?? 'text',
    );
  }
}

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

class MockQuerySnapshot implements QuerySnapshot {
  final List<QueryDocumentSnapshot> _docs;

  MockQuerySnapshot(this._docs);

  @override
  List<QueryDocumentSnapshot> get docs => _docs;

  @override
  List<DocumentChange> get docChanges => [];

  @override
  SnapshotMetadata get metadata => MockSnapshotMetadata();

  @override
  int get size => _docs.length;
}

class MockSnapshotMetadata implements SnapshotMetadata {
  @override
  bool get hasPendingWrites => false;

  @override
  bool get isFromCache => false;
}

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

class TeacherChatScreen extends StatefulWidget {
  final String studentId;
  final String studentName;

  const TeacherChatScreen({
    Key? key,
    required this.studentId,
    required this.studentName,
  }) : super(key: key);

  @override
  _TeacherChatScreenState createState() => _TeacherChatScreenState();
}

class _TeacherChatScreenState extends State<TeacherChatScreen> {
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
        currentUser!.uid,
        widget.studentId,
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
        title: Text('Chat with ${widget.studentName}'),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
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
                                  'Start a conversation with ${widget.studentName}',
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
                                        widget.studentName[0].toUpperCase(),
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
                                                ? Colors.green.shade600
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
                                        'T',
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
                          backgroundColor: Colors.green.shade600,
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

//

class VideoCallScreen extends StatefulWidget {
  const VideoCallScreen({Key? key}) : super(key: key);

  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isSpeakerOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main video (teacher)
          Center(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.grey[900],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.blue.shade600,
                      child: Icon(Icons.person, size: 60, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Teacher",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Connecting...',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Self view - Camera on/off er upor depend kore
          Positioned(
            top: 60,
            right: 16,
            child: Container(
              width: 120,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: _isCameraOff
                  ? const Center(
                      child: Icon(Icons.person, size: 60, color: Colors.white),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        // Eikhane actual camera preview thakbe
                        // Apnar real app e camera package use kore video feed show korben
                        color: Colors.black,
                      ),
                      child: const Center(
                        child: Icon(Icons.videocam, size: 40, color: Colors.white),
                      ),
                    ),
            ),
          ),

          // Call controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCallButton(
                      icon: _isMuted ? Icons.mic_off : Icons.mic,
                      color: _isMuted ? Colors.red : Colors.white,
                      onPressed: () {
                        setState(() {
                          _isMuted = !_isMuted;
                        });
                      },
                      label: _isMuted ? 'Unmute' : 'Mute',
                    ),
                    const SizedBox(width: 16),
                    _buildCallButton(
                      icon: _isCameraOff ? Icons.videocam_off : Icons.videocam,
                      color: _isCameraOff ? Colors.red : Colors.white,
                      onPressed: () {
                        setState(() {
                          _isCameraOff = !_isCameraOff;
                        });
                      },
                      label: _isCameraOff ? 'Camera On' : 'Camera Off',
                    ),
                    const SizedBox(width: 16),
                    _buildCallButton(
                      icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                      color: _isSpeakerOn ? Colors.white : Colors.grey,
                      onPressed: () {
                        setState(() {
                          _isSpeakerOn = !_isSpeakerOn;
                        });
                      },
                      label: _isSpeakerOn ? 'Speaker' : 'Speaker Off',
                    ),
                    const SizedBox(width: 16),
                    _buildCallButton(
                      icon: Icons.call_end_outlined,
                      color: Colors.white,
                      backgroundColor: Colors.red,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      label: 'End',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Back button
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallButton({
    required IconData icon,
    required Color color,
    Color? backgroundColor,
    required VoidCallback onPressed,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.grey[800],
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon, color: color, size: 28),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}