//
//  AddressCell.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 25/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

class AddressCell: UITableViewCell {

    @IBOutlet var viewAddressContainer: UIView!
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet var lblMobileNumber: UILabel!
    @IBOutlet var lblAddressInfo: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        viewAddressContainer.layer.cornerRadius = 2.0
        viewAddressContainer.layer.masksToBounds = true
        viewAddressContainer.layer.borderColor = UIColor(hexString: "CCCCCC")?.cgColor
        viewAddressContainer.layer.borderWidth = 1.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureWithCellDetail(_ cellDetail: CellDetail) {
        
        if let addressInfo = cellDetail.cellData as? Address {
            
            // Set user name
            lblUserName.text = addressInfo.fullName
            
            // Set mobile number
            lblMobileNumber.text = addressInfo.phoneNumber
            
            // Set address line
            lblAddressInfo.text = addressInfo.fullAddress
        }
    }
}
