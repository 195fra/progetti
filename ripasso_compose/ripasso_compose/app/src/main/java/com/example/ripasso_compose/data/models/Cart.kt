package com.example.ripasso_compose.data.models

// CartItem: tiene il prodotto + la quantità
// Prima usavi Set<Product> che non supportava più unità dello stesso prodotto
data class CartItem(
    val product: Product,
    var quantity: Int = 1
) {
    val subtotal: Double get() = product.price * quantity.toDouble()
}

data class Cart(
    val items: MutableList<CartItem> = mutableListOf(),
) {
    val totalPrice: Double get() = items.sumOf { it.subtotal }
    val totalItems: Int     get() = items.sumOf { it.quantity }
}
