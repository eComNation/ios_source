//
//  ProductDetailTabsCell.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 15/06/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit
import Material

class ProductDetailTabsCell: UITableViewCell {

    @IBOutlet var viewTabbarContainer: UIView!
    
    // MARK: Tabbar related properties
    var topTabbar: TabBar?
    var btnTab1: FlatButton?
    var btnDetail: FlatButton?
    var btnTab2: FlatButton?
    var btnTab3: FlatButton?
    var btnTab4: FlatButton?
    
    var selectedTab: ((ProductDetailTab) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureWithSelectedTab(_ selectedTab: ProductDetailTab, hasDetails: Bool = false)  {
        
        // Add tabbar to container view
        if topTabbar == nil {
            topTabbar = TabBar(frame: viewTabbarContainer.bounds)
            topTabbar!.backgroundColor = UIColor.clear
            topTabbar!.lineColor = BaseApplicationColor
            topTabbar!.borderWidth = 0.5
            topTabbar!.height = 40.0
            topTabbar!.borderColor = UIColor.lightGray
            viewTabbarContainer.addSubview(topTabbar!)
            
            var tabsToShow : [FlatButton] = []
            
            if TabHeader1.isNotEmpty {
                btnTab1 = FlatButton()
                btnTab1!.pulseColor = BaseApplicationColor!
                btnTab1!.setTitle(TabHeader1.uppercased(), for: UIControlState())
                btnTab1!.setTitleColor(FadedApplicationColor, for: UIControlState())
                btnTab1!.setTitleColor(BaseApplicationColor, for: .selected)
                btnTab1!.titleLabel?.font = UIFont.boldSystemFont(ofSize: 10)
                btnTab1!.borderWidth = 0.0
                btnTab1!.tag = 0
                btnTab1?.addTarget(self, action: #selector(selectedTabButton(_:)), for: .touchUpInside)
                
                tabsToShow.append(btnTab1!)
            }
            
            if ShowsDetailsTab {
                btnDetail = FlatButton()
                btnDetail!.pulseColor = BaseApplicationColor!
                btnDetail!.setTitle("DETAIL", for: UIControlState())
                btnDetail!.setTitleColor(FadedApplicationColor, for: UIControlState())
                btnDetail!.setTitleColor(BaseApplicationColor, for: .selected)
                btnDetail!.titleLabel?.font = UIFont.boldSystemFont(ofSize: 10)
                btnDetail!.borderWidth = 0.0
                btnDetail!.tag = 1
                btnDetail?.addTarget(self, action: #selector(selectedTabButton(_:)), for: .touchUpInside)
                
                tabsToShow.append(btnDetail!)
            }
            
            if TabHeader2.isNotEmpty {
                btnTab2 = FlatButton()
                btnTab2!.pulseColor = BaseApplicationColor!
                btnTab2!.setTitle(TabHeader2.uppercased(), for: UIControlState())
                btnTab2!.setTitleColor(FadedApplicationColor, for: UIControlState())
                btnTab2!.setTitleColor(BaseApplicationColor, for: .selected)
                btnTab2!.titleLabel?.font = UIFont.boldSystemFont(ofSize: 10)
                btnTab2!.borderWidth = 0.0
                btnTab2!.tag = 2
                btnTab2?.addTarget(self, action: #selector(selectedTabButton(_:)), for: .touchUpInside)
                
                tabsToShow.append(btnTab2!)
            }
            
            if TabHeader3.isNotEmpty {
                btnTab3 = FlatButton()
                btnTab3!.pulseColor = BaseApplicationColor!
                btnTab3!.setTitle(TabHeader3.uppercased(), for: UIControlState())
                btnTab3!.setTitleColor(FadedApplicationColor, for: UIControlState())
                btnTab3!.setTitleColor(BaseApplicationColor, for: .selected)
                btnTab3!.titleLabel?.font = UIFont.boldSystemFont(ofSize: 10)
                btnTab3!.borderWidth = 0.0
                btnTab3!.tag = 3
                btnTab3?.addTarget(self, action: #selector(selectedTabButton(_:)), for: .touchUpInside)
                
                tabsToShow.append(btnTab3!)
            }
            
            if TabHeader4.isNotEmpty {
                btnTab4 = FlatButton()
                btnTab4!.pulseColor = BaseApplicationColor!
                btnTab4!.setTitle(TabHeader4.uppercased(), for: UIControlState())
                btnTab4!.setTitleColor(FadedApplicationColor, for: UIControlState())
                btnTab4!.setTitleColor(BaseApplicationColor, for: .selected)
                btnTab4!.titleLabel?.font = UIFont.boldSystemFont(ofSize: 10)
                btnTab4!.borderWidth = 0.0
                btnTab4!.tag = 3
                btnTab4?.addTarget(self, action: #selector(selectedTabButton(_:)), for: .touchUpInside)
                
                tabsToShow.append(btnTab4!)
            }
            
            topTabbar!.buttons = tabsToShow
        }
        
        btnTab1?.isSelected = false
        btnDetail?.isSelected = false
        btnTab2?.isSelected = false
        btnTab3?.isSelected = false
        btnTab4?.isSelected = false
        
        switch selectedTab {
        case .tab1:
            btnTab1?.isSelected = true
        case .detail:
            btnDetail?.isSelected = true
        case .tab2:
            btnTab2?.isSelected = true
        case .tab3:
            btnTab3?.isSelected = true
        case .tab4:
            btnTab4?.isSelected = true
        }
    }
    
    func selectedTabButton(_ sender: FlatButton) {
        
        if sender.isSelected {
            return
        }
        
        btnTab1?.isSelected = false
        btnDetail?.isSelected = false
        btnTab2?.isSelected = false
        btnTab3?.isSelected = false
        btnTab4?.isSelected = false
        
        sender.isSelected = true
        
        if selectedTab != nil {
            let selectedTabValue: ProductDetailTab = ProductDetailTab(rawValue: sender.tag)!
            selectedTab!(selectedTabValue)
        }
    }
}
