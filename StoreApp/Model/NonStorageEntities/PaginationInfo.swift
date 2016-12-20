//
//  PaginationInfo.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 11/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

class PaginationInfo: NSObject {

    var currentPage: Int = 0
    var nextPage: Int = 0
    var previousPage: Int = 0
    var totalPages: Int = 0
    var totalEntries: Int = 0
    
    override init() {
        super.init()
    }
    
    init(dictionary: Dictionary<String, AnyObject>) {
        
        super.init()
        
        if let value = dictionary["current_page"] as? Int {
            currentPage = value
        }
        
        if let value = dictionary["next_page"] as? Int {
            nextPage = value
        }
        
        if let value = dictionary["previous_page"] as? Int {
            previousPage = value
        }
        
        if let value = dictionary["total_pages"] as? Int {
            totalPages = value
        }
        
        if let value = dictionary["total_entries"] as? Int {
            totalEntries = value
        }
    }
}
