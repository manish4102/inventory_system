// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class ExpensesDataChartsPage extends StatefulWidget {
//   @override
//   _ExpensesDataChartsPageState createState() => _ExpensesDataChartsPageState();
// }

// class _ExpensesDataChartsPageState extends State<ExpensesDataChartsPage> {
//   String selectedTimeFrame = 'Today';
//   DateTime? startDate;
//   DateTime? endDate;
//   List<Map<String, dynamic>> expensesData = [];
//   String selectedChartType = 'Column';

//   @override
//   void initState() {
//     super.initState();
//     fetchExpensesData(selectedTimeFrame);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Expenses Data Charts'),
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
//                     fetchExpensesData(selectedTimeFrame);
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
//                 _showChartDialog('Expense Cost');
//               },
//               child: Text('Expense Cost Chart'),
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
//       title: ChartTitle(text: 'Expenses Cost Comparison'),
//       primaryXAxis: CategoryAxis(),
//       series: <ChartSeries>[
//         ColumnSeries<Map<String, dynamic>, String>(
//           dataSource: expensesData,
//           xValueMapper: (Map<String, dynamic> expense, _) => expense['expenseType'] as String,
//           yValueMapper: (Map<String, dynamic> expense, _) => expense['cost'] as double,
//           name: 'Cost',
//           dataLabelSettings: DataLabelSettings(isVisible: true),
//           enableTooltip: true,
//         ),
//       ],
//     );
//   }

//   Widget _buildLineChart() {
//     return SfCartesianChart(
//       title: ChartTitle(text: 'Expenses Cost Comparison Over Time'),
//       primaryXAxis: CategoryAxis(),
//       series: <ChartSeries>[
//         LineSeries<Map<String, dynamic>, String>(
//           dataSource: expensesData,
//           xValueMapper: (Map<String, dynamic> expense, _) => expense['expenseType'] as String,
//           yValueMapper: (Map<String, dynamic> expense, _) => expense['cost'] as double,
//           name: 'Cost',
//           markerSettings: MarkerSettings(isVisible: true),
//           dataLabelSettings: DataLabelSettings(isVisible: true),
//           enableTooltip: true,
//         ),
//       ],
//     );
//   }

//   Widget _buildPieChart() {
//     return SfCircularChart(
//       title: ChartTitle(text: 'Expenses Cost Distribution'),
//       legend: Legend(isVisible: true),
//       series: <CircularSeries>[
//         PieSeries<Map<String, dynamic>, String>(
//           dataSource: expensesData,
//           xValueMapper: (Map<String, dynamic> expense, _) => expense['expenseType'] as String,
//           yValueMapper: (Map<String, dynamic> expense, _) => expense['cost'] as double,
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
//         fetchExpensesData(selectedTimeFrame);
//       });
//     }
//   }

//   Future<void> fetchExpensesData(String timeFrame) async {
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
//       QuerySnapshot expensesQuery = await users
//           .doc(user?.uid)
//           .collection('Expenses')
//           .where('timestamp', isGreaterThanOrEqualTo: start)
//           .where('timestamp', isLessThan: end)
//           .get();

//       expensesData = expensesQuery.docs.map((doc) {
//         return {
//           'cost': doc['cost'] as double,  // <-- Changed type to double
//           'expenseType': doc['expenseType'] as String,
//           'timestamp': doc['timestamp'],
//         };
//       }).toList();

//       setState(() {});

//     } catch (e) {
//       print('Error fetching expenses data: $e');
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Added import for NumberFormat
import 'package:google_fonts/google_fonts.dart';

class ExpensesDataChartsPage extends StatefulWidget {
  @override
  _ExpensesDataChartsPageState createState() => _ExpensesDataChartsPageState();
}

class _ExpensesDataChartsPageState extends State<ExpensesDataChartsPage> {
  String selectedTimeFrame = 'Today';
  DateTime? startDate;
  DateTime? endDate;
  List<Map<String, dynamic>> expensesData = [];
  String selectedChartType = 'Column';

  @override
  void initState() {
    super.initState();
    fetchExpensesData(selectedTimeFrame);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expenses Data Charts', style: GoogleFonts.poppins(fontSize: 20, color: Colors.black)),
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
                    fetchExpensesData(selectedTimeFrame);
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
                  'Selected Date Range: ${DateFormat('dd/MM/yyyy').format(startDate!)} - ${DateFormat('dd/MM/yyyy').format(endDate!)}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _showChartDialog('Expense Cost');
              },
              style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 112, 64, 244)),
            minimumSize: MaterialStateProperty.all<Size>(Size(300, 50)),
          ),
              child: Text('Expense Cost Chart', style: GoogleFonts.poppins(fontSize: 15, color: Colors.white),),
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
      title: ChartTitle(text: 'Expenses Cost Comparison'),
      primaryXAxis: CategoryAxis(
        title: AxisTitle(text: 'Expense Type'),
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: 'Cost (₹)'),
        numberFormat: NumberFormat.compactCurrency(locale: 'en_US', symbol: '₹'), // Using compact format with ₹ symbol
      ),
      series: <ChartSeries>[
        ColumnSeries<Map<String, dynamic>, String>(
          dataSource: expensesData,
          xValueMapper: (Map<String, dynamic> expense, _) => expense['expenseType'] as String,
          yValueMapper: (Map<String, dynamic> expense, _) => expense['cost'] as double,
          name: 'Cost',
          dataLabelSettings: DataLabelSettings(isVisible: true),
          enableTooltip: true,
        ),
      ],
    );
  }

  Widget _buildLineChart() {
    return SfCartesianChart(
      title: ChartTitle(text: 'Expenses Cost Comparison Over Time'),
      primaryXAxis: CategoryAxis(
        title: AxisTitle(text: 'Expense Type'),
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: 'Cost (₹)'),
        numberFormat: NumberFormat.compact(), // Using compact format with ₹ symbol
      ),
      series: <ChartSeries>[
        LineSeries<Map<String, dynamic>, String>(
          dataSource: expensesData,
          xValueMapper: (Map<String, dynamic> expense, _) => expense['expenseType'] as String,
          yValueMapper: (Map<String, dynamic> expense, _) => expense['cost'] as double,
          name: 'Cost',
          markerSettings: MarkerSettings(isVisible: true),
          dataLabelSettings: DataLabelSettings(isVisible: true),
          enableTooltip: true,
        ),
      ],
    );
  }

  Widget _buildPieChart() {
    return SfCircularChart(
      title: ChartTitle(text: 'Expenses Cost Distribution'),
      legend: Legend(isVisible: true),
      series: <CircularSeries>[
        PieSeries<Map<String, dynamic>, String>(
          dataSource: expensesData,
          xValueMapper: (Map<String, dynamic> expense, _) => expense['expenseType'] as String,
          yValueMapper: (Map<String, dynamic> expense, _) => expense['cost'] as double,
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
        fetchExpensesData(selectedTimeFrame);
      });
    }
  }

  Future<void> fetchExpensesData(String timeFrame) async {
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

    try {
      QuerySnapshot expensesQuery = await users
          .doc(user?.uid)
          .collection('Expenses')
          .where('timestamp', isGreaterThanOrEqualTo: start)
          .where('timestamp', isLessThan: end)
          .get();

      expensesData = expensesQuery.docs.map((doc) {
        return {
          'cost': doc['cost'] as double,  // <-- Changed type to double
          'expenseType': doc['expenseType'] as String,
          'timestamp': doc['timestamp'],
        };
      }).toList();

      setState(() {});

    } catch (e) {
      print('Error fetching expenses data: $e');
    }
  }
}