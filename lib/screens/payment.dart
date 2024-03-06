import 'package:flutter/material.dart';
import 'home_page.dart';
import 'package:quirky_quarters/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class PaymentScreen extends StatefulWidget {
  final String receiptId;

  PaymentScreen({Key? key, required this.receiptId}) : super(key: key);

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool showWhoAreYou = true;
  Receipt receipt = Receipt.emptyReceipt();
  String? selectedUser;
  String? nonFronter;
  List<String> nonFronters = []; 
  String? fronter;
  List<String> names = [];
  double? amountOwed;

  @override
  void initState() {
    super.initState();
    initStateAsync();
  }

  void initStateAsync() async {   
    Receipt? fetchReceipt = await fetchReceiptData(widget.receiptId);
    if (fetchReceipt != null) {
      setState(() {
        receipt = fetchReceipt;
      });
    }
    fetchFronterAndPayers();
  }

  void fetchFronterAndPayers() async {
    setState(() {
      fronter = receipt.fronter; 
      Set<String> uniquePayers = receipt.entries 
          .map((entry) => entry.payer ?? '') // Extract payers from entries
          .toSet(); // Convert list of payers to a set to eliminate duplicates 
      if (uniquePayers.contains(fronter)) {
        uniquePayers.remove(fronter);
      }
      nonFronters = uniquePayers.toList(); // Convert back to list

      names = nonFronters.toList();
      names.add(fronter!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Time to Square Up!'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (showWhoAreYou) buildUserDropdown(), // show the who are you dropdown conditionally
            if (selectedUser != null)
              // get rid of buildUserDropdown
              if (selectedUser == fronter)
                ...buildFronterUI()
              else
                ...buildNonFronterUI(),
          ],
        ),
      ),
    );
  }

  Widget buildUserDropdown() {
    return DropdownButton<String>(
      hint: Text('Who are you?'),
      value: selectedUser,
      onChanged: (String? newValue) {
        setState(() {
          selectedUser = newValue;
          amountOwed = calculateAmountOwedByPayer(newValue); // Update amount owed if needed
          showWhoAreYou = newValue == null; // make who are you dropdown disappear if a user is selected
        });
      },
      items: names.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  List<Widget> buildFronterUI() {
  return [
    Row(
      mainAxisSize: MainAxisSize.min, // Use minimum space needed by the children
      children: [
        Text(' Hi  '),
        buildUserDropdown(),
      ],
    ),
    DropdownButton<String>(
      value: nonFronter,
      hint: Text('Who are you requesting from?'),
      onChanged: (String? newValue) {
        setState(() {
          nonFronter = newValue;
          amountOwed = calculateAmountOwedByPayer(newValue);
        });
      },
      items: nonFronters.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    ),
    if (nonFronter != null) 
      Text('owes you ${amountOwed?.toStringAsFixed(2)}'),
    ];
  }

  

  List<Widget> buildNonFronterUI() {
    return [
      Row(
        mainAxisSize: MainAxisSize.min, // Use minimum space needed by the children
        children: [
          Text(' Hi  '),
          buildUserDropdown(),
        ],
      ),
      Text("you owe $fronter \$${amountOwed?.toStringAsFixed(2)}")
    ];
  }


  double calculateAmountOwedByPayer(String? payerName) {
    if (payerName == null) return 0.0;

    // Calculate raw total for the payer
    final double rawTotal = receipt.entries
        .where((entry) => entry.payer == payerName)
        .fold(0.0, (sum, entry) => sum + entry.cost);

    // Calculate payer's share of the tip and tax based on their raw total
    final double payerTip = receipt.tip != null ? rawTotal / receipt.total * receipt.tip! : 0;
    final double payerTax = receipt.tax != null ? rawTotal / receipt.total * receipt.tax! : 0;

    // Calculate total amount owed by the payer
    final double payerTotal = rawTotal + payerTip + payerTax;

    return payerTotal;
  }
}