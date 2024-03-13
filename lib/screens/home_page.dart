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
    final String code = codeController.text.trim();
    if (code == "") {
      return;
    }

    setState(() {
      errorMessage = null;
    });

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
        errorMessage = 'Invalid code.';
      });
    }
  }

  //TODO: [UI] Change font, background, and buttons to appear more aesthetically pleasing
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
    onTap: () {
      // Close the keyboard if the user taps outside of the TextField
      FocusScope.of(context).requestFocus(new FocusNode());
      // Revert back to showing the "Join Receipt" button if in joiningReceipt mode
      if (joiningReceipt) {
        setState(() {
          codeController.clear();
          joiningReceipt = false;
        });
      }
    },
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Quirky Quarters'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', width: 250, height: 250,), 
            ElevatedButton.icon(
              icon: Icon(Icons.receipt), 
              label: Text('Start Receipt'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditExpenseRoute()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(240, 60),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                textStyle: TextStyle(
                  fontSize: 20, // This increases the font size
                ),
              ),
            ),
            SizedBox(height: 15),
            FractionallySizedBox(
              widthFactor: 1,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (joiningReceipt) 
                    Container(
                      width: 240,
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              controller: codeController,
                              decoration: InputDecoration(
                                labelText: 'Enter Receipt Code',
                                errorText: errorMessage,
                              ),
                              onSubmitted: (_) async { await submitCode(); },
                            ),
                          ),
                          IconButton(
                            onPressed: () async { await submitCode(); },
                            icon: Icon(Icons.arrow_forward_ios),
                          ),
                        ],
                      ),
                    ),
                  if (!joiningReceipt)
                    Container(
                      width: 240,
                      child: ElevatedButton.icon(
                        icon: Icon(Icons.input), 
                        label: Text('Join Receipt'),
                        onPressed: () { setState(() { joiningReceipt = true; }); },
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(240, 60),
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          textStyle: TextStyle(
                            fontSize: 20, // This increases the font size
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 15),
            ElevatedButton.icon(
              icon: Icon(Icons.visibility), 
              label: Text('View Receipts'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ViewReceiptsRoute()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(240, 60),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                textStyle: TextStyle(
                  fontSize: 20, // This increases the font size
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}