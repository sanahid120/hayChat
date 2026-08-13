import 'package:flutter/material.dart';
import 'package:hay_chat/app/asset_paths.dart';
import 'package:hay_chat/auth/presentation/screens/sign_in_screen.dart';

import '../../../app/app_colors.dart';
import '../../../app/app_strings.dart';
import '../../../shared/utils/validators.dart';
import '../widgets/input_field_widget.dart';

class ForgetPasswordScreen extends StatelessWidget {
  ForgetPasswordScreen({super.key});

  static const String routeName = '/forget-password';

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

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
                  AppStrings.forgotPassword,

                  style: TextTheme.of(
                    context,
                  ).headlineLarge?.copyWith(color: AppColors.textPrimary),
                ),

                Text(
                  AppStrings.forgotPasswordDescription,
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

                      SizedBox(height: 20),

                      FilledButton(
                        onPressed: () {},
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primaryDark,
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          AppStrings.resetButton,
                          style: TextTheme.of(
                            context,
                          ).bodyLarge?.copyWith(color: AppColors.textPrimary),
                        ),
                      ),
                      SizedBox(height: 20),

                      Align(
                        alignment: Alignment.center,

                        child: TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                              context,
                              SignInScreen.routeName,
                            );
                          },
                          child: Text(
                            'Remember Password?',
                            style: TextTheme.of(
                              context,
                            ).bodyLarge?.copyWith(color: AppColors.primary),
                          ),
                        ),
                      ),
                      SizedBox(height: 20,),
                      Image.asset(AssetPaths.illustration4),
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
