import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:quirky_quarters/screens/edit_expense.dart';
import 'package:quirky_quarters/screens/split_summary.dart';

// TODO: [DEV] Add ItemCostName to file with reusable classes.
class ItemCostName<T1, T2> {
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
  
  // TODO: [DEV] Load items and costs from Firebase.
  var itemsCostsNames = [
    ItemCostName("Lamb Chops", 30.00, ""), 
    ItemCostName("Steak", 50.00, ""), 
    ItemCostName("Boba", 2.00, ""),
    ItemCostName("Coke", 1.50, "")
  ];

  Set<int> selectedItems = {};
  var tagging = false;

  final TextEditingController payerController = TextEditingController();

  void selectItem(int itemIndex) {
    setState(() {
      if (selectedItems.contains(itemIndex)) {
        selectedItems.remove(itemIndex);
      } else {
        selectedItems.add(itemIndex);
      }
    });
  }

  tagPayer(String name) {
    setState((){ 
      tagging = false; 
      for (var idx in selectedItems) {
        itemsCostsNames[idx].name = name;
      }
      selectedItems.clear(); 
    });
    payerController.clear();
  }

  String generateCode() {
    var rng = Random();
    var code = List.generate(6, (_) => rng.nextInt(9)).join();
    return code;
  }

  void showCodeDialog(BuildContext context, String code) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Your Code"),
          content: Text(code),
          actions: <Widget>[
            TextButton(
              child: Text("Copy"),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                Navigator.of(context).pop(); 
              },
            ),
            TextButton(
              child: Text("Close"),
              onPressed: () {
                Navigator.of(context).pop(); 
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // TODO: [DEV] Consider design of back button when user flow is not linear,
      // e.g., when the user goes back and forth between editing and the summary.
      appBar: AppBar(
        title: const Text('Receipt Summary'),
      ),
      body: Center(
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  height: 2
                ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded( 
                    child: Stack(
                      alignment: Alignment.center, 
                      children: [
                        Text(
                          "Expense Title",
                          style: Theme.of(context).textTheme.headlineLarge,
                          textAlign: TextAlign.center,
                        ),
                        Positioned(
                          right: 0, 
                          child: IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const EditExpenseRoute()),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
                  //TODO: [DEV] Load expense title in from Firebase
              Column(
                children: [
                  // Header Row with Titles
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
                    child: Row(
                      children: [
                        SizedBox(width: 48), // Space allocated for the divide symbol button
                        Expanded(
                          flex: 3,
                          child: Text("Item", style: Theme.of(context).textTheme.headlineMedium),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text("Cost", style: Theme.of(context).textTheme.headlineMedium),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text("Name", style: Theme.of(context).textTheme.headlineMedium),
                        ),
                      ],
                    ),
                  ),
                  // Dynamic List of Items
                  for (var i = 0; i < itemsCostsNames.length; i++)
                  Row(
                    children: [
                      IconButton(
                        icon: Text('÷', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          // TODO: [DEV] Implement add entry functionality
                        },
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              if (selectedItems.contains(i)) {
                                selectedItems.remove(i);
                              } else {
                                selectedItems.add(i);
                              }
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: selectedItems.contains(i) ? Colors.lightBlueAccent.withOpacity(0.5) : Colors.transparent, // Highlight if selected
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Padding(
                                      padding: EdgeInsets.only(left: 12), 
                                      child: Text(itemsCostsNames[i].item),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text("\$${itemsCostsNames[i].cost.toStringAsFixed(2)}"),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(itemsCostsNames[i].name),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),  
            ]
          )
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  String code = generateCode();
                  showCodeDialog(context, code);
                },
                child: Text("Share Code"),
              ),
              if (tagging)
                ElevatedButton(
                  onPressed: () {
                  },
                  child: Text("Confirm Tag"),
                )
              else
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      tagging = true;
                    });
                  },
                  // TODO: [DEV] Implement Tag Payer functionality
                  child: Text("Tag Payer"),
                ),
              ElevatedButton(
                onPressed: () {
                  // TODO: [DEV] Implement Next functionality
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SplitSummaryRoute()),
                  );
                },
                child: Text("Next"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
