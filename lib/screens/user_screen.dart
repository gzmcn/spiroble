import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/services.dart';
import 'package:spiroble/Screens/ResetPasswordScreen.dart';
import 'package:spiroble/screens/LoginScreen.dart';
import 'package:spiroble/widgets/CircularProgressBar.dart';
import 'package:spiroble/widgets/input_fields.dart';
import 'package:fancy_button_flutter/fancy_button_flutter.dart';
import 'dart:convert';
import 'dart:math';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ProfileScreenState();
  }
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseReference database = FirebaseDatabase.instance.ref();
  final FirebaseAuth auth = FirebaseAuth.instance;

  bool loading = true;
  Map<String, String> userData = {
    'ad': '',
    'soyad': '',
    'dogumTarihi': '',
    'kilo': '',
    'boy': '',
    'cinsiyet': '',
    'uyruk': '',
    'email': '',
    'password': '',
  };

  Map<String, double> results = {};

  final TextEditingController adController = TextEditingController();
  final TextEditingController soyadController = TextEditingController();
  final TextEditingController dogumTarihiController = TextEditingController();
  final TextEditingController kiloController = TextEditingController();
  final TextEditingController boyController = TextEditingController();
  final TextEditingController uyrukController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final currentUser = auth.currentUser;
      if (currentUser != null) {
        final snapshot = await database.child('users/${currentUser.uid}').get();
        if (snapshot.exists) {
          final data = Map<String, dynamic>.from(snapshot.value as Map);

          // Veri türü uyumsuzluğunu düzeltmek için 'toString' kullanıyoruz
          setState(() {
            adController.text = data['ad'] ?? '';
            soyadController.text = data['soyad'] ?? '';
            dogumTarihiController.text = data['dogumTarihi'] ?? '';

            // 'int' değerleri 'String'e dönüştürüyoruz
            kiloController.text = data['kilo']?.toString() ?? '';
            boyController.text = data['boy']?.toString() ?? '';
            uyrukController.text = data['uyruk'] ?? '';
            emailController.text = currentUser.email ?? '';
            loading = false;

            String gender = data['cinsiyet'] ?? 'Erkek';

            // calculateM fonksiyonunu burada çağırıyoruz
            calculateMForAllLabels(
                gender); // 'gender' parametresini gönderiyoruz
          });
        }
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  Future<void> calculateMForAllLabels(String gender) async {
    try {
      // Dosyaları yükle
      final parametersData =
          await rootBundle.loadString('assets/parameters.csv');
      final secondTableData =
          await rootBundle.loadString('assets/ikincitablo.csv');

      // CSV verilerini ayrıştır ve tür dönüşümü yap
      List<List<double>> parametersTable = const LineSplitter()
          .convert(parametersData)
          .map((line) =>
              line.split(',').map((e) => double.tryParse(e) ?? 0.0).toList())
          .toList();
      List<List<dynamic>> secondTable = const LineSplitter()
          .convert(secondTableData)
          .map((line) => line.split(','))
          .toList();

      Map<String, double> tempResults = {};

      // Sabitler (ikincitablo.csv) - Yatay olarak al
      Map<String, Map<String, double>> constants = {};
      for (int i = 1; i < secondTable.length; i++) {
        for (int j = 1; j < secondTable[i].length; j++) {
          String label = secondTable[0][j]; // The label is in the first row
          if (!constants.containsKey(label)) {
            constants[label] = {};
          }
          constants[label]?[secondTable[i][0]] =
              double.parse(secondTable[i][j]);
        }
      }

      // Hasta verileri
      double age = 26;
      double height = 184;
      int afrAm = 0;
      int neAsia = 0;
      int seAsia = 0;

      // Mspline interpolasyonu fonksiyonu
      double interpolateMspline(double age, double ageClose, double ageNext,
          double msplineClose, double msplineNext) {
        return msplineClose +
            ((age - ageClose) / 0.25) * (msplineNext - msplineClose);
      }

      // Sonuçları sakla

      // Her etiket için hesaplama yap
      for (var title in constants.keys) {
        // Cinsiyete göre sabitler
        var labels = gender == 'Erkek'
            ? [
                'FEV1 males',
                'FVC males',
                'FEV1FVC males',
                'FEF2575 males',
                'FEF75 males'
              ]
            : [
                'FEV1 females',
                'FVC females',
                'FEV1FVC females',
                'FEF2575 females',
                'FEF75 females'
              ];

        for (var label in labels) {
          // Sabitler a0, a1, a2, a3, a4, a5 değerlerini al
          double a0 = constants[label]?['a0'] ?? 0.0;
          double a1 = constants[label]?['a1'] ?? 0.0;
          double a2 = constants[label]?['a2'] ?? 0.0;
          double a3 = constants[label]?['a3'] ?? 0.0;
          double a4 = constants[label]?['a4'] ?? 0.0;
          double a5 = constants[label]?['a5'] ?? 0.0;

          // Yaş aralığını bul
          var closeRow = parametersTable.lastWhere((row) => row[0] <= age);
          var nextRow = parametersTable.firstWhere((row) => row[0] > age);

          // Mspline değerini her etiket için farklı kolonlardan al
          int msplineColumnIndex =
              labels.indexOf(label) + 1; // Label'a göre kolon indeksini al
          double msplineClose = closeRow[msplineColumnIndex];
          double msplineNext = nextRow[msplineColumnIndex];

          double msplineInterpolated = interpolateMspline(
              age, closeRow[0], nextRow[0], msplineClose, msplineNext);

          // Formülü uygula
          double M = exp(
            a0 +
                a1 * log(height) +
                a2 * log(age) +
                a3 * afrAm +
                a4 * neAsia +
                a5 * seAsia +
                msplineInterpolated,
          );
          if (!tempResults.containsKey(label) || tempResults[label] != M) {
            tempResults[label] =
                M; // Yalnızca değer farklıysa veya yeni bir etiketse kaydet
            print('$label için hesaplanan M: $M');
          }
        }
      }
      setState(() {
        results = tempResults; // Update the results map in the state
      });
    } catch (e) {
      print('Bir hata oluştu: $e');
    }
  }

  Future<void> saveUserData() async {
    try {
      final currentUser = auth.currentUser;
      if (currentUser != null) {
        await database.child('users/${currentUser.uid}').update({
          'ad': adController.text,
          'soyad': soyadController.text,
          'dogumTarihi': dogumTarihiController.text,
          'kilo': kiloController.text,
          'boy': boyController.text,
          'uyruk': uyrukController.text,
        });
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Profil başarıyla güncellendi!')));
      }
    } catch (error) {
      print('Error updating user data: $error');
    }
  }

  Future<String> fetchUserName() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // Reference to the users' data
      final database = FirebaseDatabase.instance.ref();
      final snapshot = await database.child('users/${currentUser.uid}').get();

      // Check if data exists
      if (snapshot.exists) {
        final userName = snapshot.child('ad').value;

        // Safely return the username as a string or a fallback if null
        return userName != null ? userName.toString() : "No name available";
      } else {
        print("No user data available");
        return "No name available";
      }
    } else {
      print("No current user found.");
      return "No name available";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Profilim',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await auth.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (ctx) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Updated Profile Section
            Container(
              padding: EdgeInsets.all(16),
              height: 130,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFFA0BAFD), Color(0xFF3A2A6B)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage("assets/user-logo.png"),
                    radius: 35,
                  ),
                  SizedBox(width: 20), // Spacing between avatar and text
                  Expanded(
                    // Ensures the text gets enough space
                    child: FutureBuilder<String>(
                      future: fetchUserName(), // Call the async function here
                      builder: (BuildContext context,
                          AsyncSnapshot<String> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            // Center the loading indicator
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Text(
                            "Error loading name",
                            style: TextStyle(color: Colors.white, fontSize: 22),
                          );
                        } else if (snapshot.hasData) {
                          return Text(
                            snapshot.data ??
                                "Unknown User", // Display the username once fetched
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          );
                        } else {
                          return Text(
                            "No name available",
                            style: TextStyle(color: Colors.white, fontSize: 22),
                          );
                        }
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.settings),
                    onPressed: () {},
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Input Fields
            InputFields(
              controller: adController,
              placeholder: 'Ad',
              icon: Icon(
                Icons.person,
                color: Color(0xFFA0BAFD),
              ),
            ),
            SizedBox(height: 16),
            InputFields(
              controller: soyadController,
              placeholder: 'Soyad',
              icon: Icon(
                Icons.person_outline,
                color: Color(0xFFA0BAFD),
              ),
            ),
            SizedBox(height: 16),
            InputFields(
              controller: dogumTarihiController,
              placeholder: 'Doğum Tarihi (YYYY-MM-DD)',
              icon: Icon(
                Icons.calendar_today,
                color: Color(0xFFA0BAFD),
              ),
              keyboardType: TextInputType.datetime,
            ),
            SizedBox(height: 16),
            InputFields(
              controller: kiloController,
              placeholder: 'Kilo (kg)',
              icon: Icon(
                Icons.monitor_weight,
                color: Color(0xFFA0BAFD),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            InputFields(
              controller: boyController,
              placeholder: 'Boy (cm)',
              icon: Icon(
                Icons.height,
                color: Color(0xFFA0BAFD),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16),
            InputFields(
              controller: uyrukController,
              placeholder: 'Uyruk',
              icon: Icon(
                Icons.flag,
                color: Color(0xFFA0BAFD),
              ),
            ),
            SizedBox(height: 16),
            InputFields(
              controller: emailController,
              placeholder: 'E-posta',
              icon: Icon(
                Icons.mail,
                color: Color(0xFFA0BAFD),
              ),
            ),
            SizedBox(height: 16),
            Align(
              alignment: Alignment.center,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100, // Açık mavi arka plan rengi
                  borderRadius: BorderRadius.circular(12), // Kenar yuvarlatma
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade200
                          .withOpacity(0.5), // Hafif mavi gölge
                      blurRadius: 8, // Bulanıklık
                      offset: Offset(0, 4), // Gölgede hafif dikey kayma
                    ),
                  ],
                ),
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (ctx) => ResetPasswordScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Şifremi Değiştirmek İsterim',
                    style: TextStyle(
                      color: Color(0xFFA0BAFD), // Daha koyu mavi yazı rengi
                      fontSize: 16, // Font boyutu
                      fontWeight: FontWeight.bold, // Kalın yazı
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 24),

            SizedBox(
                height:
                    16), // Kaydet butonu ile M Hesapla butonu arasında boşluk

            // Save Button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: FancyButton(
                onClick: saveUserData,
                button_text: "Kaydet",
                button_height: 50,
                button_width: 300,
                button_radius: 50,
                button_outline_width: 0,
                button_outline_color: Colors.pink[50],
                button_text_size: 22,
                button_color: Color(0xFFA0BAFD),
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      'Beklenen Değerler',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(
                          top: 8), // Adds space between the text and the line
                      height: 4, // Height of the line
                      width: 280, // Width of the line (you can adjust this)
                      color: Colors.black, // Line color
                    ),
                  ],
                ),
              ],
            ),

            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: results.isNotEmpty
                      ? Wrap(
                          spacing: 16, // Horizontal space between items
                          runSpacing: 16, // Vertical space between lines
                          children: results.entries.map((entry) {
                            // Remove the 'males' part from the entry.key
                            String updatedKey = entry.key;
                            if (entry.key.contains('males'))
                              updatedKey =
                                  entry.key.replaceAll('males', '').trim();
                            else
                              updatedKey =
                                  entry.key.replaceAll('females', '').trim();

                            return Container(
                              width: 100, // You can adjust the width as needed
                              child: CustomCircularProgressBar(
                                progress: entry.value, // Use M value here
                                maxValue:
                                    100, // Adjust this based on the M value range
                                minValue: 0,
                                text:
                                    '$updatedKey \n ${entry.value.toStringAsFixed(2)}', // Display label and value
                              ),
                            );
                          }).toList(),
                        )
                      : Container(),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
