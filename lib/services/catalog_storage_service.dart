import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/catalog_item.dart';

class CatalogStorageService {
  static const String _catalogKey = 'catalog_items';

  /// Save catalog items to SharedPreferences
  static Future<void> saveCatalog(List<CatalogItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = items.map((item) => item.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await prefs.setString(_catalogKey, jsonString);
  }

  /// Load catalog items from SharedPreferences
  static Future<List<CatalogItem>> loadCatalog() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_catalogKey);
    
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((json) => CatalogItem.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // If there's an error parsing, return empty list
      return [];
    }
  }

  /// Clear all catalog items
  static Future<void> clearCatalog() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_catalogKey);
  }

  /// Search catalog items by description (case-insensitive)
  static List<CatalogItem> searchCatalog(
    List<CatalogItem> items,
    String query,
  ) {
    if (query.isEmpty) {
      return items;
    }

    final lowerQuery = query.toLowerCase();
    return items.where((item) {
      return item.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Filter catalog items by price range
  static List<CatalogItem> filterByPriceRange(
    List<CatalogItem> items, {
    double? minPrice,
    double? maxPrice,
  }) {
    return items.where((item) {
      if (minPrice != null && item.unitPrice < minPrice) return false;
      if (maxPrice != null && item.unitPrice > maxPrice) return false;
      return true;
    }).toList();
  }

  /// Sort catalog items
  static List<CatalogItem> sortCatalog(
    List<CatalogItem> items, {
    required SortOption sortBy,
    bool ascending = true,
  }) {
    final sorted = List<CatalogItem>.from(items);
    
    switch (sortBy) {
      case SortOption.description:
        sorted.sort((a, b) => ascending
            ? a.description.compareTo(b.description)
            : b.description.compareTo(a.description));
        break;
      case SortOption.price:
        sorted.sort((a, b) => ascending
            ? a.unitPrice.compareTo(b.unitPrice)
            : b.unitPrice.compareTo(a.unitPrice));
        break;
    }
    
    return sorted;
  }
}

enum SortOption {
  description,
  price,
}
