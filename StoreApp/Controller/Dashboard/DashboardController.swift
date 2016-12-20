 //
//  ViewController.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 06/04/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit
import Material
import AlamofireImage
import Whisper

let kBannerCellIdentifier = "BannerCell"
let kListBannerCellIdentifier = "ListBannerCell"
let kFeaturedProductHeaderCellIdentifier = "FeaturedProductHeaderCell"
let kFeaturedProductCellIdentifier = "FeaturedProductCell"
let kStoreDetailCellIdentifier = "StoreDetailCell"

class DashboardController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: Outlets
    @IBOutlet var collDashBoardDetail: UICollectionView!
    @IBOutlet var cartButton: RPUIBarButton!
    @IBOutlet var viewTabbarContainer: UIView!
    @IBOutlet var tabBarHeight: NSLayoutConstraint!
    
    // MARK: Tabbar related properties
    var topTabbar: TabBar?
    var btnHome: FlatButton?
    var btnFeaturedCollection: FlatButton?
    var hasFeaturedProducts: Bool = false
    var isDataLoaded : Bool = false
    
    // MARK: Side Panel related properties
    var sidePanel: SidePanelController?
    var currentPanelState: SidePanelState = .closed
    var overlayButton: UIButton?
    
    // MARK: Dashboard detail collection
    var sectionList: [SectionDetail] = []
    var paginationInfo: PaginationInfo?
    
    var emptyDataView: EmptyDataView? = Bundle.main.loadNibNamed("EmptyDataView", owner: nil, options: nil)?[0] as? EmptyDataView
    
    // MARK: Life-cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(receivedCartUpdate), name: NSNotification.Name(rawValue: CartUpdateNotification), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userLoggedOut), name: NSNotification.Name(rawValue: UserLoggedOutNotification), object: nil)
        
        // Set title of navigation bar
        self.title = ApplicationName
