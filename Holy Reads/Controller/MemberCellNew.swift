//
//  MemberCellNew.swift
//  Holy Reads
//
//  Created by Ashish Soni on 23/10/20.
//  Copyright © 2020 Ajeet singh Rawat. All rights reserved.
//

import UIKit
import WebKit
class MemberCellNew: UICollectionViewCell {
    
    @IBOutlet weak var planView: UIView!
    @IBOutlet weak var monthLbl: UILabel!
    @IBOutlet weak var priceLbl: UIButton!
    @IBOutlet weak var pageContro: UIPageControl!
    @IBOutlet weak var buyBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        pageContro.numberOfPages = 3
       // pageContro.currentPage = 0
        priceLbl.layer.cornerRadius = 15
        priceLbl.layer.borderWidth = 1
        priceLbl.layer.borderColor = UIColor(red: 254/255, green: 153/255, blue: 37/255, alpha: 1.0).cgColor
        buyBtn.layer.cornerRadius = 20
        // Initialization code
        
    }
}
