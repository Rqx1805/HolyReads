//
//  Notification_IpadVC.swift
//  Holy Reads
//
//  Created by Ashish Soni on 20/07/20.
//  Copyright © 2020 Ajeet singh Rawat. All rights reserved.
//

import UIKit
import PMAlertController

class Notification_IpadVC: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var tblNotification: UITableView!
    @IBOutlet weak var lblNoDataFound: UILabel!
    @IBOutlet weak var clear_all_btn: UIButton!
    
    // MARK: - Variable
    var arrNotification = [[String:Any]]()
    var refreshContoller = UIRefreshControl()
    
    
    // MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshContoller.addTarget(self, action: #selector(Refresh), for: .valueChanged)
        self.tblNotification.addSubview(refreshContoller)
        
        self.tblNotification.rowHeight = UITableView.automaticDimension
        self.tblNotification.estimatedRowHeight = 20
    }
    
    // MARK: - ViewWillAppear
    override func viewWillAppear(_ animated: Bool) {
        self.NotificationApiCall()
    }
    
    // MARK: - NavigationBar Buttons
    @IBAction func btnBack_DidSelect(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnClearAllNotifiction(_ sender: UIButton) {
        let myAlert = PMAlertController(title: "Holy Reads", description: "Are you sure you want to clear all the notifications?", image: UIImage(named: "welcome_logo"), style: .alert)
       // let myAlert = UIAlertController(title: "Holy Reads", message:message, preferredStyle: UIAlertController.Style.alert);
        
        myAlert.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () -> Void in
            print("Cancel")
        }))
        
        myAlert.addAction(PMAlertAction(title: "Yes", style: .default, action: { () in
            self.ClearNotificationApiCall()
        }))
        
        self.present(myAlert, animated: true, completion: nil)
        
    }
    
    @objc func Refresh() {
        self.NotificationApiCall()
    }
    
    //MARK: - MarkBookFavourite API Call
    func NotificationApiCall() {
        self.showHud()
        let parameterDictionary = NSMutableDictionary()
        let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        parameterDictionary.setValue(user_id, forKey: "user_id")
        let methodName = "getAllNotifications"
        
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
            
            if status == "1" {
                if let response  = DataManager.getVal(responseData?["data"]) as? [[String:Any]] {
                    self.arrNotification = response
                    self.lblNoDataFound.isHidden = true
                    self.tblNotification.reloadData()
                }
            } else{
                self.lblNoDataFound.isHidden = false
                //self.view.makeToast(message: message)
            }
            self.refreshContoller.endRefreshing()
            self.clearHud()
        }
    }
    
    func ClearNotificationApiCall() {
        self.showHud()
        let parameterDictionary = NSMutableDictionary()
        let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        parameterDictionary.setValue(user_id, forKey: "user_id")
        let methodName = "clearNotification"
        
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
            if status == "1" {
                self.arrNotification.removeAll()
                self.lblNoDataFound.isHidden = false
                self.tblNotification.reloadData()
            } else{
                self.lblNoDataFound.isHidden = false
                // self.view.makeToast(message: message)
            }
            self.clearHud()
        }
    }
}

// MARK: - UITableViewDelegate
extension Notification_IpadVC: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.clear_all_btn.setTitle(arrNotification.count == 0 ? "" : "Clear All", for: .normal)
        return arrNotification.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Notification_IpadCell", for: indexPath) as! Notification_IpadCell
        let dict = arrNotification[indexPath.row]
        if let title = dict["title"] as? String{
            cell.lblTitle.text = title
        }
        if let description = dict["description"] as? String{
            cell.lblDescription.text = description
        }
        if let date = dict["date"] as? String{
            let time = self.getCreatePostTime(strdate: date)
            cell.lblTime.text = time
        }
        return cell
    }
}


