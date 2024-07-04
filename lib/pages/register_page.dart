// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:inventory_system/pages/login_page.dart';
// import 'package:inventory_system/reusable_widgets.dart/button_widget.dart';
// import 'package:inventory_system/reusable_widgets.dart/email_textfield_widet.dart';
// import 'package:inventory_system/reusable_widgets.dart/input_textfield_widget.dart';
// import 'package:inventory_system/reusable_widgets.dart/textfield_widget.dart';

// class RegisterPage extends StatefulWidget {
//   const RegisterPage({Key? key}) : super(key: key);

//   @override
//   State<RegisterPage> createState() => _RegisterPageState();
// }

// class _RegisterPageState extends State<RegisterPage> {
//   TextEditingController _passwordTextController = TextEditingController();
//   TextEditingController _confirmpasswordTextController = TextEditingController();
//   TextEditingController _emailTextController = TextEditingController();
//   TextEditingController _fullnameTextController = TextEditingController();
//   TextEditingController _phonenumberTextController = TextEditingController();
//   TextEditingController _addressTextController = TextEditingController();
//   String? _selectedType;

//   final List<String> _dropdownValues = ["Kirana Store", "Medical", ];

//   bool passwordConfirmed() {
//     return _passwordTextController.text == _confirmpasswordTextController.text;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           Positioned(
//             top: 0,
//             left: 0,
//             child: Container(
//               width: MediaQuery.of(context).size.width,
//               height: MediaQuery.of(context).size.height,
//               decoration: BoxDecoration(
//                 image: DecorationImage(
//                   image: const AssetImage('lib/assets/images/login_background.png'),
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//           ),
//           Center(
//         child: Padding(
//           padding: EdgeInsets.fromLTRB(
//               20, MediaQuery.of(context).size.height * 0.05, 20, 0),
//           child: SingleChildScrollView(
//             child: Column(
//               children: <Widget>[
//                 Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Container(
//                           margin: EdgeInsets.only(left: 16.0),
//                           padding: EdgeInsets.all(12.0),
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: Colors.white,
//                           ),
//                           child: InkWell(
//   onTap: () {
//     Navigator.pop(context);  // This will navigate back to the previous page
//   },
//   child: Icon(
//     Icons.arrow_back,
//     size: 15,
//     color: Color.fromARGB(255, 112, 64, 244),
//   ),
// ),
//                         ),
//                         Container(
//                           margin: EdgeInsets.only(left: 16.0),
//                           padding: EdgeInsets.all(12.0),
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: Colors.white,
//                           ),
//                           child: Icon(
//                             Icons.translate,
//                             size: 15,
//                             color: Color.fromARGB(255, 112, 64, 244),
//                           ),
//                         ),
//                       ],
//                     ),
//                 SizedBox(height: 8),
//                 Row(
//                       children: [
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             SizedBox(height: 18),
//                             Text('Create', style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.w500, color: Colors.white)),
//                             Text('Account', style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.w500, color: Colors.white)),
//                             Text('Please sign up to continue.', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white)),
//                           ],
//                         )
//                       ],
//                     ),
//                 SizedBox(height: 28),
//                 InputTextField(
//                     labelText: 'Enter Full Name',
//                     isPasswordType: false,
//                     controller: _fullnameTextController),
//                 SizedBox(height: 10),
//                 emailReusableTextField(
//                     'Enter Email', false, _emailTextController),
//                 SizedBox(height: 10),
//                 InputTextField(labelText: 'Enter Phone Number',
//                     isPasswordType: false, controller: _phonenumberTextController),
//                 SizedBox(height: 10),
//                 InputTextField(
//                     labelText: 'Enter Password',
//                     isPasswordType: true,
//                     controller: _passwordTextController),
//                 SizedBox(height: 10),
//                 InputTextField(labelText: 'Confirm Password', isPasswordType: true,
//                     controller: _confirmpasswordTextController),
//                 SizedBox(height: 10),
//                 InputTextField(
//                     labelText: 'Enter Address',
//                     isPasswordType: false,
//                     controller: _addressTextController),
//                 SizedBox(height: 15),
//                 buildDropdownMenu(),
//                 SizedBox(height: 15),
//                 signInSignUpButton(context, false, () async {
//                   if (passwordConfirmed()) {
//                     try {
//                       final UserCredential userCredential =
//                           await FirebaseAuth.instance
//                               .createUserWithEmailAndPassword(
//                         email: _emailTextController.text,
//                         password: _passwordTextController.text,
//                       );

