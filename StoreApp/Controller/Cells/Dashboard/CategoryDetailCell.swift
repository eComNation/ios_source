//
//  CategoryDetailCell.swift
//  GreenOBazaar
//
//  Created by Rakesh Pethani on 29/06/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit
import Material

class CategoryDetailCell: UICollectionViewCell {

    @IBOutlet var containerView: View!
    @IBOutlet var imgCategory: UIImageView!
    @IBOutlet var lblCategory: UILabel!
    
    // MARK: Configuration
    func configureWithCellDetail(_ cellDetail: CellDetail) {
        
        containerView.depth = depth
        
        if let category = cellDetail.cellData as? Category {
            
            lblCategory.text = category.name
            
            if let categoryImageURL = category.imageUrl {
                imgCategory.setImageWithURL(categoryImageURL, completion: { (success, isCancelled, image) in

                })
            }
        }
    }
}
