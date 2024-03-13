import 'package:flutter/material.dart';
import 'package:quirky_quarters/utils.dart';
import 'package:url_launcher/url_launcher.dart';


class PaymentScreen extends StatefulWidget {
  final String receiptId;

  PaymentScreen({Key? key, required this.receiptId}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
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
      body: Center(
        child: Padding(  
          padding: const EdgeInsets.all(8.0),
          child: Theme(
            data: ThemeData(
              textTheme: TextTheme(
                bodyLarge: TextStyle(fontSize: 80), // not working
              ),
            ),
            child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (showWhoAreYou) buildUserDropdown(), // show the who are you dropdown conditionally
                if (selectedUser != null)
                  if (selectedUser == fronter)
                    ...buildFronterUI()
                  else
                    ...buildNonFronterUI(),
              ],
            ),
          ),
        )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _launchVenmo,
        tooltip: 'Pay with Venmo',
        child: Icon(Icons.payment),
      ),
    );
  }

  Widget buildUserDropdown() {
    return DropdownButton<String>(
      hint: Text('Who are you?', style: TextStyle(fontSize: 36)),
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
          child: Text(value, style: TextStyle(fontSize: 36)),
        );
      }).toList(),
    );
  }

  List<Widget> buildFronterUI() {
  return [
    Row(
      mainAxisSize: MainAxisSize.min, // Use minimum space needed by the children
      children: [
        Text(' Hi  ', style: TextStyle(fontSize: 36)),
        buildUserDropdown(),
      ],
    ),
    SizedBox(height: 25),
    DropdownButton<String>(
      value: nonFronter,
      hint: Text('Who are you requesting?', style: TextStyle(fontSize: 26)),
      onChanged: (String? newValue) {
        setState(() {
          nonFronter = newValue;
          amountOwed = calculateAmountOwedByPayer(newValue);
        });
      },
      items: nonFronters.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: TextStyle(fontSize: 36, color: Colors.blue)),
        );
      }).toList(),
    ),
    SizedBox(height: 25),
    if (nonFronter != null) ...[ 
      Text('owes you ', style: TextStyle(fontSize: 36)),
      Text(
        "\$${amountOwed?.toStringAsFixed(2)}",
        style: TextStyle(  
          fontSize: 40,
          fontWeight: FontWeight.bold, 
          color: Colors.green, 
        ),
      ),
    ]
    ];
  }

  

  List<Widget> buildNonFronterUI() {
    return [
      Row(
        mainAxisSize: MainAxisSize.min, // Use minimum space needed by the children
        children: [
          Text(' Hi  ', 
            style: TextStyle(fontSize: 36)
          ),
          buildUserDropdown(),
        ],
      ),
      SizedBox(height: 25), 
      Row( 
        mainAxisAlignment: MainAxisAlignment.center, 
        children: <Widget>[ 
          Text("you owe ", style: TextStyle(fontSize: 36)),
          Text(
            "$fronter ",
            style: TextStyle(
              fontSize: 40,
              color: Colors.blue, 
            ),
          ),
        ]
       ),
      SizedBox(height: 20),
      Text(
        "\$${amountOwed?.toStringAsFixed(2)}",
        style: TextStyle(  
          fontSize: 40,
          fontWeight: FontWeight.bold, 
          color: Colors.green, 
        )
      ),
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
  
  void _launchVenmo() async {
    final Uri venmoUrl = Uri.parse('https://venmo.com/'); 
    if (await canLaunchUrl(venmoUrl)) {
      await launchUrl(venmoUrl);
    } else {
      throw 'Could not launch $venmoUrl';
    }
  }

  // A way to launch to a pre filled pay/charge page with username and amount pre filled. 
  // Requires app so need to test on physical device
  // void _launchVenmo(double amountOwed) async {
  //   const String recipientUsername = 'brad'; // Replace with actual username
  //   final Uri venmoUrl = Uri.parse(
  //     'venmo://paycharge?txn=pay&recipients=$recipientUsername&amount=$amountOwed'
  //   );

  //   if (await canLaunchUrl(venmoUrl)) {
  //     await launchUrl(venmoUrl);
  //   } else {
  //     throw 'Could not launch Venmo';
  //   }
  // }

}