//
//  MembershipPlanUpdateVC.swift
//  Holy Reads
//
//  Created by mac-14 on 15/01/20.
//  Copyright © 2020 Ajeet singh Rawat. All rights reserved.
//

import UIKit

class MembershipPlanUpdateVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: - Outlets
    @IBOutlet weak var tblMembershipPlan: UITableView!
    
    // MARK: - Variable
    var arrPlans = [[String:Any]]()
    var tappedPlanName = ""
    var currentPlanMemberCount = Int()
    var subscriptionPlanName = ""
    // MARK: - ViewLifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    // MARK: - ViewWillAppear

    override func viewWillAppear(_ animated: Bool) {
       // self.onShowFloatingBanner(title: "", message: "Pick a plan to start your free trial")
        self.getMembershipPlanApiCall()
        //self.view.makeToast(message: "Pick a plan to start your free trial")
    }
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Tableview Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrPlans.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SubscriptionPlanCell") as! SubscriptionPlanCell
        let dic = arrPlans[indexPath.row] as! [String:Any]
        if let title = dic["subscription_title"] as? String{
            cell.btnPlan.setTitle(title, for: .normal)
            cell.btnPlan.isUserInteractionEnabled = false
        }
        cell.tag = indexPath.row
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let dic = arrPlans[indexPath.row] as! [String:Any]
        if let name = dic["subscription_title"] as? String {
            if name == "Church" && self.subscriptionPlanName == "Church"  {
                self.view.makeToast(message: "You already have church plan. Please contact admin to upgrade your plan.")
            } else {
                if let memberCount  = dic["members_allowed"] as? Int {
                    
                    if memberCount >= currentPlanMemberCount {
                        if let subscriptionTitleName =  dic["slug"] as? String{
                            self.tappedPlanName = subscriptionTitleName
                        }
                        if let id =  dic["subscription_id"] as? Int {
                            if tappedPlanName == "church" {
                                let obj = self.storyboard?.instantiateViewController(withIdentifier: "ChurchPlanVC") as! ChurchPlanVC
                                obj.planId = id
                                // obj.isFrom = "MySubscriptionVC"
                                //obj.isFrom = "Login"
                                self.navigationController?.pushViewController(obj, animated: true)
                            } else {
                                let obj = self.storyboard?.instantiateViewController(withIdentifier: "SubscriptionPlanVC") as! SubscriptionPlanVC
                                obj.planId = id
                                obj.isFrom = "MySubscriptionVC"
                                self.navigationController?.pushViewController(obj, animated: true)
                            }
                        }
                    } else {
                        let normalAlert = UIAlertController(title: "Holy reads", message: "You are trying to degrade you plan. All your added member will be deleted if you degrade your plan", preferredStyle: .alert)
                        normalAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                            if let subscriptionTitleName =  dic["slug"] as? String{
                                self.tappedPlanName = subscriptionTitleName
                            }
                            if let id =  dic["subscription_id"] as? Int {
                                if self.tappedPlanName == "church" {
                                    let obj = self.storyboard?.instantiateViewController(withIdentifier: "ChurchPlanVC") as! ChurchPlanVC
                                    obj.planId = id
                                    // obj.isFrom = "MySubscriptionVC"
                                    //obj.isFrom = "Login"
                                    self.navigationController?.pushViewController(obj, animated: true)
                                } else {
                                    let obj = self.storyboard?.instantiateViewController(withIdentifier: "SubscriptionPlanVC") as! SubscriptionPlanVC
                                    obj.planId = id
                                    obj.isFrom = "MySubscriptionVC"
                                    self.navigationController?.pushViewController(obj, animated: true)
                                }
                            }
                        }))
                        normalAlert.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: nil))
                        
                        self.present(normalAlert, animated: true, completion: nil)
                        //
                    }
                    
                }
            }
        }
     }
    
 
    func getMembershipPlanApiCall () {
        self.view.endEditing(true)
            self.showHud()
            let parameterDictionary = NSMutableDictionary()
            let methodName = "getAllSubscriptionPlan"
            
            DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
                let status  = DataManager.getVal(responseData?["status"]) as! String
                let message  = DataManager.getVal(responseData?["message"]) as! String
                if status == "1" {
                    if let response = DataManager.getVal(responseData?["data"]) as? [[String: Any]]{
                        self.arrPlans = response
                        self.tblMembershipPlan.reloadData()
                    }
                }
                else{
                    self.view.makeToast(message: message)
                }
                self.clearHud()
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

 
