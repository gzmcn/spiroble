import 'package:flutter/material.dart';

class TTextTheme{
  TTextTheme._();

  static TextTheme lightTextTheme = TextTheme(
    headlineLarge: TextStyle().copyWith(fontSize: 35, fontWeight:  FontWeight.bold, color: Colors.black),
    headlineMedium: TextStyle().copyWith(fontSize: 24, fontWeight:  FontWeight.w600, color: Colors.black),
    headlineSmall: TextStyle().copyWith(fontSize: 18, fontWeight:  FontWeight.w300, color: Colors.black),
  );
  static TextTheme darkTextTheme = TextTheme(
    headlineLarge: TextStyle().copyWith(fontSize: 35, fontWeight:  FontWeight.bold, color: Colors.white),
    headlineMedium: TextStyle().copyWith(fontSize: 24, fontWeight:  FontWeight.w600, color: Colors.white),
    headlineSmall: TextStyle().copyWith(fontSize: 18, fontWeight:  FontWeight.w300, color: Colors.white),
  );
}