//                       final User? user = userCredential.user;

//                       if (user != null) {
//                         final String userId = user.uid;

//                         CollectionReference usersCollection =
//                             FirebaseFirestore.instance.collection('Users');

//                         // Convert phone number to integer
//                         int phoneNumber = int.tryParse(
//                             _phonenumberTextController.text) ?? 0;

//                         await usersCollection.doc(userId).set({
//                           'Full Name': _fullnameTextController.text.trim(),
//                           'Email': _emailTextController.text.trim(),
//                           'Phone Number': phoneNumber,
//                           'Password': _passwordTextController.text.trim(),
//                           'Address': _addressTextController.text.trim(),
//                           'Role': _selectedType,
//                         });

//                         print('Created New Account!!');
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => LogInPage()),
//                         );
//                       }
//                     } catch (error) {
//                       print('Error: $error');
//                     }
//                   }
//                 }),
//                 SizedBox(height: 10),
//                 Text ("Or signup with",
//                       style: GoogleFonts.poppins(color: Colors.black.withOpacity(0.6))),
//                     SizedBox(height: 5,),
//                     Container(
//                       height: 40.0,
//                       width: 40.0,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.2),
//                             spreadRadius: 2,
//                             blurRadius: 4,
//                             offset: Offset(0, 2), // changes position of shadow
//                           ),
//                         ],
//                       ),
//                       child: ClipOval(
//                         child: Padding(
//                           padding: EdgeInsets.all(0.0),
//                           child: Image.asset(
//                             'lib/assets/images/google_logo_image.jpeg', // Replace with your image path
//                             height: 24.0,
//                             width: 24.0,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 20),
//                 signInOption(),
//                 SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     ]));
//   }

//   Row signInOption() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Text(
//           "Already have an account?",
//           style: GoogleFonts.poppins(color: Colors.black.withOpacity(0.6)),
//         ),
//         GestureDetector(
//           onTap: () {
//             Navigator.pop(
//                 context,
//                 MaterialPageRoute(
//                     builder: (context) => LogInPage()));
//           },
//           child: Text(
//             " Log In",
//             style: GoogleFonts.poppins(
//                 color: Color.fromARGB(255, 112, 64, 244), fontWeight: FontWeight.w500),
//           ),
//         )
//       ],
//     );
//   }

