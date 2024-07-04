// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class VendorsPage extends StatefulWidget {
//   const VendorsPage({Key? key}) : super(key: key);

//   @override
//   State<VendorsPage> createState() => _VendorsPageState();
// }

// class _VendorsPageState extends State<VendorsPage> {
//   late List<QueryDocumentSnapshot<Map<String, dynamic>>> documents;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('VENDORS'),
//         centerTitle: true,
//         backgroundColor: Color.fromARGB(255, 138, 99, 246),
//         actions: <Widget>[
//           IconButton(
//             onPressed: () {
//               showAddVendorDialog();
//             },
//             icon: Icon(Icons.add_sharp),
//           ),
//         ],
//       ),
//       body: StreamBuilder(
//         stream: getCurrentUserVendors(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return Center(
//               child: CircularProgressIndicator(),
//             );
//           }

//           documents = snapshot.data!.docs.cast<QueryDocumentSnapshot<Map<String, dynamic>>>();

//           return ListView.builder(
//             itemCount: documents.length,
//             itemBuilder: (context, index) {
//               final vendorDocument = documents[index].data() as Map<String, dynamic>;

//               final vendorName = vendorDocument['name'] ?? '';
//               final phoneNumber = vendorDocument['phoneNumber']?.toString() ?? '';
//               final productSold = vendorDocument['product'] ?? '';

