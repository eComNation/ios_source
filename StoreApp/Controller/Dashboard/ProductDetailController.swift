//
//  ProductDetailController.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 27/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit
import SKPhotoBrowser
import Whisper

class ProductDetailController: BaseDetailController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func prepareUIRelatedResources() {

    }
    
    // MARK: Preparation Operations
    override func prepareDataSources(shouldReload: Bool = true) {

        sectionList.removeAll() 
        
        if product != nil {
            
            if product?.default_variant?.quantity == 0 {
                btnBuy.setTitle("OUT OF STOCK", for: .normal)
                btnBuy.backgroundColor = UIColor.darkGray
                btnBuy.isEnabled = false
            } else {
                btnBuy.setTitle("ADD TO CART", for: .normal)
                btnBuy.backgroundColor = GeneralButtonColor
                btnBuy.isEnabled = true
            }
            
            let sectionDetail = SectionDetail()
            sectionDetail.sectionType = .ProductDetail
            sectionDetail.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0)

            // Prepare image cell detail
            let imageCellDetail = CellDetail()
            imageCellDetail.cellData = product
            imageCellDetail.cellType = .ProductMultipleImages
            imageCellDetail.cellSize = CGSize.init(width: self.view.frame.width , height: self.view.frame.width / CGFloat(ProductDetailImageCellWidthByHeightFactor))
            sectionDetail.sectionDataList.append(imageCellDetail)
            
            // Prepare image cell detail
            let titleCellDetail = CellDetail()
            titleCellDetail.cellData = product
            titleCellDetail.cellType = .ProductTitle
            titleCellDetail.cellSize = CGSize.init(width: self.view.frame.width , height: 63 + (product?.name?.heightWithConstrainedWidth(width: self.view.frame.width - 16, font: UIFont.systemFont(ofSize: 18)))!)
            sectionDetail.sectionDataList.append(titleCellDetail)
            
            // Prepare quantity cell detail
            let quantityCellDetail = CellDetail()
            quantityCellDetail.cellData = product
            quantityCellDetail.cellType = .ProductQuantity
            quantityCellDetail.cellSize = CGSize.init(width: self.view.frame.width ,height: 50)
            sectionDetail.sectionDataList.append(quantityCellDetail)
            
            // Prepare product detail tabs
            let detailTabsCell = CellDetail()
            detailTabsCell.cellData = product
            detailTabsCell.cellType = .ProductDetailTabs
            detailTabsCell.cellSize = CGSize.init(width: self.view.frame.width ,height: 70)
            sectionDetail.sectionDataList.append(detailTabsCell)
            
            // Prepare decsription cell detail
            if selectedDetailTab == .tab1 {
                if (product?.desc?.characters.count)! > 0 {
                    let descriptionCellDetail = CellDetail()
                    descriptionCellDetail.cellData = product
                    descriptionCellDetail.cellType = .ProductHelp
                    descriptionCellDetail.cellText = String.init(htmlEncodedString: (product?.desc)!)
                    let height = 20 + descriptionCellDetail.cellText!.heightWithConstrainedWidth(width: self.view.frame.width - 46, font: UIFont.systemFont(ofSize: 14))
                    descriptionCellDetail.cellSize = CGSize.init(width: self.view.frame.width ,height: height)
                    sectionDetail.sectionDataList.append(descriptionCellDetail)
                }
            }
            
            if selectedDetailTab == .tab2 {
                let helpCellDetail = CellDetail()
                helpCellDetail.cellData = product
                helpCellDetail.cellType = .ProductHelp
                helpCellDetail.cellText = TabText2
                let height = 20 + helpCellDetail.cellText!.heightWithConstrainedWidth(width: self.view.frame.width - 46, font: UIFont.systemFont(ofSize: 14))
                helpCellDetail.cellSize = CGSize.init(width: self.view.frame.width ,height: height)
                
                sectionDetail.sectionDataList.append(helpCellDetail)
            }
            
            if selectedDetailTab == .tab3 {
                let helpCellDetail = CellDetail()
                helpCellDetail.cellData = product
                helpCellDetail.cellType = .ProductHelp
                helpCellDetail.cellText = TabText3
                let height = 20 + helpCellDetail.cellText!.heightWithConstrainedWidth(width: self.view.frame.width - 46, font: UIFont.systemFont(ofSize: 14))
                helpCellDetail.cellSize = CGSize.init(width: self.view.frame.width ,height: height)
                
                sectionDetail.sectionDataList.append(helpCellDetail)
            }
            
            
            // Prepare similar products cell
            if let similarProducts = persistencyManager.fetchAll("Product", predicate: SimilarProductPredicate, sortDescriptors: [NSSortDescriptor(key: "position", ascending: true)]), similarProducts.count > 0 {
                let similarCellDetail = CellDetail()
                similarCellDetail.cellData = similarProducts as AnyObject?
                similarCellDetail.cellType = .SimilarProducts
                similarCellDetail.cellText = "SIMILAR PRODUCTS"
                similarCellDetail.cellSize = CGSize.init(width: self.view.frame.width ,height: 250)
                
                sectionDetail.sectionDataList.append(similarCellDetail)
            }
            
            // Prepare related products cell
            if let relatedProducts = product?.relatedProducts , relatedProducts.count > 0 {
                let relatedCellDetail = CellDetail()
                relatedCellDetail.cellData = relatedProducts.allObjects as AnyObject?
                relatedCellDetail.cellType = .RelatedProducts
                relatedCellDetail.cellText = "RELATED PRODUCTS"
                relatedCellDetail.cellSize = CGSize.init(width: self.view.frame.width ,height: 250)
                
                sectionDetail.sectionDataList.append(relatedCellDetail)
            }
            
            // Prepare recent products cell
            if let recentProducts = persistencyManager.fetchAll("Product", predicate: RecentProductPredicate, sortDescriptors: [NSSortDescriptor(key: "position", ascending: true)]) , recentProducts.count > 0 {
                let recentCellDetail = CellDetail()
                recentCellDetail.cellData = recentProducts as AnyObject?
                recentCellDetail.cellType = .RecentProducts
                recentCellDetail.cellText = "RECENTLY VIEWED PRODUCTS"
                recentCellDetail.cellSize = CGSize.init(width: self.view.frame.width , height: 250)
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

    override func getAddedData(result: String) {
        self.prepareDataSources()
    }
    
    @IBAction func btnBuyTapped(_ sender: UIButton) {
        if product?.default_variant != nil {
            let cartController = UIStoryboard.cartController()
            cartController?.buyingItemId = Int((product?.default_variant?.id)!)
            cartController?.buyingQuantity = selectedQuantity
            self.navigationController?.pushViewController(cartController!, animated: true)
        }
    }
}


// MARK: Tableview delegate methods
extension ProductDetailController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        /*let sectionDetail = sectionList[indexPath.section]
        let cellDetail = sectionDetail.sectionDataList[indexPath.row]
        
        switch cellDetail.cellType {
        case .ProductMultipleImages:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductMultipleImageCell", for: indexPath as IndexPath) as! ProductMultipleImageCell
            openImageBrowser(cell.imgProduct.image, originView: cell)
            
        default: break
        }*/
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
        return sectionList[indexPath.section].sectionDataList[indexPath.row].cellSize.height
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionList[section].headerSize.height
    }
}

