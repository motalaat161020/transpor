// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:math';

import 'package:admin_dashboard/layout.dart';
import 'package:admin_dashboard/pages/authentication/forgetpassword.dart';
import 'package:admin_dashboard/routing/routes.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class AuthenticationPage extends StatefulWidget {
  const AuthenticationPage({super.key});

  @override
  State<AuthenticationPage> createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF667eea),
              Color(0xFF764ba2),
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 450),
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo with animation
                      Hero(
                        tag: "logo",
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              "assets/images/logo.jpg",
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Welcome Text
                      Text(
                        "مرحباً بك",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "تسجيل الدخول إلى لوحة التحكم",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 30),

                      _buildEmailAndPasswordFields(),
                      const SizedBox(height: 30),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed:
                              _isLoading ? null : _signInWithEmailAndPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF667eea),
                            foregroundColor: Colors.white,
                            elevation: 8,
                            shadowColor:
                                const Color(0xFF667eea).withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text(
                                  "تسجيل الدخول",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Forget Password Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: OutlinedButton(
                          onPressed: () {
                            Get.to(() => const ForgetPassword());
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: Color(0xFF667eea), width: 2),
                            foregroundColor: const Color(0xFF667eea),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            "نسيت كلمة المرور؟",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
    );
  }

  Widget _buildEmailAndPasswordFields() {
    return Column(
      children: [
        // Email Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'البريد الإلكتروني',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'أدخل البريد الإلكتروني',
                prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF667eea), width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال البريد الإلكتروني';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value)) {
                  return 'يرجى إدخال بريد إلكتروني صحيح';
                }
                return null;
              },
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Password Field
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'كلمة المرور',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _passwordController,
              obscureText: _obscureText,
              decoration: InputDecoration(
                hintText: 'أدخل كلمة المرور',
                prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[600]),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[600],
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF667eea), width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'يرجى إدخال كلمة المرور';
                }
                if (value.length < 6) {
                  return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                }
                return null;
              },
            ),
          ],
        ),
      ],
    );
  }

  Future<bool> checkUserExistsInFirestore(String userId) async {
    try {
      final docSnapshot =
          await _firestore.collection('admins').doc(userId).get();
      return docSnapshot.exists;
    } catch (e) {
      debugPrint('Error checking user in Firestore: $e');
      return false;
    }
  }

  String generateToken(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#%^&*()_+-={}[]:;"\'<>,.?/';
    final random = Random.secure();
    return String.fromCharCodes(
      Iterable.generate(
          length, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

Future<void> _signInWithEmailAndPassword() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }
  setState(() {
    _isLoading = true;
  });

  try {
    // Sign in with Firebase Auth - استخدم القيم من الحقول
    final userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailController.text.trim(), // استخدم النص من حقل الإيميل
      password: _passwordController.text.trim(), // استخدم النص من حقل كلمة المرور
    );

    final user = userCredential.user;
    if (user == null) {
      throw Exception('فشل في تسجيل الدخول');
    }

    // Check if user exists in Firestore admins collection
    final userExistsInFirestore = await checkUserExistsInFirestore(user.uid);

    if (!userExistsInFirestore) {
      await FirebaseAuth.instance.signOut();
      _showErrorDialog('خطأ', 'هذا الحساب غير مخول لتسجيل الدخول');
      return;
    }

    // Create session
    await createSession(user.uid);
  } on FirebaseAuthException catch (e) {
    String errorMessage = 'حدث خطأ في تسجيل الدخول';

    switch (e.code) {
      case 'user-not-found':
        errorMessage = 'لا يوجد مستخدم بهذا البريد الإلكتروني';
        break;
      case 'wrong-password':
      case 'invalid-credential':
        errorMessage = 'كلمة المرور غير صحيحة';
        break;
      case 'too-many-requests':
        errorMessage =
            'تم تجاوز عدد المحاولات المسموحة. حاول مرة أخرى لاحقاً';
        break;
      case 'user-disabled':
        errorMessage = 'تم تعطيل هذا الحساب';
        break;
      case 'invalid-email':
        errorMessage = 'البريد الإلكتروني غير صحيح';
        break;
    }

    _showErrorDialog('خطأ في تسجيل الدخول', errorMessage);
  } catch (e) {
    debugPrint('Login error: $e');
    _showErrorDialog('خطأ', 'حدث خطأ غير متوقع. حاول مرة أخرى');
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

void _showErrorDialog(String title, String message) {
    AwesomeDialog(
      width: 450,
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.scale,
      title: title,
      desc: message,
      btnOkText: 'موافق',
      btnOkOnPress: () {},
    ).show();
  }

  void _showSuccessDialog(String title, String message, VoidCallback onOk) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.scale,
      title: title,
      desc: message,
      btnOkText: 'موافق',
      btnOkOnPress: onOk,
    ).show();
  }

  Future<void> createSession(String userId) async {
    try {
      String sessionToken = generateToken(200);

      // Update admin document with session info
      await _firestore.collection('admins').doc(userId).update({
        'SessionCreatedAt': Timestamp.now(),
        'token': sessionToken,
        'lastLogin': Timestamp.now(),
      });

      // Verify token was saved correctly
      final docSnapshot =
          await _firestore.collection('admins').doc(userId).get();

      if (!docSnapshot.exists) {
        throw Exception('فشل في العثور على بيانات المستخدم');
      }

      final data = docSnapshot.data();
      final String storedToken = data!['token'].toString();

      if (sessionToken == storedToken) {
        debugPrint('Session created successfully, navigating to SiteLayout');

        // Navigate to main app
        Get.offAll(() => const SiteLayout());

        // Set up auto logout after 1 hour
        Timer(const Duration(hours: 5), () async {
          try {
            await FirebaseAuth.instance.signOut();
            Get.offAll(() => const AuthenticationPage());
          } catch (e) {
            debugPrint('Auto logout error: $e');
          }
        });
      } else {
        throw Exception('فشل في التحقق من الجلسة');
      }
    } catch (error) {
      debugPrint('Failed to create session: $error');
      _showErrorDialog('خطأ', 'فشل في إنشاء الجلسة. حاول مرة أخرى');
    }
  }

  Future<void> signIn() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Add debug logging
      print('Attempting login with email: ${_emailController.text}');

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (userCredential.user != null) {
        print('Login successful for user: ${userCredential.user?.email}');

        // Verify admin status before proceeding
        DocumentSnapshot adminDoc = await FirebaseFirestore.instance
            .collection('admins')
            .doc(userCredential.user?.uid)
            .get();

        if (adminDoc.exists) {
          Get.offAllNamed(rootRoute);
        } else {
          await FirebaseAuth.instance.signOut();
          throw 'User is not an admin';
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });

      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'لا يوجد مستخدم بهذا البريد الإلكتروني';
          break;
        case 'wrong-password':
          errorMessage = 'كلمة المرور غير صحيحة';
          break;
        case 'invalid-email':
          errorMessage = 'البريد الإلكتروني غير صحيح';
          break;
        default:
          errorMessage = 'فشل تسجيل الدخول: ${e.message}';
      }

      Get.snackbar(
        'خطأ',
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );

      print('Login error: ${e.code} - ${e.message}');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      Get.snackbar(
        'خطأ',
        'حدث خطأ غير متوقع',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );

      print('Unexpected error during login: $e');
    }
  }
}