//        let image = UIImage(named: "logo_large")
//        self.navigationItem.titleView = UIImageView(image: image)
        
        networkManager.busyNavigationController = self.navigationController
        
        // Remove all featured products
        persistencyManager.deleteAll("Product", predicate: FeaturedProductPredicate)

        // empty data view
        emptyDataView?.frame = view.bounds
        view.addSubview(emptyDataView!)
        
        emptyDataView?.onActionButtonTap = {
            self.fetchNecessayDetailsFromServer()
        }
        
        fetchNecessayDetailsFromServer()
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.onSignupActivation = {
                self.redirectToLogin()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        logManager.logScreenWithName(String(describing: DashboardController()))
        
        if isDataLoaded {
            if hasFeaturedProducts {
                self.prepareDashBoardDetails(true)
            } else {
                self.prepareDashboardWithoutFeaturedProducts(true)
            }
        }
        
        cartButton.badgeString = cartManager.cartCountString
        cartButton.badgeTextColor = UIColor.white
        cartButton.badgeBackgroundColor = GeneralButtonColor!
        cartButton.badgeEdgeInsets = UIEdgeInsetsMake(10, 0, 0, 10)
        
        self.view.layoutIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        redirectToLogin()
        print("Content offset: \(collDashBoardDetail.contentOffset)")
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
                Whisper(message: message, to: self.navigationController!, action: .Show)
            })
        }
    }
    
    // MARK: Preparing collectionview resources
    func prepareDashBoardDetails(_ shouldReload: Bool) {
        
        // Remove all data first
        sectionList.removeAll()

        let mainSection = SectionDetail()
        mainSection.footerSize = CGSize(width: self.view.frame.width, height: 40)
        
        if btnHome?.isSelected == true {
            
            let normalBannerPredicate = NSPredicate(format: "is_list = %@", true as CVarArg)
            if persistencyManager.count("Banner", predicate: normalBannerPredicate) > 0 {
                
                let bannerCellDetail = CellDetail()
                bannerCellDetail.cellType = .Banner
                bannerCellDetail.cellSize = CGSize(width: self.view.frame.width, height: self.view.frame.width / CGFloat(BannerCellWidthByHeightFactor))
                let bannerOrder = NSSortDescriptor(key: "position", ascending: true)
                bannerCellDetail.cellData = persistencyManager.fetchAll("Banner", predicate: normalBannerPredicate, sortDescriptors: [bannerOrder])! as [Banner] as AnyObject?
                mainSection.sectionDataList.append(bannerCellDetail)
            }
            
            let listBannerPredicate = NSPredicate(format: "is_list = %@", false as CVarArg)
            if persistencyManager.count("Banner", predicate: normalBannerPredicate) > 0 {
                
                let bannerOrder = NSSortDescriptor(key: "position", ascending: true)
                let allListBanners = persistencyManager.fetchAll("Banner", predicate: listBannerPredicate, sortDescriptors: [bannerOrder])! as [Banner]
                
                for banner in allListBanners {
                    let bannerCellDetail = CellDetail()
                    bannerCellDetail.cellType = .ListBanner
                    //let requiredHeight = banner.bannerHeight > 0 ? CGFloat(banner.bannerHeight) : self.view.frame.width / CGFloat(BannerListCellWidthByHeightFactor)
                    bannerCellDetail.cellSize = CGSize(width: self.view.frame.width, height: self.view.frame.width * CGFloat(banner.heightByWidth))
                    bannerCellDetail.cellData = banner
                    mainSection.sectionDataList.append(bannerCellDetail)
                }
            }
            

            let storeDetailCellDetail = CellDetail()
            storeDetailCellDetail.cellType = .StoreDetail
            storeDetailCellDetail.cellSize = CGSize(width: self.view.frame.width, height: 140)
            mainSection.sectionDataList.append(storeDetailCellDetail)
        }
        
        if btnFeaturedCollection?.isSelected == true {
            
            if persistencyManager.count("Product", predicate: FeaturedProductPredicate) > 0 {
                
                let productOrder = NSSortDescriptor(key: "position", ascending: true)
                let allProducts = persistencyManager.fetchAll("Product", predicate: FeaturedProductPredicate, sortDescriptors: [productOrder])! as [Product]
                let productCellSize = CGSize(width: self.view.frame.width / 2, height: (self.view.frame.width / 2) / CGFloat(FeaturedProductCellWidthByHeightFactor))
                for product in allProducts {
                    let productCellDetail = CellDetail()
                    productCellDetail.cellType = .FeaturedProduct
                    productCellDetail.cellSize = productCellSize
                    productCellDetail.cellData = product
                    mainSection.sectionDataList.append(productCellDetail)
                }
            }
        }

        sectionList.append(mainSection)
        
        if shouldReload {
            collDashBoardDetail.reloadData()
        }
    }
    
    func prepareDashboardWithoutFeaturedProducts(_ shouldReload: Bool) {
        // Remove all data first
        sectionList.removeAll()
        
        let mainSection = SectionDetail()
        mainSection.footerSize = CGSize(width: self.view.frame.width, height: 40)
        
        let normalBannerPredicate = NSPredicate(format: "is_list = %@", true as CVarArg)
        if persistencyManager.count("Banner", predicate: normalBannerPredicate) > 0 {
            
            let bannerCellDetail = CellDetail()
            bannerCellDetail.cellType = .Banner
            bannerCellDetail.cellSize = CGSize(width: self.view.frame.width, height: self.view.frame.width / CGFloat(BannerCellWidthByHeightFactor))
            let bannerOrder = NSSortDescriptor(key: "position", ascending: true)
            bannerCellDetail.cellData = persistencyManager.fetchAll("Banner", predicate: normalBannerPredicate, sortDescriptors: [bannerOrder])! as [Banner] as AnyObject?
            mainSection.sectionDataList.append(bannerCellDetail)
        }
        
        let listBannerPredicate = NSPredicate(format: "is_list = %@", false as CVarArg)
        if persistencyManager.count("Banner", predicate: normalBannerPredicate) > 0 {
            
            let bannerOrder = NSSortDescriptor(key: "position", ascending: true)
            let allListBanners = persistencyManager.fetchAll("Banner", predicate: listBannerPredicate, sortDescriptors: [bannerOrder])! as [Banner]
            
            for banner in allListBanners {
                let bannerCellDetail = CellDetail()
                bannerCellDetail.cellType = .ListBanner
                //let requiredHeight = banner.bannerHeight > 0 ? CGFloat(banner.bannerHeight) : self.view.frame.width / CGFloat(BannerListCellWidthByHeightFactor)
                bannerCellDetail.cellSize = CGSize(width: self.view.frame.width, height: self.view.frame.width * CGFloat(banner.heightByWidth))
                bannerCellDetail.cellData = banner
                mainSection.sectionDataList.append(bannerCellDetail)
            }
        }
        
        
        let storeDetailCellDetail = CellDetail()
        storeDetailCellDetail.cellType = .StoreDetail
        storeDetailCellDetail.cellSize = CGSize(width: self.view.frame.width, height: 140)
        mainSection.sectionDataList.append(storeDetailCellDetail)
        
        sectionList.append(mainSection)
        
        if shouldReload {
            collDashBoardDetail.reloadData()
        }
        
    }
    
    func prepareUIRelatedResources() {
        
        // Add tabbar to container view
        topTabbar = TabBar(frame: viewTabbarContainer.bounds)
        topTabbar!.backgroundColor = UIColor.clear
        topTabbar!.lineColor = UIColor.white
        topTabbar!.borderWidth = 0.0
        topTabbar!.height = 40.0
        
        viewTabbarContainer.backgroundColor = BaseApplicationColor
        viewTabbarContainer.addSubview(topTabbar!)
        
        btnHome = FlatButton()
        btnHome!.pulseColor = Material.Color.white
        btnHome!.setTitle("HOME", for: UIControlState())
        btnHome!.setTitleColor(FadedApplicationColor, for: UIControlState())
        btnHome!.setTitleColor(UIColor.white, for: .selected)
        btnHome!.titleLabel?.font = UIFont.boldSystemFont(ofSize: 10)
        btnHome!.borderWidth = 0.0
        btnHome!.isSelected = true
        btnHome!.addTarget(self, action: #selector(homeTapped(_:)), for: .touchUpInside)
        
        btnFeaturedCollection = FlatButton()
        btnFeaturedCollection!.pulseColor = Material.Color.white
        btnFeaturedCollection!.setTitle("FEATURED COLLECTION", for: UIControlState())
        btnFeaturedCollection!.setTitleColor(FadedApplicationColor, for: UIControlState())
        btnFeaturedCollection!.setTitleColor(UIColor.white, for: .selected)
        btnFeaturedCollection!.titleLabel?.font = UIFont.boldSystemFont(ofSize: 10)
        btnFeaturedCollection!.borderWidth = 0.0
        btnFeaturedCollection!.isSelected = false
        btnFeaturedCollection!.addTarget(self, action: #selector(featuredCollectionTapped(_:)), for: .touchUpInside)
        
        topTabbar!.buttons = [btnHome!, btnFeaturedCollection!]
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
        
        // Fetch banners
        networkManager.fetchBanners(16) { (success, message, response) -> (Void) in
        }

        // Fetch all filters
        networkManager.fetchFilterAttributes { (success, message, response) -> (Void) in
        }
        
        // Fetch pincodes
        networkManager.fetchAvailablePincodes { (success, message, response) -> (Void) in
        }
        
        // Fetch featured products
        fetchFeaturedProducts()
    }
    
    func fetchFeaturedProducts() {
        
        let page: Int = paginationInfo != nil ? (paginationInfo?.nextPage)! : 1
        networkManager.fetchFeaturedProducts(page) { (success, message, response) -> (Void) in
            
            if (success) {
                if let responseData = response as? [String : AnyObject] {
                    if let pageDict = responseData["pagination_info"] as? [String : AnyObject] {
                        self.paginationInfo = PaginationInfo(dictionary: pageDict)
                    }
                }
                self.hasFeaturedProducts = persistencyManager.count("Product", predicate: FeaturedProductPredicate) > 0
                
                self.isDataLoaded = true
                
                if self.hasFeaturedProducts {
                    self.tabBarHeight.constant = 40
                    self.prepareUIRelatedResources()
                    self.prepareDashBoardDetails(true)
                } else {
                    self.tabBarHeight.constant = 0
                    self.prepareDashboardWithoutFeaturedProducts(true)
                }
                
                self.emptyDataView!.isHidden = true
            }
        }
    }
    
    // MARK: CollectionView flow layout delegates
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return sectionList[(indexPath as NSIndexPath).section].sectionDataList[(indexPath as NSIndexPath).row].cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionList[section].sectionInset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return sectionList[section].headerSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        
        if btnFeaturedCollection?.isSelected == false {
            return CGSize.zero
        }
        
        if paginationInfo == nil {
            return CGSize.zero
        }
        
        if paginationInfo != nil && paginationInfo?.nextPage == 0 {
            return CGSize.zero
        }
        
        return sectionList[section].footerSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionList[section].lineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return sectionList[section].itemSpacing
    }
    
    // MARK: CollectionView delegates
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        
        if btnFeaturedCollection?.isSelected == true {
            fetchFeaturedProducts()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let sectionDetail = sectionList[(indexPath as NSIndexPath).section]
        let cellDetail = sectionDetail.sectionDataList[(indexPath as NSIndexPath).row]
        
        switch cellDetail.cellType {
        case .FeaturedProduct:
            if let product = cellDetail.cellData as? Product {
                let productDetailController = utility.getDetailsController()
                productDetailController.product = product
                self.navigationController?.pushViewController(productDetailController, animated: true)
            }
        
        case .ListBanner:
            if let banner = cellDetail.cellData as? Banner {
                if banner.category_id > 0 {
                    if let category: Category = persistencyManager.fetchFirst("Category", predicate: NSPredicate(format: "id == %d", banner.category_id), sortDescriptors: nil) {
                        let productListController = UIStoryboard.productListController()
                        productListController?.selectedCategory = category
                        self.navigationController?.pushViewController(productListController!, animated: true)
                    }
                }
            }
            
        default:
            break
        }
    }
    
    // MARK: CollectionView datasource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sectionList[section].sectionDataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "LoadingFooterView", for: indexPath) as! LoadingFooterView
        view.indicatorView.startAnimation()
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let sectionDetail = sectionList[(indexPath as NSIndexPath).section]
        let cellDetail = sectionDetail.sectionDataList[(indexPath as NSIndexPath).row]
        
        switch cellDetail.cellType {
        case .Banner:
            let bannerCell = collectionView.dequeueReusableCell(withReuseIdentifier: kBannerCellIdentifier, for: indexPath) as! BannerCell
            bannerCell.configureWithCellDetail(cellDetail)
            bannerCell.tappedBanner = { (banner) in
                if banner.category_id > 0 {
                    if let category: Category = persistencyManager.fetchFirst("Category", predicate: NSPredicate(format: "id == %d", banner.category_id), sortDescriptors: nil) {
                        self.sidePanel?.onCategorySelected!(category,categoryListing.contains(category.id))
                    }
                }
            }
            
            return bannerCell
        
        case .ListBanner:
            let listBannerCell = collectionView.dequeueReusableCell(withReuseIdentifier: kListBannerCellIdentifier, for: indexPath) as! ListBannerCell
            listBannerCell.configureWithCellDetail(cellDetail)
            /*listBannerCell.downloadedImage = { (image) in
                print(image.size.height)
                cellDetail.cellSize = CGSize(width: image.size.width, height: image.size.height)
                collectionView.reloadData()
            }*/
            return listBannerCell
            
        case .FeaturedProductHeader:
            let productHeaderCell = collectionView.dequeueReusableCell(withReuseIdentifier: kFeaturedProductHeaderCellIdentifier, for: indexPath) as! FeaturedProductHeaderCell
            return productHeaderCell
            
        case .FeaturedProduct:
            let productCell = collectionView.dequeueReusableCell(withReuseIdentifier: kFeaturedProductCellIdentifier, for: indexPath) as! FeaturedProductCell
            productCell.configureWithCellDetail(cellDetail)
            return productCell
            
        case .StoreDetail:
            let storeCell = collectionView.dequeueReusableCell(withReuseIdentifier: kStoreDetailCellIdentifier, for: indexPath) as! StoreDetailCell
            storeCell.configureWithCellDetail()
            storeCell.selectedProductImage = { (imageURL) in
                UIApplication.shared.openURL(URL(string: imageURL)!)
            }
            return storeCell
            
        default:
            break
        }
        
        return UICollectionViewCell()
    }
    
    // MARK: Button events
    @IBAction func menuButtonTapped(_ sender: UIBarButtonItem) {
        toggleSidePanel()
    }
    
    @IBAction func searchTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.pushViewController(UIStoryboard.productListController()!, animated: true)
    }
    
    @IBAction func cartTapped(_ sender: RPUIBarButton) {
        self.navigationController?.pushViewController(UIStoryboard.cartController()!, animated: true)
    }
    
    func homeTapped(_ sender: FlatButton) {
        
        sender.isSelected = true
        btnFeaturedCollection?.isSelected = false
        
        self.collDashBoardDetail.setContentOffset(CGPoint.zero, animated: false)
        prepareDashBoardDetails(true)
    }
    
    func featuredCollectionTapped(_ sender: FlatButton) {
        
        sender.isSelected = true
        btnHome?.isSelected = false
        
        self.collDashBoardDetail.setContentOffset(CGPoint.zero, animated: false)
        prepareDashBoardDetails(true)
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
            if sidePanel == nil || overlayButton == nil {
                setUpSidePanelResources()
            }
       
            UIApplication.shared.keyWindow?.addSubview((overlayButton)!)
            UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions(), animations: {
                self.overlayButton?.alpha = 1.0
                }, completion: nil)
            
            
            UIApplication.shared.keyWindow?.addSubview((sidePanel?.view)!)
            sidePanel?.didMove(toParentViewController: self)
            UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions(), animations: {
                self.sidePanel?.view.frame.origin.x = 0
                }, completion: nil)
            
        } else if currentPanelState == .opened {
            currentPanelState = .closed
            if sidePanel != nil {
                UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions(), animations: {
                    self.sidePanel?.view.frame.origin.x = -SidePanelSize
                    }, completion: { (finished) in
                        if finished {
                            self.sidePanel?.view.removeFromSuperview()
                        }
                })
            }

            if overlayButton != nil {
                UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions(), animations: {
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
                
                let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
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

