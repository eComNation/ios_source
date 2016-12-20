//
//  NetworkManager.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 07/04/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit
import Alamofire
import BusyNavigationBar

let networkManager = NetworkManager.sharedManager

open class NetworkManager: NSObject {

    // MARK: Properties
    /// Singleton instance of `NetworkManager`
    open static let sharedManager = NetworkManager()
    
    
    /// Busy navigation bar object
    var busyNavigationBarOptions: BusyNavigationBarOptions
    var busyNavigationController: UINavigationController?
    
    /// Network request counter
    open var networkRequestCount: Int = 0
    fileprivate var networkRequestCounter: Int {
        get {
            return networkRequestCount
        }
        
        set {
            networkRequestCount = newValue
            if networkRequestCount > 0 {
                UIApplication.shared.isNetworkActivityIndicatorVisible = true
//                if let navController = busyNavigationController {
//                    navController.navigationBar.start(busyNavigationBarOptions)
//                }
            }
            
            if networkRequestCount <= 0 {
                networkRequestCount = 0
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
//                if let navController = self.busyNavigationController {
//                    navController.navigationBar.stop()
//                }
            }
        }
    }
    
    open var noRequestRunning: Bool {
        if networkRequestCount == 0 {
            return true
        }        
        
        return false
    }
    
    public typealias Completion = (Bool, String?, AnyObject?) -> (Void)

    
    // MARK: Initialization
    /**
        A constructor of `NetworkManager`. Initializes all necessary resources along with `NetworkManager` itself.
     */
    fileprivate override init() {
        print("Initialized Network Manager")
       
        busyNavigationBarOptions = BusyNavigationBarOptions()
        busyNavigationBarOptions.animationType = .stripes
        busyNavigationBarOptions.color = UIColor.black
        busyNavigationBarOptions.alpha = 1.0
        
        super.init()
    }
    
    fileprivate func resolveErrorMessage(_ responseData: [String : AnyObject]) -> String {
        
        if let errors = responseData["error"] as? [String] , errors.count > 0 {
            return errors.first!
        } else if let error = responseData["error"] as? String {
            return error
        }
        
        return "Something went wrong."
    }
}



// MARK: Category Operations
extension NetworkManager {
    
    public func fetchStoreCategories(_ completion: @escaping Completion) {
        
        networkRequestCounter += 1
        Alamofire.request(BaseServiceURL+StoreCategoriesRoot, method: .get, parameters: nil , encoding: URLEncoding.default, headers: ["User-Agent": "iOS"]).responseJSON { (response) in
            
            self.networkRequestCounter -= 1
            
            guard response.result.isSuccess else {
                print("Couldn't fetch categories: \(response.result.error?.localizedDescription)")
                completion(false, response.result.error?.localizedDescription, nil)
                return
            }
            
            if let responseData = response.result.value as? [String : AnyObject] {
                //print(responseData.jsonString)
                if let categoryArray = responseData["categories"] as? [[String : AnyObject]] {
                    persistencyManager.replaceAllWithArray("Category", entitiesArray: categoryArray)
                    completion(true, nil, response.result.value as AnyObject?)
                } else {
                    completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                }
            } else {
                completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
            }
        }
    }
    
    public func fetchFilterAttributes(_ completion: @escaping Completion) {
        
        networkRequestCounter += 1
        Alamofire.request(BaseServiceURL+StoreCategoryFilterAttributes, method: .get, parameters: nil, encoding: URLEncoding.default, headers: ["User-Agent": "iOS"]).responseJSON { (response) in
            self.networkRequestCounter -= 1
            
            guard response.result.isSuccess else {
                print("Couldn't fetch filter attributes: \(response.result.error?.localizedDescription)")
                completion(false, response.result.error?.localizedDescription, nil)
                return
            }
            
            if let responseData = response.result.value as? [String : AnyObject] {
                if let filterGroupsArray = responseData["filter_attributes"] as? [[String : AnyObject]] {
                    persistencyManager.replaceAllWithArray("FilterGroup", entitiesArray: filterGroupsArray)
                    completion(true, nil, response.result.value as AnyObject?)
                } else {
                    completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                }
            } else {
                completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
            }
        }
    }
    
    public func fetchAvailablePincodes(_ completion: @escaping Completion) {
        
        networkRequestCounter += 1
        Alamofire.request(PincodeURL, method: .get, parameters: nil, encoding: URLEncoding.default, headers: ["User-Agent": "iOS"]).responseJSON { (response) in
            self.networkRequestCounter -= 1
            
            guard response.result.isSuccess else {
                print("Couldn't fetch filter attributes: \(response.result.error?.localizedDescription)")
                completion(false, response.result.error?.localizedDescription, nil)
                return
            }
            
            if let responseData = response.result.value as? [String : AnyObject] {
                persistencyManager.deleteAll("Pincode")
                for(key,value) in responseData {
                    persistencyManager.insert("Pincode", entityData: [key : value], autoSave: false, position: 0)
                }
            } else {
                completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
            }
        }
    }
}


// MARK: Banner Operations
extension NetworkManager {
    public func fetchBanners(_ count: Int, completion: @escaping Completion) {
        
        networkRequestCounter += 1
        Alamofire.request(BaseServiceURL+StoreBanners, method: .get, parameters: ["count" : count], encoding: URLEncoding.default, headers: ["User-Agent": "iOS"]).responseJSON { (response) in
            self.networkRequestCounter -= 1
            
            guard response.result.isSuccess else {
                print("Couldn't fetch banners: \(response.result.error?.localizedDescription)")
                completion(false, response.result.error?.localizedDescription, nil)
                return
            }
            
            if let responseData = response.result.value as? [String : AnyObject] {
                //print(responseData.jsonString)
                if let bannerArray = responseData["banners"] as? [[String : AnyObject]] {
                    persistencyManager.replaceAllWithArray("Banner", entitiesArray: bannerArray)
                    completion(true, nil, response.result.value as AnyObject?)
                } else {
                    completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                }
            } else {
                completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
            }
        }
    }
}

// MARK: Product operations
extension NetworkManager {
    
    public func fetchFeaturedProducts(_ page: Int, completion: @escaping Completion) {
        
        networkRequestCounter += 1
        
        let parameters: [String : AnyObject] = ["page": page as AnyObject,
                                                "per_page": 10 as AnyObject]
        
        Alamofire.request(BaseServiceURL+StoreFeaturedProducts, method: .get, parameters: parameters , encoding: URLEncoding.default, headers: ["User-Agent": "iOS"]).responseJSON { (response) in
            
            self.networkRequestCounter -= 1
            
            guard response.result.isSuccess else {
                print("Couldn't fetch featured products: \(response.result.error?.localizedDescription)")
                completion(false, response.result.error?.localizedDescription, nil)
                return
            }
            
            if let responseData = response.result.value as? [String : AnyObject] {
                
                //print(responseData.jsonString)
                
                if let fProductsArray = responseData["products"] as? [[String : AnyObject]] {
                    var newArray: [[String : AnyObject]] = []
                    for dictionary in fProductsArray {
                        var newDictionary: [String : AnyObject] = dictionary
                        newDictionary.updateValue(true as AnyObject, forKey: "isFeatured")
                        newArray.append(newDictionary)
                    }
                    persistencyManager.append("Product", entitiesArray: newArray, autoSave: true)
                    completion(true, nil, response.result.value as AnyObject?)
                } else {
                    completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                }
            } else {
                completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
            }
        }
    }
    
