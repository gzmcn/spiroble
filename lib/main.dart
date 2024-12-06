import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:spiroble/blocs/theme.bloc.dart';
import 'package:spiroble/bluetooth/BluetoothConnectionManager.dart';
import 'package:provider/provider.dart';
import 'package:spiroble/screens/StartSplashScreen.dart'; // SplashScreen import ediliyor
import 'firebase_options.dart';
import 'package:flutter/services.dart';
import 'package:spiroble/screens/AnimationScreen.dart'; // Import MetricsPushKeyProvider

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // Firebase'i başlatıyoruz
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // MultiProvider kullanarak BluetoothManager ve MetricsPushKeyProvider'ı sağlıyoruz
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => BluetoothConnectionManager(),
      ),
      ChangeNotifierProvider(
        create: (context) => MetricsPushKeyProvider(), // Add MetricsPushKeyProvider
      ),
    ],
    child: MyApp(),
  ));
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
            debugShowCheckedModeBanner: false, // Debug banner'ı kaldırmak
            home: StartSplashScreen(), // İlk ekran olarak StartSplashScreen
            theme: themeState.themeData, // Tema yönetimi
            darkTheme: DarkThemeState().themeData,
            themeMode: ThemeMode.dark,
          );
        },
      ),
    );
  }
}
