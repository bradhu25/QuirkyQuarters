import 'package:flutter/material.dart';
import 'package:quirky_quarters/screens/receipt_summary.dart';
import 'dart:math';

class ItemAndCost<T1, T2> {
  String item;
  double cost;

  ItemAndCost(this.item, this.cost);
}

class EditExpenseRoute extends StatefulWidget {
  const EditExpenseRoute({super.key});

  @override
  State<EditExpenseRoute> createState() => _EditExpenseRouteState();
}

class _EditExpenseRouteState extends State<EditExpenseRoute> {
  var itemsAndCosts = [];

  final TextEditingController expenseTitleController = TextEditingController(text: "Expense #1");
  final TextEditingController itemController = TextEditingController();
  final TextEditingController costController = TextEditingController();

  addNewItemAndCost() {
    var item = itemController.text;
    var cost = double.tryParse(costController.text);
    if (item.isNotEmpty && cost != null) {
      setState(() {
        itemsAndCosts.add(ItemAndCost(item, cost));
        itemController.clear();
        costController.clear();
      });
    }
  }

  removeItemAndCost(int i) {
    setState(() {
        itemsAndCosts.removeAt(i);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Expense'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: DefaultTextStyle(
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  height: 2
                ),
            child: Column(
              children: [
                SizedBox(height: 20,),
                Container(
                  width: 300,
                  height: Theme.of(context).textTheme.headlineLarge!.fontSize,
                  child: TextField(
                    controller: expenseTitleController,
                    style: Theme.of(context).textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: 'Expense Title',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 10,),
                      Container(
                        width: max(MediaQuery.of(context).size.width * 0.1, 100),
                        child: Column(
                          children: [
                            // TODO: [UI] Add minimum width of column for when we don't 
                            // have any items yet. [Victoria]
                            Text("      ",
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            for (var i = 0; i < itemsAndCosts.length; i++)
                              IconButton(
                                icon: Icon(Icons.remove_circle_outline),
                                onPressed: () {
                                  removeItemAndCost(i);
                                },
                              ),
                          ]
                        ),
                      ),
      
                      // TODO: [UI] Make spacing between columns (buttons, items, costs) 
                      // dynamic to screen size. See Flexible / Expanded widget. [Victoria]
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Item", style: Theme.of(context).textTheme.headlineMedium),
                            for (var pair in itemsAndCosts) 
                              Padding(
                                padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.01), // Dynamic bottom padding based on screen height
                                child: Text(pair.item),
                              ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Cost", style: Theme.of(context).textTheme.headlineMedium),
                            for (var pair in itemsAndCosts) 
                              Padding(
                                padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.01), // Dynamic bottom padding based on screen height
                                child: Text("\$${pair.cost.toStringAsFixed(2)}"),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                Row(
                  children: [
                    SizedBox(width: 10,),
                    IconButton(
                            icon: Icon(Icons.add_circle_outline),
                            onPressed: () {
                              addNewItemAndCost();
                            },
                    ),
                    // TODO: [UI] Update container to Flexible / Expanded widget to match other items.
                    Flexible(
                      flex: 2, // Adjust the flex factor as needed for your design
                      child: Container(
                        height: Theme.of(context).textTheme.headlineSmall!.fontSize,
                        child: TextField(
                          controller: itemController,
                          style: Theme.of(context).textTheme.headlineSmall,
                          decoration: InputDecoration(hintText: 'New Item'),
                        ),
                      ),
                    ),
                    SizedBox(width: 50), // Consider using a smaller width or a Flexible spacer for responsiveness
                    Flexible(
                      flex: 2, // Adjust the flex factor as needed for your design
                      child: Container(
                        height: Theme.of(context).textTheme.headlineSmall!.fontSize,
                        child: TextField(
                          controller: costController,
                          style: Theme.of(context).textTheme.headlineSmall,
                          decoration: InputDecoration(hintText: 'Cost'),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),
                // TODO: [UI] Adjust Tax/Tip title and textbox alignment.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start, // Align row items to the start
                      children: [
                        SizedBox(width: 25), // Space before the label
                        Text(
                          "Tax:",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Expanded(
                          child: SizedBox(width: 25), // Optional, for additional space between label and field if needed
                        ),
                        Container(
                          width: 120, // Fixed width for the TextField container
                          child: TextField(
                            textAlign: TextAlign.center, // Center text within the TextField
                            decoration: InputDecoration(
                              hintText: 'Tax',
                              isDense: true, // Makes the TextField more compact
                              contentPadding: EdgeInsets.all(8), // Adjust padding inside the TextField
                            ),
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        Expanded(child: Container()), // Ensures the TextField stays centered in the overall row
                      ],
                    ),
                    SizedBox(height: 15), // Space between the Tax and Tip rows
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start, // Align row items to the start
                      children: [
                        SizedBox(width: 25), // Space before the label
                        Text(
                          "Tip:",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Expanded(
                          child: SizedBox(width: 25), // Optional, for additional space between label and field if needed
                        ),
                        Container(
                          width: 120, // Fixed width for the TextField container
                          child: TextField(
                            textAlign: TextAlign.center, // Center text within the TextField
                            decoration: InputDecoration(
                              hintText: 'Tip',
                              isDense: true,
                              contentPadding: EdgeInsets.all(8),
                            ),
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        Expanded(child: Container()), // Ensures the TextField stays centered in the overall row
                      ],
                    ),
                // TODO: [UI] Make Next/Camera buttons appear fixed at the bottom of
                // the screen. This means we can still see them when we scroll.
                SizedBox(height: 250),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                  // TODO: [UI] Fix spacing between 'Next' button and camera icon
                  children: [
                    Spacer(flex: 4,),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: [DEV] Implement Next button functionality and ensure cannot advance without filled out expenses.
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ReceiptSummaryRoute()),
                        );
                      },
                      child: const Text('Next'),
                    ),
                    Spacer(flex: 2), 
                    IconButton(
                      icon: Icon(Icons.camera_alt_outlined),
                      onPressed: () {
                        // TODO: [DEV] Implement camera icon functionality
                      },
                    ),
                    Spacer(flex: 1), 
                  ],
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}