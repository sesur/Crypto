//
//  CryptoApp.swift
//  Crypto
//
//  Created by Sergiu on 18.08.2024.
//

import SwiftUI
import CryptoAPI

class DependencyManager: ObservableObject {
    static let shared = DependencyManager()

    let cryptoService: CryptoAPIService
    let crypto: Crypto
    let cryptoRepository: RealmCoinRepository
    let coinUseCase: CoinUseCase
    let viewModel: CoinViewModel

    private init() {
        self.cryptoService = CryptoAPIService()
        self.crypto = Crypto(delegate: cryptoService)
        self.cryptoService.crypto = self.crypto
        self.cryptoRepository = RealmCoinRepository()
        self.coinUseCase = CoinUseCase(repository: cryptoRepository, service: cryptoService)
        self.viewModel = CoinViewModel(coinUseCase: coinUseCase)
    }
}

@main
struct MainApp: App {
    @StateObject private var dependencyManager = DependencyManager.shared

    var body: some Scene {
        WindowGroup {
            CriptoListView(viewModel: dependencyManager.viewModel)
        }
    }
}
