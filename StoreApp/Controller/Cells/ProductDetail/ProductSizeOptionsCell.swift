//
//  ProductSizeOptionsCell.swift
//  Timberfruit
//
//  Created by Rakesh Pethani on 31/07/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit
import Material

class ProductSizeOptionsCell: UITableViewCell {

    @IBOutlet var viewOptionsContainer: UIView!
    
    var selectionMadeForLevel: ((Int, String, Int) -> ())?
    
    // MARK: Configuration
    func configureWithCellDetail(_ cellDetail: CellDetail) {
        
        if let variantDictionary = cellDetail.cellData as? [String : [ProductVariant]] {
            
            for view in viewOptionsContainer.subviews {
                view.removeFromSuperview()
            }
            
            var y: CGFloat = 0
            
            var level = 1
            
            for (key, variants) in variantDictionary {
                
                if variants.count == 0 {
                    continue
                }
                
                let sizeSelectionView = SizeSelectionView(frame: CGRect(x: 0, y: y, width: Material.Device.width - 16, height: 115))
                
                let sortedVariants = variants.sorted(by: { $0.id < $1.id })
                
                for variant in sortedVariants {
                    variant.level = level
                }
                
                var selectedSize = sortedVariants.first?.option2 != nil ? (sortedVariants.first?.option2)! : ""
                var selectedQuantity = "\((sortedVariants.first?.selectedQuantity)!)"
                
                if let selectedVariant = sortedVariants.filter({ $0.isSelected }).first {
                    selectedSize = selectedVariant.option2 != nil ? (selectedVariant.option2)! : ""
                    selectedQuantity = "\(selectedVariant.selectedQuantity)"
                } else {
                    sortedVariants.first?.isSelected = true
                }
                
                sizeSelectionView.setUIElementsWithTitle(key, size: selectedSize, quantity: selectedQuantity, lvl: level, sizes: sortedVariants.map({ $0.option2! }))
                sizeSelectionView.selectionMadeForLevel = { (lvl, selSize, selQuantity) in
                    if self.selectionMadeForLevel != nil {
                        self.selectionMadeForLevel!(lvl, selSize, selQuantity)
                    }
                }
                
                viewOptionsContainer.addSubview(sizeSelectionView)

                y += 125
                level += 1
            }
            
            self.viewOptionsContainer.layoutIfNeeded()
        }
    }
}
