import 'package:flutter/material.dart';

class SpiroScreen extends StatefulWidget {
  const SpiroScreen({super.key});

  @override
  State<SpiroScreen> createState() => _SpiroScreen();
}

class _SpiroScreen extends State<SpiroScreen> {
  double progress = 0.0; // Initial progress (0 to 10)
  final double maxHeight = 10.0; // Maksimum yükseklik (10 birim)

  // This function is used to increment the progress by 1 unit
  void incrementProgress() {
    setState(() {
      if (progress < maxHeight) {
        progress += 1.0; // Char 1 geldiğinde sıvıyı bir birim yükselt
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [const Color(0xFFA0BAFD), Colors.deepOrange.shade700],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Üfleyin",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              CustomPaint(
                size: const Size(120, 300), // Boru boyutu
                painter: SpirometerPainter(progress, maxHeight),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // Teste başla işlevi
                  print("Teste Başla butonuna tıklandı.");
                  incrementProgress(); // Butona basıldığında sıvıyı bir birim yükselt
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: const Color.fromARGB(255, 0, 0, 0),
                  backgroundColor: const Color.fromARGB(255, 251, 251, 251),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 15), // Buton boyutu
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(30), // Yuvarlatılmış köşeler
                  ),
                  elevation: 8, // Gölge efekti
                ),
                child: const Text(
                  "Char 1 Verisi Gönder",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              if (progress == maxHeight) // Sıvı en üst seviyeye geldiğinde
                const Text(
                  "Sonuçlandı",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SpirometerPainter extends CustomPainter {
  final double progress; // Animasyonun ilerleme değeri
  final double maxHeight; // Maksimum yükseklik (10 birim)

  SpirometerPainter(this.progress, this.maxHeight);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint progressPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.blueAccent, Colors.purpleAccent], // Gradyan renkler
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final rect = Rect.fromLTWH(20, 10, size.width - 40,
        size.height - 20); // Boru şeklindeki dikdörtgen
    final progressHeight =
        (size.height - 20) * (progress / maxHeight); // Sıvı seviyesi

    // Boru (dış çerçeve)
    canvas.drawRect(rect, borderPaint);

    // İçerideki sıvı
    canvas.drawRect(
      Rect.fromLTWH(20, size.height - 10 - progressHeight, size.width - 40,
          progressHeight),
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SpiroScreen(),
  ));
}
