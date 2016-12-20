//
//  ProductPincodeCell.swift
//  Hiva
//
//  Created by Rakesh Pethani on 28/06/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

class ProductPincodeCell: UITableViewCell {

    @IBOutlet var txtPincode: UITextField!
    @IBOutlet var btnCheck: UIButton!
    
    var checkPincode: ((_ code: String) -> ())?
    
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
        btnCheck.setTitleColor(GeneralButtonColor, for: .normal)
        txtPincode.text = ""
    }
    
    @IBAction func btnCheckTapped(_ sender: UIButton) {
        
        if txtPincode.text?.isNotEmpty == true {
            if checkPincode != nil {
                checkPincode!(txtPincode.text!)
            }
        }
    }
}
