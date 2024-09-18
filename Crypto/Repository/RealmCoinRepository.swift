//
//  RealmCryptoRepository.swift
//  Crypto
//
//  Created by Sergiu on 18.08.2024.
//

import Foundation
import RealmSwift

protocol CoinRepository {
    func saveCoin(_ coin: Coin)
    func fetchAllCoins() -> [Coin]
    func fetchCoin(byCode code: String) -> Coin?
}

final class RealmCoinRepository: CoinRepository {
    private let realm = try! Realm()
    
    func saveCoin(_ coin: Coin) {
        let coinObject = CoinRealmObject(coin: coin)
        try! realm.write {
            realm.add(coinObject, update: .modified)
        }
    }
    
    func fetchAllCoins() -> [Coin] {
        return realm.objects(CoinRealmObject.self).map { $0.toCoin() }
    }
    
    func fetchCoin(byCode code: String) -> Coin? {
        return realm.object(ofType: CoinRealmObject.self, forPrimaryKey: code)?.toCoin()
    }
}
