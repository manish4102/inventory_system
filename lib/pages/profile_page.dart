// import 'package:flutter/material.dart';
// import 'package:inventory_system/pages/home_page.dart';
// import 'package:inventory_system/pages/notifications_page.dart';
// import 'package:curved_navigation_bar/curved_navigation_bar.dart';
// import 'package:inventory_system/pages/products_page.dart';
// import 'package:inventory_system/pages/sales_page.dart';
// //import 'package:inventory_system/utils/routes.dart' as route;


// class ProfilePage extends StatefulWidget {
//   const ProfilePage({super.key});

//   @override
//   State<ProfilePage> createState() => _ProfilePageState();
// }

// class _ProfilePageState extends State<ProfilePage> {
//   int _currentIndex = 3;

//   final List<Widget> _pages = [
//     HomePage(),
//     SalesPage(),
//     ProductsPage(),
//     ProfilePage(),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('PROFILE PAGE'),
//         centerTitle: true,
//         actions: <Widget>[
//             IconButton(
//             onPressed: () {
//               Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationsPage()));
//             }, 
//             icon: Icon(Icons.notifications),
//             ),
//         ],
//         backgroundColor: Color.fromARGB(255, 138, 99, 246),
//         leading: IconButton(
//           onPressed: () {}, 
//           icon: Icon(Icons.menu),
//           ),
//           shape: const RoundedRectangleBorder( 
//             borderRadius: BorderRadius.only( 
//             bottomLeft: Radius.circular (25),
//             bottomRight: Radius.circular (25),
//           ),
//         ),
//       ),
//       body: Center(child: Text("Profile Page"),),
//       bottomNavigationBar: CurvedNavigationBar(
//         index: _currentIndex,
//         backgroundColor: Colors.white, 
//         color: Color.fromARGB(255, 138, 99, 246), 
//         buttonBackgroundColor: Color.fromARGB(255, 138, 99, 246),
//         items: const <Widget>[
//           Icon(Icons.home, size: 30),
//           Icon(Icons.attach_money, size: 30),
//           Icon(Icons.inventory, size: 30),
//           Icon(Icons.person, size: 30),
//         ],
//         onTap: (index) {
//           setState(() {
//             _currentIndex = index;
//             Navigator.push(context, MaterialPageRoute(builder: (context) => _pages[_currentIndex]));
//           });
//         },
//       ),
//       );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:inventory_system/pages/home_page.dart';
import 'package:inventory_system/pages/notifications_page.dart';
import 'package:inventory_system/pages/products_page.dart';
import 'package:inventory_system/pages/sales_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _currentIndex = 3;
  late User? _user;

  final List<Widget> _pages = [
    HomePage(),
    SalesPage(),
    ProductsPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return CircularProgressIndicator();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('PROFILE PAGE', style: GoogleFonts.poppins(fontSize: 20, color: Colors.black),),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsPage()),
              );
            },
            icon: Icon(Icons.notifications),
          ),
        ],
        backgroundColor: Color.fromARGB(255, 112, 64, 244),
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 16.0),
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('Users').doc(_user?.uid).get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.data() == null) {
                  return Text('Error fetching user data');
                } else {
                  var userData = snapshot.data!.data() as Map<String, dynamic>;
                  return Column(
                    children: [
                      _buildEditableInfoContainer("Full Name", userData['Full Name'] ?? ""),
                      _buildEditableInfoContainer("Email", userData['Email'] ?? ""),
                      _buildEditableInfoContainer("Phone Number", userData['Phone Number']?.toString() ?? ""),
                      _buildEditableInfoContainer("Address", userData['Address'] ?? ""),
                      _buildEditableInfoContainer("Role", userData['Role'] ?? ""),
                    ],
                  );
                }
              },
            ),
          ],
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

  Widget _buildEditableInfoContainer(String label, String value) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              IconButton(
                onPressed: () {
                  _editInfo(label, value);
                },
                icon: Icon(Icons.edit),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _editInfo(String label, String currentValue) {
    TextEditingController controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $label'),
          content: TextField(
            controller: controller,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Update the backend with the new value
                await _updateBackend(label, controller.text);

                // Close the dialog
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateBackend(String label, String newValue) async {
    // Update the Firestore document with the new value
    await FirebaseFirestore.instance.collection('Users').doc(_user?.uid).update({label: newValue});
    setState(() {});
  }
}
