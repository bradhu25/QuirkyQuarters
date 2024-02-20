import 'package:flutter/material.dart';
import 'package:quirky_quarters/screens/join_receipt.dart';
import 'package:quirky_quarters/screens/edit_expense.dart';
import 'package:quirky_quarters/screens/receipt_summary.dart';
import 'package:quirky_quarters/screens/view_receipts.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quirky Quarters'),
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
            ElevatedButton(
              child: const Text('Join Receipt'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const JoinReceiptRoute()),
                );
              },
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

            SizedBox(height: 10),
            ElevatedButton(
              child: const Text('DEV'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ReceiptSummaryRoute()),
                );
              },
            ),
          ]
        ),
      ),
    );
  }
}