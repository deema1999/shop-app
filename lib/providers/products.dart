import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

import 'product.dart';

class Products with ChangeNotifier {
  final String authToken;
  final String userId;
  List<Product> _items = [];

  Products(this.authToken, this._items, this.userId);

  List<Product> get items {
    return [..._items];
  }

  Product findProductById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  List<Product> get favoritesProducts {
    return _items.where((product) => product.isFavorite == true).toList();
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    String filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url =
        'https://shopapp-42c90-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString';

    try {
      final response = await http.get(url);
      final List<Product> loadedProducts = [];
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      if (extractedData == null) return;
      url =
          "https://shopapp-42c90-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken";

      final favoriteResponse = await http.get(url);
      final favoriteProducts = json.decode(favoriteResponse.body);

      extractedData.forEach((productId, productData) {
        loadedProducts.add(
          Product(
            id: productId,
            title: productData['title'],
            description: productData['description'],
            imageUrl: productData['imageUrl'],
            price: productData['price'],
            isFavorite: favoriteProducts == null
                ? false
                : favoriteProducts[productId] ?? false,
          ),
        );
      });
      _items = loadedProducts.reversed.toList();
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(Product product) async {
    final String url =
        "https://shopapp-42c90-default-rtdb.firebaseio.com/products.json?auth=$authToken";
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            "creatorId": userId,
            "title": product.title,
            "description": product.description,
            "imageUrl": product.imageUrl,
            "price": product.price,
          },
        ),
      );

      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );

      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> updateProduct(String productId, Product newProduct) async {
    int productIndex = _items.indexWhere((product) => productId == product.id);
    final url =
        "https://shopapp-42c90-default-rtdb.firebaseio.com/products/$productId.json?auth=$authToken";

    if (productIndex >= 0) {
      await http.patch(
        url,
        body: json.encode(
          {
            "title": newProduct.title,
            "description": newProduct.description,
            "imageUrl": newProduct.imageUrl,
            "price": newProduct.price
          },
        ),
      );
      _items[productIndex] = newProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String productId) async {
    final url =
        "https://shopapp-42c90-default-rtdb.firebaseio.com/products/$productId.json?auth=$authToken";

    // This pattern is called optimistic updating
    // we don't wait for delete request result so we remove item immediatly
    // if delete from server failed we don't won't to remove the item from the list
    // so we use this pattern to avoid that problem using roll back
    // since delete don't throw errors i will create my own errror to reach catch error block

    final existingProductIndex =
        _items.indexWhere((product) => product.id == productId);
    var existingProduct = _items[existingProductIndex];

    _items.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException("Could not delete this product .");
    }
    existingProduct = null;
  }
}
