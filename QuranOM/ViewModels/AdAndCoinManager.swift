//
//  AdAndCoinManager.swift
//  QuranOM
//
//  Created by Moody on 2024-09-23.
//

import Foundation
import StoreKit

class AdAndCoinManager: NSObject, ObservableObject {
    
    // Coins
    @Published var coins: Int = CoinsManager.shared.coins
    
    // StoreKit
    @Published var areAdsRemoved = false
    @Published var availableProducts: [Product] = []
    
    @Published var errorMessage: String = " "
    
    override init() {
        super.init()
        
        Task {
            await loadProducts()
        }
        
        // Check if the user has already purchased Remove Ads
        if UserDefaults.standard.bool(forKey: "areAdsRemoved") {
            self.areAdsRemoved = true
        }
    }
    
    func addCoins(_ amount: Int) {
        CoinsManager.shared.addCoins(amount)
        self.coins = CoinsManager.shared.coins
    }
    
    // Spend 1000 coins to remove ads
    func removeAdsWithCoins() {
        if coins >= 1000 {
            coins -= 1000
            CoinsManager.shared.removeAds()
            removeAds() // Update ads state
            errorMessage = ""
        } else {
            errorMessage = "Not enough coins!"
        }
    }
    
    // Mark ads as removed
    private func removeAds() {
        areAdsRemoved = true
        UserDefaults.standard.set(true, forKey: "areAdsRemoved")  // Save ad removal state
    }
    
    // Purchase the "Remove Ads" product
    @MainActor
    func purchaseRemoveAds() async {
        errorMessage = ""
        
        guard let product = availableProducts.first(where: { $0.id == "com.quranom.removeads" }) else {
            print("Remove Ads product not found.")
            return
        }
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(_):
                    // Successfully purchased, remove ads
                    removeAds()
                case .unverified(_, _):
                    print("Purchase unverified.")
                }
            case .userCancelled:
                print("User cancelled the purchase.")
            case .pending:
                print("Purchase pending.")
            @unknown default:
                print("Unknown Error: Purchasing Ad Removal.")
            }
        } catch {
            print("Purchase failed: \(error)")
        }
    }
    
    // Restore previously purchased non-consumable items (like "Remove Ads")
    @MainActor
    func restorePurchases() async {
        errorMessage = ""
        
        do {
            for await result in Transaction.currentEntitlements {
                if case .verified(let transaction) = result {
                    if transaction.productID == "com.quranom.removeads" {
                        removeAds()
                    }
                }
            }
            print("Purchases restored successfully.")
        } catch {
            print("Failed to restore purchases: \(error)")
        }
    }
    
    // Fetch in-app products using the new StoreKit 2 Product API
    @MainActor
    func loadProducts() async {
        errorMessage = ""
        
        do {
            let products = try await Product.products(for: ["com.quranom.removeads"])
            print(products)
            availableProducts = products
        } catch {
            print("Failed to load products: \(error)")
        }
    }
    
}
