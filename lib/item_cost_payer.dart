import 'package:cloud_firestore/cloud_firestore.dart';

class Receipt<T1> {
  List<ItemCostPayer> entries;

  Receipt({required this.entries});

  factory Receipt.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Receipt(
      entries: [
        for (var entry in data?['entries'])
          ItemCostPayer.fromFirestore(entry, options),
      ],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      "entries": [ 
        for (var entry in entries)
          entry.toFirestore()
      ],
    };
  }

  @override toString() {
    String receiptString = "";
    for (var entry in entries) {
      receiptString += "${entry.item}, ${entry.cost}, ${entry.payer}";
    }
    return receiptString;
  }
}

class ItemCostPayer<T1, T2, T3> {
  String item;
  double cost;
  String? payer;

  ItemCostPayer({required this.item, required this.cost, this.payer});

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
