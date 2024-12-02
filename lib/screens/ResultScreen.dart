import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:spiroble/screens/TestDetailScreen.dart';

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
  List<Map<String, String>> measurements = []; // Başlangıçta boş liste

  @override
  void initState() {
    super.initState();
    fetchMeasurements(); // Başlangıçta veri çekmeye başla
  }

  // Backend'den veri çekme simülasyonu
  Future<void> fetchMeasurements() async {
    // Bu kısımda gerçek API çağrısı yapılacak
    await Future.delayed(Duration(seconds: 2)); // 2 saniye bekle

    setState(() {
      // Backend'den gelen veriler ile listeyi güncelle
      measurements = [
        {
          "emoji": "🔥",
          "fvc": "3.13 L",
          "pef": "451 L/m",
          "fev1": "1.20",
          "date": "12 Mar 2021"
        },
        {
          "emoji": "🔥",
          "fvc": "3.32 L",
          "pef": "375 L/m",
          "fev1": "1.22",
          "date": "11 Mar 2021"
        },
        {
          "emoji": "🔥",
          "fvc": "4.11 L",
          "pef": "429 L/m",
          "fev1": "1.34",
          "date": "10 Mar 2021"
        },
        {
          "emoji": "🔥",
          "fvc": "4.12 L",
          "pef": "429 L/m",
          "fev1": "1.34",
          "date": "10 Mar 2021"
        }
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // Koyu zemin
      body: Column(
        children: [
          // Üst kısım: Siyah gölgeli başlık ve altın menü butonları
          Container(
            color: Colors.grey[850], // Koyu zemin
            child: Column(
              children: [
                // Modern Başlık
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    children: [
                      Text(
                        "Günlük Ölçüm Değerleri",
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              shadows: [
                                Shadow(
                                  color: Colors.black45,
                                  blurRadius: 6,
                                  offset: Offset(2, 2),
                                ),
                              ],
                              color: Colors.white,
                            ),
                      ),
                    ],
                  ),
                ),
                // Altın Renkli Menü Butonları
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
          Expanded(
            // Ölçüm değerleri listesi
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: measurements.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: measurements.length,
                      itemBuilder: (context, index) {
                        final measurement = measurements[index];
                        return ElevatedMeasurementCard(
                          emoji: measurement['emoji']!,
                          fvc: measurement['fvc']!,
                          pef: measurement['pef']!,
                          fev1: measurement['fev1']!,
                          date: measurement['date']!,
                        );
                      },
                    ),
            ),
          ),
          // Alt Kısım: Profil ve Arama Butonları
          Container(
            color: Colors.grey[850],
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () {
                    print("Test Butonuna Tıklandı");
                  },
                  icon: Icon(Icons.search, color: Color.fromARGB(255, 182, 148, 0)),
                  iconSize: 32,
                ),
                IconButton(
                  onPressed: () {
                    print("Profil Butonuna Tıklandı");
                  },
                  icon: Icon(Icons.person, color: Color.fromARGB(255, 182, 148, 0)),
                  iconSize: 32,
                ),
              ],
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
        color: Colors.grey[800], // Koyu arka plan
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