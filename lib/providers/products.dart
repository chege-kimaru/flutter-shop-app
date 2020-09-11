import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/providers/product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    Product(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    Product(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    Product(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),
  ];

  final String _authToken;
  final String _userId;

  Products(this._authToken, this._userId, _items);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favItems {
    return _items
        .where((product) => product.isFavorite != null && product.isFavorite)
        .toList();
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  // //using .then
  // Future<void> addProduct(Product product) {
  //   const url = 'https://flutter-shop-app-38330.firebaseio.com/products.json';
  //   return http
  //       .post(url,
  //           body: json.encode({
  //             'title': product.title,
  //             'description': product.description,
  //             'price': product.price,
  //             'imageUrl': product.imageUrl,
  //             'isFavorite': product.isFavorite
  //           }))
  //       // then also returns a future so this works great for us
  //       .then((response) {
  //     final newProduct = Product(
  //         id: json.decode(response.body)['name'],
  //         title: product.title,
  //         description: product.description,
  //         price: product.price,
  //         imageUrl: product.imageUrl);
  //     _items.add(newProduct);
  //     // _items.insert(0, newProduct); //insert at start of list
  //     notifyListeners();
  //   }).catchError((error) => throw error);
  // }

  Future<void> fetchAndSetProducts([filterByUser = false]) async {
    try {
      final filterString =
          filterByUser ? 'orderBy="creatorId"&equalTo="$_userId"' : '';
      final url =
          'https://flutter-shop-app-38330.firebaseio.com/products.json?auth=$_authToken&$filterString';
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      if (extractedData == null) return;
      final favoriteUrl =
          'https://flutter-shop-app-38330.firebaseio.com/userFavorites/$_userId.json?auth=$_authToken';
      final favoriteResponse = await http.get(favoriteUrl);
      final favoriteData = json.decode(favoriteResponse.body);

      extractedData.forEach((key, value) {
        loadedProducts.add(Product(
            id: key,
            title: value['title'],
            description: value['description'],
            price: value['price'],
            imageUrl: value['imageUrl'],
            isFavorite:
                favoriteData == null ? false : favoriteData[key] ?? false));
      });
      _items = loadedProducts;
      print(_items);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  // using async await
  Future<void> addProduct(Product product) async {
    try {
      final url =
          'https://flutter-shop-app-38330.firebaseio.com/products.json?auth=$_authToken';
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'creatorId': _userId,
          }));
      final newProduct = Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);
      _items.add(newProduct);
      // _items.insert(0, newProduct); //insert at start of list
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> editProduct(String id, Product product) async {
    final productIndex = _items.indexWhere((element) => element.id == id);
    if (productIndex >= 0) {
      final url =
          'https://flutter-shop-app-38330.firebaseio.com/products/$id.json?auth=$_authToken';
      await http.patch(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl
          }));
      _items[productIndex] = product;
    } else {}
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    final existingProductIndex =
        _items.indexWhere((element) => element.id == id);
    var existingProduct = _items[existingProductIndex];

    try {
      final url =
          'https://flutter-shop-app-38330.firebaseio.com/products/$id.json?auth=$_authToken';
      final response = await http.delete(url);
      if (response.statusCode >= 400) {
        throw HttpException('Could not delete product');
      }
      existingProduct = null;
      _items.removeWhere((element) => element.id == id);
      notifyListeners();
    } catch (error) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw error;
    }
  }
}
