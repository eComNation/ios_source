//
//  BannerDetailCell.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 10/04/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit
import AlamofireImage

class BannerDetailCell: UICollectionViewCell {
    
    @IBOutlet var imgBanner: UIImageView!
    @IBOutlet var downloadIndicator: NVActivityIndicatorView!
    
    // MARK: Configuration
    func configureWithCellDetail(_ cellDetail: CellDetail) {
        
        if let banner = cellDetail.cellData as? Banner {
            if let bannerImageURL = banner.bannerURL {
                
                downloadIndicator.color = GeneralButtonColor!
                downloadIndicator.startAnimation()
                imgBanner.setImageWithURL(bannerImageURL, completion: { (success, isCancelled, image) in
                    if success || (success == false && isCancelled == false) {
                        self.downloadIndicator.stopAnimation()
                    }
                })
            }
        }
    }
}