    public func fetchProductsForCategory(_ categoryId: Int32, page: Int, completion: @escaping Completion) {
        
        networkRequestCounter += 1
        
        let parameters: [String : AnyObject] = ["active_category" : Int(categoryId) as AnyObject,
                                                "page": page as AnyObject,
                                                "per_page": 16 as AnyObject,
                                                "facets": false as AnyObject]
        
        Alamofire.request(BaseServiceURL+StoreProducts, method: .get, parameters: parameters , encoding: URLEncoding.default, headers: ["User-Agent": "iOS"]).responseJSON { (response) in
            self.networkRequestCounter -= 1
            
            guard response.result.isSuccess else {
                print("Couldn't fetch products: \(response.result.error?.localizedDescription)")
                completion(false, response.result.error?.localizedDescription, nil)
                return
            }
            
            if let responseData = response.result.value as? [String : AnyObject] {
                if let productsArray = responseData["products"] as? [[String : AnyObject]] {
                    persistencyManager.append("Product", entitiesArray: productsArray, autoSave: true)
                    completion(true, nil, response.result.value as AnyObject?)
                } else {
                    completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                }
            } else {
                completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
            }
        }
    }
    
    public func fetchProductMatchingDetails(_ details: [String : AnyObject], isRecent: Bool, completion: @escaping Completion) {
        
        networkRequestCounter += 1
        
        Alamofire.request(BaseServiceURL+StoreProducts, method: .get, parameters: details , encoding: URLEncoding.default, headers: ["User-Agent": "iOS"]).responseJSON { (response) in
            self.networkRequestCounter -= 1
            
            guard response.result.isSuccess else {
                print("Couldn't fetch products: \(response.result.error?.localizedDescription)")
                completion(false, response.result.error?.localizedDescription, nil)
                return
            }
            
            if let responseData = response.result.value as? [String : AnyObject] {
                //print(responseData.jsonString)
                if let productsArray = responseData["products"] as? [[String : AnyObject]] {
                    var newArray: [[String : AnyObject]] = []
                    for dictionary in productsArray {
                        var newDictionary: [String : AnyObject] = dictionary
                        newDictionary.updateValue(isRecent as AnyObject, forKey: "isRecent")
                        newArray.append(newDictionary)
                    }
                    print("Products count: \(newArray.count)")
                    persistencyManager.append("Product", entitiesArray: newArray, autoSave: true)
                    completion(true, nil, response.result.value as AnyObject?)
                } else if let _ = responseData["min"] {
                    completion(true, nil, response.result.value as AnyObject?)
                }else {
                    completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                }
            } else {
                completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
            }
        }
    }
    
    public func fetchSimilarProductsForProductId(_ productId: Int32, completion: @escaping Completion) {
        
        networkRequestCounter += 1
        
        Alamofire.request(BaseServiceURL+StoreProducts+"/\(Int(productId))/similar_products", method: .get, parameters: nil , encoding: URLEncoding.default, headers: ["User-Agent": "iOS"]).responseJSON { (response) in
            self.networkRequestCounter -= 1
            
            guard response.result.isSuccess else {
                print("Couldn't fetch similar product: \(response.result.error?.localizedDescription)")
                completion(false, response.result.error?.localizedDescription, nil)
                return
            }
            
            if let responseData = response.result.value as? [String : AnyObject] {
                //print(responseData.jsonString)
                if let productsArray = responseData["products"] as? [[String : AnyObject]] {
                    var newArray: [[String : AnyObject]] = []
                    for dictionary in productsArray {
                        var newDictionary: [String : AnyObject] = dictionary
                        newDictionary.updateValue(true as AnyObject, forKey: "isSimilar")
                        newArray.append(newDictionary)
                    }
                    print("Products count: \(newArray.count)")
                    persistencyManager.append("Product", entitiesArray: newArray, autoSave: true)
                    completion(true, nil, response.result.value as AnyObject?)
                } else {
                    completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                }
            } else {
                completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
            }
        }
    }
    
    public func fetchProductDetailForProductId(_ productId: Int32, completion: @escaping Completion) {
        
        networkRequestCounter += 1

        Alamofire.request(BaseServiceURL+StoreProducts+"/\(Int(productId))", method: .get, parameters: nil , encoding: URLEncoding.default, headers: ["User-Agent": "iOS"]).responseJSON { (response) in
            self.networkRequestCounter -= 1
            
            guard response.result.isSuccess else {
                print("Couldn't fetch product detail: \(response.result.error?.localizedDescription)")
                completion(false, response.result.error?.localizedDescription, nil)
                return
            }
            
            if let responseData = response.result.value as? [String : AnyObject] {
                print(responseData.jsonString)
                if responseData["product"] != nil {
                    completion(true, nil, response.result.value as AnyObject?)
                } else {
                    completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                }
            } else {
                completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
            }
        }
    }
    
    public func fetchFavouriteProducts(_ page: Int, completion: @escaping Completion) {
        
        if let accessToken = customerManager.accessToken {
            
            networkRequestCounter += 1
            
            let parameters: [String : AnyObject] = ["page": page as AnyObject,
                                                    "per_page": 16 as AnyObject]
            
            Alamofire.request(BaseServiceURL+CustomerFavouriteProduct, method: .get, parameters: parameters , encoding: URLEncoding.default, headers: ["Authorization": "Bearer \(accessToken)","User-Agent": "iOS"]).responseJSON { (response) in
                self.networkRequestCounter -= 1
                
                guard response.result.isSuccess else {
                    print("Couldn't add favourite product: \(response.result.error?.localizedDescription)")
                    completion(false, response.result.error?.localizedDescription, nil)
                    return
                }
                
                if let responseData = response.result.value as? [String : AnyObject] {
                    //print(responseData.jsonString)
                    if let favouriteProductsArray = responseData["products"] as? [[String : AnyObject]] {
                        persistencyManager.append("FavouriteProduct", entitiesArray: favouriteProductsArray)
                        completion(true, nil, response.result.value as AnyObject?)
                    } else {
                        completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                    }
                } else {
                    completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
                }
            }
        }
    }
    
    public func addFavouriteProduct(_ productId: Int32, completion: @escaping Completion) {
        
        if let accessToken = customerManager.accessToken {
            
            networkRequestCounter += 1
            
            Alamofire.request(BaseServiceURL+CustomerFavouriteProduct+"/\(productId)", method: .post, parameters: nil , encoding: URLEncoding.default, headers: ["Authorization": "Bearer \(accessToken)","User-Agent": "iOS"]).responseJSON { (response) in
                self.networkRequestCounter -= 1
                
                guard response.result.isSuccess else {
                    print("Couldn't add favourite product: \(response.result.error?.localizedDescription)")
                    completion(false, response.result.error?.localizedDescription, nil)
                    return
                }
                
                if let responseData = response.result.value as? [String : AnyObject] {
                    //print(responseData.jsonString)
                    if let result = responseData["result"] as? String , result == "success" {
                        completion(true, nil, response.result.value as AnyObject?)
                    } else {
                        completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                    }
                } else {
                    completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
                }
            }
        }
    }
    
