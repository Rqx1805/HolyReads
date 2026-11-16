//
//  EditNotView.swift
//  Holy Reads
//
//  Created by MAC-25 on 19/02/21.
//  Copyright © 2021 Ajeet singh Rawat. All rights reserved.
//

import UIKit

class EditNotView: UIView {

   
    var buttonCancelHandler : (() -> Void)?
    var buttonDoneHandler : (() -> Void)?
    
    @IBOutlet weak var popview: UIView!
    class func intitiateFromNib() -> EditNotView {
        let View1 = UINib.init(nibName: "EditNotView", bundle: nil).instantiate(withOwner: self, options: nil).first as! EditNotView
        
        return View1
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.popview.layer.cornerRadius = 8
        
    }
    @IBAction func CnacelBtnAction(_ sender: Any) {
        buttonCancelHandler?()
    }
    @IBAction func OKBtnAction(_ sender: Any) {
        buttonDoneHandler?()
    }
}
