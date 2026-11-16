//
//  SignIn_IpadVC.swift
//  Holy Reads
//
//  Created by Ashish Soni on 20/07/20.
//  Copyright © 2020 Ajeet singh Rawat. All rights reserved.
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
class SignIn_IpadVC: UIViewController {
    
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
    
    @IBAction func appleBtnAction(_ sender: Any) {
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
        //        let request = PKPaymentRequest()
        //        let paymentItem = PKPaymentSummaryItem.init(label: "Hello", amount: 0.01)
        //        let paymentNetworks = [PKPaymentNetwork.amex, .discover, .masterCard, .visa,]
        //        request.currencyCode = "USD"
        //        request.countryCode = "US"
        //        request.merchantIdentifier = "merchant.merchant.com.HolyReads.App"
        //        request.merchantCapabilities = PKMerchantCapability.capability3DS // 4
        //        request.supportedNetworks = paymentNetworks // 5
        //        request.paymentSummaryItems = [paymentItem] // 6
        //
        //        let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request)!
        //        applePayController.delegate = self
        //        self.present(applePayController, animated: true, completion: nil)
        
        
        //        let request = PKPaymentRequest()
        //        let paymentItem = PKPaymentSummaryItem.init(label: "Holy Reads", amount: 1)
        //        let SupportedPaymentNetworks = [PKPaymentNetwork.visa, PKPaymentNetwork.masterCard, PKPaymentNetwork.amex]
        //
        //        let paymentNetworks = [PKPaymentNetwork.amex, PKPaymentNetwork.discover, PKPaymentNetwork.masterCard, PKPaymentNetwork.visa]
        //
        //        if PKPaymentAuthorizationController.canMakePayments(usingNetworks:SupportedPaymentNetworks ) {
        //            request.currencyCode = "USD"
        //            request.countryCode = "US"
        //            request.merchantIdentifier = "merchant.merchant.com.HolyReads.App"
        //            request.merchantCapabilities = PKMerchantCapability.capability3DS // 4
        //            request.supportedNetworks = paymentNetworks // 5
        //            request.paymentSummaryItems = [paymentItem] // 6
        //        }
        //
        //        if PKPaymentAuthorizationViewController.canMakePayments(usingNetworks: SupportedPaymentNetworks) {
        //            guard let paymentVC = PKPaymentAuthorizationViewController(paymentRequest: request) else {
        //                displayDefaultAlert(title: "Error", message: "Unable to present Apple Pay authorization.")
        //                return
        //            }
        //            paymentVC.delegate = self as! PKPaymentAuthorizationViewControllerDelegate
        //            self.present(paymentVC, animated: true, completion: nil)
        //        }
        
        //        let request = Stripe.paymentRequest(withMerchantIdentifier: "merchant.merchant.com.HolyReads.App")
        //        request.paymentSummaryItems = [PKPaymentSummaryItem(label: "Holy Reads", amount: 0.01)]
        //        request.requiredBillingAddressFields = PKAddressField.all
        //        request.requiredShippingAddressFields = PKAddressField(rawValue: PKAddressField.postalAddress.rawValue | PKAddressField.email.rawValue)
        //        request.countryCode = "US"
        //        request.currencyCode = "USD"
        //        request.merchantCapabilities = PKMerchantCapability(rawValue: PKMerchantCapability.capabilityEMV.rawValue | PKMerchantCapability.capability3DS.rawValue)
        //        request.supportedNetworks = [.amex, .masterCard, .visa]
        //
        //        if Stripe.canSubmitPaymentRequest(request) {
        //            let paymentController = PKPaymentAuthorizationViewController(paymentRequest: request)!
        //            paymentController.delegate = self
        //            self.navigationController?.present(paymentController, animated: true, completion: nil)
        //        } else {
        //            //popup
        //            // DHUtils.alert("Apple Pay", message: "Please add your credit card to Passbook.", inViewController: self)
        //        }
        
        
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
                            let myAlert = PMAlertController(title: "Holy Reads", description: "Device Limit Exceeded! \n You can be logged into one device at a time. Would you like to log out from other devices?", image: UIImage(named: "welcome_logo"), style: .alert)
                            
                            myAlert.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () -> Void in
                                print("Cancel")
                            }))
                            
                            myAlert.addAction(PMAlertAction(title: "Yes", style: .default, action: { () in
                                let response = DataManager.getVal(responseData?["data"]) as! [String: Any]
                                DataManager.saveinDefaults(response)
                                if response["verified_status"] as! Int == 2 {
                                  let objVC = UIStoryboard(name: "MainStoryboard_iPad", bundle: nil).instantiateViewController(withIdentifier: "OTPVerification_IpadVC") as! OTPVerification_IpadVC
                                    objVC.isFrom = "Login"
                                    objVC.subscriptionStatus = subscriptionStatus
                                    objVC.freetrialstatus = freetrialStatus
                                    objVC.strEmail = self.txtEmail.text!
                                    self.navigationController?.pushViewController(objVC, animated: true)
                                } else if response["verified_status"] as! Int == 1 {
                                    let userid = response["user_id"] as! Int
                                    if subscriptionStatus == "1" {
                                      let objVC = UIStoryboard(name: "MainStoryboard_iPad", bundle: nil).instantiateViewController(withIdentifier: "TabBar_IpadVC") as? UITabBarController
                                        self.navigationController?.pushViewController(objVC!, animated: true)
                                        Config().AppUserDefaults.set(true, forKey: "isCurrentUser")
                                        self.GetdeviceLinit(userid: userid)
                                        Analytics.logEvent(AnalyticsEventLogin, parameters: [
                                            AnalyticsParameterMethod: self.method
                                            ])
                                    }else {
                                      let objVC = UIStoryboard(name: "MainStoryboard_iPad", bundle: nil).instantiateViewController(withIdentifier: "TabBar_IpadVC") as? UITabBarController
                                        self.navigationController?.pushViewController(objVC!, animated: true)
                                        Config().AppUserDefaults.set(true, forKey: "isCurrentUser")
                                        self.GetdeviceLinit(userid: userid)
                                        Analytics.logEvent(AnalyticsEventLogin, parameters: [
                                            AnalyticsParameterMethod: self.method
                                            ])
                                    }
                                }
                            }))
                            
                            self.present(myAlert, animated: true, completion: nil)
                                  }else {
                                      let response = DataManager.getVal(responseData?["data"]) as! [String: Any]
                                    
                                      DataManager.saveinDefaults(response)
                                      let userid = response["user_id"] as! Int
                                      if response["verified_status"] as! Int == 2 {
                                        let objVC = UIStoryboard(name: "MainStoryboard_iPad", bundle: nil).instantiateViewController(withIdentifier: "OTPVerification_IpadVC") as! OTPVerification_IpadVC
                                          objVC.isFrom = "Login"
                                          objVC.subscriptionStatus = subscriptionStatus
                                          objVC.freetrialstatus = freetrialStatus
                                          objVC.strEmail = self.txtEmail.text!
                                          self.navigationController?.pushViewController(objVC, animated: true)
                                      } else if response["verified_status"] as! Int == 1 {
                                          if subscriptionStatus == "1" {
                                            let objVC = UIStoryboard(name: "MainStoryboard_iPad", bundle: nil).instantiateViewController(withIdentifier: "TabBar_IpadVC") as? UITabBarController
                                              self.navigationController?.pushViewController(objVC!, animated: true)
                                              Config().AppUserDefaults.set(true, forKey: "isCurrentUser")
                                              self.GetdeviceLinit(userid: userid)
                                              Analytics.logEvent(AnalyticsEventLogin, parameters: [
                                                  AnalyticsParameterMethod: self.method
                                                  ])
                                           } else {
                                              if freetrialStatus == "1" {
                                                let objVC = UIStoryboard(name: "MainStoryboard_iPad", bundle: nil).instantiateViewController(withIdentifier: "TabBar_IpadVC") as? UITabBarController
                                                  self.navigationController?.pushViewController(objVC!, animated: true)
                                                  Config().AppUserDefaults.set(true, forKey: "isCurrentUser")
                                                self.GetdeviceLinit(userid: userid)
                                                  Analytics.logEvent(AnalyticsEventLogin, parameters: [
                                                      AnalyticsParameterMethod: self.method
                                                      ])
                                              }else {
                                                let myAlert = PMAlertController(title: "Holy Reads", description: message, image: UIImage(named: "welcome_logo"), style: .alert)
                                              
                                                
                                                myAlert.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () -> Void in
                                                    print("Cancel")
                                                }))
                                                
                                                myAlert.addAction(PMAlertAction(title: "Yes", style: .default, action: { () in
                                                    let objVC = UIStoryboard(name: "MainStoryboard_iPad", bundle: nil).instantiateViewController(withIdentifier: "MembershipPlanVCNewIPAD") as! MembershipPlanVCNewIPAD
                                                    objVC.isFrom = "Login"
                                                    self.navigationController?.pushViewController(objVC, animated: true)
                                                }))
                                              

                                                self.present(myAlert, animated: true, completion: nil)
                                              }
                                              
                                          }
                                      }
                                  }
                    }else {
                        let myAlert = PMAlertController(title: "Holy Reads", description: message, image: UIImage(named: "welcome_logo"), style: .alert)
                        
                        myAlert.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () -> Void in
                            print("Cancel")
                        }))
                        
                        myAlert.addAction(PMAlertAction(title: "Yes", style: .default, action: { () in
                            let objVC = UIStoryboard(name: "MainStoryboard_iPad", bundle: nil).instantiateViewController(withIdentifier: "MembershipPlanVCNewIPAD") as! MembershipPlanVCNewIPAD
                            objVC.isFrom = "Login"
                            self.navigationController?.pushViewController(objVC, animated: true)
                        }))
                        
                        self.present(myAlert, animated: true, completion: nil)
                    }
                    
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
        let obj = UIStoryboard(name: "MainStoryboard_iPad", bundle: nil).instantiateViewController(withIdentifier: "ForgotPassword_IpadVC") as! ForgotPassword_IpadVC
        self.navigationController?.pushViewController(obj, animated: true)
    }
    @IBAction func btnNewCustomer_DidSelect(_ sender: UIButton) {
//        let obj = UIStoryboard(name: "MainStoryboard_iPad", bundle: nil).instantiateViewController(withIdentifier: "SignUp_IpadVC") as! SignUp_IpadVC
//        self.navigationController?.pushViewController(obj, animated: true)
        
        let obj = UIStoryboard(name: "MainStoryboard_iPad", bundle: nil).instantiateViewController(withIdentifier: "Welcome_IpadVC") as! Welcome_IpadVC
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
                    let objVC: UIViewController? = UIStoryboard(name: "MainStoryboard_iPad", bundle: nil).instantiateViewController(withIdentifier: "TabBar_IpadVC")
                    DataManager.saveinDefaults(response)
                    self.navigationController?.pushViewController(objVC!, animated: true)
                    Config().AppUserDefaults.set(true, forKey: "isCurrentUser")
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


extension SignIn_IpadVC: PKPaymentAuthorizationViewControllerDelegate {
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
extension SignIn_IpadVC: ASAuthorizationControllerDelegate {

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
extension SignIn_IpadVC: ASAuthorizationControllerPresentationContextProviding {

    //For present window

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {

        return self.view.window!

    }

}