    public func removeFavouriteProduct(_ productId: Int32, completion: @escaping Completion) {
        
        if let accessToken = customerManager.accessToken {
            
            networkRequestCounter += 1
            
            Alamofire.request(BaseServiceURL+CustomerFavouriteProduct+"/\(productId)", method: .delete, parameters: nil , encoding: URLEncoding.default, headers: ["Authorization": "Bearer \(accessToken)","User-Agent": "iOS"]).responseJSON { (response) in
                self.networkRequestCounter -= 1
                
                guard response.result.isSuccess else {
                    print("Couldn't remove favourite product: \(response.result.error?.localizedDescription)")
                    completion(false, response.result.error?.localizedDescription, nil)
                    return
                }
                
                if let responseData = response.result.value as? [String : AnyObject] {
                    //print(responseData.jsonString)
                    if let result = responseData["result"] as? String , result == "success" {
                        completion(true, nil, response.result.value as AnyObject?)
                    } else {
                        completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                    }
                } else {
                    completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
                }
            }
        }
    }
}

// Jewellery App Operations
extension NetworkManager {
    
    public func fetchJewelleryProductForProductId(_ productId: Int32, completion: @escaping Completion) {
        
        networkRequestCounter += 1
        
        Alamofire.request(JewelleryURL+StoreProducts+"/\(Int(productId))?store_id=" + StoreId, method: .get, parameters: nil , encoding: URLEncoding.default, headers: ["User-Agent": "iOS"]).responseJSON { (response) in
            self.networkRequestCounter -= 1
            
            guard response.result.isSuccess else {
                print("Couldn't fetch jewellery product detail: \(response.result.error?.localizedDescription)")
                completion(false, response.result.error?.localizedDescription, nil)
                return
            }
            
            if let responseData = response.result.value as? [String : AnyObject] {
                print(responseData.jsonString)
                if responseData["product"] != nil {
                    completion(true, nil, response.result.value as AnyObject?)
                } else {
                    completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                }
            } else {
                completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
            }
        }
    }
    
    public func fetchJewelleryPrice(_ productId: Int32, completion: @escaping Completion) {
        
        networkRequestCounter += 1
        
        Alamofire.request(JewelleryURL+StoreProducts+"/\(Int(productId))/price?store_id=" + StoreId, method: .get, parameters: nil , encoding: URLEncoding.default, headers: ["User-Agent": "iOS"]).responseJSON { (response) in
            self.networkRequestCounter -= 1
            
            guard response.result.isSuccess else {
                print("Couldn't fetch product price detail: \(response.result.error?.localizedDescription)")
                completion(false, response.result.error?.localizedDescription, nil)
                return
            }
            
            if let responseData = response.result.value as? [String : AnyObject] {
                print(responseData.jsonString)
                if responseData["price"] != nil {
                    completion(true, nil, response.result.value as AnyObject?)
                } else {
                    completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                }
            } else {
                completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
            }
        }
    }
    
}

// MARK: Login/Signup related operations
extension NetworkManager {
    
    public func signupWithDetail(_ fName: String, lName: String, login: String, phone: String, password: String, cPassword: String, marketingMails: Bool, completion: @escaping Completion) {
        
        /*
         1. {"customer":{"email":"rocky.onlyads@gmail.com","phone":null,"last_name":"Pethani","first_name":"Rakesh"}}
         2. {"error":["Login has already been taken"]}
        */
        
        networkRequestCounter += 1
        
        let parameters: [String : AnyObject] = ["first_name" : fName as AnyObject,
                                                "last_name": lName as AnyObject,
                                                "login": login as AnyObject,
                                                "phone": phone as AnyObject,
                                                "password": password as AnyObject,
                                                "password_confirmation": cPassword as AnyObject,
                                                "marketing_mails": marketingMails as AnyObject]
        
        Alamofire.request(BaseServiceURL+CustomerSignup, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: ["User-Agent": "iOS"]).responseJSON { (response) in
            self.networkRequestCounter -= 1
            
            guard response.result.isSuccess else {
                print("Couldn't Sign up: \(response.result.error?.localizedDescription)")
                completion(false, response.result.error?.localizedDescription, nil)
                return
            }
            
            if let responseData = response.result.value as? [String : AnyObject] {
                //print(responseData.jsonString)
                if responseData["customer"] != nil {
                    completion(true, nil, response.result.value as AnyObject?)
                } else {
                    completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                }
            } else {
                completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
            }
        }
    }
    
    public func loginWithDetail(_ login: String, password: String, completion: @escaping Completion) {
        
        /*
            Demo
            ID: abhi.h@ecomnation.in
            PWD: 1234
         */
        
        /*
         1. {"error":["Customer not found."]}
         2. {"error":["Invalid username or password."]}
         3. {"refresh_token":"406d87d936c74b95739a6b6799c31b620c3d4274283c5a90c0b8a0d331b3825a",
            "created_at":"2016-05-09T09:50:25.000Z",
            "access_token":"2a07319576b7002cb2a1dcedb4176f872be3f85f3079e18a7a17bd7732cd726b",
            "expires_in":604800}
        */
        
        networkRequestCounter += 1
        
        let parameters: [String : AnyObject] = ["login": login as AnyObject,
                                                "password": password as AnyObject,
                                                "client_id": ApplicationClientId as AnyObject,
                                                "secret": ApplicationClientSecret as AnyObject]
        
        Alamofire.request(BaseServiceURL+CustomerSignin, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: ["User-Agent": "iOS"]).responseJSON { (response) in
            self.networkRequestCounter -= 1
            
            guard response.result.isSuccess else {
                print("Couldn't Sign in: \(response.result.error?.localizedDescription)")
                completion(false, response.result.error?.localizedDescription, nil)
                return
            }
            
            if let responseData = response.result.value as? [String : AnyObject] {
                //print(responseData.jsonString)
                if responseData["access_token"] != nil {
                    customerManager.setDetailsInCurrentCustomer(responseData)
                    completion(true, nil, response.result.value as AnyObject?)
                } else {
                    completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                }
            } else {
                completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
            }
        }
    }
    
    public func loginWithGoogle(_ token: String, completion: @escaping Completion) {
        
        networkRequestCounter += 1
        
        let parameters: [String : AnyObject] = ["access_token": token as AnyObject,
                                                "client_id": ApplicationClientId as AnyObject,
                                                "secret": ApplicationClientSecret as AnyObject]
        
        Alamofire.request(BaseServiceURL+CustomerSigninGoogle, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: ["User-Agent": "iOS"]).responseJSON { (response) in
            self.networkRequestCounter -= 1
            
            guard response.result.isSuccess else {
                print("Couldn't Sign in: \(response.result.error?.localizedDescription)")
                completion(false, response.result.error?.localizedDescription, nil)
                return
            }
            
            if let responseData = response.result.value as? [String : AnyObject] {
                //print(responseData.jsonString)
                if responseData["access_token"] != nil {
                    customerManager.setDetailsInCurrentCustomer(responseData)
                    completion(true, nil, response.result.value as AnyObject?)
                } else {
                    completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                }
            } else {
                completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
            }
        }
    }
    
