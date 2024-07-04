import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

class ForgotPasswordOTPPage extends StatefulWidget {
  const ForgotPasswordOTPPage({super.key});

  @override
  State<ForgotPasswordOTPPage> createState() => _ForgotPasswordOTPPageState();
}

class _ForgotPasswordOTPPageState extends State<ForgotPasswordOTPPage> {
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
                  Icons.numbers_sharp,
                  size: 150, 
                  color: Colors.black,
                ),
                SizedBox(height: 18),
                Text('OTP', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,color: Colors.black),),
                Text('Enter the code', style: TextStyle(fontSize: 18, color: Colors.black)),
                SizedBox(height: 28),
                OtpTextField(
                  numberOfFields: 6,
                  filled: true,
                  fillColor: Colors.black26,
                  onSubmit: (code) => {print("The OTP is => $code"),},
                ),
                SizedBox(height: 18),
                Container(
      width: MediaQuery.of(context).size.width, 
      height: 50,
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: ElevatedButton (
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordOTPPage()));
        }, 
        child: Text("NEXT",
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
                RoundedRectangleBorder (borderRadius: BorderRadius.circular (8)))))),
            ],
          ),
        ),
      ),),
    );
  }
}