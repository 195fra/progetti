package com.example.ripasso_compose.presentation.cart

import androidx.lifecycle.ViewModel
import com.example.ripasso_compose.data.models.Cart
import com.example.ripasso_compose.data.models.CartItem
import com.example.ripasso_compose.data.models.Product
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import javax.inject.Inject

sealed interface CartUiState {
    data object Loading : CartUiState
    data object Empty   : CartUiState
    data class  Success(val items: List<CartItem>, val totalPrice: Double, val totalItems: Int) : CartUiState
    data class  Error(val message: String) : CartUiState
}

@HiltViewModel
class CartViewmodel @Inject constructor(
    private val cart: Cart
) : ViewModel() {

    private val _uiState = MutableStateFlow<CartUiState>(CartUiState.Loading)
    val cartProducts: StateFlow<CartUiState> = _uiState.asStateFlow()

    init { refresh() }

    // Chiamato dal ProductDetailScreen dopo addToCart()
    fun refresh() {
        _uiState.value = if (cart.items.isEmpty()) {
            CartUiState.Empty
        } else {
            CartUiState.Success(
                items      = cart.items.toList(),
                totalPrice = cart.totalPrice,
                totalItems = cart.totalItems
            )
        }
    }

    // Aggiunge al carrello — se già presente incrementa la quantità
    fun addToCart(product: Product) {
        val existing = cart.items.find { it.product.id == product.id }
        if (existing != null) {
            existing.quantity++
        } else {
            cart.items.add(CartItem(product = product, quantity = 1))
        }
        refresh()
    }

    // Rimuove completamente un prodotto dal carrello
    fun removeFromCart(productId: Int) {
        cart.items.removeAll { it.product.id.toInt() == productId }
        refresh()
    }

    // Aggiorna la quantità — se quantity <= 0 rimuove il prodotto
    fun updateQuantity(productId: Int, quantity: Int) {
        if (quantity <= 0) {
            removeFromCart(productId)
            return
        }
        cart.items.find { it.product.id.toInt() == productId }?.quantity = quantity
        refresh()
    }

    // Svuota tutto il carrello
    fun clearCart() {
        cart.items.clear()
        refresh()
    }

    // Conferma ordine: svuota e restituisce true se c'era almeno un prodotto
    fun confirmOrder(): Boolean {
        if (cart.items.isEmpty()) return false
        clearCart()
        return true
    }
}
