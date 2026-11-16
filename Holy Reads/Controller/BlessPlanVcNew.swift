//
//  BlessPlanVcNew.swift
//  Holy Reads
//
//  Created by MAC-25 on 09/11/20.
//  Copyright © 2020 Ajeet singh Rawat. All rights reserved.
//

import UIKit
import WebKit
class BlessPlanVcNew: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {

  
    @IBOutlet weak var planCollectionView: UICollectionView!
    var planArray = NSMutableArray()
    var isFrom = ""
    var buttonCounter = NSMutableArray()
    @IBOutlet weak var selectPlanCollection: UICollectionView!
    @IBOutlet weak var selectplanBtn: UIButton!
    @IBOutlet weak var desLbl: UILabel!
    var selectedIndex = Int()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectplanBtn.layer.cornerRadius = 20
//        let LibariryLayOut = UICollectionViewFlowLayout()
//        LibariryLayOut.itemSize = CGSize(width: screenWidth, height: screenHeight-100)
//        LibariryLayOut.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 10)
//        LibariryLayOut.minimumInteritemSpacing = 0
//        LibariryLayOut.minimumLineSpacing = 0
//        LibariryLayOut.scrollDirection = .vertical
//
//        planCollectionView.collectionViewLayout = LibariryLayOut
        
