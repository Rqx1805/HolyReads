//
//  Download_IpadCell.swift
//  Holy Reads
//
//  Created by Ashish Soni on 20/07/20.
//  Copyright © 2020 Ajeet singh Rawat. All rights reserved.
//

import UIKit

class Download_IpadCell: UITableViewCell {

    @IBOutlet weak var lblBookName: UILabel!
    @IBOutlet weak var lblBookAuthor: UILabel!
    @IBOutlet weak var imgBook: UIImageView!
    @IBOutlet weak var btnCheck: UIButton!
    @IBOutlet weak var btnRead: UIButton!
    @IBOutlet weak var btnAudio: UIButton!
    @IBOutlet weak var btnVideo: UIButton!
    @IBOutlet weak var descriptionLbl: UILabel!
    @IBOutlet weak var readCheck: UIButton!
    @IBOutlet weak var videoCheck: UIButton!
    @IBOutlet weak var audioChcek: UIButton!
    @IBOutlet weak var deleteBtnNew: UIButton!
    @IBOutlet weak var bookchcekview: UIView!
    @IBOutlet weak var bookopenview: UIView!
    @IBOutlet weak var videocheckview: UIView!
    @IBOutlet weak var viewopenview: UIView!
    @IBOutlet weak var audiocheckview: UIView!
    @IBOutlet weak var audioopenview: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
