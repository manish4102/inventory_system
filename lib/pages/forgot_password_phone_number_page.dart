import 'package:flutter/material.dart';
import 'package:inventory_system/reusable_widgets.dart/textfield_widget.dart';

class ForgotPasswordPhoneNumberPage extends StatefulWidget {
  const ForgotPasswordPhoneNumberPage({super.key});

  @override
  State<ForgotPasswordPhoneNumberPage> createState() => _ForgotPasswordPhoneNumberPageState();
}

class _ForgotPasswordPhoneNumberPageState extends State<ForgotPasswordPhoneNumberPage> {
  TextEditingController _forgotpasswordphonenumberTextController = TextEditingController();

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
                  Icons.phone_sharp,
                  size: 150, 
                  color: Colors.black,
                ),
                SizedBox(height: 18),
                Text('Forgot Password,', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold,color: Colors.black),),
                Text('Enter your phone number', style: TextStyle(fontSize: 18, color: Colors.black)),
                SizedBox(height: 40),
                reusableTextField('Enter Phone Number', Icons.phone_android_sharp, false, _forgotpasswordphonenumberTextController),
                SizedBox(height: 20,),
                Container(
      width: MediaQuery.of(context).size.width, 
      height: 50,
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: ElevatedButton (
        onPressed: () {}, 
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
                RoundedRectangleBorder (borderRadius: BorderRadius.circular (8)))), // ButtonStyle
),
),
            ]))
          )
      )
    );
  }
}