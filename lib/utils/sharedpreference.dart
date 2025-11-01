import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/holding_model.dart';

class StorageService {
  static const _key = 'portfolio';

  static Future<void> savePortfolio(List<Holding> portfolio) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = portfolio.map((h) => h.toJson()).toList();
    prefs.setString(_key, jsonEncode(jsonData));
  }

  static Future<List<Holding>> loadPortfolio() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return [];
    final List data = jsonDecode(jsonStr);
    return data.map((e) => Holding.fromJson(e)).toList();
  }
}