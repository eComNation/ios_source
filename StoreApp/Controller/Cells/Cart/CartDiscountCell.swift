//
//  CartDiscountCell.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 30/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

class CartDiscountCell: UITableViewCell {

    @IBOutlet var viewDiscount: UIView!
    @IBOutlet var txtDiscount: UITextField!
    @IBOutlet var btnApply: UIButton!
    
    var applyCode: ((_ code: String?) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        viewDiscount.layer.cornerRadius = 2.0
        viewDiscount.layer.masksToBounds = true
        viewDiscount.layer.borderColor = UIColor(hexString: "CCCCCC")?.cgColor
        viewDiscount.layer.borderWidth = 1.0
        
        btnApply.setTitleColor(GeneralButtonColor, for: UIControlState())
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureWithCellDetail(_ cellDetail: CellDetail) {
        
    }
    
    @IBAction func btnApplyTapped(_ sender: UIButton) {
        
        if applyCode != nil {
            applyCode!(txtDiscount.text)
        }
    }
}
