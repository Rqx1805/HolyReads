//
//  SignUp_IpadVC.swift
//  Holy Reads
//
//  Created by Ashish Soni on 20/07/20.
//  Copyright © 2020 Ajeet singh Rawat. All rights reserved.
//

import UIKit
import SVProgressHUD
import Photos
import FirebaseAnalytics
import PMAlertController
class SignUp_IpadVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    // MARK: - IBOutlet
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmPassword: UITextField!
    @IBOutlet weak var btnAgree: UIButton!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var btnSelectProfilePic: UIButton!
    
    //MARK: - Variables
    let imagePicker = UIImagePickerController()
    var imageData = Data()
    
    
    // MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        imagePicker.delegate = self
        imgProfile.layer.cornerRadius = self.imgProfile.frame.height/2
        btnSelectProfilePic.setImage(#imageLiteral(resourceName: "camera"), for: .normal)
    }
    // MARK: - ViewWillAppear
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    
    // MARK: - IBAction
    @IBAction func btnTermsCondition(_ sender: Any) {
        let obj = UIStoryboard(name: "MainStoryboard_iPad", bundle: nil).instantiateViewController(withIdentifier: "Webview_IpadVC") as! Webview_IpadVC
        obj.strTittle = "Terms & Conditions"
        obj.strURL = "pages/mobile_terms"
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    @IBAction func btnEditProfilePhoto(_ sender: UIButton) {
        
        let actionSheet = UIAlertController(title: "Choose option", message: "", preferredStyle: .actionSheet)
        let actionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let actionCamera = UIAlertAction(title: "TakePhoto", style: .default) { action in
            self.checkCameraPermission()
        }
        let actionLibrary = UIAlertAction(title: "PhotoLibrary", style: .default) { action in
            self.checkPhotoLibraryPermission()
        }
        actionSheet.addAction(actionCamera)
        actionSheet.addAction(actionLibrary)
        actionSheet.addAction(actionCancel)
        
        // this code use only in ipad if we are not using it then the app get close
        // code start from here
        
        actionSheet.popoverPresentationController?.sourceView = self.view
        actionSheet.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
        actionSheet.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        
        // code end's her
        
        self.present(actionSheet, animated: true, completion: nil)
        
        //        let alert:UIAlertController = UIAlertController(title: "Choose", message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        //        let gallaryAction = UIAlertAction(title: "Gallary", style: UIAlertAction.Style.default) {
        //            UIAlertAction in self.appDelegate.checkGalleryPermission{(GalleryPermission) in
        //                if GalleryPermission {
        //                    self.openGallary()
        //                }
        //            }
        //        }
        //        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertAction.Style.default) {
        //            UIAlertAction in self.appDelegate.checkCameraPermission{(cameraPermission) in
        //                if cameraPermission {
        //                    self.openCamera()
        //                }
        //            }
        //        }
        //        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
        //        alert.addAction(gallaryAction)
        //        alert.addAction(cameraAction)
        //        alert.addAction(cancelAction)
        //
        //        self.present(alert, animated: true, completion: nil)
    }
    
    //    func openGallary() {
    //        imagePicker.allowsEditing = false
    //        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
    //        present(imagePicker, animated: true, completion: nil)
    //    }
    //    func openCamera() {
    //        if UIImagePickerController.isSourceTypeAvailable(.camera){
    //            imagePicker.allowsEditing = false
    //            imagePicker.sourceType = UIImagePickerController.SourceType.camera
    //            present(imagePicker, animated: true, completion: nil)
    //        } else {
    //            print("Camera Not Present")
    //        }
    //    }
    
    @IBAction func btnSubmit_DidSelect(_ sender: UIButton) {
        self.view.endEditing(true)
        if DataManager.isConnectedToNetwork() {
            if ValidationClass().ValidateSignUpForm(self){
                self.showHud()
                let encoded__Question = (txtEmail.text! as NSString).data(using: String.Encoding.utf8.rawValue)
                let base64String = encoded__Question?.base64EncodedString(options: .init(rawValue: 0))
                print(base64String!) // bXkgcGxhbmkgdGV4dA==
                let parameterDictionary = NSMutableDictionary()
               
                
                let methodName = "signup"
                
                if imgProfile.image == nil {
                    parameterDictionary.setValue(DataManager.getVal(base64String) as! String, forKey: "email")
                    parameterDictionary.setValue(DataManager.getVal(txtPassword.text!) as! String, forKey: "password")
                    print(parameterDictionary)
                    DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
                        let status  = DataManager.getVal(responseData?["status"]) as! String
                        let message  = DataManager.getVal(responseData?["message"]) as! String
                        if status == "1" {
                            if status == "1" {
                                let response = DataManager.getVal(responseData?["data"]) as! [String: Any]
                                DataManager.saveinDefaults(response)
                                let myAlert = PMAlertController(title: "Holy Reads", description: "Your 5-day free trial has been started. \n Happy Reading!", image: UIImage(named: "welcome_logo"), style: .alert)
//                                      myAlert.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () -> Void in
//                                          print("Cancel")
//                                      }))
                                      
                                      myAlert.addAction(PMAlertAction(title: "Yes", style: .default, action: { () in
                                        let obj = UIStoryboard(name: "MainStoryboard_iPad", bundle: nil).instantiateViewController(withIdentifier: "OTPVerification_IpadVC") as! OTPVerification_IpadVC
                                        self.txtEmail.text = ""
                                        self.txtPassword.text = ""
                                        self.txtConfirmPassword.text = ""
                                        self.btnAgree.isSelected = false
                                        self.navigationController?.pushViewController(obj, animated: true)
                                      }))
                                            
                                                      
                                    self.present(myAlert, animated: true, completion: nil)
                                
                                // Config().AppUserDefaults.set(true, forKey: "isCurrentUser")
                            }
                            else{
                                self.view.makeToast(message: message)
                            }
                            self.clearHud()
                        } else if status == "0" {
                            self.clearHud()
                            self.view.makeToast(message: message)
                            // self.view.makeToast(message: message)
                        }
                    }
                } else {
                    parameterDictionary.setValue(DataManager.getVal(txtEmail.text!) as! String, forKey: "email")
                    parameterDictionary.setValue(DataManager.getVal(txtPassword.text!) as! String, forKey: "password")
                    print(parameterDictionary)
                    //For upload image
                    let dataArr = NSMutableArray()
                    let dataDict = NSMutableDictionary()
                    dataDict.setObject("profile_picture", forKey: "image" as NSCopying)
                    dataDict.setObject(resize(self.imgProfile.image!).pngData()!, forKey: "imageData" as NSCopying)
                    dataDict.setObject("png", forKey: "ext" as NSCopying)
                    dataArr.add(dataDict)
                    
                    DataManager.getAPIResponseFileSingleImage(parameterDictionary, methodName: methodName as NSString ,dataArray: dataArr){(responseData,error)-> Void in
                        let status  = DataManager.getVal(responseData?["status"]) as! String
                        let message  = DataManager.getVal(responseData?["message"]) as! String
                        
                        if status == "1" {
                            let response = DataManager.getVal(responseData?["data"]) as! [String: Any]
                            DataManager.saveinDefaults(response)
                            let myAlert = PMAlertController(title: "Holy Reads", description: "Your 5-day free trial has been started.\n Happy Reading!", image: UIImage(named: "welcome_logo"), style: .alert)
//                                  myAlert.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () -> Void in
//                                      print("Cancel")
//                                  }))
                                  
                                  myAlert.addAction(PMAlertAction(title: "Yes", style: .default, action: { () in
                                    let obj = UIStoryboard(name: "MainStoryboard_iPad", bundle: nil).instantiateViewController(withIdentifier: "OTPVerification_IpadVC") as! OTPVerification_IpadVC
                                    self.txtEmail.text = ""
                                    self.txtPassword.text = ""
                                    self.txtConfirmPassword.text = ""
                                    self.btnAgree.isSelected = false
                                    self.navigationController?.pushViewController(obj, animated: true)
                                    Analytics.logEvent(AnalyticsEventSignUp, parameters: [
                                        AnalyticsParameterMethod: self.method
                                        ])
                                self.present(myAlert, animated: true, completion: nil)
                                  }))
                            
                        } else{
                            self.view.makeToast(message: message)
                        }
                        self.clearHud()
                    }
                }
            }
        } else {
            self.view.makeToast(message: "No Internet Connection.")
            
        }
        
    }
    
    @IBAction func btnSignIn_DidSelect(_ sender: UIButton){
        let obj = UIStoryboard(name: "MainStoryboard_iPad", bundle: nil).instantiateViewController(withIdentifier: "SignIn_IpadVC") as! SignIn_IpadVC
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    @IBAction func btnAgree_didSelect(_ sender: UIButton) {
        self.view.endEditing(true)
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func btnAcceptTermsConditions_DidSelect(_ sender: UIButton) {
        
    }
    
    @IBAction func btnClose_DidSelect(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func checkPhotoLibraryPermission() {
        //           let status = PHPhotoLibrary.authorizationStatus()
        //           switch status {
        //           case .authorized: openGallary()
        //           case .denied: showPhotoLibraryPermissionAlert()
        //           case .notDetermined: openGallary()
        //           default: showPhotoLibraryPermissionAlert()
        //           }
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized: self.openGallary()
            case .denied, .restricted: self.showPhotoLibraryPermissionAlert()
            case .notDetermined: self.openGallary()
            default: self.showPhotoLibraryPermissionAlert()
            }
        }
    }
    
    func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized: openCamera()
        case .denied: showCameraPermissionAlert()
        case .notDetermined: openCamera()
        default: showCameraPermissionAlert()
        }
    }
    func showCameraPermissionAlert() {
        let alert = UIAlertController(title: "Holy reads", message: "Holy reads would like to access your camera to update your photos", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Settings", style: .cancel, handler: { (error) in
            let url = URL(string: UIApplication.openSettingsURLString)
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url!, options: [:], completionHandler: { (error) in
                })
            } else {
                UIApplication.shared.openURL(url!)
            }
        }))
        appDelegate.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    func showPhotoLibraryPermissionAlert() {
        let alert = UIAlertController(title: "Holy reads", message: "Holy reads would like to access your photo library to update your profile", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "Settings", style: .cancel, handler: { (error) in
            let url = URL(string: UIApplication.openSettingsURLString)
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url!, options: [:], completionHandler: { (error) in
                })
            } else {
                UIApplication.shared.openURL(url!)
            }
        }))
        appDelegate.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    func openGallary() {
        DispatchQueue.main.async() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.allowsEditing = true
            self.imagePicker.delegate = self
            self.present(self.imagePicker, animated: true) {
                self.navigationController?.navigationBar.isHidden = true
            }
        } else {
            self.showAlert("Photo library is not available on this device", nil)
        }
        }
    }
    
    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            self.showAlert("Camera is not available on this device", nil)
        }
    }
    
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let pickedImage = info[.originalImage] as? UIImage
        imgProfile.image = pickedImage
        if imgProfile != nil{
            btnSelectProfilePic.setImage(UIImage.init(named: ""), for: .normal)
        }
        imageData = pickedImage?.jpegData(compressionQuality: 0.8)! ?? Data()
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func cancel(){
        print("Cancel Clicked")
    }
}

