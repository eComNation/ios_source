//
//  ProductBrandCell.swift
//  StoreApp
//
//  Created by Abhilesh Halarnkar on 27/10/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

class ProductBrandCell: UITableViewCell {
    
    @IBOutlet var imgBrandLogo: UIImageView!
    @IBOutlet var lblBrandName: UILabel!
    @IBOutlet var lblProductName: UILabel!
    @IBOutlet var lblProductPrice: UILabel!
    @IBOutlet var lblBy: UILabel!
    
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
        
        if let product = cellDetail.cellData as? Product {
            
            lblProductName.text = product.name
            lblProductPrice.text = product.currentVariantPrice.formattedWithCurrency
            
            lblBrandName.text = product.custom_attributes?.first
            if let productImageURL = product.custom_attributes?.last {
                imgBrandLogo.setImageWithURL(URL(string: "http:"+productImageURL)!, completion: { (success, isCancelled, image) in
                    if success || (success == false && isCancelled == false) {
                    }
                })
            }
            
            // Hide/Show sale image
            if product.isOnSale {
                lblProductPrice.attributedText = product.bigPriceString
            }
        
        }
    }
}