//               return Padding(
//                 padding: EdgeInsets.all(8.0),
//                 child: Card(
//                   color: Color.fromARGB(255, 138, 99, 246),
//                   child: ListTile(
//                     title: Text('Vendor Name: $vendorName', style: TextStyle(color: Colors.white)),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('Phone Number: $phoneNumber', style: TextStyle(color: Colors.white)),
//                         Text('Product Sold: $productSold', style: TextStyle(color: Colors.white)),
//                       ],
//                     ),
//                     trailing: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         IconButton(
//                           icon: Icon(Icons.edit, color: Colors.black),
//                           onPressed: () {
//                             showEditVendorDialog(
//                               vendorName: vendorName,
//                               phoneNumber: int.tryParse(phoneNumber) ?? 0,
//                               product: productSold,
//                               documentReference: documents[index].reference,
//                             );
//                           },
//                         ),
//                         IconButton(
//                           icon: Icon(Icons.delete, color: Colors.black),
//                           onPressed: () {
//                             deleteVendor(documents[index].reference);
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   Stream<QuerySnapshot> getCurrentUserVendors() {
//     final FirebaseAuth auth = FirebaseAuth.instance;
//     final User? user = auth.currentUser;

//     if (user != null) {
//       final String userId = user.uid;
//       final userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);
      
//       // Access the 'Vendors' collection inside the user's document
//       final vendorsCollection = userDocRef.collection('Vendors');

//       return vendorsCollection.snapshots();
//     }

//     return Stream<QuerySnapshot>.empty();
//   }

//   Future<void> addVendorToFirestore(String vendorName, int phoneNumber, String product) async {
//     final User? user = FirebaseAuth.instance.currentUser;

//     if (user != null) {
//       final String userId = user.uid;
//       final userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);
      
//       // Create a new collection 'Vendors' inside the user's document
//       final vendorsCollection = userDocRef.collection('Vendors');

//       await vendorsCollection.add({
//         'name': vendorName,
//         'phoneNumber': phoneNumber,
//         'product': product,
//       });

//       print('Vendor added to Firestore');
//     }
//   }

//   Future<void> showAddVendorDialog() async {
//     final TextEditingController vendorNameController = TextEditingController();
//     final TextEditingController phoneNumberController = TextEditingController();
//     final TextEditingController productController = TextEditingController();

//     return showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Add Vendor"),
//           content: Container(
//             child: ListView(
//               shrinkWrap: true,
//               children: <Widget>[
//                 TextField(
//                   controller: vendorNameController,
//                   decoration: InputDecoration(labelText: "Vendor Name"),
//                 ),
//                 TextField(
//                   controller: phoneNumberController,
//                   decoration: InputDecoration(labelText: "Phone Number"),
//                   keyboardType: TextInputType.phone,
//                 ),
//                 TextField(
//                   controller: productController,
//                   decoration: InputDecoration(labelText: "Product Sold"),
//                 ),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: Text("Cancel"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: Text("Add"),
//               onPressed: () {
//                 final vendorName = vendorNameController.text;
//                 final phoneNumber = int.tryParse(phoneNumberController.text) ?? 0;
//                 final product = productController.text;

//                 addVendorToFirestore(vendorName, phoneNumber, product);
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> showEditVendorDialog({
//     required String vendorName,
//     required int phoneNumber,
//     required String product,
//     required DocumentReference documentReference,
//   }) async {
//     final TextEditingController vendorNameController = TextEditingController(text: vendorName);
//     final TextEditingController phoneNumberController = TextEditingController(text: phoneNumber.toString());
//     final TextEditingController productController = TextEditingController(text: product);

//     return showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text("Edit Vendor"),
//           content: Container(
//             child: ListView(
//               shrinkWrap: true,
//               children: <Widget>[
//                 TextField(
//                   controller: vendorNameController,
//                   decoration: InputDecoration(labelText: "Vendor Name"),
//                 ),
//                 TextField(
//                   controller: phoneNumberController,
//                   decoration: InputDecoration(labelText: "Phone Number"),
//                   keyboardType: TextInputType.phone,
//                 ),
//                 TextField(
//                   controller: productController,
//                   decoration: InputDecoration(labelText: "Product Sold"),
//                 ),
//               ],
//             ),
//           ),
//           actions: <Widget>[
//             TextButton(
//               child: Text("Cancel"),
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//             ),
//             TextButton(
//               child: Text("Save"),
//               onPressed: () {
//                 final newVendorName = vendorNameController.text;
//                 final newPhoneNumber = int.tryParse(phoneNumberController.text) ?? 0;
//                 final newProduct = productController.text;

//                 updateVendorInformation(documentReference, newVendorName, newPhoneNumber, newProduct);
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> updateVendorInformation(
//     DocumentReference documentReference,
//     String newVendorName,
//     int newPhoneNumber,
//     String newProduct,
//   ) async {
//     try {
//       await documentReference.update({
//         'name': newVendorName,
//         'phoneNumber': newPhoneNumber,
//         'product': newProduct,
//       });
//       print('Vendor information updated successfully.');
//     } catch (e) {
//       print('Error updating vendor information: $e');
//     }
//   }

//   Future<void> deleteVendor(DocumentReference vendorRef) async {
//     try {
//       await vendorRef.delete();
//       print('Vendor deleted successfully.');
//     } catch (e) {
//       print('Error deleting vendor: $e');
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';

class VendorsPage extends StatefulWidget {
  const VendorsPage({Key? key}) : super(key: key);

  @override
  State<VendorsPage> createState() => _VendorsPageState();
}

class _VendorsPageState extends State<VendorsPage> {
  final Uuid uuid = Uuid();
  late List<QueryDocumentSnapshot<Map<String, dynamic>>> documents;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('VENDORS', style: GoogleFonts.poppins(fontSize: 20, color: Colors.black),),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 112, 64, 244),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              showAddVendorDialog();
            },
            icon: Icon(Icons.add_sharp),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: getCurrentUserVendors(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          documents = snapshot.data!.docs.cast<QueryDocumentSnapshot<Map<String, dynamic>>>();

          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (context, index) {
              final vendorDocument = documents[index].data() as Map<String, dynamic>;

              final vendorName = vendorDocument['name'] ?? '';
              final phoneNumber = vendorDocument['phoneNumber']?.toString() ?? '';
              final productSold = vendorDocument['product'] ?? '';

              return Padding(
                padding: EdgeInsets.all(8.0),
                child: Card(
                  color: Color.fromARGB(255, 138, 99, 246),
                  child: ListTile(
                    title: Text('Vendor Name: $vendorName', style: TextStyle(color: Colors.white)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Phone Number: $phoneNumber', style: TextStyle(color: Colors.white)),
                        Text('Product Sold: $productSold', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.black),
                          onPressed: () {
                            showEditVendorDialog(
                              vendorName: vendorName,
                              phoneNumber: int.tryParse(phoneNumber) ?? 0,
                              product: productSold,
                              documentReference: documents[index].reference,
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.black),
                          onPressed: () {
                            deleteVendor(documents[index].reference);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Stream<QuerySnapshot> getCurrentUserVendors() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      final String userId = user.uid;
      final userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);

      final vendorsCollection = userDocRef.collection('Vendors');

      return vendorsCollection.snapshots();
    }

    return Stream<QuerySnapshot>.empty();
  }

  Future<void> addVendorToFirestore(String vendorName, int phoneNumber, String product) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final String userId = user.uid;
      final userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);

      final vendorsCollection = userDocRef.collection('Vendors');

      final String vendorId = uuid.v4();

      await vendorsCollection.doc(vendorId).set({
        'id': vendorId,
        'name': vendorName,
        'phoneNumber': phoneNumber,
        'product': product,
      });
    }
  }

  Future<void> showAddVendorDialog() async {
    final TextEditingController vendorNameController = TextEditingController();
    final TextEditingController phoneNumberController = TextEditingController();
    final TextEditingController productController = TextEditingController();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Vendor"),
          content: Container(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                TextField(
                  controller: vendorNameController,
                  decoration: InputDecoration(labelText: "Vendor Name"),
                ),
                TextField(
                  controller: phoneNumberController,
                  decoration: InputDecoration(labelText: "Phone Number"),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: productController,
                  decoration: InputDecoration(labelText: "Product Sold"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Add"),
              onPressed: () {
                final vendorName = vendorNameController.text;
                final phoneNumber = int.tryParse(phoneNumberController.text) ?? 0;
                final product = productController.text;

                addVendorToFirestore(vendorName, phoneNumber, product);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showEditVendorDialog({
    required String vendorName,
    required int phoneNumber,
    required String product,
    required DocumentReference documentReference,
  }) async {
    final TextEditingController vendorNameController = TextEditingController(text: vendorName);
    final TextEditingController phoneNumberController = TextEditingController(text: phoneNumber.toString());
    final TextEditingController productController = TextEditingController(text: product);

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Vendor"),
          content: Container(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                TextField(
                  controller: vendorNameController,
                  decoration: InputDecoration(labelText: "Vendor Name"),
                ),
                TextField(
                  controller: phoneNumberController,
                  decoration: InputDecoration(labelText: "Phone Number"),
                  keyboardType: TextInputType.phone,
                ),
                TextField(
                  controller: productController,
                  decoration: InputDecoration(labelText: "Product Sold"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Save"),
              onPressed: () {
                final newVendorName = vendorNameController.text;
                final newPhoneNumber = int.tryParse(phoneNumberController.text) ?? 0;
                final newProduct = productController.text;

                updateVendorInformation(documentReference, newVendorName, newPhoneNumber, newProduct);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> updateVendorInformation(
    DocumentReference documentReference,
    String newVendorName,
    int newPhoneNumber,
    String newProduct,
  ) async {
    try {
      await documentReference.update({
        'name': newVendorName,
        'phoneNumber': newPhoneNumber,
        'product': newProduct,
      });
    } catch (e) {
      print('Error updating vendor information: $e');
    }
  }

  Future<void> deleteVendor(DocumentReference vendorRef) async {
    try {
      await vendorRef.delete();
    } catch (e) {
      print('Error deleting vendor: $e');
    }
  }
}

