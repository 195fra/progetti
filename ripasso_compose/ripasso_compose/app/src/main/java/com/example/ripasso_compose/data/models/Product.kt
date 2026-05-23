package com.example.ripasso_compose.data.models

data class Product (
    val id: String,
    val title: String,
    val price: Int,
    val description: String,
    val category: Category,
    val images: List<String>,
    var inCart: Int = 0
)


