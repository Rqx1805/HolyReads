//
//  BlessFriendVC.swift
//  Holy Reads
//
//  Created by mac-14 on 02/09/19.
//  Copyright © 2019 Ajeet singh Rawat. All rights reserved.
//

import UIKit

class BlessFriendVC: UIViewController {

    // MARK: - IBOutlet
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var btnChooseSubscriptionPlan: UIButton!
    @IBOutlet weak var txtPassword: UITextField!
    
 
    var subsciptionDetails = Int()
    var planDuration = ""
    var SubscriptionID:String!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        btnChooseSubscriptionPlan.layer.borderColor = #colorLiteral(red: 0.9960784314, green: 0.6, blue: 0.1450980392, alpha: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        SubscriptionID = DataManager.getVal(Config().AppUserDefaults.value(forKey: "SubId")) as? String
    }
    
    // MARK: - NavigationBar Buttons
    @IBAction func btnBack_DidSelect(_ sender: Any) {
        SubscriptionID = ""
        self.navigationController?.popViewController(animated: true)
    }
    
   // MARK: - IBAction
    
    @IBAction func brnChoosePlan(_ sender: Any) {
        let obj = self.storyboard?.instantiateViewController(withIdentifier: "BlessPlanVcNew") as! BlessPlanVcNew
       // obj.delegate = self
        let defaults = UserDefaults.standard
        defaults.setValue(txtEmail.text, forKey: "BlessEmail")
        defaults.setValue(txtName.text, forKey: "BlessUser")
        defaults.setValue(txtPassword.text, forKey: "BlessPassword")
        defaults.synchronize()
        self.navigationController?.pushViewController(obj, animated: true)
        
    }
    @IBAction func btnMakePayment(_ sender: Any) {
         self.view.endEditing(true)
        if ValidationClass().ValidateBlessFriendForm(self) {
            self.showHud()
            
//            "username" : "Holy",
//            "email" : "holy@mailinator.com",
//            "password" : "A4admin",
//            "subscription_details" : 1,
//            "duration" : 30
            let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
            let parameterDictionary = NSMutableDictionary()
            parameterDictionary.setValue(user_id, forKey: "user_id")
            parameterDictionary.setValue(SubscriptionID, forKey: "subscription_id")
            parameterDictionary.setValue(DataManager.getVal(txtEmail.text!) as! String, forKey: "email")
            parameterDictionary.setValue(DataManager.getVal(txtName.text!) as! String, forKey: "username")
            parameterDictionary.setValue(DataManager.getVal(txtPassword.text!) as! String, forKey: "password")
           // parameterDictionary.setObject(DataManager.getVal(subsciptionDetails), forKey: "subscription_details" as NSCopying)
           // parameterDictionary.setValue(DataManager.getVal(planDuration) as! String, forKey: "duration")
            print(parameterDictionary)
            
            let methodName = "blessafriend"
            
            DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
                let status  = DataManager.getVal(responseData?["status"]) as! String
                let message  = DataManager.getVal(responseData?["message"]) as! String
                if status == "1" {
                //    let response = DataManager.getVal(responseData?["data"]) as! [String: Any]
                    self.navigationController?.popViewController(animated: true)
                    self.topViewController()?.view.makeToast(message: message)
                    UserDefaults.standard.removeObject(forKey: "SubId")
                 }
                else{
                    self.view.makeToast(message: message)
                }
                self.clearHud()
            }
        }
        
        // self.navigationController?.popViewController(animated: true)
        
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
extension BlessFriendVC: PlanDelegate {
    func updatePlanData(subsciptionDetails: Int, planDuration: String) {
         self.subsciptionDetails = subsciptionDetails
        self.planDuration = planDuration
    }
}


