//
//  SubscriptionPlanVC.swift
//  Holy Reads
//
//  Created by mac-14 on 30/08/19.
//  Copyright © 2019 Ajeet singh Rawat. All rights reserved.
//

import UIKit
import WebKit
class SubscriptionPlanVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var lblPlanName: UILabel!
    @IBOutlet weak var tblPlanDetails: UITableView!
    @IBOutlet weak var txtSelectPriceDetails: UITextView!
    
    @IBOutlet weak var btnWrittenSummaries: UIButton!
    @IBOutlet weak var btnAudioVideoSummaries: UIButton!
    @IBOutlet weak var btnAudioSummaries: UIButton!
    
    @IBOutlet weak var lblWrittenSummaries: UILabel!
    @IBOutlet weak var lblAudioVideoSummaries: UILabel!
    @IBOutlet weak var lblAudioSummaries: UILabel!
    
    @IBOutlet weak var imgWrittenSummaries: UIImageView!
    @IBOutlet weak var imgAudioVideoSummaries: UIImageView!
    @IBOutlet weak var imgAudioSummaries: UIImageView!
    
    @IBOutlet weak var imgMonthlyTriangle: UIImageView!
    @IBOutlet weak var imgQuaterlyTriangle: UIImageView!
    @IBOutlet weak var imgAnnuallyTriangle: UIImageView!
    
    @IBOutlet weak var choosePlanColletionView: UICollectionView!
    //monthly
    @IBOutlet weak var lblMonthlyCurrency: UILabel!
    @IBOutlet weak var lblMonthlyPrice: UILabel!
    @IBOutlet weak var lblPlanDetails: UILabel!
    @IBOutlet weak var btnMonthly: UIButton!
    
    //Anually
    @IBOutlet weak var lblYearlyCurrency: UILabel!
    @IBOutlet weak var lblYearlyPrice: UILabel!
    @IBOutlet weak var lblYearly: UILabel!
    @IBOutlet weak var btnYearly: UIButton!
    
    // Quaterly
    @IBOutlet weak var lblQuaterlyCurrency: UILabel!
    @IBOutlet weak var lblQuaterlyPrice: UILabel!
    @IBOutlet weak var lblQuaterly: UILabel!
    @IBOutlet weak var btnQuaterly: UIButton!
    
    @IBOutlet weak var lblFreeTrial: UILabel!
    @IBOutlet weak var btnFreeTrial: UIButton!
    
    // MARK: - Variables
       
    var isFrom = ""
    var planId = Int()
    var dictPlanDetails = [String:Any]()
    var selectedIndex = Int()
    var arrPlans = ["Monthly","Quaterly", "Annually"]
    var planType = "1"
    var planDuration = ""
    var arrPriceDiscount = [[String:Any]]()
    var arrSummaryPlan = [Int]()
    var arrAudioPlan = [Int]()
    var arrAudioVideoPlan = [Int]()
    var buttonCounter = 1
    
    // MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //         let str = "<p>Lorem Ipsum is simply dummy text.</p>\n<p>Lorem Ipsum is simply dummy text.</p>\n<p>Lorem Ipsum is simply dummy text.</p>\n<p>Lorem Ipsum is simply dummy text.</p>"
        //
        //
        //        let fullNameArr = str.components(separatedBy: ".")
        //
        //        print(fullNameArr)
        //
        
        // lblQuaterlyPrice.attributedText = add(stringList: fullNameArr, font: UIFont.systemFont(ofSize: 10), bullet: "●")
        
        // self.lblQuaterlyPrice.text = "\u{2022} This is a list item!"
        let ChoosePlanLiberaryLayOut = UICollectionViewFlowLayout()
        ChoosePlanLiberaryLayOut.itemSize = CGSize(width: screenWidth/3-20, height: 140)
        ChoosePlanLiberaryLayOut.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        ChoosePlanLiberaryLayOut.minimumInteritemSpacing = 0
        ChoosePlanLiberaryLayOut.minimumLineSpacing = 15
        ChoosePlanLiberaryLayOut.scrollDirection = .horizontal
        
        choosePlanColletionView.collectionViewLayout = ChoosePlanLiberaryLayOut
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        if isFrom == "MySubscriptionVC" || isFrom == "Login" {
            self.btnFreeTrial.isHidden = true
            lblFreeTrial.isHidden = true
            if buttonCounter == 1 {
                btnWrittenSummaries.isSelected = true
                lblWrittenSummaries.textColor = Config().AppOrangeColor
                imgWrittenSummaries.image = #imageLiteral(resourceName: "radio1")
                
                btnAudioVideoSummaries.isSelected = false
                lblAudioVideoSummaries.textColor = UIColor.lightGray
                imgAudioVideoSummaries.image = #imageLiteral(resourceName: "radio")
                
                btnAudioSummaries.isSelected = false
                lblAudioSummaries.textColor = UIColor.lightGray
                imgAudioSummaries.image = #imageLiteral(resourceName: "radio")
            } else if buttonCounter == 3 {
                btnAudioVideoSummaries.isSelected = true
                lblAudioVideoSummaries.textColor = Config().AppOrangeColor
                imgAudioVideoSummaries.image = #imageLiteral(resourceName: "radio1")
                
                btnWrittenSummaries.isSelected = false
                lblWrittenSummaries.textColor = UIColor.lightGray
                imgWrittenSummaries.image = #imageLiteral(resourceName: "radio")
                
                btnAudioSummaries.isSelected = false
                lblAudioSummaries.textColor = UIColor.lightGray
                imgAudioSummaries.image = #imageLiteral(resourceName: "radio")
            } else if buttonCounter == 2 {
                btnAudioSummaries.isSelected = true
                lblAudioSummaries.textColor = Config().AppOrangeColor
                imgAudioSummaries.image = #imageLiteral(resourceName: "radio1")
                
                btnWrittenSummaries.isSelected = false
                lblWrittenSummaries.textColor = UIColor.lightGray
                imgWrittenSummaries.image = #imageLiteral(resourceName: "radio")
                
                btnAudioVideoSummaries.isSelected = false
                lblAudioVideoSummaries.textColor = UIColor.lightGray
                imgAudioVideoSummaries.image = #imageLiteral(resourceName: "radio")
            }
            self.choosePlanColletionView.reloadData()
        } else {
            self.buttonCounter = 1
            self.selectedIndex = 0
            self.choosePlanColletionView.reloadData()
        }
    }
    
   
    // MARK: - ViewWillAppear
    
    override func viewWillAppear(_ animated: Bool) {
        getMembershipPlanDetails(planId: planId)
    }
    
    // MARK: - NavigationBar Buttons
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - IBAction
    @IBAction func btnFreeTrial(_ sender: UIButton) {
        self.freeTrial()
    }
    
    @IBAction func btnWrittenSummaries(_ sender: UIButton) {
        if sender.tag == 101{
            buttonCounter = 1
            btnWrittenSummaries.isSelected = true
            lblWrittenSummaries.textColor = Config().AppOrangeColor
            imgWrittenSummaries.image = #imageLiteral(resourceName: "radio1")
            
            btnAudioVideoSummaries.isSelected = false
            lblAudioVideoSummaries.textColor = UIColor.lightGray
            imgAudioVideoSummaries.image = #imageLiteral(resourceName: "radio")
            
            btnAudioSummaries.isSelected = false
            lblAudioSummaries.textColor = UIColor.lightGray
            imgAudioSummaries.image = #imageLiteral(resourceName: "radio")
            self.planType = "1"
        } else if sender.tag == 102{
            buttonCounter = 3
            
            btnAudioVideoSummaries.isSelected = true
            lblAudioVideoSummaries.textColor = Config().AppOrangeColor
            imgAudioVideoSummaries.image = #imageLiteral(resourceName: "radio1")
            
            btnWrittenSummaries.isSelected = false
            lblWrittenSummaries.textColor = UIColor.lightGray
            imgWrittenSummaries.image = #imageLiteral(resourceName: "radio")
            
            btnAudioSummaries.isSelected = false
            lblAudioSummaries.textColor = UIColor.lightGray
            imgAudioSummaries.image = #imageLiteral(resourceName: "radio")
            self.planType = "2"
            
        } else if sender.tag == 103 {
            buttonCounter = 2
            
            btnAudioSummaries.isSelected = true
            lblAudioSummaries.textColor = Config().AppOrangeColor
            imgAudioSummaries.image = #imageLiteral(resourceName: "radio1")
            
            btnWrittenSummaries.isSelected = false
            lblWrittenSummaries.textColor = UIColor.lightGray
            imgWrittenSummaries.image = #imageLiteral(resourceName: "radio")
            
            btnAudioVideoSummaries.isSelected = false
            lblAudioVideoSummaries.textColor = UIColor.lightGray
            imgAudioVideoSummaries.image = #imageLiteral(resourceName: "radio")
            self.planType = "3"
            
        }
        self.choosePlanColletionView.reloadData()
    }
    
    @IBAction func btnMakePayment_DidSelect(_ sender: UIButton) {
        self.SelectMembershipPlan()
    }
    
    // MARK: - UITableViewDelegate
    //    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //        return self.plan_description_Array.count
    //    }
    
    //    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //        let cell = tableView.dequeueReusableCell(withIdentifier: "PlanCell", for: indexPath) as! PlanCell
    //        let dict = DataManager.getVal(self.plan_description_Array[indexPath.row]) as! NSDictionary
    //
    //        let monthly_description = DataManager.getVal(dict["description"]) as! String
    //        cell.lblDescription.text = monthly_description.htmlToString
    //        print(monthly_description)
    //
    //        return cell
    //    }
    
    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //
    //
    //    }
    // MARK: - UICollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChoosePlanCell", for: indexPath) as! ChoosePlanCell
        if arrPriceDiscount.count != 0 {
        let dict = DataManager.getVal(self.arrPriceDiscount[indexPath.row]) as! [String:Any]
        //        let monthly_price = DataManager.getVal(dict["price"]) as! String
                let Discount = DataManager.getVal(dict["discount"]) as! String
        //
        //        cell.lblPrice.text = monthly_price
                cell.lblDiscount.text = "Save \(Discount)"
        }
        if arrSummaryPlan.count != 0 {
            //cell.lblDiscount.text = String(arrDiscount[indexPath.row])
            if buttonCounter == 1 {
                cell.lblPrice.text =  String("$\(arrSummaryPlan [indexPath.row])")
            } else  if buttonCounter == 2{
                cell.lblPrice.text =  String("$\(arrAudioPlan [indexPath.row])")
            }else  if buttonCounter == 3{
                cell.lblPrice.text =  String("$\(arrAudioVideoPlan [indexPath.row])")
            }
        }
        
        cell.lblPlanType.text = arrPlans[indexPath.row]
        if self.selectedIndex == indexPath.row{
            cell.btnPlanType.backgroundColor = #colorLiteral(red: 0.9959338307, green: 0.6004624963, blue: 0.1465278566, alpha: 1)
            cell.lblCurrency.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cell.lblPrice.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cell.lblPlanType.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cell.lblDiscount.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            cell.imgTriangle.isHidden = false
            //cell.img.setImage(UIImage(named:"check-box"), for: .normal)
        } else {
            // cell.CheckButton.setImage(UIImage(named:"uncheck"), for: .normal)
            cell.btnPlanType.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
            cell.lblCurrency.textColor = #colorLiteral(red: 0.9959338307, green: 0.6004624963, blue: 0.1465278566, alpha: 1)
            cell.lblPrice.textColor = #colorLiteral(red: 0.9959338307, green: 0.6004624963, blue: 0.1465278566, alpha: 1)
            cell.lblPlanType.textColor = #colorLiteral(red: 0.9959338307, green: 0.6004624963, blue: 0.1465278566, alpha: 1)
            cell.btnPlanType.setImage(UIImage.init(named: "Rectangle-1"), for: .selected)
            cell.lblDiscount.textColor = #colorLiteral(red: 0.9959338307, green: 0.6004624963, blue: 0.1465278566, alpha: 1)
            cell.imgTriangle.isHidden = true
        }
        cell.layer.cornerRadius = 4
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
        self.choosePlanColletionView.reloadData()
        self.updateDetails()
        //self.tblPlanDetails.reloadData()
    }
    func updateDetails () {
        if let summaryPrice = dictPlanDetails["summary_only_price"] as? Int {
            self.arrSummaryPlan = mul(val: summaryPrice)
        }
        if let audioPrice = dictPlanDetails["summary_audio_price"] as? Int{
            self.arrAudioPlan = mul(val: audioPrice)
        }
        if let audioVideoPrice = dictPlanDetails["summary_audio_video_price"] as? Int{
            self.arrAudioVideoPlan = mul(val: audioVideoPrice)
        }
        if let strDes = dictPlanDetails["subscription_title"] as? String{
            self.lblPlanName.text = strDes
        }
        if selectedIndex == 0 {
            if let strDes = dictPlanDetails["monthly_description"] as? String{
                // let url = URL(string: "http://i.devtechnosys.tech:8083/holyreads/pages/mobile_subscription_description")!
                //let requestObj = URLRequest(url: url)
                //webView.loadRequest(requestObj)
                // let desctiption =  strDes.htmlToString
                let trimmed = strDes.replacingOccurrences(of: "\r\n", with: "")
                let fullNameArr = trimmed.components(separatedBy: ".")
                var s = [String]()
                for i in 0..<fullNameArr.count-1 {
                    s.append(fullNameArr[i])
                }
                self.lblPlanDetails.attributedText = addBulletToString(stringList: s, font: UIFont.systemFont(ofSize: 15), bullet: "●")
                self.planDuration = "30"
            }
        } else if selectedIndex == 1 {
            if let strDes = dictPlanDetails["quarterly_description"] as? String{
                let trimmed = strDes.replacingOccurrences(of: "\r\n", with: "")
                let fullNameArr = trimmed.components(separatedBy: ".")
                var s = [String]()
                
                for i in 0..<fullNameArr.count-1 {
                    s.append(fullNameArr[i])
                }
                self.lblPlanDetails.attributedText = addBulletToString(stringList: s, font: UIFont.systemFont(ofSize: 15), bullet: "●")
                self.planDuration = "90"
            }
        } else if selectedIndex == 2 {
            if let strDes = dictPlanDetails["anually_description"] as? String{
                let trimmed = strDes.replacingOccurrences(of: "\r\n", with: "")
                let fullNameArr = trimmed.components(separatedBy: ".")
                var s = [String]()
                
                for i in 0..<fullNameArr.count-1 {
                    s.append(fullNameArr[i])
                }
                self.lblPlanDetails.attributedText = addBulletToString(stringList: s, font: UIFont.systemFont(ofSize: 15), bullet: "●")
                self.planDuration = "365"
            }
        }
        self.choosePlanColletionView.reloadData()
    }
    
    //MARK:- API Calling (getPerticularSubscriptionData)
    func getMembershipPlanDetails (planId: Int) {
        self.view.endEditing(true)
        self.showHud()
        let idPlan = DataManager.getVal(planId)
        let parameterDictionary = NSMutableDictionary()
        parameterDictionary.setValue(idPlan, forKey: "subscription_id")
        print(parameterDictionary)
        
        let methodName = "getPerticularSubscriptionData"
        
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
            
            if status == "1" {
                if  let response = DataManager.getVal(responseData?["data"]) as? [String:Any]{
                    self.dictPlanDetails = response
                    self.arrPriceDiscount = DataManager.getVal(self.dictPlanDetails["price"]) as! [[String:Any]]
                    self.updateDetails()
                    self.choosePlanColletionView.reloadData()
                }
            }else{
                self.view.makeToast(message: message)
            }
            self.clearHud()
        }
    }
    
    //MARK:- API Calling (SelectMembershipPlan)
    
    func SelectMembershipPlan() {
        //      "subscription_id" : "5",
        //        "user_id" : "315",
        //        "subscription_details" : "3",
        //        "duration" : 365
        self.view.endEditing(true)
        self.showHud()
        let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        
        let parameterDictionary = NSMutableDictionary()
        parameterDictionary.setObject(DataManager.getVal(buttonCounter), forKey: "subscription_details" as NSCopying)
        parameterDictionary.setObject(DataManager.getVal(String(planId)), forKey: "subscription_id" as NSCopying)
        parameterDictionary.setValue(user_id, forKey: "user_id")
       // parameterDictionary.setValue(buttonCounter, forKey: "subscription_details")
        parameterDictionary.setValue(planDuration, forKey: "duration")
        
        print(parameterDictionary)
        
        let methodName = "chooseSubscription"
        
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
            
            if status == "1" {
                 if self.isFrom == "MySubscriptionVC" {
                    let normalAlert = UIAlertController(title: "Holy reads", message: message, preferredStyle: .alert)
                    normalAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        self.appDelegate.showMain()
                    }))
                    self.present(normalAlert, animated: true, completion: nil)
                    //self.navigationController?.popViewController(animated: true)
                } else  if self.isFrom == "Login" {
                    let normalAlert = UIAlertController(title: "Holy reads", message: message, preferredStyle: .alert)
                    normalAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        Config().AppUserDefaults.set(true, forKey: "isCurrentUser")
                        self.appDelegate.showMain()
                    }))
                    self.present(normalAlert, animated: true, completion: nil)
             
                } else  {
                    let normalAlert = UIAlertController(title: "Holy reads", message: message, preferredStyle: .alert)
                    normalAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        self.appDelegate.showFirstPage()
                    }))
                    self.present(normalAlert, animated: true, completion: nil)
                 }
            }  else {
                self.view.makeToast(message: message)
            }
            self.clearHud()
        }
    }
    
    func freeTrial() {
        self.view.endEditing(true)
        self.showHud()
        
        let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        let parameterDictionary = NSMutableDictionary()
        parameterDictionary.setValue(user_id, forKey: "user_id")
        print(parameterDictionary)
        
        let methodName = "freetrial"
        
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
            
            if status == "1" {
                self.appDelegate.showFirstPage()
            } else{
                self.view.makeToast(message: message)
            }
            self.clearHud()
        }
    }
    
    
    
    
    
}

