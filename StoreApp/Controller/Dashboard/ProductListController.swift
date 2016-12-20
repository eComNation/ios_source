//
//  ProductListController.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 03/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit
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


let kProductCellIdentifier = "ProductCell"
let kProductListCellIdentifier = "ProductListCell"
let kProductCountHeaderCellIdentifier = "ProductCountHeader"

class ProductListController: UIViewController {

    @IBOutlet var cartButton: RPUIBarButton!
    
    // MARK: Filter sort view outlets
    @IBOutlet var filterSortContainerHeight: NSLayoutConstraint!
    @IBOutlet var filterSortContainerView: UIView!
    @IBOutlet var btnFilter: UIButton!
    @IBOutlet var btnSort: UIButton!
    @IBOutlet var btnListGridView: UIButton!
    @IBOutlet var lblMaxAmount: UILabel!
    
    // MARK: Filter sort list view outlets
    @IBOutlet var tblFilterSort: UITableView!
    @IBOutlet var btnResetFilters: UIButton!
    @IBOutlet var btnApplyFilters: UIButton!
    @IBOutlet var priceSlider: YSRangeSlider!
    @IBOutlet var lblMinAmount: UILabel!

    // MARK: Product collection outlets
    @IBOutlet var colProductList: UICollectionView!
    @IBOutlet var colProductListTop: NSLayoutConstraint!

    // MARK: Datasource containers
    var selectedCategory: Category?
    var filterSectionList: [SectionDetail] = []
    var productSectionList: [SectionDetail] = []
    var paginationInfo: PaginationInfo?
    var facetsInfo: FacetsInfo?
    var selectedFilters: [String] = []
    
    var categoryResourceURI : String?
    
    var filterDictionaries: [FilterGroup:[Filter]] = [:]
    var selectedSort : String?
    var selectedSortKey : String?
    var searchCriteria: String?
    
    // MARK: Other properties
    var sortMenu: BTNavigationDropdownMenu?
    var emptyDataView: EmptyDataView? = Bundle.main.loadNibNamed("EmptyDataView", owner: nil, options: nil)?[0] as? EmptyDataView
    
    // MARK: Life cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set title of navigation bar
        self.title = selectedCategory?.name?.capitalized
        
        selectedSort = sort_display[0]
        selectedSortKey = sort_criteria[0]
        
        // Remove all featured products
        persistencyManager.deleteAll("Product", predicate: NormalProductPredicate)
        
        resetConstraintsToMinimize()
        prepareUIRelatedResources()
        
        fetchProducts()
        
        if selectedCategory == nil {
            showSearchView(false)
        }
        
        emptyDataView?.frame = colProductList.bounds
        colProductList.backgroundView = emptyDataView
        
        emptyDataView?.onActionButtonTap = {
            self.fetchProducts()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        logManager.logScreenWithName(String(describing: ProductListController()))
        
        NotificationCenter.default.addObserver(self, selector: #selector(receivedCartUpdate), name: NSNotification.Name(rawValue: CartUpdateNotification), object: nil)
        
        cartButton.badgeString = cartManager.cartCountString
        cartButton.badgeTextColor = UIColor.white
        cartButton.badgeBackgroundColor = GeneralButtonColor!
        cartButton.badgeEdgeInsets = UIEdgeInsetsMake(10, 0, 0, 10)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: CartUpdateNotification), object: nil)
        
        sortMenu?.hide()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        cartButton.badgeString = cartManager.cartCountString
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
    
    // MARK: Preparation jobs
    func resetConstraintsToMinimize() {
        filterSortContainerHeight.constant = 0
        colProductListTop.constant = 0
        self.view.layoutIfNeeded()
    }
    
    func prepareButtonsUI() {
        
        // Prepare filter button
        btnFilter.layer.cornerRadius = 2.0
        btnFilter.layer.borderColor = UIColor.gray.cgColor
        btnFilter.layer.borderWidth = 0.5
        btnFilter.layer.masksToBounds = true
        
        // Prepare sort button
        btnSort.layer.cornerRadius = 2.0
        btnSort.layer.borderColor = UIColor.gray.cgColor
        btnSort.layer.borderWidth = 0.5
        btnSort.layer.masksToBounds = true
        
        // Prepare list grid view button
        btnListGridView.layer.cornerRadius = 2.0
        btnListGridView.layer.borderColor = UIColor.gray.cgColor
        btnListGridView.layer.borderWidth = 0.5
        btnListGridView.layer.masksToBounds = true
        
        // Prepare reset filter button
        btnResetFilters.layer.borderColor = UIColor.white.cgColor
        btnResetFilters.layer.borderWidth = 0.5
        btnResetFilters.layer.masksToBounds = true
        btnResetFilters.backgroundColor = GeneralButtonColor
        
        // Prepare apply filter button
        btnApplyFilters.layer.borderColor = UIColor.white.cgColor
        btnApplyFilters.layer.borderWidth = 0.5
        btnApplyFilters.layer.masksToBounds = true
        btnApplyFilters.backgroundColor = GeneralButtonColor
    }
    
