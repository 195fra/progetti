package com.example.ripasso_compose.domain.usecases

import com.example.ripasso_compose.data.models.Product
import com.example.ripasso_compose.data.repositoryImpl.ProductRepositoryImpl
import javax.inject.Inject

class getProductsUsecase @Inject constructor(
    private val repository: ProductRepositoryImpl
) {

    suspend operator fun invoke(): List<Product> = repository.getProductList()
    suspend operator fun invoke(id: Int): Product = repository.getProductById(id)
}