import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

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
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.light,
          seedColor: const Color.fromARGB(255, 82, 14, 94)!,
        ),
        textTheme: GoogleFonts.latoTextTheme(
          ThemeData(brightness: Brightness.light).textTheme,
        ),
      );
}

class DarkThemeState extends ThemeState {
  @override
  ThemeData get themeData => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color.fromARGB(255, 82, 14, 94)!,
        ),
        textTheme: GoogleFonts.latoTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
      );
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
