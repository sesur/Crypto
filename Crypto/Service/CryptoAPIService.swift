//
//  CryptoService.swift
//  Crypto
//
//  Created by Sergiu on 18.08.2024.
//

import Foundation
import CryptoAPI
import Combine

protocol CryptoService {
    func connect()
    func disconnect()
    func fetchAllCoins() -> [Coin]
    var coinPriceDidUpdate: PassthroughSubject<Coin, Never> { get }
}

final class CryptoAPIService: CryptoService {
    var coinPriceDidUpdate = PassthroughSubject<Coin, Never>()
    var crypto: Crypto!
    private var isConnected = false
    
    init() {}
    
    func connect() {
        guard !isConnected else { return }
        let result = crypto.connect()
        if case .failure(let error) = result {
            print("Failed to connect to CryptoAPI: \(error.localizedDescription)")
        }
    }
    
    func disconnect() {
        crypto.disconnect()
        isConnected = false
    }
    
    func fetchAllCoins() -> [Coin] {
        let cryptoCoins = crypto.getAllCoins()
        let coins = cryptoCoins.map { cryptoCoin in
            Coin(
                name: cryptoCoin.name,
                code: cryptoCoin.code,
                price: cryptoCoin.price,
                imageUrl: cryptoCoin.imageUrl,
                minPrice: cryptoCoin.price,
                maxPrice: cryptoCoin.price,
                priceChangeAnimationTrigger: false,
                priceChange: .unchanged
            )
        }
        return coins
    }
}

extension CryptoAPIService: CryptoDelegate {
    func cryptoAPIDidConnect() {
        isConnected = true
        debugPrint("Connected to CryptoAPI")
    }
    
    func cryptoAPIDidUpdateCoin(_ coin: CryptoAPI.Coin) {
        let convertedCoin = Coin(
            name: coin.name,
            code: coin.code,
            price: coin.price,
            imageUrl: coin.imageUrl,
            minPrice: coin.price,
            maxPrice: coin.price,
            priceChangeAnimationTrigger: false,
            priceChange: .unchanged
        )
        coinPriceDidUpdate.send(convertedCoin)
    }
    
    func cryptoAPIDidDisconnect() {
        isConnected = false
        debugPrint("Disconnected from CryptoAPI")
    }
}
