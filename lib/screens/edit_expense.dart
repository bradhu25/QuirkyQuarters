import 'package:flutter/material.dart';
import 'package:quirky_quarters/screens/receipt_summary.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quirky_quarters/utils.dart';
import 'package:quirky_quarters/screens/photo.dart';
import 'package:permission_handler/permission_handler.dart';

class EditExpenseRoute extends StatefulWidget {
  final String? receiptId;
  const EditExpenseRoute({super.key, this.receiptId});

  @override
  State<EditExpenseRoute> createState() => _EditExpenseRouteState();
}

class _EditExpenseRouteState extends State<EditExpenseRoute> {

  Receipt receipt = Receipt.emptyReceipt();
  String receiptId = generateCode();

  final TextEditingController expenseTitleController = TextEditingController(text: "Untitled Expense");
  List<TextEditingController> itemControllers = [TextEditingController()];
  List<TextEditingController> costControllers = [TextEditingController()];
  final TextEditingController taxController = TextEditingController();
  final TextEditingController tipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initStateAsync();
  }

  void initStateAsync() async {
    if (widget.receiptId != null) {
      Receipt? fetchReceipt = await fetchReceiptData(widget.receiptId!);
      if (fetchReceipt != null) {
        setState(() {
          receiptId = widget.receiptId!;
          receipt = fetchReceipt;
          List<TextEditingController> existingItems = [];
          List<TextEditingController> existingCosts = [];
          
          for (var entry in receipt.entries) {
            existingItems.add(TextEditingController(text: entry.item));
            existingCosts.add(TextEditingController(text: entry.cost.toStringAsFixed(2)));
          }

          itemControllers = [...existingItems, TextEditingController()];
          costControllers = [...existingCosts, TextEditingController()];
        });
      }
    }
  }

  addExpensesToDatabase() {
    var tax = double.tryParse(taxController.text);
    var tip = double.tryParse(tipController.text);
    receipt.tax = tax;
    receipt.tip = tip;
    receipt.title = expenseTitleController.text;

    // TODO: [DEV] Consider update vs add case.
    FirebaseFirestore.instance
        .collection('receipt_book')
        .doc(receiptId)
        .withConverter(
          fromFirestore: Receipt.fromFirestore,
          toFirestore: (Receipt obj, options) => obj.toFirestore(),
        )
        .set(receipt)
        .onError((e, _) => print("Error writing document: $e"));

    // New receipt was created and saved.
    if (widget.receiptId == null) {
      FirebaseFirestore.instance
        .collection('receipts_per_user')
        .doc('default_user')
        .update({ 'receipts': FieldValue.arrayUnion([receiptId]) })
        .onError((e, _) => print("Error updating document: $e"));
    }
  }

  goToReceiptSummary() {
    if (receipt.entries.isEmpty) {
      return;
    }
    addExpensesToDatabase();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ReceiptSummaryRoute(receiptId: receiptId)),
    );
  }

  editItem(int i) {
    var item = itemControllers[i].text;
    if (item.isNotEmpty) {
      setState(() {
        receipt.entries[i].item = item;
      });
    }
  }
  
  editCost(int i) {
    var cost = double.tryParse(costControllers[i].text);
    if (cost != null) {
      setState(() {
        cost = (100 * cost!).truncateToDouble() / 100;
        costControllers[i].text = cost!.toStringAsFixed(2);
        
        receipt.total = receipt.total - receipt.entries[i].cost + cost!;
        receipt.entries[i].cost = cost!;
      });
    }
  }


  addNewItemAndCost() {
    var item = itemControllers.last.text;
    var cost = double.tryParse(costControllers.last.text);
    if (item.isNotEmpty && cost != null) {
      setState(() {
        cost = (100 * cost!).truncateToDouble() / 100;
        costControllers.last.text = cost!.toStringAsFixed(2);
        receipt.entries.add(ItemCostPayer(item: item, cost: cost!, payer: null));
        receipt.total += cost!;
        itemControllers.add(TextEditingController());
        costControllers.add(TextEditingController());
      });
    }
  }

  removeItemAndCost(int i) {
    setState(() {
        receipt.total -= receipt.entries[i].cost;
        receipt.entries.removeAt(i);
        itemControllers.removeAt(i);
        costControllers.removeAt(i);
    });
  }


  Future<void> _handleCameraPermissionAndNavigate() async {
    final cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      await Permission.camera.request();
    }
    if (await Permission.camera.isGranted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CameraPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Camera permission is required to take pictures")),
      );
    }
  }


@override
Widget build(BuildContext context) {
  //TODO: [DEV] Fix deprecation with PopScope
  return WillPopScope(
    onWillPop: () async {
      return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Unsaved Changes'),
          content: Text('Are you sure you want to leave without saving?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Yes'),
            ),
          ],
        ),
      ) ?? false; 
    },
    child: Scaffold( 
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
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      for (var i = 0; i < receipt.entries.length; i++)
                             IconButton(
                              icon: Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                 removeItemAndCost(i);
                              },
                             ),
                      ],
                    ),
                    SizedBox(width: 10), // Provides spacing between the button and the text fields
                    Expanded(
                      flex: 2, 
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // Align content to the start
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 12), // Align the label text with the TextField content
                            child: Text("Item", style: Theme.of(context).textTheme.headlineSmall),
                          ),
                          for (var i = 0; i < receipt.entries.length; i++) 
                            TextField(
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                border: OutlineInputBorder(), 
                              ),
                              controller: itemControllers[i],
                              onTapOutside: (_) { editItem(i); },
                              onSubmitted: (_) { editItem(i); },
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
                              controller: itemControllers.last,
                              onTapOutside: (_) { addNewItemAndCost(); },
                              onSubmitted: (_) { addNewItemAndCost(); },
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
                          for (var i = 0; i < receipt.entries.length; i++) 
                            TextField(
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                border: OutlineInputBorder(), 
                              ),
                              controller: costControllers[i],
                              onTapOutside: (_) { editCost(i); },
                              onSubmitted: (_) { editCost(i); },
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
                              controller: costControllers.last,
                              onTapOutside: (_){ addNewItemAndCost(); },
                              onSubmitted: (_){ addNewItemAndCost(); },
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
                                controller: taxController,
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
                                controller: tipController,
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
                      goToReceiptSummary();
                    },
                    child: const Text('Save'),
                  ),
                  IconButton(
                    icon: Icon(Icons.camera_alt_outlined),
                    onPressed: _handleCameraPermissionAndNavigate,
                  ),
                ],
              ),
            ),
          ),
      ),
      
    );
  }
}