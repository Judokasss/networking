import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:networking/currency_dropdown.dart';
import 'weather.dart';
import 'joke.dart';

void main() {
  runApp(NetworkingApp());
}

class NetworkingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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

  List<String> currencies = [];

  String fromCurrency = 'USD';
  String toCurrency = 'RUB';

  TextEditingController amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadCurrencies();
  }

  Future<void> loadCurrencies() async {
    try {
      Response response = await _dio.get(
          'https://v6.exchangerate-api.com/v6/e60de7641155726cec5968ea/latest/USD');
      Map<String, dynamic> data = response.data as Map<String, dynamic>;

      List<String> loadedCurrencies = data['conversion_rates'].keys.toList();

      setState(() {
        currencies = loadedCurrencies;
      });
    } catch (error) {
      print('Error loading currencies: $error');
    }
  }

  Future<void> fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Проверка на пустой ввод
      if (amountController.text.isEmpty) {
        setState(() {
          _data = 'Введите значение для конвертации';
          _isLoading = false;
        });
        return;
      }

      double amount = double.tryParse(amountController.text) ?? 0.0;

      Response response = await _dio.get(
        'https://v6.exchangerate-api.com/v6/e60de7641155726cec5968ea/latest/$fromCurrency',
      );
      Map<String, dynamic> data = response.data as Map<String, dynamic>;

      setState(() {
        if (data['result'] == 'success') {
          _data =
              '$amount $fromCurrency = ${amount * data['conversion_rates'][toCurrency]} $toCurrency';
        } else {
          _data = 'Ошибка при загрузке курсов валют';
        }
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _data = 'Error: $error';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Количество вкладок
      child: Scaffold(
        backgroundColor: Colors.blue[50],
        appBar: AppBar(
          backgroundColor: Colors.lightBlueAccent,
          centerTitle: true,
          title: Text('Networking'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Currency'),
              Tab(text: 'Weather'),
              Tab(text: 'Joke'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Содержимое для вкладки "Currency"
            _buildCurrencyTab(),
            // Содержимое для вкладки "Weather"
            WeatherPage(),
            // Содержимое для вкладки "Joke"
            JokePage(),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyTab() {
    return _isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CurrencyDropdown(
                    label: 'Из:',
                    value: fromCurrency,
                    currencies: currencies,
                    onChanged: (String? newValue) {
                      setState(() {
                        fromCurrency = newValue ?? 'USD';
                      });
                    },
                  ),
                  SizedBox(width: 20),
                  CurrencyDropdown(
                    label: 'В:',
                    value: toCurrency,
                    currencies: currencies,
                    onChanged: (String? newValue) {
                      setState(() {
                        toCurrency = newValue ?? 'RUB';
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 10),
              Container(
                width: 280,
                child: TextField(
                  controller: amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'Введите значения для конвертации',
                  ),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: fetchData,
                child: Text('Конвертировать'),
              ),
              SizedBox(height: 20),
              Text(
                _data,
                style: TextStyle(fontSize: 18),
              ),
            ],
          );
  }
}
