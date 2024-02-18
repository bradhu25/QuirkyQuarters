import 'package:flutter/material.dart';


class EditExpenseRoute extends StatelessWidget {
  const EditExpenseRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                          Text("\$100"),
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
                      ),
                    ),
                    SizedBox(width: 50),
                    Container(
                      width: 120,
                      height: Theme.of(context).textTheme.headlineSmall!.fontSize,
                      child: TextField(
                        style: Theme.of(context).textTheme.headlineSmall,
                        decoration: InputDecoration(hintText: 'Cost'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),
                // TODO: Adjust Tax/Tip title and textbox alignment.
                Row(
                  children: [
                    SizedBox(width: 25,),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Tax: ",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        SizedBox(height: 15),
                        Text("Tip: ",
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ]
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 120,
                          height: Theme.of(context).textTheme.headlineSmall!.fontSize,
                          child: TextField(
                            style: Theme.of(context).textTheme.headlineSmall,
                            decoration: InputDecoration(
                              hintText: 'Tax',
                            ),
                          ),
                        ),
                        SizedBox(height: 25,),
                        Container(
                          width: 120,
                          height: Theme.of(context).textTheme.headlineSmall!.fontSize,
                          child: TextField(
                            style: Theme.of(context).textTheme.headlineSmall,
                            decoration: InputDecoration(
                              hintText: 'Tip',
                            ),
                          ),
                        ),
                      ]
                    ),
                  ]
                ),
                // TODO: Make Next/Camera buttons appear fixed at the bottom of
                // the screen. This means we can still see them when we scroll.
                SizedBox(height: 250),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, 
                  // TODO: Fix spacing between 'Next' button and camera icon
                  children: [
                    Spacer(flex: 4,),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Implement Next button functionality
                      },
                      child: Text('Next'),
                    ),
                    Spacer(flex: 2), 
                    IconButton(
                      icon: Icon(Icons.camera_alt_outlined),
                      onPressed: () {
                        // TODO: Implement camera icon functionality
                      },
                    ),
                    Spacer(flex: 1), 
                  ],
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}