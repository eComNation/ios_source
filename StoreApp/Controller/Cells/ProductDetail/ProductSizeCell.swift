//
//  ProductSizeCell.swift
//  ViraniGems
//
//  Created by Rushi Sangani on 12/09/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

class ProductSizeCell: UICollectionViewCell {
    
    @IBOutlet var lblSize: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.layer.borderColor = UIColor.gray.cgColor
        self.contentView.layer.cornerRadius = 2
        self.contentView.layer.borderWidth = 0.5
        self.contentView.layer.masksToBounds = true
    }
    
    // MARK: Configuration
    func configureWithCellDetail(_ cellDetail: CellDetail) {
        lblSize.font = UIFont.systemFont(ofSize: 15)
        lblSize.text = cellDetail.cellText?.uppercased()
        
        if cellDetail.cellText == SelectedSize {
            self.contentView.layer.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4).cgColor
        } else {
            self.contentView.layer.backgroundColor = UIColor.white.cgColor
        }
    }
}

