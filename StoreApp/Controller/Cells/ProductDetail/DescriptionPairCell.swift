//
//  DescriptionPairCell.swift
//  StoreApp
//
//  Created by Abhilesh Halarnkar on 21/11/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import Foundation

class DescriptionPairCell: UITableViewCell {
    
    // MARK: Configuration
    func configureWithCellDetail(_ cellDetail: CellDetail) {
        
        if let detailsArray = cellDetail.cellData as? Array<GemOption> , self.contentView.subviews.count <= 1 {
            
            let view = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 20))
            view.backgroundColor = UIColor(hexString: "EEEEEE")
            self.contentView.addSubview(view)
            
            var y: CGFloat = 25
            
            let lblHeader = UILabel(frame: CGRect(x: 10, y: y, width: self.frame.size.width - 20, height: 20))
            lblHeader.text = cellDetail.cellText
            lblHeader.font = UIFont.systemFont(ofSize: 14, weight: 0.4)
            lblHeader.textColor = UIColor.darkGray
            self.contentView.addSubview(lblHeader)
            y += 25
            
            let divideView = UIView(frame: CGRect(x: 5, y: y, width: self.frame.size.width - 10, height: 1))
            divideView.backgroundColor = UIColor(hexString: "E6E6E6")
            self.contentView.addSubview(divideView)
            
            y += 5
            
            for detailData in detailsArray {
                
                if detailData.name!.isNotEmpty {
                    let lblHeader = UILabel(frame: CGRect(x: 10, y: y, width: self.frame.size.width - 20, height: 20))
                    lblHeader.text = detailData.name
                    lblHeader.font = UIFont.systemFont(ofSize: 12, weight: 0.4)
                    lblHeader.textColor = UIColor.darkGray
                    self.contentView.addSubview(lblHeader)
                    y += 20
                    
                    let divideView = UIView(frame: CGRect(x: 5, y: y, width: self.frame.size.width - 10, height: 1))
                    divideView.backgroundColor = UIColor(hexString: "E6E6E6")
                    self.contentView.addSubview(divideView)
                    
                    y += 5
                }
                
                for detail in detailData.values! {
                    
                    let lblTitle = UILabel(frame: CGRect(x: 10, y: y, width: 120, height: 20))
                    lblTitle.text = detail.id
                    lblTitle.font = UIFont.systemFont(ofSize: 12)
                    lblTitle.textColor = UIColor(hexString: "B3B3B3")
                    self.contentView.addSubview(lblTitle)
                    
                    let lblValues = UILabel(frame: CGRect(x: 160, y: y, width: self.frame.size.width - 170, height: 20))
                    lblValues.text = detail.name
                    lblValues.textAlignment = NSTextAlignment.right
                    lblValues.font = UIFont.systemFont(ofSize: 12)
                    lblValues.textColor = UIColor.darkGray
                    self.contentView.addSubview(lblValues)
                    
                    y += 20
                    
                    let divideView = UIView(frame: CGRect(x: 5, y: y, width: self.frame.size.width - 10, height: 1))
                    divideView.backgroundColor = UIColor(hexString: "E6E6E6")
                    self.contentView.addSubview(divideView)
                    
                    y += 5
                }
            }
        }
    }
}

