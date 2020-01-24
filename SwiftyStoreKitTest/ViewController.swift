//
//  ViewController.swift
//  SwiftyStoreKitTest
//
//  Created by Keishin CHOU on 2020/01/23.
//  Copyright © 2020 Keishin CHOU. All rights reserved.
//

import UIKit
import SwiftyStoreKit

class ViewController: UIViewController {
    
    @IBOutlet weak var consumableProduct1: UIButton!
    @IBOutlet weak var nonConsumableProduct1: UIButton!
    @IBOutlet weak var nonConsumableProduct2: UIButton!
    @IBOutlet weak var autoRenewableSubs1: UIButton!
    @IBOutlet weak var autoRenewableSubs2: UIButton!
    @IBOutlet weak var nonRenewingSubs1: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        SwiftyStoreKit.retrieveProductsInfo(IAPProductManager.iapProductIDs) { result in
            
            if result.error == nil {
                for product in result.retrievedProducts {
                    print("Product: \(product.localizedTitle),description: \(product.localizedDescription), price: \(product.localizedPrice!)")
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
    }
    @IBAction func nonConsumableProduct1(_ sender: UIButton) {
    }
    @IBAction func nonConsumableProduct2(_ sender: UIButton) {
    }
    @IBAction func autoRenewableSubs1(_ sender: UIButton) {
    }
    @IBAction func autoRenewableSubs2(_ sender: UIButton) {
    }
    @IBAction func nonRenewingSubs1(_ sender: UIButton) {
    }
    
}

