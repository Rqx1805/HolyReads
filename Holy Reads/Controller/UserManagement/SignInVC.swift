//
//  SignInVC.swift
//  Holy Reads
//
//  Created by mac-14 on 30/08/19.
//  Copyright © 2019 Ajeet singh Rawat. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import PassKit
import Stripe
import FirebaseAnalytics
import AuthenticationServices
import LocalAuthentication
import PMAlertController
import AdSupport
class SignInVC: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    
    var dictSocialInfo = [String:Any]()
    let identifierManager = ASIdentifierManager.shared()
    //APPLE PAY
    
     // MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    // MARK: - IBAction
    func displayDefaultAlert(title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
       let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - Apple SignIn
    @IBAction func appleSignInBtn(_ sender: Any) {
        if #available(iOS 13.0, *) {
                  let authorizationButton = ASAuthorizationAppleIDButton()
              } else {
                  // Fallback on earlier versions
              }
              if #available(iOS 13.0, *) {
                  let appleIDProvider = ASAuthorizationAppleIDProvider()
                  let request = appleIDProvider.createRequest()
                  request.requestedScopes = [.fullName, .email]
                  let authorizationController = ASAuthorizationController(authorizationRequests: [request])
                  authorizationController.delegate = self
                  authorizationController.performRequests()
                  
                              
              } else {
                self.view.makeToast(message: "Please update your apple version to use login")
              }
    }
    
    func GetdeviceLinit(userid:Int!) {
        let deviceToken = DataManager.getVal(Config().AppUserDefaults.object(forKey: "Devicetoken") as AnyObject?) as! String
        let parameterDictionary = NSMutableDictionary()
        let device_id = identifierManager.advertisingIdentifier.uuidString
        parameterDictionary.setValue(DataManager.getVal(userid) as! String, forKey: "user_id")
        parameterDictionary.setValue(DataManager.getVal(device_id) as! String, forKey: "phone_device_id")
        parameterDictionary.setValue(DataManager.getVal(deviceToken) as! String, forKey: "firebase_id")
        print(parameterDictionary)
        
        let methodName = "deviceLimitCheckPassed"
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
            if status == "1" {
//                DataManager.ClearUserDetails()
//                self.appDelegate.showFirstPage()
            } else{
                self.view.makeToast(message: message)
            }
        }
    }
    
    
    @IBAction func btnSignIn_DidSelect(_ sender: UIButton) {
        
        self.view.endEditing(true)
        if ValidationClass().ValidateSignInForm(self) {
            self.showHud()
            let encoded__Question = (txtEmail.text! as NSString).data(using: String.Encoding.utf8.rawValue)
            let base64String = encoded__Question?.base64EncodedString(options: .init(rawValue: 0))
            print(base64String!) // bXkgcGxhbmkgdGV4dA==
            let parameterDictionary = NSMutableDictionary()
            parameterDictionary.setValue(DataManager.getVal(base64String) as! String, forKey: "email")
            parameterDictionary.setValue(DataManager.getVal(txtPassword.text!) as! String, forKey: "password")
            let device_id = identifierManager.advertisingIdentifier.uuidString
            parameterDictionary.setValue(DataManager.getVal(device_id) as! String, forKey: "phone_device_id")
            print(parameterDictionary)

            let methodName = "login"

            DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
                let status = DataManager.getVal(responseData?["status"]) as! String
                let message = DataManager.getVal(responseData?["message"]) as! String
                let subscriptionStatus  = DataManager.getVal(responseData?["subscribed_status"]) as! String
                let freetrialStatus  = DataManager.getVal(responseData?["free_trial_status"]) as! String
                let device_loginsts  = DataManager.getVal(responseData?["device_logged_in_status"]) as! String
                if status == "1" {
                    let response = DataManager.getVal(responseData?["data"]) as! [String: Any]
                    var userID:Int!
                    userID = response["user_id"] as? Int
                    let defaults = UserDefaults.standard
                    defaults.setValue(userID, forKey: "user_id")
                    defaults.synchronize()
                    if freetrialStatus == "1" {
                        if device_loginsts == "3" {
                            let myAlert = PMAlertController(title: "Holy Reads", description: "Device Limit Exceeded! \n You can be logged into one device at a time. Would you like to log out from other devices?", image: UIImage(named: "welcome_logo"), style: .alert) //Image by freepik.com, taken on flaticon.com
                          //  let myAlert = UIAlertController(title: "HolyReads", message:"Device Limit Exceeded! \n You can be logged into one device at a time. Would you like to log out from other devices?", preferredStyle: UIAlertController.Style.alert);
                            
                            myAlert.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () -> Void in
                                print("Cancel")
                            }))
                            
                            myAlert.addAction(PMAlertAction(title: "Yes", style: .default, action: { () in
                                let response = DataManager.getVal(responseData?["data"]) as! [String: Any]
                                DataManager.saveinDefaults(response)
                                if response["verified_status"] as! Int == 2 {
                                    let objVC = self.storyboard?.instantiateViewController(withIdentifier: "OTPVerificationVC") as! OTPVerificationVC
                                    objVC.isFrom = "Login"
                                    objVC.subscriptionStatus = subscriptionStatus
                                    objVC.freetrialstatus = freetrialStatus
                                    objVC.strEmail = self.txtEmail.text!
                                    self.navigationController?.pushViewController(objVC, animated: true)
                                } else if response["verified_status"] as! Int == 1 {
                                    let userid = response["user_id"] as! Int
                                    if subscriptionStatus == "1" {
                                        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "tabbar") as? UITabBarController
                                        self.navigationController?.pushViewController(objVC!, animated: true)
                                        Config().AppUserDefaults.set(true, forKey: "isCurrentUser")
                                        self.GetdeviceLinit(userid: userid)
                                        Analytics.logEvent(AnalyticsEventLogin, parameters: [
                                            AnalyticsParameterMethod: self.method
                                            ])
                                    }else {
                                        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "tabbar") as? UITabBarController
                                        self.navigationController?.pushViewController(objVC!, animated: true)
                                        Config().AppUserDefaults.set(true, forKey: "isCurrentUser")
                                        self.GetdeviceLinit(userid: userid)
                                        Analytics.logEvent(AnalyticsEventLogin, parameters: [
                                            AnalyticsParameterMethod: self.method
                                            ])
                                    }
                                }
                            }))
                            
