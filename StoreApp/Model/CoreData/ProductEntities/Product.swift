//
//  Product.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 11/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import Foundation
import CoreData
import UIKit
import SKPhotoBrowser
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


class Product: NSManagedObject {

    @NSManaged var category_id: Int32
    @NSManaged var created_at: TimeInterval
    @NSManaged var id: Int32
    @NSManaged var insertedOn: TimeInterval
    @NSManaged var minimum_stock_level: Int32
    @NSManaged var name: String?
    @NSManaged var desc: String?
    @NSManaged var detailed_description: String?
    @NSManaged var position: Int32
    @NSManaged var previous_price: String?
    @NSManaged var price: String?
    @NSManaged var product_image_url: String?
    @NSManaged var image_url: String?
    @NSManaged var permalink: String?
    @NSManaged var quantity: Int32
    @NSManaged var track_quantity: Bool
    @NSManaged var url: String?
    @NSManaged var isFeatured: Bool
    @NSManaged var isRelated: Bool
    @NSManaged var isRecent: Bool
    @NSManaged var isSimilar: Bool
    
    @NSManaged var custom_attributes: Array<String>?
    
    @NSManaged var relatedProducts: NSSet?
    @NSManaged var options: NSSet?
    @NSManaged var variants: NSSet?
    @NSManaged var images: NSSet?
    @NSManaged var filter_attributes: NSSet?
    @NSManaged var default_variant: ProductVariant?

    var selectedColor: String?
    
    var autoScrollTimer: Timer?
    var selectedVariant : ProductVariant?
    var currentImage: Int = 0
    var listenForImageChange: ((URL) -> ())?
    
    var detailsCount: Int {
        var count = 0
        
        if let filterAttributes = filter_attributes?.allObjects as? [ProductFilterAttribute] {
            for filterAttribute in filterAttributes where filterAttribute.values?.count > 0 {
                count += 1
            }
        }
        
        return count
    }
    
    var detailsArray: [ProductFilterAttribute]? {
        
        if let filterAttributes = filter_attributes?.allObjects as? [ProductFilterAttribute] {
            return filterAttributes.filter({ $0.values?.count > 0 }).sorted(by: { $0.0.position < $0.1.position })
        }
        
        return nil
    }
    
    var productURL: URL? {
        if url != nil {
            return URL(string: "http:"+url!)
        }
        return nil
    }
    
    
    var productImageURL: URL? {
        if product_image_url != nil {
            return URL(string: "http:"+product_image_url!)
        }
        if image_url != nil {
            return URL(string: image_url!)
        }
        return nil
    }
    
    var productThumbImageURL: URL? {
        if product_image_url != nil {
            return URL(string: "http:"+product_image_url!.replace(target: "list", withString: "thumb"))
        }
        return nil
    }
    
    var isOnSale: Bool {
        return Double(currentPrice) < Double(previousPrice)
    }
    
    var percentageString: String {
        return String(Int((Double(previousPrice)! - Double(currentPrice)!) / Double(previousPrice)! * 100)) + "% OFF"
    }
    
    var isAnyVariantSelected: Bool {
        for variant in variants?.allObjects as! [ProductVariant] {
            if variant.isSelected && variant.selectedQuantity > 0 {
                return true
            }
        }
        return false
    }
    
    // MARK: Price related changes
    var currentVariantPrice: String {
        if let priceValue = selectedVariant?.price {
            return priceValue
        }
        
        return "0.0"
    }
    
    var currentPrice: String {
        if let priceValue = price {
            return priceValue
        }
        
        return "0.0"
    }
    
    var priceWithVariants: String {
        
        var totalPrice = 0.0
        for variant in variants?.allObjects as! [ProductVariant] {
            if variant.isSelected {
                if let price = variant.price {
                    totalPrice += Double(price)! * Double(variant.selectedQuantity)
                }
            }
        }
        
        return String(format: "%.2f", totalPrice)
    }
    
    var previousPrice: String {
        if let priceValue = previous_price {
            return priceValue
        }
        
        return "0.0"
    }
    
    var previousVariantPrice: String {
        if let priceValue = selectedVariant?.previous_price {
            return priceValue
        }
        
        return "0.0"
    }
    
