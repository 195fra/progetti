package com.example.ripasso_compose.presentation.productDetail

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.ripasso_compose.data.models.Cart
import com.example.ripasso_compose.data.models.Product
import com.example.ripasso_compose.domain.usecases.getProductsUsecase
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

sealed interface DetailUiState {
    data object Loading : DetailUiState
    data class  Success(val product: Product) : DetailUiState
    data class  Error(val message: String)    : DetailUiState
}

@HiltViewModel
class ProductDetailViewmodel @Inject constructor(
    private val usecase : getProductsUsecase,
    private val cart    : Cart               // Cart @Singleton iniettato da Hilt
) : ViewModel() {

    private val _uiState = MutableStateFlow<DetailUiState>(DetailUiState.Loading)
    val uiState: StateFlow<DetailUiState> = _uiState.asStateFlow()

    // Stato per il feedback "aggiunto al carrello"
    private val _addedToCart = MutableStateFlow(false)
    val addedToCart: StateFlow<Boolean> = _addedToCart.asStateFlow()

    fun fetchProductDetails(productId: Int) {
        _uiState.value = DetailUiState.Loading
        viewModelScope.launch {
            _uiState.value = try {
                DetailUiState.Success(usecase(productId))
            } catch (e: Exception) {
                DetailUiState.Error(e.message ?: "Errore sconosciuto")
            }
        }
    }

    // Aggiunge al carrello — incrementa la quantità se già presente
    fun addToCart(product: Product) {
        val existing = cart.items.find { it.product.id == product.id }
        if (existing != null) {
            existing.quantity++
        } else {
            cart.items.add(
                com.example.ripasso_compose.data.models.CartItem(
                    product  = product,
                    quantity = 1
                )
            )
        }
        _addedToCart.value = true
    }

    fun resetAddedToCart() {
        _addedToCart.value = false
    }
}