//                            let okAction = UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler:nil)
//
//                            let sayhi = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler:  { action in
//                                let response = DataManager.getVal(responseData?["data"]) as! [String: Any]
//                                DataManager.saveinDefaults(response)
//                                if response["verified_status"] as! Int == 2 {
//                                    let objVC = self.storyboard?.instantiateViewController(withIdentifier: "OTPVerificationVC") as! OTPVerificationVC
//                                    objVC.isFrom = "Login"
//                                    objVC.subscriptionStatus = subscriptionStatus
//                                    objVC.freetrialstatus = freetrialStatus
//                                    objVC.strEmail = self.txtEmail.text!
//                                    self.navigationController?.pushViewController(objVC, animated: true)
//                                } else if response["verified_status"] as! Int == 1 {
//                                    if subscriptionStatus == "1" {
//                                        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "tabbar") as? UITabBarController
//                                        self.navigationController?.pushViewController(objVC!, animated: true)
//                                        Config().AppUserDefaults.set(true, forKey: "isCurrentUser")
//                                        Analytics.logEvent(AnalyticsEventLogin, parameters: [
//                                            AnalyticsParameterMethod: self.method
//                                            ])
//                                    }else {
//                                        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "tabbar") as? UITabBarController
//                                        self.navigationController?.pushViewController(objVC!, animated: true)
//                                        Config().AppUserDefaults.set(true, forKey: "isCurrentUser")
//                                        Analytics.logEvent(AnalyticsEventLogin, parameters: [
//                                            AnalyticsParameterMethod: self.method
//                                            ])
//                                    }
//                                }
//
//                            })
//                            myAlert.addAction(okAction);
//                            myAlert.addAction(sayhi);
                            
                            self.present(myAlert, animated: true, completion: nil)

