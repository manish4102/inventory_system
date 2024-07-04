import 'package:flutter/material.dart';
import 'package:inventory_system/pages/expenses_data_charts_page.dart';
import 'package:inventory_system/pages/products_data_charts_page.dart';
import 'package:inventory_system/pages/sales_data_charts.dart';
import 'package:google_fonts/google_fonts.dart';

class InsightsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('INSIGHTS', style: GoogleFonts.poppins(fontSize: 20, color: Colors.black),),
        centerTitle: true,
        backgroundColor: Color.fromARGB(255, 112, 64, 244),
        leading: IconButton(
          onPressed: () {},
          icon: Icon(Icons.menu),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25),
            bottomRight: Radius.circular(25),
          ),
        ),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 50,),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SalesDataChartsPage()),
                );
              },
              style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 112, 64, 244)),
            minimumSize: MaterialStateProperty.all<Size>(Size(300, 50)),
          ),
              child: Text('Sales Data Charts', style: GoogleFonts.poppins(fontSize: 15, color: Colors.white),),
            ),
            SizedBox(height: 20,),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductsDataChartsPage()),
                );
              },
              style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 112, 64, 244)),
            minimumSize: MaterialStateProperty.all<Size>(Size(300, 50)),
          ),
              child: Text('Product Data Charts', style: GoogleFonts.poppins(fontSize: 15, color: Colors.white),),
            ),
            SizedBox(height: 20,),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ExpensesDataChartsPage()),
                );
              },
              style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Color.fromARGB(255, 112, 64, 244)),
            minimumSize: MaterialStateProperty.all<Size>(Size(300, 50)),
          ),
              child: Text('Expenses Data Charts', style: GoogleFonts.poppins(fontSize: 15, color: Colors.white),),
            ),
          ],
        ),
      ),
      
    );
  }
}
