import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:geolocator/geolocator.dart';

class WeatherPage extends StatefulWidget {
  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final String apiKey = "446845576747717ea9bd7c2aa1aed387";
  String city = ""; // Исходный город
  Dio dio = Dio();

  @override
  void initState() {
    super.initState();
    _getInitialWeatherData();
  }

  Future<void> _getInitialWeatherData() async {
    // Проверяем разрешения на доступ к геолокации
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // Если разрешения отсутствуют, запрашиваем их
      await _requestLocationPermission();
    } else {
      // Разрешения есть, получаем текущую геопозицию пользователя
      await _getCurrentLocationWeather();
    }
  }

  Future<void> _getCurrentLocationWeather() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Используем координаты для запроса данных о погоде
      await _updateWeatherData(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  Future<void> _requestLocationPermission() async {
    // Запрашиваем разрешение на доступ к геолокации
    LocationPermission permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // Пользователь отклонил запрос, обрабатываем ситуацию
      // выводим сообщение
    } else {
      // Разрешение получено, обновляем данные о погоде
      await _getCurrentLocationWeather();
    }
  }

  Future<void> _updateWeatherData({double? latitude, double? longitude}) async {
    if (latitude != null && longitude != null) {
      try {
        Map<String, dynamic>? weatherData = await getWeatherData(
          latitude: latitude,
          longitude: longitude,
        );
        if (weatherData == null) {
          print('Данные о погоде для текущего местоположения недоступны');
        } else {
          setState(() {
            city = weatherData[
                'name']; // Обновляем город на основе данных о местоположении
          });
        }
      } catch (error) {
        print('Ошибка при обновлении погодных данных: $error');
      }
    }
  }

  Future<Map<String, dynamic>?> getWeatherData({
    double? latitude,
    double? longitude,
  }) async {
    try {
      String url = 'https://api.openweathermap.org/data/2.5/weather';
      if (latitude != null && longitude != null) {
        url += '?lat=$latitude&lon=$longitude';
      } else {
        url += '?q=$city';
      }
      url += '&appid=$apiKey';

      Response response = await dio.get(url);

      if (response.statusCode == 200) {
        Map<String, dynamic> weatherData = json.decode(response.toString());

        // Добавляем проверку на пустоту или ошибки в данных о погоде
        if (weatherData.isEmpty ||
            weatherData['main'] == null ||
            weatherData['weather'] == null) {
          return null; // Возвращаем null в случае пустоты или ошибок
        }

        return weatherData;
      } else {
        return null; // Возвращаем null в случае ошибки HTTP
      }
    } catch (error) {
      return null; // Возвращаем null в случае других ошибок
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Weather App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              _showSearchDialog(context);
            },
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder(
          future: getWeatherData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text(
                'Error: ${snapshot.error}',
                style: TextStyle(fontWeight: FontWeight.bold),
              );
            } else {
              if (snapshot.data == null) {
                return Text(
                  'Такого местоположения не существует',
                  style: TextStyle(fontWeight: FontWeight.bold),
                );
              }

              var weatherData = snapshot.data as Map<String, dynamic>;

              // Конвертируем температуру из Кельвинов в Цельсии
              var temperatureInCelsius =
                  (weatherData['main']['temp'] - 273.15).toStringAsFixed(1);

              // Получаем данные о том, как ощущается погода
              var feelsLikeTemperature =
                  (weatherData['main']['feels_like'] - 273.15)
                      .toStringAsFixed(1);

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Погода в $city: $temperatureInCelsius°C',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Ощущается как: $feelsLikeTemperature°C',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (weatherData['weather'][0]['icon'] != null)
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                              'https://openweathermap.org/img/w/${weatherData['weather'][0]['icon']}.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    Text(
                      'Weather icon not available',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  SizedBox(height: 20),
                  _buildDetailedWeather(weatherData),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildDetailedWeather(Map<String, dynamic> weatherData) {
    if (weatherData['main'] == null || weatherData['wind'] == null) {
      return Text(
        'Detailed weather data is missing.',
        style: TextStyle(fontWeight: FontWeight.bold),
      );
    }

    var humidity = weatherData['main']['humidity'];
    var pressure = weatherData['main']['pressure'];
    var windSpeed = weatherData['wind']['speed'];

    return Column(
      children: [
        Text(
          'Влажность: $humidity%',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          'Давление: $pressure hPa',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          'Скорость ветра: $windSpeed м/с',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  _showSearchDialog(BuildContext context) async {
    TextEditingController searchController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Enter city name',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'City Name',
              hintStyle: TextStyle(fontWeight: FontWeight.normal),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                String enteredCity = searchController.text.trim();
                if (enteredCity.isNotEmpty) {
                  setState(() {
                    city = enteredCity;
                  });
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Вы ничего не ввели!!!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text(
                'Search',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
