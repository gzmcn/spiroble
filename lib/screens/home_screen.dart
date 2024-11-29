import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:spiroble/blocs/bluetooth_bloc.dart';
import 'package:spiroble/screens/testScreen.dart';
import 'package:spiroble/bluetooth/BluetoothConnectionManager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    print(BluetoothConnectionManager().connectedDeviceId.toString());
    if (BluetoothConnectionManager().checkConnection()) {
      print('connected');
    } else {
      print('disconnected');
    }
  }

  String getGreetingMessage() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return "günaydın!";
    } else if (hour < 18) {
      return "iyi günler!";
    } else {
      return "iyi akşamlar!";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFFA0BAFD), Colors.deepOrange.shade700],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                getGreetingMessage(),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Bugün harika bir gün olacak!",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => TestScreen(),
                  ));
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                  backgroundColor: const Color.fromARGB(255, 251, 251, 251),
                  padding: EdgeInsets.symmetric(
                      horizontal: 30, vertical: 15), // Buton boyutu
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(30), // Yuvarlatılmış köşeler
                  ), // Buton metin rengi
                  elevation: 8, // Gölge efekti
                ),
                child: BlocBuilder<BluetoothBloc, BluetoothState>(
                  builder: (context, state) {
                    if (state is BluetoothInitial) {
                      return Center(child: CircularProgressIndicator());
                    } else if (state is BluetoothConnected) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Bağlı Cihaz: ${state.device.name}',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold)),
                            ElevatedButton(
                              onPressed: () {
                                context
                                    .read<BluetoothBloc>()
                                    .add(BluetoothDisconnect());
                              },
                              child: Text('Bağlantıyı Kes'),
                            ),
                          ],
                        ),
                      );
                    } else if (state is BluetoothDisconnected) {
                      return Center(
                        child: ElevatedButton(
                          onPressed: () {
                            // Cihaza bağlan
                            // Burada bağlantı kodu eklenebilir.
                          },
                          child: Text('Cihaza Bağlan'),
                        ),
                      );
                    } else if (state is BluetoothError) {
                      return Center(
                          child: Text(state.message,
                              style: TextStyle(color: Colors.red)));
                    }
                    return Container();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
