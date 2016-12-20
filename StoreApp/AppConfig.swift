//
//  AppConfig.swift
//  StoreApp
//
//  Created by Abhilesh Halarnkar on 20/10/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import Foundation

// MARK: Global color componants
let BaseApplicationColor = UIColor(hexString: "43311D")
let FadedApplicationColor = UIColor(hexString: "95837F")

let SidePanelBGColor = UIColor(hexString: "43311D")
let SidePanelCellColor = UIColor(hexString: "E7D8C7")
let SidePanelTextColor = UIColor(hexString: "777777")

let GeneralButtonColor = UIColor(hexString: "FF6600")
let ClickedButtonColor = UIColor(hexString: "1D1600")
let NavigationBarTitleColor = UIColor.white
let ErrorRedColor = UIColor(hexString: "d32f2f")
let SuccessGreenColor = UIColor(hexString: "4caf50")
let LightBackColor = UIColor(hexString: "F2F2F2")
let FooterColor = UIColor(hexString: "43311D")
let CopyrightTextColor = UIColor(hexString: "FFFFFF")

// MARK: Size components
var ProductDetailImageCellWidthByHeightFactor = 1.0
var FeaturedProductCellWidthByHeightFactor = 0.8
var BannerCellWidthByHeightFactor = 1.6
var BannerListCellWidthByHeightFactor = 1.48
var SidePanelSize: CGFloat {
    return UIScreen.main.bounds.size.width * 0.7
}

//  5504 hiva
//  5626 greenobazaar
//  5628 shubharambh
//  5645 timberfruit
//  5651 addwik
//  5668 abjewels
//  5674 surplusnation
//  5678 mygarments
//  5680 storyhomes
//  5684 outletsindia

// MARK: Global application related string constants
let StoreId = "5626"

let StoreType = ""

let ApplicationName = "Store App"
let BaseServiceURL = "http://greenobazaar.my39shop.com/"

let ProductShareURL = "https://outletsindia.my39shop.com/products/"

let PincodeURL = "http://hiva.my39shop.com/store_data/store_5504/available_pincodes.json"

let ApplicationId = "1142092238"

let ApplicationClientId = "5d19221ad03c83909da4bb4ff93c09a2a86647c8e067d790e5d3198b44c184d9"
let ApplicationClientSecret = "34f4f1a8da5219134d54b5b71f84ecdee644f587285d62ea9be602d836c4db66"

let GoogleSignInClientId = ""
let FacebookSignInClientId = ""
let GoogleAnalyticsTrackingId = "UA-80376498-5"

let ProductColor = "http://d27afjhe0vu8x.cloudfront.net/store_5684/"

let ContactPhone = "9898989898"
let ContactMail = "asdadadsdas"

let CopyrightText = "© TIMBERFRUIT ALL RIGHTS RESERVED | POWERED BY ECOMNATION"

let TabHeader1 = "Product Details"
let TabHeader2 = ""
let TabHeader3 = ""
let TabHeader4 = ""

let TabText1 = ""
let TabText2 = "Do not use blade while opening.\n\nOpen the parcel from one side and slowly tear up the packaging."

let TabText3 = "Owned by Elite Decor Pvt. Ltd., Story@Home deals in a vast range of home furnishing products such as bed sheets, blankets, quilts, comforters, pillows, bathrooms sets, decorative vases and more.\nWith the prime focus to offer amazing home products at attractive prices, Story@Home is a growing premium brand in India which aims to dress up homes and give them a fresh feel that has never experienced before."

let TabText4 = ""

let ApplicationFBLink = "https://www.facebook.com/"
let ApplicationTwitterLink = "sfsdf"
let ApplicationInstagramLink = "sfsdfds"
let ApplicationPinterestLink = ""
let ApplicationYoutubeLink = "gfhgg"
let ApplicationGPlusLink = ""

// MARK: Conditional features
let IsPinCodeCheckIsEnabled = true
let ShowsDetailsTab = false
let EnableDiscountListing = true
let EnableOutOfStock = true
let AllowsProductImagesAutoAnimation = false
let ShowLoaderIcon = true

let categoryListing: [Int32] = [5699 , 5834 , 5833]

let sort_display: [String] = ["Default" , "Title A-Z" , "Title Z-A" , "Price Low-High" , "Price High-Low"]

let sort_criteria: [String] = ["priority" , "title_ascending" , "title_descending" , "price_ascending" , "price_descending"]