    public func loginWithFacebook(_ token: String, completion: @escaping Completion) {
        
        networkRequestCounter += 1
        
        let parameters: [String : AnyObject] = ["access_token": token as AnyObject,
                                                "client_id": ApplicationClientId as AnyObject,
                                                "secret": ApplicationClientSecret as AnyObject]
        
        Alamofire.request(BaseServiceURL+CustomerSigninFacebook, method: .post, parameters: parameters , encoding: URLEncoding.default, headers: ["User-Agent": "iOS"]).responseJSON { (response) in
            self.networkRequestCounter -= 1
            
            guard response.result.isSuccess else {
                print("Couldn't Sign in: \(response.result.error?.localizedDescription)")
                completion(false, response.result.error?.localizedDescription, nil)
                return
            }
            
            if let responseData = response.result.value as? [String : AnyObject] {
                //print(responseData.jsonString)
                if responseData["access_token"] != nil {
                    customerManager.setDetailsInCurrentCustomer(responseData)
                    completion(true, nil, response.result.value as AnyObject?)
                } else {
                    completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                }
            } else {
                completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
            }
        }
    }
    
    public func contactUsWithDetail(_ detail: [String : AnyObject], completion: @escaping Completion) {
        
        networkRequestCounter += 1
        
        Alamofire.request(BaseServiceURL+StoreContact, method: .post, parameters: detail , encoding: URLEncoding.default, headers: ["User-Agent": "iOS"]).responseJSON { (response) in
            self.networkRequestCounter -= 1
            
            guard response.result.isSuccess else {
                print("Couldn't Contact Store: \(response.result.error?.localizedDescription)")
                completion(false, response.result.error?.localizedDescription, nil)
                return
            }
            
            if let responseData = response.result.value as? [String : AnyObject] {
                //print(responseData.jsonString)
                if let result = responseData["result"] as? String , result == "success" {
                    completion(true, nil, response.result.value as AnyObject?)
                } else {
                    completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                }
            } else {
                completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
            }
        }
    }
    
    public func resetPasswordForUsername(_ username: String, completion: @escaping Completion) {
        
        networkRequestCounter += 1
        
        Alamofire.request(BaseServiceURL+CustomerPasswordReset, method: .get, parameters: ["login": username] , encoding: URLEncoding.default, headers: ["User-Agent": "iOS"]).responseJSON { (response) in
            self.networkRequestCounter -= 1
            
            guard response.result.isSuccess else {
                print("Couldn't Reset Password: \(response.result.error?.localizedDescription)")
                completion(false, response.result.error?.localizedDescription, nil)
                return
            }
            
            if let responseData = response.result.value as? [String : AnyObject] {
                //print(responseData.jsonString)
                if responseData["customer"] != nil {
                    completion(true, nil, response.result.value as AnyObject?)
                } else {
                    completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                }
            } else {
                completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
            }
        }
    }
}


// MARK: Profile related jobs
extension NetworkManager {

    public func refreshCustomerProfile(_ completion: @escaping Completion) {
        
        /*
         1. {"error":"Invalid route"}
         2. {"error":"OAuth Unauthorized"}
         */
        
        if let accessToken = customerManager.accessToken {
            
            networkRequestCounter += 1

            Alamofire.request(BaseServiceURL+CustomerProfile, method: .get, parameters: nil , encoding: URLEncoding.default, headers: ["Authorization": "Bearer \(accessToken)","User-Agent": "iOS"]).responseJSON { (response) in
                self.networkRequestCounter -= 1
                
                guard response.result.isSuccess else {
                    print("Couldn't refresh profile: \(response.result.error?.localizedDescription)")
                    completion(false, response.result.error?.localizedDescription, nil)
                    return
                }
                
                if let responseData = response.result.value as? [String : AnyObject] {
                    //print(responseData.jsonString)
                    if responseData["customer"] != nil {
                        customerManager.setDetailsInCurrentCustomer(responseData)
                        completion(true, nil, response.result.value as AnyObject?)
                    } else {
                        completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                    }
                } else {
                    completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
                }
            }
        }
    }
    
    public func updateCustomerProfile(_ profileInfo: [String : AnyObject], completion: @escaping Completion) {
        
        /*
         1. {"error":"Invalid route"}
         2. {"error":"OAuth Unauthorized"}
         */
        
        if let accessToken = customerManager.accessToken {
            
            networkRequestCounter += 1

            Alamofire.request(BaseServiceURL+CustomerUpdateProfile, method: .put, parameters: profileInfo, encoding: URLEncoding.default, headers: ["Authorization": "Bearer \(accessToken)","User-Agent": "iOS"]).responseJSON { (response) in
                self.networkRequestCounter -= 1
                
                guard response.result.isSuccess else {
                    print("Couldn't update profile: \(response.result.error?.localizedDescription)")
                    completion(false, response.result.error?.localizedDescription, nil)
                    return
                }
                
                if let responseData = response.result.value as? [String : AnyObject] {
                    //print(responseData.jsonString)
                    if responseData["customer"] != nil {
                        customerManager.setDetailsInCurrentCustomer(responseData)
                        completion(true, nil, response.result.value as AnyObject?)
                    } else {
                        completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                    }
                } else {
                    completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
                }
            }
        }
    }
    
    public func changeCustomerPassword(_ passwordInfo: [String : AnyObject], completion: @escaping Completion) {
        
        /*
         1. {"error":"Invalid route"}
         2. {"error":"OAuth Unauthorized"}
         */
        
        if let accessToken = customerManager.accessToken {
            
            networkRequestCounter += 1

            Alamofire.request(BaseServiceURL+CustomerChangePassword, method: .put, parameters: passwordInfo, encoding: URLEncoding.default, headers: ["Authorization": "Bearer \(accessToken)","User-Agent": "iOS"]).responseJSON { (response) in
                self.networkRequestCounter -= 1
                
                guard response.result.isSuccess else {
                    print("Couldn't change password: \(response.result.error?.localizedDescription)")
                    completion(false, response.result.error?.localizedDescription, nil)
                    return
                }
                
                if let responseData = response.result.value as? [String : AnyObject] {
                    //print(responseData.jsonString)
                    if let success = responseData["result"] as? String , success == "success" {
                        completion(true, nil, response.result.value as AnyObject?)
                    } else {
                        completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                    }
                } else {
                    completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
                }
            }
        }
    }
    
