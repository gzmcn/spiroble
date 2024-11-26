import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      home: ResultsScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ResultsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final String? userId = FirebaseAuth.instance.currentUser?.uid;
    print(userId);

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Kullanıcı oturumu açık değil.')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFA0BAFD),
        elevation: 0,
        title: const Text(
          'Sonuçlarım',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('results')
            .where('userId', isEqualTo: userId)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Bir hata oluştu: ${snapshot.error}'));
          }

          final results = snapshot.data?.docs ?? [];
          if (results.isEmpty) {
            return const Center(child: Text('Henüz sonuç bulunmamaktadır.'));
          }

          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final resultData = results[index].data() as Map<String, dynamic>;
              final int averageValue = resultData['average'] ?? 0;
              final Color circleColor = _getColorBasedOnAverage(averageValue);

              return GestureDetector(
                onTap: () {
                  // Tıklama işlemini buraya ekleyebilirsiniz.
                  // Örneğin, detay ekranına yönlendirme:
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => TestDetailScreen(resultData),
                  //   ),
                  // );
                  print('Tıklanan sonuç: $averageValue');
                },
                child: Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 3,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(15),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: circleColor,
                      ),
                      child: Center(
                        child: Text(
                          averageValue.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      'Sonuç #$index',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Ortalama Değer: $averageValue',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Ortalama değere göre renk belirleyen yardımcı fonksiyon
  Color _getColorBasedOnAverage(int average) {
    if (average >= 75) {
      return Colors.green; // 75 ve üzeri: Yeşil
    } else if (average >= 50) {
      return Colors.orange; // 50-74 arası: Turuncu
    } else {
      return Colors.red; // 0-49 arası: Kırmızı
    }
  }
}
