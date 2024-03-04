import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quirky_quarters/screens/edit_expense.dart';
import 'package:quirky_quarters/screens/view_receipts.dart';
import 'package:quirky_quarters/screens/split_summary.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool joiningReceipt = false;
  TextEditingController codeController = TextEditingController();
  String? errorMessage;

  // TODO: [DEV] Dispose text controllers elsewhere in the code.
  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  Future<void> submitCode() async {
    setState(() {
      errorMessage = null;
    });

    final String code = codeController.text.trim();
    final db = FirebaseFirestore.instance
              .collection("receipt_book")
              .doc(code);
    final docSnap = await db.get();

    if (docSnap.data() != null) {
      if (!context.mounted) return;
      setState(() {
        joiningReceipt = false;
        codeController.clear();
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SplitSummaryRoute(receiptId: code,)), 
      );
    } else {
      setState(() {
        errorMessage = 'Invalid code. Please try again.';
      });
    }
  }

  //TODO: [UI] Change font, background, and buttons to appear more aesthetically pleasing
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quirky Quarters'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text('Start Receipt'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditExpenseRoute()),
                );
              },
            ),
            SizedBox(height: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                joiningReceipt ? 
                  TextField(
                    controller: codeController,
                    decoration: InputDecoration(
                      labelText: 'Enter Receipt Code',
                      errorText: errorMessage,
                    ),
                    onTapOutside: (_) async { await submitCode(); },
                    onSubmitted: (_) async { await submitCode(); },
                  ) : 
                  ElevatedButton(
                    child: const Text('Join Receipt'),
                    onPressed: () { setState(() { joiningReceipt = true; }); },
                  ),
              ]
            ),
            SizedBox(height: 10),
            ElevatedButton(
              child: const Text('View Receipts'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ViewReceiptsRoute()),
                );
              },
            ),
          ]
        ),
      ),
    );
  }
}