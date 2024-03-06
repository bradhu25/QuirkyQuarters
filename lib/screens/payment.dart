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
  Receipt receipt = Receipt.emptyReceipt();
  String? selectedUser;
  String? nonFronter;
  List<String> payers = []; // Will be fetched from Firestore
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
    // Receipt? receipt = await fetchReceiptData(widget.receiptId);
    // if (receipt != null) {
    setState(() {
      fronter = receipt.fronter; 
      payers = receipt.entries
          .map((entry) => entry.payer ?? '') // Extract payers from entries
          .toSet() // Convert list of payers to a set to eliminate duplicates
          .toList(); // Convert back to a list

      names = (fronter?.isNotEmpty ?? false) ? [fronter!] : [];
      names.addAll(payers.where((payer) => payer.isNotEmpty)); // Ensures no empty names are added
    });
    // }
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
            DropdownButton<String>(
              hint: Text('Who are you?'),
              value: selectedUser,
              onChanged: (String? newValue) {
                setState(() {
                  selectedUser = newValue;
                });
              },
              items: names.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            if (selectedUser != null)
              if (selectedUser == fronter)
                ...buildFronterUI()
              else
                ...buildNonFronterUI(),
          ],
        ),
      ),
    );
  }

  List<Widget> buildFronterUI() {
  return [
    Text('Hi $selectedUser'),
    DropdownButton<String>(
      value: nonFronter,
      hint: Text('Select name'),
      onChanged: (String? newValue) {
        setState(() {
          nonFronter = newValue;
          amountOwed = calculateAmountOwedByPayer(newValue);
        });
      },
      items: payers.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    ),
    if (nonFronter != null) 
      Text('$nonFronter owes you ${amountOwed?.toStringAsFixed(2)}'),
    ];
  }

  

  List<Widget> buildNonFronterUI() {
    // Build UI for when a non-fronter user is selected
    return [
      Text('Hi $selectedUser,'),
      Text('you owe $fronter \$${amountOwed?.toStringAsFixed(2)}'),
      // ...additional UI elements
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

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: PaymentPage(),
//     );
//   }
// }

// class PaymentPage extends StatefulWidget {
//   @override
//   _PaymentPageState createState() => _PaymentPageState();
// }

// class _PaymentPageState extends State<PaymentPage> {
//   bool? isPaying; //  initialized to null as no button is selected

//   @override
//   Widget build(BuildContext context) {
//     // Colors for the buttons
//     Color selectedColor = Colors.blue.shade900; 
//     Color unselectedColor = Colors.blue; 
//     Color inactiveColor = Colors.grey;
//     Color textColor = Colors.white;

//     String name = "Victoria"; // TODO: make name dynamic from split summary or fill in from textbox

//     String debtText = isPaying == true
//         ? "You owe $name"
//         : isPaying == false
//           ? "$name owes you"
//           : ''; // Empty string if no button is selected

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Color.fromARGB(255, 159, 224, 255),
//         // automaticallyImplyLeading: false, // disable back button
//         actions: <Widget>[
//           IconButton(
//             icon: const Icon(Icons.home),
//             tooltip: 'Go Home',
//             onPressed: () {
//               Navigator.of(context).push(_backToHome());
//             },
//           ),
//         ],
//       ),
//       backgroundColor: const Color.fromARGB(255, 159, 224, 255),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 30.0),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               'Time to SQUARE up!',
//               style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 24),
//             Row(
//               mainAxisSize: MainAxisSize.min,
//               children: <Widget>[
//                 ElevatedButton(
//                   onPressed: () {
//                     setState(() {
//                       isPaying = true;
//                     });
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: isPaying == true ? selectedColor : (isPaying == false ? inactiveColor : unselectedColor),
//                     foregroundColor: textColor,
//                   ),
//                   child: Text('Paying'),
//                 ),
//                 SizedBox(width: 8),
//                 ElevatedButton(
//                   onPressed: () {
//                     setState(() {
//                       isPaying = false;
//                     });
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: isPaying == false ? selectedColor : (isPaying == true ? inactiveColor : unselectedColor),
//                     foregroundColor: textColor,
//                   ),
//                   child: Text('Requesting'),
//                 ),
//               ],
//             ),
//             SizedBox(height: 24),
//             Text(
//               debtText,
//               style: TextStyle(fontSize: 20),
//             ),
//             Text(
//               '\$15.00', // TODO: make dynamic
//               style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
//             ),
//             Spacer(), // Use Spacer to push the rest to the bottom
//             Text(
//               'Pay with:',
//               style: TextStyle(fontSize: 20),
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: <Widget>[
//                 _paymentButton('Venmo'),
//                 _paymentButton('PayPal'),
//                 _paymentButton('Manually'),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _paymentButton(String paymentMethod) {
//     return ElevatedButton(
//       onPressed: () {
//         // TODO: Implement payment logic
//       },
//       child: Text(paymentMethod),
//     );
//   }

//   // animation to go back home. can be reused for other home navigations. 
//   // swipes left animation instead of default swipe right animation that Navigator.of(context).pushNamed('/') would do
//   // not currently called but keeping in case helpful for future animations
//   Route _backToHome() {
//     return PageRouteBuilder(
//       pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
//       transitionsBuilder: (context, animation, secondaryAnimation, child) {
//         var begin = const Offset(-1.0, 0.0);
//         var end = Offset.zero;
//         var curve = Curves.ease;
//         var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
//         var offsetAnimation = animation.drive(tween);
//         return SlideTransition(
//           position: offsetAnimation,
//           child: child,
//         );
//       },
//     );
//   }
// }
