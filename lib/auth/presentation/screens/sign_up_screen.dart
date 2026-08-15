import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hay_chat/app/app_strings.dart';
import 'package:hay_chat/app/methods/scaffold_message.dart';
import 'package:hay_chat/app/models/user_model.dart';
import 'package:hay_chat/auth/presentation/providers/sign_up_provider.dart';
import 'package:hay_chat/shared/presentation/screens/homepage_bottom_nav_bar.dart';
import 'package:hay_chat/shared/utils/validators.dart';
import 'package:provider/provider.dart';

import '../../../app/app_colors.dart';
import '../widgets/input_field_widget.dart';
import 'sign_in_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  static const String routeName = '/sign-up';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 46),
                Text(
                  AppStrings.createAccount,
                  style: Theme.of(context)
                      .textTheme
                      .headlineLarge
                      ?.copyWith(color: AppColors.textPrimary),
                ),
                Text(
                  AppStrings.getStarted,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(color: AppColors.textHint),
                ),
                const SizedBox(height: 50),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InputField(
                        controller: _fullNameController,
                        label: AppStrings.name,
                        hintText: "Enter your name",
                        icon: Icons.person,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          if (value.length < 3) {
                            return 'Name must be at least 3 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      InputField(
                        controller: _emailController,
                        label: AppStrings.email,
                        icon: Icons.email,
                        hintText: 'Enter your email',
                        validator: Validators.emailValidator,
                      ),
                      const SizedBox(height: 20),
                      InputField(
                        controller: _passwordController,
                        label: AppStrings.password,
                        icon: Icons.lock,
                        hintText: 'Enter your password',
                        validator: Validators.passwordValidator,
                      ),
                      const SizedBox(height: 20),
                      Consumer<SignUpProvider>(
                        builder: (context, signUpProvider, _) {
                          return Visibility(
                            visible: !signUpProvider.signUpInProgress,
                            replacement: const Center(
                              child: CircularProgressIndicator(),
                            ),
                            child: FilledButton(
                              onPressed: onPressedSignUp,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primaryDark,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                AppStrings.signUp,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(color: AppColors.textPrimary),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            RichText(
                              text: TextSpan(
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(color: AppColors.textHint),
                                text: AppStrings.alreadyHaveAnAccount,
                                children: [
                                  TextSpan(
                                    text: AppStrings.signIn,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          color: AppColors.primary,
                                          decoration: TextDecoration.underline,
                                          decorationColor: AppColors.primary,
                                          decorationThickness: 1.5,
                                        ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          SignInScreen.routeName,
                                        );
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ],
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
    );
  }

  Future<void> onPressedSignUp() async {
    if (_formKey.currentState!.validate()) {
      final signUpProvider = context.read<SignUpProvider>();

      bool isSuccess = await signUpProvider.signUp(
        UserModel(
          name: _fullNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );

      if (!mounted) return;

      if (isSuccess) {
        ScaffoldMessage.showMessage(
          'Account created successfully!',
          context,
          AppColors.textPrimary,
          AppColors.success,
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          HomepageBottomNavBar.routeName,
          (route) => false,
        );
      } else if (signUpProvider.errorMessage != null) {
        ScaffoldMessage.showMessage(
          signUpProvider.errorMessage!,
          context,
          AppColors.textPrimary,
          AppColors.error,
        );
      }
    }
  }
}
