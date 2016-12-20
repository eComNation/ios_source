//
//  ProductDescriptionCell.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 29/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

class ProductDescriptionCell: UITableViewCell {

    @IBOutlet var lblDescription: UILabel!
    @IBOutlet var btnMoreLess: UIButton!
    
    var moreLessTapped: ((_ isExpanded: Bool) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        btnMoreLess.setTitleColor(GeneralButtonColor, for: UIControlState())
        btnMoreLess.borderColor = GeneralButtonColor!
        btnMoreLess.borderWidth = 0.5
        btnMoreLess.cornerRadius = 1
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: Configuration
    func configureWithCellDetail(_ cellDetail: CellDetail, isExpanded: Bool) {
        
        btnMoreLess.isSelected = isExpanded
        if let product = cellDetail.cellData as? Product {
            lblDescription.text = product.desc
        }
    }
    
    @IBAction func btnMoreTap(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if moreLessTapped != nil {
            moreLessTapped!(sender.isSelected)
        }
    }
}
