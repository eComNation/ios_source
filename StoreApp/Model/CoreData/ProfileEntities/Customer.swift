//
//  Customer.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 15/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import Foundation
import CoreData


open class Customer: NSManagedObject {

    @NSManaged var refresh_token: String?
    @NSManaged var access_token: String?
    @NSManaged var created_at: String?
    @NSManaged var expires_in: Double
    @NSManaged var email: String?
    @NSManaged var phone: String?
    @NSManaged var last_name: String?
    @NSManaged var first_name: String?
}


extension Customer: PersistencyOperation {
    
    public func setWithDictionary(_ dictionary: Dictionary<String, AnyObject>, position: Int) {
        
        if let value = dictionary["refresh_token"] as? String {
            self.refresh_token = value
        }
        
        if let value = dictionary["access_token"] as? String {
            self.access_token = value
        }
        
        if let value = dictionary["created_at"] as? String {
            self.created_at = value
        }
        
        if let value = dictionary["expires_in"] as? Double {
            self.expires_in = value
        }
        
        if let profileDict = dictionary["customer"] as? [String : AnyObject] {
            if let value = profileDict["email"] as? String {
                self.email = value
            }
            
            if let value = profileDict["phone"] as? String {
                self.phone = value
            }
            
            if let value = profileDict["last_name"] as? String {
                self.last_name = value
            }
            
            if let value = profileDict["first_name"] as? String {
                self.first_name = value
            }
        }
    }
}
