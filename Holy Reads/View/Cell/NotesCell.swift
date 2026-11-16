//
//  NotesCell.swift
//  Holy Reads
//
//  Created by mac-14 on 03/01/20.
//  Copyright © 2020 Ajeet singh Rawat. All rights reserved.
//

import UIKit

class NotesCell: UITableViewCell {
 //MARK:- IBOutlets
    
    @IBOutlet weak var lblCount: UILabel!
    @IBOutlet weak var lblNotes: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
    
    @IBOutlet weak var btnEditNote: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
