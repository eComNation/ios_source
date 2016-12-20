//
//  ABJewelsDetailController.swift
//  StoreApp
//
//  Created by Abhilesh Halarnkar on 14/11/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import Foundation

class ABJewelsDetailController: BaseDetailController {
    
    var jewelleryProduct: JewelleryProduct?
    var jewelleryPrice: JewelleryPrice?
    var metal_option: String = ""
    var diamond_options: String = ""
    
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
                btnBuy.backgroundColor = UIColor.lightGray
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
            
            let descriptionCellDetail = CellDetail()
            descriptionCellDetail.cellData = product
            descriptionCellDetail.cellType = .ProductHelp
            descriptionCellDetail.cellText = product?.desc?.htmlString
            let height = 20 + descriptionCellDetail.cellText!.heightWithConstrainedWidth(width: self.view.frame.width - 46, font: UIFont.systemFont(ofSize: 14))
            descriptionCellDetail.cellSize = CGSize.init(width: self.view.frame.width ,height: height)
            sectionDetail.sectionDataList.append(descriptionCellDetail)
            
            if jewelleryProduct != nil && jewelleryPrice != nil {
                
                var detailDictionary : Array<GemOption> = []
                let gemOp0 = GemOption()
                gemOp0.name = ""; gemOp0.values = []
                gemOp0.values!.append(JewelleryOption(idValue: "Stock Number", nameValue: product!.default_variant!.sku! ))
                
                let gemOp1 = GemOption()
                gemOp1.name = "METAL DETAILS"; gemOp1.values = []
                gemOp1.values!.append(JewelleryOption(idValue: "Metal/Purity", nameValue: jewelleryPrice!.metal!.name! ))
                gemOp1.values!.append(JewelleryOption(idValue: "Approximate Weight", nameValue: "\(jewelleryPrice!.metal!.weight) gm" ))
                gemOp1.values!.append(JewelleryOption(idValue: "Size", nameValue: jewelleryPrice!.metal!.size! ))
                gemOp1.values!.append(JewelleryOption(idValue: "Per Gram Rate", nameValue: "Rs. \(jewelleryPrice!.metal!.per_gm_rate)/gm" ))
                gemOp1.values!.append(JewelleryOption(idValue: "Price", nameValue: "Rs. \(jewelleryPrice!.metal!.price)" ))
                
                let gemOp2 = GemOption()
                gemOp2.name = "MAKING DETAILS"; gemOp2.values = []
                gemOp2.values!.append(JewelleryOption(idValue: "Setting Type", nameValue: jewelleryProduct!.making_type! ))
                gemOp2.values!.append(JewelleryOption(idValue: "Making Charge", nameValue: "Rs. \(jewelleryPrice!.making_charge)" ))
                
                let gemOp3 = GemOption()
                gemOp3.name = "GRAND TOTAL"; gemOp3.values = []
                gemOp3.values!.append(JewelleryOption(idValue: "Grand Total", nameValue: "Rs. \(jewelleryPrice!.total)" ))
                
                detailDictionary.append(gemOp0)
                detailDictionary.append(gemOp1)
                detailDictionary.append(gemOp2)
                detailDictionary.append(gemOp3)
                
                let descriptionCell = CellDetail()
                descriptionCell.cellType = .DescriptionPair
                descriptionCell.cellData = detailDictionary as AnyObject?
                descriptionCell.cellText = "PRODUCT DETAILS"
                descriptionCell.cellSize = CGSize.init(width: self.view.frame.width ,height: 350)
                sectionDetail.sectionDataList.append(descriptionCell)
            }
            
            // Prepare related products cell
            if let similarProducts = persistencyManager.fetchAll("Product", predicate: SimilarProductPredicate, sortDescriptors: [NSSortDescriptor(key: "position", ascending: true)]), similarProducts.count > 0 {
                let relatedCellDetail = CellDetail()
                relatedCellDetail.cellData = similarProducts as AnyObject?
                relatedCellDetail.cellType = .SimilarProducts
                relatedCellDetail.cellText = "SIMILAR PRODUCTS"
                relatedCellDetail.cellSize = CGSize.init(width: self.view.frame.width ,height: 250)
                sectionDetail.sectionDataList.append(relatedCellDetail)
            }
            
            // Prepare related products cell
            if let relatedProducts = product?.relatedProducts , relatedProducts.count > 0 {
                let relatedCellDetail = CellDetail()
                relatedCellDetail.cellData = relatedProducts as AnyObject?
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
    
    func getAdditionalData() {
    
        networkManager.fetchJewelleryProductForProductId(currentProductId, completion: { (success, message, response) -> (Void) in
            
            if success {
                if let responseData = response as? [String : AnyObject] {
                    if let productDictionary = responseData["product"] as? [String : AnyObject] {
                        self.jewelleryProduct = JewelleryProduct(dictionary: productDictionary)
                        self.getPrice()
                    }
                }
                
            } else {
                self.emptyDataView?.showEmptyDataViewWithMessage(message != nil ? message! : "Something went wrong", buttonTitle: "REFRESH")
            }
        })
    }
    
    func getPrice() {
        networkManager.fetchJewelleryPrice(currentProductId, completion: {
            (success, message, response) -> (Void) in
            
            if success {
                if let responseData = response as? [String : AnyObject] {
                    if let productDictionary = responseData["price"] as? [String : AnyObject] {
                        self.jewelleryPrice = JewelleryPrice(dictionary: productDictionary)
                        self.jewelleryPrice?.metal = JewelleryOption(dictionary: productDictionary["metal"] as! [String : AnyObject])
                        self.setPriceData()
                        self.prepareDataSources()
                    }
                }
                
            } else {
                self.emptyDataView?.showEmptyDataViewWithMessage(message != nil ? message! : "Something went wrong", buttonTitle: "REFRESH")
            }
        })
    }
    
    func setPriceData() {
        metal_option = "&metal_option_id=" + (jewelleryPrice?.metal?.id!)!
        
        product?.selectedVariant?.price = "\(jewelleryPrice!.total)"
        
        diamond_options = "";
        let diaOptions = jewelleryPrice?.gem_options
        
        if (diaOptions != nil && !(diaOptions?.isEmpty)!) {
            for diamond in diaOptions! {
                diamond_options += "&diamond_options[\(diamond.id!)]=\(diamond.value?.id)"
            }
        }
    }
    
    override func getAddedData(result: String) {
        getAdditionalData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnBuyTapped(_ sender: UIButton) {
        if product?.default_variant != nil {
            let cartController = UIStoryboard.cartController()
            cartController?.cartParameters = metal_option + diamond_options + "&product_id=\(product!.id)"
            cartController?.buyingQuantity = selectedQuantity
            self.navigationController?.pushViewController(cartController!, animated: true)
        }
    }
}


// MARK: Tableview delegate methods
extension ABJewelsDetailController: UITableViewDelegate {
    
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
extension ABJewelsDetailController: UITableViewDataSource {
    
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
                cell.imgProduct.setImageWithURL(NSURL(string: imageURL) as! URL) { (success, isCancelled, image) in
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
            
        case .ProductHelp:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProductHelpCell", for: indexPath as IndexPath) as! ProductHelpCell
            cell.configureWithCellDetail(cellDetail)
            return cell
            
        case .DescriptionPair:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DescriptionPairCell", for: indexPath as IndexPath) as! DescriptionPairCell
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