    func prepareUIRelatedResources() {
        
        // Prepare buttons UI
        prepareButtonsUI()
        
        // Register section header nib for filters table view
        let nib = UINib(nibName: "FilterSectionHeader", bundle: nil)
        tblFilterSort.register(nib, forHeaderFooterViewReuseIdentifier: "FilterSectionHeader")
        
        // Prepare sort menu view
        sortMenu = BTNavigationDropdownMenu(navigationController: self.navigationController, title: sort_display.first!, items: sort_display as [AnyObject])
        sortMenu?.cellSelectionColor = sortMenu?.cellBackgroundColor
        sortMenu?.cellSeparatorColor = UIColor(white: 1, alpha: 0.3)
        sortMenu?.cellTextLabelFont = UIFont.systemFont(ofSize: 16)
        sortMenu?.didSelectItemAtIndexHandler = {[weak self] (indexPath: Int) -> () in
            
            if self?.selectedSort != sort_display[indexPath] {
                self?.selectedSort = sort_display[indexPath]
                self?.selectedSortKey = sort_criteria[indexPath]
                print("Selected sort: \(self?.selectedSort)")
                
                self?.paginationInfo = nil
                
                // Fetch again with new filters
                self?.fetchProducts()
            }
            
            if self?.btnFilter.isSelected == true {
                self?.toggleFilterArea()
            }
        }
        
        // Set price slider delegate
        priceSlider.delegate = self
    }
    
    // MARK: Data source preparation
    func prepareFilterDatasource() {
        
        // Remove all previous sections from filter section list
        filterSectionList.removeAll()
        filterDictionaries.removeAll()
        
        if facetsInfo != nil {
            priceSlider.minimumValue = CGFloat((facetsInfo?.min)!)
            priceSlider.maximumValue = CGFloat((facetsInfo?.max)!)
            priceSlider.minimumSelectedValue = CGFloat((facetsInfo?.min)!)
            priceSlider.maximumSelectedValue = CGFloat((facetsInfo?.max)!)
        } else {
            priceSlider.minimumValue = 0
            priceSlider.maximumValue = 0
            priceSlider.minimumSelectedValue = 0
            priceSlider.maximumSelectedValue = 0
        }
        
        lblMinAmount.text = Double(priceSlider.minimumSelectedValue).formattedWithCurrency
        lblMaxAmount.text = Double(priceSlider.maximumSelectedValue).formattedWithCurrency
        
        if facetsInfo?.attributes_index.count > 0 {
            
            var allAttributeIndexes: [String] = []
            
            for attributeIndex in (facetsInfo?.attributes_index.keys)! {
                allAttributeIndexes.append(attributeIndex)
            }
            
            let filterPredicate = NSPredicate(format: "attribute_index IN %@", allAttributeIndexes)
            let sortDescriptor = NSSortDescriptor(key: "value", ascending: true)
            
            if let filtersArray: [Filter] = persistencyManager.fetchAll("Filter", predicate: filterPredicate, sortDescriptors: [sortDescriptor]) , filtersArray.count > 0 {
                
                print(filtersArray.count)

                filterDictionaries = filtersArray.categorise({ $0.filter! })
                let filterDictionariesTuples = filterDictionaries.sorted(by: { return $0.0.name > $1.0.name })
                filterDictionaries.removeAll()
                
                for (filterGroup, filters) in filterDictionariesTuples {
                    filterDictionaries[filterGroup] = filters
                }
                
                for (filterGroup, filters) in filterDictionaries {
                    
                    let sectionDetail = SectionDetail()
                    sectionDetail.sectionType = .FilterGroups
                    sectionDetail.sectionData = filterGroup
                    sectionDetail.headerSize = CGSize(width: ScreenWidth, height: 45)
                    
                    for filter in filters {
                        let cellDetail = CellDetail()
                        cellDetail.cellData = filter
                        cellDetail.cellSize = CGSize(width: 0, height: 45)
                        cellDetail.cellText = filter.value?.capitalized
                        sectionDetail.sectionDataList.append(cellDetail)
                    }
                    
                    filterSectionList.append(sectionDetail)
                }
            }
        }
        
        tblFilterSort.reloadData()
    }

