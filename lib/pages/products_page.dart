import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:inventory_system/pages/home_page.dart';
import 'package:inventory_system/pages/profile_page.dart';
import 'package:inventory_system/pages/sales_page.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:google_fonts/google_fonts.dart';


class ProductsPage extends StatefulWidget {
  const ProductsPage({Key? key}) : super(key: key);

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  final TextEditingController productPriceController = TextEditingController();
  final TextEditingController productQuantityController = TextEditingController();
  final TextEditingController productDescriptionController = TextEditingController();
  final TextEditingController vendorController = TextEditingController();
  late List<QueryDocumentSnapshot<Map<String, dynamic>>> documents;
  String selectedProduct = '';
  String selectedVendor = '';

  int _currentIndex = 2;

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
        title: Text('PRODUCTS', style: GoogleFonts.poppins(fontSize: 20, color: Colors.black),),
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

              final productName = productDocument['product'] ?? '';
              double productPrice = productDocument['price'] ?? 0.0;
              double productQuantity = productDocument['quantity'] ?? 0.0;
              final time = productDocument['time'];
              final productDescription = productDocument['description'] ?? '';

              final formattedTimestamp = time != null
                  ? DateFormat.yMd().add_Hm().format((time as Timestamp).toDate())
                  : 'No timestamp';

