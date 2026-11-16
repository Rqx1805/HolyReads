//
//  CuratedListVC.swift
//  Holy Reads
//
//  Created by mac-14 on 04/03/20.
//  Copyright © 2020 Ajeet singh Rawat. All rights reserved.
//

import UIKit
import SDWebImage
import WebKit

class CuratedListVC: UIViewController,WKNavigationDelegate {
     // MARK: - IBOutlet
    
    @IBOutlet weak var lblImgBookName: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lblSubtitile: UILabel!
    @IBOutlet weak var lblBookName: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var webview: WKWebView!
    @IBOutlet weak var webviewHeightConstraint: NSLayoutConstraint!
    // MARK: - Variable
      var dictCuratedList = [String:Any]()
    // MARK: - ViewLifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.webview.navigationDelegate = self
        self.webview.scrollView.showsHorizontalScrollIndicator = false
        self.webview.scrollView.showsVerticalScrollIndicator = false
        //self.webview.scrollView.isScrollEnabled = false

//        if let desciption = dictCuratedList["content"] as? String {
//            let strHtml = desciption
//            webview.loadHTMLString(strHtml, baseURL: nil)
//
//
//        }
        if let strUrl = dictCuratedList["url"] as? String {
            let url = URL (string: strUrl)
            let requestObj = URLRequest(url: url!)
            webview.load(requestObj)
        }
//         if let bannerImg =  dictCuratedList["banner_image"] as? String {
//                   self.img.sd_imageIndicator = SDWebImageActivityIndicator.gray
//                   self.img.startAnimating()
//                   let url = URL.init(string: bannerImg)
//                   self.img.sd_setImage(with: url, placeholderImage: UIImage.init(named: ""), options: .refreshCached, completed: { (img, error, cacheType, url) in
//                   })
//                   self.img.stopAnimating()
//               }
//               if let title =  dictCuratedList["title"] as? String{
//                   self.lblImgBookName.text = title
//                   self.lblBookName.text = title
//
//               }
//               if let subtitle =  dictCuratedList["short_description"] as? String{
//                   self.lblSubtitile.text = subtitle
//                }
              // if let description =  dictCuratedList["description"] as? String{
              //     self.lblDescription.text = description
              // }
        
  //
//            "banner_image" = "https://devnode.devtechnosys.tech/holyreads/webroot/expert_curated/image1.png";
//            content = "<p>1.Billy Graham, the Inspirational Writings: Peace with God, the Secrets of Happiness, Answers to Life\U2019s  ;
//            id = 1
//            "short_description" = "Billy Graham is a name that most people know, even those whonot claim the Christian faith. A prominent evangelical Christian, he took the call to preaching to new heights throughout his career. Not only has he spoken the timeless words of God to the masses, but he has written numerous books, pamphlets, and sermons over the years. Below is a list of ten of his best, top-selling books."
//            title = "Top 10 Recommended Billy Graham Books"
//
        // Do any additional setup after loading the view.
    }
    
    @IBAction func btnBack(_ sender: UIButton) {
           self.navigationController?.popViewController(animated: true)
       }
    
//  func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
//        webView.frame.size.height = 1
//        webView.frame.size = webView.sizeThatFits(.zero)
//        //webView.scrollView.isScrollEnabled=false
//        webView.frame.size = webView.scrollView.contentSize
//
//      //  webviewHeightConstraint.constant = webView.scrollView.contentSize.height
//        
//    }
      
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
