import 'dart:async';
import 'dart:isolate';
import 'dart:convert';

class PythonRunner {
  static Future<Map<String, dynamic>> analyzeData(List<Map<String, dynamic>> salesData) async {
    ReceivePort receivePort = ReceivePort();

    await Isolate.spawn(_analyzeData, {'salesData': salesData, 'receivePort': receivePort.sendPort});

    final completer = Completer<Map<String, dynamic>>();
    receivePort.listen((message) {
      completer.complete(message);
    });

    return completer.future;
  }

  static void _analyzeData(Map<String, dynamic> message) async {
    try {
      List<Map<String, dynamic>> salesData = message['salesData'];
      SendPort sendPort = message['receivePort'];

      print("Received data: $salesData");  // Debugging line

      // Analyze the data
      Map<String, dynamic> insights = {};

      for (var sale in salesData) {
        for (var product in sale['products']) {
          String productName = product['name'];
          int quantity = product['quantity'];
          double price = product['price'];
          double totalPrice = product['totalPrice'];

          double profitPerUnit = price - (totalPrice / quantity);
          double totalProfit = profitPerUnit * quantity;

          if (insights.containsKey(productName)) {
            insights[productName]['quantity'] += quantity;
            insights[productName]['total_profit'] += totalProfit;
          } else {
            insights[productName] = {
              'quantity': quantity,
              'average_price': price,
              'total_profit': totalProfit
            };
          }
        }
      }

      sendPort.send(insights);
    } catch (error) {
      print('Error: $error'); // Print the error to console
    }
  }
}
