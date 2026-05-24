import SwiftUI

// ─── CartView ─────────────────────────────────────────────
// Equivalente a CartScreen.kt in Android Compose

struct CartView: View {
    @EnvironmentObject var cart: CartStore
    @Environment(\.dismiss) private var dismiss

    @State private var showConfirmAlert = false
    @State private var showClearAlert   = false
    @State private var showSuccessAlert = false

    var body: some View {
        Group {
            if cart.items.isEmpty {
                // ── Carrello vuoto ────────────────────────
                VStack(spacing: 16) {
                    Text("🛒").font(.system(size: 64))
                    Text("Il carrello è vuoto").font(.title2).bold()
                    Text("Aggiungi prodotti dal catalogo")
                        .foregroundStyle(.secondary)
                    Button("Torna al catalogo") { dismiss() }
                        .buttonStyle(.borderedProminent)
                }

            } else {
                // ── Lista prodotti nel carrello ───────────
                VStack(spacing: 0) {
                    List {
                        // Card per ogni prodotto
                        ForEach(cart.items) { item in
                            CartItemRow(item: item)
                        }

                        // Riepilogo totale
                        Section {
                            HStack {
                                Text("🛍️")
                                Text("Numero totale prodotti")
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("\(cart.totalItems)").bold()
                            }
                            HStack {
                                Text("💳")
                                Text("Totale complessivo").bold()
                                Spacer()
                                Text("€ \(cart.totalPrice, specifier: "%.2f")")
                                    .font(.title3).bold()
                                    .foregroundStyle(.blue)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)

                    // Pulsanti footer
                    Divider()
                    VStack(spacing: 10) {
                        Button {
                            showConfirmAlert = true
                        } label: {
                            Label("Conferma ordine", systemImage: "cart.fill.badge.plus")
                                .frame(maxWidth: .infinity)
                                .font(.headline)
                        }
                        .buttonStyle(.borderedProminent)

                        Button {
                            showClearAlert = true
                        } label: {
                            Label("Svuota carrello", systemImage: "trash")
                                .frame(maxWidth: .infinity)
                                .font(.subheadline).bold()
                        }
                        .buttonStyle(.bordered)
                        .tint(.red)
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Il mio carrello")
        .navigationBarTitleDisplayMode(.inline)

        // ── Alert: Conferma ordine ──────────────────────
        .alert("Conferma ordine", isPresented: $showConfirmAlert) {
            Button("Annulla", role: .cancel) { }
            Button("Conferma") {
                cart.clearCart()
                showSuccessAlert = true
            }
        } message: {
            Text("Confermi l'ordine di \(cart.totalItems) prodotti per € \(String(format: "%.2f", cart.totalPrice))?")
        }

        // ── Alert: Svuota carrello ──────────────────────
        .alert("Svuota carrello", isPresented: $showClearAlert) {
            Button("Annulla", role: .cancel) { }
            Button("Svuota", role: .destructive) { cart.clearCart() }
        } message: {
            Text("Vuoi rimuovere tutti i prodotti?")
        }

        // ── Alert: Ordine confermato ────────────────────
        .alert("Ordine confermato! ✅", isPresented: $showSuccessAlert) {
            Button("OK") { dismiss() }
        } message: {
            Text("Grazie per il tuo acquisto.")
        }
    }
}

// ── Riga singolo prodotto nel carrello ────────────────────
struct CartItemRow: View {
    @ObservedObject var item: CartItem
    @EnvironmentObject var cart: CartStore

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Immagine
            AsyncImage(url: URL(string: item.product.firstImage)) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Color.gray.opacity(0.2)
            }
            .frame(width: 70, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(item.product.title)
                    .font(.subheadline).bold()
                    .lineLimit(2)

                Text("€ \(item.product.price, specifier: "%.2f")")
                    .font(.subheadline).bold()
                    .foregroundStyle(.blue)

                HStack {
                    // Stepper quantità
                    HStack(spacing: 0) {
                        Button {
                            cart.updateQuantity(item.product.id, quantity: item.quantity - 1)
                        } label: {
                            Image(systemName: "minus")
                                .frame(width: 32, height: 32)
                        }

                        Text("\(item.quantity)")
                            .font(.subheadline).bold()
                            .frame(minWidth: 28)

                        Button {
                            cart.updateQuantity(item.product.id, quantity: item.quantity + 1)
                        } label: {
                            Image(systemName: "plus")
                                .frame(width: 32, height: 32)
                        }
                    }
                    .buttonStyle(.bordered)
                    .clipShape(Capsule())

                    Spacer()

                    // Subtotale
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Subtotale")
                            .font(.caption).foregroundStyle(.secondary)
                        Text("€ \(item.subtotal, specifier: "%.2f")")
                            .font(.subheadline).bold()
                            .foregroundStyle(.blue)
                    }
                }
            }
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                cart.removeFromCart(item.product.id)
            } label: {
                Label("Elimina", systemImage: "trash")
            }
        }
    }
}
