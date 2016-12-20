//
//  DiscountCoupon.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 30/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import Foundation
import CoreData


open class DiscountCoupon: NSManagedObject {

    @NSManaged var id: Int32
    @NSManaged var title: String?
    @NSManaged var code: String?
    @NSManaged var expires_on: String?
    @NSManaged var product_sku: String?
    
    @NSManaged var created_at: String?
    @NSManaged var updated_at: String?
    @NSManaged var insertedOn: TimeInterval
    @NSManaged var position: Int32

    @NSManaged var percentage: Float
    @NSManaged var product_category: Int32
    @NSManaged var store_id: Int32
    @NSManaged var purchase_limit: Double
    @NSManaged var flat_rate: Double

}

extension DiscountCoupon: PersistencyOperation {
    
    public func setWithDictionary(_ dictionary: Dictionary<String, AnyObject>, position: Int) {
        
        // General Info
        if let value = dictionary["id"] as? Int {
            self.id = Int32(value)
        }
        
        if let value = dictionary["title"] as? String {
            self.title = value
        }
        
        if let value = dictionary["code"] as? String {
            self.code = value
        }
        
        if let value = dictionary["expires_on"] as? String {
            self.expires_on = value
        }
        
        if let value = dictionary["product_sku"] as? String {
            self.product_sku = value
        }
        
        // Creation related info
        if let value = dictionary["created_at"] as? String {
            self.created_at = value
        }
        
        if let value = dictionary["updated_at"] as? String {
            self.updated_at = value
        }
        
        if let positionVal = dictionary["position"] as? Int {
            self.position = Int32(positionVal)
        } else {
            self.position = Int32(position)
        }
        
        insertedOn = Date().timeIntervalSinceNow
        
        // Pricing related info
        if let value = dictionary["percentage"] as? Float {
            self.percentage = value
        }
        
        if let value = dictionary["product_category"] as? Int {
            self.product_category = Int32(value)
        }
        
        if let value = dictionary["store_id"] as? Int {
            self.store_id = Int32(value)
        }
        
        if let value = dictionary["purchase_limit"] as? Double {
            self.purchase_limit = value
        }
        
        if let value = dictionary["flat_rate"] as? Double {
            self.flat_rate = value
        }
    }
}
