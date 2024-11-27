import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';

class FEV1Calculator {
  // CSV dosyasından veriyi okuma
  Future<List<List<dynamic>>> loadCSVData() async {
    final String response = await rootBundle.loadString('assets/data.csv');
    List<List<dynamic>> data = const CsvToListConverter().convert(response);
    return data;
  }

  // Yaşa göre lineer interpolasyon hesaplama
  double linearInterpolation(double age, List<double> ages, List<double> fev1Values) {
    for (int i = 0; i < ages.length - 1; i++) {
      if (age >= ages[i] && age <= ages[i + 1]) {
        double x0 = ages[i];
        double x1 = ages[i + 1];
        double y0 = fev1Values[i];
        double y1 = fev1Values[i + 1];

        return y0 + (age - x0) * (y1 - y0) / (x1 - x0);
      }
    }
    throw Exception("Age is out of bounds.");
  }

  // FEV1 hesaplama
  Future<double> calculateFEV1(double age) async {
    // CSV verisini yükle
    List<List<dynamic>> rawData = await loadCSVData();

    // Yaş ve FEV1 verilerini çıkaralım
    List<double> ages = rawData.map((row) {
      // Yaş değerini double'a dönüştürme
      return double.tryParse(row[0].toString()) ?? 0.0;
    }).toList();

    List<double> fev1Males = rawData.map((row) {
      // FEV1 erkek verisini double'a dönüştürme
      return double.tryParse(row[1].toString()) ?? 0.0;
    }).toList();

    List<double> fev1Females = rawData.map((row) {
      // FEV1 kadın verisini double'a dönüştürme
      return double.tryParse(row[6].toString()) ?? 0.0;
    }).toList();

    // Yaşa uygun FEV1 hesaplama (örneğin erkek için)
    double fev1Male = linearInterpolation(age, ages, fev1Males);
    // Veya kadın için:
    // double fev1Female = linearInterpolation(age, ages, fev1Females);

    return fev1Male; // veya fev1Female
  }
}
