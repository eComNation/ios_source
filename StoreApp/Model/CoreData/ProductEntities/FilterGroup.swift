//
//  FilterGroup.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 05/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import Foundation
import CoreData


class FilterGroup: NSManagedObject {

    @NSManaged var name: String?
    @NSManaged var insertedOn: TimeInterval
    @NSManaged var position: Int32
    @NSManaged var values: NSSet?

    var isExpanded: Bool = false
}

extension FilterGroup: PersistencyOperation {
    
    func toggleExpansation() {
        isExpanded = !isExpanded
    }
    
    func setWithDictionary(_ dictionary: Dictionary<String, AnyObject>, position: Int) {
        
        if let nameVal = dictionary["name"] as? String {
            self.name = nameVal
        }
        
        if let filtersArray = dictionary["values"] as? [[String : AnyObject]] {
            self.values = NSSet(array: persistencyManager.prepare("Filter", entitiesArray: filtersArray))
        }
        
        if let positionVal = dictionary["position"] as? Int {
            self.position = Int32(positionVal)
        } else {
            self.position = Int32(position)
        }
        
        insertedOn = Date().timeIntervalSinceNow
    }
}
