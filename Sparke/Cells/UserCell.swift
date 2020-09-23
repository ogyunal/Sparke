//
//  BusinessCardCell.swift
//  Social
//
//  Created by Sam Addadahine on 13/04/2020.
//  Copyright © 2020 Sam Addadahine. All rights reserved.
//

import Foundation
import UIKit

class UserCell: UITableViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var userImage: UIImageView!
    
    init(style: UITableViewCell.CellStyle, reuseIdentifier: String) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
        
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
        
    override func prepareForReuse() {
        super.prepareForReuse()
    }
        
    override func awakeFromNib() {
        super.awakeFromNib()
            
        self.selectionStyle = UITableViewCell.SelectionStyle.none
            
        }
    }
