import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inventory_system/pages/expenses_page.dart';
import 'package:inventory_system/pages/insights_page.dart';
import 'package:inventory_system/pages/invoice_page.dart';
import 'package:inventory_system/pages/login_page.dart';
import 'package:inventory_system/pages/notifications_page.dart';
import 'package:inventory_system/pages/products_page.dart';
import 'package:inventory_system/pages/profile_page.dart';
import 'package:inventory_system/pages/sales_page.dart';
import 'package:inventory_system/pages/sales_report_page.dart';
import 'package:inventory_system/pages/add_vendor_page.dart'; // Import your actual VendorsPage file
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    SalesPage(),
    ProductsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(''),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              FirebaseAuth.instance.signOut().then((value) {
                print("Signed Out");
                Navigator.push(context, MaterialPageRoute(builder: (context) => LogInPage()));
              });
            },
            icon: const Icon(Icons.logout),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationsPage()));
            },
            icon: const Icon(Icons.notifications),
          ),
        ],
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {},
          icon: Icon(Icons.menu),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome', style: GoogleFonts.poppins(fontSize: 30, fontWeight: FontWeight.w500, color: Color.fromARGB(255, 112, 64, 244))),
              FutureBuilder(
            future: getCurrentUserName(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Text(
                    '${snapshot.data}',
                    style: GoogleFonts.poppins(
                      color: Color.fromARGB(255, 112, 64, 244),
                      fontSize: 18,
                    ),
                  ),
                );
              } else {
                return CircularProgressIndicator();
              }
            },
          ),
          SizedBox(height: 10),
          Stack(
            alignment: Alignment.bottomCenter,
            children: [ 
              Container(
                        width: 350,
                        height: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage("lib/assets/images/dukaan_image.png"),
                          ),
                        ),
                      ),
                      Container(
                          width: 350,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Have a nice day!',
                              style:GoogleFonts.poppins(fontSize: 20, color: Colors.black),
                            )
                          )
                        ) 
                    ],
          ),
              Expanded(
  child: Container(
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: ListView(
        children: [
          InkWell(
  onTap: () {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ProductsPage()));
  },
  child: Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Image Container
        Container(
          width: 130,
          height: 130,
          margin: const EdgeInsets.only(left: 10),
          padding: const EdgeInsets.all(10),  // Padding from all sides
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            border: Border.all(
              color: Color.fromARGB(255, 112, 64, 244),  // Black border color
              width: 2,  // Border width
            ),
            image: DecorationImage(
              image: AssetImage('lib/assets/images/products.png'), // Replace with your image path
              fit: BoxFit.none,
            ),
          ),
        ),
        
        // Title
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            children: [
              Text("PRODUCTS", style: GoogleFonts.poppins(color: Color.fromARGB(255, 112, 64, 244), fontSize: 20, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    ),
  ),
),

          InkWell(
  onTap: () {
    Navigator.push(context, MaterialPageRoute(builder: (context) => SalesPage()));
  },
  child: Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Image Container
        Container(
          width: 130,
          height: 130,
          margin: const EdgeInsets.only(left: 10),
          padding: const EdgeInsets.all(10),  // Padding from all sides
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            border: Border.all(
              color: Color.fromARGB(255, 112, 64, 244),  // Black border color
              width: 2,  // Border width
            ),
            image: DecorationImage(
              image: AssetImage('lib/assets/images/sales.png'), // Replace with your image path
              fit: BoxFit.none,
            ),
          ),
        ),
        
        // Title
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            children: [
              Text("SALES", style: GoogleFonts.poppins(color: Color.fromARGB(255, 112, 64, 244), fontSize: 20, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    ),
  ),
),

          InkWell(
  onTap: () {
    Navigator.push(context, MaterialPageRoute(builder: (context) => ExpensesPage()));
  },
  child: Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Image Container
        Container(
          width: 130,
          height: 130,
          margin: const EdgeInsets.only(left: 10),
          padding: const EdgeInsets.all(10),  // Padding from all sides
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            border: Border.all(
              color: Color.fromARGB(255, 112, 64, 244),  // Black border color
              width: 2,  // Border width
            ),
            image: DecorationImage(
              image: AssetImage('lib/assets/images/expenses.png'), // Replace with your image path
              fit: BoxFit.none,
            ),
          ),
        ),
        
        // Title
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            children: [
              Text("EXPENSES", style: GoogleFonts.poppins(color: Color.fromARGB(255, 112, 64, 244), fontSize: 20, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    ),
  ),
),
          InkWell(
  onTap: () {
    Navigator.push(context, MaterialPageRoute(builder: (context) => SalesReportPage()));
  },
  child: Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Image Container
        Container(
          width: 130,
          height: 130,
          margin: const EdgeInsets.only(left: 10),
          padding: const EdgeInsets.all(10),  // Padding from all sides
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            border: Border.all(
              color: Color.fromARGB(255, 112, 64, 244),  // Black border color
              width: 2,  // Border width
            ),
            image: DecorationImage(
              image: AssetImage('lib/assets/images/sales.png'), // Replace with your image path
              fit: BoxFit.none,
            ),
          ),
        ),
        
        // Title
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            children: [
              Text("SALES REPORT", style: GoogleFonts.poppins(color: Color.fromARGB(255, 112, 64, 244), fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    ),
  ),
),
          InkWell(
  onTap: () {
    Navigator.push(context, MaterialPageRoute(builder: (context) => VendorsPage()));
  },
  child: Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Image Container
        Container(
          width: 130,
          height: 130,
          margin: const EdgeInsets.only(left: 10),
          padding: const EdgeInsets.all(10),  // Padding from all sides
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            border: Border.all(
              color: Color.fromARGB(255, 112, 64, 244),  // Black border color
              width: 2,  // Border width
            ),
            image: DecorationImage(
              image: AssetImage('lib/assets/images/sales.png'), // Replace with your image path
              fit: BoxFit.none,
            ),
          ),
        ),
        
        // Title
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            children: [
              Text("VENDORS", style: GoogleFonts.poppins(color: Color.fromARGB(255, 112, 64, 244), fontSize: 20, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    ),
  ),
),
          InkWell(
  onTap: () {
    Navigator.push(context, MaterialPageRoute(builder: (context) => InvoicePage()));
  },
  child: Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Image Container
        Container(
          width: 130,
          height: 130,
          margin: const EdgeInsets.only(left: 10),
          padding: const EdgeInsets.all(10),  // Padding from all sides
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            border: Border.all(
              color: Color.fromARGB(255, 112, 64, 244),  // Black border color
              width: 2,  // Border width
            ),
            image: DecorationImage(
              image: AssetImage('lib/assets/images/sales.png'), // Replace with your image path
              fit: BoxFit.none,
            ),
          ),
        ),
        
        // Title
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            children: [
              Text("INVOICE", style: GoogleFonts.poppins(color: Color.fromARGB(255, 112, 64, 244), fontSize: 20, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    ),
  ),
),
          InkWell(
  onTap: () {
    Navigator.push(context, MaterialPageRoute(builder: (context) => InsightsPage()));
  },
  child: Container(
    margin: const EdgeInsets.only(bottom: 10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Colors.white,
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Image Container
        Container(
          width: 130,
          height: 130,
          margin: const EdgeInsets.only(left: 10),
          padding: const EdgeInsets.all(10),  // Padding from all sides
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            border: Border.all(
              color: Color.fromARGB(255, 112, 64, 244),  // Black border color
              width: 2,  // Border width
            ),
            image: DecorationImage(
              image: AssetImage('lib/assets/images/sales.png'), // Replace with your image path
              fit: BoxFit.none,
            ),
          ),
        ),
        
        // Title
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            children: [
              Text("INSIGHTS", style: GoogleFonts.poppins(color: Color.fromARGB(255, 112, 64, 244), fontSize: 20, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    ),
  ),
),
        ],
      ),
    ),
  ),
),

            ],
          ),
        ),
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _currentIndex,
        backgroundColor: Colors.white, 
        color: Color.fromARGB(255, 112, 64, 244), 
        buttonBackgroundColor: Color.fromARGB(255, 112, 64, 244),
        items: const <Widget>[
          Icon(Icons.home, size: 30),
          Icon(Icons.currency_rupee, size: 30),
          Icon(Icons.inventory, size: 30),
          Icon(Icons.person, size: 30),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            Navigator.push(context, MaterialPageRoute(builder: (context) => _pages[_currentIndex]));
          });
        },
      ),
    );
  }
}
Future<String> getCurrentUserName() async {
    User? user = FirebaseAuth.instance.currentUser;
    String userName = '';

    if (user != null) {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          userName = documentSnapshot['Full Name'];
        }
      });
    }

    return userName;
  }



