//
//  BannerCell.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 10/04/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

let kBannerDetailCellIdentifier = "BannerDetailCell"

class BannerCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // Data source related properties
    let sectionDetail: SectionDetail = SectionDetail()
    
    // Outlets
    @IBOutlet var collBannerDetail: UICollectionView!
    @IBOutlet var paggerBanner: UIPageControl!
    
    var tappedBanner:((_ banner: Banner) -> ())?
    var autoScrollTimer: Timer?
    
    deinit {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }
    
    // MARK: Configuration
    func configureWithCellDetail(_ cellDetail: CellDetail) {
        
        if autoScrollTimer != nil {
            autoScrollTimer?.invalidate()
            autoScrollTimer = nil
        }
        
        autoScrollTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(goToNextPage), userInfo: nil, repeats: true)
        
        if let bannerArray = cellDetail.cellData as? [Banner] {
            sectionDetail.sectionDataList.removeAll()
            for banner in bannerArray {
                let bannerDetailCellDetail = CellDetail()
                bannerDetailCellDetail.cellSize = CGSize(width: self.frame.width, height: self.frame.height)
                bannerDetailCellDetail.cellData = banner
                bannerDetailCellDetail.cellType = .BannerDetail
                sectionDetail.sectionDataList.append(bannerDetailCellDetail)
            }
            
            collBannerDetail.delegate = self
            collBannerDetail.dataSource = self
            collBannerDetail.reloadData()
            
            paggerBanner.numberOfPages = bannerArray.count
            paggerBanner.currentPage = 0
        }
    }
    
    func goToNextPage() {
        
        let bannersCount = sectionDetail.sectionDataList.count
        if bannersCount == 0 {
            return
        }
        
        if paggerBanner.currentPage == bannersCount - 1 {
            paggerBanner.currentPage = 0
        } else {
            paggerBanner.currentPage += 1
        }
        
        if paggerBanner.currentPage > 0 {
            collBannerDetail.scrollToItem(at: IndexPath(item: paggerBanner.currentPage, section: 0), at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
        } else {
            collBannerDetail.scrollToItem(at: IndexPath(item: paggerBanner.currentPage, section: 0), at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
        }
    }
    
    // MARK: CollectionView flow layout delegates
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return sectionDetail.sectionDataList[(indexPath as NSIndexPath).row].cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionDetail.sectionInset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return sectionDetail.headerSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return sectionDetail.footerSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionDetail.lineSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return sectionDetail.itemSpacing
    }
    
    // MARK: CollectionView delegates
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let banner = sectionDetail.sectionDataList[(indexPath as NSIndexPath).row].cellData as? Banner {
            if tappedBanner != nil {
                tappedBanner!(banner)
            }
        }
    }
    
    // MARK: CollectionView datasource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sectionDetail.sectionDataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let bannerCell = collectionView.dequeueReusableCell(withReuseIdentifier: kBannerDetailCellIdentifier, for: indexPath) as! BannerDetailCell
        bannerCell.configureWithCellDetail(sectionDetail.sectionDataList[(indexPath as NSIndexPath).row])
        return bannerCell
    }
    
    // MARK: Scroll view delegates
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = collBannerDetail.contentOffset.x / collBannerDetail.frame.size.width
        paggerBanner.currentPage = Int(ceil(currentPage))
    }
}
