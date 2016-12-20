//
//  JewelleryProduct.swift
//  StoreApp
//
//  Created by Abhilesh Halarnkar on 21/11/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import Foundation


class JewelleryProduct: NSObject {
    var id: String?
    var making_type: String?
    var making_charge: Double = 0
    var engrave_charge: Double = 0
    var discount: Double = 0
    var metal_options: Array<JewelleryOption>?
    var metal_sizes: Array<JewelleryOption>?
    var gem_options: Array<GemOption>?
    
    override init() {
        super.init()
    }
    
    init(dictionary: Dictionary<String, AnyObject>) {
        
        super.init()
        
        if let value = dictionary["id"] as? String {
            id = value
        }
        
        if let value = dictionary["making_type"] as? String {
            making_type = value
        }
        
        if let value = dictionary["making_charge"] as? Double {
            making_charge = value
        }
        
        if let value = dictionary["engrave_charge"] as? Double {
            engrave_charge = value
        }
        
        if let value = dictionary["discount"] as? Double {
            discount = value
        }
        
        if let value = dictionary["metal_options"] as? Array<JewelleryOption> {
            metal_options = value
        }
        
        if let value = dictionary["metal_sizes"] as? Array<JewelleryOption> {
            metal_sizes = value
        }
        
        if let value = dictionary["gem_options"] as? Array<GemOption> {
            gem_options = value
        }
    }
}
