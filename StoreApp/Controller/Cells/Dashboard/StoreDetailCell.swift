//
//  StoreDetailCell.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 31/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit
import CoreData

class StoreDetailCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var buttonCollectionWidth: NSLayoutConstraint!
    @IBOutlet var lblCopyRights: UILabel!
    
    @IBOutlet var colButtons: UICollectionView!
    var imageArray : [StoreDetail] = []
    var selectedProductImage: ((String) -> ())?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundColor = FooterColor
        lblCopyRights.textColor = CopyrightTextColor
        lblCopyRights.text = CopyrightText
        
        let calulatedWidth = (5.0 * (Float(imageArray.count - 1))) + (30.0 * (Float(imageArray.count)))
        buttonCollectionWidth.constant = CGFloat(calulatedWidth)
    }
    
    func configureWithCellDetail() {
        
        imageArray = []
        
        if ApplicationFBLink.isNotEmpty {
            let value = StoreDetail()
            value.url = ApplicationFBLink
            value.image_name = "social_facebook"
            imageArray.append(value)
        }
        
        if ApplicationInstagramLink.isNotEmpty {
            let value = StoreDetail()
            value.url = ApplicationInstagramLink
            value.image_name = "social_instagram"
            imageArray.append(value)
        }
        
        if ApplicationTwitterLink.isNotEmpty {
            let value = StoreDetail()
            value.url = ApplicationTwitterLink
            value.image_name = "social_twitter"
            imageArray.append(value)
        }
        
        if ApplicationPinterestLink.isNotEmpty {
            let value = StoreDetail()
            value.url = ApplicationPinterestLink
            value.image_name = "social_pinterest"
            imageArray.append(value)
        }
        
        if ApplicationYoutubeLink.isNotEmpty {
            let value = StoreDetail()
            value.url = ApplicationYoutubeLink
            value.image_name = "social_youtube"
            imageArray.append(value)
        }
        
        if ApplicationGPlusLink.isNotEmpty {
            let value = StoreDetail()
            value.url = ApplicationGPlusLink
            value.image_name = "social_googleplus"
            imageArray.append(value)
        }
        
        colButtons.delegate = self
        colButtons.dataSource = self
        colButtons.reloadData()
    }
    
    // MARK: CollectionView delegates
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let imageData = imageArray[indexPath.row]
        if(selectedProductImage != nil){
            selectedProductImage!(imageData.url!)
        }
        collectionView.reloadData()
    }
    
    // MARK: CollectionView datasource
    private func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView.collectionViewLayout.invalidateLayout()
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductImageCell", for: indexPath as IndexPath) as! ProductImageCell
        
        let image = imageArray[indexPath.row]
        
        cell.imageView.image = UIImage(named: image.image_name!)
        
        return cell
    }
}
