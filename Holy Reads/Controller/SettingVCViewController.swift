//
//  SettingVCViewController.swift
//  Holy Reads
//
//  Created by mac-14 on 03/09/19.
//  Copyright © 2019 Ajeet singh Rawat. All rights reserved.
//

import UIKit
import SDWebImage
import EvernoteSDK
import PMAlertController
import AdSupport
import CoreData
class SettingVCViewController: UIViewController {
    
    //MARK:- Outlets
    @IBOutlet weak var tblSetting: UITableView!
    @IBOutlet weak var txtUsername: UILabel!
    @IBOutlet weak var txtEmail: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    
    

    let identifierManager = ASIdentifierManager.shared()
    //MARK:- Variables
    var dicUserDetails = [String:Any]()
    var arrSyncHighlights = [[String:Any]]()

     var arrTitles = [["title": "Personal Information", "expendable": false, "leftIcon":"Personal Information", "rightButton":""],
                     ["title": "Change Password", "expendable": false,"leftIcon":"Change password", "rightButton":""],
                     ["title": "My Subscription", "expendable": false,"leftIcon":"My Subscription", "rightButton":""],
                     ["title": "Bless a Friend", "expendable": false,"leftIcon":"Bless a Friend", "rightButton":""],
                     ["title": "My Downloads", "expendable": false,"leftIcon":"My Downloads", "rightButton":""],
                   //  ["title": "Notification Channels", "expendable": false,"leftIcon":"Notification", "rightButton":""],
                     ["title": "Notification Channels", "expendable": true, "isExpended": false,"leftIcon":"Notification", "rightButton":"down","expendData": ["Email Notification Settings", "In-App Notification Settings"]],
                     ["title": "Support", "expendable": true, "isExpended": false,"leftIcon":"Support", "rightButton":"down","expendData": ["FAQ", "Contact Us", "Privacy Policy", "Submit Feedback"]],
                     ["title": "Notification", "expendable": false,"leftIcon":"Notification", "rightButton":""],
                     ["title": "Logout", "expendable": false,"leftIcon":"logout", "rightButton":""],
                     ["title": "Kindle Integration", "expendable": false,"leftIcon":"", "rightButton":""],
                     ["title": "EverNote Integration", "expendable": false,"leftIcon":"", "rightButton":""]
    ]
    var arrExpandImg = [ "FAQ","Contact us","Privacy Policy","Submit Feedback"]
    var arrExpandImg1 = [ "Notification","Notification"]
    var notificationStatus = ""
    var exstr:String!
    
    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    // MARK: - ViewWillAppear

    override func viewWillAppear(_ animated: Bool) {
        //self.showUserData()
        //self.performSelector(inBackground: #selector(notificationApi), with: nil)
        self.getProfileData()
        self.getSyncHighlight()
        
        
        let freests = UserDefaults.standard.value(forKey: "FREESTS") as? String
        let substs = UserDefaults.standard.value(forKey: "SUBSTS") as? String
    
        if substs == "1" {
            arrTitles = [["title": "Personal Information", "expendable": false, "leftIcon":"Personal Information", "rightButton":""],
                            ["title": "Change Password", "expendable": false,"leftIcon":"Change password", "rightButton":""],
                            ["title": "My Subscription", "expendable": false,"leftIcon":"My Subscription", "rightButton":""],
                            ["title": "Bless a Friend", "expendable": false,"leftIcon":"Bless a Friend", "rightButton":""],
                            ["title": "My Downloads", "expendable": false,"leftIcon":"My Downloads", "rightButton":""],
//                            ["title": "Notification Channels", "expendable": false,"leftIcon":"Notification", "rightButton":""],
                            ["title": "Notification Channels", "expendable": true, "isExpended": false,"leftIcon":"Notification", "rightButton":"down","expendData": ["Email Notification Settings", "In-App Notification Settings"]],
                            ["title": "Support", "expendable": true, "isExpended": false,"leftIcon":"Support", "rightButton":"down","expendData": ["FAQ", "Contact Us", "Privacy Policy", "Submit Feedback"]],
                            ["title": "Notification", "expendable": false,"leftIcon":"Notification", "rightButton":""],
                            ["title": "Logout", "expendable": false,"leftIcon":"logout", "rightButton":""],
                            ["title": "Kindle Integration", "expendable": false,"leftIcon":"", "rightButton":""],
                            ["title": "EverNote Integration", "expendable": false,"leftIcon":"", "rightButton":""]
           ]
        }else {
            if freests == "1" {
                arrTitles = [["title": "Personal Information", "expendable": false, "leftIcon":"Personal Information", "rightButton":""],
                                ["title": "Change Password", "expendable": false,"leftIcon":"Change password", "rightButton":""],
                                ["title": "Upgrade Subscription", "expendable": false,"leftIcon":"My Subscription", "rightButton":""],
                                ["title": "Bless a Friend", "expendable": false,"leftIcon":"Bless a Friend", "rightButton":""],
                                ["title": "My Downloads", "expendable": false,"leftIcon":"My Downloads", "rightButton":""],
//                                ["title": "Notification Channels", "expendable": false,"leftIcon":"Notification", "rightButton":""],
                                ["title": "Notification Channels", "expendable": true, "isExpended": false,"leftIcon":"Notification", "rightButton":"down","expendData": ["Email Notification Settings", "In-App Notification Settings"]],
                                ["title": "Support", "expendable": true, "isExpended": false,"leftIcon":"Support", "rightButton":"down","expendData": ["FAQ", "Contact Us", "Privacy Policy", "Submit Feedback"]],
                                ["title": "Notification", "expendable": false,"leftIcon":"Notification", "rightButton":""],
                                ["title": "Logout", "expendable": false,"leftIcon":"logout", "rightButton":""],
                                ["title": "Kindle Integration", "expendable": false,"leftIcon":"", "rightButton":""],
                                ["title": "EverNote Integration", "expendable": false,"leftIcon":"", "rightButton":""]
               ]
            }else {
                arrTitles = [["title": "Personal Information", "expendable": false, "leftIcon":"Personal Information", "rightButton":""],
                                ["title": "Change Password", "expendable": false,"leftIcon":"Change password", "rightButton":""],
                                ["title": "Upgrade Subscription", "expendable": false,"leftIcon":"My Subscription", "rightButton":""],
                                ["title": "Bless a Friend", "expendable": false,"leftIcon":"Bless a Friend", "rightButton":""],
                                ["title": "My Downloads", "expendable": false,"leftIcon":"My Downloads", "rightButton":""],
//                                ["title": "Notification Channels", "expendable": false,"leftIcon":"Notification", "rightButton":""],
                                ["title": "Notification Channels", "expendable": true, "isExpended": false,"leftIcon":"Notification", "rightButton":"down","expendData": ["Email Notification Settings", "In-App Notification Settings"]],
                                ["title": "Support", "expendable": true, "isExpended": false,"leftIcon":"Support", "rightButton":"down","expendData": ["FAQ", "Contact Us", "Privacy Policy", "Submit Feedback"]],
                                ["title": "Notification", "expendable": false,"leftIcon":"Notification", "rightButton":""],
                                ["title": "Logout", "expendable": false,"leftIcon":"logout", "rightButton":""],
                                ["title": "Kindle Integration", "expendable": false,"leftIcon":"", "rightButton":""],
                                ["title": "EverNote Integration", "expendable": false,"leftIcon":"", "rightButton":""]
               ]
            }
        }
        
    }
    
