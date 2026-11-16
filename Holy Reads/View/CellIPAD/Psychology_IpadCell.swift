//
//  Psychology_IpadCell.swift
//  Holy Reads
//
//  Created by Ashish Soni on 20/07/20.
//  Copyright © 2020 Ajeet singh Rawat. All rights reserved.
//

import UIKit

class Psychology_IpadCell: UITableViewCell {
    
    @IBOutlet weak var imgBook: UIImageView!
    
    @IBOutlet weak var lblBookTitle: UILabel!
    
    @IBOutlet weak var lblAuthorNAme: UILabel!
    
    @IBOutlet weak var lblDescription: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
