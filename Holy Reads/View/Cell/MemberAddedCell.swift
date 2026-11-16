//
//  MemberAddedCell.swift
//  Holy Reads
//
//  Created by mac-14 on 10/01/20.
//  Copyright © 2020 Ajeet singh Rawat. All rights reserved.
//

import UIKit

class MemberAddedCell: UITableViewCell {

    @IBOutlet weak var lblEmail: UILabel!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var imgVerified: UIImageView!
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
