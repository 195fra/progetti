package com.example.ripasso_compose.presentation.cart

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.navigation.NavController
import coil3.compose.AsyncImage
import com.example.ripasso_compose.data.models.CartItem

@Composable
fun CartScreen(
    navController: NavController,
    cartViewmodel: CartViewmodel = hiltViewModel()
) {
    val uiState by cartViewmodel.cartProducts.collectAsState()

    // Dialog di conferma ordine
    var showConfirmDialog by remember { mutableStateOf(false) }
    // Dialog svuota carrello
    var showClearDialog   by remember { mutableStateOf(false) }
    // Dialog ordine confermato
    var showSuccessDialog by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            @OptIn(ExperimentalMaterial3Api::class)
            TopAppBar(
                title = { Text("Il mio carrello") },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Indietro")
                    }
                }
            )
        }
    ) { paddingValues ->

        Box(modifier = Modifier.padding(paddingValues)) {

            when (val state = uiState) {

                // ── Loading ──────────────────────────────────────────
                CartUiState.Loading -> {
                    Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                        CircularProgressIndicator()
                    }
                }

                // ── Errore ───────────────────────────────────────────
                is CartUiState.Error -> {
                    Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                        Text("Errore: ${state.message}", color = MaterialTheme.colorScheme.error)
                    }
                }

                // ── Carrello vuoto ────────────────────────────────────
                CartUiState.Empty -> {
                    Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Text("🛒", fontSize = 64.sp)
                            Spacer(Modifier.height(16.dp))
                            Text("Il carrello è vuoto",
                                fontSize = 20.sp, fontWeight = FontWeight.Bold)
                            Spacer(Modifier.height(8.dp))
                            Text("Aggiungi prodotti dal catalogo",
                                color = MaterialTheme.colorScheme.onSurfaceVariant)
                            Spacer(Modifier.height(24.dp))
                            Button(onClick = { navController.navigate("product_list") {
                                popUpTo("product_list") { inclusive = true }
                            }}) {
                                Text("Torna al catalogo")
                            }
                        }
                    }
                }

                // ── Successo: lista prodotti nel carrello ─────────────
                is CartUiState.Success -> {
                    Column(Modifier.fillMaxSize()) {

                        // Lista prodotti
                        LazyColumn(
                            modifier = Modifier.weight(1f),
                            contentPadding = PaddingValues(10.dp)
                        ) {
                            items(state.items, key = { it.product.id }) { item ->
                                CartItemCard(
                                    item           = item,
                                    onRemove       = { cartViewmodel.removeFromCart(item.product.id.toInt()) },
                                    onIncrement    = { cartViewmodel.updateQuantity(item.product.id.toInt(), item.quantity + 1) },
                                    onDecrement    = { cartViewmodel.updateQuantity(item.product.id.toInt(), item.quantity - 1) },
                                )
                            }

                            // ── Riepilogo ──────────────────────────
                            item {
                                Spacer(Modifier.height(8.dp))
                                Card(
                                    modifier  = Modifier.fillMaxWidth(),
                                    elevation = CardDefaults.cardElevation(2.dp)
                                ) {
                                    Column(Modifier.padding(16.dp)) {
                                        Row(
                                            Modifier.fillMaxWidth(),
                                            horizontalArrangement = Arrangement.SpaceBetween
                                        ) {
                                            Text("Numero totale prodotti",
                                                color = MaterialTheme.colorScheme.onSurfaceVariant)
                                            Text("${state.totalItems}",
                                                fontWeight = FontWeight.Bold)
                                        }
                                        Spacer(Modifier.height(8.dp))
                                        HorizontalDivider()
                                        Spacer(Modifier.height(8.dp))
                                        Row(
                                            Modifier.fillMaxWidth(),
                                            horizontalArrangement = Arrangement.SpaceBetween,
                                            verticalAlignment = Alignment.CenterVertically
                                        ) {
                                            Text("Totale complessivo",
                                                fontWeight = FontWeight.SemiBold)
                                            Text(
                                                "€ ${state.totalPrice}",
                                                fontSize = 20.sp,
                                                fontWeight = FontWeight.ExtraBold,
                                                color = MaterialTheme.colorScheme.primary
                                            )
                                        }
                                    }
                                }
                            }
                        }

                        // ── Footer pulsanti ────────────────────────────
                        HorizontalDivider()
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(horizontal = 16.dp, vertical = 12.dp),
                            verticalArrangement = Arrangement.spacedBy(10.dp)
                        ) {
                            // Conferma ordine
                            Button(
                                onClick = { showConfirmDialog = true },
                                modifier = Modifier.fillMaxWidth(),
                                shape    = RoundedCornerShape(50)
                            ) {
                                Icon(Icons.Default.Add, contentDescription = null)
                                Spacer(Modifier.width(8.dp))
                                Text("Conferma ordine", fontSize = 16.sp)
                            }

                            // Svuota carrello
                            OutlinedButton(
                                onClick  = { showClearDialog = true },
                                modifier = Modifier.fillMaxWidth(),
                                shape    = RoundedCornerShape(50)
                            ) {
                                Icon(Icons.Default.Delete, contentDescription = null)
                                Spacer(Modifier.width(8.dp))
                                Text("Svuota carrello", fontSize = 15.sp)
                            }
                        }
                    }
                }
            }
        }
    }

    // ── Dialog: Conferma ordine ──────────────────────────────────────
    if (showConfirmDialog) {
        val state = uiState as? CartUiState.Success
        AlertDialog(
            onDismissRequest = { showConfirmDialog = false },
            title   = { Text("Conferma ordine") },
            text    = {
                Text("Confermi l'ordine di ${state?.totalItems} prodotti " +
                     "per € ${state?.totalPrice ?: 0.0}?")
            },
            confirmButton = {
                Button(onClick = {
                    cartViewmodel.confirmOrder()
                    showConfirmDialog = false
                    showSuccessDialog = true
                }) { Text("Conferma") }
            },
            dismissButton = {
                OutlinedButton(onClick = { showConfirmDialog = false }) { Text("Annulla") }
            }
        )
    }

    // ── Dialog: Svuota carrello ──────────────────────────────────────
    if (showClearDialog) {
        AlertDialog(
            onDismissRequest = { showClearDialog = false },
            title   = { Text("Svuota carrello") },
            text    = { Text("Vuoi rimuovere tutti i prodotti?") },
            confirmButton = {
                TextButton(onClick = {
                    cartViewmodel.clearCart()
                    showClearDialog = false
                }) { Text("Svuota", color = MaterialTheme.colorScheme.error) }
            },
            dismissButton = {
                OutlinedButton(onClick = { showClearDialog = false }) { Text("Annulla") }
            }
        )
    }

    // ── Dialog: Ordine confermato ────────────────────────────────────
    if (showSuccessDialog) {
        AlertDialog(
            onDismissRequest = {},
            title   = { Text("Ordine confermato! ✅") },
            text    = { Text("Grazie per il tuo acquisto.") },
            confirmButton = {
                Button(onClick = {
                    showSuccessDialog = false
                    navController.navigate("product_list") {
                        popUpTo("product_list") { inclusive = true }
                    }
                }) { Text("OK") }
            }
        )
    }
}