        let LibariryLayOut = UICollectionViewFlowLayout()
        LibariryLayOut.itemSize = CGSize(width: screenWidth/3, height: 139)
        LibariryLayOut.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 5)
        LibariryLayOut.minimumInteritemSpacing = 0
        LibariryLayOut.minimumLineSpacing = 5
        LibariryLayOut.scrollDirection = .horizontal

        selectPlanCollection.collectionViewLayout = LibariryLayOut
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
       self.getHomeData()
    }
    
    @IBAction func selectplanbuttonAction(_ sender: Any) {
//        if buttonCounter.count == 0 {
//            self.view.makeToast(message: "Please choose plan")
//        }else {
            self.navigationController?.popViewController(animated: true)

        //}
    }
    func getHomeData() {
        self.showHud()
        let parameterDictionary = NSMutableDictionary()
        let methodName = "getAllSubscricptions"
        //let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        //parameterDictionary.setValue(user_id, forKey: "user_id")
        
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
           
            
            if status == "1" {
                self.planArray = DataManager.getVal(responseData?["data"]) as! NSMutableArray
                self.planCollectionView.reloadData()
                self.selectPlanCollection.reloadData()
            }
             else{
                self.view.makeToast(message: message)
             }
            self.clearHud()
        }
    }


    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.planCollectionView {
            return 0
        }else {
            return planArray.count
        }
      
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == planCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! BlessPlanVcNewCell
            cell.pageContro.numberOfPages = 3
            cell.pageContro.currentPage = indexPath.item
            cell.pageContro.isHidden = false
            var dict = NSDictionary()
            dict = planArray.object(at: indexPath.item) as! NSDictionary
            var idnew:Int!
            idnew = dict.value(forKey: "id") as? Int
            var price:String!
            price = dict.value(forKey: "price") as? String
            cell.monthLbl.text = dict.value(forKey: "title") as? String
            cell.priceLbl.setTitle("$" + price, for: .normal)
           // cell.descwebview.loadHTMLString( (dict.value(forKey: "description") as? String)!, baseURL: nil)
            cell.buyBtn.setTitle("SELECT PLAN", for: .normal)
            cell.buyBtn.tag = indexPath.item
            cell.buyBtn.addTarget(self, action: #selector(HandleBuyBtnAction(_:)), for: .touchUpInside)
            
            if self.buttonCounter.contains(idnew!){
                cell.selectBtn.setImage(UIImage(named:"check"), for: .normal)
            }else{
                cell.selectBtn.setImage(UIImage(named:"box"), for: .normal)
            }
            
            
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChoosePlanCell", for: indexPath) as! ChoosePlanCell
            var dict = NSDictionary()
            dict = planArray.object(at: indexPath.item) as! NSDictionary
            var price:String!
            price = dict.value(forKey: "price") as? String
            cell.lblPrice.text = "$" + price
            cell.lblPlanType.text = dict.value(forKey: "title") as? String
            var plantype:String!
            plantype = dict.value(forKey: "title") as? String
            var idnew:Int!
            idnew = dict.value(forKey: "id") as? Int
            var discount:Int!
            discount = dict.value(forKey: "discount") as? Int
            var newdis:String!
            if discount == 0 {
                newdis = ""
                cell.lblDiscount.text = newdis
            }else {
                newdis = String(discount)
                cell.lblDiscount.text = "Save " + newdis + "%"
            }
//            var newdis:String!
//            newdis = String(discount)
//            cell.lblDiscount.text = "Save " + newdis + "%"
            
            if self.selectedIndex == indexPath.row{
                cell.btnPlanType.backgroundColor = #colorLiteral(red: 0.9959338307, green: 0.6004624963, blue: 0.1465278566, alpha: 1)
                cell.lblCurrency.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                cell.lblPrice.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                cell.lblPlanType.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                cell.lblDiscount.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                cell.imgTriangle.isHidden = false
                if let description =  dict.value(forKey: "description") as? String {
                    // webView.loadHTMLString(description, baseURL: nil)
                    var trimmed:String!
                    if description.contains("\r\n") {
                         trimmed = description.replacingOccurrences(of: "\r\n", with: "")
                    }else {
                         trimmed = description.replacingOccurrences(of: "\n", with: "")
                    }
                    let trimmed2 = trimmed.replacingOccurrences(of: "<ul><li>", with: "")
                    let trimmed23 = trimmed2.replacingOccurrences(of: "<ul> <li>", with: "")
                    let trimmed1 = trimmed23.replacingOccurrences(of: "</li> <li>", with: "")
                    let trimmed3 = trimmed1.replacingOccurrences(of: "</li><li>", with: "")
                    let trimmed4 = trimmed3.replacingOccurrences(of: "</strong>", with: "")
                    let trimmed5 = trimmed4.replacingOccurrences(of: "<strong>&nbsp;", with: " ")
                    let fullNameArr = trimmed5.components(separatedBy: ".")
                    var s = [String]()
                    
                    for i in 0..<fullNameArr.count-1 {
                        s.append(fullNameArr[i])
                    }
                    var plannew:String!
                    if plantype == "Monthly" {
                        plannew = "one month"
                    }else if plantype == "6-Month" {
                        plannew = "six months"
                    }else{
                        plannew = "one year"
                    }
                    let defaults = UserDefaults.standard
                    defaults.setValue(plannew, forKey: "Tl")
                    defaults.synchronize()
                    self.desLbl.attributedText = addBulletToStringNew(stringList: s, font: UIFont.systemFont(ofSize: 15), bullet: "●")
                    
                }
                //self.Newwebview.loadHTMLString((dict.value(forKey: "description") as? String)!, baseURL: nil)
                let defaults = UserDefaults.standard
                defaults.setValue(idnew, forKey: "SubId")
                defaults.synchronize()
                
            } else {
                cell.btnPlanType.backgroundColor = #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1)
                cell.lblCurrency.textColor = #colorLiteral(red: 0.9959338307, green: 0.6004624963, blue: 0.1465278566, alpha: 1)
                cell.lblPrice.textColor = #colorLiteral(red: 0.9959338307, green: 0.6004624963, blue: 0.1465278566, alpha: 1)
                cell.lblPlanType.textColor = #colorLiteral(red: 0.9959338307, green: 0.6004624963, blue: 0.1465278566, alpha: 1)
                cell.lblDiscount.textColor = .red
                cell.btnPlanType.setImage(UIImage.init(named: "Rectangle-1"), for: .selected)
                cell.imgTriangle.isHidden = true
            }
            
            if indexPath.row == 2 {
                cell.starImg.isHidden = false
            }else {
                cell.starImg.isHidden = true
            }
            return cell
        }
       
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
        var dict = NSDictionary()
        dict = planArray.object(at: indexPath.item) as! NSDictionary
        var plantype:String!
        plantype = dict.value(forKey: "title") as? String
        var idnew:Int!
        idnew = dict.value(forKey: "id") as? Int

        if self.buttonCounter.contains(idnew!){
           self.buttonCounter.remove(idnew!)
        }else {
           self.buttonCounter.removeAllObjects()
           self.buttonCounter.add(idnew!)
           let defaults = UserDefaults.standard
           defaults.setValue(idnew, forKey: "SubId")
           defaults.synchronize()
        }
      //  self.Newwebview.loadHTMLString((dict.value(forKey: "description") as? String)!, baseURL: nil)
        if let description =  dict.value(forKey: "description") as? String {
            // webView.loadHTMLString(description, baseURL: nil)
            var trimmed:String!
            if description.contains("\r\n") {
                 trimmed = description.replacingOccurrences(of: "\r\n", with: "")
            }else {
                 trimmed = description.replacingOccurrences(of: "\n", with: "")
            }
            let trimmed2 = trimmed.replacingOccurrences(of: "<ul><li>", with: "")
            let trimmed23 = trimmed2.replacingOccurrences(of: "<ul> <li>", with: "")
            let trimmed1 = trimmed23.replacingOccurrences(of: "</li> <li>", with: "")
            let trimmed3 = trimmed1.replacingOccurrences(of: "</li><li>", with: "")
            let trimmed4 = trimmed3.replacingOccurrences(of: "</strong>", with: "")
            let trimmed5 = trimmed4.replacingOccurrences(of: "<strong>&nbsp;", with: " ")
            let fullNameArr = trimmed5.components(separatedBy: ".")
            var s = [String]()
            
            for i in 0..<fullNameArr.count-1 {
                s.append(fullNameArr[i])
            }
            var plannew:String!
            if plantype == "Monthly" {
                plannew = "one month"
            }else if plantype == "6-Month" {
                plannew = "six months"
            }else{
                plannew = "one year"
            }
            let defaults = UserDefaults.standard
            defaults.setValue(plannew, forKey: "Tl")
            defaults.synchronize()
            self.desLbl.attributedText = addBulletToStringNew(stringList: s, font: UIFont.systemFont(ofSize: 15), bullet: "●")
            
        }
        self.selectPlanCollection.reloadData()
    }
    
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        var dict = NSDictionary()
//        dict = planArray.object(at: indexPath.item) as! NSDictionary
//        var idnew:Int!
//        idnew = dict.value(forKey: "id") as? Int
//
//        if self.buttonCounter.contains(idnew!){
//            self.buttonCounter.remove(idnew!)
//        }else {
//            self.buttonCounter.removeAllObjects()
//            self.buttonCounter.add(idnew!)
//            let defaults = UserDefaults.standard
//            defaults.setValue(idnew, forKey: "SubId")
//            defaults.synchronize()
//        }
//        self.planCollectionView.reloadData()
//    }
    
    @objc func HandleBuyBtnAction(_ sender:UIButton) {
        if buttonCounter.count == 0 {
            self.view.makeToast(message: "Please choose plan")
        }else {
            self.navigationController?.popViewController(animated: true)

        }
//        var dict = NSDictionary()
//        dict = planArray.object(at: sender.tag) as! NSDictionary
//        var subid:Int!
//        subid = dict.value(forKey: "id") as? Int
//        let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
//        self.PurchasePlanAPI(UserID: user_id, SubscriptionID: String(subid))
    }
    
    
    func PurchasePlanAPI(UserID:String!,SubscriptionID:String!) {
        let user_email = DataManager.getVal(Config().AppUserDefaults.value(forKey: "BlessEmail")) as! String
        let user_name = DataManager.getVal(Config().AppUserDefaults.value(forKey: "BlessUser")) as! String
        let user_password = DataManager.getVal(Config().AppUserDefaults.value(forKey: "BlessPassword")) as! String
        self.showHud()
        let parameterDictionary = NSMutableDictionary()
        let methodName = "blessafriend"
        parameterDictionary.setValue(UserID, forKey: "user_id")
        parameterDictionary.setValue(SubscriptionID, forKey: "subscription_id")
        parameterDictionary.setValue(user_name, forKey: "username")
        parameterDictionary.setValue(user_email, forKey: "email")
        parameterDictionary.setValue(user_password, forKey: "password")

        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
           
            
            if status == "1" {
                var dict = NSDictionary()
                dict = DataManager.getVal(responseData?["data"]) as! NSDictionary
                print(dict)
                var userID:Int!
                userID = dict.value(forKey: "user_id") as? Int
                let defaults = UserDefaults.standard
                defaults.setValue(userID, forKey: "user_id")
                defaults.synchronize()
                let alert = UIAlertController(title: "Holy Reads", message: message, preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
                    let objVC = self.storyboard?.instantiateViewController(withIdentifier: "tabbar") as? UITabBarController
                    self.navigationController?.pushViewController(objVC!, animated: true)
                    Config().AppUserDefaults.set(true, forKey: "isCurrentUser")
                }))
                self.present(alert, animated: true, completion: nil)
                
            }
            else{
                self.view.makeToast(message: message)
             }
            self.clearHud()
        }
    }

    
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! BlessPlanVcNewCell
//        cell.pageContro.currentPage = indexPath.item
//
//    }
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height-150)
//    }
    
    @IBAction func baclBtnAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

}