    func fetchItemRecordFromDB(){
        let appDelegate =   (UIApplication.shared.delegate) as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let request     =   NSFetchRequest<NSManagedObject>(entityName:"FolioReaderdatabase")
        do{
            var resArr          =   [NSManagedObject]()
            resArr              =   try managedContext.fetch(request)
            print("PharmacyArr = ", resArr)
            print(resArr.count)
            for data in resArr {
                let content = data.value(forKey: "content") as? String
                let note = data.value(forKey: "note") as? String
                let pagenumber = data.value(forKey: "page_number") as? String
                let bookid = data.value(forKey: "book_id") as? String
                let userid = data.value(forKey: "user_id") as? String
                let rangy = data.value(forKey: "rangy") as? String
                let app_id = data.value(forKey: "app_id") as? String
                let typem = data.value(forKey: "type") as? String
                let chaptername = data.value(forKey: "chapter_name") as? String
                self.localdatasave(Content: content, Note: note, PageNumber: pagenumber, BookId: bookid, UserId: userid, Rangy: rangy, App_Id: app_id, Type: typem, ChapterName: chaptername)
            }
            
            UserDefaults.standard.removeObject(forKey: "OF")
            
        }catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func localdatasave(Content:String!,Note:String!,PageNumber:String!,BookId:String!,UserId:String!,Rangy:String!,App_Id:String!,Type:String!,ChapterName:String!) {
        let parameterDictionary = NSMutableDictionary()
        var highlighclass:String!
        if Type == "highlight_yellow" {
            highlighclass = "highlight_span_yellow"
        }else if Type == "highlight_green" {
            highlighclass = "highlight_span_lime"
        }else if Type == "highlight_blue" {
            highlighclass = "highlight_span_blue"
        }else if Type == "highlight_pink" {
            highlighclass = "highlight_span_pink"
        }else if Type == "highlight_underline" {
            highlighclass = "highlight_span_underline"
        }
        var NewPage:Int!
        NewPage = Int(PageNumber)
        parameterDictionary.setValue(DataManager.getVal(App_Id) as! String, forKey: "app_id")
        parameterDictionary.setValue(DataManager.getVal(UserId) as! String, forKey: "user_id")
        parameterDictionary.setValue(DataManager.getVal(NewPage) as! String, forKey: "page_number")
        parameterDictionary.setValue(DataManager.getVal(BookId) as! String, forKey: "book_id")
        parameterDictionary.setValue(DataManager.getVal(Note) as! String, forKey: "note")
        
        parameterDictionary.setValue(DataManager.getVal(Content) as! String, forKey: "selection")
        parameterDictionary.setValue(DataManager.getVal(ChapterName) as! String, forKey: "chapter_name")
        parameterDictionary.setValue(DataManager.getVal(highlighclass) as! String, forKey: "highlight_class")
        parameterDictionary.setValue(DataManager.getVal(Type) as! String, forKey: "android_highlight_type")
        parameterDictionary.setObject(Rangy!, forKey: "rangy" as NSCopying)
        parameterDictionary.setObject("3", forKey: "highlight_form" as NSCopying)
        print(parameterDictionary)
        let methodName = "saveHighlight"
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
        let status  = DataManager.getVal(responseData?["status"]) as! String
        let message  = DataManager.getVal(responseData?["message"]) as! String
        if status == "1" {
            self.saveHighlightNote(HighlightedId: App_Id, HighlightedText: Note)
            print("Successfully Saved the highlighted text.")
        }
        else{
            print("Error in saving the highlighted text.")
        }
    }
    }
    
