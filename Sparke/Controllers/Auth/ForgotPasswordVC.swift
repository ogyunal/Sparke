//
//  ForgotPasswordVC.swift
//  Social
//
//  Created by Sam Addadahine on 13/04/2020.
//  Copyright © 2020 Sam Addadahine. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class ForgotPasswordVC: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {

    //TextField Outlets
    @IBOutlet var emailTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        emailTF.addBottomBorder()
        
    }
    
    @IBAction func backAction() {
        
        self.navigationController?.popViewController(animated: true)
        
    }

    @IBAction func goAction() {
        
        recover()
        
    }

    func recover() {
    
        self.view.activityStartAnimating()
        if ( emailTF.text?.isValidEmail())! {
                 
            Auth.auth().sendPasswordReset(withEmail:  emailTF.text!) { (error) in
                     
                if let error = error {
                    self.view.activityStopAnimating()
                    self.showCustomAlert(title: "Login Error", message: error.localizedDescription)
                    return
                }
                
                else {
                    self.view.activityStopAnimating()
                    let alert = UIAlertController(title: "", message: "We have sent you an email with instructions to recover your password", preferredStyle: UIAlertController.Style.alert)
                        
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
                             
                        self.dismiss(animated: true, completion: nil)
                             
                    }))
                         
                        self.present(alert, animated: true, completion: nil)
                         
                    }
                 }
             }
             else {
                 self.view.activityStopAnimating()
                 self.showCustomAlert(title: "Oops", message: "Please enter a valid email address")
                 
             }
         }
    }

