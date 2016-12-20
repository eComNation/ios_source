//
//  ProductPriceOnlyCell.swift
//  Timberfruit
//
//  Created by Rakesh Pethani on 02/08/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

class ProductPriceOnlyCell: UITableViewCell {

    @IBOutlet var lblPrice: UILabel!
    
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
            lblPrice.text = product.priceWithVariants.formattedWithCurrency
        }
    }
}
