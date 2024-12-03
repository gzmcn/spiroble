import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:spiroble/blocs/theme.bloc.dart';
import 'package:spiroble/bluetooth/BluetoothConnectionManager.dart';
import 'package:spiroble/screens/appScreen.dart';
import 'package:spiroble/screens/hosgeldiniz.dart';
import 'package:provider/provider.dart';
import 'package:spiroble/screens/StartSplashScreen.dart'; // Ensure splashScreen.dart is imported
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => BluetoothConnectionManager(),
        )
      ],
      child: MyApp(),
    )
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeBloc(),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            home: StartSplashScreen(),  // StartSplashScreen will appear first
            theme: themeState.themeData,
          );
        },
      ),
    );
  }
}
