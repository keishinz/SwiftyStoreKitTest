//
//  ViewController.swift
//  SwiftyStoreKitTest
//
//  Created by Keishin CHOU on 2020/01/23.
//  Copyright © 2020 Keishin CHOU. All rights reserved.
//

import UIKit
import StoreKit
import SwiftyStoreKit

class ViewController: UIViewController {
    
    @IBOutlet weak var consumableProduct1: UIButton!
    @IBOutlet weak var nonConsumableProduct1: UIButton!
    @IBOutlet weak var nonConsumableProduct2: UIButton!
    @IBOutlet weak var autoRenewableSubs1: UIButton!
    @IBOutlet weak var autoRenewableSubs2: UIButton!
    @IBOutlet weak var nonRenewingSubs1: UIButton!
    
    private var purchaseButtons: Array<UIButton>!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        purchaseButtons = [
            consumableProduct1,
            nonConsumableProduct1,
            nonConsumableProduct2,
            autoRenewableSubs1,
            autoRenewableSubs2,
            nonRenewingSubs1
        ]
        
        var productIdentifiers = [String]()
        var retrievedProducts = [SKProduct]()
        
        SwiftyStoreKit.retrieveProductsInfo(IAPProductManager.iapProductIDs) { result in
            
            if result.error == nil {
                for product in result.retrievedProducts {
                    print("Product: \(product.localizedTitle),description: \(product.localizedDescription), price: \(product.localizedPrice!)")
                    print(product.productIdentifier)
                    productIdentifiers.append(product.productIdentifier)
                    retrievedProducts.append(product)
                }
                
                for product in retrievedProducts {
                    if let i = IAPProductManager.iapProductIDsArray.firstIndex(of: product.productIdentifier) {
                        self.purchaseButtons[i].setTitle("\(product.localizedDescription) - \(product.localizedPrice!)", for: .normal)
                    }
                    
                    if product.productIdentifier.contains("Subs") {
                        if product.productIdentifier.contains("auto") {
                            self.verifyPurchase(with: product.productIdentifier, purchaesType: .autoRenewableSubscription)
                        } else {
                            self.verifyPurchase(with: product.productIdentifier, purchaesType: .nonRenewingSubscriprion, validDuration: TimeInterval(3600 * 24 * 30))
                        }
                    } else {
                        self.verifyPurchase(with: product.productIdentifier, purchaesType: .nonSubscription)
                    }
                    
                }
                
                if !result.invalidProductIDs.isEmpty {
                    for invalidProductID in result.invalidProductIDs {
                        print("Invalid product identifier: \(invalidProductID)")
                    }
                }
            } else {
                print("Error: \(result.error!)")
            }
        }
        
    }

    @IBAction func consumableProduct1(_ sender: UIButton) {
        purchaseButtonTapped(at: sender)
    }
    @IBAction func nonConsumableProduct1(_ sender: UIButton) {
        purchaseButtonTapped(at: sender)
    }
    @IBAction func nonConsumableProduct2(_ sender: UIButton) {
        purchaseButtonTapped(at: sender)
    }
    @IBAction func autoRenewableSubs1(_ sender: UIButton) {
        purchaseButtonTapped(at: sender)
    }
    @IBAction func autoRenewableSubs2(_ sender: UIButton) {
        purchaseButtonTapped(at: sender)
    }
    @IBAction func nonRenewingSubs1(_ sender: UIButton) {
        purchaseButtonTapped(at: sender)
    }
    @IBAction func restorePurchases(_ sender: UIButton) {
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
            }
            else if results.restoredPurchases.count > 0 {
                print("Restore Success: \(results.restoredPurchases)")
            }
            else {
                print("Nothing to Restore")
            }
        }
    }
    
    func purchaseButtonTapped(at sender: UIButton) {
        if let i = purchaseButtons.firstIndex(of: sender) {
            print(i)
            let productionIdentifier = IAPProductManager.iapProductIDsArray[i]
            purchaseProduct(with: productionIdentifier)
        }
    }
    
    
    func verifyPurchase(with productIdentifier: String, purchaesType: IAPProductManager.IAPPurchaseType, validDuration: TimeInterval? = nil) {
        
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: IAPProductManager.appSpecificSharedSecret)
        
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            
            switch result {
                
            case .success(let receipt):
                // Verify purchases
                switch purchaesType {
                case .nonSubscription:
                    // Verify the purchase of Consumable or NonConsumable
                    let purchaseResult = SwiftyStoreKit.verifyPurchase(
                        productId: productIdentifier,
                        inReceipt: receipt)
                    
                    switch purchaseResult {
                    case .purchased(let receiptItem):
                        print("\(productIdentifier) is purchased: \(receiptItem)")
                    case .notPurchased:
                        print("The user has never purchased \(productIdentifier)")
                    }
                    
                case .nonRenewingSubscriprion:
                    // Verify the purchases of Non Renewing Subscription
                    guard let validDuration = validDuration else { return }
                    let purchaseResult = SwiftyStoreKit.verifySubscription(
                        ofType: .nonRenewing(validDuration: validDuration),
                        productId: productIdentifier,
                        inReceipt: receipt)
                    
                    switch purchaseResult {
                    case .purchased(let expiryDate, let items):
                        print("\(productIdentifier) is valid until \(expiryDate)\n\(items)\n")
                    case .expired(let expiryDate, let items):
                        print("\(productIdentifier) is expired since \(expiryDate)\n\(items)\n")
                    case .notPurchased:
                        print("The user has never purchased \(productIdentifier)")
                    }
                    
                case .autoRenewableSubscription:
                    // Verify purchases of Auto Renewable Subscription
                    let purchaseResult = SwiftyStoreKit.verifySubscription(
                        ofType: .autoRenewable,
                        productId: productIdentifier,
                        inReceipt: receipt)
                    
                    switch purchaseResult {
                    case .purchased(let expiryDate, let items):
                        print("\(productIdentifier) is valid until \(expiryDate)\n\(items)\n")
                    case .expired(let expiryDate, let items):
                        print("\(productIdentifier) is expired since \(expiryDate)\n\(items)\n")
                    case .notPurchased:
                        print("The user has never purchased \(productIdentifier)")
                    }
                }

            case .error(let error):
                print("Receipt verification failed: \(error)")
            }
        }
    }
    
    func purchaseProduct(with productIdentifier: String) {
        
        if !productIdentifier.contains("Subs") {
            SwiftyStoreKit.retrieveProductsInfo([productIdentifier]) { result in
            
                if let product = result.retrievedProducts.first {
                    SwiftyStoreKit.purchaseProduct(product, quantity: 1, atomically: true) { result in
                        switch result {
                        case .success(let purchase):
                            print("Purchase Success: \(purchase.productId)")
                        case .error(let error):
                            switch error.code {
                            case .unknown:
                                print("Unknown error. Please contact support")
                            case .clientInvalid:
                                print("Not allowed to make the payment")
                            case .paymentCancelled:
                                break
                            case .paymentInvalid:
                                print("The purchase identifier was invalid")
                            case .paymentNotAllowed:
                                print("The device is not allowed to make the payment")
                            case .storeProductNotAvailable:
                                print("The product is not available in the current storefront")
                            case .cloudServicePermissionDenied:
                                print("Access to cloud service information is not allowed")
                            case .cloudServiceNetworkConnectionFailed:
                                print("Could not connect to the network")
                            case .cloudServiceRevoked:
                                print("User has revoked permission to use this cloud service")
                            default: print((error as NSError).localizedDescription)
                            }
                        }
                    }
                }
            }
        } else {
            SwiftyStoreKit.purchaseProduct(productIdentifier, atomically: true) { result in
                
                switch result {
                case .success(let purchase):
                    print("subscription successed.")
                    // Deliver content from server, then:
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                        print("finished transaction.")
                    }
                    
                    if productIdentifier.contains("auto") {
                        self.verifyPurchase(with: productIdentifier, purchaesType: .autoRenewableSubscription)
                    } else {
                        self.verifyPurchase(with: productIdentifier, purchaesType: .nonRenewingSubscriprion, validDuration: TimeInterval(3600 * 24 * 30))
                    }
                case .error(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
}

