// ═══════════════════════════════════════════════════════
//  presentation/screens/home_screen.dart
//  Equivalente a HomeScreen.kt
//
//  In Android usavi:
//    val uiState by homeViewModel.products.collectAsState()
//    when (val state = uiState) { Loading -> ... Error -> ... Success -> ... }
//
//  In Flutter con Riverpod:
//    final asyncProducts = ref.watch(productsProvider)
//    asyncProducts.when(loading: ..., error: ..., data: ...)
//
//  ConsumerWidget = @Composable con hiltViewModel()
// ═══════════════════════════════════════════════════════

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/product.dart';
import '../../providers.dart';
import 'detail_screen.dart';
import 'cart_screen.dart';

// ── Screen principale ─────────────────────────────────────
// ConsumerWidget = Composable che può leggere i provider Riverpod
// Equivalente al tuo @Composable con hiltViewModel()

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch() = collectAsState() nel tuo Android
    // Quando productsProvider cambia stato, Flutter ridisegna automaticamente
    final asyncProducts = ref.watch(productsProvider);

    // Legge lo stato del carrello per mostrare il badge
    final cartState = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogo Prodotti'),
        actions: [
          // Pulsante carrello con badge — equivalente al tuo Button + Icon
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                ),
              ),
              if (cartState.totalItems > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${cartState.totalItems}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),

      // ── Body: gestione Loading / Error / Success ──────────
      // Equivalente al tuo:
      //   when (val state = uiState) {
      //     ListUiState.Loading -> ...
      //     is ListUiState.Error -> ...
      //     is ListUiState.Success -> ...
      //   }
      body: asyncProducts.when(
        // Equivalente a ListUiState.Loading
        loading: () => const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Caricamento prodotti…'),
            ],
          ),
        ),

        // Equivalente a ListUiState.Error
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text('Errore: $error', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                // ref.refresh() = equivalente a homeViewModel.fetchProducts()
                onPressed: () => ref.refresh(productsProvider),
                child: const Text('Riprova'),
              ),
            ],
          ),
        ),

        // Equivalente a ListUiState.Success
        data: (products) => ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: products.length,
          itemBuilder: (_, index) => _ProductCard(
            product: products[index],
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailScreen(productId: products[index].id),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Card prodotto ─────────────────────────────────────────
// Equivalente alla Card dentro il tuo LazyColumn
class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Immagine — equivalente a Coil AsyncImage
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: product.firstImage,
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey[200],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Info prodotto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.category.name.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '€ ${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
