
//
//  ProductTitleCell.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 27/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

class ProductTitleOnlyCell: UITableViewCell {

    @IBOutlet var lblProductName: UILabel!
    
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
        
        if let product = cellDetail.cellData as? Product {            
            lblProductName.text = product.name
        }
    }
}