//                            let alert = UIAlertController(title: "HolyReads", message: "Device Limit Exceeded! You can be logged into one device at a time. Would you like to log out from other devices?.", preferredStyle: UIAlertController.Style.alert)
//                            self.present(alert, animated: true, completion: nil)
//                                                //  Success = false
//                                                // add an action (button)
//                            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
//                                let response = DataManager.getVal(responseData?["data"]) as! [String: Any]
//                                DataManager.saveinDefaults(response)
//                                if response["verified_status"] as! Int == 2 {
//                                    let objVC = self.storyboard?.instantiateViewController(withIdentifier: "OTPVerificationVC") as! OTPVerificationVC
//                                    objVC.isFrom = "Login"
//                                    objVC.subscriptionStatus = subscriptionStatus
//                                    objVC.freetrialstatus = freetrialStatus
//                                    objVC.strEmail = self.txtEmail.text!
//                                    self.navigationController?.pushViewController(objVC, animated: true)
//                                } else if response["verified_status"] as! Int == 1 {
//                                    if subscriptionStatus == "1" {
//                                        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "tabbar") as? UITabBarController
//                                        self.navigationController?.pushViewController(objVC!, animated: true)
//                                        Config().AppUserDefaults.set(true, forKey: "isCurrentUser")
//                                        Analytics.logEvent(AnalyticsEventLogin, parameters: [
//                                            AnalyticsParameterMethod: self.method
//                                            ])
//                                    }else {
//                                        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "tabbar") as? UITabBarController
//                                        self.navigationController?.pushViewController(objVC!, animated: true)
//                                        Config().AppUserDefaults.set(true, forKey: "isCurrentUser")
//                                        Analytics.logEvent(AnalyticsEventLogin, parameters: [
//                                            AnalyticsParameterMethod: self.method
//                                            ])
//                                    }
//                                }
//                                                   
//                                }))
                        }else {
                            let response = DataManager.getVal(responseData?["data"]) as! [String: Any]
                            DataManager.saveinDefaults(response)
                            if response["verified_status"] as! Int == 2 {
                                let objVC = self.storyboard?.instantiateViewController(withIdentifier: "OTPVerificationVC") as! OTPVerificationVC
                                objVC.isFrom = "Login"
                                objVC.subscriptionStatus = subscriptionStatus
                                objVC.freetrialstatus = freetrialStatus
                                objVC.strEmail = self.txtEmail.text!
                                self.navigationController?.pushViewController(objVC, animated: true)
                            } else if response["verified_status"] as! Int == 1 {
                                let userid = response["user_id"] as! Int
                                if subscriptionStatus == "1" {
                                    let objVC = self.storyboard?.instantiateViewController(withIdentifier: "tabbar") as? UITabBarController
                                    self.navigationController?.pushViewController(objVC!, animated: true)
                                    Config().AppUserDefaults.set(true, forKey: "isCurrentUser")
                                    self.GetdeviceLinit(userid: userid)
                                    Analytics.logEvent(AnalyticsEventLogin, parameters: [
                                        AnalyticsParameterMethod: self.method
                                        ])
                                 } else {
                                    if freetrialStatus == "1" {
                                        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "tabbar") as? UITabBarController
                                        self.navigationController?.pushViewController(objVC!, animated: true)
                                        Config().AppUserDefaults.set(true, forKey: "isCurrentUser")
                                        self.GetdeviceLinit(userid: userid)
                                        Analytics.logEvent(AnalyticsEventLogin, parameters: [
                                            AnalyticsParameterMethod: self.method
                                            ])
                                    }else {
                                        let myAlert = PMAlertController(title: "Holy Reads", description: message, image: UIImage(named: "welcome_logo"), style: .alert)
                                       // let myAlert = UIAlertController(title: "Holy Reads", message:message, preferredStyle: UIAlertController.Style.alert);
                                        
                                        myAlert.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () -> Void in
                                            print("Cancel")
                                        }))
                                        
                                        myAlert.addAction(PMAlertAction(title: "Yes", style: .default, action: { () in
                                            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "MembershipPlanVCNew") as! MembershipPlanVCNew
                                            objVC.isFrom = "Login"
                                            self.navigationController?.pushViewController(objVC, animated: true)
                                        }))
                                        
//                                        let okAction = UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler:nil)
//
//                                        let sayhi = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler:  { action in
//                                            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "MembershipPlanVCNew") as! MembershipPlanVCNew
//                                            objVC.isFrom = "Login"
//                                            self.navigationController?.pushViewController(objVC, animated: true)
//
//                                        })
//                                        myAlert.addAction(okAction);
//                                        myAlert.addAction(sayhi);
                                        
                                        self.present(myAlert, animated: true, completion: nil)
