//
//  WebDashboardViewController.swift
//  ViraniGems
//
//  Created by Rushi Sangani on 14/09/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit
import Material
import AlamofireImage
import Whisper

class WebDashboardViewController: UIViewController, UIWebViewDelegate {

    // MARK: Outlets
    @IBOutlet var cartButton: RPUIBarButton!
    @IBOutlet weak var webView: UIWebView!
    
    // MARK: Side Panel related properties
    var sidePanel: SidePanelController?
    var currentPanelState: SidePanelState = .closed
    var overlayButton: UIButton?
    var webDashBoardURL = BaseServiceURL + "pages/mobile_home"
    
    // MARK: Other properties
    var emptyDataView: EmptyDataView? = Bundle.main.loadNibNamed("EmptyDataView", owner: nil, options: nil)?[0] as? EmptyDataView
    
    // MARK: Life-cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(receivedCartUpdate), name: NSNotification.Name(rawValue: CartUpdateNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userLoggedOut), name: NSNotification.Name(rawValue: UserLoggedOutNotification), object: nil)
        
        // Set title of navigation bar
        self.title = ApplicationName
        
        networkManager.busyNavigationController = self.navigationController
        
        // Remove all products
        persistencyManager.deleteAll("Product", predicate: NormalProductPredicate)
        
        // empty data view
        emptyDataView?.frame = view.bounds
        view.addSubview(emptyDataView!)
        
        emptyDataView?.onActionButtonTap = {
            self.loadRequest()
        }
        
