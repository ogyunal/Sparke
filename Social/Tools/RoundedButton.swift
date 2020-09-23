//
//  RoundedButton.swift
//  Social
//
//  Created by Sam Addadahine on 10/04/2020.
//  Copyright © 2020 Sam Addadahine. All rights reserved.
//

import Foundation
import UIKit

class RoundedButton: UIButton {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.layer.cornerRadius = 15
        self.layer.backgroundColor = #colorLiteral(red: 0.1650000066, green: 0.1609999985, blue: 0.4160000086, alpha: 1)
        self.setTitleColor(.white, for: .normal)
        
    }
}
