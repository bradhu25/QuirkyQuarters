import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_fonts/google_fonts.dart';


Future<void> main () async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

runApp(MaterialApp( // routes not const
    title: 'Quirky Quarters',
    theme: ThemeData(
      colorScheme: ColorScheme.light(
        primary: Colors.teal[300]!, // A lighter shade of teal as the primary color
        onPrimary: Colors.white, // For text/icons on top of the primary color
        secondary: Colors.cyan[200]!, // A lighter shade of cyan for the secondary color
        onSecondary: Colors.black, // For text/icons on top of the secondary color
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.teal[300], // Use the primary color from the color scheme
        iconTheme: IconThemeData(color: Colors.white), // Icon color in the app bar
        titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.cyan[200],
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: Colors.teal[300], // Default button color
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.teal[300]), // Background color for elevated buttons
          foregroundColor: MaterialStateProperty.all(Colors.white), // Text color for elevated buttons
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(Colors.teal[300]), // Text color for text buttons
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal[300]!, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.teal[300]!, width: 1.0),
        ),
      ),
      // Fonts
      textTheme: GoogleFonts.montserratTextTheme(),
    ),
    routes: {
      '/': (context) => HomePage(),
    },
  ));
}