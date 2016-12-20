//
//  DictionaryExtension.swift
//  Greenfibre
//
//  Created by Rakesh Pethani on 23/04/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import Foundation

extension Dictionary where Key: ExpressibleByStringLiteral, Value:AnyObject {
    
    var jsonString:String {
        
        if let dict = (self as AnyObject) as? Dictionary<String, AnyObject> {
            do {
                let data = try JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions(rawValue: UInt.allZeros))
                if let string = String(data: data, encoding: String.Encoding.utf8) {
                    return string
                }
            } catch {
                print(error)
            }
        }
        return ""
    }
}

public extension Sequence {
    
    /// Categorises elements of self into a dictionary, with the keys given by keyFunc
    
    func categorise<U : Hashable>(_ keyFunc: (Iterator.Element) -> U) -> [U:[Iterator.Element]] {
        var dict: [U:[Iterator.Element]] = [:]
        for el in self {
            let key = keyFunc(el)
            if case nil = dict[key]?.append(el) { dict[key] = [el] }
        }
        return dict
    }
}
