//
//  PostCell.swift
//  Social
//
//  Created by Sam Addadahine on 13/04/2020.
//  Copyright © 2020 Sam Addadahine. All rights reserved.
//

import Foundation
import UIKit

class PostCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var likeCount: UILabel!
    @IBOutlet var commentCount: UILabel!
    
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