//                                        let alert = UIAlertController(title: "HolyReads", message: message, preferredStyle: UIAlertController.Style.alert)
//                                        self.present(alert, animated: true, completion: nil)
//                                        //  Success = false
//                                        // add an action (button)
//                                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
//                                            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "MembershipPlanVCNew") as! MembershipPlanVCNew
//                                            objVC.isFrom = "Login"
//                                            self.navigationController?.pushViewController(objVC, animated: true)
//                                        }))
                                        
                                    }
                                    
                                }
                            }
                        }
                    }else
                    {
                        
                        
                        let myAlert = PMAlertController(title: "Holy Reads", description: message, image: UIImage(named: "welcome_logo"), style: .alert)
                       // let myAlert = UIAlertController(title: "Holy Reads", message:message, preferredStyle: UIAlertController.Style.alert);
                        
                        myAlert.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () -> Void in
                            print("Cancel")
                        }))
                        
                        myAlert.addAction(PMAlertAction(title: "Yes", style: .default, action: { () in
                            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "MembershipPlanVCNew") as! MembershipPlanVCNew
                            objVC.isFrom = "Login"
                            self.navigationController?.pushViewController(objVC, animated: true)
                        }))
                        
                        
                        //let myAlert = UIAlertController(title: "Holy Reads", message:message, preferredStyle: UIAlertController.Style.alert);
//                        let okAction = UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler:nil)
//                        
//                        let sayhi = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler:  { action in
//                            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "MembershipPlanVCNew") as! MembershipPlanVCNew
//                            objVC.isFrom = "Login"
//                            self.navigationController?.pushViewController(objVC, animated: true)
//                            
//                        })
//                        myAlert.addAction(okAction);
//                        myAlert.addAction(sayhi);
                        
                        self.present(myAlert, animated: true, completion: nil)
//                        let alert = UIAlertController(title: "HolyReads", message: message, preferredStyle: UIAlertController.Style.alert)
//                        self.present(alert, animated: true, completion: nil)
//                        //  Success = false
//                        // add an action (button)
//                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
//                            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "MembershipPlanVCNew") as! MembershipPlanVCNew
//                            objVC.isFrom = "Login"
//                            self.navigationController?.pushViewController(objVC, animated: true)
//                        }))
                    }
                    
