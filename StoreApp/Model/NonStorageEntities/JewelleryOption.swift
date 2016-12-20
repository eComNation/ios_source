//
//  JewelleryOption.swift
//  StoreApp
//
//  Created by Abhilesh Halarnkar on 21/11/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import Foundation

class JewelleryOption: NSObject {
    var id: String?
    var name: String?
    var type: String?
    var shape: String?
    var clarity: String?
    var color: String?
    var carat: Double = 0
    var rate: Double = 0
    var size: String?
    var price: Double = 0
    var per_gm_rate: Double = 0
    var weight: Double = 0
    var is_default: Bool?
    
    override init() {
        super.init()
    }
    
    init(idValue: String, nameValue: String) {
        self.id = idValue
        self.name = nameValue
    }
    
    init(dictionary: Dictionary<String, AnyObject>) {
        
        super.init()
        
        if let value = dictionary["id"] as? String {
            id = value
        }
        
        if let value = dictionary["name"] as? String {
            name = value
        }
        
        if let value = dictionary["type"] as? String {
            type = value
        }
        
        if let value = dictionary["shape"] as? String {
            shape = value
        }
        
        if let value = dictionary["clarity"] as? String {
            clarity = value
        }
        
        if let value = dictionary["color"] as? String {
            color = value
        }
        
        if let value = dictionary["carat"] as? Double {
            carat = value
        }
        
        if let value = dictionary["rate"] as? Double {
            rate = value
        }
        
        if let value = dictionary["size"] as? String {
            size = value
        }
        
        if let value = dictionary["price"] as? Double {
            price = value
        }
        
        if let value = dictionary["per_gm_rate"] as? Double {
            per_gm_rate = value
        }
        
        if let value = dictionary["weight"] as? Double {
            weight = value
        }
        
        if let value = dictionary["is_default"] as? Bool {
            is_default = value
        }
    }
}
