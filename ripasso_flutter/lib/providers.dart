// ═══════════════════════════════════════════════════════
//  providers.dart
//
//  Questo file sostituisce in Flutter:
//    • NetworkModule.kt  (crea il Dio/Retrofit)
//    • CartModule.kt     (crea il Cart singleton)
//    • HomeViewModel.kt  (ListUiState + StateFlow)
//    • ProductDetailViewmodel.kt (DetailUiState)
//    • CartViewmodel.kt  (CartUiState + StateFlow)
//
//  In Riverpod NON serve @HiltViewModel, @Inject, @Module —
//  i provider fanno tutto automaticamente.
// ═══════════════════════════════════════════════════════

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/models/product.dart';
import 'data/product_repository.dart';

// ─────────────────────────────────────────────────────────
//  1. DIO  (equivalente al tuo NetworkModule.kt)
//     In Android:  @Provides fun provideRetrofit() + provideApiService()
//     In Flutter:  un semplice Provider
// ─────────────────────────────────────────────────────────
final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    baseUrl: 'https://api.escuelajs.co/api/v1',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
});

// ─────────────────────────────────────────────────────────
//  2. REPOSITORY  (equivalente a ProductRepositoryImpl @Inject)
//     In Android: class ProductRepositoryImpl @Inject constructor(api)
//     In Flutter: Provider che riceve il Dio dal provider sopra
// ─────────────────────────────────────────────────────────
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final dio = ref.read(dioProvider);
  return ProductRepository(dio);
});

// ─────────────────────────────────────────────────────────
//  3. LISTA PRODOTTI  (equivalente a HomeViewModel.kt)
//
//     In Android:
//       sealed interface ListUiState { Loading, Success, Error }
//       class HomeViewModel : ViewModel() {
//         val products: StateFlow<ListUiState>
//         fun fetchProducts() { viewModelScope.launch { usecase() } }
//       }
//
//     In Flutter con Riverpod:
//       FutureProvider gestisce loading/error/data automaticamente —
//       non devi scrivere il when() manuale nel ViewModel.
//       Nella screen usi asyncProducts.when(loading, error, data).
// ─────────────────────────────────────────────────────────
final productsProvider = FutureProvider<List<Product>>((ref) {
  return ref.read(productRepositoryProvider).getProducts();
});

// ─────────────────────────────────────────────────────────
//  4. DETTAGLIO PRODOTTO  (equivalente a ProductDetailViewmodel.kt)
//
//     In Android:
//       class ProductDetailViewmodel @Inject constructor(usecase, cart)
//       fun fetchProductDetails(id: Int) { viewModelScope.launch { ... } }
//
//     In Flutter:
//       FutureProvider.family riceve l'id come parametro —
//       è come il tuo LaunchedEffect(productId) { viewModel.fetch(it) }
//       ma gestito automaticamente da Riverpod.
// ─────────────────────────────────────────────────────────
final productDetailProvider =
    FutureProvider.family<Product, int>((ref, id) {
  return ref.read(productRepositoryProvider).getProductById(id);
});

// ─────────────────────────────────────────────────────────
//  5. CARRELLO  (equivalente a CartViewmodel.kt + CartModule.kt)
//
//     In Android:
//       @Singleton Cart (via CartModule)
//       class CartViewmodel @Inject constructor(cart: Cart)
//       val cartProducts: StateFlow<CartUiState>
//
//     In Flutter:
//       NotifierProvider è il singleton — esiste una sola istanza
//       per tutta l'app, esattamente come il tuo Cart @Singleton.
//       CartState contiene la lista, il totale e i metodi.
// ─────────────────────────────────────────────────────────

// Stato del carrello — equivalente a Cart.kt + CartUiState
class CartState {
  const CartState({this.items = const []});

  final List<CartItem> items;

  // Equivalente a cart.totalPrice
  double get totalPrice =>
      items.fold(0.0, (sum, i) => sum + i.product.price * i.quantity);

  int get totalItems => items.fold(0, (sum, i) => sum + i.quantity);

  CartState copyWith({List<CartItem>? items}) =>
      CartState(items: items ?? this.items);
}

// CartNotifier — equivalente al tuo CartViewmodel.kt
// NotifierProvider = @HiltViewModel + @Singleton + StateFlow tutto insieme
class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() => const CartState(); // stato iniziale = carrello vuoto

  // Equivalente al tuo addToCart() nel ProductDetailViewmodel
  void addToCart(Product product) {
    final index = state.items.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      // prodotto già presente → aggiorna quantità
      final updated = [...state.items];
      updated[index] =
          updated[index].copyWith(quantity: updated[index].quantity + 1);
      state = state.copyWith(items: updated);
    } else {
      state = state.copyWith(
        items: [...state.items, CartItem(product: product, quantity: 1)],
      );
    }
  }

  void removeFromCart(int productId) {
    state = state.copyWith(
      items: state.items.where((i) => i.product.id != productId).toList(),
    );
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) { removeFromCart(productId); return; }
    state = state.copyWith(
      items: state.items
          .map((i) => i.product.id == productId
              ? i.copyWith(quantity: quantity)
              : i)
          .toList(),
    );
  }

  void clearCart() => state = const CartState();
}

// Il provider del carrello — come il @Singleton Cart in CartModule.kt
final cartProvider = NotifierProvider<CartNotifier, CartState>(
  CartNotifier.new,
);