    func saveHighlightNote(HighlightedId: String, HighlightedText: String) {
       self.view.endEditing(true)
       let parameterDictionary = NSMutableDictionary()
       parameterDictionary.setObject( HighlightedId, forKey: "app_id" as NSCopying)
       parameterDictionary.setObject( HighlightedText, forKey: "text" as NSCopying)
       print(parameterDictionary)
       let methodName = "saveHighlightNote"
       DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
           let status  = DataManager.getVal(responseData?["status"]) as! String
           let message  = DataManager.getVal(responseData?["message"]) as! String
           if status == "1" {
              //self.view.makeToast(message: message)
           } else{
              // self.view.makeToast(message: message)
           }
       }
       
   }
  
//    func showUserData (){
//        let email = DataManager.getVal(Config().AppUserDefaults.value(forKey: "email")) as! String
//        txtEmail.text = email
//        let username = DataManager.getVal(Config().AppUserDefaults.value(forKey: "username")) as! String
//        txtUsername.text = username
//        if let profileImg = DataManager.getVal(Config().AppUserDefaults.value(forKey: "profile_picture")) as? String
//        {
//            self.imgProfile.sd_imageIndicator = SDWebImageActivityIndicator.gray
//            self.imgProfile.startAnimating()
//            let url = URL.init(string: profileImg)
//            self.imgProfile.sd_setImage(with: url, placeholderImage: UIImage.init(named: ""), options: .refreshCached, completed: { (img, error, cacheType, url) in
//            })
//            self.imgProfile.stopAnimating()
//        }
//
//    }
    
    @objc func actionNotificationButtonClick(_ sender: UISwitch) {
        print("Switchtapped")
        if sender.isOn{
            notificationStatus = "1"
        } else {
            notificationStatus = "0"
        }
        self.notificationApi()
        //changenotificationsetting
        
    }
    
    @objc func actionNotificationButtonClickNew(_ sender: UISwitch) {
        print("Switchtapped")
        if sender.isOn{
            notificationStatus = "1"
        } else {
            notificationStatus = "0"
        }
        self.notificationApi1()
        //changenotificationsetting
        
    }
    
    @objc func actionNotificationButtonClickNew1(_ sender: UISwitch) {
        print("Switchtapped")
        if sender.isOn{
            notificationStatus = "1"
        } else {
            notificationStatus = "0"
        }
        self.notificationApi2()
        //changenotificationsetting
        
    }
    
    @objc func actionRightButtonClick(_ sender: UIButton) {
        print("RightButtontapped")

    }
    
    
    @objc func actionButtonHeaderClick(_ sender: UIButton) {
        if sender.tag == 0{
            let obj = self.storyboard?.instantiateViewController(withIdentifier: "EditProfileVC") as! EditProfileVC
            self.navigationController?.pushViewController(obj, animated: true)
        }
        else if sender.tag == 1{
            let obj = self.storyboard?.instantiateViewController(withIdentifier: "ChangePassword") as! ChangePassword
            self.navigationController?.pushViewController(obj, animated: true)
        } else if sender.tag == 2{
            let freests = UserDefaults.standard.value(forKey: "FREESTS") as? String
            let substs = UserDefaults.standard.value(forKey: "SUBSTS") as? String
        
            if substs == "1" {
                let obj = self.storyboard?.instantiateViewController(withIdentifier: "MySubscriptionVC") as! MySubscriptionVC
                self.navigationController?.pushViewController(obj, animated: true)
            }else {
                if freests == "1" {
                    let obj = self.storyboard?.instantiateViewController(withIdentifier: "MembershipPlanVCNew") as! MembershipPlanVCNew
                    self.navigationController?.pushViewController(obj, animated: true)
//                    let myAlert = UIAlertController(title: "Holy Reads", message:"Your 7-days free trial is remaining. Want to buy plan?", preferredStyle: UIAlertController.Style.alert);
//                    let okAction = UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler:nil)
//
//                    let sayhi = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler:  { action in
//                        let obj = self.storyboard?.instantiateViewController(withIdentifier: "MembershipPlanVCNew") as! MembershipPlanVCNew
//                        self.navigationController?.pushViewController(obj, animated: true)
//
//                    })
//                    myAlert.addAction(okAction);
//                    myAlert.addAction(sayhi);
//
//                    self.present(myAlert, animated: true, completion: nil)
                }else {
                    let obj = self.storyboard?.instantiateViewController(withIdentifier: "MembershipPlanVCNew") as! MembershipPlanVCNew
                    self.navigationController?.pushViewController(obj, animated: true)
                }
//                let obj = self.storyboard?.instantiateViewController(withIdentifier: "MembershipPlanVCNew") as! MembershipPlanVCNew
//                self.navigationController?.pushViewController(obj, animated: true)
            }
          
        } else if sender.tag == 3{
            let obj = self.storyboard?.instantiateViewController(withIdentifier: "BlessFriendVC") as! BlessFriendVC
            self.navigationController?.pushViewController(obj, animated: true)
        } else if sender.tag == 4{
            let obj = self.storyboard?.instantiateViewController(withIdentifier: "MyDownloadsVC") as! MyDownloadsVC
            self.navigationController?.pushViewController(obj, animated: true)
        } else if sender.tag == 5{
//            let obj = self.storyboard?.instantiateViewController(withIdentifier: "NotificationChannelVC") as! NotificationChannelVC
//            self.navigationController?.pushViewController(obj, animated: true)
            if let isExpended = (arrTitles[sender.tag])["isExpended"] as? Bool {
                var dicData = arrTitles[sender.tag]
                
                dicData["isExpended"] = !isExpended
                if isExpended {
                    dicData["rightButton"] = "down"
                } else{
                    dicData["rightButton"] = "up"
                }
                exstr = "5"
                arrTitles.remove(at: sender.tag)
                arrTitles.insert(dicData, at: sender.tag)
                tblSetting.reloadData()
            
            }
        } else if sender.tag == 6{
            if let isExpended = (arrTitles[sender.tag])["isExpended"] as? Bool {
                var dicData = arrTitles[sender.tag]
                dicData["isExpended"] = !isExpended
                if isExpended {
                    dicData["rightButton"] = "down"
                } else{
                    dicData["rightButton"] = "up"
                }
                exstr = "6"
                arrTitles.remove(at: sender.tag)
                arrTitles.insert(dicData, at: sender.tag)
                tblSetting.reloadData()
            }
        }else if sender.tag == 7{
            let obj = self.storyboard?.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
            self.navigationController?.pushViewController(obj, animated: true)
        }
//        else if sender.tag == 8 {
//            if let isExpended = (arrTitles[sender.tag])["isExpended"] as? Bool {
//                var dicData = arrTitles[sender.tag]
//                dicData["isExpended"] = !isExpended
//                if isExpended {
//                    dicData["rightButton"] = "down"
//                } else{
//                    dicData["rightButton"] = "up"
//                }
//                arrTitles.remove(at: sender.tag)
//                arrTitles.insert(dicData, at: sender.tag)
//                tblSetting.reloadData()
//            }
//        }
//        else if sender.tag == 9{
//            let obj = self.storyboard?.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
//            self.navigationController?.pushViewController(obj, animated: true)
//        }
        else if sender.tag == 8 {
            
            let myAlert = PMAlertController(title: "Holy Reads", description: "Are you sure you want to logout?", image: UIImage(named: "welcome_logo"), style: .alert)
           // let myAlert = UIAlertController(title: "Holy Reads", message:message, preferredStyle: UIAlertController.Style.alert);
            
            myAlert.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () -> Void in
                print("Cancel")
            }))
            
            myAlert.addAction(PMAlertAction(title: "Yes", style: .default, action: { () in
                self.LogoutAPI()
            }))
            
            self.present(myAlert, animated: true, completion: nil)
            
