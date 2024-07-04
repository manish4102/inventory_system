import 'package:flutter/material.dart';
import 'package:inventory_system/pages/add_products_page.dart';
import 'package:inventory_system/pages/add_sales_page.dart';
import 'package:inventory_system/pages/expenses_page.dart';
import 'package:inventory_system/pages/forgot_password_page.dart';
import 'package:inventory_system/pages/home_page.dart';
import 'package:inventory_system/pages/insights_page.dart';
import 'package:inventory_system/pages/invoice_page.dart';
import 'package:inventory_system/pages/login_page.dart';
import 'package:inventory_system/pages/products_page.dart';
import 'package:inventory_system/pages/register_page.dart';
import 'package:inventory_system/pages/sales_page.dart';
import 'package:inventory_system/pages/sales_report_page.dart';

const String loginPage = 'login_Page';
const String registerPage = 'register_Page';
const String homePage = 'home_Page';
const String productsPage = 'products_Page';
const String salesPage = 'sales_Page';
const String addproductsPage = 'add_products_Page';
const String forgotpasswordPage = 'forgot_password_Page';
const String expensesPage = 'expenses_Page';
const String salesReportPage = 'sales_report_Page';
const String insightsPage = 'insights_Page';
const String invoicePage = 'invoice_Page';

Route <dynamic> controller(RouteSettings settings) {
  switch(settings.name) {
    case ('login_Page'):
      return MaterialPageRoute(builder: (context) => LogInPage());
    case ('register_Page'):
      return MaterialPageRoute(builder: (context) => RegisterPage());
    case ('home_Page'):
      return MaterialPageRoute(builder: (context) => HomePage());
    case ('products_Page'):
      return MaterialPageRoute(builder: (context) => ProductsPage());
    case ('sales_Page'):
      return MaterialPageRoute(builder: (context) => SalesPage());
    case ('add_products_Page'):
      return MaterialPageRoute(builder: (context) => AddProductsPage());
    case ('forgot_password_Page'):
      return MaterialPageRoute(builder: (context) => ForgotPasswordPage());
    case ('add_sales_Page'):
      return MaterialPageRoute(builder: (context) => AddSalesPage());
    case('expenses_Page'):
      return MaterialPageRoute(builder: (context) => ExpensesPage());
    case('invoice_Page'):
      return MaterialPageRoute(builder: (context) => InvoicePage());
    case('insights_Page'):
      return MaterialPageRoute(builder: (context) => InsightsPage());
    case('sales_report_Page'):
      //return MaterialPageRoute(builder: (context) => SalesReportPage);
    default:
      throw('Oopps pressed wrong button!!');
  }
}