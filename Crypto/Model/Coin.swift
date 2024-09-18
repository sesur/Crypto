//
//  Coin.swift
//  Crypto
//
//  Created by Sergiu on 18.08.2024.
//

import Foundation
import RealmSwift

struct Coin: Identifiable {
    var id: String { code }
    var name: String
    var code: String
    var price: Double
    var imageUrl: String?
    var minPrice: Double
    var maxPrice: Double
    var priceChangeAnimationTrigger: Bool = false
    var priceChange: PriceChange = .unchanged
}

class CoinRealmObject: Object {
    @Persisted var name: String
    @Persisted(primaryKey: true) var code: String
    @Persisted var price: Double
    @Persisted var imageUrl: String?
    @Persisted var minPrice: Double
    @Persisted var maxPrice: Double
    
    convenience init(coin: Coin) {
        self.init()
        self.name = coin.name
        self.code = coin.code
        self.price = coin.price
        self.imageUrl = coin.imageUrl
        self.minPrice = coin.minPrice
        self.maxPrice = coin.maxPrice
    }
    
    func toCoin() -> Coin {
        return Coin(name: name, code: code, price: price, imageUrl: imageUrl, minPrice: minPrice, maxPrice: maxPrice)
    }
}
