//
//  Pincode.swift
//  Hiva
//
//  Created by Rakesh Pethani on 28/06/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import Foundation
import CoreData


class Pincode: NSManagedObject {

    @NSManaged var code: String?
    @NSManaged var isAvailable: Bool

}

extension Pincode: PersistencyOperation {
    
    func setWithDictionary(_ dictionary: Dictionary<String, AnyObject>, position: Int) {
        
        if let value = dictionary.keys.first {
            code = value
        }
        
        if let value = dictionary.values.first as? Bool {
            isAvailable = value
        }
    }
}
