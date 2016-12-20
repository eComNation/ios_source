//
//  MyFavouritesController.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 15/06/16.
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


class MyFavouritesController: UITableViewController {

    // MARK: Outlets
    @IBOutlet var footerView: UIView!
    @IBOutlet var activityIndicator: NVActivityIndicatorView!
    
    // MARK: Other variables
    var emptyDataView: EmptyDataView? = Bundle.main.loadNibNamed("EmptyDataView", owner: nil, options: nil)?[0] as? EmptyDataView
    
    // MARK: Datasource containers
    var productSectionList: [SectionDetail] = []
    var paginationInfo: PaginationInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        persistencyManager.deleteAll("FavouriteProduct")
        fetchFavouriteProducts()
        
        emptyDataView?.frame = self.tableView.bounds
        self.tableView.backgroundView = emptyDataView
        
        emptyDataView?.onActionButtonTap = {
            self.fetchFavouriteProducts()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        logManager.logScreenWithName(String(describing: MyFavouritesController()))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Preparation methods
    func prepareFavouriteProductsDatasource() {
        
        // Remove all previous sections from product section list
        productSectionList.removeAll()
        
        let mainSection = SectionDetail()
        
        if persistencyManager.count("FavouriteProduct") > 0 {
            
            let favouriteProductOrder = NSSortDescriptor(key: "position", ascending: true)
            let allFavouriteProducts = persistencyManager.fetchAll("FavouriteProduct", predicate: nil, sortDescriptors: [favouriteProductOrder])! as [FavouriteProduct]
            let favouriteProductCellSize = CGSize(width: self.view.frame.width, height: 100)
            for favouriteProduct in allFavouriteProducts {
                let favouriteProductCellDetail = CellDetail()
                favouriteProductCellDetail.cellType = .FavouriteProduct
                favouriteProductCellDetail.cellSize = favouriteProductCellSize
                favouriteProductCellDetail.cellData = favouriteProduct
                mainSection.sectionDataList.append(favouriteProductCellDetail)
            }
        }
        
        productSectionList.append(mainSection)
        tableView.reloadData()
    }

    
    // MARK: Service methods
    func fetchFavouriteProducts() {
        
        if paginationInfo != nil && paginationInfo?.nextPage == 0 {
            return
        }
        
        let page: Int = paginationInfo != nil ? (paginationInfo?.nextPage)! : 1
        
        emptyDataView?.showIndicatorView()
        networkManager.fetchFavouriteProducts(page) { (success, message, response) -> (Void) in
            
            if success {
                if let responseData = response as? [String : AnyObject] {
                    if let pageDict = responseData["pagination_info"] as? [String : AnyObject] {
                        self.paginationInfo = PaginationInfo(dictionary: pageDict)
                    }
                }
                
                if persistencyManager.count("FavouriteProduct") == 0 {
                    self.paginationInfo = nil
                    self.emptyDataView?.showEmptyDataViewWithMessage(message != nil ? message! : "No Favourite Products", buttonTitle: "REFRESH")
                }
                
                self.prepareFavouriteProductsDatasource()
            } else {
                self.emptyDataView?.showEmptyDataViewWithMessage(message != nil ? message! : "No Favourite Products", buttonTitle: "REFRESH")
            }
            
            if self.paginationInfo != nil && self.paginationInfo?.nextPage > 0 {
                self.footerView.isHidden = false
                self.activityIndicator.startAnimation()
            } else {
                self.footerView.isHidden = true
                self.activityIndicator.stopAnimation()
            }
        }
    }

    
    // MARK: Button events
    @IBAction func backTapped(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return productSectionList.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if productSectionList[section].sectionDataList.count == 0 {
            emptyDataView?.isHidden = false
        } else {
            emptyDataView?.isHidden = true
        }
        
        return productSectionList[section].sectionDataList.count
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
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
        
        if (indexPath as NSIndexPath).row == productSectionList[(indexPath as NSIndexPath).section].sectionDataList.count - 1 {
            fetchFavouriteProducts()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavouriteProductCell", for: indexPath) as! FavouriteProductCell
        
        let cellDetail = productSectionList[(indexPath as NSIndexPath).section].sectionDataList[(indexPath as NSIndexPath).row]
        cell.configureWithCellDetail(cellDetail)
        
        cell.removeFavouriteProduct = { [weak cellDetail] in
            
            if let product = cellDetail?.cellData as? FavouriteProduct {
                networkManager.removeFavouriteProduct(product.id, completion: { (success, message, response) -> (Void) in
                    if success {
                        persistencyManager.deleteFirst("FavouriteProduct", predicate: NSPredicate(format: "id = %d",product.id), sortDescriptors: nil)
                        self.prepareFavouriteProductsDatasource()
                        let message = Message(title: "Removed from favourites.", backgroundColor: SuccessGreenColor!)
                        Whisper(message: message, to: self.navigationController!, action: .Show)
                    } else {
                        let message = Message(title: message!, backgroundColor: ErrorRedColor!)
                        Whisper(message: message, to: self.navigationController!, action: .Show)
                    }
                })
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let favouriteProduct = productSectionList[(indexPath as NSIndexPath).section].sectionDataList[(indexPath as NSIndexPath).row].cellData as? FavouriteProduct {
            if let productDetailController = UIStoryboard.productDetailController() {
                productDetailController.favouriteProduct = favouriteProduct
                self.navigationController?.pushViewController(productDetailController, animated: true)
            }
        }
    }
}
