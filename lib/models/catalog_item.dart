class CatalogItem {
  String description;
  double unitPrice;

  CatalogItem({
    required this.description,
    required this.unitPrice,
  });

  Map<String, dynamic> toJson() => {
        'description': description,
        'unitPrice': unitPrice,
      };

  factory CatalogItem.fromJson(Map<String, dynamic> json) => CatalogItem(
        description: json['description'] as String,
        unitPrice: json['unitPrice'] as double,
      );
}
