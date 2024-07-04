import 'package:flutter/material.dart';

TextField reusableTextField(String text, IconData icon, bool isPasswordType,
    TextEditingController controller) {
      return TextField( 
      controller: controller,
      obscureText: isPasswordType,
      enableSuggestions: !isPasswordType, 
      autocorrect: !isPasswordType,
      cursorColor: Colors.black,
      style: TextStyle(color: Colors.black.withOpacity (0.9)),
      decoration: InputDecoration (
        prefixIcon: Icon(
          icon,
          color: Colors.black,
        ),
      labelText: text, 
      labelStyle: TextStyle(color: Colors.black26,), 
      filled: true, 
      floatingLabelBehavior: FloatingLabelBehavior.never, 
      fillColor: Colors.white,
      border: OutlineInputBorder (
      borderRadius: BorderRadius. circular (8.0), 
      borderSide: const BorderSide (width: 0, style: BorderStyle.solid)
      ),), // OutlineInputBorder ), // InputDecoration
      keyboardType: isPasswordType 
      ? TextInputType.visiblePassword
      : TextInputType.emailAddress,
      );
}
