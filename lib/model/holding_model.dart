class Holding {
  final String coinId;
  final String name;
  final String symbol;
  double quantity;
  double? currentPrice;

  Holding({
    required this.coinId,
    required this.name,
    required this.symbol,
    required this.quantity,
    this.currentPrice,
  });

  double get totalValue => (currentPrice ?? 0) * quantity;

  Map<String, dynamic> toJson() => {
    'coinId': coinId,
    'name': name,
    'symbol': symbol,
    'quantity': quantity,
  };

  factory Holding.fromJson(Map<String, dynamic> json) => Holding(
    coinId: json['coinId'],
    name: json['name'],
    symbol: json['symbol'],
    quantity: json['quantity'],
  );
}