import Foundation

// ─── API Service ──────────────────────────────────────────
// Equivalente a ApiService.kt (Retrofit) in Android
// In Swift si usa URLSession — nessuna libreria esterna necessaria

class ApiService {
    static let shared = ApiService()
    private let baseURL = "https://api.escuelajs.co/api/v1"

    private init() {}

    // Equivalente a getProductList() in Android
    func getProducts() async throws -> [Product] {
        let url = URL(string: "\(baseURL)/products?limit=30")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let products = try JSONDecoder().decode([Product].self, from: data)
        return products.filter { !$0.images.isEmpty && !$0.category.name.isEmpty }
    }

    // Equivalente a getProductById() in Android
    func getProductById(_ id: Int) async throws -> Product {
        let url = URL(string: "\(baseURL)/products/\(id)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try JSONDecoder().decode(Product.self, from: data)
    }
}
