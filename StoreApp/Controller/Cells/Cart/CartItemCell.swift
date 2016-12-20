//
//  CartItemCell.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 28/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit
import AlamofireImage

class CartItemCell: UITableViewCell {

    @IBOutlet var imgItem: UIImageView!
    @IBOutlet var lblSKUCode: UILabel!
    @IBOutlet var lblItemName: UILabel!
    @IBOutlet var lblQuantity: UILabel!
    @IBOutlet var lblPrice: UILabel!
    @IBOutlet var lblCustomAttribute: UILabel!
    @IBOutlet var btnMinus: UIButton!
    @IBOutlet var btnPlus: UIButton!
    @IBOutlet var btnRemove: UIButton!
    @IBOutlet var lblQuantityWarning: UILabel!
    
    var increaseQuantity: (() -> (Int))?
    var decreaseQuantity: (() -> (Int))?
    var removeItem: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        btnMinus.layer.cornerRadius = 5.00
        btnMinus.layer.borderColor = UIColor.gray.cgColor
        btnMinus.layer.borderWidth = 1.0
        btnMinus.layer.masksToBounds = true
        
        btnPlus.layer.cornerRadius = 5.00
        btnPlus.layer.borderColor = UIColor.gray.cgColor
        btnPlus.layer.borderWidth = 1.0
        btnPlus.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureWithCellDetail(_ cellDetail: CellDetail) {
        if let orderItem = cellDetail.cellData as? OrderItem {
            
            // Set image
            if let imageUrl = orderItem.productImageURLWithHTTP {
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

            // Set quantity warning
            lblQuantityWarning.text = ""
//            if orderItem.max_quantity_possible == 0 {
//                lblQuantityWarning.text = "OUT OF STOCK"
//            } else if orderItem.max_quantity_possible < orderItem.quantity {
//                lblQuantityWarning.text = "ONLY \(orderItem.max_quantity_possible) LEFT"
//            }
            
            // Set custom detail label
            if let customDetails = orderItem.custom_details {
                lblCustomAttribute.isHidden = false
                lblCustomAttribute.text = customDetails
            } else {
                lblCustomAttribute.isHidden = true
            }
            
            // Set Price
            if let price = orderItem.actual_price {
                lblPrice.text = price.formattedWithCurrency
            } else {
                lblPrice.text = "0.0".formattedWithCurrency
            }
        }
    }
    
    @IBAction func btnMinusTapped(_ sender: UIButton) {
        
        if decreaseQuantity != nil {
            lblQuantity.text = String(decreaseQuantity!())
        }
    }
    
    @IBAction func btnPlusTapped(_ sender: UIButton) {
        
        if increaseQuantity != nil {
            lblQuantity.text = String(increaseQuantity!())
        }
    }
    
    @IBAction func btnRemoveTapped(_ sender: UIButton) {
        
        if removeItem != nil {
            removeItem!()
        }
    }
}
