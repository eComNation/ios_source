//
//  ListBannerCell.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 07/06/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit
import Material
import AlamofireImage

var heightDiff : CGFloat = 0.0

class ListBannerCell: UICollectionViewCell {

    @IBOutlet var viewBanner: View!
    @IBOutlet var imgBanner: UIImageView!
    @IBOutlet var downloadIndicator: NVActivityIndicatorView!
    
    var downloadedImage: ((_ image: UIImage) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewBanner.borderColor = UIColor.lightGray
        viewBanner.borderWidth = 0.5
        //self.contentView.layer.masksToBounds = true
    }

    // MARK: Configuration
    func configureWithCellDetail(_ cellDetail: CellDetail) {
        
        if let banner = cellDetail.cellData as? Banner {
            if let bannerImageURL = banner.bannerURL {
                
                viewBanner.depth = depth
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
    
    /*func imageWithImage (sourceImage:UIImage, scaledToWidth: CGFloat) -> UIImage {
        let oldWidth = sourceImage.size.width
        let scaleFactor = scaledToWidth / oldWidth
        
        let newHeight = sourceImage.size.height * scaleFactor
        let newWidth = oldWidth * scaleFactor
        
        UIGraphicsBeginImageContext(CGSize(width:newWidth, height:newHeight))
        sourceImage.draw(in: CGRect(x:0, y:0, width:newWidth, height:newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }*/
}
