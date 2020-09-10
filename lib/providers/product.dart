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

  Future<void> toggleFavoriteStatus() async {
    if (this.isFavorite == null) {
      this.isFavorite = false;
    }
    final oldStatus = isFavorite;
    this.isFavorite = !this.isFavorite;
    notifyListeners();
    final url =
        'https://flutter-shop-app-38330.firebaseio.com/products/$id.json';
    try {
      final response =
          await http.patch(url, body: json.encode({'isFavorite': isFavorite}));
      if (response.statusCode >= 400) {
        throw HttpException('Could not favorite product');
      }
    } catch (error) {
      isFavorite = oldStatus;
      notifyListeners();
    }
  }
}