    public func fetchCustomerOrders(_ page: Int, completion: @escaping Completion) {
        
        /*
         1. {"error":"Invalid route"}
         2. {"error":"OAuth Unauthorized"}
         */
        
        if let accessToken = customerManager.accessToken {
            
            networkRequestCounter += 1
            
            let parameters: [String : AnyObject] = ["page": page as AnyObject,
                                                    "per_page": 16 as AnyObject]
            
            Alamofire.request(BaseServiceURL+CustomerOrders, method: .get, parameters: parameters , encoding: URLEncoding.default, headers: ["Authorization": "Bearer \(accessToken)","User-Agent": "iOS"]).responseJSON { (response) in
                self.networkRequestCounter -= 1
                
                guard response.result.isSuccess else {
                    print("Couldn't fetch orders: \(response.result.error?.localizedDescription)")
                    completion(false, response.result.error?.localizedDescription, nil)
                    return
                }
                
                if let responseData = response.result.value as? [String : AnyObject] {
                    //print(responseData.jsonString)
                    
                    if let ordersArray = responseData["orders"] as? [[String : AnyObject]] {
                        persistencyManager.append("OrderInfo", entitiesArray: ordersArray, autoSave: true)
                        completion(true, nil, response.result.value as AnyObject?)
                    } else {
                        completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                    }
                } else {
                    completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
                }
            }
        }
    }
    
    public func fetchOrderInfo(_ orderId: Int, completion: @escaping Completion) {
        
        /*
         1. {"error":"Invalid route"}
         2. {"error":"OAuth Unauthorized"}
         */
        
        if let accessToken = customerManager.accessToken {
            
            networkRequestCounter += 1
            
            Alamofire.request(BaseServiceURL+CustomerOrders+"/\(orderId)", method: .get, parameters: nil , encoding: URLEncoding.default, headers: ["Authorization": "Bearer \(accessToken)","User-Agent": "iOS"]).responseJSON { (response) in
                self.networkRequestCounter -= 1
                
                guard response.result.isSuccess else {
                    print("Couldn't fetch order info: \(response.result.error?.localizedDescription)")
                    completion(false, response.result.error?.localizedDescription, nil)
                    return
                }
                
                if let responseData = response.result.value as? [String : AnyObject] {
                    //print(responseData.jsonString)
                    
                    if let _ = responseData["order"] as? [String : AnyObject] {
                        completion(true, nil, response.result.value as AnyObject?)
                    } else {
                        completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                    }
                } else {
                    completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
                }
            }
        }
    }
    
    public func fetchCustomerAddresses(_ completion: @escaping Completion) {
        
        /*
         1. {"error":"Invalid route"}
         2. {"error":"OAuth Unauthorized"}
         */
        
        if let accessToken = customerManager.accessToken {
            
            networkRequestCounter += 1
            
            Alamofire.request(BaseServiceURL+CustomerAddresses, method: .get, parameters: nil , encoding: URLEncoding.default, headers: ["Authorization": "Bearer \(accessToken)","User-Agent": "iOS"]).responseJSON { (response) in
                self.networkRequestCounter -= 1
                
                guard response.result.isSuccess else {
                    print("Couldn't fetch Addresses: \(response.result.error?.localizedDescription)")
                    completion(false, response.result.error?.localizedDescription, nil)
                    return
                }
                
                if let responseData = response.result.value as? [String : AnyObject] {
                    //print(responseData.jsonString)
                    
                    if let addressesArray = responseData["addresses"] as? [[String : AnyObject]] {
                        persistencyManager.replaceAllWithArray("Address", entitiesArray: addressesArray)
                        completion(true, nil, response.result.value as AnyObject?)
                    } else {
                        completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                    }
                } else {
                    completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
                }
            }
        }
    }
    
    public func addCustomerAddress(_ address: [String : AnyObject],completion: @escaping Completion) {
        
        /*
         1. {"error":"Invalid route"}
         2. {"error":"OAuth Unauthorized"}
         */
        
        if let accessToken = customerManager.accessToken {
            
            networkRequestCounter += 1
            
            Alamofire.request(BaseServiceURL+CustomerAddresses, method: .post, parameters: address , encoding: URLEncoding.default, headers: ["Authorization": "Bearer \(accessToken)","User-Agent": "iOS"]).responseJSON { (response) in
                self.networkRequestCounter -= 1
                
                guard response.result.isSuccess else {
                    print("Couldn't add Address: \(response.result.error?.localizedDescription)")
                    completion(false, response.result.error?.localizedDescription, nil)
                    return
                }
                
                if let responseData = response.result.value as? [String : AnyObject] {
                    //print(responseData.jsonString)
                    
                    if let addressDict = responseData["address"] as? [String : AnyObject] {
                        persistencyManager.append("Address", entitiesArray: [addressDict])
                        completion(true, nil, response.result.value as AnyObject?)
                    } else {
                        completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                    }
                } else {
                    completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
                }
            }
        }
    }
    
    public func updateCustomerAddress(_ addressId: Int, address: [String : AnyObject],completion: @escaping Completion) {
        
        /*
         1. {"error":"Invalid route"}
         2. {"error":"OAuth Unauthorized"}
         */
        
        if let accessToken = customerManager.accessToken {
            
            networkRequestCounter += 1
            
            Alamofire.request(BaseServiceURL+CustomerAddresses+"/\(addressId)", method: .put, parameters: address , encoding: URLEncoding.default, headers: ["Authorization": "Bearer \(accessToken)","User-Agent": "iOS"]).responseJSON { (response) in
                self.networkRequestCounter -= 1
                
                guard response.result.isSuccess else {
                    print("Couldn't update Address: \(response.result.error?.localizedDescription)")
                    completion(false, response.result.error?.localizedDescription, nil)
                    return
                }
                
                if let responseData = response.result.value as? [String : AnyObject] {
                    //print(responseData.jsonString)
                    
                    if let _ = responseData["address"] as? [String : AnyObject] {
                        completion(true, nil, response.result.value as AnyObject?)
                    } else {
                        completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                    }
                } else {
                    completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
                }
            }
        }
    }
    
    public func deleteCustomerAddresses(_ addressId: Int, completion: @escaping Completion) {
        
        /*
         1. {"error":"Invalid route"}
         2. {"error":"OAuth Unauthorized"}
         */
        
        if let accessToken = customerManager.accessToken {
            
            networkRequestCounter += 1
            
            Alamofire.request(BaseServiceURL+CustomerAddresses+"/\(addressId)", method: .delete, parameters: nil , encoding: URLEncoding.default, headers: ["Authorization": "Bearer \(accessToken)","User-Agent": "iOS"]).responseJSON { (response) in
                self.networkRequestCounter -= 1
                
                guard response.result.isSuccess else {
                    print("Couldn't delete Address: \(response.result.error?.localizedDescription)")
                    completion(false, response.result.error?.localizedDescription, nil)
                    return
                }
                
                if let responseData = response.result.value as? [String : AnyObject] {
                    //print(responseData.jsonString)
                    
                    if let _ = responseData["address"] as? [String : AnyObject] {
                        persistencyManager.deleteFirst("Address", predicate: NSPredicate(format: "id == %d", addressId), sortDescriptors: nil)
                        completion(true, nil, response.result.value as AnyObject?)
                    } else {
                        completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                    }
                } else {
                    completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
                }
            }
        }
    }
    
