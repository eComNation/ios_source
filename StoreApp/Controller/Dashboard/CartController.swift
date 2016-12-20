//
//  CartController.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 28/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit
import Whisper
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


class CartController: UIViewController {

    @IBOutlet var btnCheckout: UIBarButtonItem!
    @IBOutlet var tblCart: UITableView!
    @IBOutlet var checkoutWebView: UIWebView!
    @IBOutlet var cartViewLeft: NSLayoutConstraint!
    @IBOutlet var btnProceedToCheckout: UIButton!
    
    var buyingItemId: Int = 0
    var buyingQuantity: Int = 0
    var cartParameters: String?
    var selectedColor: String?
    var customAttributes: [String:String]?
    var selectedVariants: [ProductVariant]?
    
    var updatingVariantId: Int = 0
    var updatingQuantity: Int = 0
    
    var isWebViewVisible: Bool = false
    
    // MARK: Other variables
    var emptyDataView: EmptyDataView? = Bundle.main.loadNibNamed("EmptyDataView", owner: nil, options: nil)?[0] as? EmptyDataView
    
    // MARK: Datasource containers
    var orderSectionList: [SectionDetail] = []
    
//    var authRequest : NSURLRequest? = nil
//    var authenticated = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Cart"
        
        prepareUIRelatedResources()
        prepareOrdersDatasource()
        fetchCart()
        fetchDiscountCoupons()
        
        emptyDataView?.frame = tblCart.bounds
        tblCart.backgroundView = emptyDataView
        
        emptyDataView?.onActionButtonTap = {
            self.fetchCart()
        }
        
        btnCheckout.isEnabled = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        logManager.logScreenWithName(String(describing: CartController()))
        
