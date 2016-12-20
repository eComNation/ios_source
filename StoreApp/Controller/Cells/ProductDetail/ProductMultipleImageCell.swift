//
//  ProductMultipleImageCell.swift
//  ViraniGems
//
//  Created by Rushi Sangani on 29/09/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class ProductMultipleImageCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionViewForProductImages: UICollectionView!
    @IBOutlet weak var collectionViewWidth: NSLayoutConstraint!
    @IBOutlet var imgProduct: UIImageView!
    @IBOutlet var downloadIndicator: NVActivityIndicatorView!
    
    var selectedProductImage: ((String) -> ())?
    var onImageCompleted: (() -> ())?
    var imagesArray = NSMutableArray()
    
    var selectedImageIndex: NSInteger = 0
    let margins: Float = 10.0
    let cellSpacing: Float = 8.0
    let cellWidth: Float = 58.0
    
    let imageDownloader = ImageDownloader(
        configuration: ImageDownloader.defaultURLSessionConfiguration(),
        downloadPrioritization: .fifo,
        maximumActiveDownloads: 10,
        imageCache: AutoPurgingImageCache()
    )
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if(imagesArray.count > 1){
            collectionViewHeight.constant = 60
            collectionViewForProductImages.delegate = self
            collectionViewForProductImages.dataSource = self
            collectionViewForProductImages.reloadData()
        } else {
            collectionViewHeight.constant = 0
        }
        
        let calulatedWidth = 1 + (cellSpacing * (Float(imagesArray.count - 1))) + (cellWidth * (Float(imagesArray.count)))
        collectionViewWidth.constant = CGFloat((calulatedWidth > Float(self.frame.size.width - CGFloat(margins*2))) ? Float(self.frame.size.width - CGFloat(margins*2)) : calulatedWidth)
    }
    
    // MARK: Configuration
    func configureWithCellDetail(cellDetail: CellDetail) {
        
        if let product = cellDetail.cellData as? Product {
            
            imagesArray = NSMutableArray(array: product.allImagesURL!)
            
            if let imageURLs = product.allImagesURL , product.autoScrollTimer == nil {
                
                setCurrentImage(product.allImagesURL?.first)
                
                if AllowsProductImagesAutoAnimation {
                    let allURLRequests: [URLRequestConvertible] = imageURLs.map({ URLRequest(url: $0) })
                    
                    imageDownloader.download(allURLRequests) { response in
                        
                        if response.result.isSuccess {
                            self.startCyclyingImages(product)
                        }
                    }
                }
            }
        }
    }
    
    func setCurrentImage(_ url: URL?) {
        self.addAnimationToImage()
        downloadIndicator.color = GeneralButtonColor!
        downloadIndicator.startAnimation()
        if let productImageURL = url {
            imgProduct.setImageWithURL(productImageURL, completion: { (success, isCancelled, image) in
                if success || (success == false && isCancelled == false) {
                    self.downloadIndicator.stopAnimation()
                    if self.onImageCompleted != nil {
                        self.onImageCompleted!()
                    }
                }
            })
        }
    }
    
    func addAnimationToImage() {
        let fadeTransition = CATransition()
        fadeTransition.duration = 0.5
        fadeTransition.repeatCount = 0
        imgProduct.layer.add(fadeTransition, forKey: "imageFade")
    }
    
    func startCyclyingImages(_ product: Product) {
        if product.autoScrollTimer == nil {
            product.startImageTimer()
            product.listenForImageChange = { [weak self](imageUrl) in
                self?.addAnimationToImage()
                self?.downloadIndicator.color = GeneralButtonColor!
                self?.downloadIndicator.startAnimation()
                self?.imgProduct.setImageWithURL(imageUrl, completion: { (success, isCancelled, image) in
                    if success || (success == false && isCancelled == false) {
                        self?.downloadIndicator.stopAnimation()
                    }
                })
            }
        }
    }
    
    // MARK: CollectionView delegates
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let imageData = imagesArray[indexPath.row] as? URL {
            if(selectedProductImage != nil){
                selectedProductImage!(imageData.absoluteString)
            }
        }
        selectedImageIndex = indexPath.row
        collectionView.reloadData()
    }
    
    // MARK: CollectionView datasource
    private func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView.collectionViewLayout.invalidateLayout()
        return imagesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductImageCell", for: indexPath as IndexPath) as! ProductImageCell
        
        let imageURL = imagesArray[indexPath.row] as! URL
        
        // set image
        cell.downloadIndicator.color = GeneralButtonColor!
        cell.downloadIndicator.startAnimation()
        cell.imageView?.setImageWithURL(imageURL) { (success, isCancelled, image) in
           cell.downloadIndicator.stopAnimation()
        }
        
        cell.isImageSelected = (selectedImageIndex == indexPath.row) ? true : false
        
        cell.contentView.layer.cornerRadius = 1
        cell.contentView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.8).cgColor
        cell.contentView.layer.borderWidth = 0.5
        
        return cell
    }
}
