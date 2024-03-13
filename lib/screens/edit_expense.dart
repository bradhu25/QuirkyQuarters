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
  final formKey = GlobalKey<FormState>();

  final TextEditingController expenseTitleController = TextEditingController();
  final TextEditingController fronterController = TextEditingController(); // for the person who pays the whole bill
  List<TextEditingController> itemControllers = [TextEditingController()];
  List<TextEditingController> costControllers = [TextEditingController()];
  final TextEditingController taxController = TextEditingController();
  final TextEditingController tipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initStateAsync();
  }

  @override
  void dispose() {
    expenseTitleController.dispose();
    fronterController.dispose();
    taxController.dispose();
    tipController.dispose();
    for (final controller in itemControllers) {
      controller.dispose();
    }
    for (final controller in costControllers) {
      controller.dispose();
    }
    super.dispose();
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
          // Set the fronter and title from the fetched receipt
          fronterController.text = receipt.fronter;
          expenseTitleController.text = receipt.title;
          taxController.text = (receipt.tax != null || receipt.tax == 0.0) ? "" : receipt.tax!.toStringAsFixed(2);
          tipController.text = (receipt.tip != null || receipt.tip == 0.0) ? "" : receipt.tip!.toStringAsFixed(2);

          
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
    var fronter = fronterController.text;
    var tax = double.tryParse(taxController.text);
    var tip = double.tryParse(tipController.text);
    receipt.fronter = fronter;
    receipt.tax = tax;
    receipt.tip = tip;
    receipt.title = expenseTitleController.text;

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
    if (formKey.currentState?.validate() == false) {
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
    if (await Permission.camera.isGranted && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const CameraPage()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Camera permission is required to take pictures")),
      );
    }
  }


@override
Widget build(BuildContext context) {
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
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Center(
            child: DefaultTextStyle(
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    height: 2
                  ),
              child: Column(
                children: [
                  SizedBox(height: 20),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      controller: expenseTitleController,
                      style: Theme.of(context).textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText: 'Expense Title',
                        hintText: 'Expense Title',
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction, 
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 30),
                  SizedBox(
                    width: 300,
                    child: TextFormField(
                      controller: fronterController,
                      decoration: InputDecoration(
                        labelText: 'Fronter',
                        border: OutlineInputBorder(),
                      ),
                      autovalidateMode: AutovalidateMode.onUserInteraction, 
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a Fronter';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(height: 30),
                  Row(
                    children: [
                      SizedBox(width: 48),
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: EdgeInsets.only(left: 12), // Align the label text with the TextField content
                          child: Text("Items", style: Theme.of(context).textTheme.headlineSmall),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Padding(
                                padding: EdgeInsets.only(left: 6), // Align the label text with the TextField content
                                child: Text("Cost", style: Theme.of(context).textTheme.headlineSmall),
                        ),
                      ),
                    ]
                  ),
                  // Dynamic List of Items
                  for (var i = 0; i < receipt.entries.length; i++) ...[
                    Row(
                      children: [
                        IconButton(
                            icon: Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              removeItemAndCost(i);
                            },
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                      border: OutlineInputBorder(), 
                                    ),
                                    autovalidateMode: AutovalidateMode.onUserInteraction, 
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter an Item';
                                      }
                                      return null;
                                    },
                                    controller: itemControllers[i],
                                    onTapOutside: (_) { 
                                      FocusScope.of(context).unfocus();
                                      editItem(i);
                                    },
                                    onFieldSubmitted: (_) { editItem(i); },
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 36.0),
                                  child: TextFormField(
                                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                                    textInputAction: TextInputAction.done,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                      border: OutlineInputBorder(), 
                                    ),
                                    autovalidateMode: AutovalidateMode.onUserInteraction, 
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter an Cost';
                                      } else if (num.tryParse(value) == null) {
                                        return 'Please enter a Cost';
                                      }
                                      return null;
                                    },
                                    controller: costControllers[i],
                                    onTapOutside: (_) { 
                                      FocusScope.of(context).unfocus();
                                      editCost(i);
                                    },
                                    onFieldSubmitted: (_) { editCost(i); },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove_circle_outline, color: Colors.grey),
                        onPressed: null,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    hintText: 'Enter Item',
                                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                    border: OutlineInputBorder(), 
                                  ),
                                  autovalidateMode: AutovalidateMode.onUserInteraction, 
                                  validator: (value) {
                                    if (itemControllers.length == 1 && (value == null || value.isEmpty)) {
                                      return 'Please enter an Item';
                                    } else if (itemControllers.length > 1 && receipt.entries.isEmpty) {
                                      return 'Please enter an Item';
                                    }
                                    return null;
                                  },
                                  controller: itemControllers.last,
                                  onTapOutside: (_) { 
                                    FocusScope.of(context).unfocus();
                                    addNewItemAndCost();
                                  },
                                  onFieldSubmitted: (_) { addNewItemAndCost(); },
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 36.0),
                                child: TextFormField(
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  textInputAction: TextInputAction.done,
                                  decoration: InputDecoration(
                                    hintText: 'Enter Cost',
                                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                    border: OutlineInputBorder(), 
                                  ),
                                  autovalidateMode: AutovalidateMode.onUserInteraction, 
                                  validator: (value) {
                                    if (costControllers.length == 1 && (value == null || value.isEmpty)) {
                                      return 'Please enter a Cost';
                                    } else if (costControllers.length > 1 && receipt.entries.isEmpty) {
                                      return 'Please enter a Cost';
                                    } else if (value != null && value.isNotEmpty && num.tryParse(value) == null) {
                                      return 'Please enter a Cost';
                                    }

                                    return null;
                                  },
                                  controller: costControllers.last,
                                  onTapOutside: (_){ 
                                    FocusScope.of(context).unfocus();
                                    addNewItemAndCost();
                                  },
                                  onFieldSubmitted: (_) { addNewItemAndCost(); },
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
                    padding: const EdgeInsets.symmetric(horizontal: 18), // Keep padding for overall alignment
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("Tax:", style: Theme.of(context).textTheme.headlineSmall),
                            SizedBox(width: 10), // Space between label and field
                            Flexible(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width / 2 - 20, // Half the screen width minus padding
                                child: TextFormField(
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  textInputAction: TextInputAction.done,
                                  controller: taxController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter Tax',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                  ),
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty && num.tryParse(value) == null) {
                                      return 'Please enter a number';
                                    }
                                    return null;
                                  }
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
                            SizedBox(width: 12), // Space between label and field
                            Flexible(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width / 2 - 20, // Half the screen width minus padding
                                child: TextFormField(
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  textInputAction: TextInputAction.done,
                                  controller: tipController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter Tip',
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                  ),
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty && num.tryParse(value) == null) {
                                      return 'Please enter a number';
                                    }
                                    return null;
                                  }
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleCameraPermissionAndNavigate,
        tooltip: 'Take Picture',
        child: Icon(Icons.camera_alt_outlined),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomAppBar(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  goToReceiptSummary();
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
  );}
  }
