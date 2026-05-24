import Foundation

// ─── CartStore ────────────────────────────────────────────
// Equivalente a CartViewmodel.kt + Cart.kt in Android
// @MainActor = tutto gira sul main thread (come viewModelScope in Kotlin)
// ObservableObject = come StateFlow — le View si aggiornano automaticamente

@MainActor
class CartStore: ObservableObject {

    // Singleton — come @Singleton in Hilt
    static let shared = CartStore()

    // @Published = come MutableStateFlow — le View si ricostruiscono ad ogni cambio
    @Published var items: [CartItem] = []

    private init() {}

    var totalPrice: Double { items.reduce(0) { $0 + $1.subtotal } }
    var totalItems: Int    { items.reduce(0) { $0 + $1.quantity } }

    // Equivalente a addToCart() nel CartViewmodel
    func addToCart(_ product: Product) {
        if let existing = items.first(where: { $0.product.id == product.id }) {
            existing.quantity += 1
        } else {
            items.append(CartItem(product: product))
        }
    }

    // Equivalente a removeFromCart()
    func removeFromCart(_ productId: Int) {
        items.removeAll { $0.product.id == productId }
    }

    // Equivalente a updateQuantity()
    func updateQuantity(_ productId: Int, quantity: Int) {
        if quantity <= 0 {
            removeFromCart(productId)
            return
        }
        items.first(where: { $0.product.id == productId })?.quantity = quantity
    }

    // Equivalente a clearCart()
    func clearCart() {
        items.removeAll()
    }
}
