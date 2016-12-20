//
//  DoubleExtension.swift
//  Timberfruit
//
//  Created by Rakesh Pethani on 03/08/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import Foundation
import UIKit

extension Double {
    
    var formattedWithCurrency: String {

        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.roundingMode = .halfUp
        numberFormatter.locale = Locale(identifier: "en_IN")
        numberFormatter.maximumFractionDigits = 1
        return numberFormatter.string(from: NSNumber(value: self))!
    }
}
