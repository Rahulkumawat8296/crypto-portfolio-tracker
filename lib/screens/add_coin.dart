import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/coin_model.dart';
import '../model/holding_model.dart';
import '../usercontroller/profile_controller.dart';

class AddCoinScreen extends StatefulWidget {
  const AddCoinScreen({super.key});

  @override
  State<AddCoinScreen> createState() => _AddCoinScreenState();
}

class _AddCoinScreenState extends State<AddCoinScreen> {
  final ctrl = Get.find<PortfolioController>();
  final searchCtrl = TextEditingController();
  final qtyCtrl = TextEditingController();

  List<Coin> suggestions = [];
  Coin? selected;

  void onSearchChanged(String q) {
    if (q.isEmpty) {
      setState(() => suggestions = []);
      return;
    }

    final res = ctrl.searchCoins(q, limit: 12);
    print('Found ${res.length} coins for "$q"'); // Debug log
    setState(() {
      suggestions = res;
    });
  }

  void onSelectCoin(Coin c) {
    print('Selected ${c.name}'); // Debug log
    setState(() {
      selected = c;
      searchCtrl.text = '${c.name} (${c.symbol.toUpperCase()})';
      suggestions = [];
    });
  }

  /// Called when the user taps on "Add to portfolio"
  void onAdd() {
    if (selected == null) {
      Get.snackbar('Validation', 'Please select a coin');
      return;
    }

    final qText = qtyCtrl.text.trim();
    if (qText.isEmpty) {
      Get.snackbar('Validation', 'Please enter quantity');
      return;
    }

    final q = double.tryParse(qText);
    if (q == null || q <= 0) {
      Get.snackbar('Validation', 'Enter a valid positive number');
      return;
    }

    final holding = Holding(
      coinId: selected!.id,
      name: selected!.name,
      symbol: selected!.symbol,
      quantity: q,
    );

    ctrl.addOrUpdateHolding(holding);
    Get.back();
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    qtyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.indigo.shade900,
        title: const Text(
          'Add Asset',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: searchCtrl,
                decoration: const InputDecoration(
                  labelText: 'Search coin by name or symbol',
                ),
                onChanged: onSearchChanged,
              ),

              // Show search suggestions
              if (suggestions.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 240),
                  child: Card(
                    elevation: 3,
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(), // ✅ fix touch issue
                      itemBuilder: (context, i) {
                        final c = suggestions[i];
                        return ListTile(
                          title: Text(c.name),
                          subtitle: Text(c.symbol.toUpperCase()),
                          onTap: () => onSelectCoin(c),
                        );
                      },
                      separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: Colors.grey),
                      itemCount: suggestions.length,
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              TextField(
                controller: qtyCtrl,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Quantity (e.g. 0.5)',
                ),
              ),

              const SizedBox(height: 18),

              GestureDetector(
                onTap: onAdd,
                child: Container(
                  alignment: Alignment.center,
                  height: 50,
                  width: Get.width,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.indigo.shade900,
                  ),
                  child: const Text(
                    "Add to portfolio",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
