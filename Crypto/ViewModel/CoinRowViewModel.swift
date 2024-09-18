//
//  CoinRowViewModel.swift
//  Crypto
//
//  Created by Sergiu on 20.08.2024.
//

import Foundation

final class CoinRowViewModel: ObservableObject {
    
    @Published var name: String
    @Published var code: String
    @Published var minPrice: String
    @Published var maxPrice: String
    @Published var currentPrice: String
    @Published var imageUrl: String?
    @Published var priceChangeAnimationTrigger: Bool
    @Published var priceChange: PriceChange = .unchanged
    
    init(coin: Coin, coinViewModel: CoinViewModel) {
        self.name = coin.name
        self.code = coin.code
        self.minPrice = CoinRowViewModel.formatPrice(coin.minPrice)
        self.maxPrice = CoinRowViewModel.formatPrice(coin.maxPrice)
        self.currentPrice = CoinRowViewModel.formatPrice(coin.price)
        self.imageUrl = coin.imageUrl
        self.priceChangeAnimationTrigger = coin.priceChangeAnimationTrigger
        self.priceChange = coin.priceChange
    }
    
    private static func formatPrice(_ price: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.groupingSize = 3
        formatter.decimalSeparator = "."
        
        // Decide how many fraction digits based on the price value
        if price < 1 {
            formatter.minimumFractionDigits = 6
            formatter.maximumFractionDigits = 6
        } else {
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
        }
        
        if let formattedPrice = formatter.string(from: NSNumber(value: price)) {
            return "$ \(formattedPrice)"
        } else {
            return "$ \(price)"
        }
    }
}
