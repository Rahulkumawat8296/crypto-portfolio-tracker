import 'package:get/get.dart';
import '../../model/coin_model.dart';
import 'dart:async';
import '../model/holding_model.dart';
import '../services/api_services.dart';
import '../utils/sharedpreference.dart';


class PortfolioController extends GetxController {
  var isLoading = true.obs;
  var isFetchingPrices = false.obs;
  var coins = <Coin>[].obs; // full coin list
  var coinIndex = <String, List<Coin>>{}.obs; // index by first char -> coins
  var portfolio = <Holding>[].obs;
  var totalValue = 0.0.obs;
  Timer? _autoRefreshTimer;

  @override
  void onInit() {
    super.onInit();
    loadInitial();
    // optional: auto refresh every 3 minutes (be mindful of API limits)
    _autoRefreshTimer = Timer.periodic(const Duration(minutes: 3), (_) {
      if (portfolio.isNotEmpty) refreshPrices();
    });
  }

  @override
  void onClose() {
    _autoRefreshTimer?.cancel();
    super.onClose();
  }

  Future<void> loadInitial() async {
    isLoading.value = true;
    try {
      // load saved portfolio first
      final saved = await StorageService.loadPortfolio();
      portfolio.assignAll(saved);

      // fetch the huge coins list (only once)
      final list = await ApiService.fetchCoinsList();
      coins.assignAll(list);

      // build a simple index by first letter (lowercase)
      final Map<String, List<Coin>> idx = {};
      for (var c in list) {
        final key = (c.name.isNotEmpty ? c.name[0].toLowerCase() : c.symbol[0].toLowerCase());
        idx.putIfAbsent(key, () => []).add(c);
      }
      coinIndex.assignAll(idx);

      // fetch prices for items in portfolio
      await refreshPrices();
    } catch (e) {
      // keep going; UI should show errors
      print('loadInitial error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Search coins by substring in name or symbol. Efficiently restrict initial candidates by first letter.
  List<Coin> searchCoins(String query, {int limit = 20}) {
    if (query.isEmpty) return [];
    final q = query.toLowerCase();
    final key = q[0];
    final candidates = coinIndex[key] ?? coins; // fallback to full list if not indexed
    final results = <Coin>[];
    for (var c in candidates) {
      if (results.length >= limit) break;
      if (c.name.toLowerCase().contains(q) || c.symbol.toLowerCase().contains(q)) {
        results.add(c);
      }
    }
    // if not enough results, expand search to entire list
    if (results.length < limit) {
      for (var c in coins) {
        if (results.length >= limit) break;
        if (results.contains(c)) continue;
        if (c.name.toLowerCase().contains(q) || c.symbol.toLowerCase().contains(q)) {
          results.add(c);
        }
      }
    }
    return results;
  }

  Future<void> refreshPrices() async {
    if (portfolio.isEmpty) {
      totalValue.value = 0;
      await StorageService.savePortfolio(portfolio);
      return;
    }
    isFetchingPrices.value = true;
    try {
      final ids = portfolio.map((e) => e.coinId).toSet().toList();
      final prices = await ApiService.fetchPrices(ids);

      for (var h in portfolio) {
        h.currentPrice = prices[h.coinId] ?? h.currentPrice ?? 0.0;
      }
      totalValue.value = portfolio.fold(0.0, (s, h) => s + h.totalValue);
      await StorageService.savePortfolio(portfolio);
    } catch (e) {
      print('refreshPrices error: $e');
      // swallow; UI will show existing values or 0
    } finally {
      isFetchingPrices.value = false;
    }
  }

  void addOrUpdateHolding(Holding holding) {
    final existing = portfolio.firstWhereOrNull((h) => h.coinId == holding.coinId);
    if (existing != null) {
      existing.quantity += holding.quantity;
      // optional: keep other fields
    } else {
      portfolio.add(holding);
    }
    refreshPrices();
  }

  void removeHolding(String coinId) {
    portfolio.removeWhere((h) => h.coinId == coinId);
    refreshPrices();
  }
}