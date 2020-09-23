//
//  ImageExtension.swift
//  Social
//
//  Created by Sam Addadahine on 10/12/2019.
//  Copyright © 2019 Sam Addadahine. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SDWebImage

extension UIImageView {
   
    func loadImageUsingCacheUrlString(urlString: String, scale: UIView.ContentMode, completion: @escaping (_ result: Bool)-> Void) {
        
        self.image = nil
        self.contentMode = scale
        
        //check the image cache first
        if let cachedImage = Constants.imageCache.object(forKey: urlString as AnyObject) as?
            
            UIImage {
            self.image = cachedImage
            completion(true)
            print("cached")
            return
        }
        
        self.sd_cancelCurrentImageLoad()
        
        //No cached, so fetch image
        self.sd_imageIndicator = SDWebImageActivityIndicator.gray
        self.sd_setImage(with: URL(string:urlString), placeholderImage: nil, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, type, url) in
            
            if error != nil {
                
                completion(false)
                print("error: \(error!)")
            } else {
                
                if let pic = image {

                    Constants.imageCache.setObject(pic, forKey: urlString as AnyObject)
                    completion(true)
                    
                } else {
                    

                    completion(false)
                }
            }
        })
    }
}
