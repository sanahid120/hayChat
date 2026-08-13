import 'package:flutter/material.dart';

import '../../../app/app_colors.dart';

class InputField extends StatelessWidget {
  const InputField({
    super.key,
    required this.controller,
    this.label,
    required this.hintText,
    this.validator,
    this.icon,
  });

  final TextEditingController controller;
  final String? label;
  final String hintText;
  final String? Function(String?)? validator;
  final IconData? icon;


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(label??"",style: TextTheme.of(
          context,
        ).bodyLarge?.copyWith(color: AppColors.textHint),),
        TextFormField(

          validator: validator,
          keyboardType: TextInputType.emailAddress,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: TextStyle(color: AppColors.textSecondary),

          controller: controller,
          decoration: InputDecoration(
            fillColor: AppColors.inputBackground,
            prefixIcon: Icon(
              icon,
              color: AppColors.primary,
            ),
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 16,

              color: AppColors.textHint,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.border),
            ),
          ),

        )
      ],
    );
  }
}
