import 'package:flutter/material.dart';

// TODO: [DEV] Move ItemCostName to file for shared classes.
class ItemCostName {
  String item;
  double cost;
  String name;

  ItemCostName(this.item, this.cost, this.name);
}

class SplitSummaryRoute extends StatefulWidget {
  const SplitSummaryRoute({super.key});

  @override
  State<SplitSummaryRoute> createState() => _SplitSummaryRouteState();
}

class _SplitSummaryRouteState extends State<SplitSummaryRoute> {
  // TODO: [DEV] Fetch using Firebase.
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
    // TODO: [DEV] Consider case where item has not been tagged. We could still
    // have those items in a drop down with the `name' as "Untagged Items".
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
