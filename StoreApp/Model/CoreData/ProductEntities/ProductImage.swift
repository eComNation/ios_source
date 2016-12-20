//
//  ProductImage.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 23/04/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import Foundation
import CoreData


class ProductImage: NSManagedObject {

    @NSManaged var id: Int32
    @NSManaged var url: String?
    @NSManaged var insertedOn: TimeInterval
    @NSManaged var position: Int32
    @NSManaged var product: Product?

    var imageURL: URL? {
        if url != nil {
            return URL(string: imageMediumURLString!)
        }
        return nil
    }
    
    var imageURLString: String? {
        if url != nil {
            return "http:"+url!
        }
        return nil
    }
    
    var imageMediumURLString: String? {
        
        if let selectedColor = product?.selectedColor {
            print(ProductColor + "products/files/\((product?.id)!)/\(selectedColor)_medium.jpg")
            return ProductColor + "products/files/\((product?.id)!)/\(selectedColor)_medium.jpg"
        }
        
        if url != nil {
            var components = url!.components(separatedBy: "/")
            let lastComponent = components.last?.replacingOccurrences(of: ".", with: "_medium.")

            components.removeLast()
            components.append(lastComponent!)
            
            return "http:"+components.joined(separator: "/")
        }
        return nil
    }
}

extension ProductImage: PersistencyOperation {
    
    func setWithDictionary(_ dictionary: Dictionary<String, AnyObject>, position: Int) {
        
        if let idVal = dictionary["id"] as? Int {
            self.id = Int32(idVal)
        }
        
        if let urlVal = dictionary["url"] as? String {
            self.url = urlVal
        }
        
        if let positionVal = dictionary["position"] as? Int {
            self.position = Int32(positionVal)
        } else {
            self.position = Int32(position)
        }
        
        insertedOn = Date().timeIntervalSinceNow
    }
}