    func prepareProductDatasource() {
        
        // Remove all previous sections from product section list
        productSectionList.removeAll()
        
        let mainSection = SectionDetail()
        mainSection.footerSize = CGSize(width: self.view.frame.width, height: 50)
        
        if persistencyManager.count("Product", predicate: NormalProductPredicate) > 0 {
            
            let productHeaderCellDetail = CellDetail()
            productHeaderCellDetail.cellSize = CGSize(width: self.view.frame.width, height: 30)
            productHeaderCellDetail.cellType = .ProductCountHeader
            productHeaderCellDetail.cellText = "\(paginationInfo!.totalEntries) PRODUCTS FOUND"
            mainSection.sectionDataList.append(productHeaderCellDetail)
            
            let productOrder = NSSortDescriptor(key: "position", ascending: true)
            let allProducts = persistencyManager.fetchAll("Product", predicate: NormalProductPredicate, sortDescriptors: [productOrder])! as [Product]
            var productCellSize = CGSize(width: self.view.frame.width / 2, height: (self.view.frame.width / 2) / CGFloat(FeaturedProductCellWidthByHeightFactor))
            if btnListGridView.isSelected {
                productCellSize = CGSize(width: self.view.frame.width, height: 116)
            }
            print("All products count: \(allProducts.count)")
            for product in allProducts {
                let productCellDetail = CellDetail()
                productCellDetail.cellType = .Product
                productCellDetail.cellSize = productCellSize
                productCellDetail.cellData = product
                mainSection.sectionDataList.append(productCellDetail)
            }
        }

        productSectionList.append(mainSection)
        colProductList.reloadData()
    }
    
    // MARK: Service related jobs
    func fetchProducts() {
        
        if paginationInfo == nil {
            
            self.filterSortContainerHeight.constant = 0
            UIView.animate(withDuration: 0.3, animations: {
                self.view.layoutIfNeeded()
            })
            
            persistencyManager.deleteAll("Product", predicate: NormalProductPredicate)
            self.prepareProductDatasource()
        }
        
        emptyDataView?.showIndicatorView()
        networkManager.fetchProductMatchingDetails(getFetchDetails(false), isRecent: false) { (success, message, response) -> (Void) in
            
            if success {
                if let responseData = response as? [String : AnyObject] {
                    if let paginationDictionary = responseData["pagination_info"] as? [String : AnyObject] {
                        self.paginationInfo = PaginationInfo(dictionary: paginationDictionary)
                    }
                }
                self.prepareProductDatasource()
                
                if self.facetsInfo == nil {
                    self.fetchFacets()
                }
                
                if persistencyManager.count("Product", predicate: NormalProductPredicate) == 0 {
                    self.emptyDataView?.showEmptyDataViewWithMessage("No products to display", buttonTitle: nil)
                }
                else{
                    self.filterSortContainerHeight.constant = 48
                    UIView.animate(withDuration: 0.3, animations: {
                        self.view.layoutIfNeeded()
                    })
                }
                
            } else {
                self.emptyDataView?.showEmptyDataViewWithMessage(message != nil ? message! : "Something went wrong", buttonTitle: "REFRESH")
            }
        }
    }
    
    func fetchFacets() {

        networkManager.fetchProductMatchingDetails(getFetchDetails(true), isRecent: false) { (success, message, response) -> (Void) in
            
            if success {
                
                if let responseData = response as? [String : AnyObject] {
                    self.facetsInfo = FacetsInfo(dictionary: responseData)
                }
                
                self.prepareFilterDatasource()
            }
        }
    }
    
    func getFetchDetails(_ isFacet: Bool) -> [String : AnyObject] {
        
        let page: Int = paginationInfo != nil ? (paginationInfo?.nextPage)! : 1
        
        var parameters: [String : AnyObject] = ["page": page as AnyObject,
                                                "per_page": 16 as AnyObject,
                                                "facets": isFacet as AnyObject]
        
        if let categoryId = selectedCategory?.id {
            parameters["active_category"] = Int32(categoryId) as AnyObject?
        }
        
        if selectedFilters.count > 0 {
            parameters["filter_attributes"] = selectedFilters.joined(separator: ",") as AnyObject?
        }
        
        parameters["sort_criteria"] = selectedSortKey as AnyObject?
        
        if searchCriteria?.characters.count > 0 {
            parameters["search_criteria"] = searchCriteria! as AnyObject?
        }
        
        if facetsInfo != nil {

            let priceBetween = String(format: "%.0f", priceSlider.minimumSelectedValue) + "," + String(format: "%.0f", priceSlider.maximumSelectedValue)
            print(priceBetween)
            parameters["price_between"] = priceBetween as AnyObject?
        }
        
        if EnableOutOfStock {
            parameters["variants"] = 1 as AnyObject?
        }
        
        print("Parameters: \(parameters)")
        
        return parameters
    }
    
