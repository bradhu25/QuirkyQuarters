import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'screens/join_receipt.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main () async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

runApp(MaterialApp( // routes not const
    title: 'Quirky Quarters',
    // home: HomePage(), // moved to routes
    routes: {
    '/': (context) => HomePage(),
    '/joinReceipt': (context) => JoinReceiptRoute(), 
  },
  ));
}