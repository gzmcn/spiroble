import 'package:flutter/material.dart';

class MatematikSayfasi extends StatelessWidget {
  final List<double> akisHizi; // Akış hızları
  final List<double> toplamVolum; // Toplam hacim
  final List<double> miliSaniye; // Zaman (milisaniye)

  MatematikSayfasi({
    required this.akisHizi,
    required this.toplamVolum,
    required this.miliSaniye,
  });

  // FEV1 (Forced Expiratory Volume in 1 second) hesaplama
  double hesaplaFEV1(List<double> akisHizi, List<double> zaman) {
    // İlk bir saniye (1000 ms) için toplam hacmi hesaplayacağız
    double totalVolume = 0;

    for (int i = 0; i < akisHizi.length - 1; i++) {
      // Zaman farkını hesapla (milisaniyeyi saniyeye çevir)
      double deltaTime = (zaman[i + 1] - zaman[i]) / 1000.0;

      // Akış hızı ile zaman farkını çarparak hacim artışını hesapla
      totalVolume += akisHizi[i] * deltaTime;

      // 1 saniyeyi geçtikten sonra işlemi durdur
      if (zaman[i + 1] >= 1000) {
        break;
      }
    }

    return totalVolume;
  }

  // FVC (Forced Vital Capacity) hesaplama
  double hesaplaFVC(List<double> toplamVolum) {
    // FVC, toplam vital kapasiteyi temsil eder ve genellikle hacmin başlangıçtan sona kadar olan farkıdır.
    return toplamVolum.last - toplamVolum.first;
  }

  // PEF (Peak Expiratory Flow) hesaplama
  double hesaplaPEF(List<double> akisHizi) {
    // PEF, zirve ekspirasyon akış hızıdır, yani en yüksek akış hızını alırız.
    return akisHizi
        .reduce((value, element) => value > element ? value : element);
  }

  // FEF2575 (Forced Expiratory Flow at 25-75% of FVC) hesaplama
  double hesaplaFEF2575(List<double> akisHizi, List<double> toplamVolum) {
    // Bu hesaplama, FVC'nin %25 ve %75'inde ölçülen akış hızlarını kullanır.
    // 25% ve 75%'in hacim değerlerini bulmamız gerek.
    double fvc = hesaplaFVC(toplamVolum);
    double fef25 = 0.0;
    double fef75 = 0.0;

    // %25 ve %75 hacim değerlerini bulma
    double volume25 = fvc * 0.25;
    double volume75 = fvc * 0.75;

    // Bu hacimleri kullanarak FEF25 ve FEF75'yi hesaplama
    for (int i = 0; i < toplamVolum.length; i++) {
      if (toplamVolum[i] >= volume25 && fef25 == 0.0) {
        fef25 = akisHizi[i];
      }
      if (toplamVolum[i] >= volume75 && fef75 == 0.0) {
        fef75 = akisHizi[i];
        break; // %75'teki akış hızını bulduktan sonra duruyoruz.
      }
    }

    // FEF2575, FEF25 ve FEF75'in ortalaması alınarak hesaplanır
    return (fef25 + fef75) / 2;
  }

  @override
  Widget build(BuildContext context) {
    final fef2575 = hesaplaFEF2575(akisHizi, toplamVolum);
    final fvc = hesaplaFVC(toplamVolum);
    final fev1 = hesaplaFEV1(akisHizi, toplamVolum);
    final pef = hesaplaPEF(akisHizi);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matematiksel Hesaplamalar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FEF2575: $fef2575'),
            Text('FVC: $fvc'),
            Text('FEV1: $fev1'),
            Text('PEF: $pef'),
            Text('FEV1/FVC: ${fev1 / fvc}'),
          ],
        ),
      ),
    );
  }
}