//
//                    if device_loginsts == "1" {
//                        let alert = UIAlertController(title: "HolyReads", message: "Device limit exceeded. Please logout form other devices to login.", preferredStyle: UIAlertController.Style.alert)
//                        self.present(alert, animated: true, completion: nil)
//                                            //  Success = false
//                                            // add an action (button)
//                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
//                            let response = DataManager.getVal(responseData?["data"]) as! [String: Any]
//                            DataManager.saveinDefaults(response)
//                            if response["verified_status"] as! Int == 2 {
//                                let objVC = self.storyboard?.instantiateViewController(withIdentifier: "OTPVerificationVC") as! OTPVerificationVC
//                                objVC.isFrom = "Login"
//                                objVC.subscriptionStatus = subscriptionStatus
//                                objVC.freetrialstatus = freetrialStatus
//                                objVC.strEmail = self.txtEmail.text!
//                                self.navigationController?.pushViewController(objVC, animated: true)
//                            } else if response["verified_status"] as! Int == 1 {
//                                if subscriptionStatus == "1" {
//                                    let objVC = self.storyboard?.instantiateViewController(withIdentifier: "tabbar") as? UITabBarController
//                                    self.navigationController?.pushViewController(objVC!, animated: true)
//                                    Config().AppUserDefaults.set(true, forKey: "isCurrentUser")
//                                    Analytics.logEvent(AnalyticsEventLogin, parameters: [
//                                        AnalyticsParameterMethod: self.method
//                                        ])
//                                 } else {
//                                    if freetrialStatus == "1" {
//                                        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "tabbar") as? UITabBarController
//                                        self.navigationController?.pushViewController(objVC!, animated: true)
//                                        Config().AppUserDefaults.set(true, forKey: "isCurrentUser")
//                                        Analytics.logEvent(AnalyticsEventLogin, parameters: [
//                                            AnalyticsParameterMethod: self.method
//                                            ])
//                                    }else {
//                                        let alert = UIAlertController(title: "HolyReads", message: message, preferredStyle: UIAlertController.Style.alert)
//                                        self.present(alert, animated: true, completion: nil)
//                                        //  Success = false
//                                        // add an action (button)
//                                        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
//                                            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "MembershipPlanVCNew") as! MembershipPlanVCNew
//                                            objVC.isFrom = "Login"
//                                            self.navigationController?.pushViewController(objVC, animated: true)
//                                        }))
//
//                                    }
//
//                                }
//                            }
//
//                            }))
//                    }else {
//                        let response = DataManager.getVal(responseData?["data"]) as! [String: Any]
//                        DataManager.saveinDefaults(response)
//                        if response["verified_status"] as! Int == 2 {
//                            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "OTPVerificationVC") as! OTPVerificationVC
//                            objVC.isFrom = "Login"
//                            objVC.subscriptionStatus = subscriptionStatus
//                            objVC.freetrialstatus = freetrialStatus
//                            objVC.strEmail = self.txtEmail.text!
//                            self.navigationController?.pushViewController(objVC, animated: true)
//                        } else if response["verified_status"] as! Int == 1 {
//                            if subscriptionStatus == "1" {
//                                let objVC = self.storyboard?.instantiateViewController(withIdentifier: "tabbar") as? UITabBarController
//                                self.navigationController?.pushViewController(objVC!, animated: true)
//                                Config().AppUserDefaults.set(true, forKey: "isCurrentUser")
//                                Analytics.logEvent(AnalyticsEventLogin, parameters: [
//                                    AnalyticsParameterMethod: self.method
//                                    ])
//                             } else {
//                                if freetrialStatus == "1" {
//                                    let objVC = self.storyboard?.instantiateViewController(withIdentifier: "tabbar") as? UITabBarController
//                                    self.navigationController?.pushViewController(objVC!, animated: true)
//                                    Config().AppUserDefaults.set(true, forKey: "isCurrentUser")
//                                    Analytics.logEvent(AnalyticsEventLogin, parameters: [
//                                        AnalyticsParameterMethod: self.method
//                                        ])
//                                }else {
//                                    let alert = UIAlertController(title: "HolyReads", message: message, preferredStyle: UIAlertController.Style.alert)
//                                    self.present(alert, animated: true, completion: nil)
//                                    //  Success = false
//                                    // add an action (button)
//                                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: {(action:UIAlertAction!) in
//                                        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "MembershipPlanVCNew") as! MembershipPlanVCNew
//                                        objVC.isFrom = "Login"
//                                        self.navigationController?.pushViewController(objVC, animated: true)
//                                    }))
//
//                                }
//
//                            }
//                        }
//                    }
//
                }
                else{
                    self.view.makeToast(message: message)
                }
                self.clearHud()
            }
        }
    }
    
    @IBAction func btnClose_DidSelect(_ sender: UIButton) {
        UIControl().sendAction(#selector(URLSessionTask.suspend), to: UIApplication.shared, for: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
   
    @IBAction func btnFacebook_DidSelect(_ sender: UIButton) {
        let fbLoginManager = LoginManager()
        fbLoginManager.logOut()
        fbLoginManager.logIn(permissions: ["email","public_profile"], from: self, handler: { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : LoginManagerLoginResult = result!
                // if user cancel the login
                if (result?.isCancelled)!{
                    return
                }
                if(fbloginresult.grantedPermissions.contains("email"))
                {
                    self.getFBUserData()
                }
            }
        })
    }
    
    func getFBUserData(){
        if((AccessToken.current) != nil){
            GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: {(connection, result, error) -> Void in
                if error != nil{
                    print("FB error")
                    return
                }
                let fbLoginManager = LoginManager()
                fbLoginManager.logOut()
                print(result as Any)
                
                let fields = result as? [String:Any];
                let fullName = DataManager.getVal(fields?["name"]) as! String;
                let firstName = DataManager.getVal(fields?["first_name"]) as! String;
                let lastName = DataManager.getVal(fields?["last_name"]) as! String;
                let social_id = DataManager.getVal(fields?["id"]) as! String;
                let email = DataManager.getVal(fields?["email"]) as! String;
                let facebookProfileUrl = "http://graph.facebook.com/\(social_id)/picture?type=large"
                
//                if let pic = DataManager.getVal(fields?["picture"]) as? [String:Any] {
//                    if let data = DataManager.getVal(pic["data"]) as? [String:Any] {
//                        if let url = data["url"] as? String {
//                            let fbImgUrl = url
//                            self.dictSocialInfo["url"] = fbImgUrl
//                        }
//                    }
//                 }
                self.dictSocialInfo["name"] = fullName
                self.dictSocialInfo["email"] = email
                self.dictSocialInfo["social_id"] = social_id
                self.dictSocialInfo["first_name"] = firstName
                self.dictSocialInfo["last_name"] = lastName
                self.dictSocialInfo["image"] = facebookProfileUrl
                
                self.facebookApiCall()
            })
        }
    }
    
    @IBAction func btnForgotPassword_DidSelect(_ sender: UIButton) {
        let obj = self.storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordVC") as! ForgotPasswordVC
        self.navigationController?.pushViewController(obj, animated: true)
    }
    @IBAction func btnNewCustomer_DidSelect(_ sender: UIButton) {
//        let obj = self.storyboard?.instantiateViewController(withIdentifier: "SignUpVC") as! SignUpVC
//        self.navigationController?.pushViewController(obj, animated: true)
        
        let obj = self.storyboard?.instantiateViewController(withIdentifier: "WelcomeVC") as! WelcomeVC
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    func AppleLoginAPI(UserName:String!,Email:String!,AppleId:String!){
        self.showHud()
        let deviceToken = DataManager.getVal(Config().AppUserDefaults.object(forKey: "Devicetoken") as AnyObject?) as! String
        let parameterDictionary = NSMutableDictionary()
        parameterDictionary.setValue(UserName, forKey: "username")
        parameterDictionary.setValue(Email, forKey: "email")
        parameterDictionary.setValue(AppleId, forKey: "apple_id")
        parameterDictionary.setValue(deviceToken, forKey: "device_id")
        parameterDictionary.setValue("1", forKey: "device_type")
        
        print(parameterDictionary)
        
        let methodName = "AppleLogin"
        
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
            let subscriptionStatus  = DataManager.getVal(responseData?["subscribed_status"]) as! String
            
            if status == "1" {
                let response = DataManager.getVal(responseData?["data"]) as! [String: Any]
                if subscriptionStatus == "1" {
                    let objVC: UIViewController? = self.storyboard?.instantiateViewController(withIdentifier: "tabbar")
                    DataManager.saveinDefaults(response)
                    self.navigationController?.pushViewController(objVC!, animated: true)
                    Config().AppUserDefaults.set(true, forKey: "isCurrentUser")
                    Config().AppUserDefaults.set(true, forKey: "isIntroSkipped")
                    
                    
                } else {
                    let objVC = self.storyboard?.instantiateViewController(withIdentifier: "MembershipPlanVC") as! MembershipPlanVC
                    DataManager.saveinDefaults(response)
                    objVC.isFrom = "Login"
                    self.navigationController?.pushViewController(objVC, animated: true)
                }
            } else{
                self.view.makeToast(message: message)
            }
            self.clearHud()
        }
    }
    
    
    
    func facebookApiCall(){
         self.showHud()
        let parameterDictionary = NSMutableDictionary()
        parameterDictionary.setValue(dictSocialInfo["name"], forKey: "username")
        parameterDictionary.setValue(dictSocialInfo["email"], forKey: "email")
        parameterDictionary.setValue(dictSocialInfo["social_id"], forKey: "fb_id")
        parameterDictionary.setValue(dictSocialInfo["first_name"], forKey: "first_name")
        parameterDictionary.setValue(dictSocialInfo["image"], forKey: "profile_picture")
        //parameterDictionary.setValue( dictSocialInfo["url"] , forKey: "profile_picture")
         
        print(parameterDictionary)
        
        let methodName = "facebooklogin"
        
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
            let subscriptionStatus  = DataManager.getVal(responseData?["subscribed_status"]) as! String

            if status == "1" {
                let response = DataManager.getVal(responseData?["data"]) as! [String: Any]
                if subscriptionStatus == "1" {
                    let objVC: UIViewController? = self.storyboard?.instantiateViewController(withIdentifier: "tabbar")
                    DataManager.saveinDefaults(response)
                    self.navigationController?.pushViewController(objVC!, animated: true)
                    Config().AppUserDefaults.set(true, forKey: "isCurrentUser")
                } else {
                    let objVC = self.storyboard?.instantiateViewController(withIdentifier: "MembershipPlanVC") as! MembershipPlanVC
                    DataManager.saveinDefaults(response)
                    objVC.isFrom = "Login"
                    self.navigationController?.pushViewController(objVC, animated: true)
                }
                // let objVC: UIViewController? = self.storyboard?.instantiateViewController(withIdentifier: "tabbar")
                // DataManager.saveinDefaults(response)
                // Config().AppUserDefaults.set(true, forKey: "isCurrentUser")
                // self.navigationController?.pushViewController(objVC!, animated: true)
            } else{
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


extension SignInVC: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewControllerDidFinish(_ controller: PKPaymentAuthorizationViewController) {
        self.dismiss()
    }
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, completion: ((PKPaymentAuthorizationStatus) -> Void)) {
      completion(PKPaymentAuthorizationStatus.success)
        
    }
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didAuthorizePayment payment: PKPayment, handler completion: @escaping (PKPaymentAuthorizationResult) -> Void) {
        let token = payment.token
        let paymentData = token.paymentData
        
    }
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelect paymentMethod: PKPaymentMethod, handler completion: @escaping (PKPaymentRequestPaymentMethodUpdate) -> Void) {
        //self.dismiss()
        print("Three")
    }
    func paymentAuthorizationViewControllerWillAuthorizePayment(_ controller: PKPaymentAuthorizationViewController) {
        print("Four")
    }
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelect shippingMethod: PKShippingMethod, handler completion: @escaping (PKPaymentRequestShippingMethodUpdate) -> Void) {
        print("Five")
    }
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelectShippingContact contact: PKContact, handler completion: @escaping (PKPaymentRequestShippingContactUpdate) -> Void) {
        print("Six")
    }
    
    func paymentAuthorizationViewController(_ controller: PKPaymentAuthorizationViewController, didSelectShippingContact contact: PKContact, completion: @escaping (PKPaymentAuthorizationStatus, [PKShippingMethod], [PKPaymentSummaryItem]) -> Void) {
         print("\(#function)")
     }
}
@available(iOS 13.0, *)
extension SignInVC: ASAuthorizationControllerDelegate {

