import 'package:flutter/material.dart';
import 'package:spiroble/screens/StartSplashScreen.dart'; // SplashScreen ekranını ekliyoruz

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: StartSplashScreen(), // Uygulama açıldığında SplashScreen gösterilecek
      theme: ThemeData(
        primarySwatch: Colors.blue,
        // Diğer tema özelliklerini buraya ekleyebilirsiniz
      ),
    );
  }
}