    // MARK: Button events
    @IBAction func backTapped(_ sender: UIBarButtonItem) {
        
        for (_, filters) in filterDictionaries {
            
            for filter in filters {
                filter.isSelected = false
            }
        }
        
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSearchTapped(_ sender: UIBarButtonItem) {
        
        showSearchView()
    }
    
    @IBAction func cartTapped(_ sender: RPUIBarButton) {
        self.navigationController?.pushViewController(UIStoryboard.cartController()!, animated: true)
    }
    
    @IBAction func btnFilterTap(_ sender: UIButton) {
        toggleFilterArea()
    }
    
    @IBAction func btnSortTap(_ sender: UIButton) {
        sortMenu?.toggle()
    }
    
    @IBAction func btnListGridViewTapped(_ sender: UIButton) {
        btnListGridView.isSelected = !(btnListGridView.isSelected)
        prepareProductDatasource()
    }
    
    @IBAction func btnResetFilterTapped(_ sender: UIButton) {
        
        for (_, filters) in filterDictionaries {
            
            for filter in filters {
                filter.isSelected = false
            }
        }
        
        selectedFilters.removeAll()
        
        // Reload filter table
        tblFilterSort.reloadData()
        
        paginationInfo = nil
        
        // Fetch again with new filters
        fetchProducts()
        
        // Toggle filter area
        toggleFilterArea()
    }
    
    @IBAction func btnApplyFilterTapped(_ sender: UIButton) {

        selectedFilters.removeAll()
        
        for (_, filters) in filterDictionaries {
            
            for filter in filters where filter.isSelected {
                selectedFilters.append(filter.attribute_index!)
            }
        }
        
        paginationInfo = nil
        
        // Fetch again with new filters
        fetchProducts()
        
        // Toggle filter area
        toggleFilterArea()
    }
    
    func toggleFilterArea() {
        
        btnFilter.isSelected = !btnFilter.isSelected
        
        if btnFilter.isSelected {
            let remainingHeight = ScreenHeight - 64.0 - filterSortContainerHeight.constant
            colProductListTop.constant = remainingHeight
        } else {
            colProductListTop.constant = 0
        }
        
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: UIViewAnimationOptions(), animations: {
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func showSearchView(_ animated: Bool = true) {
        
        let searchController = UIStoryboard.searchController()
        searchController?.searchString = searchCriteria
        searchController?.cancelledSearch = {
            self.dismiss(animated: true, completion: nil)
        }
        
        searchController?.searchForString = { (searchString) in
            self.dismiss(animated: true, completion: {
                
                self.paginationInfo = nil
                
                self.searchCriteria = searchString
                self.fetchProducts()
                
                if searchString.characters.count > 0 {
                    customerManager.addRecentSearch(searchString)
                }
            })
        }
        
        self.present(searchController!, animated: animated) {
            
        }
    }
}

// MARK: Price slider delegate
extension ProductListController: YSRangeSliderDelegate {
    
    func rangeSliderDidChange(_ rangeSlider: YSRangeSlider, minimumSelectedValue: CGFloat, maximumSelectedValue maximumSelectedSelectedValue: CGFloat) {
        lblMinAmount.text = Double(minimumSelectedValue).formattedWithCurrency
        lblMaxAmount.text = Double(maximumSelectedSelectedValue).formattedWithCurrency
    }
}

// MARK: Table view delegate
extension ProductListController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath) as! FilterCell
        let filter = filterSectionList[(indexPath as NSIndexPath).section].sectionDataList[(indexPath as NSIndexPath).row].cellData as! Filter
        filter.isSelected = !filter.isSelected
        cell.setCheckStatus(filter.isSelected, animated: true)
        tableView.reloadRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return filterSectionList[section].headerSize.height
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        // Dequeue with the reuse identifier
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "FilterSectionHeader") as! FilterSectionHeader
        cell.setWithFilterGroup(filterSectionList[section].sectionData as! FilterGroup)
        
