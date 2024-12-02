import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; // provider paketini kullanıyoruz.
import 'package:spiroble/bluetooth/bloc/BluetoothBloc.dart';
import 'package:spiroble/bluetooth/BluetoothConnectionManager.dart';
import 'package:spiroble/screens/LoginScreen.dart';
import 'package:spiroble/screens/appScreen.dart';
import 'package:spiroble/screens/splashScreen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // BluetoothConnectionManager örneğini burada oluşturuyoruz
  final bluetoothConnectionManager = BluetoothConnectionManager();

  runApp(
    MultiBlocProvider(
      providers: [
        // BluetoothBloc'a BluetoothConnectionManager sağlıyoruz
        BlocProvider<BluetoothBloc>(
          create: (_) => BluetoothBloc(bluetoothConnectionManager),
        ),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); // Yükleniyor ekranı
          }
          if (snapshot.hasData) {
            return AppScreen();
          }
          return LoginScreen();
        },
      ),
    );
  }
}
