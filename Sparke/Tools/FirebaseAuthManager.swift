//
//  FirebaseAuthManager.swift
//  Social
//
//  Created by Sam Addadahine on 07/02/2020.
//  Copyright © 2020 Sam Addadahine. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class FirebaseAuthManager {

    func createUser(email: String, password: String, completionBlock: @escaping (_ error: String, _ user: String,_ success: Bool) -> Void) {
           Auth.auth().createUser(withEmail: email, password: password) {(authResult, error) in
               if let user = authResult?.user {
                    completionBlock("No Error",user.uid,true)
               } else {
                    completionBlock(error!.localizedDescription,"No User",false)
               }
           }
       }
    
    func signIn(email: String, pass: String, completionBlock: @escaping (_ error: String,_ success: Bool) -> Void) {
           Auth.auth().signIn(withEmail: email, password: pass) { (user, error) in
               if let error = error, let _ = AuthErrorCode(rawValue: error._code) {
                completionBlock(error.localizedDescription,false)
               } else {
                    completionBlock("No Error",true)
               }
           }
       }

}
