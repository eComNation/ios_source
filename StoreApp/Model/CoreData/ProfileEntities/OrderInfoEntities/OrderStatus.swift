//
//  OrderStatus.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 17/05/16.
//  Copyright © 2016 Rakesh Pethani. All rights reserved.
//

import Foundation
import CoreData


open class OrderStatus: NSManagedObject {

    @NSManaged var id: Int32
    @NSManaged var name: String?
    @NSManaged var orderInfo: OrderInfo?
}


extension OrderStatus: PersistencyOperation {
    
    public func setWithDictionary(_ dictionary: Dictionary<String, AnyObject>, position: Int) {
        
        if let value = dictionary["id"] as? Int {
            self.id = Int32(value)
        }
        
        if let value = dictionary["name"] as? String {
            self.name = value
        }
    }
}
