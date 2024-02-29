import 'package:flutter/material.dart';
import 'package:quirky_quarters/utils.dart';

class SplitSummaryRoute extends StatefulWidget {
  final String receiptId;
  const SplitSummaryRoute({super.key, required this.receiptId});

  @override
  State<SplitSummaryRoute> createState() => _SplitSummaryRouteState();
}

class _SplitSummaryRouteState extends State<SplitSummaryRoute> {

  Receipt receipt = Receipt.emptyReceipt();
  String receiptId = "";

  // Mapping for person name and items associated with that person
  Map<String, List<ItemCostPayer>> itemsByPayer = {};

  @override
  void initState() {
    super.initState();
    initStateAsync();
  }

  void initStateAsync() async {   
    Receipt? fetchReceipt = await fetchReceiptData(widget.receiptId);
    if (fetchReceipt != null) {
      setState(() {
        receiptId = widget.receiptId;
        receipt = fetchReceipt;
      });
    }

    organizeItemsByPayer();
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

  @override
  Widget build(BuildContext context) {
    // Create a list of ExpansionTiles for each payer 
    List<Widget> payerTiles = itemsByPayer.entries.map((payer) {
      double rawTotal = payer.value.fold(0, (prev, item) => prev + item.cost);
      double payerTip = receipt.tip != null ? rawTotal / receipt.total * receipt.tip! : 0;
      double payerTax = receipt.tax != null ? rawTotal / receipt.total * receipt.tax! : 0;
      double payerTotal = rawTotal + payerTip + payerTax;
      
      return Card(
        child: ExpansionTile(
          title: Text(payer.key),
          subtitle: Text('Total: \$${payerTotal.toStringAsFixed(2)}'),
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
                  trailing: Text('\$${payerTax.toStringAsFixed(2)}'),
                ),
            if (receipt.tip != null)
              ListTile(
                  title: Text("Tip:"),
                  trailing: Text('\$${payerTip.toStringAsFixed(2)}'),
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
