import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:google_fonts/google_fonts.dart';

class SalesReportPage extends StatefulWidget {
  @override
  _SalesReportPageState createState() => _SalesReportPageState();
}

class _SalesReportPageState extends State<SalesReportPage> {
  double totalProfitt = 0.0;
  String selectedTimeFrame = 'Today';
  DateTime? selectedDate;
  List<Map<String, dynamic>> salesData = [];
  late Future<Map<String, double>> productCostPricesFuture;
  double netProfit = 0.0;
  double totalProfit = 0.0;
  Map<String, double> productCostPrices = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SALES REPORT', style: GoogleFonts.poppins(fontSize: 20, color: Colors.black),),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: () async {},
            icon: Icon(Icons.notifications),
          ),
          IconButton(
            onPressed: () {
              _showChartOptionsDialog();
            },
            icon: Icon(Icons.show_chart),
          ),
        ],
        backgroundColor: Color.fromARGB(255, 138, 99, 246),
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
      body: Column(
        children: [
          DropdownButton<String>(
            value: selectedTimeFrame,
            onChanged: (String? newValue) {
              if (newValue == 'Custom') {
                _selectCustomDate(context);
              } else {
                setState(() {
                  selectedDate = null;
                  selectedTimeFrame = newValue!;
                  fetchSalesData(selectedTimeFrame);
                  fetchNetProfit();
                });
              }
            },
            items: <String>['Today', 'This Week', 'This Month', 'Custom']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          if (selectedTimeFrame == 'Custom' && selectedDate != null)
            Text('Selected Date: ${selectedDate?.toLocal()}'),
          FutureBuilder(
  future: productCostPricesFuture,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      Map<String, double> productCostPrices = snapshot.data as Map<String, double>;

      // Add print statement to check productCostPrices
      print('Product Cost Prices: $productCostPrices');

      if (salesData.isNotEmpty) {
  double totalCostPrice = 0.0; // Initialize totalCostPrice variable
  double totalSellingPrice = 0.0; // Initialize totalSellingPrice variable
  int totalQuantity = 0; // Initialize totalQuantity variable
   // Initialize totalProfit variable

  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    physics: BouncingScrollPhysics(),
    child: DataTable(
      columns: <DataColumn>[
        DataColumn(label: Text('Product Name', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('Product Cost Price', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('Quantity Sold', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('Total Selling Price', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('Total Cost Price', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(label: Text('Profit', style: TextStyle(fontWeight: FontWeight.bold))),
      ],
      rows: salesData.map((sale) {
        String productName = sale['name'] ?? '';
        double productCostPrice = productCostPrices[productName] ?? 0.0;
        int quantity = sale['quantity'] as int? ?? 0;
        double totalPrice = sale['totalPrice'] as double? ?? 0.0;

        totalQuantity += quantity; // Accumulate total quantity
        totalSellingPrice += totalPrice; // Accumulate total selling price
        totalCostPrice += quantity * productCostPrice; // Accumulate total cost price
        totalProfit = totalSellingPrice - totalCostPrice; // Accumulate total profit
        totalProfitt = totalProfit;

        return DataRow(
          cells: <DataCell>[
            DataCell(Text(productName)),
            DataCell(Text(productCostPrice.toStringAsFixed(2))),
            DataCell(Text(quantity.toString())),
            DataCell(Text(totalPrice.toStringAsFixed(2))),
            DataCell(Text(
              (quantity * productCostPrice).toStringAsFixed(2))),
            DataCell(Text((totalPrice - (quantity * productCostPrice)).toStringAsFixed(2))),
          ],
        );
      }).toList() +
      [
        // Add a row for 'Total'
        DataRow(
          cells: <DataCell>[
            DataCell(Text('Total', style: TextStyle(fontWeight: FontWeight.bold))),
            DataCell(Text('')), // Placeholder for 'Product Cost Price'
            DataCell(Text(totalQuantity.toString(), style: TextStyle(fontWeight: FontWeight.bold))),
            DataCell(Text(totalSellingPrice.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.bold))),
            DataCell(Text(totalCostPrice.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.bold))),
            DataCell(Text(totalProfit.toStringAsFixed(2), style: TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
      ],
    ),
  );
} else {
  return Text('No sales data available.');
}
    } else if (snapshot.hasError) {
      return Text('Error fetching data: ${snapshot.error}');
    } else {
      return CircularProgressIndicator();
    }
  },
),
          Container(
            color: netProfit < 0 ? Colors.red : Colors.green,
            child: ListTile(
              title: Text(
                'Net Profit',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              trailing: Text(
                netProfit.toStringAsFixed(2),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectCustomDate(BuildContext context) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2022),
      lastDate: DateTime(2023, 12, 31),
    ).then((value) {
      if (value != null) {
        setState(() {
          selectedDate = value;
          selectedTimeFrame = 'Custom';
          fetchSalesData(selectedTimeFrame);
        });
      }
    });
  }

  Future<void> fetchNetProfit() async {
    CollectionReference users =
        FirebaseFirestore.instance.collection('Users');
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || salesData.isEmpty) {
      return;
    }

    Timestamp start = Timestamp.now();
    Timestamp end = Timestamp.now();

    if (selectedTimeFrame == 'Today') {
      DateTime now = DateTime.now();
      start = Timestamp.fromDate(
          DateTime(now.year, now.month, now.day));
      end = Timestamp.fromDate(
          DateTime(now.year, now.month, now.day)
              .add(Duration(days: 1)));
    } else if (selectedTimeFrame == 'This Week') {
      DateTime now = DateTime.now();
      DateTime monday = DateTime(
          now.year, now.month, now.day - now.weekday + 1);
      DateTime nextMonday = monday.add(Duration(days: 7));
      start = Timestamp.fromDate(monday);
      end = Timestamp.fromDate(nextMonday);
    } else if (selectedTimeFrame == 'This Month') {
      DateTime now = DateTime.now();
      start = Timestamp.fromDate(
          DateTime(now.year, now.month, 1));
      end = Timestamp.fromDate(
          DateTime(now.year, now.month + 1, 1));
    } else if (selectedTimeFrame == 'Custom' &&
        selectedDate != null) {
      DateTime customStart = DateTime(
          selectedDate!.year,
          selectedDate!.month,
          selectedDate!.day);
      DateTime customEnd = DateTime(
          selectedDate!.year,
          selectedDate!.month,
          selectedDate!.day)
          .add(Duration(days: 1));
      start = Timestamp.fromDate(customStart);
      end = Timestamp.fromDate(customEnd);
    }

    if (salesData.isNotEmpty) {
      double totalSellingPrice =
          salesData.last['total_selling_price'] as double? ?? 0.0;
      double totalCostPrice =
          salesData.last['total_cost_price'] as double? ?? 0.0;

      totalProfit = salesData.fold<double>(
          0.0,
          (sum, sale) {
            double productCostPrice =
                productCostPrices[sale['name']] ?? 0.0;
            int quantity = sale['quantity'] as int? ?? 0;
            double totalPrice =
                sale['totalPrice'] as double? ?? 0.0;
            return sum + (totalPrice - (quantity * productCostPrice));
          });

      double totalExpenses = 0.0;

      try {
        QuerySnapshot expensesQuery = await users
            .doc(user.uid)
            .collection('Expenses')
            .where('timestamp', isGreaterThanOrEqualTo: start)
            .where('timestamp', isLessThan: end)
            .get();
        for (var doc in expensesQuery.docs) {
          totalExpenses += (doc['cost'] as double?) ?? 0.0;
        }
      } catch (e) {
        print('Error fetching expenses data: $e');
      }

      setState(() {
        netProfit = totalProfitt - totalExpenses;
      });
    }
  }

  Future<void> fetchSalesData(String timeFrame) async {
    CollectionReference users =
        FirebaseFirestore.instance.collection('Users');
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    Timestamp start = Timestamp.now();
    Timestamp end = Timestamp.now();

    if (selectedTimeFrame == 'Today') {
      DateTime now = DateTime.now();
      start = Timestamp.fromDate(
          DateTime(now.year, now.month, now.day));
      end = Timestamp.fromDate(
          DateTime(now.year, now.month, now.day)
              .add(Duration(days: 1)));
    } else if (selectedTimeFrame == 'This Week') {
      DateTime now = DateTime.now();
      DateTime monday = DateTime(
          now.year, now.month, now.day - now.weekday + 1);
      DateTime nextMonday = monday.add(Duration(days: 7));
      start = Timestamp.fromDate(monday);
      end = Timestamp.fromDate(nextMonday);
    } else if (selectedTimeFrame == 'This Month') {
      DateTime now = DateTime.now();
      start = Timestamp.fromDate(
          DateTime(now.year, now.month, 1));
      end = Timestamp.fromDate(
          DateTime(now.year, now.month + 1, 1));
    } else if (selectedTimeFrame == 'Custom' &&
        selectedDate != null) {
      DateTime customStart = DateTime(
          selectedDate!.year,
          selectedDate!.month,
          selectedDate!.day);
      DateTime customEnd = DateTime(
          selectedDate!.year,
          selectedDate!.month,
          selectedDate!.day)
          .add(Duration(days: 1));
      start = Timestamp.fromDate(customStart);
      end = Timestamp.fromDate(customEnd);
    }

    try {
      QuerySnapshot salesQuery = await users
          .doc(user.uid)
          .collection('Sales')
          .where('time', isGreaterThanOrEqualTo: start)
          .where('time', isLessThan: end)
          .get();

      salesData = salesQuery.docs.fold<List<Map<String, dynamic>>>(
          [],
          (List<Map<String, dynamic>> acc, doc) {
        Map<String, dynamic> sale =
            doc.data() as Map<String, dynamic>;
        List<dynamic>? products =
            sale['products'] as List<dynamic>?;

        if (products != null && products.isNotEmpty) {
          for (var product in products) {
            String productName = product['name'] ?? '';
            int quantity = product['quantity'] ?? 0;
            double totalPrice = product['totalPrice'] ?? 0.0;
            double productCostPrice =
                productCostPrices[productName] ?? 0.0;

            if (acc.any((entry) => entry['name'] == productName)) {
              acc.firstWhere((entry) => entry['name'] == productName)['quantity'] += quantity;
              acc.firstWhere((entry) => entry['name'] == productName)['totalPrice'] += totalPrice;
            } else {
              acc.add({
                'name': productName,
                'quantity': quantity,
                'totalPrice': totalPrice,
              });
            }
          }
        }

        return acc;
      });

      fetchNetProfit();
    } catch (e) {
      print('Error fetching sales data: $e');
    }
  }

  Future<Map<String, double>> fetchProductCostPrices() async {
    CollectionReference users =
        FirebaseFirestore.instance.collection('Users');
    final user = FirebaseAuth.instance.currentUser;
    Map<String, double> costPrices = {};

    if (user == null) {
      return costPrices;
    }

    try {
      QuerySnapshot products = await users
          .doc(user.uid)
          .collection('Products')
          .get();

      print('Product Documents: ${products.docs}');

      products.docs.forEach((productDoc) {
        String productName = productDoc['product'] as String;
        double costPrice =
            (productDoc['price'] as num?)?.toDouble() ?? 0.0;
        costPrices[productName] = costPrice;
      });

      print('Product Cost Prices: $costPrices');
    } catch (e) {
      print('Error fetching product cost prices: $e');
    }

    return costPrices;
  }

  // Function to show the visualization options
  void _showChartOptionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Chart Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  _showTotalSellingPriceChart();
                },
                child: Text('Total Selling Price Chart'),
              ),
              ElevatedButton(
                onPressed: () {
                  _showTotalQuantitySoldChart();
                },
                child: Text('Total Quantity Sold Chart'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to show the total selling price chart
  void _showTotalSellingPriceChart() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Total Selling Price Chart'),
          content: Container(
            height: 300,
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              series: <ChartSeries>[
                // Replace the following series with your actual chart data
                ColumnSeries<Map<String, dynamic>, String>(
                  dataSource: salesData,
                  xValueMapper: (Map<String, dynamic> sales, _) =>
                      sales['name'] as String,
                  yValueMapper: (Map<String, dynamic> sales, _) =>
                      sales['totalPrice'] as double,
                  name: 'Total Selling Price',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  void _showTotalQuantitySoldChart() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Total Quantity Sold Chart'),
          content: Container(
            height: 300,
            child: SfCartesianChart(
              primaryXAxis: CategoryAxis(),
              series: <ChartSeries>[
                ColumnSeries<Map<String, dynamic>, String>(
                  dataSource: salesData,
                  xValueMapper: (
Map<String, dynamic> sale, _) => sale['name'].toString(),
                  yValueMapper: (Map<String, dynamic> sale, _) => sale['quantity'] as int,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    productCostPricesFuture = fetchProductCostPrices();
    fetchSalesData(selectedTimeFrame);
  }
}
