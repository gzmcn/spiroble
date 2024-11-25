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
  final DatabaseReference _databaseRef =
  FirebaseDatabase.instance.ref("test_results");
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    _databaseRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          _items = data.entries.map((e) {
            final key = e.key;
            final value = Map<String, dynamic>.from(e.value);
            return {
              'id': key,
              'title': value['title'],
              'date': value['date'],
              'values': List<String>.from(value['values']),
              'value1': value['value1'],
              'value2': value['value2'],
              'value3': value['value3'],
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
                IconButton(
                  icon: const Icon(Icons.search, color: Colors.black, size: 24),
                  onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context)  => TestDetailScreen(),
                          ),
                      );
                    },
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
                              item['title'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF333333),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Date
                        Align(
                          alignment: Alignment.topRight,
                          child: Text(
                            item['date'],
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF888888),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Values
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: item['values']
                              .map<Widget>(
                                (value) => Text(
                              value,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                          )
                              .toList(),
                        ),
                        const SizedBox(height: 10),
                        // Value Details
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['value1'],
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF666666),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              item['value2'],
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF666666),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              item['value3'],
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF666666),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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

