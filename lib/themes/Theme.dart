import 'package:flutter/material.dart';
import 'package:spiroble/themes/TextTheme.dart';


class TAppTheme{
  TAppTheme._();


  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness:  Brightness.light,
    primaryColor: Color(0xFF3A2A6B),
    scaffoldBackgroundColor: Colors.white54,
    textTheme: TTextTheme.lightTextTheme,
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness:  Brightness.dark,
    primaryColor: Color.fromARGB(255, 197, 151, 0),
    scaffoldBackgroundColor: Colors.black87,
    textTheme: TTextTheme.lightTextTheme,
  );

}