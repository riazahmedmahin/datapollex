import 'package:datapollex/main.dart';
import 'package:datapollex/screens/auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
                              width: double.infinity,
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

