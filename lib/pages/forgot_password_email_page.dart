import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:inventory_system/pages/forgot_password_otp_page.dart';
import 'package:inventory_system/reusable_widgets.dart/textfield_widget.dart';
import 'package:inventory_system/utils/routes.dart';

class ForgotPasswordEmailPage extends StatefulWidget {
  const ForgotPasswordEmailPage({super.key});

  @override
  State<ForgotPasswordEmailPage> createState() => _ForgotPasswordEmailPageState();
}

class _ForgotPasswordEmailPageState extends State<ForgotPasswordEmailPage> {
  TextEditingController _forgotpasswordemailTextController = TextEditingController();

  Future passwordReset() async {
    var forgot_email = _forgotpasswordemailTextController.text.trim();
    try{
    await FirebaseAuth.instance.sendPasswordResetEmail(email: forgot_email).then((value) => print('Email Sent'));
    //showDialog(
        //context: context, 
        //builder: (context) {
          //return AlertDialog(
            //content: Text('Link Sent to Email'),
          //);
        //}
      //);
    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog(
        context: context, 
        builder: (context) {
          return AlertDialog(
            content: Text(e.message.toString()),
          );
        }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.1, 20, 0),
          child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
                Icon(
                  Icons.email_outlined,
                  size: 150, 
                  color: Colors.black,
                ),
                SizedBox(height: 18),
                Text('Forgot Password,', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,color: Colors.black),),
                Text('Enter your email', style: TextStyle(fontSize: 18, color: Colors.black)),
                SizedBox(height: 40),
                reusableTextField('Enter Email', Icons.email, false, _forgotpasswordemailTextController),
                SizedBox(height: 20,),
                Container(
      width: MediaQuery.of(context).size.width, 
      height: 50,
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: ElevatedButton (
        onPressed: () => passwordReset(),
          //Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordOTPPage()));
        
        child: Text("RESET PASSWORD",
          style: const TextStyle(
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
                RoundedRectangleBorder (borderRadius: BorderRadius.circular (8)))), // ButtonStyle
),
),
            ]))
          )
      )
    );
  }
}