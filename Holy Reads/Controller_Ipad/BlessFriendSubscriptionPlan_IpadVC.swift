//
//  BlessFriendSubscriptionPlan_IpadVC.swift
//  Holy Reads
//
//  Created by Ashish Soni on 20/07/20.
//  Copyright © 2020 Ajeet singh Rawat. All rights reserved.
//

import UIKit
import WebKit
@objc protocol PlanDelegates {
    func updatePlanData(subsciptionDetails: Int, planDuration: String)
    
}

class BlessFriendSubscriptionPlan_IpadVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource  {
    
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
    
    var isFrom = ""
    var planId = String()
    var dictPlanDetails = [String:Any]()
    var selectedIndex = Int()
    var arrPlans = ["Quaterly","Monthly", "Annually"]
    var planType = "1"
    var planDuration = ""
    var plan_description_Array = [Any]()
    var arrSummaryPlan = [Int]()
    var arrAudioPlan = [Int]()
    var arrAudioVideoPlan = [Int]()
    var arrPriceDiscount = [[String:Any]]()
    var buttonCounter = 1
    
    weak var delegate: PlanDelegates?
    
    
    // MARK: - ViewLifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let ChoosePlanLiberaryLayOut = UICollectionViewFlowLayout()
        ChoosePlanLiberaryLayOut.itemSize = CGSize(width: screenWidth/3-20, height: 140)
        ChoosePlanLiberaryLayOut.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        ChoosePlanLiberaryLayOut.minimumInteritemSpacing = 0
        ChoosePlanLiberaryLayOut.minimumLineSpacing = 15
        ChoosePlanLiberaryLayOut.scrollDirection = .horizontal
        
        choosePlanColletionView.collectionViewLayout = ChoosePlanLiberaryLayOut
    }
    
    // MARK: - ViewWillAppear
    
    override func viewWillAppear(_ animated: Bool) {
        getMembershipPlanDetails(planId: "1")
    }
    
    
    // MARK: - NavigationBar Buttons
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - IBAction
    
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
            
        } else if sender.tag == 103{
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
        if buttonCounter == 0 {
            self.view.makeToast(message: "Please select plan details")
            return
        } else if planDuration == ""{
            self.view.makeToast(message: "Please select plan duration")
            return
        }
        self.delegate?.updatePlanData(subsciptionDetails: buttonCounter, planDuration: planDuration)
        self.navigationController?.popViewController(animated: true)
        
        
    }
    
    
    // MARK: - UICollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChossePlan_IpadCell", for: indexPath) as! ChossePlan_IpadCell
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
            cell.lblDiscount.textColor = #colorLiteral(red: 0.9959338307, green: 0.6004624963, blue: 0.1465278566, alpha: 1)
            cell.btnPlanType.setImage(UIImage.init(named: "Rectangle-1"), for: .selected)
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
        if let summaryPrice = dictPlanDetails["summary_only_price"] as? Int{
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
            if let strDes = dictPlanDetails["quarterly_description"] as? String{
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
            if let strDes = dictPlanDetails["monthly_description"] as? String{
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
    
    //    func updateDetails() {
    //        if let strDes = dictPlanDetails["subscription_title"] as? String{
    //            self.lblPlanName.text = strDes
    //        }
    //
    //        if selectedIndex == 0 {
    //            if let strDes = dictPlanDetails["quarterly_description"] as? String{
    //                // let url = URL(string: "http://i.devtechnosys.tech:8083/holyreads/pages/mobile_subscription_description")!
    //                //let requestObj = URLRequest(url: url)
    //                //webView.loadRequest(requestObj)
    //                // let desctiption =  strDes.htmlToString
    //
    //                let trimmed = strDes.replacingOccurrences(of: "\r\n", with: "")
    //                let fullNameArr = trimmed.components(separatedBy: ".")
    //                var s = [String]()
    //                for i in 0..<fullNameArr.count-1 {
    //                    s.append(fullNameArr[i])
    //                }
    //                self.lblPlanDetails.attributedText = self.addBulletToString(stringList: s, font: UIFont.systemFont(ofSize: 15), bullet: "●")
    //                self.planDuration = "90"
    //
    //            }
    //        } else if selectedIndex == 1{
    //            if let strDes = dictPlanDetails["monthly_description"] as? String{
    //                let trimmed = strDes.replacingOccurrences(of: "\r\n", with: "")
    //                let fullNameArr = trimmed.components(separatedBy: ".")
    //                var s = [String]()
    //
    //                for i in 0..<fullNameArr.count-1 {
    //                    s.append(fullNameArr[i])
    //                }
    //                self.lblPlanDetails.attributedText = addBulletToString(stringList: s, font: UIFont.systemFont(ofSize: 15), bullet: "●")
    //                self.planDuration = "30"
    //            }
    //
    //        } else if selectedIndex == 2{
    //            if let strDes = dictPlanDetails["anually_description"] as? String{
    //                let trimmed = strDes.replacingOccurrences(of: "\r\n", with: "")
    //                let fullNameArr = trimmed.components(separatedBy: ".")
    //                var s = [String]()
    //
    //
    //                for i in 0..<fullNameArr.count-1 {
    //                    s.append(fullNameArr[i])
    //                }
    //                self.lblPlanDetails.attributedText = self.addBulletToString(stringList: s, font: UIFont.systemFont(ofSize: 15), bullet: "●")
    //                self.planDuration = "365"
    //            }
    //        }
    //    }
    
    //MARK:- API Calling (getPerticularSubscriptionData)
    func getMembershipPlanDetails (planId: String) {
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
    
}











