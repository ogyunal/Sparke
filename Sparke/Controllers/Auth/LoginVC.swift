//
//  LoginVC.swift
//  Social
//
//  Created by Sam Addadahine on 13/04/2020.
//  Copyright © 2020 Sam Addadahine. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class LoginVC: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {

    //TextField Outlets
    @IBOutlet var emailTF: UITextField!
    @IBOutlet var passwordTF: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
       
        passwordTF.isSecureTextEntry = true
        
        [emailTF, passwordTF].forEach {
            $0?.addBottomBorder()
        }
    }
    
    @IBAction func backAction() {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func goAction() {
        
        login()
    }
    
    @IBAction func forgotPasswordAction() {
        
        self.pushVC(vcString: "forgotPassword", storyboard: "Auth")
    }

    func login() {
      
        self.view.activityStartAnimating()
        
        FirebaseAuthManager().signIn(email: emailTF.text!, pass: passwordTF.text!, completionBlock: { (error,success) in
            
            if success {
                
                if let userId = Auth.auth().currentUser {
                    
                    Constants.userId = userId.uid
                    self.view.activityStopAnimating()
                    self.showVC(vcString: "tabBar", storyboard: "Main", style: .fullScreen)
                    
                } else {
                    
                    self.view.activityStopAnimating()
                    self.showCustomAlert(title: "Error", message: "There has been an error, please try again. Error: \(error)")
                    
                }
   
            } else {
                    
                self.view.activityStopAnimating()
                self.showCustomAlert(title: "Error", message: "There has been an error, please try again. Error: \(error)")
                
            }
        })
    }
}

