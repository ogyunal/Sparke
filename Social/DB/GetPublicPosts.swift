//
//  GetPublicPosts.swift
//  Social
//
//  Created by Sam Addadahine on 13/04/2020.
//  Copyright © 2020 Sam Addadahine. All rights reserved.
//

import Foundation
import Firebase

class GetPublicPosts {
    
    var posts = [Post]()
    var ref = Database.database().reference()
    var query = DatabaseQuery()
    
    func getPublicPosts(_ completion:@escaping ([Post] , _ success: Bool)-> Void) {
        
        self.posts.removeAll()
            
        Constants.ref.child("posts").observeSingleEvent(of: .value, with: { snapshot in
            
            if ( snapshot.value is NSNull ) {
                print("– – – Data was not found1 – – –")
                completion(self.posts, false)
                        
            } else {
                        
                for child in snapshot.children {
                    let snap = child as! DataSnapshot
                    let dict = snap.value as! [String: Any]
                    
                    let thumbnailUrl = dict["thumbnail_url"] as? String
                    let timestamp = dict["timestamp"] as? Double
                    let userId = dict["userId"] as? String
                    let likeCount = dict["likeCount"] as? Int ?? 0
                    let commentCount = dict["commentCount"] as? Int ?? 0
                    
                    self.posts.append(Post(thumbnailUrl: thumbnailUrl!, userId: userId!, timestamp: timestamp!, postId: snap.key, likeCount: likeCount, commentCount: commentCount))
                    
                    self.posts.sort { $0.timestamp > $1.timestamp }
                        
                }
                        
                    DispatchQueue.main.async {
                            
                        completion(self.posts, true)
                    }
                }
            })
        }
    }

