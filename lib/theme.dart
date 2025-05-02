import 'package:flutter/material.dart';

//light
final safetyThemeClassic = ThemeData(
  primaryColor: const Color(0xFFFFA500),  // Safety orange
  scaffoldBackgroundColor: const Color(0xFFF2F2F2), // Light grey
  textTheme: const TextTheme(
    bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF333333)), // Dark grey text for better contrast
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFF78D07), // Slightly darker orange for buttons
      foregroundColor: Colors.white,
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFFFA500), // Safety orange app bar
    titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
  ),
    // Add more theme properties as needed
);

final safetyThemeModern = ThemeData(
  primaryColor: const Color(0xFF4CAF50), // Safety green
  scaffoldBackgroundColor: Colors.white,
  textTheme: const TextTheme(
    bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Color(0xFF333333)),
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF388E3C), // Darker green for buttons
      foregroundColor: Colors.white,
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF4CAF50), // Safety green app bar
    titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),

  ),
  // Add more theme properties
);

final safetyThemeHighVisibility = ThemeData(
  primaryColor: const Color(0xFFFFEE00), // High-visibility yellow
  scaffoldBackgroundColor: const Color(0xFF111111), // Dark background for contrast
  textTheme: const TextTheme(
    bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white),
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white,),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFF7BD00), // Slightly darker yellow for buttons
      foregroundColor: Colors.black,  // Black text on yellow buttons
    ),
  ),
  appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFEE00),
    titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),

  ),
  // Add more theme properties
);

//dark
final safetyThemeDarkOrange = ThemeData(
  brightness: Brightness.dark, // Set brightness to dark
  primaryColor: const Color(0xFFFFA500), // Keep safety orange
  scaffoldBackgroundColor: const Color(0xFF222222), // Dark grey background
  textTheme: const TextTheme(
    bodyMedium: TextStyle(fontSize: 16, color: Colors.white70), // Lighter text on dark background
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFF78D07), // Darker orange for buttons
      foregroundColor: Colors.white,
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFFFA500),
    titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
  ),

  // ... other theme properties
);

final safetyThemeDarkGreen = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFF4CAF50), // Keep safety green
  scaffoldBackgroundColor: const Color(0xFF222222),
  textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 16, color: Colors.white70),
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF388E3C),
      foregroundColor: Colors.white,
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF4CAF50),
    titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black), // Black text on Green AppBar
  ),
  // ... other theme properties
);

final safetyThemeDarkHighVisibility = ThemeData(
  brightness: Brightness.dark,
  primaryColor: const Color(0xFFFFEE00),
  scaffoldBackgroundColor: const Color(0xFF222222),
  textTheme: const TextTheme(
        bodyMedium: TextStyle(fontSize: 16, color: Colors.white70),
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111111)), // Very dark grey for better contrast
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFF7BD00), // Yellow is still appropriate as an accent.
      foregroundColor: Colors.black,  // Black on Yellow Button.
    ),
  ),
  appBarTheme: const AppBarTheme(
       backgroundColor: Color(0xFFFFEE00),
        titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),

  ),
  // ... other theme properties
);

