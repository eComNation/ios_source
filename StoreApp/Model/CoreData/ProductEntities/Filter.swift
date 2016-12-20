//
//  Filter.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 05/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import Foundation
import CoreData


class Filter: NSManagedObject {

    @NSManaged var insertedOn: TimeInterval
    @NSManaged var position: Int32
    @NSManaged var value: String?
    @NSManaged var attribute_index: String?
    @NSManaged var filter: FilterGroup?

    var isSelected: Bool = false
}


extension Filter: PersistencyOperation {
    
    func setWithDictionary(_ dictionary: Dictionary<String, AnyObject>, position: Int) {
        
        if let valueVal = dictionary["value"] as? String {
            self.value = valueVal
        }
        
        if let attribute_indexVal = dictionary["attribute_index"] as? String {
            self.attribute_index = attribute_indexVal
        }
        
        if let positionVal = dictionary["position"] as? Int {
            self.position = Int32(positionVal)
        } else {
            self.position = Int32(position)
        }
        
        insertedOn = Date().timeIntervalSinceNow
    }
}
