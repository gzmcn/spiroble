import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ThemeEvent {}

class SetLightTheme extends ThemeEvent {}

class SetDarkTheme extends ThemeEvent {}

abstract class ThemeState {
  ThemeData get themeData;
}

class LightThemeState extends ThemeState {
  @override
  ThemeData get themeData => ThemeData(
    useMaterial3: true,
    focusColor: Color(0xFF6F5191),
    cardColor: Color(0xFF6F5191),
    primaryColor: Colors.purple[900],
    canvasColor: Color(0xC5C7B9F1),
    scaffoldBackgroundColor: Color(0xFF503A93),
    primaryColorDark: Color(0xFF916BBD),
    tabBarTheme: TabBarTheme(
        dividerColor: Colors.white
    ),
    colorScheme: ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: const Color.fromARGB(255, 82, 14, 94),
    ),
    textTheme: GoogleFonts.latoTextTheme(
      ThemeData(brightness: Brightness.light).textTheme,
    ).copyWith(
      bodyLarge: TextStyle(
        color: Colors.black, // Light modda siyah metin
      ),
      bodyMedium: TextStyle(
        color: Colors.black, // Light modda siyah metin
      ),
    ),
  );
}

class DarkThemeState extends ThemeState {
  @override
  ThemeData get themeData => ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Color.fromARGB(50, 50, 50, 100),
      primaryColor: Color.fromARGB(50, 50, 50, 100),
      canvasColor: Color(0x335A4F73),
      focusColor: Color(0xFF3D2F4D),
      secondaryHeaderColor: Color(0xFFB7A0FD),
      cardColor: Color.fromARGB(255, 82, 14, 94),
      primaryColorDark: Color(0xFF222250), // darkmode switch color
      tabBarTheme: TabBarTheme(
        dividerColor: Color.fromARGB(50, 50, 50, 100),
      ),
      colorScheme: ColorScheme.fromSeed(
        brightness: Brightness.dark,
        seedColor: const Color.fromARGB(255, 82, 14, 94),
      ),
      textTheme: GoogleFonts.latoTextTheme(
        ThemeData(brightness: Brightness.dark).textTheme,
      ).copyWith(
        bodyLarge: TextStyle(
          color: Colors.white, // Dark modda beyaz metin
        ),
        bodyMedium: TextStyle(
          color: Colors.white, // Dark modda beyaz metin
        ),

      ));


}

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(LightThemeState()) {
    on<SetLightTheme>((event, emit) {
      emit(LightThemeState());
    });
    on<SetDarkTheme>((event, emit) {
      emit(DarkThemeState());
    });
  }
}
