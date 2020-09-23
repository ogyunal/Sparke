//
//  Notifications.swift
//  Social
//
//  Created by Sam Addadahine on 10/12/2019.
//  Copyright © 2019 Sam Addadahine. All rights reserved.
//

import Foundation

extension Notification.Name {
    
// User Control
static let registered = Notification.Name("registered")
static let loggedOut = Notification.Name("loggedOut")
    
static let refreshHome = Notification.Name("refreshHome")

static let getPosts = Notification.Name("getPosts")
static let refreshFollowing = Notification.Name("refreshFollowing")
static let refreshComments = Notification.Name("refreshComments")
static let scrollToTop = Notification.Name("scrollToTop")
        
static let updateCommentCount = Notification.Name("updateCommentCount")
}
