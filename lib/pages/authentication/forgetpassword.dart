import 'package:admin_dashboard/pages/authentication/login_as_admin.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _emailController.dispose();
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
                        tag: "logo_reset",
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Container(
                              height: 100,
                              width: 100,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
                                ),
                              ),
                              child: const Icon(
                                Icons.lock_reset,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Title Text
                      Text(
                        "استعادة كلمة المرور",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "أدخل بريدك الإلكتروني لإرسال رابط الاستعادة",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),

                      // Email Field
                      _buildEmailField(),
                      const SizedBox(height: 30),

                      // Reset Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : resetPassword,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B6B),
                            foregroundColor: Colors.white,
                            elevation: 8,
                            shadowColor: const Color(0xFFFF6B6B).withOpacity(0.4),
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
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  "إرسال رابط الاستعادة",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Back Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: OutlinedButton(
                          onPressed: () {
                            Get.off(() => const AuthenticationPage());
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF667eea), width: 2),
                            foregroundColor: const Color(0xFF667eea),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            "العودة لتسجيل الدخول",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),
                      const Divider(),
                      const SizedBox(height: 20),

                      // Emergency Access Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red[200]!),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.warning_amber_rounded, 
                                 color: Colors.red[600], size: 32),
                            const SizedBox(height: 8),
                            Text(
                              "وصول طارئ",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red[700],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "إذا كنت لا تتذكر بريدك الإلكتروني نهائياً",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.red[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _showEmergencyOptions,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[600],
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text("خيارات الوصول الطارئ"),
                              ),
                            ),
                          ],
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

  Widget _buildEmailField() {
    return Column(
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
              borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى إدخال البريد الإلكتروني';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'يرجى إدخال بريد إلكتروني صحيح';
            }
            return null;
          },
        ),
      ],
    );
  }

  Future<void> resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await auth.sendPasswordResetEmail(email: _emailController.text.trim());
      
      if (mounted) {
        AwesomeDialog(
          width: 450,
          context: context,
          dialogType: DialogType.success,
          animType: AnimType.scale,
          title: 'تم الإرسال',
          desc: "تم إرسال رابط استعادة كلمة المرور إلى بريدك الإلكتروني",
          btnOkText: 'موافق',
          btnOkOnPress: () {},
        ).show();
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'حدث خطأ في إرسال الرابط';
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'لا يوجد حساب مسجل بهذا البريد الإلكتروني';
          break;
        case 'invalid-email':
          errorMessage = 'البريد الإلكتروني غير صحيح';
          break;
        case 'too-many-requests':
          errorMessage = 'تم تجاوز عدد المحاولات المسموحة. حاول لاحقاً';
          break;
      }
      
      if (mounted) {
        AwesomeDialog(
          width: 450,
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.scale,
          title: 'خطأ',
          desc: errorMessage,
          btnOkText: 'موافق',
          btnOkOnPress: () {},
        ).show();
      }
    } catch (e) {
      if (mounted) {
        AwesomeDialog(
          width: 450,
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.scale,
          title: 'خطأ',
          desc: 'حدث خطأ غير متوقع. حاول مرة أخرى',
          btnOkText: 'موافق',
          btnOkOnPress: () {},
        ).show();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showEmergencyOptions() {
    AwesomeDialog(
      width: 500,
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.scale,
      title: 'خيارات الوصول الطارئ',
      desc: '''إذا كنت لا تستطيع الوصول لحسابك نهائياً، يمكنك:

1. محاولة البحث في بريدك الإلكتروني عن رسائل سابقة من Firebase
2. التحقق من متصفحك المحفوظة (كلمات المرور المحفوظة)
3. إنشاء مشروع Firebase جديد والبدء من جديد
4. التواصل مع مطور آخر للمساعدة في استعادة الوصول

هل تريد إنشاء حساب admin جديد للطوارئ؟''',
      btnOkText: 'إنشاء حساب طوارئ',
      btnCancelText: 'إلغاء',
      btnOkOnPress: _createEmergencyAdmin,
      btnCancelOnPress: () {},
    ).show();
  }

  void _createEmergencyAdmin() {
    // يمكنك هنا إضافة كود لإنشاء حساب admin جديد بقيم افتراضية
    // أو توجيه المستخدم لصفحة خاصة لهذا الغرض
    AwesomeDialog(
      context: context,
      dialogType: DialogType.info,
      animType: AnimType.scale,
      title: 'حساب الطوارئ',
      desc: '''يمكنك إنشاء حساب admin جديد بالمعلومات التالية:

Email: emergency@admin.com
Password: Emergency123!

ملاحظة: يُنصح بتغيير هذه البيانات فور تسجيل الدخول''',
      btnOkText: 'فهمت',
      btnOkOnPress: () {},
    ).show();
  }
}