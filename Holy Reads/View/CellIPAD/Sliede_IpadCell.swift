//
//  Sliede_IpadCell.swift
//  Holy Reads
//
//  Created by Ashish Soni on 20/07/20.
//  Copyright © 2020 Ajeet singh Rawat. All rights reserved.
//

import UIKit

class Sliede_IpadCell: UICollectionViewCell {
    
    @IBOutlet weak var imgIntro: UIImageView!
       @IBOutlet weak var lblHeading: UILabel!
       @IBOutlet weak var lblContent: UILabel!
       @IBOutlet weak var imgSelectedPage: UIImageView!
       @IBOutlet weak var btnNext: UIButton!
       @IBOutlet weak var btnSkip: UIButton!
       @IBOutlet weak var loginBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
