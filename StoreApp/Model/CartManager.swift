//
//  CartManager.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 28/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

public let cartManager = CartManager.sharedManager

open class CartManager: NSObject {

    // MARK: Properties
    /// Singleton instance of `PersistencyManager`
    open static let sharedManager = CartManager()
    
    open var isCartAvailable: Bool {
        return persistencyManager.count("Cart") > 0
    }
    
    open var currentCart: Cart? {
        return persistencyManager.fetchFirst("Cart")
    }
    
    open var cartToken: String? {
        return currentCart?.token
    }
    
    open var cartCount: Int {
        if let cart = currentCart {
            return cart.itemsCount
        }
        return 0
    }
    
    open var cartCountString: String {
        if let cart = currentCart {
            return cart.itemsCountString
        }
        return ""
    }
    
    open func setDetailsInCurrentCart(_ dictionary: Dictionary<String, AnyObject>) {
        if let cart = currentCart {
            cart.setWithDictionary(dictionary, position: 0)
        } else {
            persistencyManager.insert("Cart", entityData: dictionary)
        }
        
        persistencyManager.saveContext()
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: CartUpdateNotification), object: nil)
    }
    
    open func deleteCart() {
        persistencyManager.deleteAll("Cart")
        persistencyManager.saveContext()
        NotificationCenter.default.post(name: Notification.Name(rawValue: CartUpdateNotification), object: nil)
    }
}
