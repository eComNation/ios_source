//
//  RecentSearchCell.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 01/06/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

class RecentSearchCell: UITableViewCell {

    @IBOutlet var lblRecentSearch: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
    // MARK: Configuration
    func configureWithCellDetail(_ cellDetail: CellDetail) {
        lblRecentSearch.text = cellDetail.cellText
    }
}
