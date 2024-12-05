import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:spiroble/screens/testResultsScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ResultScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ResultScreen extends StatefulWidget {
  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final DatabaseReference _databaseRef =
      FirebaseDatabase.instance.ref("sonuclar");
  List<Map<String, dynamic>> measurements = []; // Firebase'den alınan veriler

  @override
  void initState() {
    super.initState();
    fetchMeasurements(); // Firebase'den veri çekme
  }

  // Firebase'den verileri çekme
  Future<void> fetchMeasurements() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('Kullanıcı giriş yapmamış!');
      return;
    }
    String userId = user.uid;

    _databaseRef.child(userId).onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          measurements = data.entries.map((e) {
            final key = e.key;
            final value = Map<String, dynamic>.from(e.value);
            return {
              'id': key,
              'fvc': value['fvc'] ?? '0',
              'fev1': value['fev1'] ?? '0',
              'fev6': value['fev6'] ?? '0',
              'fev1Fvc': value['fev1Fvc'] ?? '0',
              'fef2575': value['fef2575'] ?? '0',
              'pef': value['pef'] ?? '0',
              'timestamp': value['timestamp'] ?? '',
              'flowRates': List<dynamic>.from(value['flowRates'] ?? []),
              'times': List<dynamic>.from(value['times'] ?? []),
              'volumes': List<dynamic>.from(value['volumes'] ?? []),
              'emoji': "🔥", // Varsayılan emoji
            };
          }).toList();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Theme.of(context).scaffoldBackgroundColor, // Koyu tema arka planı
      body: Column(
        children: [
          // Başlık ve menü butonları
          Container(
            color: Colors.grey[850],
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Text(
                        "Test Sonuçları",
                        style:
                            Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black45,
                              blurRadius: 6,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          print("Spirometre Butonuna Tıklandı");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 197, 151, 0),
                          shadowColor: Color.fromARGB(255, 182, 148, 0),
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Spirometre",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          print("Oksimetre Butonuna Tıklandı");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 197, 151, 0),
                          shadowColor: Color.fromARGB(255, 182, 148, 0),
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Oksimetre",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Ölçüm kartları
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: measurements.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: measurements.length,
                      itemBuilder: (context, index) {
                        final DateTime timestamp =
                            DateTime.parse(measurements[index]['timestamp']);
                        final String formattedDate =
                            DateFormat('dd MMM yyyy HH:mm').format(timestamp);

                        final measurement = measurements[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (ctx) => HealthMonitorScreen(
                                measurement: measurements[
                                    index], // Liste yerine doğrudan Map göndermek
                              ),
                            ));
                          },
                          child: ElevatedMeasurementCard(
                            emoji: measurement['emoji'],
                            fvc: measurement['fvc'].toString(),
                            pef: measurement['pef'].toString(),
                            fev1: measurement['fev1'].toString(),
                            date: formattedDate,
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class ElevatedMeasurementCard extends StatelessWidget {
  final String emoji;
  final String fvc;
  final String pef;
  final String fev1;
  final String date;

  ElevatedMeasurementCard({
    required this.emoji,
    required this.fvc,
    required this.pef,
    required this.fev1,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(4, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarih ve emoji
          Row(
            children: [
              Text(
                emoji,
                style: TextStyle(fontSize: 28),
              ),
              SizedBox(width: 10),
              Text(
                date,
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
            ],
          ),
          SizedBox(height: 12),
          // FVC, PEF, FEV1: İsimler ince yazı; değerler kalın
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text(
                    'FVC',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    fvc,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    'PEF',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    pef,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  Text(
                    'FEV1',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    fev1,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
