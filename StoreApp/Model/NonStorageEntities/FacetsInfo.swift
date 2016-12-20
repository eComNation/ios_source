//
//  FacetsInfo.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 31/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

class FacetsInfo: NSObject {

    var min: Double = 0
    var max: Double = 0
    var attributes_index: [String:AnyObject] = [:]
    
    override init() {
        super.init()
    }
    
    init(dictionary: Dictionary<String, AnyObject>) {
        
        super.init()
        
        if let value = dictionary["min"] as? Double {
            min = value
        }
        
        if let value = dictionary["max"] as? Double {
            max = value
        }
        
        if let value = dictionary["attributes_index"] as? [String:AnyObject] {
            attributes_index = value
        }
    }
}
