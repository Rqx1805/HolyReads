//
//  KindleVC.swift
//  Holy Reads
//
//  Created by mac-14 on 07/01/20.
//  Copyright © 2020 Ajeet singh Rawat. All rights reserved.
//

import UIKit

class KindleVC: UIViewController {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var lblUserEmailMessage: UILabel!
    @IBOutlet weak var LblUserEm: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let email = DataManager.getVal(Config().AppUserDefaults.value(forKey: "email")) as! String

        self.lblUserEmailMessage.text = "You must add \(email) to your list of approved documents senders to receive documents sent from Holyreads"
        let text1 = "To receive summaries from Holy Reads on your Kindle, add \(email) to your approved senders."
        let range = (text1 as NSString).range(of: email)
            let attributedString = NSMutableAttributedString(string: text1)

        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.darkGray, range: range)
            self.LblUserEm.attributedText = attributedString
       // self.LblUserEm.text = "1. To receive summaries from Holy Reads on your Kindle, add ( \(email) ) to your approved senders."
        
    }
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func btnAddEmail(_ sender: UIButton) {
        self.saveKindleEmail()
     }
    
    //MARK:- Save Kindle Email Id API Calling
    
    func saveKindleEmail() {
        if ValidationClass().ValidateKindleForm(self){
            self.showHud()
            let parameterDictionary = NSMutableDictionary()
            let userId = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
            parameterDictionary.setValue(userId, forKey: "user_id")
            parameterDictionary.setValue(self.txtEmail.text, forKey: "kindle_email")
            let methodName = "saveKindleEmail"
            
            DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
                let status  = DataManager.getVal(responseData?["status"]) as! String
                let message  = DataManager.getVal(responseData?["message"]) as! String
                if status == "1" {
                    self.topViewController()?.view.makeToast(message: message)
                    self.navigationController?.popViewController(animated: false)
                    
                }else{
                    self.view.makeToast(message: message)
                }
                self.clearHud()
            }
        }
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
