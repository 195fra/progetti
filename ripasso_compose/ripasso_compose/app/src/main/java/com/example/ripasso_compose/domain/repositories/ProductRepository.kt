package com.example.ripasso_compose.domain.repositories

import com.example.ripasso_compose.data.models.Product

interface ProductRepository {
    suspend fun getProductList(): List<Product>
    suspend fun getProductById(id: Int): Product
}