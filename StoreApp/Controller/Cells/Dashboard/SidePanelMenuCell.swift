//
//  SideMenuCell.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 09/04/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

class SidePanelMenuCell: UITableViewCell {

    @IBOutlet var imgLeftArrow: UIImageView!
    @IBOutlet var lblCategoryName: UILabel!
    @IBOutlet var imgRightArrow: UIImageView!
    
    
    func configureForPreviousCategoryView() {
        
        
        self.backgroundColor = SidePanelCellColor
        
        // Set left arrow visible
        imgLeftArrow.isHidden = false
        
        // Set other views hidder
        lblCategoryName.isHidden = true
        imgRightArrow.isHidden = true
    }
    
    func configureForCellDetail(_ cellDetail: CellDetail, selectedCategoryId: Int) {
        
        contentView.backgroundColor = SidePanelCellColor
        
        // Set left/right arrow hidden
        imgLeftArrow.isHidden = true
        imgRightArrow.isHidden = true
        
        // Set category label text
        lblCategoryName.isHidden = false
        lblCategoryName.text = cellDetail.cellText
        lblCategoryName.textColor = SidePanelTextColor
        
        if let category = cellDetail.cellData as? Category , Int(category.id) != selectedCategoryId{
                // Hide/Show right arrow based on sub-category availability
                let subCategoryPredicate = NSPredicate(format: "parent_id == %d", category.id)
                if PersistencyManager.sharedManager.count("Category", predicate: subCategoryPredicate) > 0 {
                    imgRightArrow.isHidden = false
            }
        }
    }
}