    public func fetchCountries(_ completion: @escaping Completion) {
        
        networkRequestCounter += 1
        
        Alamofire.request(BaseServiceURL+StoreCountries, method: .get, parameters: nil , encoding: URLEncoding.default, headers: ["User-Agent": "iOS"]).responseJSON { (response) in
            self.networkRequestCounter -= 1
            
            guard response.result.isSuccess else {
                print("Couldn't fetch Countries: \(response.result.error?.localizedDescription)")
                completion(false, response.result.error?.localizedDescription, nil)
                return
            }
            
            if let responseData = response.result.value as? [String : AnyObject] {
                //print(responseData.jsonString)
                
                if let countriesArray = responseData["countries"] as? [[String : AnyObject]] {
                    persistencyManager.replaceAllWithArray("Country", entitiesArray: countriesArray)
                    completion(true, nil, response.result.value as AnyObject?)
                } else {
                    completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                }
            } else {
                completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
            }
        }
    }
    
    public func fetchStates(_ countryId: Int, completion: @escaping Completion) {
        
        networkRequestCounter += 1
        
        Alamofire.request(BaseServiceURL+StoreCountries+"/\(countryId)/states", method: .get, parameters: nil , encoding: URLEncoding.default, headers: ["User-Agent": "iOS"]).responseJSON { (response) in
            self.networkRequestCounter -= 1
            
            guard response.result.isSuccess else {
                print("Couldn't fetch States: \(response.result.error?.localizedDescription)")
                completion(false, response.result.error?.localizedDescription, nil)
                return
            }
            
            if let responseData = response.result.value as? [String : AnyObject] {
                //print(responseData.jsonString)
                
                if let statesArray = responseData["states"] as? [[String : AnyObject]] {
                    persistencyManager.replaceAllWithArray("State", entitiesArray: statesArray)
                    completion(true, nil, response.result.value as AnyObject?)
                } else {
                    completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                }
            } else {
                completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
            }
        }
    }
}

// MARK: Cart related operations
extension NetworkManager {
    
    public func fetchCurrentCart(_ completion: @escaping Completion) {
        
        /*
         1. {"error":"Invalid route"}
         2. {"error":"OAuth Unauthorized"}
         */
        
        if let accessToken = customerManager.accessToken {
            
            networkRequestCounter += 1
            
            Alamofire.request(BaseServiceURL+OrderCart, method: .get, parameters: ["access_token" : accessToken] , encoding: URLEncoding.default, headers: ["User-Agent": "iOS"]).responseJSON { (response) in
                self.networkRequestCounter -= 1
                
                guard response.result.isSuccess else {
                    print("Couldn't fetch Cart: \(response.result.error?.localizedDescription)")
                    completion(false, response.result.error?.localizedDescription, nil)
                    return
                }
                
                if response.response?.statusCode == 422 {
                    completion(true, nil, response.result.value as AnyObject?)
                    return
                }
                
                if let responseData = response.result.value as? [String : AnyObject] {
                    print(responseData.jsonString)
                    
                    if let cartDetails = responseData["cart"] as? [String : AnyObject] {
                        cartManager.setDetailsInCurrentCart(cartDetails)
                        completion(true, nil, response.result.value as AnyObject?)
                    } else {
                        completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                    }
                } else {
                    completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
                }
            }
            
        } else if let cartToken = cartManager.cartToken  {
            
            networkRequestCounter += 1
            
            var parameters: [String : AnyObject] = [:]
            
            if let accessToken = customerManager.accessToken {
                parameters["access_token"] = accessToken as AnyObject?
            }
            
            Alamofire.request(BaseServiceURL+OrderCart+"/\(cartToken)/get", method: .get, parameters: parameters , encoding: URLEncoding.default, headers: ["User-Agent": "iOS"]).responseJSON { (response) in
                self.networkRequestCounter -= 1
                
                guard response.result.isSuccess else {
                    print("Couldn't fetch Cart: \(response.result.error?.localizedDescription)")
                    completion(false, response.result.error?.localizedDescription, nil)
                    return
                }
                
                if let responseData = response.result.value as? [String : AnyObject] {
                    
                    print(responseData.jsonString)
                    
                    if let cartDetails = responseData["cart"] as? [String : AnyObject] {
                        cartManager.setDetailsInCurrentCart(cartDetails)
                        completion(true, nil, response.result.value as AnyObject?)
                    } else {
                        completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                    }
                } else {
                    completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
                }
            }
            
        } else {
            completion(false, "Something went wrong.", nil)
        }
    }
    
    func associateCartToCurrentUser(_ completion: @escaping Completion) {
        
        if let cartToken = cartManager.cartToken {
            
            networkRequestCounter += 1
            
            var parameters: [String : AnyObject] = [:]
            
            if let accessToken = customerManager.accessToken {
                parameters["access_token"] = accessToken as AnyObject?
            }
            
            Alamofire.request(BaseServiceURL+OrderCart+"/\(cartToken)/associate_cart_to_user", method: .get, parameters: parameters , encoding: URLEncoding.default, headers: ["User-Agent": "iOS"]).responseJSON { (response) in
                self.networkRequestCounter -= 1
                
                guard response.result.isSuccess else {
                    print("Couldn't associate: \(response.result.error?.localizedDescription)")
                    completion(false, response.result.error?.localizedDescription, nil)
                    return
                }

                if let responseData = response.result.value as? [String : AnyObject] {
                    
                    //print(responseData.jsonString)
                    
                    if let cartDetails = responseData["cart"] as? [String : AnyObject] {
                        cartManager.setDetailsInCurrentCart(cartDetails)
                        completion(true, nil, response.result.value as AnyObject?)
                    } else {
                        completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                    }
                } else {
                    completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
                }
            }
        }
    }
    
    func createCart(_ variantIds: [Int], quantities: [Int], customAttribute: [String:String]? ,completion: @escaping Completion) {
        
        networkRequestCounter += 1
        
        var paramStrings: String = ""
        for (index, value) in variantIds.enumerated() {
            if index > 0 {
                paramStrings += "&"
            }
            paramStrings += "items[][id]=\(value)&items[][quantity]=\(quantities[index])"
            if let customAttr = customAttribute {
                paramStrings += "&items[][custom_details][\(customAttr.first!.key)]=\(customAttr.first!.value)"
            }
        }
        
        if let accessToken = customerManager.accessToken {
            paramStrings += "&access_token=\(accessToken)"
        }
        
        Alamofire.request(BaseServiceURL+OrderCartCreate+"?\(paramStrings)", method: .post, parameters: nil , encoding: URLEncoding.default, headers: ["User-Agent": "iOS"]).responseJSON { (response) in
            self.networkRequestCounter -= 1
            
            guard response.result.isSuccess else {
                print("Couldn't create Cart: \(response.result.error?.localizedDescription)")
                completion(false, response.result.error?.localizedDescription, nil)
                return
            }
            
            if let responseData = response.result.value as? [String : AnyObject] {
                
                //print(responseData.jsonString)
                
                if let cartDetails = responseData["cart"] as? [String : AnyObject] {
                    cartManager.setDetailsInCurrentCart(cartDetails)
                    completion(true, nil, response.result.value as AnyObject?)
                } else {
                    completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                }
            } else {
                completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
            }
        }
    }
    
