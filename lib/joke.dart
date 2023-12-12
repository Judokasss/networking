import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class JokePage extends StatefulWidget {
  @override
  _JokePageState createState() => _JokePageState();
}

class _JokePageState extends State<JokePage> {
  final Dio _dio = Dio();
  String _imageUrl = '';
  String _dogName = '';
  bool _isLoading = false;

  Future<void> _fetchDogImage() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Response response =
          await _dio.get('https://dog.ceo/api/breeds/image/random');

      // Проверка статуса ответа
      if (response.statusCode == 200) {
        Map<String, dynamic> data = response.data as Map<String, dynamic>;

        if (data['status'] == 'success') {
          String imageUrl = data['message'];

          if (imageUrl.isNotEmpty && imageUrl.startsWith('http')) {
            List<String> urlParts = imageUrl.split('/');
            String breedName = urlParts[urlParts.length - 2];
            breedName = breedName.replaceAll('-', ' ');

            setState(() {
              _imageUrl = imageUrl;
              _dogName = breedName;
              _isLoading = false;
            });
          } else {
            _handleError('Ошибка при загрузке изображения');
          }
        } else {
          _handleError('Ошибка при загрузке изображения');
        }
      } else if (response.statusCode == 404) {
        _handleError('Изображение не найдено');
      } else {
        _handleError('Ошибка при загрузке изображения: ${response.statusCode}');
      }
    } catch (error) {
      _handleError('Error: $error');
    }
  }

  void _handleError(String errorMessage) {
    // Обработка ошибок
    setState(() {
      _imageUrl = ''; // Обнуляем изображение
      _dogName = errorMessage;
      _isLoading = false;
    });

    // Попробуйте повторно запросить изображение
    Future.delayed(const Duration(seconds: 2), () {
      if (_imageUrl.isEmpty) {
        _fetchDogImage();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              _imageUrl.isNotEmpty && _imageUrl.startsWith('http')
                  ? Card(
                      elevation: 5,
                      child: Column(
                        children: [
                          Container(
                            height: 330,
                            width: double.infinity,
                            child: Image.network(
                              _imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            _dogName,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _fetchDogImage,
                            child: Text('Получить другую собаку'),
                          ),
                        ],
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _fetchDogImage,
                      child: Text('Получить изображение собаки'),
                    ),
            ],
          );
  }
}
