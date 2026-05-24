import Foundation

// ─── Modelli dati ─────────────────────────────────────────
// Equivalente a Product.kt, Category.kt, Cart.kt in Android

struct Category: Codable, Identifiable {
    let id: Int
    let name: String
}

struct Product: Codable, Identifiable {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let category: Category
    let images: [String]

    // La Platzi API a volte restituisce le immagini come '["url"]'
    var firstImage: String {
        guard let raw = images.first else { return "" }
        if raw.hasPrefix("[") {
            return raw
                .replacingOccurrences(of: "[", with: "")
                .replacingOccurrences(of: "]", with: "")
                .replacingOccurrences(of: "\"", with: "")
                .components(separatedBy: ",")
                .first?
                .trimmingCharacters(in: .whitespaces) ?? ""
        }
        return raw
    }
}

// CartItem: prodotto + quantità
// Equivalente a CartItem.kt in Android
class CartItem: ObservableObject, Identifiable {
    let id = UUID()
    let product: Product
    @Published var quantity: Int

    init(product: Product, quantity: Int = 1) {
        self.product = product
        self.quantity = quantity
    }

    var subtotal: Double { product.price * Double(quantity) }
}
