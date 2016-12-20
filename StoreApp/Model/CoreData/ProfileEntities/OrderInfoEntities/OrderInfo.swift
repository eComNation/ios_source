//
//  OrderInfo.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 17/05/16.
//  Copyright © 2016 Rakesh Pethani. All rights reserved.
//

import Foundation
import CoreData


open class OrderInfo: NSManagedObject {

    // General Info
    @NSManaged var id: Int32
    @NSManaged var number: String?
    @NSManaged var order_process_status_id: Int32
    @NSManaged var total_items: Int32
    @NSManaged var is_viewed: Bool
    
    // Creation related info
    @NSManaged var created_at: String?
    @NSManaged var updated_at: String?
    @NSManaged var insertedOn: TimeInterval
    @NSManaged var position: Int32
    
    // Pricing properties
    @NSManaged var actual_amount: String?
    @NSManaged var grand_total: String?
    @NSManaged var discount: String?
    @NSManaged var discounted_amount: String?
    @NSManaged var sub_total: String?
    @NSManaged var tax_amount: String?
    
    // Sub entities
    @NSManaged var order_status: OrderStatus?
    @NSManaged var billing_address: Address?
    @NSManaged var shipping_address: Address?
    @NSManaged var order_line_items: NSSet?
}

extension OrderInfo: PersistencyOperation {
    
    public func setWithDictionary(_ dictionary: Dictionary<String, AnyObject>, position: Int) {
        
        // General Info
        if let value = dictionary["id"] as? Int {
            self.id = Int32(value)
        }
        
        if let value = dictionary["number"] as? String {
            self.number = value
        }
        
        if let value = dictionary["order_process_status_id"] as? Int {
            self.order_process_status_id = Int32(value)
        }
        
        if let value = dictionary["total_items"] as? Int {
            self.total_items = Int32(value)
        }
        
        if let value = dictionary["is_viewed"] as? Bool {
            self.is_viewed = value
        }
        
        // Creation related info
        if let value = dictionary["created_at"] as? String {
            self.created_at = value
        }
        
        if let value = dictionary["updated_at"] as? String {
            self.updated_at = value
        }

        insertedOn = Date().timeIntervalSinceNow
        
        if let positionVal = dictionary["position"] as? Int {
            self.position = Int32(positionVal)
        } else {
            self.position = Int32(position)
        }
        
        
        // Pricing properties
        if let value = dictionary["actual_amount"] as? String {
            self.actual_amount = value
        }
        
        if let value = dictionary["grand_total"] as? String {
            self.grand_total = value
        }
        
        if let value = dictionary["discount"] as? String {
            self.discount = value
        }
        
        if let value = dictionary["discounted_amount"] as? String {
            self.discounted_amount = value
        }
        
        if let value = dictionary["sub_total"] as? String {
            self.sub_total = value
        }
        
        if let value = dictionary["tax_amount"] as? String {
            self.tax_amount = value
        }
        
        
        // Sub entities
        if let orderStatusDict = dictionary["order_status"] as? [String : AnyObject] {
            self.order_status = persistencyManager.prepare("OrderStatus", entityData: orderStatusDict) as? OrderStatus
        }
        
        if let addressDict = dictionary["billing_address"] as? [String : AnyObject] {
            self.billing_address = persistencyManager.prepare("Address", entityData: addressDict) as? Address
        }
        
        if let addressDict = dictionary["shipping_address"] as? [String : AnyObject] {
            self.shipping_address = persistencyManager.prepare("Address", entityData: addressDict) as? Address
        }
        
        if let itemsArray = dictionary["order_line_items"] as? [[String : AnyObject]] {
            self.order_line_items = NSSet(array: persistencyManager.prepare("OrderItem", entitiesArray: itemsArray))
        }
    }
}
