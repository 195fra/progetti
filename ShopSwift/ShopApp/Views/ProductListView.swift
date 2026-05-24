import SwiftUI

// ─── ProductListView ──────────────────────────────────────
// Equivalente a ProductListScreen in Android Compose
// NavigationStack = equivalente al NavHost
// @StateObject = come hiltViewModel() — crea il ViewModel legato alla View

struct ProductListView: View {

    @StateObject private var viewModel = ProductListViewModel()

    // @EnvironmentObject legge il CartStore passato dall'App
    // Equivalente a hiltViewModel() con @Singleton in Android
    @EnvironmentObject var cart: CartStore

    var body: some View {
        NavigationStack {
            Group {
                // ── Loading ──────────────────────────────
                if viewModel.isLoading {
                    ProgressView("Caricamento prodotti…")

                // ── Errore ───────────────────────────────
                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 16) {
                        Text("⚠️").font(.system(size: 52))
                        Text("Errore").font(.title2).bold()
                        Text(error).foregroundStyle(.secondary).multilineTextAlignment(.center)
                        Button("Riprova") {
                            Task { await viewModel.fetchProducts() }
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()

                // ── Lista prodotti ───────────────────────
                } else {
                    List(viewModel.products) { product in
                        // NavigationLink = equivalente a navController.navigate("details/${id}")
                        NavigationLink(destination: ProductDetailView(productId: product.id)) {
                            ProductRowView(product: product)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Catalogo Prodotti")
            .toolbar {
                // Pulsante carrello con badge
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: CartView()) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "cart")
                                .font(.title2)
                            if cart.totalItems > 0 {
                                Text("\(cart.totalItems)")
                                    .font(.caption2).bold()
                                    .foregroundStyle(.white)
                                    .padding(4)
                                    .background(.red, in: Circle())
                                    .offset(x: 8, y: -8)
                            }
                        }
                    }
                }
            }
            // Equivalente a init { fetchProducts() } nel ViewModel
            .task { await viewModel.fetchProducts() }
        }
    }
}

// ── Riga singolo prodotto ─────────────────────────────────
// Equivalente alla Card dentro LazyColumn in Android
struct ProductRowView: View {
    let product: Product

    var body: some View {
        HStack(spacing: 14) {
            // AsyncImage = equivalente a Coil AsyncImage in Android
            AsyncImage(url: URL(string: product.firstImage)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 88, height: 88)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(product.category.name.uppercased())
                    .font(.caption).bold()
                    .foregroundStyle(.blue)

                Text(product.title)
                    .font(.subheadline).bold()
                    .lineLimit(2)

                Text("€ \(product.price, specifier: "%.2f")")
                    .font(.subheadline).bold()
                    .foregroundStyle(.blue)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}
