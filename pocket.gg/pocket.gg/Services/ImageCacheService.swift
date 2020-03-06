//
//  ImageCacheService.swift
//  pocket.gg
//
//  Created by Gabriel Siu on 2020-02-15.
//  Copyright © 2020 Gabriel Siu. All rights reserved.
//

import UIKit

final class ImageCacheService {
    
    static let cache = NSCache<NSString, UIImage>()
    
    static func getCachedImage(with key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    
    static func saveImageToCache(image: UIImage, with key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}