              return Padding(
                padding: EdgeInsets.all(8.0),
                child: Card(
                  color: Color.fromARGB(255, 112, 64, 244),
                  child: ListTile(
                    title: Text('Product Name: $productName', style: TextStyle(color: Colors.white)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Description: $productDescription', style: TextStyle(color: Colors.white)),
                        Text('Product Price: $productPrice', style: TextStyle(color: Colors.white)),
                        Text('Quantity: $productQuantity', style: TextStyle(color: Colors.white)),
                        Text('Timestamp: $formattedTimestamp', style: TextStyle(color: Colors.white)),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove, color: Colors.black),
                              onPressed: () {
                                if (productQuantity > 0) {
                                  productQuantity--;
                                  updateProductQuantity(documents[index].reference, productQuantity);
                                }
                              },
                            ),
                            Container(
                              width: 50,
                              height: 50,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                              ),
                              child: Text(
                                productQuantity.toString(),
                                style: TextStyle(fontSize: 18, color: Colors.black),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.add, color: Colors.black),
                              onPressed: () {
                                productQuantity++;
                                updateProductQuantity(documents[index].reference, productQuantity);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.black),
                          onPressed: () {
                            showEditProductDialog(
                              productPriceController: productPriceController,
                              productQuantityController: productQuantityController,
                              vendorController: vendorController,
                              productDocument: documents[index],
                              productDescriptionController: productDescriptionController,
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.black),
                          onPressed: () {
                            deleteProduct(documents[index].reference);
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
    productPriceController.clear();
    productQuantityController.clear();
    vendorController.clear();
    DateTime selectedDate = DateTime.now();

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Product"),
          content: Container(
            child: ListView(
              shrinkWrap: true,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    await showProductSelectionDialog();
                    showVendorSelectionDialog();
                  },
                  child: const Text("Select Product"),
                ),
                TextField(
                  controller: productPriceController,
                  decoration: InputDecoration(labelText: "Product Price"),
                ),
                TextField(
                  controller: productQuantityController,
                  decoration: InputDecoration(labelText: "Quantity"),
                ),
                TextField(
                  controller: productDescriptionController,
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
                ElevatedButton(
                  onPressed: () async {
                    await showVendorSelectionDialog();
                  },
                  child: const Text("Select Vendor"),
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
              child: const Text("Add"),
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
    String selectedProductTemp = selectedProduct;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Select Product"),
              content: Container(
                width: double.maxFinite,
                child: StreamBuilder(
                  stream: getVendorProducts(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    final products = snapshot.data!.docs;
                    final productNames = products.map((product) => product['product'] as String).toList();

                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: productNames.length,
                      itemBuilder: (context, index) {
                        final productName = productNames[index];

                        return RadioListTile(
                          title: Text(productName),
                          value: productName,
                          groupValue: selectedProductTemp,
                          onChanged: (String? value) {
                            setState(() {
                              selectedProductTemp = value!;
                            });
                          },
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
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text("Select"),
                  onPressed: () {
                    setState(() {
                      selectedProduct = selectedProductTemp;
                    });
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

  Future<void> showEditProductDialog({
    required TextEditingController productPriceController,
    required TextEditingController productQuantityController,
    required TextEditingController vendorController,
    required TextEditingController productDescriptionController,
    required QueryDocumentSnapshot<Map<String, dynamic>> productDocument,
  }) async {
    productPriceController.text = productDocument['price']?.toString() ?? '';
    productQuantityController.text = productDocument['quantity']?.toString() ?? '';
    vendorController.text = productDocument['vendor'] ?? '';
    productDescriptionController.text = productDocument['description'] ?? '';

    final List<String> vendorNames = await getVendorNamesList(selectedProduct);

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
                TextField(
                  controller: productDescriptionController,
                  decoration: InputDecoration(labelText: "Description"),
                ),
                ElevatedButton(
                  onPressed: () {
                    showVendorSelectionDialog();
                  },
                  child: const Text("Select Vendor"),
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
                final newProductPrice = double.tryParse(productPriceController.text) ?? 0.0;
                final newProductQuantity = double.tryParse(productQuantityController.text) ?? 0.0;

                updateProductInformation(
                  productDocument.reference,
                  selectedProduct,
                  newProductPrice,
                  vendorController.text,
                  productDescriptionController.text,
                );
                updateProductQuantity(productDocument.reference, newProductQuantity);

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showVendorSelectionDialog() async {
    String selectedVendorTemp = selectedVendor;

    final List<String> vendorNames = await getVendorNamesList(selectedProduct);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Select Vendor"),
              content: Container(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: vendorNames.length,
                  itemBuilder: (context, index) {
                    final vendorName = vendorNames[index];

                    return RadioListTile(
                      title: Text(vendorName),
                      value: vendorName,
                      groupValue: selectedVendorTemp,
                      onChanged: (String? value) {
                        setState(() {
                          selectedVendorTemp = value!;
                        });
                      },
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
                  child: const Text("Select"),
                  onPressed: () {
                    setState(() {
                      selectedVendor = selectedVendorTemp;
                    });
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

  Future<List<String>> getVendorNamesList(String productName) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      final String userId = user.uid;
      final userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);
      final vendorsCollection = userDocRef.collection('Vendors');

      try {
        final querySnapshot = await vendorsCollection.where('product', isEqualTo: productName).get();

        List<String> uniqueValues = [];

        querySnapshot.docs.forEach((doc) {
          String vendorName = doc['name'];
          if (!uniqueValues.contains(vendorName)) {
            uniqueValues.add(vendorName);
          }
        });

        return uniqueValues;
      } catch (error) {
        print('Error fetching vendors: $error');
        return [];
      }
    }

    return [];
  }

  Stream<QuerySnapshot> getCurrentUserProducts() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;

    if (user != null) {
      final String userId = user.uid;
      final CollectionReference userProductsCollection =
          FirebaseFirestore.instance.collection('Users/$userId/Products');
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

  Future<void> updateProductQuantity(DocumentReference productRef, double newQuantity) async {
    try {
      await productRef.update({'quantity': newQuantity.toDouble()});
      print('Product quantity updated successfully.');
    } catch (e) {
      print('Error updating product quantity: $e');
    }
  }

  Future<void> updateProductInformation(
      DocumentReference productRef, String productName, double newPrice, String newVendor, String description) async {
    try {
      await productRef.update({
        'product': productName,
        'price': newPrice,
        'vendor': newVendor,
        'description': description,
      });
      print('Product information updated successfully.');
    } catch (e) {
      print('Error updating product information: $e');
    }
  }

  Future<void> addProductToFirestore(DateTime selectedDate) async {
    final double price = double.tryParse(productPriceController.text) ?? 0.0;
    final double quantity = double.tryParse(productQuantityController.text) ?? 0.0;
    final String description = (productDescriptionController.text) ?? '';

    if (selectedProduct.isNotEmpty) {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        final String userId = user.uid;
        final userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);
        final productsCollection = userDocRef.collection('Products');

        await productsCollection.add({
          'product': selectedProduct,
          'price': price,
          'quantity': quantity,
          'vendor': selectedVendor,  // Added selectedVendor here
          'time': Timestamp.fromDate(selectedDate),
          'description': description
        });

        print('Product added to Firestore');
      }
    }
  }

  Stream<QuerySnapshot> getVendorProducts() {
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
}

