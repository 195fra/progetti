# ShopApp iOS — Swift + SwiftUI

App iOS equivalente al progetto Android Compose.

## Stack tecnico

| Swift / SwiftUI | Equivalente Android |
|---|---|
| `URLSession` | Retrofit + OkHttp |
| `@ObservableObject` + `@Published` | `ViewModel` + `StateFlow` |
| `@StateObject` | `hiltViewModel()` |
| `@EnvironmentObject` | Hilt `@Singleton` iniettato |
| `NavigationStack` + `NavigationLink` | `NavHost` + `navController.navigate()` |
| `AsyncImage` | Coil `AsyncImage` |
| `.task { }` | `LaunchedEffect` |
| `@main struct ShopApp` | `MainActivity` + `@HiltAndroidApp` |

## Struttura

```
ShopApp/
├── ShopApp.swift              ← Entry point (@main)
├── Models/
│   └── Models.swift           ← Product, Category, CartItem
├── Services/
│   └── ApiService.swift       ← URLSession (come Retrofit)
├── ViewModels/
│   ├── CartStore.swift        ← Carrello singleton (come CartViewmodel)
│   ├── ProductListViewModel.swift
│   └── ProductDetailViewModel.swift
└── Views/
    ├── ProductListView.swift  ← Lista prodotti
    ├── ProductDetailView.swift
    └── CartView.swift
```

## Setup in Xcode

1. **Xcode → File → New → Project → App**
2. Scegli: **Interface: SwiftUI**, **Language: Swift**
3. Sostituisci i file generati con quelli di questo progetto
4. **Run ▶** su simulatore o device

> Non serve nessun package manager (SPM / CocoaPods) —
> URLSession e SwiftUI sono già inclusi in iOS SDK.
