import 'package:flutter/material.dart';

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

  bool toggleFavoriteStatus() {
    if (this.isFavorite == null) {
      this.isFavorite = false;
    }
    this.isFavorite = !this.isFavorite;
    notifyListeners();
  }
}