//
//  SpaceCell.swift
//  StoreApp
//
//  Created by Abhilesh Halarnkar on 04/11/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

class SpaceCell: UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.contentView.backgroundColor = LightBackColor
        self.contentView.layer.masksToBounds = true
    }
    
    // MARK: Configuration
    func configureWithCellDetail(_ cellDetail: CellDetail) {
    }
}
