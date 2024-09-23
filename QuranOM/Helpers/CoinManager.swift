//
//  CoinManager.swift
//  QuranOM
//
//  Created by Moody on 2024-09-22.
//

import Foundation

class CoinsManager {
    static let shared = CoinsManager()
    private let coinsKey = "coinsKey"
    
    var coins: Int {
        get {
            return UserDefaults.standard.integer(forKey: coinsKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: coinsKey)
        }
    }

    func addCoins(_ amount: Int) {
        coins += amount
    }
    
    func removeAds() {
        coins -= 1000
    }
}
