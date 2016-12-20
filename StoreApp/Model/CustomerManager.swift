//
//  CustomerManager.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 15/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

let customerManager = CustomerManager.sharedManager

open class CustomerManager: NSObject {

    // MARK: Properties
    /// Singleton instance of `PersistencyManager`
    open static let sharedManager = CustomerManager()
    
    open var isCustomerLoggedIn: Bool {
        return persistencyManager.count("Customer") > 0
    }
    
    open var currentCustomer: Customer? {
        return persistencyManager.fetchFirst("Customer")
    }
    
    open var accessToken: String? {
        return currentCustomer?.access_token
    }
    
    open func setDetailsInCurrentCustomer(_ dictionary: Dictionary<String, AnyObject>) {
        if let customer = currentCustomer {
            customer.setWithDictionary(dictionary, position: 0)
        } else {
            persistencyManager.insert("Customer", entityData: dictionary)
        }

        persistencyManager.saveContext()
    }
    
    open func logoutCustomer() {
        persistencyManager.deleteAll("Customer")
        cartManager.deleteCart()
    }
}

// Resent search, Visited items
extension CustomerManager {
    
    func addRecentSearch(_ searchString: String) {
        
        let searchPredicate = NSPredicate(format: "searchString == %@", searchString)
        if persistencyManager.count("RecentSearch", predicate: searchPredicate) == 0 {
            persistencyManager.append("RecentSearch", entitiesArray: [["searchString" : searchString as AnyObject]])
        }
    }
    
    func addRecentProduct(_ id: Int) {
        let searchPredicate = NSPredicate(format: "id = %d", id)
        if persistencyManager.count("RecentProduct", predicate: searchPredicate) == 0 {
            if persistencyManager.count("RecentProduct") == 6 {
                persistencyManager.deleteFirst("RecentProduct", predicate: nil, sortDescriptors: [NSSortDescriptor(key: "insertedOn", ascending: false)])
            }
            persistencyManager.append("RecentProduct", entitiesArray: [["id" : id as AnyObject]])
        }
    }
}