    func addItem(_ variantIds: [Int], quantities: [Int], customAttribute: [String : String]?, completion: @escaping Completion) {
        
        if let cartToken = cartManager.cartToken {
            
            networkRequestCounter += 1
            
            var paramStrings: String = ""
            for (index, value) in variantIds.enumerated() {
                if index > 0 {
                    paramStrings += "&"
                }
                paramStrings += "items[][id]=\(value)&items[][quantity]=\(quantities[index])"
                if let customAttr = customAttribute {
                    paramStrings += "&items[][custom_details][\(customAttr.first!.key)]=\(customAttr.first!.value)"
                }
            }
            
            if let accessToken = customerManager.accessToken {
                paramStrings += "&access_token=\(accessToken)"
            }
            
            Alamofire.request(BaseServiceURL+OrderCart+"/\(cartToken)/add_items?\(paramStrings)", method: .patch, parameters: nil , encoding: URLEncoding.default, headers: ["User-Agent": "iOS"]).responseJSON { (response) in
                self.networkRequestCounter -= 1
                
                guard response.result.isSuccess else {
                    print("Couldn't add items to Cart: \(response.result.error?.localizedDescription)")
                    completion(false, response.result.error?.localizedDescription, nil)
                    return
                }
                
                if let responseData = response.result.value as? [String : AnyObject] {
                    
                    //print(responseData.jsonString)
                    
                    if let cartDetails = responseData["cart"] as? [String : AnyObject] {
                        cartManager.setDetailsInCurrentCart(cartDetails)
                        completion(true, nil, response.result.value as AnyObject?)
                    } else {
                        completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                    }
                } else {
                    completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
                }
            }
        }
    }
    
    func addJewelleryItem(cartParams: String, quantity: Int, completion: @escaping Completion) {
        networkRequestCounter += 1
        
        let cart_token = cartManager.cartToken == nil ? "" : "&cart_token=" + cartManager.cartToken!
        var url = JewelleryURL + OrderCart + "/items?store_id=" + StoreId
        url += cart_token;
        url += "&quantity=\(quantity)"
        url += cartParams
        if let accessToken = customerManager.accessToken {
            url += "&access_token=\(accessToken)"
        }
        
        Alamofire.request(url, method: .post, parameters: nil , encoding: URLEncoding.default, headers: ["User-Agent": "iOS"]).responseJSON { (response) in
            self.networkRequestCounter -= 1
            
            guard response.result.isSuccess else {
                print("Couldn't add items to Cart: \(response.result.error?.localizedDescription)")
                completion(false, response.result.error?.localizedDescription, nil)
                return
            }
            
            if let responseData = response.result.value as? [String : AnyObject] {
                
                //print(responseData.jsonString)
                
                if let cartDetails = responseData["cart"] as? [String : AnyObject] {
                    cartManager.setDetailsInCurrentCart(cartDetails)
                    completion(true, nil, response.result.value as AnyObject?)
                } else {
                    completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                }
            } else {
                completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
            }
        }
    }
    
    func updateItemQuantity(_ variantId: Int, quantity: Int, completion: @escaping Completion) {
        
        if let cartToken = cartManager.cartToken {
            
            networkRequestCounter += 1
            
            var parameters: [String : AnyObject] = ["id" : variantId as AnyObject, "quantity" : quantity as AnyObject]
            
            if let accessToken = customerManager.accessToken {
                parameters["access_token"] = accessToken as AnyObject?
            }
            
            Alamofire.request(BaseServiceURL+OrderCart+"/\(cartToken)/update_quantity", method: .patch, parameters: parameters , encoding: URLEncoding.default, headers: ["User-Agent": "iOS"]).responseJSON { (response) in
                self.networkRequestCounter -= 1
                
                guard response.result.isSuccess else {
                    print("Couldn't update Cart: \(response.result.error?.localizedDescription)")
                    completion(false, response.result.error?.localizedDescription, nil)
                    return
                }
                
                if let responseData = response.result.value as? [String : AnyObject] {
                    
                    //print(responseData.jsonString)
                    
                    if let cartDetails = responseData["cart"] as? [String : AnyObject] {
                        cartManager.setDetailsInCurrentCart(cartDetails)
                        completion(true, nil, response.result.value as AnyObject?)
                    } else {
                        completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                    }
                } else {
                    completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
                }
            }
        }
    }
    
    func removeItem(_ variantId: Int, completion: @escaping Completion) {
        
        if let cartToken = cartManager.cartToken {
            
            networkRequestCounter += 1
            
            var parameters: [String : AnyObject] = ["items[][id]" : variantId as AnyObject]
            
            if let accessToken = customerManager.accessToken {
                parameters["access_token"] = accessToken as AnyObject?
            }
            
            Alamofire.request(BaseServiceURL+OrderCart+"/\(cartToken)/delete", method: .delete, parameters: parameters , encoding: URLEncoding.default, headers: ["User-Agent": "iOS"]).responseJSON { (response) in
                self.networkRequestCounter -= 1
                
                guard response.result.isSuccess else {
                    print("Couldn't remove item from Cart: \(response.result.error?.localizedDescription)")
                    completion(false, response.result.error?.localizedDescription, nil)
                    return
                }
                
                if let responseData = response.result.value as? [String : AnyObject] {
                    //print(responseData.jsonString)
                    
                    if let cartDetails = responseData["cart"] as? [String : AnyObject] {
                        cartManager.setDetailsInCurrentCart(cartDetails)
                        completion(true, nil, response.result.value as AnyObject?)
                    } else {
                        completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                    }
                } else {
                    completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
                }
            }
        }
    }
}

// MARK: Discount/Reward/GiftCard related operations
extension NetworkManager {
    
    public func fetchDiscountCoupons(_ completion: @escaping Completion) {
        
        networkRequestCounter += 1
        
        Alamofire.request(BaseServiceURL+StoreDiscountCoupons, method: .get, parameters: nil , encoding: URLEncoding.default, headers: ["User-Agent": "iOS"]).responseJSON { (response) in
            self.networkRequestCounter -= 1
            
            guard response.result.isSuccess else {
                print("Couldn't fetch Discount coupons: \(response.result.error?.localizedDescription)")
                completion(false, response.result.error?.localizedDescription, nil)
                return
            }
            
            if let responseData = response.result.value as? [String : AnyObject] {
                
                //print(responseData.jsonString)
                
                if let discountArray = responseData["discount_coupons"] as? [[String : AnyObject]] {
                    persistencyManager.replaceAllWithArray("DiscountCoupon", entitiesArray: discountArray)
                    completion(true, nil, response.result.value as AnyObject?)
                } else {
                    completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                }
            } else {
                completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
            }
        }
    }
    
