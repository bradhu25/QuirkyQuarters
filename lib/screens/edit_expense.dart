import 'package:flutter/material.dart';
import 'package:quirky_quarters/screens/receipt_summary.dart';
import 'package:quirky_quarters/screens/photo.dart';


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
                  crossAxisAlignment: CrossAxisAlignment.end, // Aligns widgets at the bottom, useful if they have different heights
                  children: [
                    IconButton(
                      icon: Icon(Icons.add_circle_outline),
                      onPressed: () {
                        addNewItemAndCost();
                      },
                    ),
                    SizedBox(width: 10), // Provides spacing between the button and the text fields
                    Expanded(
                      flex: 2, 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // Align content to the start
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 12), // Align the label text with the TextField content
                            child: Text("New Item", style: Theme.of(context).textTheme.headlineSmall),
                          ),
                          Container(
                            margin: EdgeInsets.only(right: 10), 
                            constraints: BoxConstraints(maxWidth: 150), // Smaller width for the text box
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Enter Item',
                                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                border: OutlineInputBorder(), 
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 2, 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // Align content to the start
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 12), // Align the label text with the TextField content
                            child: Text("Cost", style: Theme.of(context).textTheme.headlineSmall),
                          ),
                          Container(
                            margin: EdgeInsets.only(right: 10), // Added to prevent the box from touching the screen's side
                            constraints: BoxConstraints(maxWidth: 150), // Smaller width for the text box
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Enter Cost',
                                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                border: OutlineInputBorder(), // Adds a border around the TextField
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Divider(
                  color: Colors.grey, 
                  thickness: 1, 
                  indent: 20, 
                  endIndent: 20, 
                ),
                SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10), // Keep padding for overall alignment
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Tax:", style: Theme.of(context).textTheme.headlineSmall),
                          SizedBox(width: 10), // Space between label and field
                          Flexible(
                            child: Container(
                              width: MediaQuery.of(context).size.width / 2 - 20, // Half the screen width minus padding
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Tax',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                ),
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15), // Space between Tax and Tip rows
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text("Tip:", style: Theme.of(context).textTheme.headlineSmall),
                          SizedBox(width: 10), // Space between label and field
                          Flexible(
                            child: Container(
                              width: MediaQuery.of(context).size.width / 2 - 20, // Half the screen width minus padding
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Tip',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                ),
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
          bottomNavigationBar: BottomAppBar(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // TODO: [DEV] Implement Next button functionality and ensure it does not proceed without fields
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ReceiptSummaryRoute()),
                      );
                    },
                    child: const Text('Next'),
                  ),
                  IconButton(
                    icon: Icon(Icons.camera_alt_outlined),
                    onPressed: () {
                      // TODO: [DEV] Implement camera icon functionality
                      /*Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CameraPage()),
                      );*/
                    },
                  ),
                ],
              ),
            ),
          ),
    );
  }
}