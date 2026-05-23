package com.example.ripasso_compose.presentation.productDetail

import android.annotation.SuppressLint
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavController
import coil3.compose.AsyncImage

@SuppressLint("UnusedMaterial3ScaffoldPaddingParameter")
@Composable
fun ProductDetailScreen(
    productId   : Int,
    navController: NavController,
    viewModel   : ProductDetailViewmodel = hiltViewModel(),
) {
    val uiState     by viewModel.uiState.collectAsState()
    val addedToCart by viewModel.addedToCart.collectAsState()

    LaunchedEffect(productId) {
        viewModel.fetchProductDetails(productId)
    }

    // Dialog feedback "aggiunto al carrello"
    if (addedToCart) {
        AlertDialog(
            onDismissRequest = { viewModel.resetAddedToCart() },
            title   = { Text("Aggiunto al carrello ✅") },
            text    = {
                val product = (uiState as? DetailUiState.Success)?.product
                Text("${product?.title ?: ""} è stato aggiunto al carrello.")
            },
            confirmButton = {
                Button(onClick = {
                    viewModel.resetAddedToCart()
                    navController.navigate("cart")
                }) { Text("Vai al carrello") }
            },
            dismissButton = {
                OutlinedButton(onClick = { viewModel.resetAddedToCart() }) {
                    Text("Continua")
                }
            }
        )
    }

    when (val state = uiState) {
        is DetailUiState.Loading -> CircularProgressIndicator()
        is DetailUiState.Error   -> Text(state.message)
        is DetailUiState.Success -> Scaffold(modifier = Modifier.safeContentPadding()) {
            Column(Modifier.fillMaxSize()) {

                // Pulsante indietro
                IconButton(onClick = { navController.popBackStack() }) {
                    Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Indietro")
                }

                // Contenuto scrollabile
                Column(
                    modifier = Modifier
                        .weight(1f)
                        .verticalScroll(rememberScrollState()),
                ) {
                    AsyncImage(
                        model              = state.product.images.firstOrNull(),
                        contentDescription = state.product.title,
                        contentScale       = ContentScale.Fit,
                        modifier           = Modifier
                            .fillMaxWidth()
                            .aspectRatio(1.3f)
                            .padding(16.dp)
                            .clip(RoundedCornerShape(24.dp)),
                    )
                    Column(
                        modifier = Modifier.padding(horizontal = 20.dp, vertical = 4.dp),
                        verticalArrangement = Arrangement.spacedBy(10.dp),
                    ) {
                        Text(state.product.title,
                            fontSize = 24.sp, fontWeight = FontWeight.ExtraBold)

                        Surface(shape = RoundedCornerShape(50)) {
                            Text(
                                state.product.category.name,
                                modifier   = Modifier.padding(horizontal = 14.dp, vertical = 5.dp),
                                fontSize   = 13.sp,
                                fontWeight = FontWeight.SemiBold
                            )
                        }

                        Text("€ ${state.product.price}",
                            fontSize = 28.sp, fontWeight = FontWeight.ExtraBold,
                            color = MaterialTheme.colorScheme.primary)

                        Text("DESCRIZIONE",
                            fontSize = 12.sp, fontWeight = FontWeight.Bold,
                            letterSpacing = 0.8.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant)

                        Text(state.product.description,
                            fontSize = 15.sp, lineHeight = 23.sp)

                        Spacer(Modifier.height(8.dp))
                    }
                }

                // Pulsante fisso in fondo
                HorizontalDivider()
                Button(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 16.dp, vertical = 12.dp),
                    shape    = RoundedCornerShape(50),
                    onClick  = { viewModel.addToCart(state.product) }
                ) {
                    Text("🛒  Aggiungi al carrello", fontSize = 16.sp)
                }
            }
        }
    }
}
