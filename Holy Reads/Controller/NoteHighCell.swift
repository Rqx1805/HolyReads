//
//  NoteHighCell.swift
//  Holy Reads
//
//  Created by Ashish Soni on 28/05/20.
//  Copyright © 2020 Ajeet singh Rawat. All rights reserved.
//

import UIKit

class NoteHighCell: UITableViewCell {
    
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
        self.selectionStyle = .none
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