// ── Card singolo prodotto nel carrello ────────────────────────────────────────
@Composable
private fun CartItemCard(
    item        : CartItem,
    onRemove    : () -> Unit,
    onIncrement : () -> Unit,
    onDecrement : () -> Unit,
) {
    Card(
        modifier  = Modifier
            .fillMaxWidth()
            .padding(vertical = 5.dp),
        elevation = CardDefaults.cardElevation(2.dp)
    ) {
        Row(
            modifier = Modifier.padding(10.dp),
            verticalAlignment = Alignment.Top
        ) {
            // Immagine
            AsyncImage(
                model              = item.product.images.firstOrNull(),
                contentDescription = item.product.title,
                contentScale       = ContentScale.Crop,
                modifier           = Modifier
                    .size(80.dp)
                    .padding(end = 12.dp)
            )

            // Info + stepper
            Column(modifier = Modifier.weight(1f)) {

                // Titolo + pulsante elimina
                Row(verticalAlignment = Alignment.Top) {
                    Text(
                        item.product.title,
                        modifier       = Modifier.weight(1f),
                        fontWeight     = FontWeight.Bold,
                        fontSize       = 14.sp,
                        maxLines       = 2
                    )
                    IconButton(onClick = onRemove, modifier = Modifier.size(28.dp)) {
                        Icon(
                            Icons.Default.Delete,
                            contentDescription = "Rimuovi",
                            tint = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }

                Text(
                    "€ ${item.product.price}",
                    fontSize   = 13.sp,
                    fontWeight = FontWeight.Bold,
                    color      = MaterialTheme.colorScheme.primary
                )

                Spacer(Modifier.height(8.dp))

                // Quantità + Subtotale
                Row(
                    Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment     = Alignment.Bottom
                ) {
                    // Stepper
                    Column {
                        Text("Quantità",
                            fontSize = 11.sp,
                            color    = MaterialTheme.colorScheme.onSurfaceVariant)
                        Spacer(Modifier.height(4.dp))
                        Surface(
                            shape = RoundedCornerShape(50),
                            color = MaterialTheme.colorScheme.surfaceVariant
                        ) {
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                IconButton(
                                    onClick  = onDecrement,
                                    modifier = Modifier.size(32.dp)
                                ) {
                                    Icon(Icons.Default.Delete, null,
                                        modifier = Modifier.size(16.dp))
                                }
                                Text(
                                    "${item.quantity}",
                                    fontSize   = 15.sp,
                                    fontWeight = FontWeight.ExtraBold,
                                    modifier   = Modifier.width(26.dp),
                                )
                                IconButton(
                                    onClick  = onIncrement,
                                    modifier = Modifier.size(32.dp)
                                ) {
                                    Icon(Icons.Default.Add, null,
                                        modifier = Modifier.size(16.dp))
                                }
                            }
                        }
                    }

                    // Subtotale
                    Column(horizontalAlignment = Alignment.End) {
                        Text("Subtotale",
                            fontSize = 11.sp,
                            color    = MaterialTheme.colorScheme.onSurfaceVariant)
                        Spacer(Modifier.height(4.dp))
                        Text(
                            "€ ${item.subtotal}",
                            fontSize   = 14.sp,
                            fontWeight = FontWeight.ExtraBold,
                            color      = MaterialTheme.colorScheme.primary
                        )
                    }
                }
            }
        }
    }
}
