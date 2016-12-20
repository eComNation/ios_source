//
//  ProductImageCell.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 27/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class ProductImageCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var downloadIndicator: NVActivityIndicatorView!
    
    // isSelected
    var isImageSelected:Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
