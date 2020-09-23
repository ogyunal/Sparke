//
//  AddLike.swift
//  Social
//
//  Created by Sam Addadahine on 13/04/2020.
//  Copyright © 2020 Sam Addadahine. All rights reserved.
//

import Foundation
import Firebase

class AddLike {
    
    var ref = Database.database().reference()
    
    func addLike(_ postId: String, _ completion:@escaping (_ success: Bool)-> Void) {
  
        Constants.ref.child("posts").child(postId).child("likes").updateChildValues([Constants.userId : true],withCompletionBlock: {(error,ref) in
            
            if error != nil {
                 
                completion(false)
                
            } else {
                
                completion(true)
                
            }
        })
    }
}




