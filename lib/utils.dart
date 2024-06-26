import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class Receipt<T1> {
  String title;
  List<ItemCostPayer> entries;
  double? tax;
  double? tip;
  double total;
  List<String> resolvedPayers;
  String fronter;

  Receipt(
    {required this.title, 
    required this.entries, 
    this.tax,
    this.tip,
    required this.total,
    required this.resolvedPayers,
    required this.fronter,}
    );
  
  Receipt.emptyReceipt() 
    : title = "Expense #1",
      entries = [],
      total = 0.00,
      resolvedPayers = [],
      fronter = "";

  factory Receipt.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Receipt(
      title: data?['title'],
      entries: [
        for (var entry in data?['entries'])
          ItemCostPayer.fromFirestore(entry, options),
      ],
      tax: data?['tax'] == null ? 0.0 : data?['tax'].toDouble(),
      tip: data?['tip'] == null ? 0.0 : data?['tip'].toDouble(),
      total: data?['total'].toDouble(),
      resolvedPayers: List<String>.from(data?['resolvedPayers'] ?? []),
      fronter: data?['fronter'] ?? "",
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "title": title,
      "entries": [ 
        for (var entry in entries)
          entry.toFirestore()
      ],
      "tax": tax,
      "tip": tip,
      "total": total,
      "resolvedPayers": resolvedPayers,
      "fronter": fronter,
    };
  }

  void divideEntry(int index, int numDivide) {
    if (index < 0 || index >= entries.length || numDivide < 1) return;
    
    ItemCostPayer itemToDivide = entries[index];
    itemToDivide.cost /= numDivide;
    for (int i = 0; i < numDivide - 1; i++) {
      ItemCostPayer newEntry = ItemCostPayer.copy(itemToDivide);
      newEntry.payer = null;
      entries.insert(index, newEntry);
    }
  }

  @override toString() {
    String receiptString = "";
    receiptString += "title: $title\n";
    receiptString += "tax: $tax\n";
    receiptString += "tip: $tip\n";
    receiptString += "entries:\n";
    for (var entry in entries) {
      receiptString += "     ${entry.item}, ${entry.cost}, ${entry.payer}\n";
    }
    
    return receiptString;
  }
}

class ItemCostPayer<T1, T2, T3> {
  String item;
  double cost;
  String? payer;

  ItemCostPayer({required this.item, required this.cost, this.payer});

  ItemCostPayer.copy(ItemCostPayer original)
      : item = original.item,
        cost = original.cost,
        payer = original.payer;

  factory ItemCostPayer.fromFirestore(
    Map<String, dynamic> entry,
    SnapshotOptions? options,
  ) {
    return ItemCostPayer(
      item: entry['item'],
      cost: entry['cost'].toDouble(),
      payer: entry['payer'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "item": item,
      "cost": cost,
      if (payer != null) "payer": payer,
    };
  }
}

String generateCode() {
    var rng = Random();
    var code = List.generate(6, (_) => rng.nextInt(9)).join();
    return code;
}

Future<Receipt?> fetchReceiptData(String receiptId) async {
    // Read from Firebase
    final db = FirebaseFirestore.instance
    .collection("receipt_book")
    .doc(receiptId)
    .withConverter(
      fromFirestore: Receipt.fromFirestore,
      toFirestore: (Receipt obj, _) => obj.toFirestore(),
    );

    final docSnap = await db.get();
    return docSnap.data();
}