import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  // Veriyi Firebase'den çekme fonksiyonu
  Future<void> _fetchData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('Kullanıcı giriş yapmamış!');
      return;
    }
    String userId = user.uid; // Aktif kullanıcının ID'si

    _databaseRef.child(userId).onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          _items = data.entries.map((e) {
            final key = e.key;
            final value = Map<String, dynamic>.from(e.value);
            return {
              'id': key,
              'fef2575': value['fef2575'],
              'fvc': value['fvc'],
              'fev1': value['fev1'],
              'pef': value['pef'],
              'fev1Fvc': value['fev1Fvc'],
              'timestamp': value['timestamp'],
            };
          }).toList();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          Container(
            height: 100,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: const BoxDecoration(
              color: Color(0xFFA0BAFD),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Test Sonuçları',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Cards
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return GestureDetector(
                  onTap: () {
                    // Burada tıklanan öğe ile ilgili işlem yapabilirsiniz
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(3, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and Icon
                        Row(
                          children: [
                            const Icon(Icons.bubble_chart,
                                color: Color(0xFFA0BAFD)),
                            const SizedBox(width: 8),
                            Text(
                              'Test Sonucu',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Timestamp
                        Align(
                          alignment: Alignment.topRight,
                          child: Text(
                            item['timestamp'],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF888888),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Values
                        Column(
                          children: [
                            Text('FEF2575: ${item['fef2575']}'),
                            Text('FVC: ${item['fvc']}'),
                            Text('FEV1: ${item['fev1']}'),
                            Text('PEF: ${item['pef']}'),
                            Text('FEV1/FVC: ${item['fev1Fvc']}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
