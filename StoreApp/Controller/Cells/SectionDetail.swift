//
//  SectionDetail.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 09/04/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

enum SectionType: String {
    case UnKnown
    case PreviousCategory
    case CategoriesList
    case AccountSettings
    case FilterGroups
    case ProductDetail
    case RecentSearch
}

class SectionDetail: NSObject {

    var sectionType: SectionType = .UnKnown
    var sectionData: AnyObject?
    var sectionDataList: [CellDetail] = []
    var sectionInset: UIEdgeInsets = UIEdgeInsets.zero
    var sectionTitle: String?
    var lineSpacing: CGFloat = 0.0
    var itemSpacing: CGFloat = 0.0
    var headerSize: CGSize = CGSize.zero
    var footerSize: CGSize = CGSize.zero
    var headerIdentifier: String?
    
    var dataCount: Int {
        return sectionDataList.count
    }
}
