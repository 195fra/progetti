import SwiftUI

// ─── Entry point ──────────────────────────────────────────
// Equivalente a MainActivity.kt + MyApp.kt in Android
// @main = punto di ingresso dell'app (come fun main() in Kotlin)

@main
struct ShopApp: App {

    // CartStore singleton — equivalente a @Singleton Cart in Hilt
    // @StateObject garantisce che esista una sola istanza per tutta l'app
    @StateObject private var cart = CartStore.shared

    var body: some Scene {
        WindowGroup {
            ProductListView()
                // .environmentObject = equivalente a passare il cart come prop
                // a tutti i figli — come il CartModule di Hilt ma automatico
                .environmentObject(cart)
        }
    }
}
