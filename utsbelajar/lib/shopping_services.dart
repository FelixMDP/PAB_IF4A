import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class Shopingservice {
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref().child('shopping_list');
  Stream<Map<String, String>> getShoppingList() {
    return _database.onValue.map((event) {
      final Map<String, String> items = {};
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null) {
        Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
        values.forEach((key, value) {
          items[key] = value['name'] as String;
        });
      }
      return items;
    });
  }

  void addItem(String name) {
    _database.push().set({'name': name});
  }

  Future<void> removeItem(String key) async {
    await _database.child(key).remove();
  }
}