//            let alertView = UIAlertController(title: "Are you sure you want to logout?", message: "", preferredStyle: .alert)
//            alertView.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
//                switch action.style{
//                case .default:
//                    self.LogoutAPI()
//                    break
//                case .cancel:
//                    break
//                case .destructive:
//
//                    break
//                }
//            }))
//            alertView.addAction(UIAlertAction(title: "No", style: .cancel) { action in
//
//            })
//            present(alertView, animated: true)
        }
        else if sender.tag == 9{
            
            let freests = UserDefaults.standard.value(forKey: "FREESTS") as? String
            let substs = UserDefaults.standard.value(forKey: "SUBSTS") as? String
            
            if substs == "1" {
                let obj = self.storyboard?.instantiateViewController(withIdentifier: "KindleVC") as! KindleVC
                self.navigationController?.pushViewController(obj, animated: false)
            }else {
                if freests == "1" {
                    let obj = self.storyboard?.instantiateViewController(withIdentifier: "KindleVC") as! KindleVC
                    self.navigationController?.pushViewController(obj, animated: false)
                }else {
                    let myAlert = PMAlertController(title: "Holy Reads", description: "Please purchase a plan.", image: UIImage(named: "welcome_logo"), style: .alert) //Image by freepik.com, taken on flaticon.com
                  //  let myAlert = UIAlertController(title: "HolyReads", message:"Device Limit Exceeded! \n You can be logged into one device at a time. Would you like to log out from other devices?", preferredStyle: UIAlertController.Style.alert);
                    
                    myAlert.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () -> Void in
                        print("Cancel")
                    }))
                    
                    myAlert.addAction(PMAlertAction(title: "Yes", style: .default, action: { () in
                        let obj = self.storyboard?.instantiateViewController(withIdentifier: "MembershipPlanVCNew") as! MembershipPlanVCNew
                        self.navigationController?.pushViewController(obj, animated: true)
                    }))
//                    let myAlert = UIAlertController(title: "Holy Reads", message:"Please buy a plan", preferredStyle: UIAlertController.Style.alert);
//                    let okAction = UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler:nil)
//
//                    let sayhi = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler:  { action in
//                        let obj = self.storyboard?.instantiateViewController(withIdentifier: "MembershipPlanVCNew") as! MembershipPlanVCNew
//                        self.navigationController?.pushViewController(obj, animated: true)
//
//                    })
//                    myAlert.addAction(okAction);
//                    myAlert.addAction(sayhi);
                    
                    self.present(myAlert, animated: true, completion: nil)
                }
            }
            
