import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:quirky_quarters/screens/edit_expense.dart';
import 'package:quirky_quarters/screens/split_summary.dart';
import 'package:quirky_quarters/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';

class ReceiptSummaryRoute extends StatefulWidget {
  final String receiptId;
  const ReceiptSummaryRoute({super.key, required this.receiptId});

  @override
  State<ReceiptSummaryRoute> createState() => _ReceiptSummaryRouteState();
}

class _ReceiptSummaryRouteState extends State<ReceiptSummaryRoute> {

  Receipt receipt = Receipt.emptyReceipt();
  String receiptId = "";

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
        onePayerTagged = fetchReceipt.entries.any((entry) => entry.payer != null && entry.payer!.isNotEmpty);
      });
    }
  }

  Set<int> selectedItems = {};
  var tagging = false;
  var onePayerTagged = false;

  final TextEditingController payerController = TextEditingController();
  final TextEditingController divideController = TextEditingController();


  void selectItem(int itemIndex) {
    if (!tagging) return;
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
      onePayerTagged = false;
      for (var idx in selectedItems) {
        receipt.entries[idx].payer = name;
      }
      selectedItems.clear(); 
    });
    payerController.clear();
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
      }
    ); 
  }

  void showDivideDialog(BuildContext context, int i) {
      showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Enter # of people to split with"),
          content: TextField(
            controller: divideController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: "# of people"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); 
              },
            ),
            TextButton(
              child: Text("Done"),
              onPressed: () {
                int numberOfPeople = int.tryParse(divideController.text) ?? 1;
                setState(() {
                  receipt.entries[i].cost /= numberOfPeople;
                  receipt.duplicateEntry(i, numberOfPeople);
                });
                divideController.clear();
                Navigator.of(context).pop();
              }
            )
          ],
        );
      }
    );
  }

  addPayersToDatabase() {
    // TODO: [DEV] Instead of overwritting entire receipt, change only necessary fields.
    FirebaseFirestore.instance
        .collection('receipt_book')
        .doc(receiptId)
        .withConverter(
          fromFirestore: Receipt.fromFirestore,
          toFirestore: (Receipt obj, options) => obj.toFirestore(),
        )
        .set(receipt)
        .onError((e, _) => print("Error writing document: $e"));
  }

  goToSplitSummary() {
    addPayersToDatabase();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SplitSummaryRoute(receiptId: receiptId,)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Summary'),
        automaticallyImplyLeading: false, // disable back button
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Go Home',
            onPressed: () {
              _showReturnHomeDialog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
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
                            receipt.title,
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
                                  MaterialPageRoute(builder: (context) => EditExpenseRoute(receiptId: receiptId)),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // TODO: [DEV] Load expense title in from Firebase
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
                            child: Text("Payer", style: Theme.of(context).textTheme.headlineMedium),
                          ),
                        ],
                      ),
                    ),
                    // Dynamic List of Items
                    for (var i = 0; i < receipt.entries.length; i++) ...[
                      Row(
                        children: [
                          IconButton(
                            icon: Text('÷', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            onPressed: () {
                              // TODO: [DEV] Implement divide entry functionality.
                              showDivideDialog(context, i);
                            },
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () { selectItem(i); },
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
                                          child: Text(receipt.entries[i].item),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text("\$${receipt.entries[i].cost.toStringAsFixed(2)}"),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(receipt.entries[i].payer ?? ""),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (i < receipt.entries.length - 1) // Check to avoid adding a divider after the last item
                          Divider(color: Colors.grey),
                    ],
                  ],
                ),  
              ],
            )
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            if (!tagging) {
              tagging = true;
            } else {
                tagging = false;
              payerController.clear();
            }
          });
        },
        label: tagging ? Text('Done') : Text('Select Entries'),
        icon: tagging ? null : Icon(Icons.highlight_alt_outlined),
      ),
      bottomNavigationBar: 
      tagging
        ? BottomAppBar(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                controller: payerController,
                enabled: selectedItems.isNotEmpty, // Enable based on whether items are selected
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(height: 1.0),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Enter payer name...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 10.0),
                    enabledBorder: selectedItems.isNotEmpty 
                      ? OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: Colors.blue),
                        ) 
                      : OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                  ),
                onSubmitted: (value) {
                  if (selectedItems.isNotEmpty) {
                    setState(() {
                      tagPayer(value);
                      onePayerTagged = true;
                      tagging = true;
                    });
                  }
                },
                onTapOutside: (PointerDownEvent event) {
                  if (selectedItems.isNotEmpty) {
                    setState(() {
                      tagPayer(payerController.text);
                      onePayerTagged = true;
                      tagging = true;
                    });
                  }
                },
              ),
            ),
          )
        : BottomAppBar(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      String code = generateCode();
                      showCodeDialog(context, code);
                    },
                    child: Text("Share Code"),
                  ),
                  ElevatedButton(
                    onPressed: onePayerTagged ? () => goToSplitSummary() : null,
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (!states.contains(MaterialState.disabled)) return Theme.of(context).colorScheme.primary;
                          return Color.fromARGB(255, 236, 232, 232); // Use grey when the button is disabled
                        },
                      ),
                      foregroundColor: MaterialStateProperty.resolveWith<Color>(
                        (Set<MaterialState> states) {
                          if (!states.contains(MaterialState.disabled)) return Colors.white;
                          return Colors.black;
                        },
                      ),
                    ),
                    child: Text("Next"),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // animation to go back home. can be reused for other home navigations. 
  // swipes left animation instead of default swipe right animation that Navigator.of(context).pushNamed('/') would do
  // not currently called but keeping in case helpful for future animations
  Route _backToHome() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(-1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  void _showReturnHomeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Return to Home Page'),
          content: const Text('Are you sure? Unsaved changes will be lost.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst); // Pop back to the first route in the stack
              },
            ),
          ],
        );
      },
    );
  }
}