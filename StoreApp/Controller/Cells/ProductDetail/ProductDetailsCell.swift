//
//  ProductDetailsCell.swift
//  Hiva
//
//  Created by Rakesh Pethani on 28/06/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

class ProductDetailsCell: UITableViewCell {

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
        
        if let product = cellDetail.cellData as? Product , self.contentView.subviews.count <= 1 {
            
            if let detailsArray = product.detailsArray {
                
                var y: CGFloat = 10
                for filterAttribute in detailsArray {
                    
                    let lblTitle = UILabel(frame: CGRect(x: 10, y: y, width: 120, height: 30))
                    lblTitle.text = filterAttribute.name?.uppercased()
                    lblTitle.font = UIFont.systemFont(ofSize: 12)
                    lblTitle.textColor = UIColor(hexString: "B3B3B3")
                    self.contentView.addSubview(lblTitle)
                    
                    let lblValues = UILabel(frame: CGRect(x: 160, y: y, width: self.frame.size.width - 160, height: 30))
                    lblValues.text = filterAttribute.values?.componentsJoined(by: ",").uppercased()
                    lblValues.font = UIFont.systemFont(ofSize: 12)
                    lblValues.textColor = UIColor.darkGray
                    self.contentView.addSubview(lblValues)
                    
                    y += 40
                    
                    let divideView = UIView(frame: CGRect(x: 10, y: y, width: self.frame.size.width - 20, height: 1))
                    divideView.backgroundColor = UIColor(hexString: "E6E6E6")
                    self.contentView.addSubview(divideView)
                    
                    y += 10
                }
            }
        }
    }
}
