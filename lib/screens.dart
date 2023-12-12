import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(NetworkingApp());
}

class NetworkingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Networking',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Dio _dio = Dio();
  String _data = '';
  bool _isLoading = false;

  final String fixerApiKey = 'c711a8ff8be8aa3ce251226f1b69eef4'; // Ваш API ключ

  double rubToUsdRate = 0.0; // Курс RUB к USD

  Future<void> fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Response response = await _dio.get(
        'http://data.fixer.io/api/latest',
        queryParameters: {'access_key': fixerApiKey},
      );

      Map<String, dynamic> data = response.data as Map<String, dynamic>;

      // Обработка данных
      rubToUsdRate = data['rates']['USD'];

      setState(() {
        _data = 'Курс RUB к USD: $rubToUsdRate';
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _data = 'error';
        _isLoading = false;
      });
    }
  }

  double convertRubToUsd(double rubAmount) {
    // Реализуйте логику конвертации валюты
    return rubAmount / rubToUsdRate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Networking'),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _data,
                    style: TextStyle(fontSize: 14),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      fetchData();
                      double usdAmount =
                          convertRubToUsd(1.0); // Пример конвертации
                      print('100 RUB = $usdAmount USD');
                    },
                    child: Text('Fetch Data'),
                  ),
                ],
              ),
      ),
    );
  }
}
