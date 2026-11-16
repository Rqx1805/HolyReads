//
//  ForgotPassword_IpadVC.swift
//  Holy Reads
//
//  Created by Ashish Soni on 20/07/20.
//  Copyright © 2020 Ajeet singh Rawat. All rights reserved.
//

import UIKit

class ForgotPassword_IpadVC: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var txtEmail: UITextField!
    
    
    // MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    // MARK: - IBAction
    
    @IBAction func btnUpdate_DidSelect(_ sender: Any) {
        self.view.endEditing(true)
        if ValidationClass().ValidateForgotPasswordForm(self){
            self.showHud()
            let parameterDictionary = NSMutableDictionary()
            parameterDictionary.setValue(DataManager.getVal(txtEmail.text!) as! String, forKey: "email")
            print(parameterDictionary)
            
            let methodName = "forgot_password"
            DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
                let status  = DataManager.getVal(responseData?["status"]) as! String
                let message  = DataManager.getVal(responseData?["message"]) as! String
                if status == "1" {
                    let response = DataManager.getVal(responseData?["data"]) as! [String: Any]
                    DataManager.saveinDefaults(response)
                    let obj = UIStoryboard(name: "MainStoryboard_iPad", bundle: nil).instantiateViewController(withIdentifier: "OTPVerification_IpadVC") as! OTPVerification_IpadVC
                    obj.isFrom = "ForgotPassword"
                    self.navigationController?.pushViewController(obj, animated: true)
                } else{
                    self.view.makeToast(message: message)
                    //self.clearAllNotice()
                }
                self.clearHud()
                
            }
        }
    }
    
    @IBAction func btnClose_DidSelect(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        
    }
    
}

