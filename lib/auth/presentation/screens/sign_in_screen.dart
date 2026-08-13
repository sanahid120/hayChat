import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hay_chat/shared/utils/validators.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_strings.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(backgroundColor: AppColors.background),

      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: .start,
              crossAxisAlignment: .start,
              children: [
                const SizedBox(height: 46),

                Text(
                  AppStrings.welcomeMsg,

                  style: TextTheme.of(
                    context,
                  ).headlineLarge?.copyWith(color: AppColors.textPrimary),
                ),

                Text(
                  AppStrings.signInToContinue,
                  style: TextTheme.of(
                    context,
                  ).headlineSmall?.copyWith(color: AppColors.textHint),
                ),
                SizedBox(height: 50),

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
                        validator: (value) {
                          final validator = Validators.emailValidator(value);
                          if (validator != null) {
                            return validator;
                          }

                          return null;
                        },
                      ),
                      SizedBox(height: 20),
                      InputField(
                        controller: _passwordController,
                        label: AppStrings.password,
                        icon: Icons.lock,
                        hintText: 'Enter your password',
                        validator: (value) {
                          final validate = Validators.passwordValidator(value);
                          if (validate != null) {
                            return validate;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20),

                      FilledButton(
                        onPressed: () {},
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
                          style: TextTheme.of(
                            context,
                          ).bodyLarge?.copyWith(color: AppColors.textPrimary),
                        ),
                      ),
                      SizedBox(height: 20),

                      Align(
                        alignment: Alignment.center,
                        child: Column(
                          children: [
                            RichText(
                              text: TextSpan(
                                style: TextTheme.of(context).bodyLarge
                                    ?.copyWith(color: AppColors.textHint),

                                text: AppStrings.doNotHaveAnAccount,
                                children: [
                                  TextSpan(
                                    text: AppStrings.signUp,
                                    style: TextTheme.of(context).bodyLarge
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
                              onPressed: () {
                                onPressedForgotPassword(context);
                              },
                              child: Text(
                                AppStrings.forgotPassword,
                                style: TextTheme.of(
                                  context,
                                ).bodyLarge?.copyWith(color: AppColors.primary),
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

  void onPressedForgotPassword(BuildContext context) {
    Navigator.pushNamed(context, ForgetPasswordScreen.routeName);
  }
}
