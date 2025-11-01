
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/coin_model.dart';


class ApiService {
  static const _base = 'https://api.coingecko.com/api/v3';

  static Future<List<Coin>> fetchCoinsList() async {
    final uri = Uri.parse('$_base/coins/list');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => Coin.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load coins: ${res.statusCode}');
    }
  }

  static Future<Map<String, double>> fetchPrices(List<String> ids) async {
    if (ids.isEmpty) return {};
    final idsParam = ids.join(',');
    final uri = Uri.parse('$_base/simple/price?ids=$idsParam&vs_currencies=usd');
    final res = await http.get(uri);
    if (res.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(res.body);
      return data.map((k, v) => MapEntry(k, (v['usd'] as num).toDouble()));
    } else {
      throw Exception('Failed to fetch prices: ${res.statusCode}');
    }
  }
}