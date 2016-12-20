//
//  CartPricingCell.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 30/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

class CartPricingCell: UITableViewCell {

    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblPrice: UILabel!
    @IBOutlet var btnRemove: UIButton!

    var removeTapped: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureWithCellDetail(_ cellDetail: CellDetail) {
        
        btnRemove.isHidden = true
        
        if let currentCart = cartManager.currentCart {

            switch cellDetail.cellType {
            case .CartPriceSubtotal:
                lblTitle.text = "SUBTOTAL"
                lblPrice.text = currentCart.subTotal.formattedWithCurrency
                
            case .CartPriceTotal:
                lblTitle.text = "TOTAL"
                lblPrice.text = currentCart.discounted_cart_amount.formattedWithCurrency

            case .CartPriceDiscount:
                if currentCart.discountCoupon != nil {
                    btnRemove.isHidden = false
                }
                lblTitle.text = "DISCOUNT"
                lblPrice.text = currentCart.discountAmount.formattedWithCurrency
            
            case .CartPriceGiftCard:
                btnRemove.isHidden = false
                lblTitle.text = "GIFT CARD"
                lblPrice.text = currentCart.gift_card_amount.formattedWithCurrency
                
            case .CartPriceRewardPoints:
                btnRemove.isHidden = false
                lblTitle.text = "REWARD POINTS"
                lblPrice.text = currentCart.rewardPointsAmount.formattedWithCurrency
                
            default: break
            }

        }
    }
    
    @IBAction func btnRemoveTapped(_ sender: UIButton) {
        if removeTapped != nil {
            removeTapped!()
        }
    }
}