        cell.onHeaderSelected = { [weak tableView] filterGroup in
            print("Selected section \(filterGroup?.name)")
            tableView!.reloadSections(IndexSet(integer: section), with: UITableViewRowAnimation.automatic)
        }
        
        return cell
    }
}

// MARK: Table view datasource
extension ProductListController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return filterSectionList.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let filterGroup = filterSectionList[section].sectionData as! FilterGroup
        
        return filterGroup.isExpanded ? filterSectionList[section].dataCount : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath) as! FilterCell
        cell.setWithFilter(filterSectionList[(indexPath as NSIndexPath).section].sectionDataList[(indexPath as NSIndexPath).row].cellData as! Filter)
       
        return cell
    }
}

// MARK: CollectionView flow layout delegates
extension ProductListController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return productSectionList[(indexPath as NSIndexPath).section].sectionDataList[(indexPath as NSIndexPath).row].cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return productSectionList[section].sectionInset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return productSectionList[section].headerSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if paginationInfo == nil {
            return CGSize.zero
        }
        
        if paginationInfo != nil && paginationInfo?.nextPage == 0 {
            return CGSize.zero
        }
        
        return productSectionList[section].footerSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return productSectionList[section].lineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return productSectionList[section].itemSpacing
    }
}


// MARK: Collection view delegate
extension ProductListController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        
        fetchProducts()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let sectionDetail = productSectionList[(indexPath as NSIndexPath).section]
        let cellDetail = sectionDetail.sectionDataList[(indexPath as NSIndexPath).row]
        
        switch cellDetail.cellType {
        case .Product:
            if let product = cellDetail.cellData as? Product {
                let productDetailController = utility.getDetailsController()
                productDetailController.product = product
                self.navigationController?.pushViewController(productDetailController, animated: true)
            }
            
        default:
            break
        }

    }
}


// MARK: Collection view datasource
extension ProductListController: UICollectionViewDataSource {
    
    // MARK: CollectionView datasource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        if productSectionList.count == 0 {
            emptyDataView?.isHidden = false
        } else {
            emptyDataView?.isHidden = true
        }
        
        return productSectionList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if productSectionList[section].sectionDataList.count == 0 {
            emptyDataView?.isHidden = false
        } else {
            emptyDataView?.isHidden = true
        }
        
        return productSectionList[section].sectionDataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "LoadingFooterView", for: indexPath) as! LoadingFooterView
        view.indicatorView.startAnimation()
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
        let sectionDetail = productSectionList[(indexPath as NSIndexPath).section]
        let cellDetail = sectionDetail.sectionDataList[(indexPath as NSIndexPath).row]
        
        switch cellDetail.cellType {
        case .ProductCountHeader:
            let productHeaderCell = collectionView.dequeueReusableCell(withReuseIdentifier: kProductCountHeaderCellIdentifier, for: indexPath) as! ProductCountHeader
            productHeaderCell.configureWithCellDetail(cellDetail)
            return productHeaderCell
            
        case .Product:
            if btnListGridView.isSelected {
                let productCell = collectionView.dequeueReusableCell(withReuseIdentifier: kProductListCellIdentifier, for: indexPath) as! ProductListCell
                productCell.configureWithCellDetail(cellDetail)
                return productCell
            }
            
            let productCell = collectionView.dequeueReusableCell(withReuseIdentifier: kProductCellIdentifier, for: indexPath) as! ProductCell
            productCell.configureWithCellDetail(cellDetail)
            return productCell
            
        default:
            break
        }
        
        return UICollectionViewCell()
    }
}

// MARK: Scroll view delegates

extension ProductListController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == tblFilterSort {
            return
        }
        
        let yVelocity = scrollView.panGestureRecognizer.velocity(in: scrollView).y
        if (yVelocity < 0) {
            print("Scrolling up")
            if filterSortContainerHeight.constant == 48 {
                filterSortContainerHeight.constant = 0
                UIView.animate(withDuration: 0.3, animations: { 
                    self.view.layoutIfNeeded()
                })
            }
        } else if (yVelocity > 0) {
            print("Scrolling down")
            if filterSortContainerHeight.constant == 0 {
                filterSortContainerHeight.constant = 48
                UIView.animate(withDuration: 0.3, animations: {
                    self.view.layoutIfNeeded()
                })
            }
        } else {
            print("Can't determine direction as velocity is 0")
        }
    }
}
