import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpensesPage extends StatefulWidget {
  const ExpensesPage({Key? key}) : super(key: key);

  @override
  State<ExpensesPage> createState() => ExpensesPageState();
}

class ExpensesPageState extends State<ExpensesPage> {
  final TextEditingController _expenseTypeController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _otherCategoryController = TextEditingController();
  String? selectedExpenseType;
  final List<String> expenseTypes = ['Light Bill', 'Rent', 'Repairing', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EXPENSES', style: GoogleFonts.poppins(fontSize: 20, color: Colors.black),),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              _showExpenseDialog(context);
            },
            icon: Icon(Icons.add),
          ),
          IconButton(
            onPressed: () async {
              // Handle notifications button press.
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
      body: _buildExpenseList(),
    );
  }

  Widget _buildExpenseList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _getExpensesStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final expenses = snapshot.data!.docs;
        return ListView.builder(
          itemCount: expenses.length,
          itemBuilder: (context, index) {
            final expense = expenses[index].data() as Map<String, dynamic>;
            final expenseType = expense['expenseType'];
            final cost = expense['cost'];
            final otherCategory = expense['otherCategory'];
            final timestamp = (expense['timestamp'] as Timestamp).toDate();
            final formattedTime = DateFormat('yyyy-MM-dd HH:mm').format(timestamp);

            return Padding(
              padding: EdgeInsets.all(8.0),
              child: Card(
                color: Color.fromARGB(255, 112, 64, 244),
                child: ListTile(
                  title: Text('Expense Type: $expenseType'),
                  subtitle: selectedExpenseType == 'Other' && otherCategory != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Cost: $cost'),
                            Text('Other Category: $otherCategory'),
                            Text('Date and Time: $formattedTime'),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Cost: $cost'),
                            Text('Date and Time: $formattedTime'),
                          ],
                        ),
                  textColor: Colors.white,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.black),
                        onPressed: () {
                          _showEditExpenseDialog(context, expenses[index].reference, expense);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.black),
                        onPressed: () {
                          _deleteExpense(expenses[index].reference);
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
    );
  }

  Stream<QuerySnapshot> _getExpensesStream() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final String userId = user.uid;
      final userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);
      final expensesCollection = userDocRef.collection('Expenses');
      return expensesCollection.snapshots();
    }
    return Stream<QuerySnapshot>.empty();
  }

  void _showExpenseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Add New Expense'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedExpenseType,
                      items: expenseTypes.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedExpenseType = newValue;
                        });
                      },
                      decoration: InputDecoration(labelText: 'Expense Type'),
                    ),
                    if (selectedExpenseType == 'Other')
                      TextField(
                        controller: _otherCategoryController,
                        decoration: InputDecoration(labelText: 'Other Category'),
                      ),
                    TextField(
                      controller: _costController,
                      decoration: InputDecoration(labelText: 'Cost'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _clearDialogFields();
                  },
                ),
                TextButton(
                  child: Text('Save'),
                  onPressed: () async {
                    await saveExpense();
                    Navigator.of(context).pop();
                    _clearDialogFields();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditExpenseDialog(
    BuildContext context,
    DocumentReference expenseRef,
    Map<String, dynamic> currentExpense,
  ) {
    final String existingExpenseType = currentExpense['expenseType'];
    final double existingCost = currentExpense['cost'];
    final String existingOtherCategory = currentExpense['otherCategory'] ?? '';

    selectedExpenseType = existingExpenseType;
    _costController.text = existingCost.toString();
    _otherCategoryController.text = existingOtherCategory;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Edit Expense'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedExpenseType,
                      items: expenseTypes.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          selectedExpenseType = newValue;
                        });
                      },
                      decoration: InputDecoration(labelText: 'Expense Type'),
                    ),
                    if (selectedExpenseType == 'Other')
                      TextField(
                        controller: _otherCategoryController,
                        decoration: InputDecoration(labelText: 'Other Category'),
                      ),
                    TextField(
                      controller: _costController,
                      decoration: InputDecoration(labelText: 'Cost'),
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _clearDialogFields();
                  },
                ),
                TextButton(
                  child: Text('Save'),
                  onPressed: () async {
                    await updateExpense(expenseRef);
                    Navigator.of(context).pop();
                    _clearDialogFields();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _clearDialogFields() {
    selectedExpenseType = null;
    _costController.clear();
    _otherCategoryController.clear();
  }

  Future<void> saveExpense() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final String userId = user.uid;
      final userDocRef = FirebaseFirestore.instance.collection('Users').doc(userId);
      final expensesCollection = userDocRef.collection('Expenses');

      final DateTime now = DateTime.now();
      final Timestamp timestamp = Timestamp.fromDate(now);

      Map<String, dynamic> data = {
        'expenseType': selectedExpenseType ?? '',
        'cost': double.tryParse(_costController.text) ?? 0.0,
        'timestamp': timestamp,
      };

      if (selectedExpenseType == 'Other') {
        data['otherCategory'] = _otherCategoryController.text;
      }

      try {
        await expensesCollection.add(data);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Expense Added successfully.'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error in adding expense: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> updateExpense(DocumentReference expenseRef) async {
    final existingExpense = await expenseRef.get();
    final data = existingExpense.data() as Map<String, dynamic>;

    data['expenseType'] = selectedExpenseType ?? '';
    data['cost'] = double.tryParse(_costController.text) ?? 0.0;

    if (selectedExpenseType != 'Other') {
      data.remove('otherCategory');
    } else {
      data['otherCategory'] = _otherCategoryController.text;
    }

    try {
      await expenseRef.set(data);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Expense updated successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating expense: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _deleteExpense(DocumentReference expenseRef) async {
    try {
      await expenseRef.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Expense deleted successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting expense: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
