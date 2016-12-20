//
//  CartRewardCell.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 30/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

class CartRewardCell: UITableViewCell {

    @IBOutlet var lblAvailableReward: UILabel!
    @IBOutlet var viewReward: UIView!
    @IBOutlet var txtRewardPoints: UITextField!
    @IBOutlet var btnReedem: UIButton!
    
    var applyRewardPoints: ((_ points: Int) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
        viewReward.layer.cornerRadius = 2.0
        viewReward.layer.masksToBounds = true
        viewReward.layer.borderColor = UIColor(hexString: "CCCCCC")?.cgColor
        viewReward.layer.borderWidth = 1.0
        
        btnReedem.setTitleColor(GeneralButtonColor, for: UIControlState())
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureWithCellDetail(_ cellDetail: CellDetail) {
        
        if let currentCart = cartManager.currentCart {
            
            lblAvailableReward.text = "Available reward points = \(currentCart.available_reward_points), which values = \(currentCart.available_reward_points / currentCart.points_per_unit_amount)"
        } else {
            lblAvailableReward.text = ""
        }
    }
    
    @IBAction func btnRedeemTapped(_ sender: UIButton) {
        
        if let rewardPoints = Int(txtRewardPoints.text!) , rewardPoints > 0 {
            if applyRewardPoints != nil {
                applyRewardPoints!(rewardPoints)
            }
        }
    }
}
