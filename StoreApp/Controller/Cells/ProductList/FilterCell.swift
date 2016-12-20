//
//  FilterCell.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 10/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

class FilterCell: UITableViewCell {

    @IBOutlet var lblFilterName: UILabel!
    @IBOutlet var chkBoxFilter: UIButton!
    
    func setWithFilter(_ filter: Filter) {

        lblFilterName.text = filter.value?.capitalized
        setCheckStatus(filter.isSelected, animated: false)
    }
    
    func setCheckStatus(_ selected: Bool, animated: Bool) {
        chkBoxFilter.isSelected = selected
    }
}
