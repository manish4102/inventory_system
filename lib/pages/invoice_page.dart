import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

class InvoiceItem {
  final String description;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });
}

class Invoice {
  final double subtotal;
  final double tax;
  final double total;
  final List<InvoiceItem> items;

  Invoice({
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.items,
  });
}

class InvoiceScreen extends StatelessWidget {
  final Invoice invoice;

  InvoiceScreen({required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invoice', style: GoogleFonts.poppins(fontSize: 20, color: Colors.black),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invoice Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text('Subtotal: \$${invoice.subtotal}'),
            Text('Tax: ${invoice.tax}%'),
            Text('Total: \$${invoice.total}'),
            SizedBox(height: 20),
            Text(
              'Items:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('Description')),
                  DataColumn(label: Text('Quantity')),
                  DataColumn(label: Text('Unit Price')),
                  DataColumn(label: Text('Total Price')),
                ],
                rows: invoice.items
                    .map(
                      (item) => DataRow(
                        cells: [
                          DataCell(Text(item.description)),
                          DataCell(Text(item.quantity.toString())),
                          DataCell(Text('\$${item.unitPrice.toStringAsFixed(2)}')),
                          DataCell(Text('\$${item.totalPrice.toStringAsFixed(2)}')),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InvoicePage extends StatefulWidget {
  const InvoicePage({Key? key}) : super(key: key);

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  File? _imageFile;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      _processImage(context);
    }
  }

  Future<void> _processImage(BuildContext context) async {
    final inputImage = InputImage.fromFilePath(_imageFile!.path);
    final textRecognizer = TextRecognizer();
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
    List<TextBlock> extractedText = recognizedText.blocks;

    print(extractedText);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Extracted Text'),
          content: SingleChildScrollView(
            child: DataTable(
              columns: <DataColumn>[
                DataColumn(
                  label: Text('Text'),
                ),
              ],
              rows: extractedText.map((block) {
                return DataRow(
                  cells: <DataCell>[
                    DataCell(Text(block.text)),
                  ],
                );
              }).toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google MLKit Text Recognition', style: TextStyle(fontSize: 22)),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _imageFile == null ? Text('Select an image to analyze. ') : Image.file(_imageFile!),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick Image'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
