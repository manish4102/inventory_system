import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:inventory_system/reusable_widgets.dart/textfield_widget.dart';
import 'package:inventory_system/utils/routes.dart' as route;
import 'package:inventory_system/pages/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddProductsPage extends StatefulWidget {
  const AddProductsPage({super.key});

  @override
  State<AddProductsPage> createState() => _AddProductsPageState();
}

class _AddProductsPageState extends State<AddProductsPage> {
  final TextEditingController _productnameTextController = TextEditingController();
  final TextEditingController _productpriceTextController = TextEditingController();
  final TextEditingController _productQuantityTextController = TextEditingController();

  Future<void> addProductToFirestore() async {
    final String productName = _productnameTextController.text;
    final double price = double.tryParse(_productpriceTextController.text) ?? 0.0;
    final int quantity = int.tryParse(_productQuantityTextController.text) ?? 0;

    if (productName.isNotEmpty) {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final String userId = user.uid;
        final userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);
        final productsCollection = userDocRef.collection('Products');

        final querySnapshot = await productsCollection.where('name', isEqualTo: productName).get();

        if (querySnapshot.docs.isEmpty) {
          // No existing product with the same name, so create a new one
          await productsCollection.add({
            'name': productName,
            'price': price, // Save as an integer
            'quantity': quantity, // Save as an integer
            'timestamp': FieldValue.serverTimestamp(), // Add a timestamp when the product is added
          });
          print('Product added to Firestore');
        } else {
          // A product with the same name exists, so update it directly
          final existingProduct = querySnapshot.docs.first;
          final existingPrice = existingProduct['price'];
          final existingQuantity = existingProduct['quantity'];

          final newPrice = (existingPrice + price) ~/ 2; // Calculate the average price
          final newQuantity = existingQuantity + quantity;

          await existingProduct.reference.update({
            'price': newPrice,
            'quantity': newQuantity,
          });
          print('Product updated in Firestore');
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ADD PRODUCTS'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: () {}, 
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
            bottomLeft: Radius.circular (25),
            bottomRight: Radius.circular (25),
          ),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Colors.grey[300],
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).size.height * 0.15, 20, 0),
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(height: 50),
                TextFormField(
                  controller: _productnameTextController,
                  decoration: InputDecoration(labelText: 'Enter Product Name'),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _productpriceTextController,
                  decoration: InputDecoration(labelText: 'Enter Product Price'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _productQuantityTextController,
                  decoration: InputDecoration(labelText: 'Enter Product Quantity'),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 20),
                Container(
                  width: MediaQuery.of(context).size.width, 
                  height: 50,
                  margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                  child: ElevatedButton(
                    onPressed: () {
                      addProductToFirestore();
                      print('Successful');
                      Navigator.pop(context, route.productsPage);
                    }, 
                    child: Text("ADD PRODUCT",
                      style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ), // Text
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith((states) {
                        if (states.contains (MaterialState.pressed)) {
                          return Colors.black26;
                        }
                        return Color.fromARGB(255, 112, 64, 244);
                      }),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder (borderRadius: BorderRadius.circular (8))),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
