//
//  FavouriteProductCell.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 15/06/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit
import AlamofireImage

class FavouriteProductCell: UITableViewCell {

    @IBOutlet var imgProduct: UIImageView!
    @IBOutlet var lblName: UILabel!
    @IBOutlet var lblCategoryName: UILabel!
    @IBOutlet var lblPrice: UILabel!
    
    var removeFavouriteProduct: (() -> ())?
    
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
        
        if let product = cellDetail.cellData as? FavouriteProduct {
            if let productImageURL = product.productThumbImageURL {
                imgProduct.setImageWithURL(productImageURL, completion: { (success, isCancelled, image) in
                })
            }
            
            lblName.text = product.name
            lblPrice.text = product.currentPrice.formattedWithCurrency
            lblCategoryName.text = product.category
        }
    }
    
    @IBAction func removeTapped(_ sender: UIButton) {
        
        if removeFavouriteProduct != nil {
            removeFavouriteProduct!()
        }
    }
}
