//
//  Notification_IpadCell.swift
//  Holy Reads
//
//  Created by Ashish Soni on 20/07/20.
//  Copyright © 2020 Ajeet singh Rawat. All rights reserved.
//

import UIKit

class Notification_IpadCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
     @IBOutlet weak var lblDescription: UILabel!
     @IBOutlet weak var lblTime: UILabel!
     @IBOutlet weak var imgBook: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