//            let obj = self.storyboard?.instantiateViewController(withIdentifier: "KindleVC") as! KindleVC
//            self.navigationController?.pushViewController(obj, animated: false)
        }
        else if sender.tag == 10 {
            let freests = UserDefaults.standard.value(forKey: "FREESTS") as? String
            let substs = UserDefaults.standard.value(forKey: "SUBSTS") as? String
            
            if substs == "1" {
                if self.arrSyncHighlights.count ==  0 {
                    self.view.makeToast(message: "No new notes found to synchronised.")
                 } else {
                    
                    let myAlert = PMAlertController(title: "Holy Reads", description: "Are you sure you want to sync all marked highlight to Evernote?", image: UIImage(named: "welcome_logo"), style: .alert)
                    myAlert.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () -> Void in
                        print("Cancel")
                    }))
                                        
                    myAlert.addAction(PMAlertAction(title: "Yes", style: .default, action: {  () in
                        switch PMAlertActionStyle.default {
                        case .default:
                            ENSession.shared.authenticate(with: self, preferRegistration: false, completion: { (_error: Error?) in
                                let note = ENNote()
                                for i in 0...self.arrSyncHighlights.count-1 {
                                    let dict = self.arrSyncHighlights[i]
                                    
                                    if let title = dict["book_title"] as? String {
                                        note.title = title
                                    }
                                    if let content = dict["highlight_text"] as? String {
                                        note.content = ENNoteContent(string: content)
                                    }
                                    ENSession.shared.upload(note, notebook: nil) { (noteRef: ENNoteRef?, error: Error?) in
                                        if (error != nil) {
                                            self.getEvernoteSyncHighlightSucessStatus(sucessStatus: "0")
                                            print(error?.localizedDescription)
                                        } else {
                                            print("Successfully Added Notes")
                                            self.view.makeToast(message: "Sucessully synchronised highlights ")

                                            self.getEvernoteSyncHighlightSucessStatus(sucessStatus: "1")
                                         }
                                    }
                                }
                                 
                            })
                            break
                        case .cancel:
                            break
                        }

                    }))
                    self.present(myAlert, animated: true, completion: nil)
                    
//                    let alertView = UIAlertController(title: "Are you sure you want to sync all marked highlight to Evernote ?", message: "", preferredStyle: .alert)
//                    alertView.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
//                        switch action.style {
//                        case .default:
//                            ENSession.shared.authenticate(with: self, preferRegistration: false, completion: { (_error: Error?) in
//                                let note = ENNote()
//                                for i in 0...self.arrSyncHighlights.count-1 {
//                                    let dict = self.arrSyncHighlights[i]
//
//                                    if let title = dict["book_title"] as? String {
//                                        note.title = title
//                                    }
//                                    if let content = dict["highlight_text"] as? String {
//                                        note.content = ENNoteContent(string: content)
//                                    }
//                                    ENSession.shared.upload(note, notebook: nil) { (noteRef: ENNoteRef?, error: Error?) in
//                                        if (error != nil) {
//                                            self.getEvernoteSyncHighlightSucessStatus(sucessStatus: "0")
//                                            print(error?.localizedDescription)
//                                        } else {
//                                            print("Successfully Added Notes")
//                                            self.view.makeToast(message: "Sucessully synchronised highlights ")
//
//                                            self.getEvernoteSyncHighlightSucessStatus(sucessStatus: "1")
//                                         }
//                                    }
//                                }
//
//                            })
//                            break
//                        case .cancel:
//                            break
//                        case .destructive:
//
//                            break
//                        }
//                    }))
//                    alertView.addAction(UIAlertAction(title: "No", style: .cancel) { action in
//
//                    })
//                    present(alertView, animated: true)
                }
            }else {
                if freests == "1" {
                    if self.arrSyncHighlights.count ==  0 {
                        self.view.makeToast(message: "No new highlight found to synchronised.")
                     } else {
                       // let alertView = UIAlertController(title: "Do you want to sync your notes with Evernote?", message: "", preferredStyle: .alert)
                        
                        let myAlert = PMAlertController(title: "Holy Reads", description: "Do you want to sync your notes with Evernote?", image: UIImage(named: "welcome_logo"), style: .alert) //Image by freepik.com, taken on flaticon.com
                      //  let myAlert = UIAlertController(title: "HolyReads", message:"Device Limit Exceeded! \n You can be logged into one device at a time. Would you like to log out from other devices?", preferredStyle: UIAlertController.Style.alert);
                        
                        myAlert.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () -> Void in
                            print("Cancel")
                        }))
                        
                        myAlert.addAction(PMAlertAction(title: "Yes", style: .default, action: { () in
                            ENSession.shared.authenticate(with: self, preferRegistration: false, completion: { (_error: Error?) in
                                let note = ENNote()
                                for i in 0...self.arrSyncHighlights.count-1 {
                                    let dict = self.arrSyncHighlights[i]
                                    
                                    if let title = dict["book_title"] as? String {
                                        note.title = title
                                    }
                                    if let content = dict["highlight_text"] as? String {
                                        note.content = ENNoteContent(string: content)
                                    }
                                    ENSession.shared.upload(note, notebook: nil) { (noteRef: ENNoteRef?, error: Error?) in
                                        if (error != nil) {
                                            self.getEvernoteSyncHighlightSucessStatus(sucessStatus: "0")
                                            print(error?.localizedDescription)
                                        } else {
                                            print("Successfully Added Notes")
                                            self.view.makeToast(message: "Sucessully synchronised highlights ")

                                            self.getEvernoteSyncHighlightSucessStatus(sucessStatus: "1")
                                         }
                                    }
                                }
                                 
                            })
                        }))
                        
                        
