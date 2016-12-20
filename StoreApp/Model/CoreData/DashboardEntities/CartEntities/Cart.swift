//
//  Cart.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 28/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import Foundation
import CoreData


open class Cart: NSManagedObject {

    @NSManaged var group_not_excluded: Bool
    @NSManaged var available_reward_points: Int32
    @NSManaged var discounted_cart_amount: Double
    @NSManaged var gift_card_amount: Double
    @NSManaged var reward_points: Int32
    @NSManaged var token: String?
    @NSManaged var discount_coupon_id: Int32
    @NSManaged var points_per_unit_amount: Int32
    @NSManaged var created_at: String?
    @NSManaged var updated_at: String?
    @NSManaged var items: NSSet?
    
    var isQuantityValidInAllOrderedItems: Bool {
        
        if let allOrderItems = items?.allObjects as? [OrderItem] {
            for orderItem in allOrderItems where orderItem.isQuantityValid == false {
                return false
            }
        }
       
        return true
    }
    
    var needsDiscountField: Bool {
        
        print(gift_card_amount)
        if hasDiscountCoupon && gift_card_amount > 0 {
            return false
        }
        
        return true
    }
    
    var hasDiscountCoupon: Bool {
        
        if discount_coupon_id > 0 {
            return true
        }
        return false
    }
    
    var discountCoupon: DiscountCoupon? {
        
        if discount_coupon_id > 0 {
            if let discountCoupon: DiscountCoupon = persistencyManager.fetchFirst("DiscountCoupon", predicate: NSPredicate(format: "SELF.id == %d", discount_coupon_id), sortDescriptors: nil) {
                return discountCoupon
            }
        }
        
        return nil
    }
    
    var discountCouponString: String {
        
        if let discountCpn = discountCoupon {
            return discountCpn.code!
        }
        
        return ""
    }
    
    var discountAmount: Double {        
        return subTotal - discounted_cart_amount
    }
    
    var rewardPointsAmount: Double {
        return Double(reward_points) * Double(points_per_unit_amount)
    }
    
    
    var subTotal: Double {
        var subtotal = 0.0
        
        if let allitems = items?.allObjects as? [OrderItem] {
            for orderitem in allitems {
                subtotal += Double(orderitem.actual_price!)!
            }
        }
        
        return subtotal
    }
    
    var itemsCount: Int {
        if let allitems = items {
            return allitems.count
        }
        return 0
    }
    
    var itemsCountString: String {
        if itemsCount > 0 {
            return String(itemsCount)
        }
        return ""
    }
}

extension Cart: PersistencyOperation {
    
    public func setWithDictionary(_ dictionary: Dictionary<String, AnyObject>, position: Int) {
        
        // General Info
        if let value = dictionary["group_not_excluded"] as? Bool {
            self.group_not_excluded = value
        }
        
        if let value = dictionary["available_reward_points"] as? Int {
            self.available_reward_points = Int32(value)
        } else {
            self.available_reward_points = 0
        }
        
        if let value = dictionary["discounted_cart_amount"] as? Double {
            self.discounted_cart_amount = value
        } else {
            self.discounted_cart_amount = 0.0
        }
        
        if let value = dictionary["gift_card_amount"] as? String {
            self.gift_card_amount = Double(value)!
        } else {
            self.gift_card_amount = 0.0
        }
        
        if let value = dictionary["reward_points"] as? Int {
            self.reward_points = Int32(value)
        } else {
            self.reward_points = 0
        }
        
        if let value = dictionary["token"] as? String {
            self.token = value
        }
        
        if let value = dictionary["discount_coupon_id"] as? Int {
            self.discount_coupon_id = Int32(value)
        } else {
            self.discount_coupon_id = 0
        }
        
        if let value = dictionary["points_per_unit_amount"] as? Int {
            self.points_per_unit_amount = Int32(value)
        } else {
            self.points_per_unit_amount = 0
        }
        
        // Creation related info
        if let value = dictionary["created_at"] as? String {
            self.created_at = value
        }
        
        if let value = dictionary["updated_at"] as? String {
            self.updated_at = value
        }
        
        if let itemsArray = dictionary["items"] as? [[String : AnyObject]] {
            self.items = NSSet(array: persistencyManager.prepare("OrderItem", entitiesArray: itemsArray))
        }
    }
}
