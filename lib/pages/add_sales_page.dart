import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:inventory_system/reusable_widgets.dart/textfield_widget.dart';
import 'package:inventory_system/utils/routes.dart' as route;
import 'package:inventory_system/pages/login_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddSalesPage extends StatefulWidget {
  const AddSalesPage({Key? key});

  @override
  State<AddSalesPage> createState() => _AddSalesPageState();
}

class _AddSalesPageState extends State<AddSalesPage> {
  final _formKey = GlobalKey<FormState>();
  final _sellingPriceController = TextEditingController();
  final _quantityController = TextEditingController();
  double totalSellingPrice = 0.0;
  String? selectedProduct;
  List<String> availableProducts = [];

  @override
  void initState() {
    super.initState();
    loadAvailableProducts();
  }

  Future<void> loadAvailableProducts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .collection('Products')
          .get();

      final products = querySnapshot.docs
          .map((doc) => doc.data()['name'] as String)
          .where((productName) => productName != null)
          .toList();

      setState(() {
        availableProducts = products;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ADD SALES'),
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
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: Colors.grey[300],
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.15, 20, 0),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(height: 50),
                  DropdownButtonFormField<String>(
                    value: selectedProduct,
                    hint: Text('Select a Product'),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedProduct = newValue;
                      });
                    },
                    items: availableProducts
                        .map((String product) {
                          return DropdownMenuItem<String>(
                            value: product,
                            child: Text(product),
                          );
                        })
                        .toList(),
                  ),
                  TextFormField(
                    controller: _sellingPriceController,
                    decoration: InputDecoration(labelText: 'Selling Price'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Selling Price is required';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Invalid Selling Price';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _quantityController,
                    decoration: InputDecoration(labelText: 'Quantity'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Quantity is required';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Invalid Quantity';
                      }
                      return null;
                    },
                  ),
                  Text('Total Selling Price: $totalSellingPrice'),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 50,
                    margin: const EdgeInsets.fromLTRB(0, 10, 0, 20),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8)),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final productName = selectedProduct;
                          final sellingPrice =
                              double.parse(_sellingPriceController.text);
                          final quantity = int.parse(_quantityController.text);

                          setState(() {
                            totalSellingPrice = sellingPrice * quantity;
                          });

                          final user = FirebaseAuth.instance.currentUser;
                          if (user != null) {
                            final productExists = await checkProductExistence(
                                user.uid, productName!);

                            if (productExists) {
                              final insufficientInventory =
                                  await updateProductQuantity(
                                      user.uid, productName, quantity);

                              if (!insufficientInventory) {
                                await FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(user.uid)
                                    .collection('Sales')
                                    .add({
                                  'productName': productName,
                                  'sellingPrice': sellingPrice,
                                  'quantity': quantity,
                                  'totalSellingPrice': totalSellingPrice,
                                  'timestamp': FieldValue.serverTimestamp(),
                                });

                                // Navigate to the sales page
                                Navigator.pop(context, route.salesPage);
                              } else {
                                final snackBar = SnackBar(
                                  content: Text('Insufficient Inventory'),
                                  backgroundColor: Colors.red,
                                );
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(snackBar);
                              }
                            } else {
                              final snackBar = SnackBar(
                                content: Text('Product does not exist'),
                                backgroundColor: Colors.red,
                              );
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(snackBar);
                            }
                          }
                        }
                      },
                      child: Text(
                        'Add Sales',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith(
                            (states) {
                          if (states.contains(MaterialState.pressed)) {
                            return Colors.black26;
                          }
                          return Color.fromARGB(255, 112, 64, 244);
                        }),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> checkProductExistence(String userId, String productName) async {
    final productSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('Products')
        .where('name', isEqualTo: productName)
        .get();

    return productSnapshot.docs.isNotEmpty;
  }

  Future<bool> updateProductQuantity(
      String userId, String productName, int soldQuantity) async {
    final productRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('Products');

    final transaction = await FirebaseFirestore.instance.runTransaction(
        (transaction) async {
      final productDoc = await productRef
          .where('name', isEqualTo: productName)
          .get();
      if (productDoc.docs.isNotEmpty) {
        final currentQuantity =
            (productDoc.docs[0].data() != null)
                ? productDoc.docs[0].data()!['quantity'] ?? 0
                : 0;
        final newQuantity = currentQuantity - soldQuantity;
        if (newQuantity >= 0) {
          transaction.update(productDoc.docs[0].reference, {'quantity': newQuantity});
        } else {
          return true; // Insufficient Inventory
        }
      } else {
        throw Exception('Product does not exist');
      }
      return false; // Sufficient Inventory
    });

    return transaction;
  }
}
