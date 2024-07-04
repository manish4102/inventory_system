import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DataService {
  static Future<Map<String, dynamic>> fetchAndAnalyzeData() async {
    Map<String, dynamic> insight = {};

    try {
      // Get current user's ID
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Fetch sales data for the current user from Firestore
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('sales')
          .get();

      List<Map<String, dynamic>> salesData = querySnapshot.docs
          .map((doc) {
            Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
            data['time'] = (data['time'] as Timestamp).toDate().toIso8601String(); // Convert Timestamp to ISO String
            return data;
          })
          .toList();

      // Print the fetched data
      print('Fetched Data:');
      print(jsonEncode(salesData));

      final response = await http.post(
        Uri.parse('http://192.168.0.101:5000/analyze-data'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{'data': salesData}),
      );

      if (response.statusCode == 200) {
        insight = jsonDecode(response.body)['insight'];
      } else {
        insight = {'error': 'Failed to analyze data: ${response.body}'};
      }

      // Print the processed insight
      print('Processed Insight:');
      print(jsonEncode(insight));

    } catch (error) {
      insight = {'error': 'Error: $error'};
    }

    return insight;
  }
}
