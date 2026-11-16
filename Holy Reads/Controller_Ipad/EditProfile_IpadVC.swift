//
//  EditProfile_IpadVC.swift
//  Holy Reads
//
//  Created by Ashish Soni on 20/07/20.
//  Copyright © 2020 Ajeet singh Rawat. All rights reserved.
//

import UIKit
import SDWebImage
import SystemConfiguration
import Photos

class EditProfile_IpadVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var txtUserName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var imgProfile: UIImageView!
    
    //MARK: - Variables
    let imagePicker = UIImagePickerController()
    var imageData = Data()
    var dicUserDetails = [String:Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.imagePicker.delegate = self
        self.imgProfile.layer.cornerRadius = 70
        self.imgProfile.clipsToBounds = true
        getProfileData()
        
    }
    
    // MARK: - NavigationBar Buttons
    @IBAction func btnBack_DidSelect(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - IBAction
    
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
    }
    
    func checkPhotoLibraryPermission() {
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
    
    
    
    //    func openGallary() {
    //        self.imagePicker.allowsEditing = false
    //        self.imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
    //        self.present(imagePicker, animated: true, completion: nil)
    //    }
    //    func openCamera() {
    //        DispatchQueue.main.async {
    //            if UIImagePickerController.isSourceTypeAvailable(.camera){
    //                self.imagePicker.allowsEditing = false
    //                self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
    //                self.present(self.imagePicker, animated: true, completion: nil)
    //            } else {
    //                print("Camera Not Present")
    //            }
    //        }
    //    }
    
    @IBAction func btnUpdate_DidSelect(_ sender: UIButton) {
        self.view.endEditing(true)
        if ValidationClass().ValidateEditProfileForm(self){
            self.showHud()
            let parameterDictionary = NSMutableDictionary()
            
            let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
            
            parameterDictionary.setValue(DataManager.getVal(txtUserName.text!) as! String, forKey: "username")
            parameterDictionary.setValue(DataManager.getVal(user_id) as! String, forKey: "user_id")
            parameterDictionary.setValue(DataManager.getVal(txtEmail.text) as! String, forKey: "email")
            
            print(parameterDictionary)
            
            //For upload image
            let dataArr = NSMutableArray()
            let dataDict = NSMutableDictionary()
            dataDict.setObject("profile_picture", forKey: "image" as NSCopying)
            dataDict.setObject(resize(self.imgProfile.image!).pngData()!, forKey: "imageData" as NSCopying)
            dataDict.setObject("png", forKey: "ext" as NSCopying)
            dataArr.add(dataDict)
            
            let methodName = "edit_profile"
            
            DataManager.getAPIResponseFileSingleImage(parameterDictionary, methodName: methodName as NSString ,dataArray: dataArr){(responseData,error)-> Void in
                let status  = DataManager.getVal(responseData?["status"]) as! String
                let message  = DataManager.getVal(responseData?["message"]) as! String
                
                if status == "1" {
                    let response = DataManager.getVal(responseData?["data"]) as! [String: Any]
                    DataManager.saveinDefaults(response)
                    self.navigationController?.popViewController(animated: true)
                    // Config().AppUserDefaults.set(true, forKey: "isCurrentUser")
                } else{
                    self.view.makeToast(message: message)
                }
                self.clearHud()
            }
        }
    }
    
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let pickedImage = info[.originalImage] as? UIImage
        imgProfile.image = pickedImage
        imageData = pickedImage?.jpegData(compressionQuality: 0.8)! ?? Data()
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    func cancel(){
        print("Cancel Clicked")
    }
    
    
    //MARK:- API Calling
    func getProfileData() {
        self.showHud()
        let parameterDictionary = NSMutableDictionary()
        let userId = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        parameterDictionary.setValue(userId, forKey: "user_id")
        
        let methodName = "profile_details"
        
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
            
            if status == "1" {
                let response = DataManager.getVal(responseData?["data"]) as! [String: Any]
                self.dicUserDetails = response
                self.setProfileData()
                
            }else{
                self.view.makeToast(message: message)
            }
            self.clearHud()
        }
    }
    
    func setProfileData()  {
        self.txtUserName.text = dicUserDetails["username"] as? String
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
