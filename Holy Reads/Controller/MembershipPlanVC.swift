//
//  MembershipPlanVC.swift
//  Holy Reads
//
//  Created by mac-14 on 05/09/19.
//  Copyright © 2019 Ajeet singh Rawat. All rights reserved.
//

import UIKit

class MembershipPlanVC: UIViewController, UITableViewDataSource, UITableViewDelegate,UIAlertViewDelegate {

    // MARK: - Outlets
    @IBOutlet weak var tblMembershipPlan: UITableView!
    
    // MARK: - Variable
    var arrPlans = [[String:Any]]()
    var tappedPlanName = ""
    var isFrom = ""
    
    // MARK: - ViewLifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }
    // MARK: - ViewWillAppear

    override func viewWillAppear(_ animated: Bool) {
        //self.onShowFloatingBanner(title: "", message: "Pick a plan to start your free trial")
//        let alert = UIAlertController(title: "Holy Reads", message: "Pick a plan to start your free trial", preferredStyle: UIAlertController.Style.alert)
//        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
//        self.present(alert, animated: true, completion: nil)
        self.getMembershipPlanApiCall()
        //self.view.makeToast(message: "Pick a plan to start your free trial")
    }
    
    //MARK:- IBAction

    
//    @IBAction func btnIndividualPlan_DidSelect(_ sender: UIButton) {
//        let obj = self.storyboard?.instantiateViewController(withIdentifier: "SubscriptionPlanVC") as! SubscriptionPlanVC
//        self.navigationController?.pushViewController(obj, animated: true)
//    }
//    @IBAction func btnFamilyPlan_DidSelect(_ sender: UIButton) {
//        let obj = self.storyboard?.instantiateViewController(withIdentifier: "SubscriptionPlanVC") as! SubscriptionPlanVC
//        self.navigationController?.pushViewController(obj, animated: true)
//
//    }
//    @IBAction func btnSmallGroupPlan_DidSelect(_ sender: UIButton) {
//        let obj = self.storyboard?.instantiateViewController(withIdentifier: "SubscriptionPlanVC") as! SubscriptionPlanVC
//        self.navigationController?.pushViewController(obj, animated: true)
//    }
//    @IBAction func btnChurchPlan_DidSelect(_ sender: UIButton) {
//        let obj = self.storyboard?.instantiateViewController(withIdentifier: "SubscriptionPlanVC") as! SubscriptionPlanVC
//        self.navigationController?.pushViewController(obj, animated: true)
//    }
    
    
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
        if let dic = arrPlans[indexPath.row] as? [String:Any] {
            if let subscriptionTitleName =  dic["slug"] as? String{
                self.tappedPlanName = subscriptionTitleName
            }
            if let id =  dic["subscription_id"] as? Int {
                if isFrom == "Login"  {
                    if tappedPlanName == "church" {
                        let obj = self.storyboard?.instantiateViewController(withIdentifier: "ChurchPlanVC") as! ChurchPlanVC
                        obj.planId = id
                         obj.isFrom = "Login"
                        self.navigationController?.pushViewController(obj, animated: true)
                    } else {
                        let obj = self.storyboard?.instantiateViewController(withIdentifier: "SubscriptionPlanVC") as! SubscriptionPlanVC
                        obj.planId = id
                        obj.isFrom = "Login"
                        self.navigationController?.pushViewController(obj, animated: true)
                    }
                } else {
                    if tappedPlanName == "church" {
                        let obj = self.storyboard?.instantiateViewController(withIdentifier: "ChurchPlanVC") as! ChurchPlanVC
                        obj.planId = id
                        self.navigationController?.pushViewController(obj, animated: true)
                    } else {
                        let obj = self.storyboard?.instantiateViewController(withIdentifier: "SubscriptionPlanVC") as! SubscriptionPlanVC
                        obj.planId = id
                        self.navigationController?.pushViewController(obj, animated: true)
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
