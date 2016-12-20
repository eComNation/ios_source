//
//  Country.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 25/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import Foundation
import CoreData


open class Country: NSManagedObject {

    @NSManaged var id: Int32
    @NSManaged var name: String?
    @NSManaged var iso: String?
    @NSManaged var iso3: String?
    @NSManaged var insertedOn: TimeInterval
    @NSManaged var position: Int32

}

extension Country: PersistencyOperation {
    
    public func setWithDictionary(_ dictionary: Dictionary<String, AnyObject>, position: Int) {
        
        if let value = dictionary["id"] as? Int {
            self.id = Int32(value)
        }
        
        if let value = dictionary["name"] as? String {
            self.name = value
        } else {
            self.name = ""
        }
        
        if let value = dictionary["iso"] as? String {
            self.iso = value
        } else {
            self.iso = ""
        }
        
        if let value = dictionary["iso3"] as? String {
            self.iso3 = value
        } else {
            self.iso3 = ""
        }
        
        if let positionVal = dictionary["position"] as? Int {
            self.position = Int32(positionVal)
        } else {
            self.position = Int32(position)
        }
        
        insertedOn = Date().timeIntervalSinceNow
    }
}
