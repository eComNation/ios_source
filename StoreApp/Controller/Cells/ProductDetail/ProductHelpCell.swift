//
//  ProductHelpCell.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 16/06/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

class ProductHelpCell: UITableViewCell {

    @IBOutlet var lblHelpCareText: UILabel!
    
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
        lblHelpCareText.text = cellDetail.cellText
    }
}
