package com.example.ripasso_compose.presentation.home

import android.annotation.SuppressLint
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ShoppingCart
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavController
import coil3.compose.AsyncImage
import com.example.ripasso_compose.R


@SuppressLint("UnusedMaterial3ScaffoldPaddingParameter")
@Composable
fun ProductListScreen(
    homeViewModel: HomeViewModel = hiltViewModel(),
    navController: NavController
) {
    val uiState   by homeViewModel.products.collectAsState()

    Scaffold (Modifier.safeContentPadding()){
        Column {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = stringResource(R.string.list_title),
                    style = MaterialTheme.typography.titleMedium
                )

                Button(onClick = { navController.navigate("cart") }) {
                    Icon(
                        imageVector = Icons.Filled.ShoppingCart,
                        contentDescription = "Carrello"
                    )
                }

            }

            Box(Modifier.padding(10.dp)) {
                when (val state = uiState) {
                    ListUiState.Loading ->
                        Text("Caricamento prodotti…")

                    is ListUiState.Error ->
                        Text("Errore: ${state.message}")

                    is ListUiState.Success ->
                        LazyColumn(
                            contentPadding = PaddingValues(vertical = 10.dp),
                        ) {
                            items(state.products, key = { it.id }) { product ->
                                Card(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .padding(vertical = 8.dp)
                                        .clickable(onClick = { navController.navigate("details/${product.id}") }),
                                    elevation = CardDefaults.cardElevation(4.dp)
                                ) {

                                    Row(modifier = Modifier.padding(16.dp), horizontalArrangement = Arrangement.SpaceBetween) {
                                        val imageUrl = product.images?.firstOrNull()
                                        AsyncImage(
                                            model = imageUrl ?: R.drawable.ic_launcher_foreground,
                                            contentDescription = "immagine del prodotto",
                                            modifier = Modifier
                                                .width(100.dp)
                                                .height(100.dp),
                                            contentScale = ContentScale.Crop
                                        )

                                        Column {
                                            Text(text = product.title)
                                            Spacer(Modifier.height(20.dp))
                                            Text(text = "Price: $${product.price}")
                                        }
                                    }
                                }
                            }
                        }
                }
            }
        }
    }
}