    var smallPriceString: NSAttributedString {
        
        let previousPriceFullString = previousPrice.formattedWithCurrency
        let currentPriceFullString = currentPrice.formattedWithCurrency
        
        if Double(currentPrice) < Double(previousPrice) {
            
            //let percentage = String(Int((Double(previousPrice)! - Double(currentPrice)!) / Double(previousPrice)! * 100)) + "% OFF"
            
            let currentPriceAttribute = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 13), NSForegroundColorAttributeName: UIColor.black]
            let priceString = NSMutableAttributedString(string: currentPriceFullString, attributes: currentPriceAttribute)
            
            // For previous price
            let previousPriceString = NSAttributedString(string: "  \(previousPriceFullString)")
            priceString.append(previousPriceString)
            
            let previousPriceRange = NSRange(location: currentPriceFullString.characters.count + 2, length: previousPriceFullString.characters.count)
            priceString.addAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 11), NSForegroundColorAttributeName: UIColor.lightGray, NSStrikethroughStyleAttributeName: NSNumber(value: NSUnderlineStyle.styleSingle.rawValue as Int)], range: previousPriceRange)
            
            // For percentage
            /*let precentageString = NSAttributedString(string: "  \(percentage)")
            priceString.append(precentageString)
            
            let percentageRange = NSRange(location: currentPriceFullString.characters.count + 2 + previousPriceFullString.characters.count + 2, length: percentage.characters.count)
            priceString.addAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 9), NSForegroundColorAttributeName: UIColor.red], range: percentageRange)*/
            
            return priceString
        }
        
        return NSAttributedString(string: "")
    }
    
    var mediumPriceString: NSAttributedString {
        
        let previousPriceFullString = previousPrice.formattedWithCurrency
        let currentPriceFullString = currentPrice.formattedWithCurrency
        
        if Double(currentPrice) < Double(previousPrice) {
            
            let percentage = String(Int((Double(previousPrice)! - Double(currentPrice)!) / Double(previousPrice)! * 100)) + "% OFF"
            
            let currentPriceAttribute = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 15), NSForegroundColorAttributeName: UIColor.black]
            let priceString = NSMutableAttributedString(string: currentPriceFullString, attributes: currentPriceAttribute)
            
            // For previous price
            let previousPriceString = NSAttributedString(string: "  \(previousPriceFullString)")
            priceString.append(previousPriceString)
            
            let previousPriceRange = NSRange(location: currentPriceFullString.characters.count + 2, length: previousPriceFullString.characters.count)
            priceString.addAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 13), NSForegroundColorAttributeName: UIColor.lightGray, NSStrikethroughStyleAttributeName: NSNumber(value: NSUnderlineStyle.styleSingle.rawValue as Int)], range: previousPriceRange)
            
            // For percentage
            let precentageString = NSAttributedString(string: "  \(percentage)")
            priceString.append(precentageString)
            
            let percentageRange = NSRange(location: currentPriceFullString.characters.count + 2 + previousPriceFullString.characters.count + 2, length: percentage.characters.count)
            priceString.addAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 11), NSForegroundColorAttributeName: UIColor.red], range: percentageRange)
            
            return priceString
        }
        
        return NSAttributedString(string: "")
    }
    
    var bigPriceString: NSAttributedString {
        
        let previousPriceFullString = previousVariantPrice.formattedWithCurrency
        let currentPriceFullString = currentVariantPrice.formattedWithCurrency
        
        if Double(currentVariantPrice) < Double(previousVariantPrice) {
            
            let percentage = String(Int((Double(previousVariantPrice)! - Double(currentVariantPrice)!) / Double(previousVariantPrice)! * 100)) + "% OFF"
            
            let currentPriceAttribute = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16), NSForegroundColorAttributeName: UIColor.black]
            let priceString = NSMutableAttributedString(string: currentPriceFullString, attributes: currentPriceAttribute)
            
            // For previous price
            let previousPriceString = NSAttributedString(string: "  \(previousPriceFullString)")
            priceString.append(previousPriceString)
            
            let previousPriceRange = NSRange(location: currentPriceFullString.characters.count + 2, length: previousPriceFullString.characters.count)
            priceString.addAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.lightGray, NSStrikethroughStyleAttributeName: NSNumber(value: NSUnderlineStyle.styleSingle.rawValue as Int)], range: previousPriceRange)
            
            // For percentage
            let precentageString = NSAttributedString(string: "  \(percentage)")
            priceString.append(precentageString)
            
            let percentageRange = NSRange(location: currentPriceFullString.characters.count + 2 + previousPriceFullString.characters.count + 2, length: percentage.characters.count)
            priceString.addAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 12), NSForegroundColorAttributeName: UIColor.red], range: percentageRange)
            
            return priceString
        }
        
        return NSAttributedString(string: currentPriceFullString)
    }
    
    // MARK: Varian operations
    var variantDictionary: [String: [ProductVariant]] {
        
        var dictionary: [String: [ProductVariant]] = [:]

        for productVariant in variants?.allObjects as! [ProductVariant] {            
            if let option = productVariant.option1 {
                if var variantArray = dictionary[option] {
                    variantArray.append(productVariant)
                    dictionary[option] = variantArray
                } else {
                    dictionary[option] = [productVariant]
                }
            }
        }
        
        var sortedDict: [String: [ProductVariant]] = [:]
        for (key, value) in dictionary.sorted(by: { $0.0 < $1.0 }) {
            sortedDict[key] = value
        }
        
        return sortedDict
    }

    var variantHash: [String : ProductVariant] {
        var hash : [String : ProductVariant] = [:]
        var options : String = ""
        for variant in variants?.allObjects as! [ProductVariant] {
            
            if variant.option1 != nil {
                options += "," + variant.option1!
            }
            
            if variant.option2 != nil {
                options += "," + variant.option2!
            }
            
            if variant.option3 != nil {
                options += "," + variant.option3!
            }
            
            if options.isNotEmpty {
                hash[options.uppercased()] = variant
            }
            options = ""
        }
        return hash
    }
    
    var optionDictionary: [String : [String]] {
        var dictionary: [String: [String]] = [:]
        var count = 1
        
        for productOption in options?.allObjects as! [ProductOption] {
            var values : [String] = []
            
            for variant in variants?.allObjects as! [ProductVariant] {
                var option : String?
                switch(count)
                {
                case 1:
                    option = variant.option1
                    break
                case 2:
                    option = variant.option2
                    break
                case 3:
                    option = variant.option3
                    break
                default:
                    break
                }
                
                if option != nil && (option?.isNotEmpty)! {
                    if !values.contains(option!) {
                        values.append(option!)
                    }
                }
                
            }
            
            dictionary[(productOption.name?.uppercased())!] = values.sorted()
            
            count += 1
        }
        
        return dictionary
    }
    
    // MARK: Image operations
    var skPhotos: [SKPhoto] {
        var imageUrls = [SKPhoto]()
        
        for productImage in (images?.allObjects as! [ProductImage]).sorted(by: { return $0.id > $1.id }) {
            if let imageURLString = productImage.imageURLString {
                let photo = SKPhoto.photoWithImageURL(imageURLString)
                photo.shouldCachePhotoURLImage = true
                photo.caption = name
                imageUrls.append(photo)
            }
        }
        
        return imageUrls
    }
    
    var allImagesURL: [URL]? {
        let urls = (images?.allObjects as! [ProductImage]).sorted(by: { return $0.position < $1.position }).map({ $0.imageURL }).filter({ $0 != nil }).map { return ($0! as URL) }
        return urls
    }
    
    func startImageTimer() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
        autoScrollTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(goToNextPage), userInfo: nil, repeats: true)
    }
    
    func stopImageTimer() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }
    
    func getCurrentImageURL() -> URL? {
        
        guard currentImage < images?.count else {
            return nil
        }
        
        if let productImageURL = (images?.allObjects as! [ProductImage]).sorted(by: { (pImage1, pImage2) -> Bool in
            return pImage1.id > pImage2.id
        })[currentImage].imageURL {
            return productImageURL as URL
        }
        
        return nil
    }
    
    func goToNextPage() {
        
        if images?.count == 0 {
            return
        }
        
        if let imageCount = images?.count {
            if currentImage == imageCount - 1 {
                currentImage = 0
            } else {
                currentImage += 1
            }
        }
        
        if let productImageURL = (images?.allObjects as! [ProductImage]).sorted(by: { (pImage1, pImage2) -> Bool in
            return pImage1.id > pImage2.id
        })[currentImage].imageURL {
            print(productImageURL)
            if listenForImageChange != nil {
                listenForImageChange!(productImageURL as URL)
            } else {
                stopImageTimer()
            }
        }
    }
}

