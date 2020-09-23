//
//  GetUserInfo.swift
//  Social
//
//  Created by Sam Addadahine on 13/04/2020.
//  Copyright © 2020 Sam Addadahine. All rights reserved.
//

import Foundation
import Firebase

struct UserInfo {
    
    var firstName: String
    var lastName: String
    var imageUrl: String
}

class GetUserInfo {
    
    var userInfo: UserInfo!
    var ref = Database.database().reference()
    var query = DatabaseQuery()
    
    func getUserInfo(_ id: String, _ completion:@escaping (UserInfo , _ success: Bool)-> Void) {
  
        Constants.ref.child("users").child(id).observeSingleEvent(of: .value, with: {(snapshot) in
                          
            if snapshot.exists() {
                
               guard let dict = snapshot.value as? [String: Any] else {
                    completion(self.userInfo, false)
                    return
                    
                }
                    let firstName = dict["first_name"] as? String ?? ""
                    let lastName = dict["last_name"] as? String ?? ""
                    let imageUrl = dict["imageUrl"] as? String ?? ""
                
                self.userInfo = UserInfo(firstName: firstName, lastName: lastName, imageUrl: imageUrl)
                
                DispatchQueue.main.async {
                    
                    completion(self.userInfo, true)
                }
                    
            } else {
                
                completion(self.userInfo, false)
            }
        })
    }
}

