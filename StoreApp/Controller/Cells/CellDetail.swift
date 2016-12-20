//
//  CellDetail.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 10/04/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

enum CellType: String {
    case UnKnown
    case MyAccount
    case ContactUs
    case Login
    case SignUp
    case Logout
    case Banner
    case BannerDetail
    case ListBanner
    case FeaturedProductHeader
    case FeaturedProduct
    case StoreDetail
    case ProductCountHeader
    case Product
    case Space
    case ProductImage
    case ProductMultipleImages
    case ProductTitle
    case ProductBrand
    case ProductTitleOnly
    case ProductColorList
    case ProductColor
    case ProductSizeOption
    case ProductSize
    case ProductSizeList
    case ProductPriceOnly
    case ProductQuantity
    case ProductPincode
    case ProductPincodeMessage
    case ProductDetailTabs
    case ProductDescription
    case DescriptionPair
    case ProductDetail
    case ProductHelp
    case ProductCare
    case RelatedProducts
    case SimilarProducts
    case RecentProducts
    case OrderInfo
    case FavouriteProduct
    case OrderBasicInfo
    case OrderItemsInfo
    case OrderPricingInfo
    case Address
    case CartItem
    case CartDiscount
    case CartReward
    case CartPriceSubtotal
    case CartPriceTotal
    case CartPriceDiscount
    case CartPriceGiftCard
    case CartPriceRewardPoints
    case Text
}

class CellDetail: NSObject {

    var cellType: CellType = .UnKnown
    var cellSize: CGSize = CGSize.zero
    var cellWidth: CGFloat {
        return cellSize.width
    }
    var cellHeight: CGFloat {
        return cellSize.height
    }
    
    var cellData: AnyObject?
    
    var cellText: String?
    var cellAttributedText: NSAttributedString?
    var cellAnimationDelay: Double = 0.0
}
