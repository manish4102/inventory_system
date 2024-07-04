import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmailTextField extends StatefulWidget {
  final String labelText;
  final TextEditingController controller;
  final bool isPasswordType;

  EmailTextField({
    required this.labelText,
    required this.controller,
    this.isPasswordType = false,
  });

  @override
  _EmailTextFieldState createState() => _EmailTextFieldState();
}

class _EmailTextFieldState extends State<EmailTextField> {
  FocusNode focusNode = FocusNode();
  bool isEmailValid = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
            child: Text(
              widget.labelText,
              style: GoogleFonts.poppins(
                color: Colors.black.withOpacity(0.6),
                fontSize: 12,
              ),
            ),
          ),
          SizedBox(height: 5),
          TextField(
            focusNode: focusNode,
            controller: widget.controller,
            obscureText: widget.isPasswordType,
            enableSuggestions: !widget.isPasswordType,
            autocorrect: !widget.isPasswordType,
            cursorColor: Colors.black.withOpacity(0.6),
            style: GoogleFonts.poppins(color: Colors.black.withOpacity(0.9), fontSize: 14),
            decoration: InputDecoration(
              floatingLabelBehavior: FloatingLabelBehavior.always,
              contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              border: InputBorder.none,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.white),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.white),
              ),
              hintText: '',
              hintStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
              suffixIcon: (focusNode.hasFocus && widget.controller.text.isNotEmpty)
                  ? (isEmailValid
                      ? Icon(Icons.check_circle, color: Colors.green)
                      : Icon(Icons.cancel, color: Colors.red))
                  : null,
            ),
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) {
              bool isValid = RegExp(
                r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$",
              ).hasMatch(value);
              if (value.isNotEmpty) {
                focusNode.requestFocus();
              }
              setState(() {
                isEmailValid = isValid;
              });
            },
          ),
        ],
      ),
    );
  }
}

Widget emailReusableTextField(String labelText, bool isPasswordType, TextEditingController controller) {
  return EmailTextField(
    labelText: labelText,
    controller: controller,
    isPasswordType: isPasswordType,
  );
}