        NotificationCenter.default.addObserver(self, selector: #selector(receivedCartUpdate), name: NSNotification.Name(rawValue: CartUpdateNotification), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: CartUpdateNotification), object: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Notification listeners
    func receivedCartUpdate() {
        DispatchQueue.main.async {
            executeAfter(1.0, closure: {
                if cartManager.cartCount > 0 {
                    self.title = "CART(\(cartManager.cartCount))"
                    self.btnProceedToCheckout.isHidden = false
                } else {
                    self.title = "CART"
                    self.btnProceedToCheckout.isHidden = true
                }
            })
        }
    }
    
    func prepareUIRelatedResources() {
        
        btnProceedToCheckout.backgroundColor = GeneralButtonColor
    }
    
    // MARK: Preparation methods
    func prepareOrdersDatasource() {
        
        // Remove all previous sections from product section list
        orderSectionList.removeAll()
        
        btnProceedToCheckout.isHidden = true
        
        if let currentCart = cartManager.currentCart {

            guard currentCart.itemsCount > 0 else {
                self.title = "CART"
                tblCart.reloadData()
                btnProceedToCheckout.isHidden = true
                return
            }

            btnProceedToCheckout.isHidden = false
            let mainSection = SectionDetail()
            self.title = "CART(\(currentCart.itemsCount))"
            
            // Prepare items cell info
            let cartItemPredicate = NSPredicate(format: "SELF.cart != nil")
            let cartItemOrder = NSSortDescriptor(key: "position", ascending: true)
            if let allCartItems = persistencyManager.fetchAll("OrderItem", predicate: cartItemPredicate, sortDescriptors: [cartItemOrder]) ,  allCartItems.count > 0 {
                
                for cartItem in allCartItems {
                    let cartItemCellDetail = CellDetail()
                    cartItemCellDetail.cellType = .CartItem
                    cartItemCellDetail.cellSize = CGSize(width: self.view.frame.width, height: 100)
                    cartItemCellDetail.cellData = cartItem
                    mainSection.sectionDataList.append(cartItemCellDetail)
                }
            }
            
            // Prepare discount cell info
            if currentCart.needsDiscountField {
                let cartDiscountCellDetail = CellDetail()
                cartDiscountCellDetail.cellType = .CartDiscount
                cartDiscountCellDetail.cellSize = CGSize(width: self.view.frame.width, height: 60)
                cartDiscountCellDetail.cellData = currentCart
                mainSection.sectionDataList.append(cartDiscountCellDetail)
            }
            
            // Prepare reward cell info
            if currentCart.available_reward_points > 0 && currentCart.reward_points == 0 {
                let cartRewardCellDetail = CellDetail()
                cartRewardCellDetail.cellType = .CartReward
                cartRewardCellDetail.cellSize = CGSize(width: self.view.frame.width, height: 80)
                cartRewardCellDetail.cellData = currentCart
                mainSection.sectionDataList.append(cartRewardCellDetail)
            }
            
            // Prepare Subtotal cell info
            let cartSubtotalCellDetail = CellDetail()
            cartSubtotalCellDetail.cellType = .CartPriceSubtotal
            cartSubtotalCellDetail.cellSize = CGSize(width: self.view.frame.width, height: 50)
            cartSubtotalCellDetail.cellData = currentCart
            mainSection.sectionDataList.append(cartSubtotalCellDetail)
            
            // Prepare Discount price cell info
            let cartDiscountCellDetail = CellDetail()
            cartDiscountCellDetail.cellType = .CartPriceDiscount
            cartDiscountCellDetail.cellSize = CGSize(width: self.view.frame.width, height: 50)
            cartDiscountCellDetail.cellData = currentCart
            mainSection.sectionDataList.append(cartDiscountCellDetail)
            
            // Prepare gift card cell info
            if currentCart.gift_card_amount > 0 {
                let cartGiftCardCellDetail = CellDetail()
                cartGiftCardCellDetail.cellType = .CartPriceGiftCard
                cartGiftCardCellDetail.cellSize = CGSize(width: self.view.frame.width, height: 50)
                cartGiftCardCellDetail.cellData = currentCart
                mainSection.sectionDataList.append(cartGiftCardCellDetail)
            }
            
            // Prepare reward points cell info
            if currentCart.reward_points > 0 {
                let cartRewardCellDetail = CellDetail()
                cartRewardCellDetail.cellType = .CartPriceRewardPoints
                cartRewardCellDetail.cellSize = CGSize(width: self.view.frame.width, height: 50)
                cartRewardCellDetail.cellData = currentCart
                mainSection.sectionDataList.append(cartRewardCellDetail)
            }
            
            // Prepare Total cell info
            let cartTotalCellDetail = CellDetail()
            cartTotalCellDetail.cellType = .CartPriceTotal
            cartTotalCellDetail.cellSize = CGSize(width: self.view.frame.width, height: 50)
            cartTotalCellDetail.cellData = currentCart
            mainSection.sectionDataList.append(cartTotalCellDetail)
            
            orderSectionList.append(mainSection)
        }
        
        tblCart.reloadData()
    }

    func resolveDisplay(_ shouldAnimate: Bool = true) {
        
        if isWebViewVisible {
            if customerManager.isCustomerLoggedIn {
                redirectToCheckout()
            } else {
                let loginScreen = UIStoryboard.loginController()
                loginScreen?.isForCheckout = true
                loginScreen?.loginCompleted = {
                    self.redirectToCheckout(shouldAnimate)
                }
                
                loginScreen?.checkoutAsGuest = {
                    self.redirectToCheckout(shouldAnimate)
                }
                
                self.navigationController?.pushViewController(loginScreen!, animated: true)
            }

        } else {

            let theURL = "about:blank"
            let theRequestURL = URL (string: theURL)
            let theRequest = URLRequest (url: theRequestURL!)
            checkoutWebView.loadRequest(theRequest)
            
            btnCheckout.isEnabled = false
            cartViewLeft.constant = 0
            if shouldAnimate {
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.layoutIfNeeded()
                })
            } else {
                self.view.layoutIfNeeded()
            }
            
            fetchCart()
        }
    }
    
    func redirectToCheckout(_ shouldAnimate: Bool = true) {
        
        var checkoutURLString = BaseServiceURL+OrderCheckout + "is_mobile=true"
        
        if let cartToken = cartManager.cartToken {
            checkoutURLString = checkoutURLString + "&cart_id=\(cartToken)"
        }
        
        if let accessToken = customerManager.accessToken {
            checkoutURLString = checkoutURLString + "&access_token=\(accessToken)"
        }
        
        print("Checkout URL: \(checkoutURLString)")
        
        let checkoutRequestURL = URL (string: checkoutURLString)
        let checkoutRequest = URLRequest (url: checkoutRequestURL!)
        checkoutWebView.delegate = self
        checkoutWebView.loadRequest(checkoutRequest)
        
        btnCheckout.isEnabled = true
        cartViewLeft.constant = -(self.view.frame.size.width)
        if shouldAnimate {
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
        } else {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: Service related jobs
    func fetchDiscountCoupons() {
        
        networkManager.fetchDiscountCoupons { (success, message, response) -> (Void) in
            self.prepareOrdersDatasource()
        }
    }
    
    func fetchCart() {
        
        emptyDataView?.showIndicatorView()
        networkManager.fetchCurrentCart { (success, message, response) -> (Void) in
            
            if success {
                self.prepareOrdersDatasource()
                
                switch StoreType {
                case utility.JEWELLERY:
                    self.addJewelleryItemToCart()
                default:
                    self.addItemToCart()
                }
                
            } else {
                if cartManager.isCartAvailable {
                    let message = Message(title: message!, backgroundColor: ErrorRedColor!)
                    Whisper(message: message, to: self.navigationController!, action: .Show)
                    self.emptyDataView?.showEmptyDataViewWithMessage("Cart is empty", buttonTitle: nil)
                    self.prepareOrdersDatasource()
                } else {
                    self.emptyDataView?.showEmptyDataViewWithMessage("Cart is empty", buttonTitle: nil)
                    
                    switch StoreType {
                    case utility.JEWELLERY:
                        self.addJewelleryItemToCart()
                    default:
                        self.createCart()
                    }
                }
            }
        }
    }
    
    func createCart() {
        
        if (buyingItemId == 0 || buyingQuantity == 0) && (selectedVariants == nil) {
            if cartManager.cartCount == 0 {
                emptyDataView?.showEmptyDataViewWithMessage("Cart is empty", buttonTitle: nil)
            }
            return
        }

        var itemIds: [Int] = []
        var quantities: [Int] = []
        
        if buyingItemId > 0 && buyingQuantity > 0 {
            itemIds = [buyingItemId]
            quantities = [buyingQuantity]
        } else if selectedVariants?.count > 0 {
            itemIds = (selectedVariants?.map({ Int($0.id) }))!
            quantities = (selectedVariants?.map({ Int($0.selectedQuantity) }))!
        }
        
        emptyDataView?.showIndicatorView()
        networkManager.createCart(itemIds, quantities: quantities, customAttribute: customAttributes) { (success, message, response) -> (Void) in
            if success {
                
                self.buyingItemId = 0
                self.buyingQuantity = 0
                self.selectedVariants = nil
                
                self.prepareOrdersDatasource()
            } else {
                let message = Message(title: message!, backgroundColor: ErrorRedColor!)
                Whisper(message: message, to: self.navigationController!, action: .Show)
                self.emptyDataView?.showEmptyDataViewWithMessage("Cart is empty", buttonTitle: nil)
            }
        }
    }
    
    func addItemToCart() {
        
        print(selectedVariants?.count ?? 0)
        if (buyingItemId == 0 || buyingQuantity == 0) && (selectedVariants == nil) {
            if cartManager.cartCount == 0 {
                emptyDataView?.showEmptyDataViewWithMessage("Cart is empty", buttonTitle: nil)
            }
            return
        }
        
        if cartManager.cartCount == 0 {
            emptyDataView?.showIndicatorView()
        }

        var itemIds: [Int] = []
        var quantities: [Int] = []
        
        if buyingItemId > 0 && buyingQuantity > 0 {
            itemIds = [buyingItemId]
            quantities = [buyingQuantity]
        } else if selectedVariants?.count > 0 {
            itemIds = (selectedVariants?.map({ Int($0.id) }))!
            quantities = (selectedVariants?.map({ Int($0.selectedQuantity) }))!
        }
        
        networkManager.addItem(itemIds, quantities: quantities, customAttribute: customAttributes) { (success, message, response) -> (Void) in
            if success {
                
                self.buyingItemId = 0
                self.buyingQuantity = 0
                self.selectedVariants = nil
                
                self.prepareOrdersDatasource()
            } else {
                let message = Message(title: message!, backgroundColor: ErrorRedColor!)
                Whisper(message: message, to: self.navigationController!, action: .Show)
                self.emptyDataView?.showEmptyDataViewWithMessage("Cart is empty", buttonTitle: nil)
            }
        }
    }
    
    func addJewelleryItemToCart() {
        
        if (buyingQuantity == 0) {
            if cartManager.cartCount == 0 {
                emptyDataView?.showEmptyDataViewWithMessage("Cart is empty", buttonTitle: nil)
            }
            return
        }
        
        if cartManager.cartCount == 0 {
            emptyDataView?.showIndicatorView()
        }
        
        networkManager.addJewelleryItem(cartParams: cartParameters!, quantity: buyingQuantity) { (success, message, response) -> (Void) in
            if success {
                
                self.buyingItemId = 0
                self.buyingQuantity = 0
                self.selectedVariants = nil
                
                self.prepareOrdersDatasource()
            } else {
                let message = Message(title: message!, backgroundColor: ErrorRedColor!)
                Whisper(message: message, to: self.navigationController!, action: .Show)
                self.emptyDataView?.showEmptyDataViewWithMessage("Cart is empty", buttonTitle: nil)
            }
        }
    }
    
    func updateQuantity() {

        networkManager.updateItemQuantity(updatingVariantId, quantity: self.updatingQuantity, completion: { (success, message, response) -> (Void) in
            
            if success {
                self.updatingVariantId = 0
                self.updatingQuantity = 0
                self.prepareOrdersDatasource()
            } else {
                let message = Message(title: message!, backgroundColor: ErrorRedColor!)
                Whisper(message: message, to: self.navigationController!, action: .Show)
            }
        })
    }
    
    func removeItem() {
        
        let alertViewController = UIAlertController(title: "Warning", message: "Are you sure you want to remove this item?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "YES", style: .default) { (action) -> Void in
            networkManager.removeItem(self.updatingVariantId, completion: { (success, message, response) -> (Void) in
                
                if success {
                    self.updatingVariantId = 0
                    self.updatingQuantity = 0
                    
                    if cartManager.cartCount == 0 {
                        self.emptyDataView?.showEmptyDataViewWithMessage("Cart is empty", buttonTitle: nil)
                    }
                    
                    self.prepareOrdersDatasource()
                } else {
                    let message = Message(title: message!, backgroundColor: ErrorRedColor!)
                    Whisper(message: message, to: self.navigationController!, action: .Show)
                }
            })
        }
        
        let cancelAction = UIAlertAction(title: "NO", style: .cancel) { (action) -> Void in
            
        }
        
        alertViewController.addAction(cancelAction)
        alertViewController.addAction(okAction)
        
        self.present(alertViewController, animated: true, completion: nil)
    }
    
    // MARK: Button events
    @IBAction func btnBackTapped(_ sender: AnyObject) {
        
        if isWebViewVisible {
            isWebViewVisible = false
            resolveDisplay()
        } else {
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func proceedToCheckoutTapped(_ sender: UIButton) {
        
//        if let currentCart = cartManager.currentCart where currentCart.isQuantityValidInAllOrderedItems == false  {
//            SweetAlert().showAlert("Warning", subTitle: "Some items in your cart are no longer available in the selected quantities.", style: AlertStyle.Warning, buttonTitle: "Ok")
//            return
//        }
        
        isWebViewVisible = true
        resolveDisplay()
    }
    
}

// MARK: - Table view data source
extension CartController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if orderSectionList.count == 0 {
            emptyDataView?.isHidden = false
        } else {
            emptyDataView?.isHidden = true
        }
        
        return orderSectionList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if orderSectionList[section].sectionDataList.count == 0 {
            emptyDataView?.isHidden = false
        } else {
            emptyDataView?.isHidden = true
        }
        
        return orderSectionList[section].sectionDataList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return orderSectionList[(indexPath as NSIndexPath).section].sectionDataList[(indexPath as NSIndexPath).row].cellSize.height
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        // Set separator insets
        if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
            cell.separatorInset = UIEdgeInsets.zero
        }
        
        if cell.responds(to: #selector(setter: UIView.preservesSuperviewLayoutMargins)) {
            cell.preservesSuperviewLayoutMargins = false
        }
        
        if cell.responds(to: #selector(setter: UIView.layoutMargins)) {
            cell.layoutMargins = UIEdgeInsets.zero
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellDetail = orderSectionList[(indexPath as NSIndexPath).section].sectionDataList[(indexPath as NSIndexPath).row]
        
        switch cellDetail.cellType {
            
        case .CartItem:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CartItemCell", for: indexPath) as! CartItemCell
            cell.configureWithCellDetail(orderSectionList[(indexPath as NSIndexPath).section].sectionDataList[(indexPath as NSIndexPath).row])
            
            cell.increaseQuantity = { [weak cellDetail]() -> (Int) in
                
                if let orderItem = cellDetail?.cellData as? OrderItem {
                
                    self.updatingQuantity = Int(orderItem.quantity) + 1
                    self.updatingVariantId = Int(orderItem.variant_id)
                    self.updateQuantity()
                    
                    return self.updatingQuantity
                }
                
                return 1
            }
            
            cell.decreaseQuantity = { [weak cellDetail]() -> (Int) in
                if let orderItem = cellDetail?.cellData as? OrderItem , orderItem.quantity > 1 {
                    
                    self.updatingQuantity = Int(orderItem.quantity) - 1
                    self.updatingVariantId = Int(orderItem.variant_id)
                    self.updateQuantity()
                    
                    return self.updatingQuantity
                }
                return 1
            }
            
            cell.removeItem = { [weak cellDetail]() -> () in
                if let orderItem = cellDetail?.cellData as? OrderItem {

                    self.updatingVariantId = Int(orderItem.variant_id)
                    self.removeItem()
                }
            }
            
            return cell
        
        case .CartDiscount:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CartDiscountCell", for: indexPath) as! CartDiscountCell
            cell.configureWithCellDetail(orderSectionList[(indexPath as NSIndexPath).section].sectionDataList[(indexPath as NSIndexPath).row])
            
            cell.applyCode = { [weak cell](code: String?) in
                
                if let discountCode = code , discountCode.isEmpty == false {
                    networkManager.applyDiscountCode(discountCode, completion: { [weak cell](success, message, response) -> (Void) in
                        if success {
                            self.prepareOrdersDatasource()
                            cell?.txtDiscount.text = ""
                        } else {
                            _ = SweetAlert().showAlert("Failed", subTitle: message != nil ? message! : "Something went wrong", style: AlertStyle.error, buttonTitle: "Ok")
                        }
                    })
                } else {
                    let message = Message(title: "Discount code can't be empty.", backgroundColor: ErrorRedColor!)
                    Whisper(message: message, to: self.navigationController!, action: .Show)
                }
            }
            return cell
         
        case .CartReward:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CartRewardCell", for: indexPath) as! CartRewardCell
            cell.configureWithCellDetail(orderSectionList[(indexPath as NSIndexPath).section].sectionDataList[(indexPath as NSIndexPath).row])
            
            cell.applyRewardPoints = { [weak cell](points: Int) in
                
                if points <= 0 {
                    let message = Message(title: "Invalid number of reward points.", backgroundColor: ErrorRedColor!)
                    Whisper(message: message, to: self.navigationController!, action: .Show)
                    return
                }
                
                networkManager.applyRewardPoints(points, completion: { [weak cell](success, message, response) -> (Void) in
                    if success {
                        self.prepareOrdersDatasource()
                        cell?.txtRewardPoints.text = ""
                    } else {
                        _ = SweetAlert().showAlert("Failed", subTitle: message != nil ? message! : "Something went wrong", style: AlertStyle.error, buttonTitle: "Ok")
                    }
                })
            }
            
            return cell
            
        case .CartPriceSubtotal, .CartPriceTotal, .CartPriceDiscount, .CartPriceGiftCard, .CartPriceRewardPoints:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CartPricingCell", for: indexPath) as! CartPricingCell
            cell.configureWithCellDetail(orderSectionList[(indexPath as NSIndexPath).section].sectionDataList[(indexPath as NSIndexPath).row])
            cell.removeTapped = {
                
                switch cellDetail.cellType {
                case .CartPriceDiscount:
                    networkManager.removeDiscountCode({ (success, message, response) -> (Void) in
                        if success {
                            self.prepareOrdersDatasource()
                        } else {
                            _ = SweetAlert().showAlert("Failed", subTitle: message != nil ? message! : "Something went wrong", style: AlertStyle.error, buttonTitle: "Ok")
                        }
                    })
                    
                case .CartPriceGiftCard:
                    networkManager.removeGiftCard({ (success, message, response) -> (Void) in
                        if success {
                            self.prepareOrdersDatasource()
                        } else {
                            _ = SweetAlert().showAlert("Failed", subTitle: message != nil ? message! : "Something went wrong", style: AlertStyle.error, buttonTitle: "Ok")
                        }
                    })
                    
                case .CartPriceRewardPoints:
                    networkManager.removeRewardPoints({ (success, message, response) -> (Void) in
                        if success {
                            self.prepareOrdersDatasource()
                        } else {
                            _ = SweetAlert().showAlert("Failed", subTitle: message != nil ? message! : "Something went wrong", style: AlertStyle.error, buttonTitle: "Ok")
                        }
                    })
                    
                default:
                    break
                }
                
            }
            return cell

        default:
            break
        }
        
        return UITableViewCell()
    }
}

// MARK: Webview delegates
extension CartController: UIWebViewDelegate {
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {

        print("Will load url: \(request.url?.absoluteString)")
        
        if (request.url?.absoluteString.contains("login"))! {
            let newURLString = request.url?.absoluteString.replacingOccurrences(of: "login", with: "shipping")
            let checkoutRequestURL = URL (string: newURLString!)
            let checkoutRequest = URLRequest (url: checkoutRequestURL!)
            self.checkoutWebView.loadRequest(checkoutRequest)
            return false
        }
        else if request.url?.absoluteString == "http://railsteam.com/" || request.url?.absoluteString == BaseServiceURL+"/" {
            fetchCart()
            _ = self.navigationController?.popToRootViewController(animated: true)
            return false
        }
        
//        if !authenticated {
//            authRequest = request
//            let urlConnection: NSURLConnection = NSURLConnection(request: request, delegate: self)!
//            urlConnection.start()
//            return false
//        }
        
        return true
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        print("Webview failed to load URL: \(error.localizedDescription)")
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        print("Webview started loading page: \(webView.request?.mainDocumentURL?.absoluteString)")
        if let requestString = webView.request?.mainDocumentURL?.absoluteString , requestString.contains("confirm") {
            fetchCart()
            _ = self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        print("Webview finished loading page: \(webView.request?.mainDocumentURL?.absoluteString)")
    }
}

//extension CartController: NSURLConnectionDelegate {
//    
//    func connection(connection: NSURLConnection, willSendRequestForAuthenticationChallenge challenge: NSURLAuthenticationChallenge) {
//        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
//            challenge.sender!.useCredential(NSURLCredential(forTrust: challenge.protectionSpace.serverTrust!), forAuthenticationChallenge: challenge)
//        }
//        challenge.sender!.continueWithoutCredentialForAuthenticationChallenge(challenge)
//    }
//    
//    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
//        authenticated = true
//        connection.cancel()
//        self.checkoutWebView.loadRequest(authRequest!)
//    }
//}
