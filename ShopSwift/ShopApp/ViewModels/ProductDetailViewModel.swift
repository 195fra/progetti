import Foundation

// ─── ProductDetailViewModel ───────────────────────────────
// Equivalente a ProductDetailViewmodel.kt in Android

@MainActor
class ProductDetailViewModel: ObservableObject {

    @Published var product: Product? = nil
    @Published var isLoading = false
    @Published var errorMessage: String? = nil

    // Equivalente a fetchProductDetails()
    func fetchProduct(id: Int) async {
        isLoading = true
        errorMessage = nil
        do {
            product = try await ApiService.shared.getProductById(id)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
