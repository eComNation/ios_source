//
//  Utility.swift
//  StoreApp
//
//  Created by Abhilesh Halarnkar on 19/10/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import Foundation
import Kanna



let utility = Utility.sharedUtility

open class Utility: NSObject {
    
    // MARK: Properties
    /// Singleton instance of `NetworkManager`
    open static let sharedUtility = Utility()
    
    
    let JEWELLERY = "jewellery";
    let MARKET_PLACE = "market_place";
    
    let ADDWIK = "addwik";
    let ABJEWELS = "5668";
    let HIVA = "5504";
    let STORYATHOME = "5680";
    let OUTLETSINDIA = "5684";
    let TIMBERFRUIT = "timberfruit";
    let VIRANI = "5644";
    let SURPLUSNATION = "surplusnation";
    let KIWIENGLAND = "5688";
    let MYGARMENTACCESSORIES = "5678";
    
    func getDetailsController() -> BaseDetailController {
        switch StoreId {
            
        case TIMBERFRUIT:
            return UIStoryboard.timberfruitDetailController()! as BaseDetailController
            
        case OUTLETSINDIA:
            return UIStoryboard.outletsDetailController()! as BaseDetailController
            
        case STORYATHOME:
            return UIStoryboard.storyAtHomeDetailController()! as BaseDetailController
            
        case ABJEWELS:
            return UIStoryboard.abJewelsDetailController()! as BaseDetailController
            
        case MYGARMENTACCESSORIES:
            return UIStoryboard.myGarmentsDetailController()! as BaseDetailController

        default:
            return UIStoryboard.productDetailController()! as BaseDetailController

        }
    }
    
    func getHTMLText(html: String, id: String) -> String {
        if let doc = HTML(html: html, encoding: .utf8) {
            
            if let element = doc.at_xpath("//*[@id='\(id)']") {
                return (element.text?.trim())!
            }
        }
        
        return "Not available"
    }
    
    func checkQuantity(product: Product) -> Int {
        if product.track_quantity {
            let variants = product.variants?.allObjects as! [ProductVariant]
            if !variants.isEmpty {
                var totalQuantity = 0
                var totalMinStockLevel = 0
                for variant in variants {
                    totalQuantity += Int(variant.quantity)
                    totalMinStockLevel += Int(variant.minimum_stock_level)
                }
                return totalQuantity - totalMinStockLevel
            } else {
                return product.quantity - product.minimum_stock_level
            }
        }
        return 1
    }
}
