//
//  LogManager.swift
//  GreenOBazaar
//
//  Created by Rakesh Pethani on 07/07/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import UIKit

public let logManager = LogManager.sharedManager

open class LogManager: NSObject {

    // MARK: Properties
    /// Singleton instance of `PersistencyManager`
    open static let sharedManager = LogManager()
    
    func logScreenWithName(_ name: String) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: name)
        let eventTracker: NSObject = GAIDictionaryBuilder.createScreenView().build()
        tracker?.send(eventTracker as! [NSObject : AnyObject])
    }
}
