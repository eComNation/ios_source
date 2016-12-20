//
//  AppConstants.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 06/04/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import Foundation
import UIKit

// MARK: Sizing related constants

var ScreenWidth: CGFloat {
    return UIScreen.main.bounds.size.width
}

var ScreenHeight: CGFloat {
    return UIScreen.main.bounds.size.height
}

// MARK: Global predicates
let FeaturedProductPredicate = NSPredicate(format: "isFeatured = %@", true as CVarArg)
let RelatedProductPredicate = NSPredicate(format: "isRelated = %@", true as CVarArg)
let RecentProductPredicate = NSPredicate(format: "isRecent = %@", true as CVarArg)
let SimilarProductPredicate = NSPredicate(format: "isSimilar = %@", true as CVarArg)
let NormalProductPredicate = NSPredicate(format: "isFeatured = %@ AND isRelated = %@ AND isRecent = %@ AND isSimilar = %@", false as CVarArg, false as CVarArg, false as CVarArg, false as CVarArg)


enum ProductDetailTab: Int {
    case tab1
    case detail
    case tab2
    case tab3
    case tab4
}

// MARK: Service related constants

let StoreCountries = "/api/v1/countries"
let StoreContact = "/api/v1/store/contact_us"

let StoreCategoriesRoot = "/api/v1/store/categories"
let StoreBanners = "/api/v1/store/home_page/banners"
let StoreCategoryFilterAttributes = "/api/v1/store/filter_attributes"

let StoreFeaturedProducts = "/api/v1/store/products/featured"
let StoreProducts = "/api/v1/store/products"
let StoreDiscountCoupons = "/api/v1/store/discount_coupons"
let StoreGiftCard = "/api/v1/store/gift_cards"

let CustomerSignup = "/api/v1/store/customer/accounts/sign_up"
let CustomerSignin = "/api/v1/store/customer/accounts/sign_in"
let CustomerSigninGoogle = "/api/v1/store/customer/accounts/sign_in_with_google"
let CustomerSigninFacebook = "/api/v1/store/customer/accounts/sign_in_with_facebook"

let CustomerProfile = "/api/v1/store/customer/profile"
let CustomerUpdateProfile = "/api/v1/store/customer/update_profile"
let CustomerChangePassword = "/api/v1/store/customer/change_password"
let CustomerOrders = "/api/v1/store/customer/orders"
let CustomerAddresses = "/api/v1/store/customer/addresses"
let CustomerPasswordReset = "/api/v1/store/customer/accounts/forgot_password"
let CustomerFavouriteProduct = "/api/v1/store/customer/favourite_products"

let OrderCart = "/api/v1/store/cart"
let OrderCartCreate = "/api/v1/store/cart/create"
let OrderCheckout = "/checkouts/init?"

let JewelleryURL = "http://jewelcommerce.my39shop.com/"
let ReviewURL = "http://reviews.my39shop.com/"
let MarketPlaceURL = "http://marketplace.my39shop.com/"

// MARK: Notifications
let CartUpdateNotification = "CartUpdated"
let UserLoggedOutNotification = "UserLoggedOut"

// MARK: Global functions
func executeAfter(_ delay:Double, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(
        deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}
