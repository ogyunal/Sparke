//
//  GetUsers.swift
//  Social
//
//  Created by Sam Addadahine on 13/04/2020.
//  Copyright © 2020 Sam Addadahine. All rights reserved.
//

import Foundation
import Firebase

class GetUsers {
    
    var users = [User]()
    var ref = Database.database().reference()
    
    func getUsers(_ type: String, _ completion:@escaping ([User] , _ success: Bool)-> Void) {
        
        users.removeAll()
               
        Constants.ref.child("users").child(Constants.userId).child(type).observeSingleEvent(of: .value, with: { snapshot in
                   
            if ( snapshot.value is NSNull ) {
                print("– – – Data was not found – – –")
                completion(self.users, false)
                               
            } else {
                               
                for child in snapshot.children {
                                                    
                    let snap = child as? DataSnapshot
                    let userKey = snap?.key
                                                     
                    Constants.ref.child("users").child(userKey!).observeSingleEvent(of: .value, with: {(snapshot) in
                                                   
                        guard let dict = snapshot.value as? [String: Any] else {
                            completion(self.users, false)
                            return
                            
                        }
                        
                        let fName = dict["first_name"] as? String
                        let lName = dict["last_name"] as? String
                        let imageUrl = dict["imageUrl"] as? String ?? ""
                        
                        self.users.append(User(first_name: fName!, last_name: lName!, imageUrl: imageUrl, id: userKey!))
                                                        
                        DispatchQueue.main.async {
                                                   
                            completion(self.users, true)
                        }
                                                         
                    })
                }
            }
        })
    }
    
}

