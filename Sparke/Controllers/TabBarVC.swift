//
//  TabBarVC.swift
//  Social
//
//  Created by Sam Addadahine on 13/04/2020.
//  Copyright © 2020 Sam Addadahine. All rights reserved.
//

import UIKit

class TabBarVC: UITabBarController {
    
    var tabImages = [UIImage(named: "home.png"), UIImage(named: "profile.png")]
    var tabSelectedImages = [UIImage(named: "home.png"), UIImage(named: "profile.png")]
    var tapCount = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        setUpImagaOntabbar(tabSelectedImages as! [UIImage], tabImages as! [UIImage])
        tabBar.barTintColor = .white
        tabBar.isTranslucent = false
        
    }
    
    func setUpImagaOntabbar(_ selectedImage : [UIImage], _ image : [UIImage]){
           
           for (index,_) in image.enumerated(){
               
               if let tab = self.tabBar.items?[index]{
                   
                   tab.image = selectedImage[index]
                   tab.image = image[index]
                   
            }
        }
    }
}

