//
//  GetComments.swift
//  Social
//
//  Created by Sam Addadahine on 13/04/2020.
//  Copyright © 2020 Sam Addadahine. All rights reserved.
//

import Foundation
import Firebase

class GetComments {
    
    var comments = [Comment]()
    var ref = Database.database().reference()
    var query = DatabaseQuery()
    
    func getComments(_ postId: String, _ completion:@escaping ([Comment] , _ success: Bool)-> Void) {
            
        //Clear out arrays
        self.comments.removeAll()
                
        //Get comment ids
        Constants.ref.child("posts").child(postId).child("comments").observeSingleEvent(of: .value, with: { postSnapshot in
            
             if ( postSnapshot.value is NSNull ) {
                print("– – – No comments – – –")
                completion(self.comments, false)
                
             } else {
                
                for child in postSnapshot.children {
                    
                    let snap = child as! DataSnapshot
                    let commentKey = snap.key
                    
                    //Find comments linked to this post ID
                    Constants.ref.child("comments").child(commentKey).observeSingleEvent(of: .value, with: { commentSnapshot in
                        
                        if ( commentSnapshot.value is NSNull ) {
                            print("– – – No comments found – – –")
                            completion(self.comments, false)
                            
                        } else {

                            let dict = commentSnapshot.value as! [String: Any]
                            
                            let content = dict["content"] as? String
                            let timestamp = dict["timestamp"] as? Double
                            let userId = dict["userId"] as? String
                            let postId = dict["postId"] as? String
                            
                            self.comments.append(Comment(commentId: commentKey, userId: userId!, content: content!, timestamp: timestamp!,postId: postId!))
                                
                            self.comments.sort { $0.timestamp > $1.timestamp }
                            
                            DispatchQueue.main.async {
                                
                                if self.comments.count == postSnapshot.childrenCount {
                                    
                                    completion(self.comments, true)
                                    
                                }
                            }
                        }
                    })
                }
            }
        })
    }
    }

