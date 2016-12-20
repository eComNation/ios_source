//
//  UIImageViewExtension.swift
//  Hiva
//
//  Created by Rakesh Pethani on 6/27/16.
//  Copyright © 2016 eComNation. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage

extension UIImageView {
    
    func setImageWithURL(_ url: URL, completion: @escaping (_ success:Bool , _ isCancelled: Bool, _ image: UIImage?) -> Void) {
        
        self.image = nil
        self.af_setImage(withURL: url, placeholderImage: nil, filter: nil, progress: nil, imageTransition: .noTransition, runImageTransitionIfCached: false, completion: { (response) in

            if response.result.isSuccess {
                completion(true, false, response.result.value)
            } else if response.result.isFailure && response.result.error?._code == NSURLErrorCancelled {
                completion(false, true, nil)
                return
            } else if response.result.isFailure && response.result.error?._code != NSURLErrorCancelled {
                self.image = UIImage(named: "NoImage")
                completion(false, false, nil)
                return
            }
            
            completion(false, false, nil)
            return
        })
    }
}
