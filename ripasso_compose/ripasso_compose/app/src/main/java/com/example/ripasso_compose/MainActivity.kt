package com.example.ripasso_compose

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.example.ripasso_compose.presentation.cart.CartScreen
import com.example.ripasso_compose.presentation.home.ProductListScreen
import com.example.ripasso_compose.presentation.productDetail.ProductDetailScreen
import com.example.ripasso_compose.ui.theme.Ripasso_composeTheme
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        setContent {
            Ripasso_composeTheme {

                val navController = rememberNavController()

                NavHost(
                    navController = navController,
                    startDestination = "product_list"
                ) {

                    composable("product_list") {
                        ProductListScreen(
                            navController = navController
                        )
                    }

                    composable("details/{productId}") { backStackEntry ->
                        val productId = backStackEntry.arguments?.getString("productId")

                        if (productId != null) {
                            ProductDetailScreen(
                                productId = productId.toInt(),
                                navController = navController
                            )
                        }
                    }
                    composable("cart") {
                        CartScreen(
                            navController = navController
                        )
                    }
                }
            }
        }
    }
}