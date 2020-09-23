//
//  GetFollowingPosts.swift
//  Social
//
//  Created by Sam Addadahine on 13/04/2020.
//  Copyright © 2020 Sam Addadahine. All rights reserved.
//

import Foundation
import Firebase

class GetFollowingPosts {
    
    var posts = [Post]()
    var ref = Database.database().reference()
    var query = DatabaseQuery()
    var following = [String]()
    
    func getFollowingPosts(_ completion:@escaping ([Post] , _ success: Bool)-> Void) {
        
        //Clear out arrays
        self.following.removeAll()
        self.posts.removeAll()
            
        //Get users I am following
        Constants.ref.child("users").child(Constants.userId).child("following").observeSingleEvent(of: .value, with: { userSnapshot in
        
         if ( userSnapshot.value is NSNull ) {
            print("– – – Not following any users – – –")
            completion(self.posts, false)
            
         } else {
            
            for child in userSnapshot.children {
                
                let snap = child as! DataSnapshot
                let userKey = snap.key

                
                //Find posts linked to this user ID
                Constants.ref.child("posts").queryOrdered(byChild: "userId").queryEqual(toValue: userKey).observeSingleEvent(of: .value, with: { postSnapshot in
                    
                    if ( postSnapshot.value is NSNull ) {
                        print("– – – This user doesn't have any posts – – –")
                        completion(self.posts, false)
                    } else {
                        
                        for child in postSnapshot.children {
                            
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
                                
                           // if self.posts.count ==  postSnapshot.childrenCount {
                                
                                completion(self.posts, true)
                                
                           // }
                        }
                    }
                })
            }
        }
    })
}
}

