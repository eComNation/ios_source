//
//  TimberDetailController.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 27/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit
import SKPhotoBrowser
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

class TimberfruitDetailController: BaseDetailController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.product?.selectedColor = nil
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    override func prepareUIRelatedResources() {
        
        // Set button buy hidden initially
        btnBuy.isHidden = true
    }
    
    // MARK: Preparation Operations
    func prepareDataSources(_ shouldReload: Bool = true) {

        sectionList.removeAll()
        
        if product != nil {
            
            if product?.default_variant?.quantity == 0 {
                btnBuy.setTitle("OUT OF STOCK", for: UIControlState())
                btnBuy.backgroundColor = UIColor.darkGray
                btnBuy.isEnabled = false
            } else {
                btnBuy.setTitle("ADD TO CART", for: UIControlState())
                btnBuy.backgroundColor = GeneralButtonColor
                btnBuy.isEnabled = true
            }
            
            executeAfter(0.2, closure: {
                self.btnBuy.isHidden = false
            })
            
            let sectionDetail = SectionDetail()
            sectionDetail.sectionType = .ProductDetail
            sectionDetail.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)

            // Prepare image cell detail
            let imageCellDetail = CellDetail()
            imageCellDetail.cellData = product
            imageCellDetail.cellType = .ProductImage
            imageCellDetail.cellSize = CGSize(width: self.view.frame.width , height: self.view.frame.width / CGFloat(ProductDetailImageCellWidthByHeightFactor))
            sectionDetail.sectionDataList.append(imageCellDetail)
            
            // Prepare title cell detail
            if product?.custom_attributes?.count == 0 {
                let titleCellDetail = CellDetail()
                titleCellDetail.cellData = product
                titleCellDetail.cellType = .ProductTitle
                titleCellDetail.cellSize = CGSize(width: self.view.frame.width , height: 63 + (product?.name?.heightWithConstrainedWidth(width: self.view.frame.width - 16, font: UIFont.systemFont(ofSize: 22)))!)
                sectionDetail.sectionDataList.append(titleCellDetail)
            } else {
                let titleCellDetail = CellDetail()
                titleCellDetail.cellData = product
                titleCellDetail.cellType = .ProductTitleOnly
                titleCellDetail.cellSize = CGSize(width: self.view.frame.width , height: 31 + (product?.name?.heightWithConstrainedWidth(width: self.view.frame.width - 16, font: UIFont.systemFont(ofSize: 22)))!)
                sectionDetail.sectionDataList.append(titleCellDetail)
                
                let colorListCellDetail = CellDetail()
                colorListCellDetail.cellData = product
                colorListCellDetail.cellType = .ProductColorList
                colorListCellDetail.cellSize = CGSize(width: self.view.frame.width , height: 100)
                sectionDetail.sectionDataList.append(colorListCellDetail)
                
            }
            
            // Prepare size cell detail
            if let variantDictionary = product?.variantDictionary , variantDictionary.count > 0 {

                let sizeCellDetail = CellDetail()
                sizeCellDetail.cellData = variantDictionary as AnyObject?
                sizeCellDetail.cellType = .ProductSizeOption
                sizeCellDetail.cellSize = CGSize(width: self.view.frame.width , height: CGFloat(35 + (125 * variantDictionary.count)))
                sectionDetail.sectionDataList.append(sizeCellDetail)
                
                let priceCellDetail = CellDetail()
                priceCellDetail.cellData = product
                priceCellDetail.cellType = .ProductPriceOnly
                priceCellDetail.cellSize = CGSize(width: self.view.frame.width , height: 60)
                sectionDetail.sectionDataList.append(priceCellDetail)
            } else {
                
                // Prepare quantity cell detail
                let quantityCellDetail = CellDetail()
                quantityCellDetail.cellData = product
                quantityCellDetail.cellType = .ProductQuantity
                quantityCellDetail.cellSize = CGSize(width: self.view.frame.width , height: 50)
                sectionDetail.sectionDataList.append(quantityCellDetail)
            }
            
            // Prepare product pincode cell detail
            if IsPinCodeCheckIsEnabled {
                if activePinCode == nil {
                    let pincodeCellDetail = CellDetail()
                    pincodeCellDetail.cellData = product
                    pincodeCellDetail.cellType = .ProductPincode
                    pincodeCellDetail.cellSize = CGSize(width: self.view.frame.width , height: 50)
                    sectionDetail.sectionDataList.append(pincodeCellDetail)
                } else {
                    let pincodeMessageCellDetail = CellDetail()
                    pincodeMessageCellDetail.cellData = product
                    pincodeMessageCellDetail.cellType = .ProductPincodeMessage
                    pincodeMessageCellDetail.cellSize = CGSize(width: self.view.frame.width , height: 50)
                    pincodeMessageCellDetail.cellText = activePinCodeMessage
                    sectionDetail.sectionDataList.append(pincodeMessageCellDetail)
                }
            }
            
            // Prepare product detail tabs
            let detailTabsCell = CellDetail()
            detailTabsCell.cellData = product
            detailTabsCell.cellType = .ProductDetailTabs
            detailTabsCell.cellSize = CGSize(width: self.view.frame.width , height: 70)
            sectionDetail.sectionDataList.append(detailTabsCell)
            
            // Prepare decsription cell detail
            if selectedDetailTab == .tab1 {
                if product?.desc?.characters.count > 0 {
                    let descriptionCellDetail = CellDetail()
                    descriptionCellDetail.cellData = product
                    descriptionCellDetail.cellType = .ProductDescription
                    descriptionCellDetail.cellAttributedText = product?.desc?.html2AttributedString
                    if isDescriptionExpanded {
                        let height = 40 + (descriptionCellDetail.cellAttributedText?.heightWithConstrainedWidth(width: self.view.frame.width - 50))!
                        descriptionCellDetail.cellSize = CGSize(width: self.view.frame.width , height: height)
                    } else {
                        descriptionCellDetail.cellSize = CGSize(width: self.view.frame.width , height: 160)
                    }
                    sectionDetail.sectionDataList.append(descriptionCellDetail)
                }
            }
            
            if selectedDetailTab == .detail {
                let helpCellDetail = CellDetail()
                helpCellDetail.cellData = product
                helpCellDetail.cellType = .ProductDetail
                helpCellDetail.cellSize = CGSize(width: self.view.frame.width , height: CGFloat((product?.detailsCount)! * 50))
                sectionDetail.sectionDataList.append(helpCellDetail)
            }
            
            if selectedDetailTab == .tab2 {
                let helpCellDetail = CellDetail()
                helpCellDetail.cellData = product
                helpCellDetail.cellType = .ProductHelp
                helpCellDetail.cellText = TabText2
                let height = 20 + helpCellDetail.cellText!.heightWithConstrainedWidth(width: self.view.frame.width - 46, font: UIFont.systemFont(ofSize: 14))
                helpCellDetail.cellSize = CGSize(width: self.view.frame.width , height: height)
                
                sectionDetail.sectionDataList.append(helpCellDetail)
            }
            
            if selectedDetailTab == .tab3 {
                let helpCellDetail = CellDetail()
                helpCellDetail.cellData = product
                helpCellDetail.cellType = .ProductHelp
                helpCellDetail.cellText = TabText3
                let height = 20 + helpCellDetail.cellText!.heightWithConstrainedWidth(width: self.view.frame.width - 46, font: UIFont.systemFont(ofSize: 14))
                helpCellDetail.cellSize = CGSize(width: self.view.frame.width , height: height)
                
                sectionDetail.sectionDataList.append(helpCellDetail)
            }
            
            // Prepare related products cell
            if let relatedProducts = product?.relatedProducts , relatedProducts.count > 0 {
                let relatedCellDetail = CellDetail()
                relatedCellDetail.cellData = relatedProducts as AnyObject?
                relatedCellDetail.cellType = .RelatedProducts
                relatedCellDetail.cellText = "RELATED PRODUCTS"
                relatedCellDetail.cellSize = CGSize(width: self.view.frame.width , height: 250)
                
                sectionDetail.sectionDataList.append(relatedCellDetail)
            }
            
            // Prepare similar products cell
            if let similarProducts = persistencyManager.fetchAll("Product", predicate: SimilarProductPredicate, sortDescriptors: nil) , similarProducts.count > 0 {
                let relatedCellDetail = CellDetail()
                relatedCellDetail.cellData = similarProducts as AnyObject?
                relatedCellDetail.cellType = .SimilarProducts
                relatedCellDetail.cellText = "SIMILAR PRODUCTS"
                relatedCellDetail.cellSize = CGSize(width: self.view.frame.width , height: 250)
                
                sectionDetail.sectionDataList.append(relatedCellDetail)
            }
            
            // Prepare recent products cell
            if let recentProducts = persistencyManager.fetchAll("Product", predicate: RecentProductPredicate, sortDescriptors: [NSSortDescriptor(key: "position", ascending: true)]) , recentProducts.count > 0 {
                let recentCellDetail = CellDetail()
                recentCellDetail.cellData = recentProducts as AnyObject?
                recentCellDetail.cellType = .RecentProducts
                recentCellDetail.cellText = "RECENTLY VIEWED PRODUCTS"
                recentCellDetail.cellSize = CGSize(width: self.view.frame.width , height: 250)
                sectionDetail.sectionDataList.append(recentCellDetail)
            }
            
            sectionList.append(sectionDetail)
        }
        
        if shouldReload {
            tblProductDetail.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Utility functions
    func getFetchDetails(_ isFacet: Bool) -> [String : AnyObject] {
        
        var parameters: [String : AnyObject] = ["page": 1 as AnyObject,
                                                "per_page": 6 as AnyObject,
                                                "facets": isFacet as AnyObject]
        
        if let categoryId = product?.category_id , categoryId > 0 {
            parameters["active_category"] = Int(categoryId) as AnyObject?
        }
        
        return parameters
    }
    
    @IBAction func btnBuyTapped(_ sender: UIButton) {
        
        if product?.custom_attributes?.count > 0 && product?.selectedColor == nil {
            let message = Message(title: "Please select color.", backgroundColor: ErrorRedColor!)
            Whisper(message: message, to: self.navigationController!, action: .Show)
            return
        }
        
        if product?.variantDictionary.count > 0 && product?.isAnyVariantSelected == false {
            let message = Message(title: "Please select quantity of atleast one option.", backgroundColor: ErrorRedColor!)
            Whisper(message: message, to: self.navigationController!, action: .Show)
            return
        }
        
        if product?.default_variant != nil {
            let cartController = UIStoryboard.cartController()
            let dict: [String:String] = ["color":(product?.selectedColor)!]
            cartController?.customAttributes = dict
            
            if product?.isAnyVariantSelected == true {
                cartController?.selectedVariants = (product?.variants?.allObjects as! [ProductVariant]).filter({ $0.isSelected && $0.selectedQuantity > 0 })
            } else {
                cartController?.buyingItemId = Int((product?.default_variant?.id)!)
                cartController?.buyingQuantity = selectedQuantity
            }
            self.navigationController?.pushViewController(cartController!, animated: true)
        }
    }
}


