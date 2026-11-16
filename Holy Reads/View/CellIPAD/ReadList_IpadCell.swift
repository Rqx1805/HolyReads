//
//  ReadList_IpadCell.swift
//  Holy Reads
//
//  Created by Ashish Soni on 20/07/20.
//  Copyright © 2020 Ajeet singh Rawat. All rights reserved.
//

import UIKit

class ReadList_IpadCell: UITableViewCell {
    
    @IBOutlet weak var imgMusic: UIButton!
       @IBOutlet weak var lblAudioName: UILabel!
       @IBOutlet weak var lblAudioCount: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
