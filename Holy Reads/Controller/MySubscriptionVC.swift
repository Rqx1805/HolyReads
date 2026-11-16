//
//  MySubscriptionVC.swift
//  Holy Reads
//
//  Created by mac-14 on 02/09/19.
//  Copyright © 2019 Ajeet singh Rawat. All rights reserved.
 
import UIKit

class MySubscriptionVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var lblPlanName: UILabel!
    @IBOutlet weak var lblPlanDetails: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblPlanDuration: UILabel!
    @IBOutlet weak var lblMemberAdded: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var tblMemberAdded: UITableView!
    @IBOutlet weak var viewAddMemberHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblDisCount: UILabel!
    
    @IBOutlet weak var btnAddMember: UIButton!
    @IBOutlet weak var tblMemberHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewSapceHeightConstraint: NSLayoutConstraint!
    // MARK: - Variable
    var dictSubscriptionDetails = [String:Any]()
    var PlanId = Int()
    var subid:Int!
    var planDuration = Int()
    var planCategory = Int()
    var arrAddeMemberDetails = [[String:Any]]()
    var currentPlanMembersCount = Int()
    var subscriptionPlanName = String()
     // MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        tblMySubscription.rowHeight = UITableView.automaticDimension
//        tblMySubscription.estimatedRowHeight = 35
    }
    // MARK: - ViewWillAppear
    
    override func viewWillAppear(_ animated: Bool) {
         self.mySubscriptionApi()
        
    }
  
    // MARK: - NavigationBar Buttons
    @IBAction func btnBack_DidSelect(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    // MARK: - IBAction
    @IBAction func btnUpdateTapped_DidSelect(_ sender: Any) {
//        let obj = self.storyboard?.instantiateViewController(withIdentifier: "MembershipPlanUpdateVC") as! MembershipPlanUpdateVC
//        obj.currentPlanMemberCount = currentPlanMembersCount
//        obj.subscriptionPlanName = subscriptionPlanName
          let obj = self.storyboard?.instantiateViewController(withIdentifier: "MembershipPlanVCNew") as! MembershipPlanVCNew
          obj.subid = self.subid
          self.navigationController?.pushViewController(obj, animated: true)
    }

    @IBAction func btnAddMember_DidSelect(_ sender: Any) {
        let obj = self.storyboard?.instantiateViewController(withIdentifier: "AddMemberVC") as! AddMemberVC
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    @objc func deleteAddedMember(_ sender :UIButton){
        if let dict = arrAddeMemberDetails[sender.tag] as? [String:Any] {
            if let email =  dict["email"] as? String{
                self.view.endEditing(true)
                self.showHud()
                let parameterDictionary = NSMutableDictionary()
                parameterDictionary.setValue(DataManager.getVal(email) as! String, forKey: "email")
                print(parameterDictionary)
                
                let methodName = "deleteMember"
                
                DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
                    let status  = DataManager.getVal(responseData?["status"]) as! String
                    let message  = DataManager.getVal(responseData?["message"]) as! String
                    let memberStatus = DataManager.getVal(responseData?["member_status"]) as! String
                    if status == "1" {
////                        let response = DataManager.getVal(responseData?["data"]) as! [String: Any]
////                        self.dictSubscriptionDetails = response
////                        self.setSubsciptionData()
//                        if memberStatus == "0" {
//                            self.btnAddMember.isHidden = false
//                            self.tableViewSapceHeightConstraint.constant = 20
//                            self.viewAddMemberHeightConstraint.constant = 40
//                        }else {
//                            self.viewAddMemberHeightConstraint.constant = 0
//                            self.tableViewSapceHeightConstraint.constant = 0
//                            self.btnAddMember.isHidden = true
//                        }
                        self.mySubscriptionApi()
                    } else{
                        self.view.makeToast(message: message)
                    }
                    self.clearHud()
                }
            }
        }
     }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrAddeMemberDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberAddedCell", for: indexPath) as! MemberAddedCell
        if arrAddeMemberDetails.count != 0 {
            let dict = arrAddeMemberDetails[indexPath.row]
            if let email =  dict["email"] as? String{
                cell.lblEmail.text = email
             }
            if let verified_status = dict["verified_status"] as? Int {
                if verified_status == 1 {
                    cell.imgVerified.image = UIImage.init(named: "checkmark")
                }else {
                  cell.imgVerified.image = UIImage.init(named: "")
                }
             }
            cell.btnDelete.tag = indexPath.row
            cell.btnDelete.addTarget(self, action: #selector(deleteAddedMember), for: .touchUpInside)
         }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    //MARK:- Api Call(My Subscription Plan)
    func mySubscriptionApi() {
        self.view.endEditing(true)
        self.showHud()
        let parameterDictionary = NSMutableDictionary()
        let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        parameterDictionary.setValue(DataManager.getVal(user_id) as! String, forKey: "user_id")
        print(parameterDictionary)
        
        let methodName = "getmysubscription"
        
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
            let memberStatus = DataManager.getVal(responseData?["member_status"]) as! String

            if status == "1" {
                let response = DataManager.getVal(responseData?["data"]) as! [String: Any]
                self.dictSubscriptionDetails = response
                if memberStatus == "0" {
                    self.btnAddMember.isHidden = false
                    self.tableViewSapceHeightConstraint.constant = 20
                    self.viewAddMemberHeightConstraint.constant = 40
                }else {
                    self.viewAddMemberHeightConstraint.constant = 0
                    self.tableViewSapceHeightConstraint.constant = 0
                    self.btnAddMember.isHidden = true
                }
                self.setSubsciptionData()
            } else{
                self.view.makeToast(message: message)
            }
            self.clearHud()
        }
    }
    
    func setSubsciptionData()  {
        
        subid = dictSubscriptionDetails["id"] as? Int
        if let planName =  dictSubscriptionDetails ["title"] as? String {
            self.subscriptionPlanName = planName
            self.lblPlanName.text = planName
            if planName == "Individual"  {
                self.viewAddMemberHeightConstraint.constant = 0
                self.tableViewSapceHeightConstraint.constant = 0
                self.btnAddMember.isHidden = true
              } else {
//                self.btnAddMember.isHidden = false
//                self.tableViewSapceHeightConstraint.constant = 20
//                self.viewAddMemberHeightConstraint.constant = 40
            }
        }
        var discount:Int!
        discount = dictSubscriptionDetails["discount"] as? Int
        var newdis:String!
        newdis = String(discount)
        if newdis == "0" {
            self.lblDisCount.text = ""
            self.lblDisCount.isHidden = true
        }else {
            self.lblDisCount.isHidden = false
            self.lblDisCount.text = "Save " + newdis + "%"
        }
       
        
        if let memberCount = dictSubscriptionDetails["members_count"] as? Int{
            currentPlanMembersCount = dictSubscriptionDetails["total_members_count"] as? Int ?? 0
            self.lblMemberAdded.text = "\(memberCount)/\(dictSubscriptionDetails["total_members_count"] as! Int) Members Added"
        }
//        if let planDetails =  dictSubscriptionDetails ["subscription_details"] as? String {
//            if planDetails == "Summary Only"{
//                planCategory = 1
//            } else if planDetails == "Summary, Audio and Video" {
//                planCategory = 3
//            } else if planDetails == "Summary and Audio" {
//                planCategory = 2
//            }
//            self.lblPlanDetails.text = planDetails
//        }
        self.lblPlanDetails.text = "Written, Audio and Video Summaries"
        if let price =  dictSubscriptionDetails ["price"] as? String {
            self.lblPrice.text = String("$\(price)")
        }
        if let planDuration =  dictSubscriptionDetails ["title"] as? String {
            if planDuration == "Monthly"{
                self.planDuration = 30
            } else if planDuration == "Quarterly"{
                self.planDuration = 120
            } else if planDuration == "Anually"{
                self.planDuration = 365
            }
            self.lblPlanDuration.text = planDuration
        }
        if let description =  dictSubscriptionDetails ["description"] as? String {
            // webView.loadHTMLString(description, baseURL: nil)
            var trimmed:String!
            if description.contains("\r\n") {
                 trimmed = description.replacingOccurrences(of: "\r\n", with: "")
            }else {
                 trimmed = description.replacingOccurrences(of: "\n", with: "")
            }
            
            let trimmed2 = trimmed.replacingOccurrences(of: "<ul> <li>", with: "")
            let trimmed20 = trimmed2.replacingOccurrences(of: "<ul><li>", with: "")
            let trimmed1 = trimmed20.replacingOccurrences(of: "</li> <li>", with: "")
            let trimmed3 = trimmed1.replacingOccurrences(of: "</li><li>", with: "")
            let trimmed4 = trimmed3.replacingOccurrences(of: "</strong>", with: "")
            let trimmed5 = trimmed4.replacingOccurrences(of: "<strong>&nbsp;", with: " ")
            let fullNameArr = trimmed5.components(separatedBy: ".")
            var s = [String]()
            
            for i in 0..<fullNameArr.count-1 {
                s.append(fullNameArr[i])
            }
            self.lblDescription.attributedText = addBulletToString(stringList: s, font: UIFont.systemFont(ofSize: 15), bullet: "●")
            print(lblDescription.text)
        }
        if let subscriptionId =  dictSubscriptionDetails ["subscription_id"] as? Int {
            self.PlanId = subscriptionId
        }
        
        if let arrMembers =  dictSubscriptionDetails ["members"] as? [[String :Any]] {
            self.arrAddeMemberDetails = arrMembers
            self.tblMemberHeightConstraint.constant = CGFloat(arrAddeMemberDetails.count * 49)
            self.tblMemberAdded.reloadData()
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