        // fetch details from server
        fetchNecessayDetailsFromServer()
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            
            appDelegate.onSignupActivation = {
                self.redirectToLogin()
            }
        }
        
        self.webView.delegate = self
        // load webview request
        loadRequest()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //super.viewWillAppear(true)
        
        //logManager.logScreenWithName(String(DashboardController))
        logManager.logScreenWithName(String(describing: WebDashboardViewController()))
        
        cartButton.badgeString = cartManager.cartCountString
        cartButton.badgeTextColor = UIColor.white
        cartButton.badgeBackgroundColor = GeneralButtonColor!
        cartButton.badgeEdgeInsets = UIEdgeInsetsMake(10, 0, 0, 10)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //redirectToLogin()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Notification listeners
    func receivedCartUpdate() {
        DispatchQueue.main.async {
            self.cartButton.badgeString = cartManager.cartCountString
        }
    }
    
    func userLoggedOut() {
        DispatchQueue.main.async {
            executeAfter(0.5, closure: {
                let message = Message(title: "Logout successful", backgroundColor: SuccessGreenColor!)
                
                if(self.navigationController != nil){
                    Whisper(message: message, to: self.navigationController!, action: .Show)
                }
            })
        }
    }
    
    func fetchNecessayDetailsFromServer() {
        
        // Fetch categories for store
        networkManager.fetchStoreCategories { (success, message, response) -> (Void) in
            if (success) {
                if (self.currentPanelState == .opened && self.sidePanel != nil) {
                    self.sidePanel?.prepareDataSources(true, animateCell: true, direction: .leftToRight)
                }
            }
        }
        
        // Fetch all filters
        networkManager.fetchFilterAttributes { (success, message, response) -> (Void) in
        }
        
        // Fetch pincodes
        networkManager.fetchAvailablePincodes { (success, message, response) -> (Void) in
        }
        
        // Fetch featured products
        networkManager.fetchFeaturedProducts(1) { (success, message, response) -> (Void) in
        }
    }
    
    //MARK: Load Request
    
    func loadRequest() {
        
        setUpSidePanelResources()
        
        let url = NSURL(string: webDashBoardURL)! as NSURL
        webView.loadRequest(NSURLRequest(url: url as URL) as URLRequest)
    }
    
    //MARK: WEBVIEW Delegate
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        // show home page only
        if request.url?.absoluteString == webDashBoardURL {
            return true
        }
        
        let host = request.url?.host
        if((host?.contains("facebook"))! || (host?.contains("twitter"))! || (host?.contains("instagram"))! || (host?.contains("pinterest"))! || (host?.contains("google"))! || (host?.contains("youtube"))! ){
            
            UIApplication.shared.openURL(request.url!)
            return false
            
        }
        
        let path = request.url!.path as String
        let paths = NSArray(array: path.characters.split(separator: "/").map(String.init))
        
        // get product id
        if path.lowercased().range(of: "products") != nil {
            let productId = paths.lastObject as! String
            if productId != "" {
                navigateToProductDetails(productId: productId)
            }
        }
            
        // get category id
        if path.lowercased().range(of: "categories") != nil {
            let categoryId = paths.lastObject as! String
            if categoryId != "" {
                navigateToCategoryDetails(categoryId: categoryId)
            }
        }
        
        return false
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        emptyDataView?.isHidden = false
        emptyDataView?.showIndicatorView()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        emptyDataView?.isHidden = true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        emptyDataView?.isHidden = true
    }
    
    //MARK: Navigate to Category details
    func navigateToCategoryDetails(categoryId: String) {
        
        print("CATEGORY ID: \(categoryId)")
        
        let categoryIdentifier = Int32(categoryId)
        
        if(categoryIdentifier != nil){
            
            if let category: Category = persistencyManager.fetchFirst("Category", predicate: NSPredicate(format: "id == %d", categoryIdentifier!), sortDescriptors: nil) {
                
                self.sidePanel?.onCategorySelected!(category,categoryListing.contains(category.id))
            }
        }
    }
    
    //MARK: Navigate to Category details
    func navigateToProductDetails(productId: String) {
        
        if let product: Product = persistencyManager.fetchFirst("Product", predicate: NSPredicate(format: "id == %d", Int32(productId)!), sortDescriptors: nil)  {
        
            let productDetailController = utility.getDetailsController()
            productDetailController.product = product
            self.navigationController?.pushViewController(productDetailController, animated: true)
        }
    }
    
    // MARK: Button events
    @IBAction func menuButtonTapped(_ sender: UIBarButtonItem) {
        toggleSidePanel()
    }
    
    @IBAction func searchTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.pushViewController(UIStoryboard.productListController()!, animated: true)
    }
    
    @IBAction func cartButtonTapped(_ sender: RPUIBarButton) {
        self.navigationController?.pushViewController(UIStoryboard.cartController()!, animated: true)
    }
    
    // MARK: Side panel handling
    func setUpSidePanelResources() {
        
        // Set overlay button
        overlayButton = UIButton(frame: (UIApplication.shared.keyWindow?.bounds)!)
        overlayButton?.backgroundColor = UIColor(white: 0, alpha: 0.8)
        overlayButton?.alpha = 0
        overlayButton?.addTarget(self, action: #selector(toggleSidePanel), for: .touchUpInside)
        
        // Set and animate side panel
        sidePanel = UIStoryboard.sidePanelController()
        sidePanel?.view.frame.origin.x = -SidePanelSize
        sidePanel?.view.frame.size.width = SidePanelSize
        
        // Listen for account option selected
        sidePanel?.onAccountOptionSelected = { (option: CellType) -> Void in
            self.toggleSidePanel()
            
            switch option {
            case .MyAccount:
                if customerManager.isCustomerLoggedIn {
                self.navigationController?.pushViewController(UIStoryboard.myAccountController()!, animated: true)
                } else {
                    self.navigationController?.pushViewController(UIStoryboard.loginController()!, animated: true)
                }
            case .ContactUs: self.navigationController?.pushViewController(UIStoryboard.contactUsController()!, animated: true)
            case .Login: self.navigationController?.pushViewController(UIStoryboard.loginController()!, animated: true)
            case .SignUp: self.navigationController?.pushViewController(UIStoryboard.signUpController()!, animated: true)
            case .Logout:
                let alertViewController = UIAlertController(title: "Warning", message: "Are you sure you want to logout?", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "YES", style: .default) { (action) -> Void in
                    customerManager.logoutCustomer()
                    let message = Message(title: "Logout successful", backgroundColor: SuccessGreenColor!)
                    Whisper(message: message, to: self.navigationController!, action: .Show)
                }
                
                let cancelAction = UIAlertAction(title: "NO", style: .cancel) { (action) -> Void in
                    
                }
                
                alertViewController.addAction(cancelAction)
                alertViewController.addAction(okAction)
                
                self.present(alertViewController, animated: true, completion: nil)
                
            default:break
            }
            
        }
        
        // Listen for category selection
        sidePanel?.onCategorySelected = { (category, isForListing) -> Void in
            
            if self.currentPanelState == .opened {
                self.toggleSidePanel()
            }
            
            print("Selected category: \(category.name)")
            
            if isForListing {
                let categoryController = UIStoryboard.categoryController()
                categoryController?.selectedCategory = category
                self.navigationController?.pushViewController(categoryController!, animated: true)
            } else {
                let productListController = UIStoryboard.productListController()
                productListController?.selectedCategory = category
                self.navigationController?.pushViewController(productListController!, animated: true)
            }
        }
    }
    
    func toggleSidePanel() {
        if currentPanelState == .closed {
            currentPanelState = .opened
            
            UIApplication.shared.keyWindow?.addSubview((overlayButton)!)
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.overlayButton?.alpha = 1.0
                }, completion: nil)
            
            
            UIApplication.shared.keyWindow?.addSubview((sidePanel?.view)!)
            sidePanel?.didMove(toParentViewController: self)
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.sidePanel?.view.frame.origin.x = 0
                }, completion: nil)
            
        } else if currentPanelState == .opened {
            currentPanelState = .closed
            if sidePanel != nil {
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                    self.sidePanel?.view.frame.origin.x = -SidePanelSize
                    }, completion: { (finished) in
                        if finished {
                            self.sidePanel?.view.removeFromSuperview()
                        }
                })
            }
            
            if overlayButton != nil {
                UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                    self.overlayButton?.alpha = 0
                    }, completion: { (finished) in
                        if finished {
                            self.overlayButton?.removeFromSuperview()
                        }
                })
            }
        }
    }
    
    // MARK: Utility methods
    func redirectToLogin() {
        
        _ = self.navigationController?.popToRootViewController(animated: false)
        if UserDefaults.standard.bool(forKey: kRedirectToLogin) == true {
            UserDefaults.standard.set(false, forKey: kRedirectToLogin)
            
            if let loginController = UIStoryboard.loginController() {
                
                self.navigationController?.pushViewController(loginController, animated: true)
                
                let delayTime = DispatchTime.now()
                DispatchQueue.main.asyncAfter(deadline: delayTime) {
                    let alertViewController = UIAlertController(title: "Congratulations!", message: "Your Id is activated now. Please, Login with you Id.", preferredStyle: .alert)
                    
                    let okAction = UIAlertAction(title: "Ok", style: .default) { (action) -> Void in
                    }
                    
                    alertViewController.addAction(okAction)
                    loginController.present(alertViewController, animated: true, completion: nil)
                }
            }
        }
    }
}
