//
//  ProductSizeListCell.swift
//  StoreApp
//
//  Created by Abhilesh Halarnkar on 27/10/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

var SelectedSize = ""

class ProductSizeListCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet var lblOption: UILabel!
    @IBOutlet var colSizes: UICollectionView!
    @IBOutlet weak var collectionViewWidth: NSLayoutConstraint!
    
    let margins: Float = 8.0
    let cellSpacing: Float = 8.0
    let cellWidth: Float = 100.0
    
    // Data source related properties
    let sectionDetail: SectionDetail = SectionDetail()
    
    var tappedSize: ((String) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        sectionDetail.sectionInset = UIEdgeInsetsMake(0, 8, 0, 8)
        sectionDetail.itemSpacing = 8
        sectionDetail.lineSpacing = 8
    }
    
    // MARK: Configuration
    func configureWithCellDetail(_ cellDetail: CellDetail) {
        
        lblOption.text = cellDetail.cellText
        if let variantDictionary = cellDetail.cellData as? [String] {
            sectionDetail.sectionDataList.removeAll()
            for variant in variantDictionary {
                let sizeCellDetail = CellDetail()
                sizeCellDetail.cellSize = CGSize(width: Int(cellWidth), height: 30)
                sizeCellDetail.cellText = variant
                sizeCellDetail.cellType = .ProductSize
                sectionDetail.sectionDataList.append(sizeCellDetail)
            }
            
            let calulatedWidth = (cellSpacing * (Float(variantDictionary.count-1))) + (cellWidth * (Float(variantDictionary.count))) + 10
            collectionViewWidth.constant = CGFloat((calulatedWidth > Float(self.frame.size.width - CGFloat(margins*2))) ? Float(self.frame.size.width - CGFloat(margins*2)) : calulatedWidth)
            
            colSizes.delegate = self
            colSizes.dataSource = self
            colSizes.reloadData()
        }
    }
    
    // MARK: CollectionView flow layout delegates
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return sectionDetail.sectionDataList[(indexPath as NSIndexPath).row].cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionDetail.sectionInset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return sectionDetail.headerSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return sectionDetail.footerSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionDetail.lineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return sectionDetail.itemSpacing
    }
    
    // MARK: CollectionView delegates
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let selectedSize = sectionDetail.sectionDataList[(indexPath as NSIndexPath).row].cellText {
            if tappedSize != nil {
                SelectedSize = selectedSize
                tappedSize!(selectedSize)
                colSizes.reloadData()
            }
        }
    }
    
    // MARK: CollectionView datasource
    internal func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sectionDetail.sectionDataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let productSizeCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductSizeCell", for: indexPath) as! ProductSizeCell
        productSizeCell.configureWithCellDetail(sectionDetail.sectionDataList[(indexPath as NSIndexPath).row])
        return productSizeCell
    }
}

