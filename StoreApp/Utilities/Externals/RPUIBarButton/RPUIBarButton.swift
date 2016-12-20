//
//  RPUIBarButton.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 28/05/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

open class RPUIBarButton: UIBarButtonItem {

    fileprivate var badgeLabel: UILabel
    open var badgeString: String? {
        didSet {
            setupBadgeViewWithString(badgeText: badgeString)
        }
    }
    
    open var badgeEdgeInsets: UIEdgeInsets? {
        didSet {
            setupBadgeViewWithString(badgeText: badgeString)
        }
    }
    
    open var badgeBackgroundColor = UIColor.red {
        didSet {
            badgeLabel.backgroundColor = badgeBackgroundColor
        }
    }
    
    open var badgeTextColor = UIColor.white {
        didSet {
            badgeLabel.textColor = badgeTextColor
        }
    }
    
    override init() {
        badgeLabel = UILabel()
        super.init()
        setupBadgeViewWithString(badgeText: "")
    }
    
    open override func awakeFromNib() {
        badgeLabel = UILabel()
        super.awakeFromNib()
        setupBadgeViewWithString(badgeText: "")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        badgeLabel = UILabel()
        super.init(coder: aDecoder)
        setupBadgeViewWithString(badgeText: "")
    }
    
    open func initWithFrame(frame: CGRect, withBadgeString badgeString: String, withBadgeInsets badgeInsets: UIEdgeInsets) -> AnyObject {
        
        badgeLabel = UILabel()
        badgeEdgeInsets = badgeInsets
        setupBadgeViewWithString(badgeText: badgeString)
        return self
    }
    
    fileprivate func setupBadgeViewWithString(badgeText: String?) {
        badgeLabel.clipsToBounds = true
        badgeLabel.text = badgeText
        badgeLabel.font = UIFont.systemFont(ofSize: 12)
        badgeLabel.textAlignment = .center
        badgeLabel.sizeToFit()
        let badgeSize = badgeLabel.frame.size
        
        let height = max(20, Double(badgeSize.height) + 5.0)
        let width = max(height, Double(badgeSize.width) + 10.0)
        
        var vertical: Double?, horizontal: Double?
        if let badgeInset = self.badgeEdgeInsets {
            vertical = Double(badgeInset.top) - Double(badgeInset.bottom)
            horizontal = Double(badgeInset.left) - Double(badgeInset.right)

            if let bounds = (self.value(forKey: "view") as? UIView)?.bounds {
                let x = (Double(bounds.size.width) - 10 + horizontal!)
                let y = -(Double(badgeSize.height) / 2) - 10 + vertical!
                badgeLabel.frame = CGRect(x: x, y: y, width: width, height: height)
            }
        } else {
            if let frame = (self.value(forKey: "view") as? UIView)?.frame {
                let x = frame.width - CGFloat((width / 2.0))
                let y = CGFloat(-(height / 2.0))
                badgeLabel.frame = CGRect(x: x, y: y, width: CGFloat(width), height: CGFloat(height))
            }
        }
        
        setupBadgeStyle()
        if let view = self.value(forKey: "view") as? UIView {
            view.addSubview(badgeLabel)
        }
        
        if let text = badgeText {
            badgeLabel.isHidden = text != "" ? false : true
        } else {
            badgeLabel.isHidden = true
        }
        
    }
    
    fileprivate func setupBadgeStyle() {
        badgeLabel.textAlignment = .center
        badgeLabel.backgroundColor = badgeBackgroundColor
        badgeLabel.textColor = badgeTextColor
        badgeLabel.layer.cornerRadius = badgeLabel.bounds.size.height / 2
    }
}
