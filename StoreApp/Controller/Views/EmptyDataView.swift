//
//  EmptyDataView.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 22/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

class EmptyDataView: UIView {

    @IBOutlet var emptyDataViewContainer: UIView!
    @IBOutlet var imgEmptyData: UIImageView!
    @IBOutlet var lblMessage: UILabel!
    @IBOutlet var btnAction: UIButton!
    
    @IBOutlet var indicatorView: NVActivityIndicatorView!

    var onActionButtonTap: (() -> (Void))?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Set order status label corner radius
        btnAction.layer.cornerRadius = 2.0
        btnAction.layer.masksToBounds = true
        btnAction.layer.borderWidth = 1.0
        btnAction.layer.borderColor = UIColor(hexString: "B3B3B3")?.cgColor
        
        self.backgroundColor = UIColor.white
        
        // Show indicator view initially
        showIndicatorView()
    }
    
    // MARK: Manipulation methods
    func showEmptyDataViewWithMessage(_ message:String, buttonTitle: String?) {
        
        lblMessage.text = message
        indicatorView.stopAnimation()
        
        if buttonTitle != nil {
            btnAction.isHidden = false
            btnAction.setTitle(buttonTitle, for: UIControlState())
        } else {
            btnAction.isHidden = true
        }
        
        UIView.animate(withDuration: 0.3, animations: { 
            self.emptyDataViewContainer.alpha = 1.0
            self.indicatorView.alpha = 0.0
        }) 
    }
    
    func showIndicatorView() {
        
        indicatorView.color = GeneralButtonColor!
        indicatorView.startAnimation()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.emptyDataViewContainer.alpha = 0.0
            self.indicatorView.alpha = 1.0
        }) 
    }
    
    
    // MARK: Actions
    @IBAction func actionButtonTapped(_ sender: UIButton) {
        
        if onActionButtonTap != nil {
            onActionButtonTap!()
        }
    }
}
