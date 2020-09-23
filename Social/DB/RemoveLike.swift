//
//  RemoveLike.swift
//  Social
//
//  Created by Sam Addadahine on 13/04/2020.
//  Copyright © 2020 Sam Addadahine. All rights reserved.
//

import Foundation
import Firebase

class RemoveLike {
    
    var ref = Database.database().reference()
    
    func removeLike(_ postId: String, _ completion:@escaping (_ success: Bool)-> Void) {
  
        Constants.ref.child("posts").child(postId).child("likes").child(Constants.userId).removeValue(completionBlock: {(error,ref) in
            
            if error != nil {
                 
                completion(false)
                
            } else {
                
                completion(true)
                
            }
        })
    }
}




