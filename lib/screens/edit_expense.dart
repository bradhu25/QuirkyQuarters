import 'package:flutter/material.dart';


class EditExpenseRoute extends StatelessWidget {
  const EditExpenseRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Expense'),
      ),
      body: Center(
        child: DefaultTextStyle(
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                height: 2
              ),
          child: Column(
            children: [
              // TODO: Make expense title editable.
              Text("Expense Title", style: Theme.of(context).textTheme.headlineLarge,),
              SizedBox(height: 30),
              Row(
                  children: [
                    SizedBox(width: 10,),
                    Column(
                      children: [
                        Text("",
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        // TODO: Fill in functionality for onPressed to remove item.
                        IconButton(
                          icon: Icon(Icons.remove_circle_outline),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.remove_circle_outline),
                          onPressed: () {},
                        )
                      ]
                    ),
                    // TODO: Make spacing between columns (buttons, items, costs) 
                    // dynamic to screen size. See Flexible / Expanded widget.
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Item",
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text("Lamb"),
                        Text("Steak"),
                      ]
                    ),
                    SizedBox(width: 104,),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Cost",
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        Text("\$30"),
                        Text("\$100")
                      ]
                    ),
                  ]
                ),
              Row(
                children: [
                  SizedBox(width: 10,),
                  // TODO: Fill in functionality for onPressed to add item.
                  IconButton(
                          icon: Icon(Icons.add_circle_outline),
                          onPressed: () {},
                  ),
                  // TODO: Update container to Flexible / Expanded widget to match other items.
                  Container(
                    width: 120,
                    height: Theme.of(context).textTheme.headlineSmall!.fontSize,
                    child: TextField(
                      style: Theme.of(context).textTheme.headlineSmall,
                      decoration: InputDecoration(hintText: 'New Item'),
                      // Set up styling and controller as needed.
                    ),
                  ),
                  SizedBox(width: 50),
                  Container(
                    width: 120,
                    height: Theme.of(context).textTheme.headlineSmall!.fontSize,
                    child: TextField(
                      style: Theme.of(context).textTheme.headlineSmall,
                      decoration: InputDecoration(hintText: 'Cost'),
                      // Set up styling and controller as needed.
                    ),
                  ),
                  // Expanded(
                  //   child: TextField(
                  //     decoration: InputDecoration(hintText: '\$Cost'),
                  //     keyboardType: TextInputType.number,
                  //     // Set up styling and controller as needed.
                  //   ),
                  // ),
                ],
              ),
            ],
          ),
        ),
      )
    );
  }
}