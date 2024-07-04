import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inventory_system/pages/forgot_password_email_page.dart';
import 'package:inventory_system/pages/forgot_password_phone_number_page.dart';
import 'package:inventory_system/pages/home_page.dart';
import 'package:inventory_system/pages/register_page.dart';
import 'package:inventory_system/reusable_widgets.dart/button_widget.dart';
import 'package:inventory_system/reusable_widgets.dart/email_textfield_widet.dart';
import 'package:inventory_system/reusable_widgets.dart/input_textfield_widget.dart';
import 'package:inventory_system/reusable_widgets.dart/textfield_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

late String user_doc_id_login;

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});

  @override
  State<LogInPage> createState() => _LogInPageState();
}

class _LogInPageState extends State<LogInPage> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage('lib/assets/images/login_background.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.05, 20, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 16.0),
                          padding: EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Icon(
                            Icons.translate,
                            size: 15,
                            color: Color.fromARGB(255, 112, 64, 244),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 18),
                            Text('Welcome', style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.w500, color: Colors.white)),
                            Text('Back,', style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.w500, color: Colors.white)),
                            Text('Please sign in to continue.', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white)),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 100),
                    emailReusableTextField('Enter Email', false, _emailTextController),
                    SizedBox(height: 20),
                    InputTextField(labelText: 'Enter Password', isPasswordType: true, controller: _passwordTextController),
                    Align(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                            builder: (context) => Container(
                              padding: EdgeInsets.fromLTRB(10, MediaQuery.of(context).size.height * 0.05, 10, 0),
                              child: Column(
                                children: [
                                  Text('Get Help!', style: GoogleFonts.poppins(fontSize: 25, fontWeight: FontWeight.bold)),
                                  Text('Select one of the options to reset your password', style: GoogleFonts.poppins(fontSize: 12)),
                                  const SizedBox(height: 40),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordEmailPage()));
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Color.fromARGB(255, 95, 45, 233),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.email_outlined, size: 60, color: Colors.white,),
                                          SizedBox(width: 10,),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('E-mail', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                                              Text('Reset password via E-mail', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 30),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordPhoneNumberPage()));
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: Color.fromARGB(255, 112, 64, 244),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.phone_android_rounded, size: 60, color: Colors.white,),
                                          SizedBox(width: 10,),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('Phone Number', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                                              Text('Reset password via Phone Number', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Text('Forgot Password?', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.black.withOpacity(0.6))),
                      ),
                    ),
                    SizedBox(height: 5),
                    signInSignUpButton(context, true, () {
                      FirebaseAuth.instance.signInWithEmailAndPassword(
                        email: _emailTextController.text, 
                        password: _passwordTextController.text,
                      ).then((value) async {
                        final User? user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          final String userId = user.uid;
                          user_doc_id_login = userId;
                          print('User ID: $userId'); 
                          Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                        }
                      }).catchError((error) {
                        print('Sign-in Error: $error');
                        String errorMessage = 'The email or mobile number or password is incorrect.';
                        
                        if (error.toString().contains('wrong-password')) {
                          errorMessage = 'The password is incorrect.';
                        } else if (error.toString().contains('user-not-found')) {
                          errorMessage = 'The email or mobile number is incorrect.';
                        }
                        
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              title: Center(
                                child: Text(
                                  'Incorrect Credentials',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    errorMessage,
                                    style: GoogleFonts.poppins(
                                      color: Colors.black,
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(0.0, 10.0, 2.0, 0.0),
                                    child: Divider(
                                      color: Colors.grey,
                                      thickness: 1.0,
                                    ),
                                  ),
                                  Center(
                                    child: TextButton(
                                      child: Text(
                                        'OK',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(255, 112, 64, 244),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop(); // Close the dialog
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      });
                    }),
                    Text ("Or login with",
                      style: GoogleFonts.poppins(color: Colors.black.withOpacity(0.6))),
                    SizedBox(height: 5,),
                    Container(
                      height: 40.0,
                      width: 40.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 4,
                            offset: Offset(0, 2), // changes position of shadow
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Padding(
                          padding: EdgeInsets.all(0.0),
                          child: Image.asset(
                            'lib/assets/images/google_logo_image.jpeg', // Replace with your image path
                            height: 24.0,
                            width: 24.0,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    signUpOption(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Row signUpOption () {
    return Row( 
      mainAxisAlignment: MainAxisAlignment.center, 
      children: [
        Text ("Don't have an account?",
          style: GoogleFonts.poppins(color: Colors.black.withOpacity(0.6))), // Text 
        GestureDetector(
          onTap: () {
            Navigator.push (context,
              MaterialPageRoute(builder: (context) => RegisterPage())) ;
          },
          child: Text(
            " Signup",
            style: GoogleFonts.poppins(color: Color.fromARGB(255, 112, 64, 244), fontWeight: FontWeight.w500),
          ),
        )
      ]
    );
  }
}
