// ═══════════════════════════════════════════════════════
//  presentation/screens/cart_screen.dart
//  Equivalente a CartScreen.kt
//
//  In Android usavi:
//    val uiState by cartViewmodel.cartProducts.collectAsState()
//    when (val state = uiState) {
//      CartUiState.Loading -> ...
//      CartUiState.Empty   -> ...
//      is CartUiState.Success -> LazyColumn { items(state.products) }
//    }
//
//  In Flutter:
//    final cartState = ref.watch(cartProvider)
//    if (cartState.items.isEmpty) → mostra vuoto
//    else → mostra lista
//    Non serve il when() perché CartState non è sealed —
//    è sempre disponibile (come il tuo Cart @Singleton).
// ═══════════════════════════════════════════════════════

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/product.dart';
import '../../providers.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ref.watch(cartProvider) = val uiState by cartViewmodel.cartProducts.collectAsState()
    // Ogni volta che aggiungi/rimuovi un prodotto, Flutter ridisegna automaticamente
    final cartState = ref.watch(cartProvider);

    // ref.read() per eseguire azioni (non osserva i cambiamenti)
    final cartNotifier = ref.read(cartProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Il mio carrello'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: cartState.items.isEmpty

          // ── Carrello vuoto ────────────────────────────────
          // Equivalente al tuo CartUiState.Empty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🛒', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  const Text('Il carrello è vuoto',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Aggiungi prodotti dal catalogo',
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Torna al catalogo'),
                  ),
                ],
              ),
            )

          // ── Lista prodotti nel carrello ───────────────────
          // Equivalente al tuo is CartUiState.Success -> LazyColumn
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: cartState.items.length,
                    itemBuilder: (_, index) {
                      final item = cartState.items[index];
                      return _CartItemCard(
                        item: item,
                        // ref.read().removeFromCart() = tuo cartViewmodel.remove()
                        onRemove: () =>
                            cartNotifier.removeFromCart(item.product.id),
                        onUpdateQuantity: (q) =>
                            cartNotifier.updateQuantity(item.product.id, q),
                      );
                    },
                  ),
                ),

                // ── Riepilogo totale ──────────────────────────
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(children: [
                        const Text('🛍️', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text('Numero totale prodotti',
                              style: TextStyle(color: Colors.grey)),
                        ),
                        Text('${cartState.totalItems}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ]),
                      const Divider(height: 20),
                      Row(children: [
                        const Text('💳', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text('Totale complessivo',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        Text(
                          '€ ${cartState.totalPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),

                // ── Pulsanti footer ─────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  child: Column(
                    children: [
                      // Conferma ordine
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _confirmOrder(context, ref),
                          icon: const Icon(
                              Icons.shopping_cart_checkout_outlined),
                          label: const Text('Conferma ordine',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            shape: const StadiumBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Svuota carrello
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _clearCart(context, ref),
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Svuota carrello',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            padding:
                                const EdgeInsets.symmetric(vertical: 15),
                            shape: const StadiumBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _confirmOrder(BuildContext context, WidgetRef ref) {
    final cartState = ref.read(cartProvider);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Conferma ordine'),
        content: Text(
          'Confermi l\'ordine di ${cartState.totalItems} prodotti '
          'per € ${cartState.totalPrice.toStringAsFixed(2)}?',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annulla')),
          ElevatedButton(
            onPressed: () {
              // ref.read().clearCart() = cartViewmodel.clear() nel tuo Android
              ref.read(cartProvider.notifier).clearCart();
              Navigator.pop(context);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => AlertDialog(
                  title: const Text('Ordine confermato! ✅'),
                  content: const Text('Grazie per il tuo acquisto.'),
                  actions: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Conferma'),
          ),
        ],
      ),
    );
  }

  void _clearCart(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Svuota carrello'),
        content: const Text('Rimuovi tutti i prodotti?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annulla')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              ref.read(cartProvider.notifier).clearCart();
              Navigator.pop(context);
            },
            child: const Text('Svuota'),
          ),
        ],
      ),
    );
  }
}

// ── Card prodotto nel carrello ────────────────────────────
class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.item,
    required this.onRemove,
    required this.onUpdateQuantity,
  });

  final CartItem item;
  final VoidCallback onRemove;
  final void Function(int) onUpdateQuantity;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Immagine
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedNetworkImage(
                imageUrl: item.product.firstImage,
                width: 80,
                height: 100,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  width: 80,
                  height: 100,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
            // Body
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Titolo + elimina
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.product.title,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          onPressed: onRemove,
                          icon: const Icon(Icons.delete_outline,
                              size: 20, color: Colors.grey),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    Text(
                      '€ ${item.product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    // Quantità + Subtotale
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Stepper
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Quantità',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Row(children: [
                                GestureDetector(
                                  onTap: () =>
                                      onUpdateQuantity(item.quantity - 1),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    child: Icon(Icons.remove,
                                        size: 18, color: Colors.indigo),
                                  ),
                                ),
                                Text('${item.quantity}',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold)),
                                GestureDetector(
                                  onTap: () =>
                                      onUpdateQuantity(item.quantity + 1),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    child: Icon(Icons.add,
                                        size: 18, color: Colors.indigo),
                                  ),
                                ),
                              ]),
                            ),
                          ],
                        ),
                        // Subtotale
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Subtotale',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Text(
                              '€ ${item.subtotal.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
