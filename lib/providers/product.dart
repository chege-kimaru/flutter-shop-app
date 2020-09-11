import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite = false;

  Product(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.price,
      @required this.imageUrl,
      this.isFavorite});

  Future<void> toggleFavoriteStatus(String token, String userId) async {
    if (this.isFavorite == null) {
      this.isFavorite = false;
    }
    final oldStatus = isFavorite;
    this.isFavorite = !this.isFavorite;
    notifyListeners();
    final url =
        'https://flutter-shop-app-38330.firebaseio.com/userFavorites/$userId.json?auth=$token';
    try {
      final response = await http.put(url, body: json.encode({id: isFavorite}));
      print('Favoriting data');
      print(response.body);
      if (response.statusCode >= 400) {
        throw HttpException('Could not favorite product');
      }
    } catch (error) {
      print(error);
      isFavorite = oldStatus;
      notifyListeners();
    }
  }
}
