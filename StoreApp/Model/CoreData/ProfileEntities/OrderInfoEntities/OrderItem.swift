//
//  OrderItem.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 22/05/16.
//  Copyright © 2016 Rakesh Pethani. All rights reserved.
//

import Foundation
import CoreData


open class OrderItem: NSManagedObject {

    // General Info
    @NSManaged var id: Int32
    @NSManaged var name: String?
    @NSManaged var image_url: String?
    @NSManaged var quantity: Int32
    @NSManaged var max_quantity_possible: Int32
    @NSManaged var vendor_id: Int32
    @NSManaged var order_id: Int32
    @NSManaged var variant_id: Int32
    @NSManaged var sku: String?
    @NSManaged var status_id: String?
    @NSManaged var custom_details: String?
    
    // Creation related info
    @NSManaged var insertedOn: TimeInterval
    @NSManaged var position: Int32
    
    // Pricing properties
    @NSManaged var discounted_price: String?
    @NSManaged var actual_price: String?

    @NSManaged var orderInfo: OrderInfo?
    @NSManaged var cart: Cart?
    
    var productImageURL: URL? {
        if image_url != nil {
            return URL(string: image_url!)
        }
        return nil
    }
    
    var productImageURLWithHTTP: URL? {
        return URL(string: "http:"+image_url!)
    }
    
    var isQuantityValid: Bool {
        
        if max_quantity_possible == 0 || (max_quantity_possible < quantity) {
            return false
        }
        
        return true
    }
}


extension OrderItem: PersistencyOperation {
    
    public func setWithDictionary(_ dictionary: Dictionary<String, AnyObject>, position: Int) {
        
        if let value = dictionary["id"] as? Int {
            self.id = Int32(value)
        }
        
        if let value = dictionary["name"] as? String {
            self.name = value
        }
        
        if let value = dictionary["image_url"] as? String {
            self.image_url = value
        }
        
        if let value = dictionary["quantity"] as? Int {
            self.quantity = Int32(value)
        }
        
        if let value = dictionary["max_quantity_possible"] as? Int {
            self.max_quantity_possible = Int32(value)
        }
        
        if let value = dictionary["vendor_id"] as? Int {
            self.vendor_id = Int32(value)
        }
        
        if let value = dictionary["order_id"] as? Int {
            self.order_id = Int32(value)
        }
        
        if let value = dictionary["variant_id"] as? Int {
            self.variant_id = Int32(value)
        }
        
        if let value = dictionary["sku"] as? String {
            self.sku = value
        }
        
        if let value = dictionary["status_id"] as? String {
            self.status_id = value
        }
        
        if let value = dictionary["custom_details"] as? [String: String] {
            
            var str: [String] = []
            for (key, val) in value {
                str.append(key.uppercased() + ": " + val)
            }
            
            self.custom_details = str.joined(separator: ",")
        }
        
        // Creation related info
        insertedOn = Date().timeIntervalSinceNow
        
        if let positionVal = dictionary["position"] as? Int {
            self.position = Int32(positionVal)
        } else {
            self.position = Int32(position)
        }
        
        // Pricing properties
        if let value = dictionary["discounted_price"] as? String {
            self.discounted_price = value
        }
        
        if let value = dictionary["actual_price"] as? String {
            self.actual_price = value
        }
    }
}
