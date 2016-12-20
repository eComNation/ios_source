//
//  RelatedProductsCell.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 01/06/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

class RelatedProductsCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet var lblSectionTitle: UILabel!
    
    // Data source related properties
    let sectionDetail: SectionDetail = SectionDetail()
    
    var tappedProduct: ((Product) -> ())?
    
    // Outlets
    @IBOutlet var colRelatedItems: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: Configuration
    func configureWithCellDetail(_ cellDetail: CellDetail) {
        
        lblSectionTitle.text = cellDetail.cellText
        
        if let productArray = cellDetail.cellData as? [Product] {
            sectionDetail.sectionDataList.removeAll()
            for product in productArray {
                let bannerDetailCellDetail = CellDetail()
                bannerDetailCellDetail.cellSize = CGSize(width: (self.frame.height - 64) * CGFloat(FeaturedProductCellWidthByHeightFactor), height: self.frame.height - 64)
                bannerDetailCellDetail.cellData = product
                bannerDetailCellDetail.cellType = .Product
                sectionDetail.sectionDataList.append(bannerDetailCellDetail)
            }
            
            colRelatedItems.delegate = self
            colRelatedItems.dataSource = self
            colRelatedItems.reloadData()
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
        if let product = sectionDetail.sectionDataList[(indexPath as NSIndexPath).row].cellData as? Product {
            if tappedProduct != nil {
                tappedProduct!(product)
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
        let productCell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCell", for: indexPath) as! ProductCell
        productCell.configureWithCellDetail(sectionDetail.sectionDataList[(indexPath as NSIndexPath).row])
        return productCell
    }
}