//                        alertView.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
//                            switch action.style {
//                            case .default:
//                                ENSession.shared.authenticate(with: self, preferRegistration: false, completion: { (_error: Error?) in
//                                    let note = ENNote()
//                                    for i in 0...self.arrSyncHighlights.count-1 {
//                                        let dict = self.arrSyncHighlights[i]
//
//                                        if let title = dict["book_title"] as? String {
//                                            note.title = title
//                                        }
//                                        if let content = dict["highlight_text"] as? String {
//                                            note.content = ENNoteContent(string: content)
//                                        }
//                                        ENSession.shared.upload(note, notebook: nil) { (noteRef: ENNoteRef?, error: Error?) in
//                                            if (error != nil) {
//                                                self.getEvernoteSyncHighlightSucessStatus(sucessStatus: "0")
//                                                print(error?.localizedDescription)
//                                            } else {
//                                                print("Successfully Added Notes")
//                                                self.view.makeToast(message: "Sucessully synchronised highlights ")
//
//                                                self.getEvernoteSyncHighlightSucessStatus(sucessStatus: "1")
//                                             }
//                                        }
//                                    }
//
//                                })
//                                break
//                            case .cancel:
//                                break
//                            case .destructive:
//
//                                break
//                            }
//                        }))
//                        alertView.addAction(UIAlertAction(title: "No", style: .cancel) { action in
//
//                        })
                        self.present(myAlert, animated: true, completion: nil)
//                        present(alertView, animated: true)
                    }
                }else {
                    
                    let myAlert = PMAlertController(title: "Holy Reads", description: "Please purchase a plan.", image: UIImage(named: "welcome_logo"), style: .alert) //Image by freepik.com, taken on flaticon.com
                  //  let myAlert = UIAlertController(title: "HolyReads", message:"Device Limit Exceeded! \n You can be logged into one device at a time. Would you like to log out from other devices?", preferredStyle: UIAlertController.Style.alert);
                    
                    myAlert.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () -> Void in
                        print("Cancel")
                    }))
                    
                    myAlert.addAction(PMAlertAction(title: "Yes", style: .default, action: { () in
                        let obj = self.storyboard?.instantiateViewController(withIdentifier: "MembershipPlanVCNew") as! MembershipPlanVCNew
                        self.navigationController?.pushViewController(obj, animated: true)
                    }))
                    
                    //let myAlert = UIAlertController(title: "Holy Reads", message:"Please buy a plan", preferredStyle: UIAlertController.Style.alert);
//                    let okAction = UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler:nil)
//
//                    let sayhi = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler:  { action in
//                        let obj = self.storyboard?.instantiateViewController(withIdentifier: "MembershipPlanVCNew") as! MembershipPlanVCNew
//                        self.navigationController?.pushViewController(obj, animated: true)
//
//                    })
//                    myAlert.addAction(okAction);
//                    myAlert.addAction(sayhi);
                    
                    self.present(myAlert, animated: true, completion: nil)
                }
            }
//            if self.arrSyncHighlights.count ==  0 {
//                self.view.makeToast(message: "No new highlight found to synchronised.")
//             } else {
//                let alertView = UIAlertController(title: "Are you sure you want to sync all marked highlight to Evernote ?", message: "", preferredStyle: .alert)
//                alertView.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
//                    switch action.style {
//                    case .default:
//                        ENSession.shared.authenticate(with: self, preferRegistration: false, completion: { (_error: Error?) in
//                            let note = ENNote()
//                            for i in 0...self.arrSyncHighlights.count-1 {
//                                let dict = self.arrSyncHighlights[i]
//
//                                if let title = dict["book_title"] as? String {
//                                    note.title = title
//                                }
//                                if let content = dict["highlight_text"] as? String {
//                                    note.content = ENNoteContent(string: content)
//                                }
//                                ENSession.shared.upload(note, notebook: nil) { (noteRef: ENNoteRef?, error: Error?) in
//                                    if (error != nil) {
//                                        self.getEvernoteSyncHighlightSucessStatus(sucessStatus: "0")
//                                        print(error?.localizedDescription)
//                                    } else {
//                                        print("Successfully Added Notes")
//                                        self.view.makeToast(message: "Sucessully synchronised highlights ")
//
//                                        self.getEvernoteSyncHighlightSucessStatus(sucessStatus: "1")
//                                     }
//                                }
//                            }
//
//                        })
//                        break
//                    case .cancel:
//                        break
//                    case .destructive:
//
//                        break
//                    }
//                }))
//                alertView.addAction(UIAlertAction(title: "No", style: .cancel) { action in
//
//                })
//                present(alertView, animated: true)
//            }
            
        }
            
            
        
    }
    //MARK:- API Calling
    func getProfileData() {
      //  self.showHud()
        self.showHud1()
        let parameterDictionary = NSMutableDictionary()
        let userId = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        parameterDictionary.setValue(userId, forKey: "user_id")
        
        let methodName = "profile_details"
        
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
            
            if status == "1" {
                let response = DataManager.getVal(responseData?["data"]) as! [String: Any]
                UserDefaults.standard.setValue(response["facebook_status"], forKey: "fbUser")
                self.dicUserDetails = response
                self.setProfileData()
                self.tblSetting.reloadData()
                let newoff = UserDefaults.standard.value(forKey: "OF") as? String
                if newoff == "off" {
                    self.fetchItemRecordFromDB()
                }else {
                    print("Ashish")
                }
                
            }else{
                self.view.makeToast(message: message)
            }
            self.clearHud()
        }
    }
    
    //MARK:- Get Sync Highlight API Calling
    
    func getSyncHighlight() {
       // self.showHud()
        self.showHud1()
        let parameterDictionary = NSMutableDictionary()
        let userId = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        parameterDictionary.setValue(userId, forKey: "user_id")
        
        let methodName = "getEvernoteSyncHighlight"
        
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
            
            if status == "1" {
                if let response = DataManager.getVal(responseData?["data"]) as? [[String: Any]] {
                    self.arrSyncHighlights = response
                }
             }else{
               // self.view.makeToast(message: message)
                self.arrSyncHighlights.removeAll()
            }
            self.clearHud()
        }
    }
    
      //MARK:-  Sync Highlight Sucess Status API Calling
    func getEvernoteSyncHighlightSucessStatus(sucessStatus: String) {
        let parameterDictionary = NSMutableDictionary()
        let userId = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        parameterDictionary.setValue(userId, forKey: "user_id")
        parameterDictionary.setValue(sucessStatus, forKey: "success")
        let methodName = "getEvernoteSyncHighlight"
        
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
            if status == "1" {
                self.getSyncHighlight()
            }else{
                // self.view.makeToast(message: message)
            }
        }
    }
 
    func setProfileData() {
        self.txtUsername.text = dicUserDetails["username"] as? String
        self.txtEmail.text =  dicUserDetails["email"] as? String
        if let profileImg = dicUserDetails["profile_picture"] as? String
        {
            self.imgProfile.sd_imageIndicator = SDWebImageActivityIndicator.gray
            let url = URL.init(string: profileImg)
            self.imgProfile.sd_setImage(with: url, placeholderImage: UIImage.init(named: ""), options: .refreshCached, completed: { (img, error, cacheType, url) in
            })
        }
    }
}

