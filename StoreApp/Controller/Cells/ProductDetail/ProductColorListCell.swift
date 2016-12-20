//
//  ProductColorListCell.swift
//  Timberfruit
//
//  Created by Rakesh Pethani on 31/07/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

class ProductColorListCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet var colColors: UICollectionView!
    
    // Data source related properties
    let sectionDetail: SectionDetail = SectionDetail()
    
    var tappedColor: ((String) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        sectionDetail.sectionInset = UIEdgeInsetsMake(0, 8, 0, 8)
        sectionDetail.itemSpacing = 8
        sectionDetail.lineSpacing = 8
    }
    
    // MARK: Configuration
    func configureWithCellDetail(_ cellDetail: CellDetail) {
        
        if let product = cellDetail.cellData as? Product {
            sectionDetail.sectionDataList.removeAll()
            for color in product.custom_attributes! {
                let colorCellDetail = CellDetail()
                colorCellDetail.cellSize = CGSize(width: 50, height: 50)
                colorCellDetail.cellData = product
                colorCellDetail.cellText = color
                colorCellDetail.cellType = .ProductColor
                sectionDetail.sectionDataList.append(colorCellDetail)
            }
            
            colColors.delegate = self
            colColors.dataSource = self
            colColors.reloadData()
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
        
        if let selectedColor = sectionDetail.sectionDataList[(indexPath as NSIndexPath).row].cellText {
            if tappedColor != nil {
                tappedColor!(selectedColor)
                colColors.reloadData()
            }
        }
    }
    
    // MARK: CollectionView datasource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sectionDetail.sectionDataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let productColorCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductColorCell", for: indexPath) as! ProductColorCell
        productColorCell.configureWithCellDetail(sectionDetail.sectionDataList[(indexPath as NSIndexPath).row])
        return productColorCell
    }
}
