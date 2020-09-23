//
//  User.swift
//  Social
//
//  Created by Sam Addadahine on 27/12/2019.
//  Copyright © 2019 Sam Addadahine. All rights reserved.
//

import Foundation

class User {
    
    var first_name: String?
    var last_name: String?
    var imageUrl: String?
    var id: String?
    
    init(first_name: String, last_name: String, imageUrl: String, id: String) {

        self.first_name = first_name
        self.last_name = last_name
        self.imageUrl = imageUrl
        self.id = id
    }
}
