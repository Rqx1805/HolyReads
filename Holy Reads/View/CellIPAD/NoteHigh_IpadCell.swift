//
//  NoteHigh_IpadCell.swift
//  Holy Reads
//
//  Created by Ashish Soni on 20/07/20.
//  Copyright © 2020 Ajeet singh Rawat. All rights reserved.
//

import UIKit

class NoteHigh_IpadCell: UITableViewCell {
    
    @IBOutlet weak var lblHighlight: UILabel!
       @IBOutlet weak var imgBook: UIImageView!
       @IBOutlet weak var lblBokName: UILabel!
       @IBOutlet weak var lblAuthorName: UILabel!
       @IBOutlet weak var btnComment: UIButton!
       @IBOutlet weak var btnShare: UIButton!
       @IBOutlet weak var btnDelete: UIButton!
       @IBOutlet weak var BtnMark: UIButton!
    @IBOutlet weak var chapterNameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
