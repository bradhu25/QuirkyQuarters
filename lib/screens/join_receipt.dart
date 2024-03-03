import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quirky_quarters/screens/split_summary.dart';

class JoinReceiptRoute extends StatefulWidget {
  const JoinReceiptRoute({super.key});
    @override
  State<JoinReceiptRoute> createState() => _JoinReceiptRouteState();
}


class _JoinReceiptRouteState extends State<JoinReceiptRoute> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _submitCode() async {
    setState(() {
      _isLoading = true; // Show loading indicator
      _errorMessage = ''; // Reset error message
    });

    final String code = _codeController.text.trim();
    // fetching receipt data?
    final db = FirebaseFirestore.instance.collection("receipt_book");
    final querySnapshot = await db.where('code', isEqualTo: code).get();

    if (querySnapshot.docs.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SplitSummaryRoute()), 
      );
    } else {
      setState(() {
        _errorMessage = 'Invalid code. Please try again.';
      });
    }

    setState(() {
      _isLoading = false; 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Receipt'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Go Home',
            onPressed: () {
              Navigator.pop(context); 
            },
          ),
        ],
      ),
      body: Center(
                child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: 'Enter Receipt Code',
                  errorText: _errorMessage.isEmpty ? null : _errorMessage,
                ),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitCode,
                      child: const Text('Submit'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}