//   Widget buildDropdownMenu() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16.0),
//           child: Text(
//             'Use For',
//             style: GoogleFonts.poppins(color: Colors.black.withOpacity(0.6)),
//           ),
//         ),
//         Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(8.0),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16.0),
//             child: DropdownButton<String>(
//               isExpanded: true,
//               value: _selectedType,
//               onChanged: (String? newValue) {
//                 setState(() {
//                   _selectedType = newValue;
//                 });
//               },
//               items: _dropdownValues.map((String value) {
//                 return DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(value, style: GoogleFonts.poppins(color: Colors.black.withOpacity(0.6)),),
//                 );
//               }).toList(),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inventory_system/pages/login_page.dart';
import 'package:inventory_system/reusable_widgets.dart/button_widget.dart';
import 'package:inventory_system/reusable_widgets.dart/email_textfield_widet.dart';
import 'package:inventory_system/reusable_widgets.dart/input_textfield_widget.dart';
import 'package:inventory_system/reusable_widgets.dart/textfield_widget.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _confirmpasswordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _fullnameTextController = TextEditingController();
  TextEditingController _phonenumberTextController = TextEditingController();
  TextEditingController _addressTextController = TextEditingController();
  String? _selectedType;

  final List<String> _dropdownValues = ["Kirana Store", "Medical"];

  bool passwordConfirmed() {
    return _passwordTextController.text == _confirmpasswordTextController.text;
  }

  Future<void> registerUser() async {
    if (passwordConfirmed()) {
      try {
        final UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailTextController.text,
          password: _passwordTextController.text,
        );

        final User? user = userCredential.user;

        if (user != null) {
          final String userId = user.uid;

          CollectionReference usersCollection =
              FirebaseFirestore.instance.collection('Users');

          // Convert phone number to integer
          int phoneNumber =
              int.tryParse(_phonenumberTextController.text) ?? 0;

          await usersCollection.doc(userId).set({
            'Full Name': _fullnameTextController.text.trim(),
            'Email': _emailTextController.text.trim(),
            'Phone Number': phoneNumber,
            'Password': _passwordTextController.text.trim(),
            'Address': _addressTextController.text.trim(),
            'Role': _selectedType,
          });

          print('Created New Account!!');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LogInPage()),
          );
        }
      } catch (error) {
        String errorMessage = 'An error occurred';
        if (error is FirebaseAuthException) {
          switch (error.code) {
            case 'weak-password':
              errorMessage = 'The password provided is too weak.';
              break;
            case 'email-already-in-use':
              errorMessage = 'The account already exists for that email.';
              break;
            case 'invalid-email':
              errorMessage = 'The email address is not valid.';
              break;
            default:
              errorMessage = error.message ?? 'An error occurred';
          }
        }
        // Show dialog with error message
        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              title: Center(
                                child: Text(
                                  'Registration Failed',
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
      }
    }
  }

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
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  20, MediaQuery.of(context).size.height * 0.05, 20, 0),
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 16.0),
                          padding: EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.pop(context);  // This will navigate back to the previous page
                            },
                            child: Icon(
                              Icons.arrow_back,
                              size: 15,
                              color: Color.fromARGB(255, 112, 64, 244),
                            ),
                          ),
                        ),
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
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 18),
                            Text('Create', style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.w500, color: Colors.white)),
                            Text('Account', style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.w500, color: Colors.white)),
                            Text('Please sign up to continue.', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white)),
                          ],
                        )
                      ],
                    ),
                    SizedBox(height: 28),
                    InputTextField(
                        labelText: 'Enter Full Name',
                        isPasswordType: false,
                        controller: _fullnameTextController),
                    SizedBox(height: 10),
                    emailReusableTextField(
                        'Enter Email', false, _emailTextController),
                    SizedBox(height: 10),
                    InputTextField(labelText: 'Enter Phone Number',
                        isPasswordType: false, controller: _phonenumberTextController),
                    SizedBox(height: 10),
                    InputTextField(
                        labelText: 'Enter Password',
                        isPasswordType: true,
                        controller: _passwordTextController),
                    SizedBox(height: 10),
                    InputTextField(labelText: 'Confirm Password', isPasswordType: true,
                        controller: _confirmpasswordTextController),
                    SizedBox(height: 10),
                    InputTextField(
                        labelText: 'Enter Address',
                        isPasswordType: false,
                        controller: _addressTextController),
                    SizedBox(height: 15),
                    buildDropdownMenu(),
                    SizedBox(height: 15),
                    signInSignUpButton(context, false, () async {
                      await registerUser();
                    }),
                    SizedBox(height: 10),
                    Text ("Or signup with",
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
                    signInOption(),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Row signInOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account?",
          style: GoogleFonts.poppins(color: Colors.black.withOpacity(0.6)),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pop(
                context,
                MaterialPageRoute(
                    builder: (context) => LogInPage()));
          },
          child: Text(
            " Log In",
            style: GoogleFonts.poppins(
                color: Color.fromARGB(255, 112, 64, 244), fontWeight: FontWeight.w500),
          ),
        )
      ],
    );
  }

  Widget buildDropdownMenu() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Use For',
            style: GoogleFonts.poppins(color: Colors.black.withOpacity(0.6)),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedType,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedType = newValue;
                });
              },
              items: _dropdownValues.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: GoogleFonts.poppins(color: Colors.black.withOpacity(0.6)),),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
