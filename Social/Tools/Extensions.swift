//
//  Extensions.swift
//  Social
//
//  Created by Sam Addadahine on 10/12/2019.
//  Copyright © 2019 Sam Addadahine. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {
   open override var preferredStatusBarStyle: UIStatusBarStyle {
      return topViewController?.preferredStatusBarStyle ?? .default
   }
}

extension UINavigationController: UIGestureRecognizerDelegate {

    func navSetup() {
        
        self.navigationBar.layer.shadowColor = #colorLiteral(red: 0.7691351771, green: 0.7645645738, blue: 0.7726495862, alpha: 1)
        self.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.navigationBar.layer.shadowRadius = 2.0
        self.navigationBar.layer.shadowOpacity = 3.0
        self.navigationBar.layer.masksToBounds = false
        self.navigationBar.tintColor = UIColor.black
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

extension UICollectionView {
    func scrollToNextItem() {
        let contentOffset = CGFloat(floor(self.contentOffset.x + self.bounds.size.width))
        self.moveToFrame(contentOffset: contentOffset)
    }

    func scrollToPreviousItem() {
        let contentOffset = CGFloat(floor(self.contentOffset.x - self.bounds.size.width))
        self.moveToFrame(contentOffset: contentOffset)
    }

    func moveToFrame(contentOffset : CGFloat) {
        self.setContentOffset(CGPoint(x: contentOffset, y: self.contentOffset.y), animated: true)
    }
}

extension String {
    
    func isValidEmail() -> Bool {
        // here, `try!` will always succeed because the pattern is valid
        let regex = try! NSRegularExpression(pattern: "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
    
}


extension UIView {
   func roundCornersTop(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
}

extension Float {
    var clean: String {
       return self.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self) : String(self)
    }
}

extension UITextField {
    func addBottomBorder(){
        let bottomLine = CALayer()
        bottomLine.frame = CGRect(x: 0, y: self.frame.size.height - 1, width: self.frame.size.width, height: 1)
        bottomLine.backgroundColor = #colorLiteral(red: 0.6078431373, green: 0.6078431373, blue: 0.6078431373, alpha: 1)
        borderStyle = .none
        layer.addSublayer(bottomLine)
    }
}

extension UIView {
    
    func activityStartAnimating() {
           let backgroundView = UIView()
           backgroundView.frame = CGRect.init(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
           backgroundView.backgroundColor = .clear
           backgroundView.tag = 475647

           var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
           activityIndicator = UIActivityIndicatorView(frame: CGRect.init(x: 0, y: 0, width: 50, height: 50))
           activityIndicator.center = self.center
           activityIndicator.hidesWhenStopped = true
           activityIndicator.style = UIActivityIndicatorView.Style.large
            activityIndicator.color = .black
           activityIndicator.startAnimating()
           self.isUserInteractionEnabled = false

           backgroundView.addSubview(activityIndicator)

           self.addSubview(backgroundView)
       }
       
       func activityStopAnimating() {
           if let background = viewWithTag(475647){
               background.removeFromSuperview()
           }
           self.isUserInteractionEnabled = true
       }
    
    func dropShadow() {
        
        layer.masksToBounds = false
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.shadowRadius = 2
    }
    
    func circleView() {
        
        self.layer.cornerRadius = self.frame.size.width/2
        self.clipsToBounds = true
    }
}

extension Dictionary where Key == String, Value == String {

    mutating func append(anotherDict:[String:String]) {
        for (key, value) in anotherDict {
            self.updateValue(value, forKey: key)
        }
    }
}

extension UIViewController {
    
    func oneActionSheet(_ sheetTitle: String, _ completion:@escaping (_ result: Bool)-> Void) {
        
        let alert:UIAlertController=UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let firstAction = UIAlertAction(title: sheetTitle, style: UIAlertAction.Style.default) {
            UIAlertAction in
             
            completion(true)
            alert.dismiss(animated: true, completion: nil)
                         
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
        UIAlertAction in
            
            completion(false)
                         
        }
        
        alert.addAction(firstAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func photoActionSheet(_ completion:@escaping (_ mediaType: String)-> Void) {
           
        let alert:UIAlertController=UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default) {
            UIAlertAction in
             
            completion("camera")
                         
        }
                     
        let gallaryAction = UIAlertAction(title: "Gallery", style: UIAlertAction.Style.default) {
        UIAlertAction in
              
            completion("gallery")
                                
        }
                     
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
        UIAlertAction in
                         
        }
                            
        alert.addAction(cameraAction)
        alert.addAction(gallaryAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func showErrorAlert()  {
        
        let alert = UIAlertController(title: "Error", message: "There has been an error, please try again", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showCustomAlert(title: String, message: String)  {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showVC(vcString: String, storyboard: String, style: UIModalPresentationStyle) {
        
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: vcString)
        vc.modalPresentationStyle = style
        self.present(vc, animated: true, completion: nil)
    }
    
    func pushVC(vcString: String, storyboard: String) {
        
        let storyboard = UIStoryboard(name: storyboard, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: vcString)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func pushRootVC(vcString: String, storyboard: String, style: UIModalPresentationStyle) {
        
        let sb = UIStoryboard(name: storyboard, bundle: nil)
        let navController = UINavigationController.init(rootViewController: sb.instantiateViewController(withIdentifier: vcString))
        navController.modalPresentationStyle = .fullScreen
        self.present(navController, animated: false, completion: {})
    }
    
}

extension UITextField {
    func validatedText(validationType: ValidatorType) throws -> String {
        let validator = VaildatorFactory.validatorFor(type: validationType)
        return try validator.validated(self.text!)
    }
}

extension UIImageView {
    func roundedImage() {
        self.layer.cornerRadius = (self.frame.width / 2)
        self.layer.masksToBounds = true
    }
}

extension Double {
    
    func dateFormat() -> String {
        
        let date = Date(timeIntervalSince1970: self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd yyyy | HH:mm"
        
        return dateFormatter.string(from:date)
        
    }
}
