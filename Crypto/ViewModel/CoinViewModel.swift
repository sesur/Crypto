//
//  CryptoViewModel.swift
//  Crypto
//
//  Created by Sergiu on 18.08.2024.
//

import SwiftUI
import Combine

enum PriceChange {
    case increased
    case decreased
    case unchanged
}

final class CoinViewModel: ObservableObject {
    @Published var coins: [Coin] = []
    @Published var name: String = ""
    @Published var code: String = ""
    @Published var currentPrice: Double = 0.0
    @Published var minPrice: Double = 0.0
    @Published var maxPrice: Double = 0.0
    @Published var imageUrl: String?
    @Published var priceChangeAnimationTrigger: Bool = false
    @Published var priceChange: PriceChange = .unchanged
    
    @Published var coinUseCase: CoinUseCase
    private var cancellables = Set<AnyCancellable>()
    
    init(coinUseCase: CoinUseCase) {
        self.coinUseCase = coinUseCase
        fetchCoins()
        observePriceChanges()
    }
    
    func fetchCoins() {
        coins = coinUseCase.fetchAllCoins()
    }
    
    func connectToAPI() {
        coinUseCase.connectToCryptoAPI()
    }
    
    func disconnectFromAPI() {
        coinUseCase.disconnectFromCryptoAPI()
    }
    
    func observePriceChanges() {
        coinUseCase.pricePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] updatedCoin in
                self?.updateCoin(updatedCoin)
            }
            .store(in: &cancellables)
    }
    
    private func updateCoin(_ updatedCoin: Coin) {
        if let index = coins.firstIndex(where: { $0.code == updatedCoin.code }) {
            var existingCoin = coins[index]
            var didUpdate = false
            
            if updatedCoin.price > existingCoin.price {
                existingCoin.priceChange = .increased
            } else if updatedCoin.price < existingCoin.price {
                existingCoin.priceChange = .decreased
            } else {
                existingCoin.priceChange = .unchanged
            }
            
            if existingCoin.price != updatedCoin.price {
                existingCoin.price = updatedCoin.price
                didUpdate = true
            }
            
            if updatedCoin.minPrice < existingCoin.minPrice {
                existingCoin.minPrice = updatedCoin.minPrice
                didUpdate = true
            }
            
            if updatedCoin.maxPrice > existingCoin.maxPrice {
                existingCoin.maxPrice = updatedCoin.maxPrice
                didUpdate = true
            }
            
            // Trigger animation if there was an update
            if didUpdate {
                existingCoin.priceChangeAnimationTrigger = true
                coins[index] = existingCoin
                
                // Reset the animation trigger after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.coins[index].priceChangeAnimationTrigger = false
                }
            }
        }
    }
}
