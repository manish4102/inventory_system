import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:number_display/number_display.dart';
import 'package:google_fonts/google_fonts.dart';

class SalesDataChartsPage extends StatefulWidget {
  @override
  _SalesDataChartsPageState createState() => _SalesDataChartsPageState();
}

class _SalesDataChartsPageState extends State<SalesDataChartsPage> {
  String selectedTimeFrame = 'Today';
  DateTime? startDate;
  DateTime? endDate;
  List<Map<String, dynamic>> salesData = [];
  late Future<Map<String, double>> productCostPricesFuture;
  double netProfit = 0.0;
  double totalProfit = 0.0;
  double totalSellingPrice = 0.0;
  double totalCostPrice = 0.0;
  int totalQuantity = 0;
  Map<String, double> productCostPrices = {};

  @override
  void initState() {
    super.initState();
    productCostPricesFuture = fetchProductCostPrices();
    fetchSalesData(selectedTimeFrame);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sales Data Charts', style: GoogleFonts.poppins(fontSize: 20, color: Colors.black),),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 112, 64, 244),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            DropdownButton<String>(
              value: selectedTimeFrame,
              onChanged: (String? newValue) {
                if (newValue == 'Custom') {
                  _selectCustomDateRange(context);
                } else {
                  setState(() {
                    startDate = null;
                    endDate = null;
                    selectedTimeFrame = newValue!;
                    fetchSalesData(selectedTimeFrame);
                  });
                }
              },
              items: <String>[
                'Today',
                'This Week',
                'This Month',
                'This Year',
                'Custom'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            if (selectedTimeFrame == 'Custom' &&
                startDate != null &&
                endDate != null)
              Text(
                  'Selected Date Range: ${DateFormat('yyyy-MM-dd').format(startDate!)} - ${DateFormat('yyyy-MM-dd').format(endDate!)}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showChartDialog('Total Selling Price');
              },
              style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 112, 64, 244)),
            minimumSize: MaterialStateProperty.all<Size>(Size(300, 50)),
            ),
              child: Text('Total Selling Price Chart', style: GoogleFonts.poppins(fontSize: 15, color: Colors.white),),
            ),
            SizedBox(height: 20,),
            ElevatedButton(
              onPressed: () {
                _showChartDialog('Total Quantity Sold');
              },
              style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 112, 64, 244)),
            minimumSize: MaterialStateProperty.all<Size>(Size(300, 50)),
          ),
              child: Text('Total Quantity Sold Chart', style: GoogleFonts.poppins(fontSize: 15, color: Colors.white),),
            ),
            SizedBox(height: 20,),
            ElevatedButton(
              onPressed: () {
                _showChartDialog('Profit per Product');
              },
              style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 112, 64, 244)),
            minimumSize: MaterialStateProperty.all<Size>(Size(300, 50)),
          ),
              child: Text('Profit per Product Chart', style: GoogleFonts.poppins(fontSize: 15, color: Colors.white),),
            ),
          ],
        ),
      ),
    );
  }

  void _showChartDialog(String chartType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$chartType Chart', style: GoogleFonts.poppins(fontSize: 25, color: Colors.black),),
          content: Container(
            height: 200,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _displayChart(chartType, 'Column');
                  },
                  style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 112, 64, 244)),
            minimumSize: MaterialStateProperty.all<Size>(Size(150, 50)),
          ),
                  child: Text('Column Chart', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),),
                ),
                SizedBox(height: 5,),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _displayChart(chartType, 'Line');
                  },
                  style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 112, 64, 244)),
            minimumSize: MaterialStateProperty.all<Size>(Size(150, 50)),
          ),
                  child: Text('Line Chart', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),),
                ),
                SizedBox(height: 5,),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _displayChart(chartType, 'Pie');
                  },
                  style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 112, 64, 244)),
            minimumSize: MaterialStateProperty.all<Size>(Size(150, 50)),
          ),
                  child: Text('Pie Chart', style: GoogleFonts.poppins(fontSize: 12, color: Colors.white),),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _displayChart(String chartType, String displayType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$chartType $displayType Chart', style: GoogleFonts.poppins(fontSize: 25, color: Colors.black),),
          content: Container(
            height: 300,
            child: displayType == 'Column'
                ? chartType == 'Total Selling Price'
                    ? _buildTotalSellingPriceChart()
                    : chartType == 'Total Quantity Sold'
                        ? _buildTotalQuantitySoldChart()
                        : _buildProfitChart()
                : displayType == 'Line'
                    ? _buildLineChart(chartType)
                    : _buildPieChart(chartType),
          ),
        );
      },
    );
  }

  Widget _buildTotalSellingPriceChart() {
    return SfCartesianChart(
      title: ChartTitle(text: 'Total Selling Price'),
      primaryXAxis: CategoryAxis(
        title: AxisTitle(text: 'Product'),
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: 'Total Selling Price (₹)'),
        numberFormat: NumberFormat.compactCurrency(locale: 'en_US', symbol: '₹'),
      ),
      series: <ChartSeries>[
        ColumnSeries<Map<String, dynamic>, String>(
          dataSource: salesData,
          xValueMapper: (Map<String, dynamic> sales, _) =>
              sales['name'] as String,
          yValueMapper: (Map<String, dynamic> sales, _) =>
              sales['totalPrice'] as double,
          name: 'Total Selling Price',
          dataLabelSettings: DataLabelSettings(isVisible: true),
          enableTooltip: true,
        ),
      ],
    );
  }

  Widget _buildTotalQuantitySoldChart() {
    return SfCartesianChart(
      title: ChartTitle(text: 'Total Quantity Sold'),
      primaryXAxis: CategoryAxis(
        title: AxisTitle(text: 'Product'),
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: 'Total Quantity Sold'),
      ),
      series: <ChartSeries>[
        ColumnSeries<Map<String, dynamic>, String>(
          dataSource: salesData,
          xValueMapper: (Map<String, dynamic> sales, _) =>
              sales['name'] as String,
          yValueMapper: (Map<String, dynamic> sales, _) =>
              sales['quantity'] as int,
          name: 'Total Quantity Sold',
          dataLabelSettings: DataLabelSettings(isVisible: true),
          enableTooltip: true,
        ),
      ],
    );
  }

  Widget _buildProfitChart() {
    return SfCartesianChart(
      title: ChartTitle(text: 'Profit per Product'),
      primaryXAxis: CategoryAxis(
        title: AxisTitle(text: 'Product'),
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: 'Profit (₹)'),
        numberFormat: NumberFormat.compactCurrency(locale: 'en_US', symbol: '₹'),
      ),
      series: <ChartSeries>[
        ColumnSeries<Map<String, dynamic>, String>(
          dataSource: salesData,
          xValueMapper: (Map<String, dynamic> sales, _) =>
              sales['name'] as String,
          yValueMapper: (Map<String, dynamic> sales, _) =>
              sales['profit'] as double,
          name: 'Profit per Product',
          dataLabelSettings: DataLabelSettings(isVisible: true),
          enableTooltip: true,
        ),
      ],
    );
  }

  Widget _buildLineChart(String chartType) {
    return SfCartesianChart(
      title: ChartTitle(text: '$chartType Over Time'),
      primaryXAxis: CategoryAxis(
        title: AxisTitle(text: 'Product'),
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: chartType == 'Total Selling Price' ? 'Total Selling Price (₹)' : 'Quantity'),
        numberFormat: NumberFormat.compactCurrency(locale: 'en_US', symbol: '₹'),
      ),
      series: <ChartSeries>[
        LineSeries<Map<String, dynamic>, String>(
          dataSource: salesData,
          xValueMapper: (Map<String, dynamic> sales, _) =>
              sales['name'] as String,
          yValueMapper: (Map<String, dynamic> sales, _) =>
              chartType == 'Total Selling Price'
                  ? sales['totalPrice'] as double
                  : sales['quantity'] as int,
          name: chartType,
          markerSettings: MarkerSettings(isVisible: true),
          dataLabelSettings: DataLabelSettings(isVisible: true),
          enableTooltip: true,
        ),
      ],
    );
  }

  Widget _buildPieChart(String chartType) {
    return SfCircularChart(
      title: ChartTitle(text: '$chartType Distribution'),
      legend: Legend(isVisible: true),
      series: <CircularSeries>[
        PieSeries<Map<String, dynamic>, String>(
          dataSource: salesData,
          xValueMapper: (Map<String, dynamic> sales, _) =>
              sales['name'] as String,
          yValueMapper: (Map<String, dynamic> sales, _) =>
              chartType == 'Total Selling Price'
                  ? sales['totalPrice'] as double
                  : chartType == 'Total Quantity Sold'
                      ? sales['quantity'] as int
                      : sales['profit'] as double,
          dataLabelSettings: DataLabelSettings(isVisible: true),
          enableTooltip: true,
          explode: true,
          explodeIndex: 0,
        ),
      ],
    );
  }

    void _selectCustomDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked.start != null && picked.end != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
        selectedTimeFrame = 'Custom';
        fetchSalesData(selectedTimeFrame);
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

  if (timeFrame == 'Today') {
    DateTime now = DateTime.now();
    start = Timestamp.fromDate(DateTime(now.year, now.month, now.day));
    end = Timestamp.fromDate(DateTime(now.year, now.month, now.day).add(Duration(days: 1)));
  } else if (timeFrame == 'This Week') {
    DateTime now = DateTime.now();
    DateTime monday = DateTime(now.year, now.month, now.day - now.weekday + 1);
    DateTime nextMonday = monday.add(Duration(days: 7));
    start = Timestamp.fromDate(monday);
    end = Timestamp.fromDate(nextMonday);
  } else if (timeFrame == 'This Month') {
    DateTime now = DateTime.now();
    start = Timestamp.fromDate(DateTime(now.year, now.month, 1));
    end = Timestamp.fromDate(DateTime(now.year, now.month + 1, 1));
  } else if (timeFrame == 'This Year') {
    DateTime now = DateTime.now();
    start = Timestamp.fromDate(DateTime(now.year, 1, 1));
    end = Timestamp.fromDate(DateTime(now.year + 1, 1, 1));
  } else if (timeFrame == 'Custom' && startDate != null && endDate != null) {
    start = Timestamp.fromDate(startDate!);
    end = Timestamp.fromDate(endDate!.add(Duration(days: 1)));
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
      Map<String, dynamic> sale = doc.data() as Map<String, dynamic>;
      List<dynamic>? products = sale['products'] as List<dynamic>?;

      if (products != null && products.isNotEmpty) {
        for (var product in products) {
          String productName = product['name'] ?? '';
          int quantity = product['quantity'] ?? 0;
          double totalPrice = product['totalPrice'] ?? 0.0;
          double productCostPrice =
              productCostPrices[productName] ?? 0.0;
          double profit = totalPrice - (quantity * productCostPrice);

          // Update existing entry or add new entry
          var existingEntry = acc.firstWhere(
            (entry) => entry['name'] == productName,
            orElse: () => <String, dynamic>{
              'name': productName,
              'quantity': 0,
              'totalPrice': 0.0,
              'profit': 0.0,
            },
          );

          existingEntry['quantity'] += quantity;
          existingEntry['totalPrice'] += totalPrice;
          existingEntry['profit'] += profit;

          if (!acc.contains(existingEntry)) {
            acc.add(existingEntry);
          }
        }
      }

      return acc;
    });

    totalQuantity = salesData.fold<int>(0, (sum, sale) => sum + (sale['quantity'] as int? ?? 0));
    totalSellingPrice = salesData.fold<double>(0.0, (sum, sale) => sum + (sale['totalPrice'] as double? ?? 0.0));
    totalCostPrice = salesData.fold<double>(0.0, (sum, sale) {
      String productName = sale['name'] ?? '';
      double productCostPrice = productCostPrices[productName] ?? 0.0;
      return sum + (sale['quantity'] as int? ?? 0) * productCostPrice;
    });
    totalProfit = totalSellingPrice - totalCostPrice;

    setState(() {});

  } catch (e) {
    print('Error fetching sales data: $e');
  }
}

Future<Map<String, double>> fetchProductCostPrices() async {
  QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('products').get();

  Map<String, double> productCostPrices = {};

  querySnapshot.docs.forEach((doc) {
    productCostPrices[doc['name']] = doc['costPrice'].toDouble();
  });

  return productCostPrices;
}

String formatNumber(int number) {
  if (number >= 1000) {
    double result = number / 1000;
    return result.toStringAsFixed(result.truncateToDouble() == result ? 0 : 1) + 'K';
  } else {
    return number.toString();
  }
}
}
