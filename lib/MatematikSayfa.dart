import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class MatematikSayfasi extends StatelessWidget {
  final List<double> akisHizi;
  final List<double> toplamVolum;
  final List<double> miliSaniye;

  MatematikSayfasi({
    required this.akisHizi,
    required this.toplamVolum,
    required this.miliSaniye,
  });

  double hesaplaFEV1(List<double> akisHizi, List<double> zaman) {
    double totalVolume = 0;
    for (int i = 0; i < akisHizi.length - 1; i++) {
      double deltaTime = (zaman[i + 1] - zaman[i]) / 1000.0;
      totalVolume += akisHizi[i] * deltaTime;
      if (zaman[i + 1] >= 1000) break;
    }
    return totalVolume;
  }

  double hesaplaFVC(List<double> toplamVolum) {
    return toplamVolum.last - toplamVolum.first;
  }

  double hesaplaPEF(List<double> akisHizi) {
    return akisHizi
        .reduce((value, element) => value > element ? value : element);
  }

  double hesaplaFEF2575(List<double> akisHizi, List<double> toplamVolum) {
    double fvc = hesaplaFVC(toplamVolum);
    double fef25 = 0.0;
    double fef75 = 0.0;
    double volume25 = fvc * 0.25;
    double volume75 = fvc * 0.75;

    for (int i = 0; i < toplamVolum.length; i++) {
      if (toplamVolum[i] >= volume25 && fef25 == 0.0) fef25 = akisHizi[i];
      if (toplamVolum[i] >= volume75 && fef75 == 0.0) {
        fef75 = akisHizi[i];
        break;
      }
    }
    return (fef25 + fef75) / 2;
  }

  Future<void> hesaplaVeKaydet() async {
    final fef2575 = hesaplaFEF2575(akisHizi, toplamVolum);
    final fvc = hesaplaFVC(toplamVolum);
    final fev1 = hesaplaFEV1(akisHizi, miliSaniye);
    final pef = hesaplaPEF(akisHizi);
    final fev1Fvc = fev1 / fvc;
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('Kullanıcı giriş yapmamış!');
      return;
    }
    String userId = user.uid; //s

    final databaseRef = FirebaseDatabase.instance.ref();

    try {
      await databaseRef.child('sonuclar/$userId').push().set({
        'fef2575': fef2575,
        'fvc': fvc,
        'fev1': fev1,
        'pef': pef,
        'fev1Fvc': fev1Fvc,
        'timestamp': DateTime.now().toIso8601String(),
      });
      print('Sonuç başarıyla kaydedildi!');
    } catch (e) {
      print('Sonuç kaydedilirken bir hata oluştu: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Matematiksel Hesaplamalar'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              await hesaplaVeKaydet();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Sonuç başarıyla kaydedildi!')),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Bir hata oluştu: $e')),
              );
            }
          },
          child: const Text('Hesapla ve Kaydet'),
        ),
      ),
    );
  }
}
