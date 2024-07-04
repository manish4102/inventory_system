// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class ProductsDataChartsPage extends StatefulWidget {
//   @override
//   _ProductsDataChartsPageState createState() => _ProductsDataChartsPageState();
// }

// class _ProductsDataChartsPageState extends State<ProductsDataChartsPage> {
//   String selectedTimeFrame = 'Today';
//   DateTime? startDate;
//   DateTime? endDate;
//   List<Map<String, dynamic>> productsData = [];
//   String selectedChartType = 'Column';

//   @override
//   void initState() {
//     super.initState();
//     fetchProductsData(selectedTimeFrame);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Products Data Charts'),
//         centerTitle: true,
//         backgroundColor: Color.fromARGB(255, 138, 99, 246),
//         leading: IconButton(
//           onPressed: () {
//             Navigator.pop(context);
//           },
//           icon: Icon(Icons.arrow_back),
//         ),
//       ),
//       body: Center(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             DropdownButton<String>(
//               value: selectedTimeFrame,
//               onChanged: (String? newValue) {
//                 if (newValue == 'Custom') {
//                   _selectCustomDateRange(context);
//                 } else {
//                   setState(() {
//                     startDate = null;
//                     endDate = null;
//                     selectedTimeFrame = newValue!;
//                     fetchProductsData(selectedTimeFrame);
//                   });
//                 }
//               },
//               items: <String>[
//                 'Today',
//                 'This Week',
//                 'This Month',
//                 'This Year',
//                 'Custom'
//               ].map<DropdownMenuItem<String>>((String value) {
//                 return DropdownMenuItem<String>(
//                   value: value,
//                   child: Text(value),
//                 );
//               }).toList(),
//             ),
//             if (selectedTimeFrame == 'Custom' &&
//                 startDate != null &&
//                 endDate != null)
//               Text(
//                   'Selected Date Range: ${startDate?.toLocal()} - ${endDate?.toLocal()}'),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () {
//                 _showChartDialog('Quantity');
//               },
//               child: Text('Product Quantity Chart'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showChartDialog(String chartType) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('$chartType Chart'),
//           content: Container(
//             height: 150,
//             child: Column(
//               children: [
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                     _displayChart(chartType, 'Column');
//                   },
//                   child: Text('Column Chart'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                     _displayChart(chartType, 'Line');
//                   },
//                   child: Text('Line Chart'),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                     _displayChart(chartType, 'Pie');
//                   },
//                   child: Text('Pie Chart'),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   void _displayChart(String chartType, String displayType) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: Text('$chartType $displayType Chart'),
//           content: Container(
//             height: 300,
//             child: displayType == 'Column'
//                 ? _buildColumnChart()
//                 : displayType == 'Line'
//                     ? _buildLineChart()
//                     : _buildPieChart(),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildColumnChart() {
//     return SfCartesianChart(
//       title: ChartTitle(text: 'Products Quantity Comparison'),
//       primaryXAxis: CategoryAxis(),
//       series: <ChartSeries>[
//         ColumnSeries<Map<String, dynamic>, String>(
//           dataSource: productsData,
//           xValueMapper: (Map<String, dynamic> product, _) => product['product'] as String,
//           yValueMapper: (Map<String, dynamic> product, _) => product['quantity'] as int,
//           name: 'Quantity',
//           dataLabelSettings: DataLabelSettings(isVisible: true),
//           enableTooltip: true,
//         ),
//       ],
//     );
//   }

//   Widget _buildLineChart() {
//     return SfCartesianChart(
//       title: ChartTitle(text: 'Products Quantity Comparison Over Time'),
//       primaryXAxis: CategoryAxis(),
//       series: <ChartSeries>[
//         LineSeries<Map<String, dynamic>, String>(
//           dataSource: productsData,
//           xValueMapper: (Map<String, dynamic> product, _) => product['product'] as String,
//           yValueMapper: (Map<String, dynamic> product, _) => product['quantity'] as int,
//           name: 'Quantity',
//           markerSettings: MarkerSettings(isVisible: true),
//           dataLabelSettings: DataLabelSettings(isVisible: true),
//           enableTooltip: true,
//         ),
//       ],
//     );
//   }

//   Widget _buildPieChart() {
//     return SfCircularChart(
//       title: ChartTitle(text: 'Products Quantity Distribution'),
//       legend: Legend(isVisible: true),
//       series: <CircularSeries>[
//         PieSeries<Map<String, dynamic>, String>(
//           dataSource: productsData,
//           xValueMapper: (Map<String, dynamic> product, _) => product['product'] as String,
//           yValueMapper: (Map<String, dynamic> product, _) => product['quantity'] as int,
//           dataLabelSettings: DataLabelSettings(isVisible: true),
//           enableTooltip: true,
//           explode: true,
//           explodeIndex: 0,
//         ),
//       ],
//     );
//   }

//   void _selectCustomDateRange(BuildContext context) async {
//     final DateTimeRange? picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );

//     if (picked != null && picked.start != null && picked.end != null) {
//       setState(() {
//         startDate = picked.start;
//         endDate = picked.end;
//         selectedTimeFrame = 'Custom';
//         fetchProductsData(selectedTimeFrame);
//       });
//     }
//   }

//   Future<void> fetchProductsData(String timeFrame) async {
//     CollectionReference users = FirebaseFirestore.instance.collection('Users');
//     final user = FirebaseAuth.instance.currentUser;

//     Timestamp start = Timestamp.now();
//     Timestamp end = Timestamp.now();