extension SettingVCViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let status = (arrTitles[section])["expendable"] as? Bool, status == true, let isExpended = (arrTitles[section])["isExpended"] as? Bool, isExpended == true {
            if let arrData = (arrTitles[section])["expendData"] as? [String] {
                return arrData.count
            } else {
                return 0
            }
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if UserDefaults.standard.value(forKey: "fbUser") != nil {
        if UserDefaults.standard.value(forKey: "fbUser") as! Int == 0  {
          return 60
        } else {
            if section == 1{
                return 0
            } else {
                return 60
            }
        }
        }
       return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 60))
        header.backgroundColor = UIColor.white
        
        let leftImg = UIImageView(image: UIImage.init(named: (arrTitles[section])["leftIcon"] as! String ) , highlightedImage: nil)
        leftImg.frame = CGRect(x: 20, y: 20, width: 20, height: 20)
        header.addSubview(leftImg)
        
        let label = UILabel(frame: CGRect(x: 55, y: 12, width: header.frame.size.width - 36, height: header.frame.size.height - 25.0))
        label.font = UIFont.init(name: "Verdana", size: 17)
        label.textColor = #colorLiteral(red: 0.1644093692, green: 0.2676883936, blue: 0.3667172194, alpha: 1)
        label.text = (arrTitles[section])["title"] as? String
        if section == 9 || section == 10 {
            label.font = UIFont.init(name: "Verdana-Bold", size: 16)
            label.frame = CGRect(x: 20, y: 12, width: header.frame.size.width - 36, height: header.frame.size.height - 25.0)
        }
        header.addSubview(label)
        
        let labelLine = UILabel(frame: CGRect(x: 0, y: header.frame.size.height - 2, width: header.frame.size.width, height:1))
        labelLine.backgroundColor = #colorLiteral(red: 0.9845257401, green: 0.9815086722, blue: 0.9844581485, alpha: 1)
        header.addSubview(labelLine)
 
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: header.frame.size.width, height: header.frame.size.height))
        button.tag = section
        button.addTarget(self, action: #selector(actionButtonHeaderClick(_:)), for: .touchUpInside)
        header.addSubview(button)
//
//        let notificationSwitch = UISwitch(frame: CGRect(x: header.frame.size.width - 70, y: 15, width: 50, height: 30))
//        notificationSwitch.contentMode = .scaleToFill
//        if UserDefaults.standard.value(forKey: "notification_status")as? String == "0"{
//            notificationSwitch.isOn = false
//        } else{
//            notificationSwitch.isOn =  true
//        }
//        notificationSwitch.tag = section
//        notificationSwitch.isUserInteractionEnabled = false
//        notificationSwitch.isHidden = true
//        if section == 5 {
//            notificationSwitch.isHidden = false
//            notificationSwitch.isUserInteractionEnabled = true
//        }
//        notificationSwitch.onTintColor = UIColor.init(red: 5.0/255.0, green: 133.0/255.0, blue: 187.0/255.0, alpha: 1)// the "on" color
//
//        notificationSwitch.addTarget(self, action: #selector(actionNotificationButtonClick(_:)), for: .touchUpInside)
//        header.addSubview(notificationSwitch)
//
//
//
//        let notificationSwitch1 = UISwitch(frame: CGRect(x: header.frame.size.width - 70, y: 15, width: 50, height: 30))
//        notificationSwitch1.contentMode = .scaleToFill
//        if UserDefaults.standard.value(forKey: "email_notification_status")as? String == "0"{
//            notificationSwitch1.isOn = false
//        } else{
//            notificationSwitch1.isOn =  true
//        }
//        notificationSwitch1.tag = section
//        notificationSwitch1.isUserInteractionEnabled = false
//        notificationSwitch1.isHidden = true
//        if section == 6 {
//            notificationSwitch1.isHidden = false
//            notificationSwitch1.isUserInteractionEnabled = true
//        }
//        notificationSwitch1.onTintColor = UIColor.init(red: 5.0/255.0, green: 133.0/255.0, blue: 187.0/255.0, alpha: 1)// the "on" color
//
//        notificationSwitch1.addTarget(self, action: #selector(actionNotificationButtonClickNew(_:)), for: .touchUpInside)
//        header.addSubview(notificationSwitch1)
//
//
//        let notificationSwitch2 = UISwitch(frame: CGRect(x: header.frame.size.width - 70, y: 15, width: 50, height: 30))
//        notificationSwitch2.contentMode = .scaleToFill
//        if UserDefaults.standard.value(forKey: "email_notification_status")as? String == "0"{
//            notificationSwitch2.isOn = false
//        } else{
//            notificationSwitch2.isOn =  true
//        }
//        notificationSwitch2.tag = section
//        notificationSwitch2.isUserInteractionEnabled = false
//        notificationSwitch2.isHidden = true
//        if section == 7 {
//            notificationSwitch2.isHidden = false
//            notificationSwitch2.isUserInteractionEnabled = true
//        }
//        notificationSwitch2.onTintColor = UIColor.init(red: 5.0/255.0, green: 133.0/255.0, blue: 187.0/255.0, alpha: 1)// the "on" color
//
//        notificationSwitch2.addTarget(self, action: #selector(actionNotificationButtonClickNew1(_:)), for: .touchUpInside)
//        header.addSubview(notificationSwitch2)
//
        
        
        let rightButton = UIButton(frame: CGRect(x: header.frame.size.width - 70, y: 15, width:50 , height: 30))
        rightButton.tag = section
        rightButton.isUserInteractionEnabled = false
        rightButton.addTarget(self, action: #selector(actionRightButtonClick(_:)), for: .touchUpInside)
        rightButton.setImage(UIImage.init(named: (arrTitles[section])["rightButton"] as! String ), for: .normal)
        //        rightButton.setImage(UIImage.init(named:UIImage(named: (arrTitles[section])["rightButton"] as! String )), for: UIControl.State.normal)
        header.addSubview(rightButton)
        
        
        return header
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell = tableView.dequeueReusableCell(withIdentifier: "ExpandCell") as? ExpandCell
        
        
        if exstr == "5" {
            let data1 = arrTitles[5] as? [String: Any]
            let cellData1 = data1?["expendData"] as? [String]
            cell?.imgIcon.image = UIImage.init(named: arrExpandImg1[indexPath.row])
            cell?.switchBtn.isHidden = false
            cell?.lblTitle.text = cellData1?[indexPath.row]
            cell?.switchBtn.tag = indexPath.row
            if indexPath.row == 0{
                cell?.switchBtn.addTarget(self, action: #selector(switchBtnTab(_:)), for: .touchUpInside)
            }else {
                cell?.switchBtn.addTarget(self, action: #selector(switchBtnTab1(_:)), for: .touchUpInside)
            }
        }
        
       // cell?.lblTitle.text = cellData?[indexPath.row]
        //cell?.lblTitle.text = cellData1?[indexPath.row]
//        if let data = arrTitles[6] as? [String: Any]{
//            if let cellData = data["expendData"] as? [String]{
//             cell?.lblTitle.text = cellData[indexPath.row]
//            }
//            cell?.switchBtn.isHidden = true
//        }
        else  if exstr == "6" {
            let data = arrTitles[6] as? [String: Any]
            let cellData = data?["expendData"] as? [String]
            cell?.imgIcon.image = UIImage.init(named: arrExpandImg[indexPath.row])
            cell?.lblTitle.text = cellData?[indexPath.row]
            cell?.switchBtn.isHidden = true
        }
        return cell!
    }
    
    @objc func switchBtnTab(_ sender: UISwitch){
        if sender.isOn{
            notificationStatus = "1"
        } else {
            notificationStatus = "0"
        }
        self.notificationApi()
    }
    
    @objc func switchBtnTab1(_ sender: UISwitch){
        if sender.isOn{
            notificationStatus = "1"
        } else {
            notificationStatus = "0"
        }
        self.notificationApi1()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if exstr == "5" {
            print("Ashish")
        }else if exstr == "6" {
            
        if indexPath.row == 0{
            let obj = self.storyboard?.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
            obj.strTittle = "FAQ"
            obj.strURL = "pages/mobilefaq"
             
            self.navigationController?.pushViewController(obj, animated: true)
        } else if indexPath.row == 1 {
            let obj = self.storyboard?.instantiateViewController(withIdentifier: "ContactUs") as! ContactUs
             
            self.navigationController?.pushViewController(obj, animated: true)
        } else if indexPath.row == 2 {
            let obj = self.storyboard?.instantiateViewController(withIdentifier: "WebViewVC") as! WebViewVC
            obj.strTittle = "Privacy Policy"
            obj.strURL = "pages/mobile_privacy"
             
            self.navigationController?.pushViewController(obj, animated: true)
        } else if indexPath.row == 3 {
            let obj = self.storyboard?.instantiateViewController(withIdentifier: "SubmitFeedbackVC") as! SubmitFeedbackVC
             
            self.navigationController?.pushViewController(obj, animated: true)
        }
        }
     }
    
    func LogoutAPI() {
        let parameterDictionary = NSMutableDictionary()
        let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        let device_id = identifierManager.advertisingIdentifier.uuidString
        parameterDictionary.setValue(DataManager.getVal(user_id) as! String, forKey: "user_id")
        parameterDictionary.setValue(DataManager.getVal(device_id) as! String, forKey: "phone_device_id")
        print(parameterDictionary)
        
        let methodName = "logout"
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
            if status == "1" {
                DataManager.ClearUserDetails()
                self.appDelegate.showFirstPage()
            } else{
                DataManager.ClearUserDetails()
                self.appDelegate.showFirstPage()
               // self.view.makeToast(message: message)
            }
        }
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
                self.tblSetting.reloadData()
            } else{
                self.view.makeToast(message: message)
                self.tblSetting.reloadData()
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
                self.tblSetting.reloadData()
            } else{
                self.view.makeToast(message: message)
                self.tblSetting.reloadData()
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






    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


