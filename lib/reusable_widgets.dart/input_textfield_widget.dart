import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InputTextField extends StatefulWidget {
  final String labelText;
  final TextEditingController controller;
  final bool isPasswordType;

  InputTextField({
    required this.labelText,
    required this.controller,
    this.isPasswordType = false,
  });

  @override
  _InputTextFieldState createState() => _InputTextFieldState();
}

class _InputTextFieldState extends State<InputTextField> {
  bool isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),  // Rounded border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),  // Adjusted shadow color and opacity
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
            controller: widget.controller,
            obscureText: !isPasswordVisible && widget.isPasswordType,
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
              suffixIcon: widget.isPasswordType
                  ? IconButton(
                      icon: Icon(
                        isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Color.fromARGB(255, 112, 64, 244),
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    )
                  : null,
            ),
            keyboardType: widget.isPasswordType ? TextInputType.visiblePassword : TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }
}