// MARK: Tableview delegate methods
extension TimberfruitDetailController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let sectionDetail = sectionList[(indexPath as NSIndexPath).section]
        let cellDetail = sectionDetail.sectionDataList[(indexPath as NSIndexPath).row]
        
        switch cellDetail.cellType {
        case .ProductMultipleImages:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductMultipleImageCell", for: indexPath) as! ProductMultipleImageCell
            openImageBrowser(cell.imgProduct.image, originView: cell)
            
        default: break
        }
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return sectionList[(indexPath as NSIndexPath).section].sectionDataList[(indexPath as NSIndexPath).row].cellSize.height
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionList[section].headerSize.height
    }
}

// MARK: Tablview datasource methods
extension TimberfruitDetailController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if sectionList.count == 0 {
            emptyDataView?.isHidden = false
//            btnBuy.hidden = true
        } else {
            emptyDataView?.isHidden = true
//            btnBuy.hidden = false
        }
        
        return sectionList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if sectionList[section].sectionDataList.count == 0 {
            emptyDataView?.isHidden = false
//            btnBuy.hidden = true
        } else {
            emptyDataView?.isHidden = true
//            btnBuy.hidden = false
        }
        
        return sectionList[section].sectionDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let sectionDetail = sectionList[(indexPath as NSIndexPath).section]
        let cellDetail = sectionDetail.sectionDataList[(indexPath as NSIndexPath).row]
        
        switch cellDetail.cellType {
        case .ProductMultipleImages:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductMultipleImageCell", for: indexPath) as! ProductMultipleImageCell
            cell.configureWithCellDetail(cellDetail: cellDetail)
            return cell
            
        case .ProductTitle:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTitleCell", for: indexPath) as! ProductTitleCell
            cell.configureWithCellDetail(cellDetail)
            return cell
        
        case .ProductTitleOnly:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTitleOnlyCell", for: indexPath) as! ProductTitleOnlyCell
            cell.configureWithCellDetail(cellDetail)
            return cell
        
        case .ProductColorList:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductColorListCell", for: indexPath) as! ProductColorListCell
            cell.configureWithCellDetail(cellDetail)
            cell.tappedColor = { (selectedColor) in
                self.product?.selectedColor = selectedColor                
                self.tblProductDetail.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            }
            return cell
        
        case .ProductSizeOption:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductSizeOptionsCell", for: indexPath) as! ProductSizeOptionsCell
            cell.configureWithCellDetail(cellDetail)
            cell.selectionMadeForLevel = { (lvl, selSize, selQuantity) in

                let variantsForLevel = (self.product?.variants?.allObjects as! [ProductVariant]).filter({ $0.level == lvl })
                for variant in variantsForLevel {
                    variant.isSelected = false
                    variant.selectedQuantity = 0
                    if variant.option2 == selSize {
                        variant.isSelected = true
                        variant.selectedQuantity = selQuantity
                    }
                }
                self.tblProductDetail.reloadRows(at: [IndexPath(row: 4, section: 0)], with: .none)
            }

            return cell

        case .ProductPriceOnly:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductPriceOnlyCell", for: indexPath) as! ProductPriceOnlyCell
            cell.configureWithCellDetail(cellDetail)
            return cell
            
        case .ProductQuantity:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductQuantityCell", for: indexPath) as! ProductQuantityCell
            cell.configureWithCellDetail(cellDetail, quantity: selectedQuantity)
            
            cell.increaseQuantity = { () -> (Int) in
                self.selectedQuantity += 1
                return self.selectedQuantity
            }
            
            cell.decreaseQuantity = { () -> (Int) in
                self.selectedQuantity -= 1
                if self.selectedQuantity < 1 {
                    self.selectedQuantity = 1
                }
                return self.selectedQuantity
            }
            
            return cell
        
        case .ProductPincode:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductPincodeCell", for: indexPath) as! ProductPincodeCell
            cell.configureWithCellDetail(cellDetail)
            cell.checkPincode = { (code) in
                self.activePinCode = code
                if let pinCode: Pincode = persistencyManager.fetchFirst("Pincode", predicate: NSPredicate(format: "code = %@", code), sortDescriptors: nil) {
                    if pinCode.isAvailable {
                        self.activePinCodeMessage = "COD available at \(code)"
                    } else {
                        self.activePinCodeMessage = "COD not available at \(code), please pay online."
                    }
                } else {
                    self.activePinCodeMessage = "Delivery not available at \(code)"
                }
                self.prepareDataSources(true)
            }
            return cell
            
        case .ProductPincodeMessage:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductPincodeMessageCell", for: indexPath) as! ProductPincodeMessageCell
            cell.configureWithCellDetail(cellDetail)
            cell.clearPincode = {
                self.activePinCode = nil
                self.activePinCodeMessage = ""
                self.prepareDataSources(true)
            }
            return cell
            
        case .ProductDetailTabs:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductDetailTabsCell", for: indexPath) as! ProductDetailTabsCell
            cell.configureWithSelectedTab(selectedDetailTab, hasDetails: product?.detailsCount > 0)
            cell.selectedTab = { (tabValue) in
                let oldValue = self.selectedDetailTab
                self.selectedDetailTab = tabValue
                self.prepareDataSources(false)
                self.tblProductDetail.reloadRows(at: [IndexPath(row: (indexPath as NSIndexPath).row + 1, section: (indexPath as NSIndexPath).section)], with: oldValue.rawValue < tabValue.rawValue ? .left : .right)
            }
            return cell
            
        case .ProductDescription:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductDescriptionCell", for: indexPath) as! ProductDescriptionCell
            cell.configureWithCellDetail(cellDetail, isExpanded: isDescriptionExpanded)
            
            cell.moreLessTapped = { (isExpanded: Bool) in
                self.isDescriptionExpanded = isExpanded
                self.prepareDataSources(false)
                
                self.tblProductDetail.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            }
            
            return cell
    
        case .ProductDetail:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductDetailsCell", for: indexPath) as! ProductDetailsCell
            cell.configureWithCellDetail(cellDetail)
            return cell
            
        case .ProductHelp:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductHelpCell", for: indexPath) as! ProductHelpCell
            cell.configureWithCellDetail(cellDetail)
            return cell
            
        case .RelatedProducts:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RelatedProductsCell", for: indexPath) as! RelatedProductsCell
            cell.configureWithCellDetail(cellDetail)
            cell.tappedProduct = { (newProduct) in
                newProduct.isRelated = false
                newProduct.isRecent = false
                newProduct.isSimilar = false
                persistencyManager.saveContext()
                self.reloadDetailWithProduct(newProduct: newProduct)
            }
            return cell
        
        case .SimilarProducts:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RelatedProductsCell", for: indexPath) as! RelatedProductsCell
            cell.configureWithCellDetail(cellDetail)
            cell.tappedProduct = { (newProduct) in
                newProduct.isRelated = false
                newProduct.isRecent = false
                newProduct.isSimilar = false
                persistencyManager.saveContext()
                self.reloadDetailWithProduct(newProduct: newProduct)
            }
            return cell
            
        case .RecentProducts:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RelatedProductsCell", for: indexPath) as! RelatedProductsCell
            cell.configureWithCellDetail(cellDetail)
            cell.tappedProduct = { (newProduct) in
                newProduct.isRelated = false
                newProduct.isRecent = false
                newProduct.isSimilar = false
                persistencyManager.saveContext()
                self.reloadDetailWithProduct(newProduct: newProduct)
            }
            return cell
            
        default:
            break
        }
        
        return UITableViewCell()
    }
}
