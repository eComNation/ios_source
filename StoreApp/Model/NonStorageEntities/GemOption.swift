//
//  GemOption.swift
//  StoreApp
//
//  Created by Abhilesh Halarnkar on 21/11/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import Foundation

class GemOption: NSObject {
    var id: String?
    var name: String?
    var nod: Int?
    var number_of_gems: Int?
    var value: JewelleryOption?
    var values: Array<JewelleryOption>?
    
    override init() {
        super.init()
    }
    
    init(dictionary: Dictionary<String, AnyObject>) {
        super.init()
        
        if let value = dictionary["id"] as? String {
            self.id = value
        }
        
        if let value = dictionary["name"] as? String {
            self.name = value
        }
        
        if let value = dictionary["nod"] as? Int {
            self.nod = value
        }
        
        if let value = dictionary["number_of_gems"] as? Int {
            self.number_of_gems = value
        }
        
        if let value = dictionary["value"] as? JewelleryOption {
            self.value = value
        }
        
        if let value = dictionary["values"] as? Array<JewelleryOption> {
            self.values = value
        }
    }
}
