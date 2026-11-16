//
//  NotificationChannelVC.swift
//  Holy Reads
//
//  Created by MAC-25 on 08/03/21.
//  Copyright © 2021 Ajeet singh Rawat. All rights reserved.
//

import UIKit

class NotificationChannelVC: UIViewController {

    @IBOutlet weak var emailSwitch: UISwitch!
    @IBOutlet weak var inAppSwitch: UISwitch!
    var notificationStatus = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.value(forKey: "notification_status")as? String == "0"{
            emailSwitch.isOn = false
        } else{
            emailSwitch.isOn =  true
        }
        
        if UserDefaults.standard.value(forKey: "email_notification_status")as? String == "0"{
            inAppSwitch.isOn = false
        } else{
            inAppSwitch.isOn =  true
        }


        // Do any additional setup after loading the view.
    }
    
    @IBAction func backBtbAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func emailSwitchAction(_ sender: UISwitch) {
        print("Switchtapped")
        if sender.isOn{
            notificationStatus = "1"
        } else {
            notificationStatus = "0"
        }
        self.notificationApi()
    }
    @IBAction func inAppSwitchAction(_ sender: UISwitch) {
        print("Switchtapped")
        if sender.isOn{
            notificationStatus = "1"
        } else {
            notificationStatus = "0"
        }
        self.notificationApi1()
    }
   
    //MARK:- Api Call
    func notificationApi() {
        self.view.endEditing(true)
        self.showHud()
        let parameterDictionary = NSMutableDictionary()
        let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        parameterDictionary.setValue(DataManager.getVal(user_id) as! String, forKey: "user_id")
        parameterDictionary.setValue(DataManager.getVal("1") as! String, forKey: "type")
        parameterDictionary.setValue(DataManager.getVal(notificationStatus) as! String, forKey: "notification_status")
        print(parameterDictionary)
        
        let methodName = "changenotificationsetting"
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
            if status == "1" {
                self.notificationStatus =  DataManager.getVal(responseData?["notification_status"]) as! String
                UserDefaults.standard.set(self.notificationStatus, forKey: "notification_status")
            } else{
                self.view.makeToast(message: message)
            }
            self.clearHud()
        }
    }
    
    func notificationApi1() {
        self.view.endEditing(true)
        self.showHud()
        let parameterDictionary = NSMutableDictionary()
        let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        parameterDictionary.setValue(DataManager.getVal(user_id) as! String, forKey: "user_id")
        parameterDictionary.setValue(DataManager.getVal("2") as! String, forKey: "type")
        parameterDictionary.setValue(DataManager.getVal(notificationStatus) as! String, forKey: "notification_status")
        print(parameterDictionary)
        
        let methodName = "changenotificationsetting"
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
            if status == "1" {
                self.notificationStatus =  DataManager.getVal(responseData?["email_status"]) as! String
                UserDefaults.standard.set(self.notificationStatus, forKey: "email_notification_status")
            } else{
                self.view.makeToast(message: message)
            }
            self.clearHud()
        }
    }
    
    func notificationApi2() {
        self.view.endEditing(true)
        self.showHud()
        let parameterDictionary = NSMutableDictionary()
        let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        parameterDictionary.setValue(DataManager.getVal(user_id) as! String, forKey: "user_id")
        parameterDictionary.setValue(DataManager.getVal("3") as! String, forKey: "type")
        parameterDictionary.setValue(DataManager.getVal(notificationStatus) as! String, forKey: "notification_status")
        print(parameterDictionary)
        
        let methodName = "changenotificationsetting"
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
            if status == "1" {
                self.notificationStatus =  DataManager.getVal(responseData?["email_status"]) as! String
                UserDefaults.standard.set(self.notificationStatus, forKey: "email_notification_status")
            } else{
                self.view.makeToast(message: message)
            }
            self.clearHud()
        }
    }



}
