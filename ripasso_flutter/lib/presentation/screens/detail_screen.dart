// ═══════════════════════════════════════════════════════
//  presentation/screens/detail_screen.dart
//  Equivalente a ProductDetailScreen.kt
//
//  In Android usavi:
//    LaunchedEffect(productId) { viewModel.fetchProductDetails(productId) }
//    val uiState by viewModel.uiState.collectAsState()
//    when (val state = uiState) { Loading -> ... }
//
//  In Flutter:
//    ref.watch(productDetailProvider(productId))
//    Il FutureProvider.family chiama automaticamente getProductById(id)
//    Non serve LaunchedEffect — Riverpod lo fa da solo.
// ═══════════════════════════════════════════════════════

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/product.dart';
import '../../providers.dart';
import 'cart_screen.dart';

class DetailScreen extends ConsumerWidget {
  const DetailScreen({super.key, required this.productId});

  final int productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch(productDetailProvider(productId)) =
    //   LaunchedEffect(productId) { viewModel.fetchProductDetails(it) }
    //   + val uiState by viewModel.uiState.collectAsState()
    // Tutto in una riga!
    final asyncProduct = ref.watch(productDetailProvider(productId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dettaglio Prodotto'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // ── Gestione Loading / Error / Success ────────────────
      // Equivalente al tuo:
      //   when (val state = uiState) {
      //     is DetailUiState.Loading -> CircularProgressIndicator()
      //     is DetailUiState.Error   -> Text(state.message)
      //     is DetailUiState.Success -> { ... }
      //   }
      body: asyncProduct.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 48)),
              Text('Errore: $error'),
              ElevatedButton(
                onPressed: () => ref.refresh(productDetailProvider(productId)),
                child: const Text('Riprova'),
              ),
            ],
          ),
        ),
        data: (product) => _DetailContent(
          product: product,
          onAddToCart: () {
            // ref.read() per eseguire un'azione (non per leggere lo stato)
            // Equivalente a: viewModel.addToCart(state.product)
            ref.read(cartProvider.notifier).addToCart(product);
            _showAddedDialog(context, product);
          },
        ),
      ),
    );
  }

  void _showAddedDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Aggiunto al carrello ✅'),
        content: Text(product.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continua'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // chiude dialog
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
            child: const Text('Vai al carrello'),
          ),
        ],
      ),
    );
  }
}

// ── Contenuto del dettaglio ───────────────────────────────
// Equivalente alla parte dentro is DetailUiState.Success nel tuo Kotlin
class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.product, required this.onAddToCart});

  final Product product;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Area scrollabile
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Immagine grande
                Container(
                  margin: const EdgeInsets.all(16),
                  height: MediaQuery.of(context).size.width * 0.72,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: CachedNetworkImage(
                    imageUrl: product.firstImage,
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorWidget: (_, __, ___) => const Center(
                      child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
                    ),
                  ),
                ),

                // Info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titolo
                      Text(
                        product.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Chip categoria — equivalente alla tua Surface(shape=RoundedCornerShape(50))
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          product.category.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Prezzo
                      Text(
                        '€ ${product.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Descrizione
                      const Text(
                        'DESCRIZIONE',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product.description,
                        style: const TextStyle(
                            fontSize: 15, color: Colors.black54, height: 1.55),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Pulsante fisso in fondo — equivalente al tuo Button onClick addToCart
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onAddToCart,
              icon: const Icon(Icons.shopping_cart_outlined),
              label: const Text('Aggiungi al carrello',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: const StadiumBorder(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
