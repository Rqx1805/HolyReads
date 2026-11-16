//
//  SubmitFeedbackVC.swift
//  Holy Reads
//
//  Created by mac-14 on 18/10/19.
//  Copyright © 2019 Ajeet singh Rawat. All rights reserved.
//

import UIKit

class SubmitFeedbackVC: UIViewController {
// MARK: - Outlets
    @IBOutlet weak var txtSubmitFeedback: UITextView!
    @IBOutlet weak var txtTitle: UITextField!
    
    // MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        txtSubmitFeedback.layer.borderColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 0.4572720462)
        txtSubmitFeedback.layer.borderWidth = 1

    }
    
    // MARK: - NavigationBar Buttons
    @IBAction func btnBack_DidSelect(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
      
    // MARK: - IBAction
    @IBAction func btnSubmit(_ sender: UIButton) {
        self.submitFeedback()
    }
       // MARK: - Submit Feedback api Call
     func submitFeedback() {
        if ValidationClass().ValidateSubmitfeedback(self) {
            self.showHud()
            
            let a = txtSubmitFeedback.text!
            let submitText = a.replacingOccurrences(of: "\n", with: "<br>")
            
            let parameterDictionary = NSMutableDictionary()
            let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
            let email = DataManager.getVal(Config().AppUserDefaults.value(forKey: "email")) as! String
            
            parameterDictionary.setValue(user_id, forKey: "user_id")
            parameterDictionary.setValue(email, forKey: "email")
            parameterDictionary.setValue(txtTitle.text!, forKey: "title")
            parameterDictionary.setValue(submitText, forKey: "feedback")
            
            print(parameterDictionary)
            let methodName = "submitfeedback"
            
            DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
                let status  = DataManager.getVal(responseData?["status"]) as! String
                let message  = DataManager.getVal(responseData?["message"]) as! String
                if status == "1" {
                    self.navigationController?.popViewController(animated: true)
                    self.topViewController()?.view.makeToast(message: message)
                } else {
                    print(message)
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
