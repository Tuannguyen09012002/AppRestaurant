class Order {
  final String id;
  final String tableNumber;
  final String itemName;
  final int itemCount;
  final double itemPrice;
  final String? paymentDate;
  final String paymentStatus;
  final String status;
  bool selected;

  Order({
    required this.id,
    required this.tableNumber,
    required this.itemName,
    required this.itemCount,
    required this.itemPrice,
    this.paymentDate,
    required this.paymentStatus,
    required this.status,
    this.selected = true,
  });


  factory Order.fromMap(String id, Map<dynamic, dynamic> map) {
    return Order(
      id: id, // Sử dụng ID từ Firebase
      tableNumber: map['tableNumber'] ?? '',
      itemName: map['itemName'] ?? '',
      itemCount: map['itemCount'] ?? 0,
      itemPrice: (map['itemPrice'] ?? 0).toDouble(),
      paymentDate: map['paymentDate'],
      paymentStatus: map['paymentStatus'] ?? '',
      status: map['status'] ?? '',
      selected: map['selected'] ?? true,
    );
  }


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tableNumber': tableNumber,
      'itemName': itemName,
      'itemCount': itemCount,
      'itemPrice': itemPrice,
      'paymentDate': paymentDate,
      'paymentStatus': paymentStatus,
      'status': status,
      'selected': selected,
    };
  }
}
