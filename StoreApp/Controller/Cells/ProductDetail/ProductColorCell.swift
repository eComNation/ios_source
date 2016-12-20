//
//  ProductColorCell.swift
//  Timberfruit
//
//  Created by Rakesh Pethani on 31/07/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

class ProductColorCell: UICollectionViewCell {

    @IBOutlet var imgColor: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.layer.borderColor = UIColor.black.cgColor
        self.contentView.layer.masksToBounds = true
    }
    
    // MARK: Configuration
    func configureWithCellDetail(_ cellDetail: CellDetail) {
        
        if let color = cellDetail.cellText {
            if let colorURL = URL(string: ProductColor + "misc/" + color + ".jpg") {
                imgColor.setImageWithURL(colorURL, completion: { (success, isCancelled, image) in
                })
            }
            
            if let product = cellDetail.cellData as? Product , product.selectedColor == color {
                self.contentView.layer.borderWidth = 1.0
            } else {
                self.contentView.layer.borderWidth = 0.0
            }
        }
    }
}
