import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_switch/flutter_advanced_switch.dart';
import 'package:spiroble/screens/asistanScreen.dart'; // Asistan ekranını import edin
import 'package:spiroble/bluetooth/BluetoothConnectionManager.dart';
import 'package:spiroble/blocs/theme.bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  Future<String> fetchUserName() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      final database = FirebaseDatabase.instance.ref();
      final snapshot = await database.child('users/${currentUser.uid}').get();

      if (snapshot.exists) {
        final userName = snapshot.child('ad').value;
        return userName != null ? userName.toString() : "No name available";
      } else {
        print("No user data available");
        return "No name available";
      }
    } else {
      print("No current user found.");
      return "No name available";
    }
  }

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

  // dark-light mode switch controller
  final _modeController = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();

    _modeController.value = themeBloc.state is DarkThemeState;

    return Scaffold(
      body: SafeArea(
        // Ensures content is displayed within safe areas
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).scaffoldBackgroundColor,
                Theme.of(context).scaffoldBackgroundColor,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height -
                            80, // Adjusted to account for padding and FAB
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 40),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                FutureBuilder<String>(
                                  future:
                                      fetchUserName(), // Fetch the username asynchronously
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Text(
                                        "👋 Merhaba!",
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      );
                                    } else if (snapshot.hasError) {
                                      return const Text(
                                        "👋 Merhaba!",
                                        style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      );
                                    } else if (snapshot.hasData) {
                                      return Text(
                                        "👋 Merhaba! ${snapshot.data}",
                                        style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      );
                                    } else {
                                      return const Text(
                                        "👋 Merhaba!",
                                        style: TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      );
                                    }
                                  },
                                ),
                                CircleAvatar(
                                  backgroundImage:
                                      AssetImage("assets/user-logo.png"),
                                  radius: 35,
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),
                            TextField(
                              decoration: InputDecoration(
                                hintText: "Doktor Arama...",
                                prefixIcon: const Icon(Icons.search,
                                    color: Colors.white70),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                filled: true,
                                fillColor: Colors.white24,
                                hintStyle:
                                    const TextStyle(color: Colors.white70),
                              ),
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "Hizmetler",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildServiceIcon(Icons.people, "Topluluk"),
                                _buildServiceIcon(
                                    Icons.medical_services, "Sağlık"),
                                _buildServiceIcon(
                                    Icons.shopping_cart, "Dükkan"),
                                _buildServiceIcon(Icons.settings, "Ayarlar"),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          "Medikal Hizmetlerin\nEn İyisinden Yararlanın",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          "Hastaneye gitmeye gerek kalmadan en kaliteli tıbbi hizmetleri sunuyoruz.",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const CircleAvatar(
                                    radius: 35,
                                    backgroundImage: NetworkImage(
                                      "https://via.placeholder.com/100", // Doktor görseli için placeholder
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "Yaklaşan Randevu",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  // Changed from Expanded to Flexible
                                  child: _buildAppointmentCard(
                                    date: "12/08\nSalı",
                                    time: "9:30",
                                    doctor: "DR. Sezai",
                                    type: "Göğüs Hastalıkları",
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  // Changed from Expanded to Flexible
                                  child: _buildAppointmentCard(
                                    date: "13/11\nCmt",
                                    time: "10:00",
                                    doctor: "DR. Sıla",
                                    type: "Dahiliye",
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 45),
                            AdvancedSwitch(
                              controller: _modeController,
                              height: 50,
                              width: 150,
                              thumb: ValueListenableBuilder<bool>(
                                valueListenable: _modeController,
                                builder: (_, isDarkMode, __) {
                                  return Icon(
                                    isDarkMode
                                        ? Icons.dark_mode
                                        : Icons.light_mode,
                                    color: Colors.white,
                                  );
                                },
                              ),
                              activeImage: const AssetImage('assets/dark.png'),
                              inactiveImage:
                                  const AssetImage('assets/light1.png'),
                              onChanged: (isDarkMode) {
                                _modeController.value = isDarkMode;
                                if (isDarkMode) {
                                  themeBloc.add(SetDarkTheme());
                                } else {
                                  themeBloc.add(SetLightTheme());
                                }
                              },
                            ),

                            const Spacer(), // Fills the remaining space to push content up
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) =>
                AsistanScreen(), // Asistan ekranına yönlendirme
          ));
        },
        backgroundColor: Colors.orangeAccent,
        child: const Icon(Icons.assistant, color: Colors.white),
      ),
    );
  }

  Widget _buildServiceIcon(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: Colors.white24,
          child: Icon(icon, color: Colors.orangeAccent, size: 28),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentCard({
    required String date,
    required String time,
    required String doctor,
    required String type,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white24,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.orangeAccent,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            time,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            doctor,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            type,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}
