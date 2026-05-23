package com.example.ripasso_compose.data.repositoryImpl

import com.example.ripasso_compose.data.ApiService
import com.example.ripasso_compose.data.ProductDatasource
import com.example.ripasso_compose.data.models.Product
import com.example.ripasso_compose.domain.repositories.ProductRepository
import javax.inject.Inject

class ProductRepositoryImpl @Inject constructor(
    private val apiService: ApiService
) : ProductRepository{

    override suspend fun getProductList(): List<Product>{
        val response = apiService.getProducts()
        return response
    }

    override suspend fun getProductById(id: Int): Product {
        val response = apiService.getProductById(id)
        return response
    }

}