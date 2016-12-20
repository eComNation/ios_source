//
//  Category.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 10/04/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import Foundation
import CoreData


class Category: NSManagedObject  {

    @NSManaged var id: Int32
    @NSManaged var name: String?
    @NSManaged var image_url: String?
    @NSManaged var parent_id: Int32
    @NSManaged var position: Int32
    @NSManaged var insertedOn: TimeInterval
    
    var imageUrl: URL? {
        if image_url != nil {
            return URL(string: image_url!)
        }
        return nil
    }
}

extension Category: PersistencyOperation {
    
    func setWithDictionary(_ dictionary: Dictionary<String, AnyObject>, position: Int) {
        if let idVal = dictionary["id"] as? Int {
            self.id = Int32(idVal)
        }
        
        if let nameVal = dictionary["name"] as? String {
            self.name = nameVal
        }
        
        if let value = dictionary["image_url"] as? String {
            self.image_url = value
        }
        
        if let parent_idVal = dictionary["parent_id"] as? Int {
            self.parent_id = Int32(parent_idVal)
        }
        
        if let positionVal = dictionary["position"] as? Int {
            self.position = Int32(positionVal)
        } else {
            self.position = Int32(position)
        }
        
        insertedOn = Date().timeIntervalSinceNow
    }
}
