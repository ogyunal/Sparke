//
//  Post.swift
//  Social
//
//  Created by Sam Addadahine on 27/12/2019.
//  Copyright © 2019 Sam Addadahine. All rights reserved.
//

import Foundation

class Post {
    
    var thumbnailUrl: String
    var userId: String
    var timestamp: Double
    var postId: String
    var likeCount: Int
    var commentCount: Int
    
    init(thumbnailUrl: String, userId: String, timestamp: Double, postId: String, likeCount: Int, commentCount: Int) {

        self.thumbnailUrl = thumbnailUrl
        self.userId = userId
        self.timestamp = timestamp
        self.postId = postId
        self.likeCount = likeCount
        self.commentCount = commentCount
        
    }
}
