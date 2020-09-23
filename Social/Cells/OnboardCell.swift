//
//  OnboardCell.swift
//  Social
//
//  Created by Sam Addadahine on 13/04/2020.
//  Copyright © 2020 Sam Addadahine. All rights reserved.
//

import Foundation
import UIKit

class OnboardCell: UICollectionViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var imageView: UIImageView!
    
    override func prepareForReuse() {
         super.prepareForReuse()

    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
}
