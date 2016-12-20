//
//  Banner.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 10/04/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import Foundation
import CoreData


class Banner: NSManagedObject {

    @NSManaged var id: Int32
    @NSManaged var position: Int32
    @NSManaged var category_id: Int32
    @NSManaged var url: String?
    @NSManaged var insertedOn: TimeInterval
    @NSManaged var is_list: Bool
    @NSManaged var bannerHeight: Float
    @NSManaged var dimensions: String
    
    var heightByWidth: Float {
        if dimensions.isNotEmpty {
            var index = dimensions.index(of: "x")
            let width = Float(dimensions.substring(to: index!))
            print(width ?? 0)
            index = dimensions.index(after: index!)
            let height = Float(dimensions.substring(from: index!))
            print(height ?? 0)
            return height!/width!
        }
        return 0
    }
    
    var bannerURL: URL? {
        if url != nil {
            return URL(string: "http:"+url!)
        }
        return nil
    }
}

extension Banner: PersistencyOperation {
    
    func setWithDictionary(_ dictionary: Dictionary<String, AnyObject>, position: Int) {
        
        if let idVal = dictionary["id"] as? Int {
            self.id = Int32(idVal)
        }
        
        if let positionVal = dictionary["position"] as? Int {
            self.position = Int32(positionVal)
        } else {
            self.position = Int32(position)
        }
        
        if let category_idVal = dictionary["category_id"] as? Int {
            self.category_id = Int32(category_idVal)
        }
        
        if let urlVal = dictionary["url"] as? String {
            self.url = urlVal
        }
        
        if let value = dictionary["is_list"] as? Bool {
            self.is_list = value
        } else {
            self.is_list = false
        }
        
        if let value = dictionary["dimensions"] as? String {
            self.dimensions = value
        }
        
        insertedOn = Date().timeIntervalSinceNow
    }
}
 
