//
//  ImageStore.swift
//  Photorama
//
//  Created by Pierce Gallego on 11/24/23.
//

import Foundation
import UIKit

struct ImageStore {
    let cache = NSCache<NSString,UIImage>()
    
    //adding image to cache
    func setImage(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
    //retrieve image from cache
    func image(forKey key: String) -> UIImage? {
        return cache.object(forKey: key as NSString)
    }
    //delete image from cache
    func deleteImage(forKey key: String) {
        cache.removeObject(forKey: key as NSString)
    }
}
