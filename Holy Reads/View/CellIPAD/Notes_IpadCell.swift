//
//  Notes_IpadCell.swift
//  Holy Reads
//
//  Created by Ashish Soni on 20/07/20.
//  Copyright © 2020 Ajeet singh Rawat. All rights reserved.
//

import UIKit

class Notes_IpadCell: UITableViewCell {
    
    
       @IBOutlet weak var lblCount: UILabel!
       @IBOutlet weak var lblNotes: UILabel!
       @IBOutlet weak var btnDelete: UIButton!
       
       @IBOutlet weak var btnEditNote: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
