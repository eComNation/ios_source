//
//  FavouriteProduct.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 15/06/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import Foundation
import CoreData


class FavouriteProduct: NSManagedObject {

    @NSManaged var id: Int32
    @NSManaged var insertedOn: TimeInterval
    @NSManaged var name: String?
    @NSManaged var position: Int32
    @NSManaged var price: String?
    @NSManaged var image_url: String?
    @NSManaged var category: String?

    var currentPrice: String {
        if let priceValue = price {
            return priceValue
        }
        
        return "0.0"
    }
    
    var productImageURL: URL? {
        if image_url != nil {
            return URL(string: image_url!)
        }
        return nil
    }
    
    var productThumbImageURL: URL? {
        if image_url != nil {
            return URL(string: image_url!.replace(target: "list", withString: "thumb"))
        }
        return nil
    }
}

extension FavouriteProduct: PersistencyOperation {
    
    func setWithDictionary(_ dictionary: Dictionary<String, AnyObject>, position: Int) {
        
        if let value = dictionary["id"] as? Int {
            self.id = Int32(value)
        }
        
        if let value = dictionary["name"] as? String {
            self.name = value
        } else {
            self.name = ""
        }
        
        if let value = dictionary["price"] as? String {
            self.price = value
        } else {
            self.price = ""
        }
        
        if let value = dictionary["image_url"] as? String {
            self.image_url = value
        } else {
            self.image_url = ""
        }
        
        if let value = dictionary["category"] as? String {
            self.category = value
        } else {
            self.category = ""
        }
        
        if let positionVal = dictionary["position"] as? Int {
            self.position = Int32(positionVal)
        } else {
            self.position = Int32(position)
        }
        
        insertedOn = Date().timeIntervalSinceNow
    }
}
