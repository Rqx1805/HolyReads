//
//  DailyBreedDetailsVC.swift
//  Holy Reads
//
//  Created by mac-14 on 02/03/20.
//  Copyright © 2020 Ajeet singh Rawat. All rights reserved.
//

import UIKit
import SDWebImage

class DailyBreedDetailsVC: UIViewController {
    //MARK:- Outlets
    
    @IBOutlet weak var lblImgBookName: UILabel!
    
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lblSubtitile: UILabel!
    @IBOutlet weak var lblBookName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    //MARK:- Variable
    
    var dictDailyBreed = [String:Any]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if let bannerImg =  dictDailyBreed["banner_image"] as? String {
            self.img.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.img.startAnimating()
            let url = URL.init(string: bannerImg)
            self.img.sd_setImage(with: url, placeholderImage: UIImage.init(named: ""), options: .refreshCached, completed: { (img, error, cacheType, url) in
            })
            self.img.stopAnimating()
        }
        if let title =  dictDailyBreed["title"] as? String{
            self.lblImgBookName.text = title
            self.lblBookName.text = title
            
        }
        if let subtitle =  dictDailyBreed["subtitle"] as? String{
            self.lblSubtitile.text = subtitle
        }
        if let description =  dictDailyBreed["description"] as? String{
            let strOne =  description.replacingOccurrences(of: "<p>", with: "")
            let strTwo = strOne.replacingOccurrences(of: "</p>", with: "\n")
            self.lblDescription.text = strTwo
        }
    }
    
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
      
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
