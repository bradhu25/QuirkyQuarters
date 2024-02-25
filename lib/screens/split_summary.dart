import 'package:flutter/material.dart';
import 'package:quirky_quarters/item_cost_payer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SplitSummaryRoute extends StatefulWidget {
  const SplitSummaryRoute({super.key});

  @override
  State<SplitSummaryRoute> createState() => _SplitSummaryRouteState();
}

class _SplitSummaryRouteState extends State<SplitSummaryRoute> {
  // TODO: [DEV] Fetch using Firebase.

  Receipt receipt = Receipt.emptyReceipt();

  // Mapping for person name and items associated with that person
  Map<String, List<ItemCostPayer>> itemsByPayer = {};

  @override
  void initState() {
    super.initState();
    // TODO: [DEV] Factor out into utils file.
    fetchReceiptData();
    // organizeItemsByPayer();
  }

  void organizeItemsByPayer() {
    setState(() {
      for (var entry in receipt.entries) {
        final name = entry.payer ?? "Untagged Items";
        if (itemsByPayer.containsKey(name)) {
          itemsByPayer[name]!.add(entry);
        } else {
          itemsByPayer[name] = [entry];
        }
      }
    });
  }

  void fetchReceiptData() async {
    // Read from Firebase
    final db = FirebaseFirestore.instance
    .collection("receipt_book")
    .doc("xMvRGYWtwhYYCEQscFZo")
    .withConverter(
      fromFirestore: Receipt.fromFirestore,
      toFirestore: (Receipt obj, _) => obj.toFirestore(),
    );

    final docSnap = await db.get();
    if (docSnap.data != null) {
      setState(() {
        receipt = docSnap.data()!; // Convert to Receipt object
      }); 
    }
    organizeItemsByPayer();
  }

  @override
  Widget build(BuildContext context) {
    // Create a list of ExpansionTiles for each payer 
    List<Widget> payerTiles = itemsByPayer.entries.map((payer) {
      double payer_total = payer.value.fold(0, (prev, item) => prev + item.cost);
      return Card(
        child: ExpansionTile(
          title: Text(payer.key),
          subtitle: Text('Total: \$${payer_total.toStringAsFixed(2)}'),
          children: 
            [  
            ...payer.value.map((entry) {
                return ListTile(
                  title: Text(entry.item),
                  trailing: Text('\$${entry.cost.toStringAsFixed(2)}'),
                );
              }).toList(),
            if (receipt.tax != null)
              ListTile(
                  title: Text("Tax:"),
                  trailing: Text('\$${(payer_total / receipt.total * receipt.tax!).toStringAsFixed(2)}'),
                ),
            if (receipt.tip != null)
              ListTile(
                  title: Text("Tip:"),
                  trailing: Text('\$${(payer_total / receipt.total * receipt.tip!).toStringAsFixed(2)}'),
                ),

            ]
        ),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Split Summary'),
      ),
      body: ListView(
        children: [
          ...payerTiles,
        ],
      ),
    );
  }
}
