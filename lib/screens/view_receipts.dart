import 'package:flutter/material.dart';
import 'package:quirky_quarters/screens/receipt_summary.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quirky_quarters/utils.dart';


class ViewReceiptsRoute extends StatefulWidget {
  const ViewReceiptsRoute({super.key});

  @override
  State<ViewReceiptsRoute> createState() => _ViewReceiptsRouteState();
}

class _ViewReceiptsRouteState extends State<ViewReceiptsRoute> {
  Future<void>? waitToFetchReceips;  
  Map<String, String> userReceipts = {};

  @override
  void initState() {
    super.initState();
    waitToFetchReceips = initStateAsync();
  }

  Future<void> initStateAsync() async {
    
    try {
      // Load receipts belonging to user.
      final receiptsPerUser = await FirebaseFirestore.instance
        .collection('receipts_per_user')
        .doc('default_user')
        .get();

      if(receiptsPerUser.data() != null && receiptsPerUser.data()?['receipts'] != null) {
        Map<String, String> fetchingTitles = {};
        // Fetch receipts in reverse order so they appear in order of recency.
        for (int i = receiptsPerUser.data()!['receipts'].length - 1; i > -1; i--) {
          // Load receipt data to fetch expense title.
          var receiptId = receiptsPerUser.data()!['receipts'][i];
          Receipt? receipt = await fetchReceiptData(receiptId.toString());
          if (receipt != null) {
            fetchingTitles[receiptId.toString()] = receipt.title;
          }
        }
        setState(() {
          userReceipts = fetchingTitles;
        });
      } 
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Receipts'),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Go Home',
            onPressed: () {
              Navigator.pop(context); // go back to previous page
            },
          ),
        ],
      ),
      body: 
        FutureBuilder<void>(
        future: waitToFetchReceips,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView(
              children: [
                ...userReceipts.entries.map((receipt) {
                  return TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ReceiptSummaryRoute(receiptId: receipt.key)),
                            );
                          },
                          child: Text(receipt.value),
                        );
                })
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}