import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shopapp/models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double price;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.imageUrl,
    @required this.price,
    this.isFavorite = false,
  });

  void _setFavoriteValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavorite(String authToken, String userId) async {
    final url =
        "https://shopapp-42c90-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$authToken";
    bool oldStatus = isFavorite;

    _setFavoriteValue(!isFavorite);

    try {
      final response = await http.put(
        url,
        body: json.encode(isFavorite),
      );

      if (response.statusCode >= 400) {
        _setFavoriteValue(oldStatus);
        throw HttpException("There is an error");
      }
    } catch (error) {
      _setFavoriteValue(oldStatus);
    }
  }
}
