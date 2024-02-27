import 'package:flutter/material.dart';


class JoinReceiptRoute extends StatelessWidget {
  const JoinReceiptRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Receipt'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Go Home',
            onPressed: () {
              Navigator.pop(context); // go back to previous page
              // Navigator.of(context).pushNamed('/'); // go back to homepage route
              // Navigator.of(context).push(_backToHome());
            },
          ),
        ],
      ),
      body: Center(

      ),
    );
  }
}