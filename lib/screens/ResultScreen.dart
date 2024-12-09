import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spiroble/screens/testResultsScreen.dart';
import 'package:provider/provider.dart';
import 'package:spiroble/screens/AnimationScreen.dart';

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

  final AnimationScreen animationScreen = AnimationScreen();

  String? metricsPushKey;

  @override
  void initState() {
    super.initState();
    _loadMetricsPushKey();
    fetchMeasurements(); // Firebase'den veri çekme
  }

  Future<void> _loadMetricsPushKey() async {
    final prefs = await SharedPreferences.getInstance();
    metricsPushKey = prefs.getString('metricsPushKey');
    setState(() {
      // Trigger a rebuild if the key changes
    });
  }

  Future<void> deleteMeasurements() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('Kullanıcı giriş yapmamış!');
      return;
    }
    String userId = user.uid;

    // Veritabanı referansı oluşturuluyor
    final databaseRef = FirebaseDatabase.instance.ref('sonuclar/$userId');

    try {
      // Tüm veriyi siliyoruz
      await databaseRef
          .remove(); // Bu, 'sonuclar/{userId}' altındaki tüm veriyi siler

      print('Veri başarıyla silindi!');
    } catch (e) {
      print('Veri silme hatası: $e');
    }

    setState(() {
      // state'i yeniden oluşturmak için setState() kullanabilirsiniz, eğer widget'ta bir değişiklik yapılması gerekliyse
    });
  }

  // Firebase'den verileri çekme
  Future<void> fetchMeasurements() async {
    // Kullanıcının giriş yapıp yapmadığını kontrol et
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('Kullanıcı giriş yapmamış!');
      return;
    }
    String userId = user.uid;

    // Veritabanı referansını al
    final DatabaseReference databaseRef =
        FirebaseDatabase.instance.ref("sonuclar/$userId/tests");

    // Verileri dinleyin
    databaseRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        // Yeni ölçümleri eski verilerle birleştir
        setState(() {
          measurements.clear(); // Mevcut listeyi temizleyin
          measurements.addAll(data.entries.map((e) {
            final key = e.key;
            final value = Map<String, dynamic>.from(e.value);

            final String rawTimestamp = value['timestamp'] ?? '';
            DateTime parsedTimestamp;

            try {
              parsedTimestamp = rawTimestamp.isNotEmpty
                  ? DateTime.parse(rawTimestamp)
                  : DateTime.now();
            } catch (e) {
              print('Tarih parse hatası: $e');
              parsedTimestamp =
                  DateTime.now(); // Hata durumunda mevcut zamanı kullan
            }

            List<dynamic> rawMeasurements = value['measurements'] ?? [];
            List<Map<String, dynamic>> processedMeasurements = rawMeasurements
                .map((m) => Map<String, dynamic>.from(m))
                .toList();

            return {
              'id': key,
              'timestamp': parsedTimestamp,
              'fvc': value['fvc'] ?? '220',
              'fev1': value['fev1'] ?? '10',
              'fev6': value['fev6'] ?? '20',
              'fev1Fvc': value['fev1Fvc'] ?? '0',
              'fef2575': value['fef2575'] ?? '0',
              'pef': value['pef'] ?? '0',
              'measurements': processedMeasurements,
              'emoji': "😮‍💨", // Varsayılan emoji
            };
          }).toList());
        });
      } else {
        print("Bu kullanıcı için veri bulunamadı.");
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
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        Text(
                          "Test Sonuçları",
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
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
                            backgroundColor: Theme.of(context).cardColor,
                            shadowColor: Theme.of(context).cardColor,
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
                            backgroundColor: Theme.of(context).cardColor,
                            shadowColor: Theme.of(context).cardColor,
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
          ),
          Container(
             alignment: Alignment.topRight,
            height: 5,
            child: IconButton(
                onPressed: () {
                  deleteMeasurements();
                },
                icon: Icon(
                    Icons.delete_sweep), color: Colors.white,
            ),
          ),
          // Ölçüm kartları
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: measurements.isEmpty
                  ? Center(
                      child: Text(
                        "Henüz bir sonuç kaydedilmemiş",
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: Colors.white),
                      ),
                    )
                  : ListView.builder(
                      itemCount: measurements.length,
                      itemBuilder: (context, index) {
                        final DateTime timestamp =
                            measurements[index]['timestamp'];
                        final String formattedDate =
                            DateFormat('dd MMM yyyy HH:mm').format(timestamp);

                        final measurement = measurements[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (ctx) => HealthMonitorScreen(
                                measurement: measurement,
                                TestId: measurement['id'] // Pass the entire map
                              ),
                            ));
                          },
                          child: ElevatedMeasurementCard(
                            emoji: measurement['emoji'],
                            fvc: measurement['fvc'].toString(),
                            pef: measurement['pef'].toString(),
                            fev1: measurement['fev1'].toString(),
                            // Add other metrics as needed
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
    final metricsPushKey =
        Provider.of<MetricsPushKeyProvider>(context).metricsPushKey;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).canvasColor,
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
