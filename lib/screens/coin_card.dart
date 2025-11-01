import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../model/holding_model.dart';

class CoinCard extends StatelessWidget {
  final Holding holding;
  const CoinCard({super.key, required this.holding});

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat.simpleCurrency(name: 'USD', decimalDigits: 2);
    final price = holding.currentPrice ?? 0.0;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text('${holding.name} (${holding.symbol.toUpperCase()})', style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('Qty: ${holding.quantity}'),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(f.format(price), style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 6),
            Text('Total ${f.format(holding.totalValue)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}