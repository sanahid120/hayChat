import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hay_chat/app/methods/scaffold_message.dart';
import 'package:hay_chat/auth/presentation/providers/sign_in_provider.dart';
import 'package:hay_chat/shared/presentation/screens/homepage_bottom_nav_bar.dart';
import 'package:hay_chat/shared/utils/validators.dart';
import 'package:provider/provider.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_strings.dart';
import '../../../app/models/user_model.dart';
import '../widgets/input_field_widget.dart';
import 'forget_password.dart';
import 'sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  static const String routeName = '/sign-in';

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    checkUser();
  }

  void checkUser() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        if (kDebugMode) {
          print('User is currently signed out!');
        }
      } else {
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          HomepageBottomNavBar.routeName,
          (route) => false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.background),
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
                  AppStrings.welcomeMsg,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  AppStrings.signInToContinue,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.textHint,
                  ),
                ),
                const SizedBox(height: 50),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                      Consumer<SignInProvider>(
                        builder: (context, authProvider, _) {
                          return Visibility(
                            visible: !authProvider.signInProgress,
                            replacement: const Center(
                              child: CircularProgressIndicator(),
                            ),
                            child: FilledButton(
                              onPressed: onPressedSignIn,
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primaryDark,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                AppStrings.signIn,
                                style: Theme.of(context).textTheme.bodyLarge
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
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(color: AppColors.textHint),
                                text: AppStrings.doNotHaveAnAccount,
                                children: [
                                  TextSpan(
                                    text: AppStrings.signUp,
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          color: AppColors.primary,
                                          decoration: TextDecoration.underline,
                                          decorationColor: AppColors.primary,
                                          decorationThickness: 1.5,
                                        ),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.pushNamed(
                                          context,
                                          SignUpScreen.routeName,
                                        );
                                      },
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: onPressedForgotPassword,
                              child: Text(
                                AppStrings.forgotPassword,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(color: AppColors.primary),
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

  void onPressedForgotPassword() {
    Navigator.pushNamed(context, ForgetPasswordScreen.routeName);
  }

  Future<void> onPressedSignIn() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<SignInProvider>();

      bool isSuccess = await authProvider.signIn(
        UserModel(
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );

      if (!mounted) return;

      if (isSuccess) {
        ScaffoldMessage.showMessage(
          AppStrings.signInSuccess,
          context,
          AppColors.textPrimary,
          AppColors.success,
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          HomepageBottomNavBar.routeName,
          (route) => false,
        );
      } else if (authProvider.errorMessage != null) {
        ScaffoldMessage.showMessage(
          authProvider.errorMessage!,
          context,
          AppColors.textPrimary,
          AppColors.error,
        );
      }
    }
  }
}
