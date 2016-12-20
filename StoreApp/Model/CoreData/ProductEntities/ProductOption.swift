//
//  ProductOption.swift
//  StoreApp
//
//  Created by Abhilesh Halarnkar on 28/10/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import Foundation
import CoreData


class ProductOption: NSManagedObject {
    
    @NSManaged var id: Int32
    @NSManaged var name: String?
    @NSManaged var insertedOn: TimeInterval
    @NSManaged var product: Product?
    
}

extension ProductOption: PersistencyOperation {
    
    public func setWithDictionary(_ dictionary: Dictionary<String, AnyObject>, position: Int) {
        
        if let idVal = dictionary["id"] as? Int {
            self.id = Int32(idVal)
        }
        
        if let value = dictionary["name"] as? String {
            self.name = value
        }
        
        insertedOn = Date().timeIntervalSinceNow
        
    }
}

