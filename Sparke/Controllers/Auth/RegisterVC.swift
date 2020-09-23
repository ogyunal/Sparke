//
//  RegisterVC.swift
//  Social
//
//  Created by Sam Addadahine on 13/04/2020.
//  Copyright © 2020 Sam Addadahine. All rights reserved.
//

import UIKit
import FirebaseAuth

struct RegisterData {
    var fName: String
    var lName: String
    var email: String
    var password: String
    var confirmPassword: String
}

class RegisterVC: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIScrollViewDelegate {

    @IBOutlet var stackView: UIStackView!
    
    //Terms Outlets
    @IBOutlet var termsView: UIView!
    @IBOutlet var termsButton: UIButton!
    @IBOutlet var scrollView: UIScrollView!
    
    //TextField Outlets
    @IBOutlet var fNameTF: UITextField!
    @IBOutlet var lNameTF: UITextField!
    @IBOutlet var emailTF: UITextField!
    @IBOutlet var passwordTF: UITextField!
    @IBOutlet var confirmPasswordTF: UITextField!
    
    //Variables
    var termsSelected = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        self.scrollView.contentSize = CGSize(width: self.scrollView.frame.size.width,  height: self.stackView.frame.size.height * 2)

    }
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
        termsView.layer.borderColor = UIColor.black.cgColor
        termsView.layer.borderWidth = 1
        termsView.circleView()
        termsButton.circleView()
       
        passwordTF.isSecureTextEntry = true
        confirmPasswordTF.isSecureTextEntry = true
        
        [fNameTF, lNameTF, emailTF, passwordTF, confirmPasswordTF].forEach {
            $0?.addBottomBorder()
        }
    }

    //MARK: - @IBActions
    
    @IBAction func backAction() {
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func goAction() {
        
        validate()
    }
    
    func validate() {
        do {
            let fName = try fNameTF.validatedText(validationType: ValidatorType.name)
            let lName = try lNameTF.validatedText(validationType: ValidatorType.name)
            let email = try self.emailTF.validatedText(validationType: ValidatorType.email)
            let password = try self.passwordTF.validatedText(validationType: ValidatorType.password)
            let confirmPassword = try self.confirmPasswordTF.validatedText(validationType: ValidatorType.password)
            let data = RegisterData(fName: fName, lName: lName, email: email, password: password, confirmPassword: confirmPassword)
            registerAction(data: data)
        } catch(let error) {
            self.showCustomAlert(title: "Error", message: (error as! ValidationError).message)
        }
    }
    
    func registerAction(data: RegisterData) {
        
        guard data.password == data.confirmPassword else {
            self.showCustomAlert(title: "Error", message: "You passwords do not match")
            return
        }
        
        guard termsSelected else {
            self.showCustomAlert(title: "Error", message: "Please accept our Terms and Conditions")
            return
        }
        
        self.view.activityStartAnimating()
        
        FirebaseAuthManager().createUser(email: data.email, password: data.password, completionBlock: { (error,user,success) in
            
            if success {
                
                let data: [String: Any] = [
                    "first_name" : data.fName,
                    "last_name" : data.lName,
                    "email" : data.email
                ]
                
                Constants.ref.child("users").child(user).updateChildValues(data, withCompletionBlock: {(error, ref) in
                    
                    if error != nil {
                        
                        self.view.activityStopAnimating()
                        self.showCustomAlert(title: "Error", message: "There has been an error, please try again. Error: \(error!)")
                        
                    } else {
                        
                        self.view.activityStopAnimating()
                        
                        if let userId = Auth.auth().currentUser {
                            
                            Constants.userId = userId.uid
                            self.showVC(vcString: "home", storyboard: "Main", style: .fullScreen)
                            
                        } else {
                            
                            self.navigationController?.popViewController(animated: true)
                            NotificationCenter.default.post(name: .registered, object: nil)
                        }
                    }
                })
                
            } else {
                
                self.showCustomAlert(title: "Error", message: "There has been an error, please try again. Error: \(error)")
                
            }
        })
    }
    
    @IBAction func termsAction() {
        
        if termsSelected {
            
            termsButton.backgroundColor = .white
            termsSelected = false
            
        } else {
            
            termsButton.backgroundColor = #colorLiteral(red: 0.1647058824, green: 0.1607843137, blue: 0.4156862745, alpha: 1)
            termsSelected = true
        }
        
    }

}