extension Product: PersistencyOperation {
    
    func setWithDictionary(_ dictionary: Dictionary<String, AnyObject>, position: Int) {
        
        if let value = dictionary["id"] as? Int {
            self.id = Int32(value)
        }
        
        if let value = dictionary["quantity"] as? Int {
            self.quantity = Int32(value)
        }
        
        if let value = dictionary["product_image_url"] as? String {
            self.product_image_url = value
        }
        
        if let value = dictionary["image_url"] as? String {
            self.image_url = value
        }
        
        if let value = dictionary["permalink"] as? String {
            self.permalink = value
        }
        
        if let value = dictionary["category_id"] as? Int {
            self.category_id = Int32(value)
        }
        
        if let value = dictionary["created_at"] as? Date {
            self.created_at = value.timeIntervalSinceNow
        }
        
        if let value = dictionary["url"] as? String {
            self.url = value
        }
        
        if let value = dictionary["previous_price"] as? String {
            self.previous_price = value
        }
        
        if let value = dictionary["minimum_stock_level"] as? Int {
            self.minimum_stock_level = Int32(value)
        }
        
        if let value = dictionary["price"] as? String {
            self.price = value
        }
        
        if let value = dictionary["track_quantity"] as? Bool {
            self.track_quantity = value
        }
        
        if let value = dictionary["name"] as? String {
            self.name = value
        }
        
        if let value = dictionary["description"] as? String , value.characters.count > 0 {
            self.desc = value
        } else {
            self.desc = "No Description available"
        }
        
        if let value = dictionary["detailed_description"] as? String , value.characters.count > 0 {
            self.detailed_description = value
        }
        
        if let value = dictionary["default_variant"] as? [String : AnyObject] {
            self.default_variant = persistencyManager.prepare("ProductVariant", entityData: value, position: 1) as? ProductVariant
        }
        
        if let value = dictionary["images"] as? [[String : AnyObject]] {
            self.images = NSSet(array: persistencyManager.prepare("ProductImage", entitiesArray: value))
        }
        
        if let value = dictionary["variants"] as? [[String : AnyObject]] {
            self.variants = NSSet(array: persistencyManager.prepare("ProductVariant", entitiesArray: value))
        }
        
        if let value = dictionary["options"] as? [[String : AnyObject]] {
            self.options = NSSet(array: persistencyManager.prepare("ProductOption", entitiesArray: value))
        }
        
        if let value = dictionary["filter_attributes"] as? [[String : AnyObject]] {
            self.filter_attributes = NSSet(array: persistencyManager.prepare("ProductFilterAttribute", entitiesArray: value))
        }
        
        if let value = dictionary["custom_attributes"] as? [String : String] {
            self.custom_attributes = value.map({ $0.1 })
        }
        
        if let value = dictionary["position"] as? Int {
            self.position = Int32(value)
        } else {
            self.position = Int32(position)
        }
        
        if let value = dictionary["isFeatured"] as? Bool {
            self.isFeatured = value
        } else {
            self.isFeatured = false
        }
        
        if let value = dictionary["isRelated"] as? Bool {
            self.isRelated = value
        } else {
            self.isRelated = false
        }
        
        if let value = dictionary["isRecent"] as? Bool {
            self.isRecent = value
        } else {
            self.isRecent = false
        }
        
        if let value = dictionary["isSimilar"] as? Bool {
            self.isSimilar = value
        } else {
            self.isSimilar = false
        }
        
        // Check for related products
        if let relatedProductsArray = dictionary["related_products"] as? [[String : AnyObject]] {
            
            self.relatedProducts = NSSet(array: persistencyManager.prepare("Product", entitiesArray: relatedProductsArray))
            
            /*var newArray: [[String : AnyObject]] = []
            for dictionary in relatedProductsArray {
                var newDictionary: [String : AnyObject] = dictionary
                newDictionary.updateValue(true as AnyObject, forKey: "isRelated")
                newArray.append(newDictionary)
            }
            persistencyManager.append("Product", entitiesArray: newArray, autoSave: true)*/
        }
        
        insertedOn = Date().timeIntervalSinceNow
    }
}
