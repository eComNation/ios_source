//
//  BaseDetailController.swift
//  StoreApp
//
//  Created by Abhilesh Halarnkar on 19/10/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit
import SKPhotoBrowser
import Whisper

class BaseDetailController: UIViewController {
    
    // MARK: Other properties
    var emptyDataView: EmptyDataView? = Bundle.main.loadNibNamed("EmptyDataView", owner: nil, options: nil)?[0] as? EmptyDataView
    
    var activePinCode: String?
    var activePinCodeMessage: String = ""
    
    @IBOutlet var tblProductDetail: UITableView!
    @IBOutlet var cartButton: RPUIBarButton!
    @IBOutlet var btnBuy: UIButton!
    
    // MARK: Datasource containers
    var product: Product?
    var favouriteProduct: FavouriteProduct?
    var sectionList: [SectionDetail] = []
    var selectedQuantity: Int = 1
    var isDescriptionExpanded: Bool = false
    var selectedDetailTab: ProductDetailTab = .tab1
    
    var currentProductId: Int32 {
        if product != nil {
            return (product?.id)!
        } else if favouriteProduct != nil {
            return (favouriteProduct?.id)!
        }
        return 0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Remove all related products
        persistencyManager.deleteAll("Product", predicate: RelatedProductPredicate)
        
        // Remove all recent products
        persistencyManager.deleteAll("Product", predicate: RecentProductPredicate)
        
        // Remove all similar products
        persistencyManager.deleteAll("Product", predicate: SimilarProductPredicate)
        
        emptyDataView?.frame = view.bounds
        view.addSubview(emptyDataView!)
        
        emptyDataView?.onActionButtonTap = {
            self.fetchProductDetails()
        }
        
        prepareUIRelatedResources()
        prepareDataSources()
        fetchProductDetails()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        logManager.logScreenWithName(String(describing: TimberfruitDetailController()))
        
        NotificationCenter.default.addObserver(self, selector: #selector(receivedCartUpdate), name: NSNotification.Name(rawValue: CartUpdateNotification), object: nil)
        
        cartButton.badgeString = cartManager.cartCountString
        cartButton.badgeTextColor = UIColor.white
        cartButton.badgeBackgroundColor = GeneralButtonColor!
        cartButton.badgeEdgeInsets = UIEdgeInsetsMake(10, 0, 0, 10)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: CartUpdateNotification), object: nil)
        
        self.product?.stopImageTimer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        cartButton.badgeString = cartManager.cartCountString
        
