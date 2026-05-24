import Foundation

// ─── ProductListViewModel ─────────────────────────────────
// Equivalente a HomeViewModel.kt in Android
// @MainActor garantisce che gli aggiornamenti UI avvengano sul main thread

@MainActor
class ProductListViewModel: ObservableObject {

    // @Published = come MutableStateFlow<ListUiState>
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    // Equivalente a fetchProducts() nel HomeViewModel
    func fetchProducts() async {
        isLoading = true
        errorMessage = nil
        do {
            products = try await ApiService.shared.getProducts()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
