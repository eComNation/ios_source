//
//  FilterSectionHeader.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 06/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

class FilterSectionHeader: UITableViewHeaderFooterView {

    @IBOutlet var lblFilter: UILabel!
    @IBOutlet var imgArrow: UIImageView!
    
    var filterGroup: FilterGroup?
    var onHeaderSelected: ((_ filterGroup: FilterGroup?) -> (Void))?
    
    func setWithFilterGroup(_ filterGroup: FilterGroup) {
        self.filterGroup = filterGroup
        lblFilter.text = filterGroup.name?.capitalized

        if self.filterGroup?.isExpanded == true {
            self.imgArrow.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2))
        } else {
            self.imgArrow.transform = CGAffineTransform.identity
        }
    }
    
    @IBAction func tappedHeader(_ sender: UIButton) {
        
        filterGroup?.toggleExpansation()
        
        if onHeaderSelected != nil {
            onHeaderSelected!(filterGroup)
        }
    }
}
