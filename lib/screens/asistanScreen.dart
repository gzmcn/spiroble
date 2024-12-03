import 'package:flutter/material.dart';

class AsistanScreen extends StatefulWidget {
  const AsistanScreen({super.key});

  @override
  _AsistanScreenState createState() => _AsistanScreenState();
}

class _AsistanScreenState extends State<AsistanScreen> {
  final List<Map<String, String>> _botQuestions = [
    {'question': 'Uygulamayı nasıl kullanmalıyım?', 'answer': 'Teste başla butonuna tıkladıktan sonra tüm gücünüzle üfleyin.Biz sizin için ölçüm yapacağız.En doğru sonuçları basit grafikler ile görebilirsiniz.Ayrıca geçmiş verilerinizden önceki ölçümler ile karşılaştırabilirsiniz'},
    {'question': 'Uygulama verilerimi doğru ölçüyor mu', 'answer': 'Tabiki de sizin için en doğru ölçümleri yapıyoruz.Uygulamıza güvenebilirsiniz'},
    {'question': 'Genel kullanıcılar içindeki başarımı görebilir miyim', 'answer': 'Uygulama bireysel ölçüm içindir.Kendi geçmiş verilerinizi görebilirsiniz ama başkalarıyla karşılaştıramazsınız.'},
    {'question': 'Cihazımda sorun var cihaz değişimi yapıyor musunuz', 'answer': 'Maalesef hayır.Cihazınız bozulduysa yeni bir cihaz satın almanız gerekmektedir.'},
  ];

  final List<Map<String, String>> _chatHistory = [];

  void _onQuestionSelected(Map<String, String> questionAndAnswer) {
    setState(() {
      _chatHistory.add(questionAndAnswer);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistan Chat'),
      ),
      body: Column(
        children: [
          // Sohbet geçmişi gösterimi
          Expanded(
            child: ListView.builder(
              itemCount: _chatHistory.length,
              itemBuilder: (context, index) {
                final item = _chatHistory[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kullanıcının seçtiği soru
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(item['question']!),
                      ),
                    ),
                    // Botun verdiği cevap
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(item['answer']!),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          // Botun sunduğu sorular
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: _botQuestions.map((qa) {
                return GestureDetector(
                  onTap: () => _onQuestionSelected(qa),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 5,
                          spreadRadius: 2,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline, color: Colors.blue),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            qa['question']!,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
