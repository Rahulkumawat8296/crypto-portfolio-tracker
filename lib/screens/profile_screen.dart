import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../usercontroller/profile_controller.dart';
import 'add_coin.dart';
import 'coin_card.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(PortfolioController());
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.indigo.shade900,
        title: const Text('Portfolio',style: TextStyle(fontSize:
        22,fontWeight: FontWeight.w600,color: Colors.white),),

      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  Obx(() => Text(
                    NumberFormat.currency(symbol: '\$').format(ctrl.totalValue.value),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  )),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: ctrl.refreshPrices,
                child: Obx(() {
                  if (ctrl.portfolio.isEmpty) {
                    return  ListView(
                      physics: AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: 80),
                        Center(child: Text('No holdings yet — tap + to add')),
                      ],
                    );
                  }
                  return ListView.builder(
                    itemCount: ctrl.portfolio.length,
                    itemBuilder: (context, i) {
                      final h = ctrl.portfolio[i];
                      return Dismissible(
                        key: Key(h.coinId),
                        background: Container(color: Colors.red, alignment: Alignment.centerLeft, padding: const EdgeInsets.only(left: 20), child: const Icon(Icons.delete, color: Colors.white)),
                        direction: DismissDirection.startToEnd,
                        onDismissed: (_) => ctrl.removeHolding(h.coinId),
                        child: CoinCard(holding: h),
                      );
                    },
                  );
                }),
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.to(() => const AddCoinScreen()),
        child: const Icon(Icons.add),
      ),
    );
  }
}