        if product != nil {
            customerManager.addRecentProduct(Int((product?.id)!))
        }
    }
    
    // MARK: Notification listeners
    func receivedCartUpdate() {
        DispatchQueue.main.async {
            self.cartButton.badgeString = cartManager.cartCountString
        }
    }
    
    func prepareUIRelatedResources() {
    }
    
    // MARK: Preparation Operations
    func prepareDataSources(shouldReload: Bool = true) {
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Service related jobs
    func fetchProductDetails() {
        
        SelectedSize = ""
        
        if currentProductId == 0 {
            return
        }
        
        self.emptyDataView?.isHidden = false
        emptyDataView?.showIndicatorView()
        networkManager.fetchProductDetailForProductId(currentProductId, completion: { (success, message, response) -> (Void) in
            
            if success {
                if let responseDate = response {
                    if let productDict = responseDate["product"] as? [String : AnyObject] {
                        let isFeatured = self.product?.isFeatured
                        if self.product != nil {
                            self.product?.setWithDictionary(productDict, position: Int((self.product?.position)!))
                            self.product?.isFeatured = isFeatured!
                        } else {
                            self.product = persistencyManager.prepare("Product", entityData: productDict, position: persistencyManager.count("Product")) as? Product
                        }
                        persistencyManager.saveContext()
                    }
                }
                
                self.product?.selectedVariant = self.product?.default_variant
                
                self.fetchSimilarProducts()
                
            } else {
                self.emptyDataView?.showEmptyDataViewWithMessage(message != nil ? message! : "Something went wrong", buttonTitle: "REFRESH")
            }
        })
    }
    
    func fetchSimilarProducts() {
        
        if currentProductId == 0 {
            self.fetchRecentProducts()
            return
        }
        
        // Remove all similar products
        persistencyManager.deleteAll("Product", predicate: SimilarProductPredicate)
        
        networkManager.fetchSimilarProductsForProductId(currentProductId) { (success, message, response) -> (Void) in
            
            self.fetchRecentProducts()
        }
    }
    
    func fetchRecentProducts() {
        
        let recentDetailsPredicate = NSPredicate(format: "id != %d", product != nil ? (product?.id)! : 0)
        guard let allRecentDetails: [RecentProduct] = persistencyManager.fetchAll("RecentProduct", predicate: recentDetailsPredicate, sortDescriptors: [NSSortDescriptor(key: "insertedOn", ascending: true)]) , allRecentDetails.count > 0 else {
            self.getAddedData(result: "")
            return
        }
        
        let idsList = allRecentDetails.map({ return String($0.id) }).joined(separator: ",")
        print("Recent products: \(idsList)")
        
        let parameters: [String : AnyObject] = ["page": 1 as AnyObject,
                                                "per_page": 6 as AnyObject,
                                                "facets": false as AnyObject,
                                                "ids": idsList as AnyObject]
        
        networkManager.fetchProductMatchingDetails(parameters, isRecent: true) { (success, message, response) -> (Void) in
            self.getAddedData(result: "")
        }
    }
    
    // MARK: Utility functions
    func getFetchDetails(isFacet: Bool) -> [String : AnyObject] {
        
        var parameters: [String : AnyObject] = ["page": 1 as AnyObject,
                                                "per_page": 6 as AnyObject,
                                                "facets": isFacet as AnyObject]
        
        if let categoryId = product?.category_id , categoryId > 0 {
            parameters["active_category"] = Int(categoryId) as AnyObject?
        }
        
        return parameters
    }
    
    func getAddedData(result: String){
    }

    func reloadDetailWithProduct(newProduct: Product) {
        tblProductDetail.setContentOffset(CGPoint.zero, animated:true)
        executeAfter(1.0) {
            self.product?.stopImageTimer()
            self.product = newProduct
            
            if self.product != nil {
                customerManager.addRecentProduct(Int((self.product?.id)!))
            }
            
            self.selectedQuantity = 1
            
            // Remove all related products
            persistencyManager.deleteAll("Product", predicate: RelatedProductPredicate)
            
            // Remove all recent products
            persistencyManager.deleteAll("Product", predicate: RecentProductPredicate)
            
            self.fetchProductDetails()
        }
    }
    
    func openImageBrowser(_ originImage: UIImage?, originView: UIView) {
        
        // create PhotoBrowser Instance, and present.
        if let allImage = product?.skPhotos {
            var browser = SKPhotoBrowser(photos: allImage)
            if originImage != nil {
                browser = SKPhotoBrowser(originImage: originImage!, photos: allImage, animatedFromView: originView)
            }
            browser.bounceAnimation = true
            browser.displayCloseButton = true
            browser.initializePageIndex((product?.currentImage)!)
            present(browser, animated: true, completion: {})
        }
    }
    
    // MARK: Button events
    @IBAction func backTapped(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func favouriteTapped(_ sender: UIBarButtonItem) {
        
        if customerManager.isCustomerLoggedIn && currentProductId > 0 {
            addCurrentProductToFavorite()
        } else if !customerManager.isCustomerLoggedIn {
            let loginController = UIStoryboard.loginController()
            loginController?.needsToAddProductToFavorite = true
            loginController?.loginCompleted = {
                executeAfter(2.0, closure: {
                    self.addCurrentProductToFavorite()
                })
            }
            self.navigationController?.pushViewController(loginController!, animated: true)
        }
    }
    
    func addCurrentProductToFavorite() {
        networkManager.addFavouriteProduct(currentProductId, completion: { (success, message, response) -> (Void) in
            
            if success {
                let message = Message(title: "Added to favourites.", backgroundColor: SuccessGreenColor!)
                Whisper(message: message, to: self.navigationController!, action: .Show)
            } else {
                let message = Message(title: message!, backgroundColor: ErrorRedColor!)
                Whisper(message: message, to: self.navigationController!, action: .Show)
            }
        })
    }
    
    @IBAction func cartTapped(_ sender: RPUIBarButton) {
        self.navigationController?.pushViewController(UIStoryboard.cartController()!, animated: true)
    }
    
    //MARK: Share Product
    @IBAction func shareTapped(_ sender: UIBarButtonItem) {
        let productName = self.product!.name
        let permalink = self.product!.permalink
        let productURL = ProductShareURL + (permalink ?? "")
        
        let activityViewController = UIActivityViewController(activityItems: [productName ?? "", productURL], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
}
