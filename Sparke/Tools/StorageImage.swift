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
   
func getStorageImage(imageUrl: String, _ completion:@escaping (UIImage , _ success: Bool)-> Void) {
    
    if imageUrl == "" {
        print("1")
        completion(UIImage(named: "Logo")!,false)
        return
    }
            
    let storageRef = Storage.storage().reference(forURL: imageUrl)
    storageRef.getData(maxSize: 1 * 2000 * 2000) { (data, error) -> Void in
                              
        guard let data = data, error == nil else {
            print("2")
            completion(UIImage(named: "Logo")!,false)
            return
        }
                              
        let pic = UIImage(data: data)
                              
            DispatchQueue.main.async {
                                  
                if let pic = pic {
                    print("3")
                    completion(pic,true)
                                          
                } else {
                    print(4)
                    completion(UIImage(named: "Logo")!,false)
                }
                                      
            }
        }
    }
