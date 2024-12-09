import 'package:flutter/material.dart';
import 'package:spiroble/screens/LoginScreen.dart';
import 'package:spiroble/screens/asistanScreen.dart'; // Asistan ekranını import edin
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea( // Ensures content is displayed within safe areas
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF3A2A6B),
                Color(0xFF3A2A6B),
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
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height - 80, // Adjusted to account for padding and FAB
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 40),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "👋 Hello!\nJohn Doe",
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                CircleAvatar(
                                  radius: 25,
                                  backgroundImage: NetworkImage(
                                    "https://via.placeholder.com/150", // Profil resmi için placeholder
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              decoration: InputDecoration(
                                hintText: "Search medical...",
                                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                filled: true,
                                fillColor: Colors.white24,
                                hintStyle: const TextStyle(color: Colors.white70),
                              ),
                              style: const TextStyle(color: Colors.white),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "Services",
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
                                _buildServiceIcon(Icons.people, "Community"),
                                _buildServiceIcon(Icons.medical_services, "Health"),
                                _buildServiceIcon(Icons.shopping_cart, "Shop"),
                                _buildServiceIcon(Icons.settings, "Settings"),
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text(
                                          "Get the Best\nMedical Services",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          "We provide the best quality medical services without further cost.",
                                          style: TextStyle(
                                            fontSize: 12,
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
                              "Upcoming Appointments",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Flexible( // Changed from Expanded to Flexible
                                  child: _buildAppointmentCard(
                                    date: "12\nTue",
                                    time: "9:30 AM",
                                    doctor: "DR. SAMUEL",
                                    type: "Depression",
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Flexible( // Changed from Expanded to Flexible
                                  child: _buildAppointmentCard(
                                    date: "13\nWed",
                                    time: "10:00 AM",
                                    doctor: "DR. JANE",
                                    type: "General",
                                  ),
                                ),
                              ],
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
            builder: (context) => AsistanScreen(), // Asistan ekranına yönlendirme
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