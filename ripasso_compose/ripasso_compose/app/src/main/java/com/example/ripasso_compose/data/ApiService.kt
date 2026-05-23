package com.example.ripasso_compose.data

import com.example.ripasso_compose.data.models.Product
import retrofit2.http.GET
import retrofit2.http.Path

interface ApiService {
    @GET("products/")
    suspend fun getProducts(): List<Product>

    @GET("products/{id}")
    suspend fun getProductById( @Path("id") id: Int): Product
}
