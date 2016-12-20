//
//  OrderCell.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 18/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

class OrderCell: UITableViewCell {

    @IBOutlet var lblOrderNumber: UILabel!
    @IBOutlet var lblOrderStatus: UILabel!
    @IBOutlet var lblOrderStatusWidth: NSLayoutConstraint!
    @IBOutlet var lblPrice: UILabel!
    @IBOutlet var lblDate: UILabel!
    @IBOutlet var lblNumberOfItems: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

        // Set order status label corner radius
        lblOrderStatus.layer.cornerRadius = 2.0
        lblOrderStatus.layer.masksToBounds = true
    }

    // MARK: Configuration
    func configureWithCellDetail(_ cellDetail: CellDetail) {
        
        if let orderInfo = cellDetail.cellData as? OrderInfo {
            
            // Set order number
            lblOrderNumber.text = "Order #" + orderInfo.number!
            
            // Set order status
            lblOrderStatus.text = orderInfo.order_status?.name!.uppercased()
            
            /*
             Order statuses:
             1: Pending (bg: 999999, border: none, text: white)
             7: Ready to dispatch (bg: none, border: 999999, text: 999999)
             8: Packing (bg: none, border: 999999, text: 999999)
             9: Failed (bg: DD4A4A, border: none, text: FFFFFF)
              : Complete (bg: 38B752, border: none, text: FFFFFF)
             */
            
            switch Int((orderInfo.order_status?.id)!) {
            case 1:
                lblOrderStatus.backgroundColor = UIColor(hexString: "999999")
                lblOrderStatus.textColor = UIColor.white
                lblOrderStatus.layer.borderColor = UIColor.clear.cgColor
                lblOrderStatus.layer.borderWidth = 0.0
                
            case 7, 8:
                lblOrderStatus.backgroundColor = UIColor.clear
                lblOrderStatus.textColor = UIColor(hexString: "999999")
                lblOrderStatus.layer.borderColor = UIColor(hexString: "999999")!.cgColor
                lblOrderStatus.layer.borderWidth = 1.0
                
            case 9:
                lblOrderStatus.backgroundColor = UIColor(hexString: "DD4A4A")
                lblOrderStatus.textColor = UIColor.white
                lblOrderStatus.layer.borderColor = UIColor.clear.cgColor
                lblOrderStatus.layer.borderWidth = 0.0
                
            default:
                lblOrderStatus.backgroundColor = UIColor(hexString: "999999")
                lblOrderStatus.textColor = UIColor.white
                lblOrderStatus.layer.borderColor = UIColor.clear.cgColor
                lblOrderStatus.layer.borderWidth = 0.0
            }
            
            lblOrderStatusWidth.constant = (lblOrderStatus.text?.widthWithConstrainedHeight(height: lblOrderStatus.frame.size.height, font: lblOrderStatus.font))! + 10
            self.layoutIfNeeded()
            
            
            // Set price
            lblPrice.text = orderInfo.grand_total!.formattedWithCurrency
            
            // Set placed on date
            if let pacedDate = orderInfo.created_at {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                if let date = dateFormatter.date(from: pacedDate) {
                    dateFormatter.dateFormat = "dd MMM,yyyy"
                    lblDate.text = "PLACED ON " + dateFormatter.string(from: date)
                } else {
                    lblDate.text = "NO DATE INFO"
                }
            }
            
            // Set number of items
            if orderInfo.total_items > 1 {
                lblNumberOfItems.text = String(format: "%d ITEMS", orderInfo.total_items)
            } else{
                lblNumberOfItems.text = String(format: "%d ITEM", orderInfo.total_items)                
            }
        }
    }

}
