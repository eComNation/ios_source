//
//  State.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 25/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import Foundation
import CoreData


open class State: NSManagedObject {

    @NSManaged var id: Int32
    @NSManaged var name: String?
    @NSManaged var insertedOn: TimeInterval
    @NSManaged var position: Int32

}


extension State: PersistencyOperation {
    
    public func setWithDictionary(_ dictionary: Dictionary<String, AnyObject>, position: Int) {
        
        if let value = dictionary["id"] as? Int {
            self.id = Int32(value)
        }
        
        if let value = dictionary["name"] as? String {
            self.name = value
        } else {
            self.name = ""
        }
        
        if let positionVal = dictionary["position"] as? Int {
            self.position = Int32(positionVal)
        } else {
            self.position = Int32(position)
        }
        
        insertedOn = Date().timeIntervalSinceNow
    }
}
