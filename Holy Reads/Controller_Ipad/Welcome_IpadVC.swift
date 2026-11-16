//
//  Welcome_IpadVC.swift
//  Holy Reads
//
//  Created by Ashish Soni on 20/07/20.
//  Copyright © 2020 Ajeet singh Rawat. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import AuthenticationServices
import LocalAuthentication
class Welcome_IpadVC: UIViewController {
    
    @IBOutlet weak var viewsignUp: UIView!
    @IBOutlet weak var facebookBtn: UIButton!
    var dictSocialInfo = [String:Any]()
    // MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        viewsignUp.clipsToBounds = true
        viewsignUp.layer.cornerRadius = 25
        if #available(iOS 11.0, *) {
            viewsignUp.layer.maskedCorners = [  .layerMinXMaxYCorner, .layerMinXMinYCorner ]
        } else {
            // Fallback on earlier versions
        }
    }
    
    // MARK: - IBAction
    
    @IBAction func btnSignUp_DidSelect(_ sender: UIButton) {
        let obj = UIStoryboard(name: "MainStoryboard_iPad", bundle: nil).instantiateViewController(withIdentifier: "SignUp_IpadVC") as! SignUp_IpadVC
        self.navigationController?.pushViewController(obj, animated: true)
        UserDefaults.standard.set(true, forKey: "isIntroSkipped")
        UserDefaults.standard.synchronize()
    }
    
    @IBAction func signAction(_ sender: Any) {
        let obj = UIStoryboard(name: "MainStoryboard_iPad", bundle: nil).instantiateViewController(withIdentifier: "SignIn_IpadVC") as! SignIn_IpadVC
        self.navigationController?.pushViewController(obj, animated: true)
        UserDefaults.standard.set(true, forKey: "isIntroSkipped")
        UserDefaults.standard.synchronize()
     
    }
    
    
    
    @IBAction func signBtnAction(_ sender: Any) {
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
        
        
//        let obj = UIStoryboard(name: "MainStoryboard_iPad", bundle: nil).instantiateViewController(withIdentifier: "SignIn_IpadVC") as! SignIn_IpadVC
//        self.navigationController?.pushViewController(obj, animated: true)
//        UserDefaults.standard.set(true, forKey: "isIntroSkipped")
//        UserDefaults.standard.synchronize()
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
    @IBAction func btnGoogle_DidSelect(_ sender: UIButton) {
        
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
                    let objVC: UIViewController? = UIStoryboard(name: "MainStoryboard_iPad", bundle: nil).instantiateViewController(withIdentifier: "TabBar_IpadVC")
                    DataManager.saveinDefaults(response)
                    self.navigationController?.pushViewController(objVC!, animated: true)
                    Config().AppUserDefaults.set(true, forKey: "isCurrentUser")
                    Config().AppUserDefaults.set(true, forKey: "isIntroSkipped")
                    
                    
                } else {
                    let objVC = UIStoryboard(name: "MainStoryboard_iPad", bundle: nil).instantiateViewController(withIdentifier: "MembershipPlan_IpadVC") as! MembershipPlan_IpadVC
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
    
}

@available(iOS 13.0, *)
extension Welcome_IpadVC: ASAuthorizationControllerDelegate {

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
                appleUserEmail = (UserDefaults.standard.value(forKey: "AppleUserEmail") as! String)
            }else{
                 UserDefaults.standard.set(appleUserEmail, forKey: "AppleUserEmail")
            }
            
            if  appleUserFirstName == nil  {
                appleUserFirstName = (UserDefaults.standard.value(forKey: "AppleUserFirstName") as! String)
            }else{
                   UserDefaults.standard.set(appleUserFirstName, forKey: "AppleUserFirstName")
            }
            
            if appleUsernme == nil  {
             appleUsernme = (UserDefaults.standard.value(forKey: "AppleUserLastName") as! String)
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
extension Welcome_IpadVC: ASAuthorizationControllerPresentationContextProviding {

    //For present window

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {

        return self.view.window!

    }

}
