import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String selectedVendor = ''; // Initialize the selectedVendor variable

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NOTIFICATIONS', style: GoogleFonts.poppins(fontSize: 20, color: Colors.black),),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 112, 64, 244),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
        ),
      ),
      body: _buildLowQuantityProductsList(),
    );
  }

  Widget _buildLowQuantityProductsList() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      final String userId = user.uid;
      final userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);
      final productsCollection = userDocRef.collection('Products');

      return StreamBuilder<QuerySnapshot>(
        stream: productsCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final products = snapshot.data?.docs ?? [];

          final lowQuantityProducts = products
              .where((product) => (product['quantity'] as int) < 4)
              .toList();

          if (lowQuantityProducts.isEmpty) {
            return Center(
              child: Text('No products with quantity below 4.'),
            );
          }

          return Container(
            padding: EdgeInsets.all(16.0),
            constraints: BoxConstraints.expand(width: MediaQuery.of(context).size.width),
            color: Colors.grey[200],
            child: ListView.builder(
              itemCount: lowQuantityProducts.length,
              itemBuilder: (context, index) {
                final product = lowQuantityProducts[index];
                final quantity = product['quantity'] as int;
                final productName = product['product'] as String;

                return Card(
                  elevation: 5.0,
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  color: Color.fromARGB(255, 138, 99, 246),
                  child: ListTile(
                    title: Text('$productName - Quantity: $quantity', style: TextStyle(color: Colors.white)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.black),
                          onPressed: () {
                            deleteNotification(product);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.message, color: Colors.black),
                          onPressed: () {
                            // When the user clicks on the message icon, show the alert dialog
                            showAlertDialog(context, product);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.phone, color: Colors.black),
                          onPressed: () {
                            // When the user clicks on the phone icon, show the call vendor dialog
                            showCallVendorDialog(context, product);
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      );
    }
    return Center(
      child: Text('User not logged in.'),
    );
  }

  void deleteNotification(DocumentSnapshot product) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      final String userId = user.uid;
      final userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);
      final productsCollection = userDocRef.collection('Products');

      await productsCollection.doc(product.id).delete();

      // After deleting, refresh the UI or do any necessary updates
      setState(() {});
    }
  }

  void showAlertDialog(BuildContext context, DocumentSnapshot product) {
    final TextEditingController quantityController = TextEditingController();
    String selectedVendor = ''; // Initialize selectedVendor here

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Send Message'),
              content: SingleChildScrollView(
                child: Container(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: 'Product Quantity'),
                      ),
                      SizedBox(height: 16.0),
                      FutureBuilder<List<String>>(
                        future: getVendorsForProduct(product['product'] as String),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }

                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }

                          final vendors = snapshot.data ?? [];

                          return Container(
                            height: 200,
                            child: ListView.builder(
                              itemCount: vendors.length,
                              itemBuilder: (context, index) {
                                final vendor = vendors[index];
                                return ListTile(
                                  title: Text(vendor),
                                  leading: Radio(
                                    value: vendor,
                                    groupValue: selectedVendor,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedVendor = value as String;
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    // Call a function to send the message
                    sendMessage(product, int.tryParse(quantityController.text) ?? 0, selectedVendor);
                    Navigator.of(context).pop();
                  },
                  child: Text('Send Message'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<List<String>> getVendorsForProduct(String productName) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      final String userId = user.uid;
      final userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);
      final vendorsCollection = userDocRef.collection('Vendors');

      try {
        final querySnapshot = await vendorsCollection.where('product', isEqualTo: productName).get();

        List<String> uniqueVendors = [];
        querySnapshot.docs.forEach((doc) {
          String vendorName = doc['name'];
          if (!uniqueVendors.contains(vendorName)) {
            uniqueVendors.add(vendorName);
          }
        });

        return uniqueVendors;
      } catch (error) {
        print('Error fetching vendors: $error');
        return [];
      }
    }

    return [];
  }

  void sendMessage(DocumentSnapshot product, int quantity, String selectedVendor) async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User? user = auth.currentUser;

      if (user != null) {
        final String userId = user.uid;
        final userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);
        final vendorsCollection = userDocRef.collection('Vendors');
        final usersCollection = FirebaseFirestore.instance.collection('Users');

        // Fetch sender's phone number and address from Users collection
        final userSnapshot = await usersCollection.doc(userId).get();
        final int senderPhoneNumber = userSnapshot['Phone Number'] as int? ?? 0;
        final String senderAddress = userSnapshot['Address'] as String? ?? '';

        // Print sender's phone number and address
        print('Sender Phone Number: $senderPhoneNumber');
        print('Sender Address: $senderAddress');

        // Fetch vendor document with similar vendor names
        final vendorSnapshot = await vendorsCollection
            .where('name', isEqualTo: selectedVendor)
            .limit(1)
            .get();

        if (vendorSnapshot.docs.isNotEmpty) {
          final vendorDocument = vendorSnapshot.docs.first;
          final int receiverPhoneNumber = vendorDocument['phoneNumber'] as int? ?? 0;

          // Print receiver's phone number
          print('Receiver Phone Number: $receiverPhoneNumber');

          // Check if the 'product' field exists in the vendor document
          if (vendorDocument['product'] != null) {
            final String productName = vendorDocument['product'] as String? ?? '';

            // Print the message with the quantity, address, and product name from the alert box
            final String message =
                'Product: $productName, Quantity: $quantity, Address: $senderAddress';

            print('Message: $message');

            // Open default messaging app
            final Uri uri = Uri(
              scheme: 'sms',
              path: '$receiverPhoneNumber',
              queryParameters: {'body': message},
            );

            if (await canLaunch(uri.toString())) {
              await launch(uri.toString());
            } else {
              print('Could not launch messaging app.');
            }
          } else {
            print('Product field is missing or null in the vendor document.');
          }
        } else {
          print('Vendor document not found for the selected vendor name: $selectedVendor');
        }
      }
    } catch (e) {
      print('Error in sendMessage: $e');
    }
  }

  void showCallVendorDialog(BuildContext context, DocumentSnapshot product) {
    final TextEditingController quantityController = TextEditingController();
    String selectedVendor = ''; // Initialize selectedVendor here

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Call Vendor'),
              content: SingleChildScrollView(
                child: Container(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<List<String>>(
                        future: getVendorsForProduct(product['product'] as String),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }

                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }

                          final vendors = snapshot.data ?? [];

                          return Container(
                            height: 200,
                            child: ListView.builder(
                              itemCount: vendors.length,
                              itemBuilder: (context, index) {
                                final vendor = vendors[index];
                                return ListTile(
                                  title: Text(vendor),
                                  leading: Radio(
                                    value: vendor,
                                    groupValue: selectedVendor,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedVendor = value as String;
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    // Call a function to call the vendor
                    callVendor(product, selectedVendor);
                    Navigator.of(context).pop();
                  },
                  child: Text('Call Vendor'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void callVendor(DocumentSnapshot product, String selectedVendor) async {
    try {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User? user = auth.currentUser;

      if (user != null) {
        final String userId = user.uid;
        final userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);
        final vendorsCollection = userDocRef.collection('Vendors');
        final usersCollection = FirebaseFirestore.instance.collection('Users');

        // Fetch sender's phone number and address from Users collection
        final userSnapshot = await usersCollection.doc(userId).get();
        final int senderPhoneNumber = userSnapshot['Phone Number'] as int? ?? 0;
        final String senderAddress = userSnapshot['Address'] as String? ?? '';

        // Print sender's phone number and address
        print('Sender Phone Number: $senderPhoneNumber');
        print('Sender Address: $senderAddress');

        // Fetch vendor document with similar vendor names
        final vendorSnapshot = await vendorsCollection
            .where('name', isEqualTo: selectedVendor)
            .limit(1)
            .get();

        if (vendorSnapshot.docs.isNotEmpty) {
          final vendorDocument = vendorSnapshot.docs.first;
          final int receiverPhoneNumber = vendorDocument['phoneNumber'] as int? ?? 0;

          // Print receiver's phone number
          print('Receiver Phone Number: $receiverPhoneNumber');

          // Check if the 'product' field exists in the vendor document
          if (vendorDocument['product'] != null) {
            // Example: Open default calling app
            final Uri uri = Uri(scheme: 'tel', path: '$receiverPhoneNumber');

            if (await canLaunch(uri.toString())) {
              await launch(uri.toString());
            } else {
              print('Could not launch calling app.');
            }
          } else {
            print('Product field is missing or null in the vendor document.');
          }
        } else {
          print('Vendor document not found for the selected vendor name: $selectedVendor');
        }
      }
    } catch (e) {
      print('Error in callVendor: $e');
    }
  }
}

