//
//  ProductVariant.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 27/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import Foundation
import CoreData


open class ProductVariant: NSManagedObject {

    @NSManaged var id: Int32
    @NSManaged var insertedOn: TimeInterval
    @NSManaged var minimum_stock_level: Int32
    @NSManaged var position: Int32
    @NSManaged var previous_price: String?
    @NSManaged var price: String?
    @NSManaged var quantity: Int32
    @NSManaged var sku: String?
    @NSManaged var weight: String?
    @NSManaged var image_id: String?
    @NSManaged var option1: String?
    @NSManaged var option2: String?
    @NSManaged var option3: String?
    @NSManaged var product: Product?
    @NSManaged var productOfVariant: Product?
    
    var isSelected = false
    var selectedQuantity = 0
    var level = 0
}

extension ProductVariant: PersistencyOperation {
    
    public func setWithDictionary(_ dictionary: Dictionary<String, AnyObject>, position: Int) {
        
        if let idVal = dictionary["id"] as? Int {
            self.id = Int32(idVal)
        }
        
        if let qtyVal = dictionary["quantity"] as? Int {
            self.quantity = Int32(qtyVal)
        }
        
        if let previous_priceVal = dictionary["previous_price"] as? String {
            self.previous_price = previous_priceVal
        }
        
        if let minimum_stock_levelVal = dictionary["minimum_stock_level"] as? Int {
            self.minimum_stock_level = Int32(minimum_stock_levelVal)
        }
        
        if let priceVal = dictionary["price"] as? String {
            self.price = priceVal
        }
        
        if let value = dictionary["sku"] as? String {
            self.sku = value
        }
        
        if let value = dictionary["weight"] as? String {
            self.weight = value
        }
        
        if let value = dictionary["image_id"] as? String {
            self.image_id = value
        }
        
        if let value = dictionary["option1"] as? String {
            self.option1 = value
        }
        
        if let value = dictionary["option2"] as? String {
            self.option2 = value
        }
        
        if let value = dictionary["option3"] as? String {
            self.option3 = value
        }
        
        if let positionVal = dictionary["position"] as? Int {
            self.position = Int32(positionVal)
        } else {
            self.position = Int32(position)
        }
        
        insertedOn = Date().timeIntervalSinceNow
    }
}
