package com.example.ripasso_compose.presentation.home

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.ripasso_compose.data.models.Product
import com.example.ripasso_compose.domain.usecases.getProductsUsecase
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

interface ListUiState {
    data class Success(val products: List<Product>) : ListUiState
    data class Error(val message: String) : ListUiState
    object Loading : ListUiState
}

@HiltViewModel
class HomeViewModel @Inject constructor(
    private val usecase: getProductsUsecase

) : ViewModel(){

    private val _uiState = MutableStateFlow<ListUiState>(ListUiState.Loading)
    val products: StateFlow<ListUiState> = _uiState.asStateFlow()

    init {
        fetchProducts()
    }

    private fun fetchProducts() {
        _uiState.value = ListUiState.Loading
        viewModelScope.launch {
            _uiState.value = try {
                ListUiState.Success(usecase())
            } catch (e: Exception) {
                println("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n"+e.message)
                ListUiState.Error(e.message ?: "Errore sconosciuto")

            }
        }
    }

}
