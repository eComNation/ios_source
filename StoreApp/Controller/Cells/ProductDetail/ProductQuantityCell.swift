//
//  ProductQuantityCell.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 27/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

class ProductQuantityCell: UITableViewCell {

    @IBOutlet var lblQuantity: UILabel!
    @IBOutlet var btnMinus: UIButton!
    @IBOutlet var btnPlus: UIButton!
    
    var increaseQuantity: (() -> (Int))?
    var decreaseQuantity: (() -> (Int))?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
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
    
    // MARK: Configuration
    func configureWithCellDetail(_ cellDetail: CellDetail, quantity: Int) {
        
        lblQuantity.text = String(quantity)
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
}
