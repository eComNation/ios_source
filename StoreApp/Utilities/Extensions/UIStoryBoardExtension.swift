//
//  UIStoryBoardExtension.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 09/04/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import Foundation
import UIKit

extension UIStoryboard {
    
    class func mainStoryboard() -> UIStoryboard { return UIStoryboard(name: "Main", bundle: Bundle.main) }
    class func loginSignupStoryborad() -> UIStoryboard { return UIStoryboard(name: "LoginSignup", bundle: Bundle.main) }
    class func profileStoryborad() -> UIStoryboard { return UIStoryboard(name: "Profile", bundle: Bundle.main) }
    class func productStoryborad() -> UIStoryboard { return UIStoryboard(name: "ProductDetail", bundle: Bundle.main) }
    
    // From main story board
    class func sidePanelController() -> SidePanelController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "SidePanelController") as? SidePanelController
    }

    class func dashboardController() -> DashboardController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "DashboardController") as? DashboardController
    }
    
    class func productListController() -> ProductListController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "ProductListController") as? ProductListController
    }
    
    class func productDetailController() -> ProductDetailController? {
        return productStoryborad().instantiateViewController(withIdentifier: "ProductDetailController") as? ProductDetailController
    }
    
    class func abJewelsDetailController() -> ABJewelsDetailController? {
        return productStoryborad().instantiateViewController(withIdentifier: "ABJewelsDetailController") as? ABJewelsDetailController
    }
    
    class func storyAtHomeDetailController() -> StoryAtHomeDetailController? {
        return productStoryborad().instantiateViewController(withIdentifier: "StoryAtHomeDetailController") as? StoryAtHomeDetailController
    }
    
    class func myGarmentsDetailController() -> MyGarmentsDetailController? {
        return productStoryborad().instantiateViewController(withIdentifier: "MyGarmentsDetailController") as? MyGarmentsDetailController
    }
    
    class func outletsDetailController() -> OutletsDetailController? {
        return productStoryborad().instantiateViewController(withIdentifier: "OutletsDetailController") as? OutletsDetailController
    }
    
    class func timberfruitDetailController() -> TimberfruitDetailController? {
        return productStoryborad().instantiateViewController(withIdentifier: "TimberfruitDetailController") as? TimberfruitDetailController
    }
    
    class func cartController() -> CartController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "CartController") as? CartController
    }
    
    class func searchController() -> SearchController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "SearchController") as? SearchController
    }
    
    class func categoryController() -> CategoryController? {
        return mainStoryboard().instantiateViewController(withIdentifier: "CategoryController") as? CategoryController
    }
    
    // From login signup story board
    class func loginController() -> LoginController? {
        return loginSignupStoryborad().instantiateViewController(withIdentifier: "LoginController") as? LoginController
    }
    
    class func signUpController() -> SignUpController? {
        return loginSignupStoryborad().instantiateViewController(withIdentifier: "SignUpController") as? SignUpController
    }
    
    class func contactUsController() -> ContactUsController? {
        return loginSignupStoryborad().instantiateViewController(withIdentifier: "ContactUsController") as? ContactUsController
    }
    
    class func forgotPasswordController() -> ForgotPasswordController? {
        return loginSignupStoryborad().instantiateViewController(withIdentifier: "ForgotPasswordController") as? ForgotPasswordController
    }
    
    // From profile storyboard
    class func myAccountController() -> MyAccountController? {
        return profileStoryborad().instantiateViewController(withIdentifier: "MyAccountController") as? MyAccountController
    }
    
    class func myOrdersController() -> MyOrdersController? {
        return profileStoryborad().instantiateViewController(withIdentifier: "MyOrdersController") as? MyOrdersController
    }
    
    class func orderDetailController() -> OrderDetailController? {
        return profileStoryborad().instantiateViewController(withIdentifier: "OrderDetailController") as? OrderDetailController
    }
    
    class func addAddressController() -> AddAddressController? {
        return profileStoryborad().instantiateViewController(withIdentifier: "AddAddressController") as? AddAddressController
    }
}
