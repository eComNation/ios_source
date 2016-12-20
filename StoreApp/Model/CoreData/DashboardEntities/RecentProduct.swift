//
//  RecentProduct.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 01/06/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import Foundation
import CoreData


class RecentProduct: NSManagedObject {

    @NSManaged var id: Int32
    @NSManaged var insertedOn: TimeInterval
    @NSManaged var position: Int32

}

extension RecentProduct: PersistencyOperation {
    
    func setWithDictionary(_ dictionary: Dictionary<String, AnyObject>, position: Int) {
        
        if let value = dictionary["id"] as? Int {
            self.id = Int32(value)
        }
        
        if let value = dictionary["position"] as? Int {
            self.position = Int32(value)
        } else {
            self.position = Int32(position)
        }
        
        insertedOn = Date().timeIntervalSinceNow
    }
}
