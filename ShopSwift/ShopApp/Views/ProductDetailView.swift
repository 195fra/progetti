import SwiftUI

// ─── ProductDetailView ────────────────────────────────────
// Equivalente a ProductDetailScreen in Android Compose

struct ProductDetailView: View {
    let productId: Int

    @StateObject private var viewModel = ProductDetailViewModel()
    @EnvironmentObject var cart: CartStore

    // Equivalente a showAddedDialog in Android
    @State private var showAddedAlert = false

    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Caricamento…")

            } else if let error = viewModel.errorMessage {
                VStack(spacing: 16) {
                    Text("⚠️").font(.system(size: 52))
                    Text(error).foregroundStyle(.secondary)
                    Button("Riprova") {
                        Task { await viewModel.fetchProduct(id: productId) }
                    }
                    .buttonStyle(.borderedProminent)
                }

            } else if let product = viewModel.product {
                // Contenuto scrollabile + pulsante fisso in fondo
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 14) {

                            // Immagine grande
                            AsyncImage(url: URL(string: product.firstImage)) { image in
                                image.resizable().scaledToFit()
                            } placeholder: {
                                Color.gray.opacity(0.15)
                                    .frame(height: 260)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 260)
                            .clipShape(RoundedRectangle(cornerRadius: 20))
                            .padding(.horizontal)

                            VStack(alignment: .leading, spacing: 10) {
                                // Titolo
                                Text(product.title)
                                    .font(.title2).bold()

                                // Chip categoria
                                Text(product.category.name)
                                    .font(.subheadline).bold()
                                    .foregroundStyle(.blue)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 5)
                                    .background(Color.blue.opacity(0.1))
                                    .clipShape(Capsule())

                                // Prezzo
                                Text("€ \(product.price, specifier: "%.2f")")
                                    .font(.largeTitle).bold()
                                    .foregroundStyle(.blue)

                                // Descrizione
                                Text("DESCRIZIONE")
                                    .font(.caption).bold()
                                    .foregroundStyle(.secondary)

                                Text(product.description)
                                    .font(.body)
                                    .foregroundStyle(.secondary)
                                    .lineSpacing(4)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 100) // spazio per il pulsante fisso
                    }

                    // Pulsante fisso in fondo
                    // Equivalente al Button fisso in fondo in Android
                    Divider()
                    Button {
                        cart.addToCart(product)
                        showAddedAlert = true
                    } label: {
                        Label("Aggiungi al carrello", systemImage: "cart.badge.plus")
                            .frame(maxWidth: .infinity)
                            .font(.headline)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                    // Equivalente a showAddedDialog in Android
                    .alert("Aggiunto al carrello ✅", isPresented: $showAddedAlert) {
                        Button("Continua") { }
                    } message: {
                        Text("\(product.title) è stato aggiunto al carrello.")
                    }
                }
            }
        }
        .navigationTitle("Dettaglio")
        .navigationBarTitleDisplayMode(.inline)
        // Equivalente a LaunchedEffect(productId) { viewModel.fetchProduct(it) }
        .task { await viewModel.fetchProduct(id: productId) }
    }
}
