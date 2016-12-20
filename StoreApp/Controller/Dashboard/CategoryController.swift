//
//  CategoryController.swift
//  GreenOBazaar
//
//  Created by Rakesh Pethani on 29/06/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit
import Material

class CategoryController: UIViewController {

    @IBOutlet var colCategories: UICollectionView!
    @IBOutlet var cartButton: RPUIBarButton!
    
    // MARK: Datasource containers
    var selectedCategory: Category?
    var sectionList: [SectionDetail] = []
    
    // MARK: View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = selectedCategory?.name
        
        prepareCategoriesDetails()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        logManager.logScreenWithName(String(describing: CategoryController()))
        
        NotificationCenter.default.addObserver(self, selector: #selector(receivedCartUpdate), name: NSNotification.Name(rawValue: CartUpdateNotification), object: nil)
        
        cartButton.badgeString = cartManager.cartCountString
        cartButton.badgeTextColor = UIColor.white
        cartButton.badgeBackgroundColor = GeneralButtonColor!
        cartButton.badgeEdgeInsets = UIEdgeInsetsMake(10, 0, 0, 10)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        cartButton.badgeString = cartManager.cartCountString
    }
    
    // MARK: Notification listeners
    func receivedCartUpdate() {
        DispatchQueue.main.async {
            self.cartButton.badgeString = cartManager.cartCountString
        }
    }
    
    // MARK: Preparing collectionview resources
    func prepareCategoriesDetails() {
        
        // Remove all data first
        sectionList.removeAll()
        
        let mainSection = SectionDetail()

        let categoryPredicate = NSPredicate(format: "parent_id == %d", selectedCategory != nil ? (selectedCategory?.id)! : 0)
        let categoryOrder = NSSortDescriptor(key: "position", ascending: true)
        if let categoriesArray: [Category] = persistencyManager.fetchAll("Category", predicate: categoryPredicate, sortDescriptors: [categoryOrder]) {
            for category in categoriesArray {
                let cellDetail = CellDetail()
                cellDetail.cellData = category
                cellDetail.cellSize = CGSize(width: Material.Device.width / 2, height: Material.Device.width / 2)
                cellDetail.cellText = category.name
                mainSection.sectionDataList.append(cellDetail)
            }
        }

        sectionList.append(mainSection)
        colCategories.reloadData()
    }

    
    // MARK: Button events
    @IBAction func backTapped(_ sender: UIBarButtonItem) {
        _ = self.navigationController?.popViewController(animated: true)
    }    
    
    @IBAction func searchTapped(_ sender: UIBarButtonItem) {
        self.navigationController?.pushViewController(UIStoryboard.productListController()!, animated: true)
    }
    
    @IBAction func cartTapped(_ sender: RPUIBarButton) {
        self.navigationController?.pushViewController(UIStoryboard.cartController()!, animated: true)
    }
    
    // MARK: CollectionView flow layout delegates
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        print("Cell size: \(sectionList[(indexPath as NSIndexPath).section].sectionDataList[(indexPath as NSIndexPath).row].cellSize)")
        return sectionList[(indexPath as NSIndexPath).section].sectionDataList[(indexPath as NSIndexPath).row].cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return sectionList[section].sectionInset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return sectionList[section].headerSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return sectionList[section].footerSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        print("Line spacing: \(sectionList[section].lineSpacing)")
        return sectionList[section].lineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        print("Item spacing: \(sectionList[section].itemSpacing)")
        return sectionList[section].itemSpacing
    }
    
    // MARK: CollectionView delegates
    func collectionView(_ collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: IndexPath) {
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: IndexPath) {
        
        let sectionDetail = sectionList[(indexPath as NSIndexPath).section]
        let cellDetail = sectionDetail.sectionDataList[(indexPath as NSIndexPath).row]
        
        if let category = cellDetail.cellData as? Category {
            let productListController = UIStoryboard.productListController()
            productListController?.selectedCategory = category
            self.navigationController?.pushViewController(productListController!, animated: true)
        }
    }
    
    // MARK: CollectionView datasource
    func numberOfSectionsInCollectionView(_ collectionView: UICollectionView) -> Int {
        return sectionList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sectionList[section].sectionDataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        
        let sectionDetail = sectionList[(indexPath as NSIndexPath).section]
        let cellDetail = sectionDetail.sectionDataList[(indexPath as NSIndexPath).row]
        
        let categoryDetailCell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryDetailCell", for: indexPath) as! CategoryDetailCell
        categoryDetailCell.configureWithCellDetail(cellDetail)
        return categoryDetailCell
    }
}
