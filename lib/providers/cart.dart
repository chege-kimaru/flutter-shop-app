import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem(
      {@required this.id,
      @required this.title,
      @required this.quantity,
      @required this.price});
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};
  Map<String, CartItem> get items {
    return {..._items};
  }

  addItem(String productId, double price, String title) {
    if (_items.containsKey(productId)) {
      _items.update(
          productId,
          (currentItem) => CartItem(
              id: currentItem.id,
              title: currentItem.title,
              price: currentItem.price,
              quantity: currentItem.quantity + 1));
    } else {
      _items.putIfAbsent(
          productId,
          () => CartItem(
              id: DateTime.now().toString(),
              title: title,
              price: price,
              quantity: 1));
    }
    notifyListeners();
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((String produtId, CartItem cartItem) =>
        total += cartItem.price * cartItem.quantity);
    return total;
  }

  void removeItem(String key) {
    _items.remove(key);
    notifyListeners();
  }

  void clear() {
    _items = {};
    notifyListeners();
  }
}
