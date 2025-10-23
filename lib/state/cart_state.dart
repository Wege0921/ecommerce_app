import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CartItem {
  final Map<String, dynamic> product;
  int quantity;

  CartItem({required this.product, required this.quantity});

  num get unitPrice {
    final p = product['price'];
    if (p is num) return p;
    if (p is String) return num.tryParse(p) ?? 0;
    return 0;
  }
  num get total => unitPrice * quantity;
  int get productId {
    final raw = product['id'];
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) {
      final n = int.tryParse(raw);
      if (n != null) return n;
    }
    return product.hashCode; // fallback to avoid crashes; should not happen in normal flow
  }
}

class CartState extends ChangeNotifier {
  final Map<int, CartItem> _items = {}; // key: productId
  static const _storageKey = 'cart_items_v1';

  CartState() {
    // Defer async load
    Future.microtask(_loadFromStorage);
  }

  List<CartItem> get items => _items.values.toList();
  bool get isEmpty => _items.isEmpty;
  int get count => _items.length;
  int get totalItems => _items.values.fold<int>(0, (sum, it) => sum + it.quantity);

  num get subtotal => _items.values.fold<num>(0, (sum, it) => sum + it.total);

  void add(Map<String, dynamic> product, {int quantity = 1, int? stock}) {
    final dynamic raw = product['id'];
    final int id = raw is int
        ? raw
        : raw is num
            ? raw.toInt()
            : raw is String
                ? (int.tryParse(raw) ?? product.hashCode)
                : product.hashCode;
    final current = _items[id];
    int newQty = (current?.quantity ?? 0) + quantity;
    if (stock != null) newQty = newQty.clamp(1, stock);
    _items[id] = CartItem(product: product, quantity: newQty);
    notifyListeners();
    _persist();
  }

  void setQuantity(int productId, int quantity, {int? stock}) {
    final it = _items[productId];
    if (it == null) return;
    int q = quantity;
    if (stock != null) q = q.clamp(1, stock);
    if (q <= 0) {
      _items.remove(productId);
    } else {
      it.quantity = q;
    }
    notifyListeners();
    _persist();
  }

  void increment(int productId, {int? stock}) {
    final it = _items[productId];
    if (it == null) return;
    setQuantity(productId, it.quantity + 1, stock: stock);
  }

  void decrement(int productId) {
    final it = _items[productId];
    if (it == null) return;
    setQuantity(productId, it.quantity - 1);
  }

  void remove(int productId) {
    _items.remove(productId);
    notifyListeners();
    _persist();
  }

  void clear() {
    _items.clear();
    notifyListeners();
    _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _items.values
          .map((e) => {
                'product': e.product,
                'quantity': e.quantity,
              })
          .toList();
      await prefs.setString(_storageKey, jsonEncode(data));
    } catch (_) {}
  }

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null) return;
      final List list = jsonDecode(raw) as List;
      _items.clear();
      for (final it in list) {
        final map = it as Map<String, dynamic>;
        final product = Map<String, dynamic>.from(map['product'] as Map);
        final qty = (map['quantity'] as num).toInt();
        final dynamic raw = product['id'];
        final int id = raw is int
            ? raw
            : raw is num
                ? raw.toInt()
                : raw is String
                    ? (int.tryParse(raw) ?? product.hashCode)
                    : product.hashCode;
        _items[id] = CartItem(product: product, quantity: qty);
      }
      notifyListeners();
    } catch (_) {}
  }
}
