//
//  ProductFilterAttribute.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 11/06/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import Foundation
import CoreData


class ProductFilterAttribute: NSManagedObject {

    @NSManaged var insertedOn: TimeInterval
    @NSManaged var name: String?
    @NSManaged var position: Int32
    @NSManaged var values: NSArray?
    @NSManaged var product: Product?
    
}

extension ProductFilterAttribute: PersistencyOperation {
    
    func setWithDictionary(_ dictionary: Dictionary<String, AnyObject>, position: Int) {
        
        if let value = dictionary["name"] as? String {
            self.name = value
        }
        
        if let value = dictionary["values"] as? NSArray {
            self.values = value
        }
        
        if let value = dictionary["position"] as? Int {
            self.position = Int32(value)
        } else {
            self.position = Int32(position)
        }
        
        insertedOn = Date().timeIntervalSinceNow       
    }
}
