//
//  PlanCell.swift
//  Holy Reads
//
//  Created by mac-14 on 30/08/19.
//  Copyright © 2019 Ajeet singh Rawat. All rights reserved.
//

import UIKit

class PlanCell: UITableViewCell {

    @IBOutlet weak var lblHighlight: UILabel!
    @IBOutlet weak var imgBook: UIImageView!
    @IBOutlet weak var lblBokName: UILabel!
    @IBOutlet weak var lblAuthorName: UILabel!
    @IBOutlet weak var btnComment: UIButton!
    @IBOutlet weak var btnShare: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var BtnMark: UIButton!
    
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
