import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:inventory_system/pages/home_page.dart';
import 'package:inventory_system/pages/products_page.dart';
import 'package:inventory_system/pages/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({Key? key}) : super(key: key);

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController deliveryAddressController = TextEditingController();
  final TextEditingController salesDescriptionController = TextEditingController();
  late List<QueryDocumentSnapshot<Map<String, dynamic>>> documents;
  List<String> selectedProducts = [];
  Map<String, Map<String, dynamic>> selectedProductsData = {};

  int _currentIndex = 1;

  final List<Widget> _pages = [
    HomePage(),
    SalesPage(),
    ProductsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SALES', style: GoogleFonts.poppins(fontSize: 20, color: Colors.black),),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              showAddProductDialog();
            },
            icon: Icon(Icons.add_sharp),
          ),
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
      body: StreamBuilder(
        stream: getCurrentUserProducts(),
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
    final productDocument = documents[index].data() as Map<String, dynamic>;
    final customerName = productDocument['customerName'] ?? '';
    final salesDescription = productDocument['description'] ?? '';
    final deliveryAddress = productDocument['deliveryAddress'] ?? '';
    final phoneNumber = productDocument['phoneNumber'] ?? 0;
    final products = productDocument['products'] ?? [];
    final time = productDocument['time']?.toDate();
    final totalBill = productDocument['totalBill'] ?? 0;

    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Card(
        color: Color.fromARGB(255, 112, 64, 244),
        child: ListTile(
          title: Text('Customer Name: $customerName', style: TextStyle(color: Colors.white)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Description: $salesDescription', style: TextStyle(color: Colors.white)),
              Text('Delivery Address: $deliveryAddress', style: TextStyle(color: Colors.white)),
              Text('Phone Number: $phoneNumber', style: TextStyle(color: Colors.white)),
              Text('Time: ${DateFormat('dd MMMM yyyy HH:mm:ss').format(time!)}', style: TextStyle(color: Colors.white)),
              SizedBox(height: 10),
              ...products.map<Widget>((product) {
                final productName = product['name'];
                final salesDescription = product['description'];
                final productPrice = product['price'];
                final productQuantity = product['quantity'];
                final totalPrice = product['totalPrice'];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Product Name: $productName', style: TextStyle(color: Colors.white)),
                    Text('Selling Price: $productPrice', style: TextStyle(color: Colors.white)),
                    Text('Quantity: $productQuantity', style: TextStyle(color: Colors.white)),
                    Text('Total Price: $totalPrice', style: TextStyle(color: Colors.white)),
                    Divider(color: Colors.white),
                  ],
                );
              }).toList(),
              Text('Total Bill: $totalBill', style: TextStyle(color: Colors.white)),

            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
//               IconButton(
//                 icon: Icon(Icons.edit),
//                 color: Colors.black,
//                 onPressed: () {
//                   print("Opening Edit Product Dialog");
//                    showEditProductDialog(  // Pass the context here
//   productDocument: documents[index] as QueryDocumentSnapshot<Map<String, dynamic>>,
// );
//                 },
//               ),
              IconButton(
                icon: Icon(Icons.delete),
                color: Colors.black,
                onPressed: () {
                  deleteProduct(documents[index].reference);
                },
              ),
              // IconButton(
              //   icon: Icon(Icons.receipt),
              //   color: Colors.black,
              //   onPressed: () {
              //     // Handle generating PDF logic here
              //   },
              // ),
              // Inside your SalesPage class
IconButton(
  onPressed: () async {
    String phoneNumber = documents[index]['phoneNumber'].toString();
    String messageUrl = 'sms:$phoneNumber';
    if (await canLaunch(messageUrl)) {
      await launch(messageUrl);
    } else {
      print('Could not launch messaging app');
    }
  },
  icon: Icon(Icons.message),
  color: Colors.black,
),
IconButton(
  onPressed: () async {
    String phoneNumber = documents[index]['phoneNumber'].toString();
    String callUrl = 'tel:$phoneNumber';
    if (await canLaunch(callUrl)) {
      await launch(callUrl);
    } else {
      print('Could not launch calling app');
    }
  },
  icon: Icon(Icons.phone),
  color: Colors.black,
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

  Future<void> showAddProductDialog() async {
    customerNameController.clear();
    phoneNumberController.clear();
    deliveryAddressController.clear();
    selectedProducts.clear();
    selectedProductsData.clear();
    DateTime selectedDate = DateTime.now();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Sales"),
          content: Container(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    await showProductSelectionDialog();
                  },
                  child: const Text("Select Product"),
                ),
                SizedBox(height: 10),
                ...selectedProductsData.entries.map((entry) {
                  final productName = entry.key;
                  final productData = entry.value;
                  return ListTile(
                    title: Text(productName),
                    subtitle: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            if (productData != null && productData['quantity'] > 1) {
                              setState(() {
                                productData['quantity'] = productData['quantity'] - 1;
                              });
                            }
                          },
                        ),
                        Text(productData != null ? '${productData['quantity']}' : '1'),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            if (productData != null) {
                              setState(() {
                                productData['quantity'] = productData['quantity'] + 1;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
                TextField(
                  controller: customerNameController,
                  decoration: InputDecoration(labelText: "Customer Name"),
                ),
                TextField(
                  controller: phoneNumberController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "Phone Number"),
                ),
                TextField(
                  controller: deliveryAddressController,
                  decoration: InputDecoration(labelText: "Delivery Address"),
                ),
                TextField(
                  controller: salesDescriptionController,
                  decoration: InputDecoration(labelText: "Description"),
                ),
                SizedBox(height: 20),
                Text("Select Date:"),
                InkWell(
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null && pickedDate != selectedDate) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${selectedDate.toLocal()}".split(' ')[0],
                          style: TextStyle(fontSize: 16),
                        ),
                        Icon(
                          Icons.calendar_today,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Add Sales"),
              onPressed: () {
                addProductToFirestore(selectedDate);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showProductSelectionDialog() async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text("Select Products"),
            content: Container(
              width: double.maxFinite,
              child: StreamBuilder(
                stream: getProducts(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final products = snapshot.data!.docs;
                  final productNames = products
                      .where((product) => (product['quantity'] ?? 0) > 0)
                      .map((product) => product['product'] as String)
                      .toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: productNames.length,
                    itemBuilder: (context, index) {
                      final productName = productNames[index];
                      final isSelected = selectedProducts.contains(productName);
                      final productData = selectedProductsData[productName] ?? {};

                      return Column(
                        children: [
                          ListTile(
                            title: Text(productName),
                            trailing: Checkbox(
                              value: isSelected,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value != null) {
                                    if (value) {
                                      selectedProducts.add(productName);
                                      selectedProductsData[productName] = {
                                        'priceController': TextEditingController(),
                                        'quantity': 1,
                                      };
                                    } else {
                                      selectedProducts.remove(productName);
                                      selectedProductsData.remove(productName);
                                    }
                                  }
                                });
                              },
                            ),
                          ),
                          if (isSelected)
                            Column(
                              children: [
                                TextField(
                                  controller: productData['priceController'] ??
                                      TextEditingController(),
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(labelText: "Selling Price"),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.remove),
                                      onPressed: () async {
                                        final maxQuantity =
                                            await getMaxProductQuantity(productName);
                                        setState(() {
                                          productData['quantity'] =
                                              (productData['quantity'] - 1).clamp(1, maxQuantity);
                                        });
                                      },
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      productData['quantity'] != null
                                          ? '${productData['quantity']}'
                                          : '1',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    SizedBox(width: 10),
                                    IconButton(
                                      icon: Icon(Icons.add),
                                      onPressed: () async {
                                        final maxQuantity =
                                            await getMaxProductQuantity(productName);
                                        setState(() {
                                          productData['quantity'] =
                                              (productData['quantity'] + 1).clamp(1, maxQuantity);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                          Divider(),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("Cancel"),
                onPressed: () {
                  setState(() {
                    // Reset the selectedProducts and selectedProductsData to the initial state
                    selectedProducts = [];
                    selectedProductsData = {};
                  });
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("Select"),
                onPressed: () {
                  // Handle the logic for adding the selected products with price and quantity here
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    },
  );
}

  Future<void> showQuantityDialog() async {
  Map<String, Map<String, dynamic>> updatedProductsData = {...selectedProductsData};

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: const Text("Select Quantity"),
            content: Container(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: selectedProductsData.length,
                itemBuilder: (context, index) {
                  final productName = updatedProductsData.keys.elementAt(index);
                  final productData = updatedProductsData[productName];

                  return ListTile(
                    title: Text(productName),
                    subtitle: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () async {
                            if (productData != null && productData['quantity'] > 1) {
                              final maxQuantity = await getMaxProductQuantity(productName);
                              setState(() {
                                productData['quantity'] = (productData['quantity'] - 1).clamp(1, maxQuantity);
                              });
                            }
                          },
                        ),
                        Text(productData != null ? '${productData['quantity']}' : '1'),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () async {
                            if (productData != null) {
                              final maxQuantity = await getMaxProductQuantity(productName);
                              setState(() {
                                productData['quantity'] = (productData['quantity'] + 1).clamp(1, maxQuantity);
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text("Cancel"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text("Done"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    },
  );
}

Future<int> getMaxProductQuantity(String productName) async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final User? user = auth.currentUser;

  if (user != null) {
    final String userId = user.uid;
    final userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);
    final productsCollection = userDocRef.collection('Products');

    try {
      final querySnapshot = await productsCollection
          .where('product', isEqualTo: productName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final int maxQuantity = querySnapshot.docs.first['quantity'] ?? 0;
        return maxQuantity;
      } else {
        return 0;
      }
    } catch (error) {
      print("Error getting max product quantity: $error");
      return 0;
    }
  }
  return 0;
}

  Future<void> showEditProductDialog({
  required QueryDocumentSnapshot<Map<String, dynamic>> productDocument,
}) async {
  TextEditingController productPriceController = TextEditingController();
  TextEditingController productQuantityController = TextEditingController();

  productPriceController.text = productDocument['price']?.toString() ?? '';
  productQuantityController.text = productDocument['quantity']?.toString() ?? '';

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Edit Product"),
        content: Container(
          child: ListView(
            shrinkWrap: true,
            children: <Widget>[
              TextField(
                controller: productPriceController,
                decoration: InputDecoration(labelText: "Product Price"),
              ),
              TextField(
                controller: productQuantityController,
                decoration: InputDecoration(labelText: "Quantity"),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text("Save"),
            onPressed: () {
              final newProductPrice = int.tryParse(productPriceController.text) ?? 0;
              final newProductQuantity = int.tryParse(productQuantityController.text) ?? 0;

              updateProductQuantity(productDocument.reference, newProductQuantity, newProductPrice);

              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

  Stream<QuerySnapshot> getCurrentUserProducts() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      final String userId = user.uid;
      final CollectionReference userProductsCollection =
          FirebaseFirestore.instance.collection('Users/$userId/Sales');
      return userProductsCollection.snapshots();
    }

    return Stream<QuerySnapshot>.empty();
  }

  Future<void> deleteProduct(DocumentReference productRef) async {
    try {
      await productRef.delete();
      print('Product deleted successfully.');
    } catch (e) {
      print('Error deleting product: $e');
    }
  }

  Future<void> updateProductQuantity(
  DocumentReference productRef,
  int newQuantity,
  int newPrice,
) async {
  try {
    await productRef.update({
      'quantity': newQuantity,
      'price': newPrice,
    });
    print('Product details updated successfully.');
  } catch (e) {
    print('Error updating product details: $e');
  }
}

Future<void> updateProductQuantityInProductsCollection(String productName, int newQuantity) async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final User? user = auth.currentUser;

  if (user != null) {
    final String userId = user.uid;
    final userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);
    final productsCollection = userDocRef.collection('Products');

    try {
      final productDoc = await productsCollection
          .where('product', isEqualTo: productName)
          .get();

      if (productDoc.docs.isNotEmpty) {
        final docRef = productDoc.docs.first.reference;
        final int currentQuantity = productDoc.docs.first['quantity'] ?? 0;
        final int updatedQuantity = currentQuantity - newQuantity;

        // Update product quantity in the Products collection
        await docRef.update({'quantity': updatedQuantity});
      }
    } catch (error) {
      print("Error updating product quantity in Products collection: $error");
    }
  }
}

  Future<void> addProductToFirestore(DateTime selectedDate) async {
  final User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    final String userId = user.uid;
    final userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);
    final salesCollection = userDocRef.collection('Sales');

    List<Map<String, dynamic>> productsList = [];
    double totalBill = 0;

    for (var entry in selectedProductsData.entries) {
      final productName = entry.key;
      final productData = entry.value;

      final newQuantity = productData['quantity'];
      final sellingPriceController = productData['priceController'];
      final sellingPrice = double.tryParse(sellingPriceController.text) ?? 0.0;
      final totalPrice = sellingPrice * newQuantity;
      totalBill += totalPrice;
      final description = productData['description'];

      productsList.add({
        'name': productName,
        'price': sellingPrice,
        'quantity': newQuantity,
        'totalPrice': totalPrice,
        'description': description,
      });

      // Update product quantity in the Products collection
      await updateProductQuantityInProductsCollection(productName, newQuantity);
    }

    await salesCollection.add({
      'customerName': customerNameController.text,
      'description': salesDescriptionController.text,
      'phoneNumber': int.tryParse(phoneNumberController.text) ?? 0,
      'deliveryAddress': deliveryAddressController.text,
      'time': Timestamp.fromDate(selectedDate),
      'products': productsList,
      'totalBill': totalBill,
    });

    print('Sales added to Firestore');
  }
}

  Stream<QuerySnapshot> getProducts() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      final String userId = user.uid;
      final userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);
      final productsCollection = userDocRef.collection('Products');

      return productsCollection.snapshots();
    }

    return Stream<QuerySnapshot>.empty();
  }
}
