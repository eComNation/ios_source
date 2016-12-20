//
//  SKCache.swift
//  SKPhotoBrowser
//
//  Created by Kevin Wolkober on 6/13/16.
//  Copyright © 2016 suzuki_keishi. All rights reserved.
//

import UIKit

open class SKCache {

    open static let sharedCache = SKCache()
    open var imageCache: SKCacheable

    init() {
        self.imageCache = SKDefaultImageCache()
    }

    open func imageForKey(_ key: String) -> UIImage? {
        return (self.imageCache as! SKImageCacheable).imageForKey(key)
    }

    open func setImage(_ image: UIImage, forKey key: String) {
        (self.imageCache as! SKImageCacheable).setImage(image, forKey: key)
    }

    open func removeImageForKey(_ key: String) {
        (self.imageCache as! SKImageCacheable).removeImageForKey(key)
    }

    open func imageForRequest(_ request: URLRequest) -> UIImage? {
        if let response = (self.imageCache as! SKRequestResponseCacheable).cachedResponseForRequest(request) {
            let data = response.data

            return UIImage(data: data)
        }

        return nil
    }

    open func setImageData(_ data: Data, response: URLResponse, request: URLRequest) {
        let cachedResponse = CachedURLResponse(response: response, data: data)
        (self.imageCache as! SKRequestResponseCacheable).storeCachedResponse(cachedResponse, forRequest: request)
    }
}

class SKDefaultImageCache: SKImageCacheable {
    var cache: NSCache<AnyObject, AnyObject>

    init() {
        self.cache = NSCache()
    }

    func imageForKey(_ key: String) -> UIImage? {
        return self.cache.object(forKey: key as AnyObject) as? UIImage
    }

    func setImage(_ image: UIImage, forKey key: String) {
        self.cache.setObject(image, forKey: key as AnyObject)
    }

    func removeImageForKey(_ key: String) {
        self.cache.removeObject(forKey: key as AnyObject)
    }
}
