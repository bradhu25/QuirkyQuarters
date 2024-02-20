import 'package:flutter/material.dart';
import 'package:quirky_quarters/screens/edit_expense.dart';

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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // TODO: [UI] Consider wrapping the text + edit widget to 
                  // prevent overflow (see Expanded/Flexible), and also center
                  // the "Expense Title" rather than entire row w/ Edit Icon

                  //TODO: [DEV] Load expense title in from Firebase
                  Text("Expense Title",
                    style: Theme.of(context).textTheme.headlineLarge,),
                  IconButton(icon: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EditExpenseRoute()),
                      );
                    },
                  )
                ]
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Column(
                    children: [
                      Text("     ",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      for (var i = 0; i < itemsCostsNames.length; i++)
                        IconButton(
                              icon: Text('÷', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                              // TODO: [DEV] implement divide entry functionality 
                              onPressed: () {},
                        ),
                    ]
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text("Item",
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text("Cost",
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text("Name",
                                style: Theme.of(context).textTheme.headlineMedium,
                              ),
                            ),
                          ]
                        ),
                        for (var i = 0; i < itemsCostsNames.length; i++)
                          // TODO: [UI] Make the highlight prettier (theme color, non-rectangular, whatever else)
                          GestureDetector(
                            onTap: () => selectItem(i),
                            child: Container(
                              color: selectedItems.contains(i) ? Color.fromARGB(255, 83, 242, 178) : Colors.transparent,
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text(itemsCostsNames[i].item),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text("\$${itemsCostsNames[i].cost.toStringAsFixed(2)}"),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(itemsCostsNames[i].name),
                                  ),
                                ]
                                ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ]
              ),
              // TODO: [UI] Make Next/Camera buttons appear fixed at the bottom of
              // the screen. This means we can still see them when we scroll.
              SizedBox(height: 250),
              // TODO: [UI] Add some padding around the buttons so that 
              // they don't go all the way from end to end of screen 
              Row(
                children: [
                  Expanded(
                    child: 
                      tagging 
                      ? TextField(
                            controller: payerController,
                            style: Theme.of(context).textTheme.headlineSmall,
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              hintText: 'Enter Name...',
                              border: InputBorder.none,
                            ),
                            onSubmitted: (name) {
                              tagPayer(name);       
                            },
                        )
                      : ElevatedButton(
                          onPressed: () {
                            setState((){ tagging = true; });
                          }, 
                          child: Text("Tag Payer")
                        ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      // TODO: [DEV] Implement Share Code functionality.
                      onPressed: () {}, 
                      child: Text("Share Code")
                      ),
                  ),
                  Expanded(
                    child: ElevatedButton(
                      // TODO: [DEV] Implement Next functionality.
                      onPressed: () {}, 
                      child: Text("Next")
                    ),
                  ),
                ]
              )
            ]
          )
        ),
      ),
    );
  }
}
