//
//  RecentSearch.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 01/06/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import Foundation
import CoreData


class RecentSearch: NSManagedObject {

    @NSManaged var searchString: String?
    @NSManaged var insertedOn: TimeInterval
    @NSManaged var position: Int32

}

extension RecentSearch: PersistencyOperation {
    
    func setWithDictionary(_ dictionary: Dictionary<String, AnyObject>, position: Int) {
        
        if let value = dictionary["searchString"] as? String {
            self.searchString = value
        }
        
        if let positionVal = dictionary["position"] as? Int {
            self.position = Int32(positionVal)
        } else {
            self.position = Int32(position)
        }
        
        insertedOn = Date().timeIntervalSinceNow
    }
}
