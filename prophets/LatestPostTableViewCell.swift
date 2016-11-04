//
//  LatestPostTableViewCell.swift
//  prophets
//
//  Created by test on 2016-11-03.
//  Copyright © 2016 Shaban Fadil. All rights reserved.
//

import UIKit

class LatestPostTableViewCell: UITableViewCell {

    @IBOutlet weak var postTitle: UILabel!
    
    @IBOutlet weak var postDate: UILabel!
    
    @IBOutlet weak var postImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
