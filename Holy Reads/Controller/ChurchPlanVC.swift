//
//  ChurchPlanVC.swift
//  Holy Reads
//
//  Created by mac-14 on 17/12/19.
//  Copyright © 2019 Ajeet singh Rawat. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

class ChurchPlanVC: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    @IBOutlet weak var txtChurchName: UITextField!
    @IBOutlet weak var txtNumberofMember: UITextField!
    @IBOutlet weak var txtComment: IQTextView!
    @IBOutlet weak var txtChurchAddress: UITextField!
    
    // MARK: - Variables
    
    var planId = Int()
    var isFrom = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.txtPhoneNumber.keyboardType = .asciiCapableNumberPad

    }
    
    
    // MARK: - NavigationBar Buttons
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSubmit_ChurchDetails(_ sender: UIButton) {
        
        self.SubmitChurchDetails()
    }
    // MARK: - Submit Church Details API calling
    
    func SubmitChurchDetails() {
        //
        //        "user_id" : 162,
        //               "name" : "yashwant singh",
        //               "email" : "yashwant02@mailniator.com",
        //               "phone" : "2343423424234",
        //               "church_name" : "st.martin",
        //               "church_address" : "2,skjdf dskfjs",
        //               "member_count" : 23,
        //               "comment" : "This is the comment for you."
        
        self.view.endEditing(true)
        if ValidationClass().ValidateChurchPlanForm(self){
            
            let a = txtComment.text!
            let submitComment = a.replacingOccurrences(of: "\n", with: "<br>")
            
            
            self.showHud()
            let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
            
            let parameterDictionary = NSMutableDictionary()
            parameterDictionary.setValue(user_id, forKey: "user_id")
            parameterDictionary.setValue(planId, forKey: "subscription_id")
            parameterDictionary.setValue(txtName.text?.trimmingCharacters(in: .whitespaces), forKey: "name")
            parameterDictionary.setValue(txtEmail.text?.trimmingCharacters(in: .whitespaces), forKey: "email")
            parameterDictionary.setValue(txtPhoneNumber.text?.trimmingCharacters(in: .whitespaces), forKey: "phone")
            parameterDictionary.setValue(txtChurchName.text?.trimmingCharacters(in: .whitespaces), forKey: "church_name")
            parameterDictionary.setValue(txtChurchAddress.text?.trimmingCharacters(in: .whitespaces), forKey: "church_address")
            parameterDictionary.setValue(txtNumberofMember.text?.trimmingCharacters(in: .whitespaces), forKey: "member_count")
            parameterDictionary.setValue(submitComment.trimmingCharacters(in: .whitespaces), forKey: "comment")
            
            print(parameterDictionary)
            
            let methodName = "submitChurchData"
            
            DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
                let status  = DataManager.getVal(responseData?["status"]) as! String
                let message  = DataManager.getVal(responseData?["message"]) as! String
                
                if status == "1" {
                    if self.isFrom == "Login" {
                        self.appDelegate.showFirstPage()
                        self.topViewController()?.view.makeToast(message: message)
                    } else {
                        self.appDelegate.showMain()
                        self.topViewController()?.view.makeToast(message: message)
                    }
                   
                } else {
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
