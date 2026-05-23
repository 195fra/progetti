package com.example.ripasso_compose.data

import com.example.ripasso_compose.data.models.Product
import javax.inject.Inject

class ProductDatasource @Inject constructor(
    private val apiService: ApiService
) {

    suspend fun getProducts(): List<Product> {
        return apiService.getProducts()
    }

    suspend fun getProductsById(id: Int): Product {
        return apiService.getProductById(id)
    }
}