    func applyDiscountCode(_ code: String, completion: @escaping Completion) {
        
        if let cartToken = cartManager.cartToken {
            
            networkRequestCounter += 1
            
            var parameters: [String : AnyObject] = ["discount_coupon_code" : code as AnyObject]
            
            if let accessToken = customerManager.accessToken {
                parameters["access_token"] = accessToken as AnyObject?
            }
            
            Alamofire.request(BaseServiceURL+OrderCart+"/\(cartToken)/apply_discount_coupon", method: .patch, parameters: parameters , encoding: URLEncoding.default, headers: ["User-Agent": "iOS"]).responseJSON { (response) in
                self.networkRequestCounter -= 1
                
                guard response.result.isSuccess else {
                    print("Couldn't apply discount: \(response.result.error?.localizedDescription)")
                    completion(false, response.result.error?.localizedDescription, nil)
                    return
                }
                
                if let responseData = response.result.value as? [String : AnyObject] {
                    
                    //print(responseData.jsonString)
                    
                    if let cartDetails = responseData["cart"] as? [String : AnyObject] {
                        cartManager.setDetailsInCurrentCart(cartDetails)
                        completion(true, nil, response.result.value as AnyObject?)
                    } else {
                        completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                    }
                } else {
                    completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
                }
            }
        }
    }
    
    func removeDiscountCode(_ completion: @escaping Completion) {
        
        if let cartToken = cartManager.cartToken {
            
            networkRequestCounter += 1
            
            var parameters: [String : AnyObject] = [:]
            
            if let accessToken = customerManager.accessToken {
                parameters["access_token"] = accessToken as AnyObject?
            }
            
            Alamofire.request(BaseServiceURL+OrderCart+"/\(cartToken)/remove_discount_coupon", method: .patch, parameters: parameters , encoding: URLEncoding.default, headers: ["User-Agent": "iOS"]).responseJSON { (response) in
                self.networkRequestCounter -= 1
                
                guard response.result.isSuccess else {
                    print("Couldn't remove discount: \(response.result.error?.localizedDescription)")
                    completion(false, response.result.error?.localizedDescription, nil)
                    return
                }
                
                if let responseData = response.result.value as? [String : AnyObject] {
                    
                    if let cartDetails = responseData["cart"] as? [String : AnyObject] {
                        cartManager.setDetailsInCurrentCart(cartDetails)
                        completion(true, nil, response.result.value as AnyObject?)
                    } else {
                        completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                    }
                } else {
                    completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
                }
            }
        }
    }
    
    public func fetchGiftCard(_ code: String, completion: @escaping Completion) {
        
        networkRequestCounter += 1
        
        Alamofire.request(BaseServiceURL+StoreGiftCard+"/\(code)", method: .get,  parameters: nil , encoding: URLEncoding.default, headers: ["User-Agent": "iOS"]).responseJSON { (response) in
            self.networkRequestCounter -= 1
            
            guard response.result.isSuccess else {
                print("Couldn't fetch Gift cards: \(response.result.error?.localizedDescription)")
                completion(false, response.result.error?.localizedDescription, nil)
                return
            }
            
            if (response.result.value as? [String : AnyObject]) != nil {
                //print(responseData.jsonString)
                
                //                if let statesArray = responseData["states"] as? [[String : AnyObject]] {
                //                    persistencyManager.replaceAllWithArray("State", entitiesArray: statesArray)
                //                    completion(true, nil, response.result.value)
                //                } else if let errors = responseData["error"] as? [String] {
                //                    completion(false, errors.first, response.result.value)
                //                } else {
                //                    completion(false, "Couldn't fetch states.", response.result.value)
                //                }
                completion(true, nil, response.result.value as AnyObject?)
            }
        }
    }
    
    func removeGiftCard(_ completion: @escaping Completion) {
        
        if let cartToken = cartManager.cartToken {
            
            networkRequestCounter += 1
            
            var parameters: [String : AnyObject] = [:]
            
            if let accessToken = customerManager.accessToken {
                parameters["access_token"] = accessToken as AnyObject?
            }
            
            Alamofire.request(BaseServiceURL+OrderCart+"/\(cartToken)/remove_gift_card", method: .patch, parameters: parameters , encoding: URLEncoding.default, headers: ["User-Agent": "iOS"]).responseJSON { (response) in
                self.networkRequestCounter -= 1
                
                guard response.result.isSuccess else {
                    print("Couldn't remove gift card: \(response.result.error?.localizedDescription)")
                    completion(false, response.result.error?.localizedDescription, nil)
                    return
                }
                
                if let responseData = response.result.value as? [String : AnyObject] {
                    
                    //print(responseData.jsonString)
                    
                    if let cartDetails = responseData["cart"] as? [String : AnyObject] {
                        cartManager.setDetailsInCurrentCart(cartDetails)
                        completion(true, nil, response.result.value as AnyObject?)
                    }  else {
                        completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                    }
                } else {
                    completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
                }
            }
        }
    }
    
    func applyRewardPoints(_ rewardPoints: Int, completion: @escaping Completion) {
        
        if let cartToken = cartManager.cartToken {
            
            networkRequestCounter += 1
            
            var parameters: [String : AnyObject] = ["reward_points" : rewardPoints as AnyObject]
            
            if let accessToken = customerManager.accessToken {
                parameters["access_token"] = accessToken as AnyObject?
            }
            
            Alamofire.request(BaseServiceURL+OrderCart+"/\(cartToken)/apply_reward_points", method: .patch, parameters: parameters , encoding: URLEncoding.default, headers: ["User-Agent": "iOS"]).responseJSON { (response) in
                self.networkRequestCounter -= 1
                
                guard response.result.isSuccess else {
                    print("Couldn't apply reward points: \(response.result.error?.localizedDescription)")
                    completion(false, response.result.error?.localizedDescription, nil)
                    return
                }
                
                if let responseData = response.result.value as? [String : AnyObject] {
                    
                    //print(responseData.jsonString)
                    
                    if let cartDetails = responseData["cart"] as? [String : AnyObject] {
                        cartManager.setDetailsInCurrentCart(cartDetails)
                        completion(true, nil, response.result.value as AnyObject?)
                    } else {
                        completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                    }
                } else {
                    completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
                }
            }
        }
    }
    
    func removeRewardPoints(_ completion: @escaping Completion) {
        
        if let cartToken = cartManager.cartToken {
            
            networkRequestCounter += 1
            
            var parameters: [String : AnyObject] = [:]
            
            if let accessToken = customerManager.accessToken {
                parameters["access_token"] = accessToken as AnyObject?
            }
            
            Alamofire.request(BaseServiceURL+OrderCart+"/\(cartToken)/remove_reward_points", method: .patch, parameters: parameters , encoding: URLEncoding.default, headers: ["User-Agent": "iOS"]).responseJSON { (response) in
                self.networkRequestCounter -= 1
                
                guard response.result.isSuccess else {
                    print("Couldn't remove reward points: \(response.result.error?.localizedDescription)")
                    completion(false, response.result.error?.localizedDescription, nil)
                    return
                }
                
                if let responseData = response.result.value as? [String : AnyObject] {
                    
                    //print(responseData.jsonString)
                    
                    if let cartDetails = responseData["cart"] as? [String : AnyObject] {
                        cartManager.setDetailsInCurrentCart(cartDetails)
                        completion(true, nil, response.result.value as AnyObject?)
                    } else {
                        completion(false, self.resolveErrorMessage(responseData), response.result.value as AnyObject?)
                    }
                } else {
                    completion(false, self.resolveErrorMessage([:]), response.result.value as AnyObject?)
                }
            }
        }
    }
}
