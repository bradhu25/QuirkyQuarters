import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class TextScannerPage extends StatefulWidget {
  final String imagePath;

  const TextScannerPage({Key? key, required this.imagePath}) : super(key: key);

  @override
  State<TextScannerPage> createState() => _TextScannerPageState();
}

class _TextScannerPageState extends State<TextScannerPage> {
  String _recognizedText = "Scanning...";
  final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  @override
  void initState() {
    super.initState();
    _performTextRecognition();
  }

  @override
  void dispose() {
    textRecognizer.close();
    super.dispose();
  }

  Future<void> _performTextRecognition() async {
    try {
      final inputImage = InputImage.fromFilePath(widget.imagePath);
      final recognizedText = await textRecognizer.processImage(inputImage);
        
      setState(() {
        print("Recognized text before: $_recognizedText");
        _recognizedText = recognizedText.text;
        print("Recognized text after: $_recognizedText");
      });

      
      // Show the dialog after text recognition
      WidgetsBinding.instance.addPostFrameCallback((_) => _showRecognizedTextDialog(context, _recognizedText));
    } catch (e) {
      print(e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An error occurred when scanning text'),
          ),
        );
      }
    }
  }

  void _showRecognizedTextDialog(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Recognized Text'),
          content: SingleChildScrollView(
            child: Text(text),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
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
        title: const Text('Text Scanner'),
      ),
      body: Center(
        child: _recognizedText == "Scanning..."
            ? Image.network(widget.imagePath)
            : Text(_recognizedText)
            // ? const CircularProgressIndicator()
            // : SingleChildScrollView(
            //     child: Text(_recognizedText),
            //   ),
      ),
    );
  }
}
