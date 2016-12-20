//
//  OrderPricingInfoCell.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 22/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

class OrderPricingInfoCell: UITableViewCell {

    @IBOutlet var lblSubtotal: UILabel!
    @IBOutlet var lblDiscount: UILabel!
    @IBOutlet var lblTaxes: UILabel!
    @IBOutlet var lblTotal: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureWithCellDetail(_ cellDetail: CellDetail) {
        
        if let orderInfo = cellDetail.cellData as? OrderInfo {
            
            // Set subtotal
            if let subTotal = orderInfo.actual_amount {
                lblSubtotal.text = subTotal.formattedWithCurrency
            } else {
                lblSubtotal.text = 0.0.formattedWithCurrency
            }
            
            // Set discount
            if let discount = orderInfo.discount {
                lblDiscount.text = discount.formattedWithCurrency
            } else {
                lblDiscount.text = 0.0.formattedWithCurrency
            }
            
            // Set taxes
            if let taxes = orderInfo.tax_amount {
                lblTaxes.text = taxes.formattedWithCurrency
            } else {
                lblTaxes.text = 0.0.formattedWithCurrency
            }
            
            // Set total
            if let total = orderInfo.grand_total {
                lblTotal.text = total.formattedWithCurrency
            } else {
                lblTotal.text = 0.0.formattedWithCurrency
            }
        }
    }
}
