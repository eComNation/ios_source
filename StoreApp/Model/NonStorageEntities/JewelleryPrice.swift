//
//  JewelleryPrice.swift
//  StoreApp
//
//  Created by Abhilesh Halarnkar on 21/11/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import Foundation


class JewelleryPrice: NSObject {
    var total: Double = 0
    var engrave_charge: Double = 0
    var making_charge: Double = 0
    var metal: JewelleryOption?
    var gem_options: Array<GemOption>?
    
    override init() {
        super.init()
    }
    
    init(dictionary: Dictionary<String, AnyObject>) {
        
        super.init()
        
        if let value = dictionary["total"] as? Double {
            total = value
        }
        
        if let value = dictionary["metal"] as? JewelleryOption {
            metal = value
        }
        
        if let value = dictionary["making_charge"] as? Double {
            making_charge = value
        }
        
        if let value = dictionary["engrave_charge"] as? Double {
            engrave_charge = value
        }
        
        if let value = dictionary["gem_options"] as? Array<GemOption> {
            gem_options = value
        }
    }
}
