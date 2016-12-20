//
//  OrderItemInfoCell.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 22/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit
import AlamofireImage

class OrderItemInfoCell: UITableViewCell {

    @IBOutlet var imgItem: UIImageView!
    @IBOutlet var lblSKUCode: UILabel!
    @IBOutlet var lblItemName: UILabel!
    @IBOutlet var lblQuantity: UILabel!
    @IBOutlet var lblPrice: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureWithCellDetail(_ cellDetail: CellDetail) {
        if let orderItem = cellDetail.cellData as? OrderItem {
            
            // Set image
            if let imageUrl = orderItem.productImageURL {
                imgItem.setImageWithURL(imageUrl, completion: { (success, isCancelled, image) in
                })
            }

            // Set sku code
            if let skuCode = orderItem.sku {
                lblSKUCode.text = "SKU: \(skuCode)"
            } else {
                lblSKUCode.text = ""
            }
            
            // Set product name
            if let productName = orderItem.name {
                lblItemName.text = productName
            } else {
                lblItemName.text = ""
            }
            
            // Set Quantity
            lblQuantity.text = "\(orderItem.quantity)"
            
            // Set Price
            if let price = orderItem.actual_price {
                lblPrice.text = price.formattedWithCurrency
            } else {
                lblPrice.text = 0.0.formattedWithCurrency
            }
        }
    }
}
