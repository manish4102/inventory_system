import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Container signInSignUpButton (
  BuildContext context, bool isLogin, Function onTap) { 
    return Container(
      width: MediaQuery.of(context).size.width, 
      height: 50,
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: ElevatedButton (
        onPressed: () {
          onTap ();
        }, 
        child: Text(
          isLogin ? 'LOG IN' : 'SIGN UP', 
          style: GoogleFonts.poppins(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ), // TextStyle ), // Text
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains (MaterialState.pressed)) {
                  return Colors.black26;
              }
              return Color.fromARGB(255, 112, 64, 244);
            }),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder (borderRadius: BorderRadius.circular (30)))), // ButtonStyle
),
);

}