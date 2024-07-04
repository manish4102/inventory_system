import 'package:flutter/material.dart';
import 'package:inventory_system/pages/login_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  changeScreen()
  {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.push (context,
              MaterialPageRoute(builder: (context) => LogInPage())) ;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    changeScreen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/assets/images/Splash_Screen_1.png'), // Replace with your image path
                fit: BoxFit.cover,
              ),
            ),
          )]));
  }
}