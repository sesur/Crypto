//
//  CryptoUseCases.swift
//  Crypto
//
//  Created by Sergiu on 18.08.2024.
//

import Foundation
import CryptoAPI
import Combine

final class CoinUseCase {
    private let repository: CoinRepository
    private let service: CryptoService
    private var cancellables = Set<AnyCancellable>()
    private var lastKnownPrices: [String: Double] = [:] // To track last known prices for comparison
    
    let pricePublisher = PassthroughSubject<Coin, Never>()
    
    init(repository: CoinRepository, service: CryptoService) {
        self.repository = repository
        self.service = service
        setupBindings()
    }
    
    private func setupBindings() {
        service.coinPriceDidUpdate
            .receive(on: DispatchQueue.main)
            .sink { [weak self] coin in
                self?.handlePriceUpdate(for: coin)
            }
            .store(in: &cancellables)
    }
    
    private func handlePriceUpdate(for updatedCoin: Coin) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
          
            if var existingCoin = self.repository.fetchCoin(byCode: updatedCoin.code) {
                var didUpdate = false
                
                // Determine if the price has increased or decreased
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
                
                if existingCoin.imageUrl != updatedCoin.imageUrl || existingCoin.name != updatedCoin.name {
                    existingCoin.imageUrl = updatedCoin.imageUrl
                    existingCoin.name = updatedCoin.name
                    didUpdate = true
                }
                
                if didUpdate {
                    existingCoin.priceChangeAnimationTrigger = true
                    existingCoin.priceChange = updatedCoin.priceChange
                    
                    // Save the updated coin to the repository and emit the update
                    self.repository.saveCoin(existingCoin)
                    self.pricePublisher.send(existingCoin)

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.repository.saveCoin(existingCoin)
                        self.pricePublisher.send(existingCoin)
                    }
                }

            } else {
                // Create and save a new coin if not found
                let newCoin = Coin(
                    name: updatedCoin.name,
                    code: updatedCoin.code,
                    price: updatedCoin.price,
                    imageUrl: updatedCoin.imageUrl,
                    minPrice: updatedCoin.minPrice,
                    maxPrice: updatedCoin.maxPrice,
                    priceChangeAnimationTrigger: true,
                    priceChange: .unchanged
                )
                
                self.repository.saveCoin(newCoin)
                self.pricePublisher.send(newCoin)
            }
            
            // Update the last known price regardless of whether it changed or not
            self.lastKnownPrices[updatedCoin.code] = updatedCoin.price
        }
    }
    
    func fetchAllCoins() -> [Coin] {
        return repository.fetchAllCoins().sorted { $0.price > $1.price }
    }
    
    func connectToCryptoAPI() {
        service.connect()
    }
    
    func disconnectFromCryptoAPI() {
        service.disconnect()
    }
}
