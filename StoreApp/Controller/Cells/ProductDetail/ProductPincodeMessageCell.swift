//
//  ProductPincodeMessageCell.swift
//  Hiva
//
//  Created by Rakesh Pethani on 28/06/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

class ProductPincodeMessageCell: UITableViewCell {

    @IBOutlet var lblPincodeMessage: UILabel!
    
    var clearPincode: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureWithCellDetail(_ cellDetail: CellDetail) {
        lblPincodeMessage.text = cellDetail.cellText
    }
    
    @IBAction func btnClearTapped(_ sender: UIButton) {
        if clearPincode != nil {
            clearPincode!()
        }
    }
}
