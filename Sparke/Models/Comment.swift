//
//  Comment.swift
//  Social
//
//  Created by Sam Addadahine on 27/12/2019.
//  Copyright © 2019 Sam Addadahine. All rights reserved.
//

import Foundation

class Comment {
    
    var commentId: String
    var userId: String
    var content: String
    var timestamp: Double
    var postId: String
    
    init(commentId: String, userId: String, content: String, timestamp: Double, postId: String) {

        self.commentId = commentId
        self.userId = userId
        self.content = content
        self.timestamp = timestamp
        self.postId = postId
    }
}
