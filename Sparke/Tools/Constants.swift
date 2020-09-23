//
//  Constants.swift
//  Social
//
//  Created by Sam Addadahine on 03/01/2020.
//  Copyright © 2020 Sam Addadahine. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class Constants {
    
// User Details
    static var fName = ""
    static var lName = ""
    static var userId = ""
    static var title = ""
    static var myImage = UIImage(named: "Logo")
    static var imageUrl = ""

// Colors
    static var greenColor = UIColor(red: 89.0/255, green: 169.0/255, blue: 112.0/255, alpha: 1.0)
    
//Database
    static var ref = Database.database().reference()
    
    static var imageCache = NSCache<AnyObject, AnyObject>()
}
