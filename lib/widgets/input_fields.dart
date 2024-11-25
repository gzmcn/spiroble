import 'package:flutter/material.dart';

class InputFields extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final Icon icon;
  final TextInputType keyboardType;
  final bool secureTextEntry;
  final VoidCallback? onTapSuffixIcon;

  const InputFields({
    required this.controller,
    required this.placeholder,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.secureTextEntry = false,
    this.onTapSuffixIcon, 
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Color(0xFFF7F2F9),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        obscureText: secureTextEntry,
        keyboardType: keyboardType,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          prefixIcon: icon,
          hintText: placeholder,
          hintStyle: TextStyle(color: Colors.grey[600]),
          suffixIcon: onTapSuffixIcon != null
              ? IconButton(
                  icon: Icon(
                    secureTextEntry ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black,
                  ),
                  onPressed: onTapSuffixIcon,
                )
              : null,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
