import 'package:flutter/material.dart';
import 'package:quirky_quarters/screens/join_receipt.dart';
import 'package:quirky_quarters/screens/edit_expense.dart';
import 'package:quirky_quarters/screens/receipt_summary.dart';
import 'package:quirky_quarters/screens/view_receipts.dart';

class ItemCostName {
  String item;
  double cost;
  String name;

  ItemCostName(this.item, this.cost, this.name);
}

class ReceiptSummaryRoute extends StatefulWidget {
  const ReceiptSummaryRoute({super.key});

  @override
  State<ReceiptSummaryRoute> createState() => _ReceiptSummaryRouteState();
}

class _ReceiptSummaryRouteState extends State<ReceiptSummaryRoute> {
  // this should be fethced from the receipt_summary as variables rather than hard coded
  List<ItemCostName> itemsCostsNames = [
    ItemCostName("Lamb Chops", 30.00, "Bradley"),
    ItemCostName("Steak", 50.00, "Gaby"),
    ItemCostName("Boba", 2.00, "Iris"),
    ItemCostName("Coke", 1.50, "Victoria"),
  ];

  // Mapping for person name and items associated with that person
  Map<String, List<ItemCostName>> itemsByPayer = {};

  @override
  void initState() {
    super.initState();
    // Organize items by payer's name
    for (var item in itemsCostsNames) {
      final name = item.name;
      if (itemsByPayer.containsKey(name)) {
        itemsByPayer[name]!.add(item);
      } else {
        itemsByPayer[name] = [item];
      }
    }
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
          children: entry.value.map((itemCostName) {
            return ListTile(
              title: Text(itemCostName.item),
              trailing: Text('\$${itemCostName.cost.toStringAsFixed(2)}'),
            );
          }).toList(),
        ),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Summary'),
      ),
      body: ListView(
        children: [
          ...payerTiles,
        ],
      ),
    );
  }
}
