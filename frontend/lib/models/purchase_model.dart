class PurchaseModel {
  final int id;
  final String userId;
  final int itemId;
  final double money;
  final String itemType;
  final DateTime purchaseDate;

  PurchaseModel({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.money,
    required this.itemType,
    required this.purchaseDate,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    return PurchaseModel(
      id: json['PurchaseID'] ?? json['purchaseId'] ?? 0,
      userId: json['UserID'] ?? json['userId'] ?? '',
      itemId: json['ItemID'] ?? json['itemId'] ?? 0,
      money: (json['Money'] ?? json['money'] ?? 0).toDouble(),
      itemType: json['ItemType'] ?? json['itemType'] ?? '',
      purchaseDate: json['CreatedAt'] != null
          ? DateTime.parse(json['CreatedAt'])
          : DateTime.now(),
    );
  }
}

class InventoryItemModel {
  final int id;
  final String userId;
  final int itemId;
  final String itemType;
  final String? itemName;
  final String? itemImageUrl;

  InventoryItemModel({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.itemType,
    this.itemName,
    this.itemImageUrl,
  });

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) {
    return InventoryItemModel(
      id: json['InventoryID'] ?? json['inventoryId'] ?? 0,
      userId: json['UserID'] ?? json['userId'] ?? '',
      itemId: json['ItemID'] ?? json['itemId'] ?? 0,
      itemType: json['ItemType'] ?? json['itemType'] ?? '',
      itemName: json['itemName'],
      itemImageUrl: json['itemImageUrl'],
    );
  }
}
