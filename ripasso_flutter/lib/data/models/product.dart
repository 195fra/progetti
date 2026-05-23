// ═══════════════════════════════════════════════════════
//  data/models/product.dart
//  Equivalente a Product.kt + Category.kt + Cart.kt
// ═══════════════════════════════════════════════════════

// ── Category ─────────────────────────────────────────────
class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
      );
}

// ── Product ───────────────────────────────────────────────
// Corrisponde esattamente alla tua Product.kt
class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final Category category;
  final List<String> images;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.images,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String? ?? '',
      category: Category.fromJson(
        json['category'] as Map<String, dynamic>? ?? {},
      ),
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  /// La Platzi API a volte restituisce le immagini come '["url"]'
  /// Stessa logica che avresti nel tuo Product.kt
  String get firstImage {
    if (images.isEmpty) return '';
    final raw = images.first;
    if (raw.startsWith('[')) {
      return raw.replaceAll(RegExp(r'[\[\]"\\]'), '').split(',').first.trim();
    }
    return raw;
  }
}

// ── CartItem ──────────────────────────────────────────────
// Equivalente al tuo Cart.kt, ma con quantità (più pratico)
class CartItem {
  final Product product;
  final int quantity;

  CartItem({required this.product, required this.quantity});

  double get subtotal => product.price * quantity;

  CartItem copyWith({int? quantity}) =>
      CartItem(product: product, quantity: quantity ?? this.quantity);
}
