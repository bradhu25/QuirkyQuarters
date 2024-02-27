import 'package:flutter/material.dart';


class ViewReceiptsRoute extends StatelessWidget {
  const ViewReceiptsRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Receipts'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.home),
            tooltip: 'Go Home',
            onPressed: () {
              Navigator.pop(context); // go back to previous page
            },
          ),
        ],
      ),
      body: Center(

      ),
    );
  }
}