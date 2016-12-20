//
//  Address.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 17/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import Foundation
import CoreData
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}



open class Address: NSManagedObject {

    @NSManaged var id: Int32
    @NSManaged var address1: String?
    @NSManaged var country_id: Int32
    @NSManaged var state_id: Int32
    @NSManaged var country_name: String?
    @NSManaged var address2: String?
    @NSManaged var phone: String?
    @NSManaged var zipcode: String?
    @NSManaged var state_name: String?
    @NSManaged var first_name: String?
    @NSManaged var city: String?
    @NSManaged var last_name: String?
    @NSManaged var insertedOn: TimeInterval
    @NSManaged var position: Int32
    @NSManaged var orderInfoBilling: OrderInfo?
    @NSManaged var orderInfoShipping: OrderInfo?
    
    var fullName: String {
        return (first_name?.capitalized)! + " " + (last_name?.capitalized)!
    }
    
    var phoneNumber: String {
        return phone!
    }
    
    var fullAddress: String {
        var addressString = ""
        
        if address1?.characters.count > 0 {
            addressString += address1!
        }
        
        if address2?.characters.count > 0 {
            addressString += ", " + address2!
        }
        
        if city?.characters.count > 0 {
            addressString += ", " + city!
        }
        
        if state_name?.characters.count > 0 {
            addressString += ", " + state_name!
        }
        
        if zipcode?.characters.count > 0 {
            addressString += ", " + zipcode!
        }
        
        if country_name?.characters.count > 0 {
            addressString += ", " + country_name!
        }
        
        return addressString
    }
}


extension Address: PersistencyOperation {
    
    public func setWithDictionary(_ dictionary: Dictionary<String, AnyObject>, position: Int) {
        
        if let value = dictionary["id"] as? Int {
            self.id = Int32(value)
        }
        
        if let value = dictionary["address1"] as? String {
            self.address1 = value
        }
        
        if let value = dictionary["country_id"] as? Int {
            self.country_id = Int32(value)
        }
        
        if let value = dictionary["state_id"] as? Int {
            self.state_id = Int32(value)
        }
        
        if let value = dictionary["country_name"] as? String {
            self.country_name = value
        }
        
        if let value = dictionary["address2"] as? String {
            self.address2 = value
        }
        
        if let value = dictionary["phone"] as? String {
            self.phone = value
        } else {
            self.phone = ""
        }
        
        if let value = dictionary["zipcode"] as? String {
            self.zipcode = value
        }
        
        if let value = dictionary["state_name"] as? String {
            self.state_name = value
        }
        
        if let value = dictionary["first_name"] as? String {
            self.first_name = value
        } else {
            self.first_name = ""
        }
        
        if let value = dictionary["city"] as? String {
            self.city = value
        }
        
        if let value = dictionary["last_name"] as? String {
            self.last_name = value
        } else {
            self.last_name = ""
        }
        
        if let positionVal = dictionary["position"] as? Int {
            self.position = Int32(positionVal)
        } else {
            self.position = Int32(position)
        }
        
        insertedOn = Date().timeIntervalSinceNow
    }
}