//     if (timeFrame == 'Today') {
//       DateTime now = DateTime.now();
//       start = Timestamp.fromDate(DateTime(now.year, now.month, now.day));
//       end = Timestamp.fromDate(DateTime(now.year, now.month, now.day).add(Duration(days: 1)));
//     } else if (timeFrame == 'This Week') {
//       DateTime now = DateTime.now();
//       DateTime monday = DateTime(now.year, now.month, now.day - now.weekday + 1);
//       DateTime nextMonday = monday.add(Duration(days: 7));
//       start = Timestamp.fromDate(monday);
//       end = Timestamp.fromDate(nextMonday);
//     } else if (timeFrame == 'This Month') {
//       DateTime now = DateTime.now();
//       start = Timestamp.fromDate(DateTime(now.year, now.month, 1));
//       end = Timestamp.fromDate(DateTime(now.year, now.month + 1, 1));
//     } else if (timeFrame == 'This Year') {
//       DateTime now = DateTime.now();
//       start = Timestamp.fromDate(DateTime(now.year, 1, 1));
//       end = Timestamp.fromDate(DateTime(now.year + 1, 1, 1));
//     } else if (timeFrame == 'Custom' && startDate != null && endDate != null) {
//       start = Timestamp.fromDate(startDate!);
//       end = Timestamp.fromDate(endDate!.add(Duration(days: 1)));
//     }

//     try {
//       QuerySnapshot productsQuery = await users
//           .doc(user?.uid)
//           .collection('Products')
//           .where('time', isGreaterThanOrEqualTo: start)
//           .where('time', isLessThan: end)
//           .get();

//       productsData = productsQuery.docs.map((doc) {
//         return {
//           'description': doc['description'],
//           'price': doc['price'],
//           'product': doc['product'],
//           'quantity': doc['quantity'],
//           'time': doc['time'],
//           'vendor': doc['vendor'],
//         };
//       }).toList();

//       setState(() {});

//     } catch (e) {
//       print('Error fetching products data: $e');
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductsDataChartsPage extends StatefulWidget {
  @override
  _ProductsDataChartsPageState createState() => _ProductsDataChartsPageState();
}

class _ProductsDataChartsPageState extends State<ProductsDataChartsPage> {
  String selectedTimeFrame = 'Today';
  DateTime? startDate;
  DateTime? endDate;
  List<Map<String, dynamic>> productsData = [];
  String selectedChartType = 'Column';

  @override
  void initState() {
    super.initState();
    fetchProductsData(selectedTimeFrame);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products Data Charts', style: GoogleFonts.poppins(fontSize: 20, color: Colors.black),),
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
                    fetchProductsData(selectedTimeFrame);
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
                  'Selected Date Range: ${startDate?.toLocal()} - ${endDate?.toLocal()}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showChartDialog('Quantity');
              },
              style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 112, 64, 244)),
            minimumSize: MaterialStateProperty.all<Size>(Size(300, 50)),
          ),
              child: Text('Product Quantity Chart', style: GoogleFonts.poppins(fontSize: 15, color: Colors.white),),
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
            height: 180,
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
                ? _buildColumnChart()
                : displayType == 'Line'
                    ? _buildLineChart()
                    : _buildPieChart(),
          ),
        );
      },
    );
  }

  Widget _buildColumnChart() {
  return SfCartesianChart(
    title: ChartTitle(text: 'Products Quantity Comparison'),
    primaryXAxis: CategoryAxis(title: AxisTitle(text: 'Product')),
    primaryYAxis: NumericAxis(
      title: AxisTitle(text: 'Quantity'),
      numberFormat: NumberFormat.decimalPattern(),
    ),
    series: <ChartSeries>[
      ColumnSeries<Map<String, dynamic>, String>(
        dataSource: productsData,
        xValueMapper: (Map<String, dynamic> product, _) =>
            product['product'] as String,
        yValueMapper: (Map<String, dynamic> product, _) =>
            product['quantity'] as int,
        name: 'Quantity',
        dataLabelSettings: DataLabelSettings(isVisible: true),
        enableTooltip: true,
      ),
    ],
  );
}


  Widget _buildLineChart() {
  return SfCartesianChart(
    title: ChartTitle(text: 'Products Quantity Comparison Over Time'),
    primaryXAxis: CategoryAxis(title: AxisTitle(text: 'Product')),
    primaryYAxis: NumericAxis(
      title: AxisTitle(text: 'Quantity'),
      numberFormat: NumberFormat.decimalPattern(),
    ),
    series: <ChartSeries>[
      LineSeries<Map<String, dynamic>, String>(
        dataSource: productsData,
        xValueMapper: (Map<String, dynamic> product, _) =>
            product['product'] as String,
        yValueMapper: (Map<String, dynamic> product, _) =>
            product['quantity'] as int,
        name: 'Quantity',
        markerSettings: MarkerSettings(isVisible: true),
        dataLabelSettings: DataLabelSettings(isVisible: true),
        enableTooltip: true,
      ),
    ],
  );
}


  Widget _buildPieChart() {
  return SfCircularChart(
    title: ChartTitle(text: 'Products Quantity Distribution'),
    legend: Legend(isVisible: true),
    series: <CircularSeries>[
      PieSeries<Map<String, dynamic>, String>(
        dataSource: productsData,
        xValueMapper: (Map<String, dynamic> product, _) =>
            product['product'] as String,
        yValueMapper: (Map<String, dynamic> product, _) =>
            product['quantity'] as int,
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
        fetchProductsData(selectedTimeFrame);
      });
    }
  }

  Future<void> fetchProductsData(String timeFrame) async {
    CollectionReference users = FirebaseFirestore.instance.collection('Users');
    final user = FirebaseAuth.instance.currentUser;

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
  }
}