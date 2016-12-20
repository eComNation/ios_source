//
//  ProductCountHeader.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 11/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

class ProductCountHeader: UICollectionViewCell {
    
    @IBOutlet var lblProductCount: UILabel!
    
    func configureWithCellDetail(_ cellDetail: CellDetail) {
        lblProductCount.text = cellDetail.cellText
    }
}
