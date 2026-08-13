import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:hay_chat/app/app_strings.dart';
import 'package:hay_chat/shared/utils/validators.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
appBar: AppBar(backgroundColor: AppColors.background,),

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
                  AppStrings.createAccount,

                  style: TextTheme.of(
                    context,
                  ).headlineLarge?.copyWith(color: AppColors.textPrimary),
                ),

                Text(
                  AppStrings.getStarted,
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
                      SizedBox(height: 20),

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
                          AppStrings.signUp,
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

                                text: AppStrings.alreadyHaveAnAccount,
                                children: [
                                  TextSpan(
                                    text: AppStrings.signIn,
                                    style: TextTheme.of(context).bodyLarge
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
}
