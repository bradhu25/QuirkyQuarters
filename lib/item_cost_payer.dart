import 'package:cloud_firestore/cloud_firestore.dart';

class Receipt<T1> {
  String title;
  List<ItemCostPayer> entries;
  double? tax;
  double? tip;
  double total;
  List<String> resolvedPayers;

  Receipt(
    {required this.title, 
    required this.entries, 
    this.tax,
    this.tip,
    required this.total,
    required this.resolvedPayers}
    );
  
  Receipt.emptyReceipt() 
    : title = "Expense #1",
      entries = [],
      total = 0.00,
      resolvedPayers = [];

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
      tax: data?['tax'],
      tip: data?['tip'],
      total: data?['total'],
      resolvedPayers: [
        for (var entry in data?['entries'])
          entry.toString(),
      ],
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
    };
  }

  void duplicateEntry(int index, int numDivide) {
    if (index < 0 || index >= entries.length || numDivide < 1) return;
    
    ItemCostPayer itemToDivide = entries[index];
    for (int i = 0; i < numDivide - 1; i++) {
      entries.insert(index, ItemCostPayer.copy(itemToDivide));
    }
  }

  @override toString() {
    String receiptString = "";
    receiptString += "title: ${title}\n";
    receiptString += "tax: ${tax}\n";
    receiptString += "tip: ${tip}\n";
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
      cost: entry['cost'],
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
