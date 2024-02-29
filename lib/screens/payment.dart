import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PaymentPage(),
    );
  }
}

class PaymentPage extends StatefulWidget {
  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool? isPaying; //  initialized to null as no button is selected

  @override
  Widget build(BuildContext context) {
    // Colors for the buttons
    Color selectedColor = Colors.blue.shade900; 
    Color unselectedColor = Colors.blue; 
    Color inactiveColor = Colors.grey;
    Color textColor = Colors.white;

    String name = "Victoria"; // TODO: make name dynamic from split summary or fill in from textbox

    String debtText = isPaying == true
        ? "You owe $name"
        : isPaying == false
          ? "$name owes you"
          : ''; // Empty string if no button is selected

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 159, 224, 255),
        // automaticallyImplyLeading: false, // disable back button
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Go Home',
            onPressed: () {
              Navigator.of(context).push(_backToHome());
            },
          ),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 159, 224, 255),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Time to SQUARE up!',
              style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isPaying = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPaying == true ? selectedColor : (isPaying == false ? inactiveColor : unselectedColor),
                    foregroundColor: textColor,
                  ),
                  child: Text('Paying'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isPaying = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPaying == false ? selectedColor : (isPaying == true ? inactiveColor : unselectedColor),
                    foregroundColor: textColor,
                  ),
                  child: Text('Requesting'),
                ),
              ],
            ),
            SizedBox(height: 24),
            Text(
              debtText,
              style: TextStyle(fontSize: 20),
            ),
            Text(
              '\$15.00', // TODO: make dynamic
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            Spacer(), // Use Spacer to push the rest to the bottom
            Text(
              'Pay with:',
              style: TextStyle(fontSize: 20),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _paymentButton('Venmo'),
                _paymentButton('PayPal'),
                _paymentButton('Manually'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentButton(String paymentMethod) {
    return ElevatedButton(
      onPressed: () {
        // TODO: Implement payment logic
      },
      child: Text(paymentMethod),
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
}
