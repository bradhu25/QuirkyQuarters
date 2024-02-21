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

  Receipt receipt = Receipt(entries: []);

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
    List<Widget> payerTiles = itemsByPayer.entries.map((entry) {
      double total = entry.value.fold(0, (prev, item) => prev + item.cost);
      return Card(
        child: ExpansionTile(
          title: Text(entry.key),
          subtitle: Text('Total: \$${total.toStringAsFixed(2)}'),
          children: entry.value.map((entry) {
            return ListTile(
              title: Text(entry.item),
              trailing: Text('\$${entry.cost.toStringAsFixed(2)}'),
            );
          }).toList(),
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
