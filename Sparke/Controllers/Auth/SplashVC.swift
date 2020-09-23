//
//  SplashVC.swift
//  Social
//
//  Created by Sam Addadahine on 13/04/2020.
//  Copyright © 2020 Sam Addadahine. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class SplashVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if Auth.auth().currentUser != nil {
            
            doesUserExist(userId: Auth.auth().currentUser!.uid)
            
        } else {
            
            self.showLoginPage()
        }
        
    }
    
    func doesUserExist(userId: String) {
        
        Constants.ref.child("users").child(userId).observeSingleEvent(of: .value, with: {(snapshot) in
                   
            if snapshot.exists() {
                //user exists
                    
                Constants.userId = userId
                self.pushRootVC(vcString: "tabBar", storyboard: "Main", style: .fullScreen)
                        
            } else {
                //user doesn't exist
                self.showLoginPage()
                 
            }
        })
    }
    
    func showLoginPage() {
        
        try! Auth.auth().signOut()
        
        self.pushRootVC(vcString: "onboard", storyboard: "Main", style: .fullScreen)
        
    }
}

