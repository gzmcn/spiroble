import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'dart:math';


class FEV1Calculator {

    List<List<dynamic>> ikincitabloData = []; 

    Future<void> loadIkincitablodata() async {
      final String response = await rootBundle.loadString('assets/ikincitablo.csv');
      ikincitabloData = const CsvToListConverter().convert(response);
    }

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
      // FEV1 kadın verisini double'a dönüştürmem
      return double.tryParse(row[6].toString()) ?? 0.0;
    }).toList();

    // Yaşa uygun FEV1 hesaplama (örneğin erkek için)
    double fev1Male = linearInterpolation(age, ages, fev1Males);
    // Veya kadın için:
    // double fev1Female = linearInterpolation(age, ages, fev1Females);

    return fev1Male; // veya fev1Female
  }

  List<dynamic> getCoefficientsColumn(int index, bool isMale) {
  int columnIndex = isMale ? index + 1 : index + 6; // Adjust column based on gender
  List<dynamic> columnCoefficients = [];
  
  // Get values from rows 1-6 (skipping header row 0) for the specified column
  for (int i = 1; i <= 6; i++) {
    if (i < ikincitabloData.length && columnIndex < ikincitabloData[i].length) {
      columnCoefficients.add(ikincitabloData[i][columnIndex]);
    }
  }
  
  print('Column coefficients: $columnCoefficients');
  return columnCoefficients;
}

  Future<double> calculateVariable(int index, double age, double height, bool isMale,
    {double AfrAm = 1.0, double NEAsia = 0.0, double SEAsia = 0.0}) async {
  try {
    print('Starting calculation with:');
    print('Index: $index, Age: $age, Height: $height, IsMale: $isMale');

    // Load data if needed
    if (ikincitabloData.isEmpty) {
      await loadIkincitablodata();
    }

    // Validate inputs
    if (index < 0 || index > 4) {
      throw Exception("Invalid index. Must be between 0 and 4.");
    }
    if (height <= 0 || age <= 0) {
      throw Exception("Height and age must be positive.");
    }

    // Get coefficients
    int genderOffset = isMale ? 1 : 6;
    print('Using gender offset: $genderOffset');

    if (index + 1 >= ikincitabloData.length) {
      throw Exception("Index out of range in ikincitabloData.");
    }

    List<dynamic> coefficients = getCoefficientsColumn(index, isMale);
    print('Raw coefficients: $coefficients');

    // Parse coefficients vertically
    double a0 = double.parse(coefficients[0].toString());
    double a1 = double.parse(coefficients[1].toString());
    double a2 = double.parse(coefficients[2].toString());
    double a3 = double.parse(coefficients[3].toString());
    double a4 = double.parse(coefficients[4].toString());
    double a5 = double.parse(coefficients[5].toString());

    print('Parsed coefficients:');
    print('a0: $a0, a1: $a1, a2: $a2, a3: $a3, a4: $a4, a5: $a5');

    // Calculate exponent terms
    double lnHeight = log(height);
    double lnAge = log(age);

    print('Calculated logarithms:');
    print('ln(height): $lnHeight');
    print('ln(age): $lnAge');

    // Calculate final exponent
    double exponent = a0 +
        a1 * lnHeight +
        a2 * lnAge +
        a3 * AfrAm +
        a4 * NEAsia +
        a5 * SEAsia;

    print('Calculated exponent: $exponent');

    // Calculate final result
    double result = exp(exponent);
    print('Final result: $result');

    return result;

  } catch (e, stackTrace) {
    print('Error in calculateVariable: $e');
    print('Stack trace: $stackTrace');
    rethrow;
  }
}
}