// MARK: Tablview datasource methods
extension ProductDetailController: UITableViewDataSource {
    
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sectionList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionList[section].sectionDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let sectionDetail = sectionList[indexPath.section]
        let cellDetail = sectionDetail.sectionDataList[indexPath.row]
        
        switch cellDetail.cellType {
        case .ProductMultipleImages:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductMultipleImageCell", for: indexPath as IndexPath) as! ProductMultipleImageCell
            cell.configureWithCellDetail(cellDetail: cellDetail)
            cell.selectedProductImage = { (imageURL) in
                cell.imgProduct.setImageWithURL(NSURL(string: "http:"+imageURL)! as URL) { (success, isCancelled, image) in
                }
            }
            cell.onImageCompleted = { () in
                self.emptyDataView?.isHidden = true
            }
            return cell
            
        case .ProductTitle:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductTitleCell", for: indexPath as IndexPath) as! ProductTitleCell
            cell.configureWithCellDetail(cellDetail)
            return cell
           
        case .ProductQuantity:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductQuantityCell", for: indexPath as IndexPath) as! ProductQuantityCell
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
            
        case .ProductDetailTabs:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductDetailTabsCell", for: indexPath as IndexPath) as! ProductDetailTabsCell
            cell.configureWithSelectedTab(selectedDetailTab)
            cell.selectedTab = { (tabValue) in
                if self.selectedDetailTab == tabValue {
                    return
                }
                let oldValue = self.selectedDetailTab
                self.selectedDetailTab = tabValue
                self.prepareDataSources(shouldReload: false)
                self.tblProductDetail.reloadRows(at: [NSIndexPath(row: indexPath.row + 1, section: indexPath.section) as IndexPath], with: oldValue.rawValue < tabValue.rawValue ? .left : .right)
            }
            return cell
            
        case .ProductDescription:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductDescriptionCell", for: indexPath as IndexPath) as! ProductDescriptionCell
            cell.configureWithCellDetail(cellDetail, isExpanded: isDescriptionExpanded)
            
            cell.moreLessTapped = { (isExpanded: Bool) in
                self.isDescriptionExpanded = isExpanded
                self.prepareDataSources(shouldReload: false)
                
                self.tblProductDetail.reloadRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
            }
            
            return cell
        
        case .ProductHelp:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductHelpCell", for: indexPath as IndexPath) as! ProductHelpCell
            cell.configureWithCellDetail(cellDetail)
            return cell
            
        case .SimilarProducts:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RelatedProductsCell", for: indexPath as IndexPath) as! RelatedProductsCell
            cell.configureWithCellDetail(cellDetail)
            cell.tappedProduct = { (newProduct) in
                newProduct.isRelated = false
                newProduct.isRecent = false
                persistencyManager.saveContext()
                self.reloadDetailWithProduct(newProduct: newProduct)
            }
            return cell
            
        case .RelatedProducts:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RelatedProductsCell", for: indexPath as IndexPath) as! RelatedProductsCell
            cell.configureWithCellDetail(cellDetail)
            cell.tappedProduct = { (newProduct) in
                newProduct.isRelated = false
                newProduct.isRecent = false
                persistencyManager.saveContext()
                self.reloadDetailWithProduct(newProduct: newProduct)
            }
            return cell
            
        case .RecentProducts:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RelatedProductsCell", for: indexPath as IndexPath) as! RelatedProductsCell
            cell.configureWithCellDetail(cellDetail)
            cell.tappedProduct = { (newProduct) in
                newProduct.isRelated = false
                newProduct.isRecent = false
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
