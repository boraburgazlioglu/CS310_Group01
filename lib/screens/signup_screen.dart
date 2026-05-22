import 'package:flutter/material.dart';
import '../utils/colors.dart';
import '../utils/text.dart';
import '../utils/padding.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    // free up memory when screen is closed
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    //functional submit function, navigation is handled by auth gate
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      displayName: _nameController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Sign up failed.'),
        ),
      );
    }
    if (success) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created. Please log in.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppPadding.allXL,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),

              // app logo
              Image.asset(
                'assets/logo.png',
                height: 100,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.music_note,
                    size: 72,
                    color: AppColors.primary,
                  );
                },
              ),
              const SizedBox(height: 8),
              Text(
                'Create your account',
                style: AppTexts.headS,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // signup form
              Container(
                padding: AppPadding.allL,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // name field
                      TextFormField(
                        controller: _nameController,
                        style: AppTexts.bodyL,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person, color: AppColors.primary),
                          hintText: 'Full Name',
                          hintStyle: AppTexts.bodyM,
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // email field
                      TextFormField(
                        controller: _emailController,
                        style: AppTexts.bodyL,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email, color: AppColors.primary),
                          hintText: 'Email',
                          hintStyle: AppTexts.bodyM,
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
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
                      const SizedBox(height: 12),

                      // password field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        style: AppTexts.bodyL,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock, color: AppColors.primary),
                          hintText: 'Password',
                          hintStyle: AppTexts.bodyM,
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
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
                      const SizedBox(height: 12),

                      // confirm password field
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        style: AppTexts.bodyL,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock_outline, color: AppColors.primary),
                          hintText: 'Confirm Password',
                          hintStyle: AppTexts.bodyM,
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // sign up button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: AppPadding.vertM,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text('Sign Up', style: AppTexts.button),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // back to login
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Already have an account? Log in',
                  style: AppTexts.bodyS.copyWith(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}