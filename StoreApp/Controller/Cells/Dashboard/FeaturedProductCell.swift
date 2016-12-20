//
//  FeaturedProductCell.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 30/04/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit
import AlamofireImage

class FeaturedProductCell: UICollectionViewCell {    

    @IBOutlet var imgLoader: UIImageView!
    @IBOutlet var imgProduct: UIImageView!
    @IBOutlet var lblProductName: UILabel!
    @IBOutlet var lblProductPrice: UILabel!
    @IBOutlet var downloadIndicator: NVActivityIndicatorView!
    @IBOutlet var lblDiscount: UILabel!
    
    override func awakeFromNib() {
        self.layer.borderWidth = 1.0
        self.layer.borderColor = UIColor(hexString: "#E6E6E6")?.cgColor
    }
    
    // MARK: Configuration
    func configureWithCellDetail(_ cellDetail: CellDetail) {
        
        // Hide sale image
        self.imgLoader.isHidden = true
        self.lblDiscount.isHidden = true
        self.lblDiscount.backgroundColor = UIColor(patternImage: UIImage(named: "sale")!)
        
        if let product = cellDetail.cellData as? Product {
            if let productImageURL = product.productImageURL {
                
                if ShowLoaderIcon {
                    imgLoader.isHidden = false
                } else {
                    downloadIndicator.color = GeneralButtonColor!
                    downloadIndicator.startAnimation()
                }
                imgProduct.setImageWithURL(productImageURL, completion: { (success, isCancelled, image) in
                    if success || (success == false && isCancelled == false) {
                        if ShowLoaderIcon {
                            self.imgLoader.isHidden = true
                        } else {
                            self.downloadIndicator.stopAnimation()
                        }
                        if product.isOnSale {
                            self.lblDiscount.isHidden = false
                            if EnableDiscountListing {
                                self.lblDiscount.text = product.percentageString
                            }
                        }
                    }
                })
            }
            
            self.lblProductName.text = product.name
            self.lblProductPrice.text = product.currentPrice.formattedWithCurrency
            
            if product.isOnSale {
                self.lblProductPrice.attributedText = product.smallPriceString
            }
        }
    }
}

