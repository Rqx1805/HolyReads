//
//  Webview_IpadVC.swift
//  Holy Reads
//
//  Created by Ashish Soni on 20/07/20.
//  Copyright © 2020 Ajeet singh Rawat. All rights reserved.
//

import UIKit
import WebKit
class Webview_IpadVC: UIViewController, WKUIDelegate {
    
    @IBOutlet weak var lblTittle: UILabel!
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var strTittle = ""
    var strURL = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let Url = Config().Web_URl + strURL
        lblTittle.text = strTittle
        let url = URL (string: Url)
        let request = URLRequest(url: url!)
        webView.load(request)
    }
    
    // MARK: - NavigationBar Buttons
    @IBAction func btnBack_DidSelect(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Web View Methods
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        activityIndicator.stopAnimating()
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        activityIndicator.isHidden = true
        activityIndicator.startAnimating()
    }
    
}