     // ASAuthorizationControllerDelegate function for authorization failed

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {

        print(error.localizedDescription)

    }

       // ASAuthorizationControllerDelegate function for successful authorization

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {

        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {

            // Create an account as per your requirement

            let appleId = appleIDCredential.user

            var appleUserFirstName = appleIDCredential.fullName?.givenName
            var appleUsernme = appleIDCredential.fullName?.familyName
            var appleUserEmail = appleIDCredential.email

            if appleUserEmail == nil {
                appleUserEmail = (UserDefaults.standard.value(forKey: "AppleUserEmail") as? String)
            }else{
                 UserDefaults.standard.set(appleUserEmail, forKey: "AppleUserEmail")
            }
            
            if  appleUserFirstName == nil  {
                appleUserFirstName = (UserDefaults.standard.value(forKey: "AppleUserFirstName") as? String)
            }else{
                   UserDefaults.standard.set(appleUserFirstName, forKey: "AppleUserFirstName")
            }
            
            if appleUsernme == nil  {
             appleUsernme = (UserDefaults.standard.value(forKey: "AppleUserLastName") as? String)
            }else{
                   UserDefaults.standard.set(appleUsernme, forKey: "AppleUserLastName")
            }
            var userName:String!
            userName = appleUserFirstName! + appleUsernme!
            self.AppleLoginAPI(UserName: userName, Email: appleUserEmail, AppleId: appleId)
            
        } else if let passwordCredential = authorization.credential as? ASPasswordCredential {

            let appleUsername = passwordCredential.user

            let applePassword = passwordCredential.password

            //Write your code

        }
    }

}


@available(iOS 13.0, *)
extension SignInVC: ASAuthorizationControllerPresentationContextProviding {

    //For present window

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {

        return self.view.window!

    }

}
