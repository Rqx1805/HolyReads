//
//  AppDelegate.swift
//  Holy Reads
//
//  Created by mac-14 on 30/08/19.
//  Copyright © 2019 Ajeet singh Rawat. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
import IQKeyboardManagerSwift
import CoreData
import EvernoteSDK
import UserNotifications
import Firebase
import FirebaseMessaging
import FirebaseCore
import FirebaseInstanceID
import FirebaseMessaging
import GoogleUtilities
import GoogleMaps
import GooglePlaces
import DeviceCheck

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate,MessagingDelegate {
    
    var window: UIWindow?
    var deafults: UserDefaults!
    var navigationController = UINavigationController()
    var initialViewController: UIViewController?
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let IpadStoryBoard = UIStoryboard(name: "MainStoryboard_iPad", bundle: nil)
    var DocumentDirectoryUrl : URL! = nil
    var noteStr:String!
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UserDefaults.standard.removeObject(forKey: "SubId")
        
        let currentDevice = DCDevice.current
        if currentDevice.isSupported {
        currentDevice.generateToken(completionHandler: { (data, error) in
            if let tokenData = data {
                print("Token: \(tokenData)")
            } else {
                print("Error: \(error?.localizedDescription ?? "")")
            }
            
        })
        }
           
        // Override point for customization after application launch.
        
        //                UIFont.familyNames.forEach({ familyName in
        //                    let fontNames = UIFont.fontNames(forFamilyName: familyName)
        //                    print(familyName, fontNames)
        //                })
        //EverNote
        
        // Ashish
        //        var instagramHooks = "https://mail.yandex.com/?uid=1130000032606157#inbox"
        //        var instagramUrl = NSURL(string: instagramHooks)
        //        if UIApplication.shared.canOpenURL(instagramUrl! as URL)
        //        {
        //            UIApplication.shared.openURL(instagramUrl! as URL)
        //
        //        } else {
        //            //redirect to safari because the user doesn't have Instagram
        //            UIApplication.shared.openURL(NSURL(string: "https://mail.yandex.com/?uid=1130000032606157#inbox")! as URL)
        //        }
        GMSServices.provideAPIKey("AIzaSyBszIcP5AH95xQiaVsmefl65wtvGAaGjYk")
        GMSPlacesClient.provideAPIKey("AIzaSyB3F_B_YH0XuWy_EB-zK-w4hyNJ1vjEJqQ")
        FirebaseApp.configure()
        
        if DataManager.isConnectedToNetwork() {
        //    Config().deleteAllRecords(tbaleName: "FolioReaderdatabase")
           // UserDefaults.standard.removeObject(forKey: "OF")
        }else{
            print("Ashish")
            
        }    
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {__, _  in })
            // For iOS 10 data message (sent via FCM
            
            Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        //FirebaseApp.configure()
        application.registerForRemoteNotifications()
        if (UIDevice.current.userInterfaceIdiom == .pad){
            print("Ipad")
        }else {
            print("Iphone")
        }
        UserDefaults.standard.removeObject(forKey: "Pgc")
        UserDefaults.standard.removeObject(forKey: "PGTxt")
//        guard let gai = GAI.sharedInstance() else {
//            assert(false, "Google Analytics not configured correctly")
//        }
//        guard let gai = GAI.sharedInstance() else {
//                  assert(false, "Google Analytics not configured correctly")
//              }
        let gai = GAI.sharedInstance()
        gai!.tracker(withTrackingId: "UA-25001600-1")
        // Optional: automatically report uncaught exceptions.
        gai!.trackUncaughtExceptions = true

        // Optional: set Logger to VERBOSE for debug information.
        // Remove before app release.
        gai!.logger.logLevel = .verbose;
        
        UserDefaults.standard.removeObject(forKey: "position")
        UserDefaults.standard.removeObject(forKey: "SAV")
//        guard let gai = GAI.sharedInstance() else { return }
//           // assert(false, "Google Analytics not configured correctly")
//      //  }
//
//        gai.tracker(withTrackingId: "UA-25001600-1")
//        // Optional: automatically report uncaught exceptions.
//        gai.trackUncaughtExceptions = true
//
//        // Optional: set Logger to VERBOSE for debug information.
//        // Remove before app release.
//        gai.logger.logLevel = .verbose;
        
        ENSession.setSharedSessionConsumerKey("ajeet-6718", consumerSecret: "92cc6c55ea712728", optionalHost: ENSessionHostSandbox)
        
        DocumentDirectoryUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 4.0))
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.toolbarTintColor = UIColor.init(red: 0/255.0, green: 111/255.0, blue: 255/255.0, alpha: 1)
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        self.navigationController.navigationBar.isHidden = true
        self.deafults = UserDefaults.standard
        self.showMain()
        return true
    }
    func applicationSignificantTimeChange(_ application: UIApplication) {
        print("kis")
    }
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        print("url \(url)")
        print("url host :\(url.host!)")
        print("url path :\(url.path)")
        
        let urlPath : String = (url.path as String?)!
        let urlHost : String = (url.host as String?)!
        if(urlHost != "holyRead") {
            print("Host is not correct")
            return false
        }
        if(urlPath == "/inner"){
            if UserDefaults.standard.value(forKey: "isCurrentUser") as? Bool ?? false  {
                if (UIDevice.current.userInterfaceIdiom == .pad){
                    initialViewController =  self.IpadStoryBoard.instantiateViewController(withIdentifier: "TabBar_IpadVC")
                }else{
                    initialViewController =  self.storyboard.instantiateViewController(withIdentifier: "tabbar")
                }
                Config().AppUserDefaults.set(true, forKey: "isCurrentUser")
            } else {
                if (UIDevice.current.userInterfaceIdiom == .pad){
                    initialViewController = IpadStoryBoard.instantiateViewController(withIdentifier: "SignIn_IpadVC") as! SignIn_IpadVC
                }else{
                    initialViewController = storyboard.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
                }
                
            }
            navigationController = UINavigationController.init(rootViewController: initialViewController!)
            navigationController.navigationBar.isHidden = true
            self.window?.rootViewController = navigationController
        } else if (urlPath == "/about"){
            
        }
        self.window?.makeKeyAndVisible()
        return true
    }
    
    func application(received remoteMessage: MessagingRemoteMessage) {
        print(remoteMessage.appData)
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
            }
            Messaging.messaging().apnsToken = deviceToken
            Messaging.messaging().isAutoInitEnabled = true
        }
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        let deafults = UserDefaults.standard
        deafults.set(fcmToken, forKey: "Devicetoken")
        deafults.synchronize()
        print("Firebase registration token: \(fcmToken)")
    }
    
    func  application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("i am not available in simulator \(error)")
    }
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("test")
        
    }
    
    // this method enables user permission

    func configureNotification(application: UIApplication) {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.badge, .sound, .alert]) { granted, _ in
                guard granted else { return }
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
    //MARK:- Click on notification click
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let userInfo = userInfo as! [String: Any]
        print(userInfo)
        //        var count:Int!
        //        count = userInfo["badge"] as? Int
        //        application.applicationIconBadgeNumber = count
        //let type = DataManager.getVal(userInfo["type"]) as! String
        
    }
    private func userNotificationCenter(center: UNUserNotificationCenter, willPresentNotification notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        //Handle the notification
        completionHandler(
            [UNNotificationPresentationOptions.alert,
             UNNotificationPresentationOptions.sound,
             UNNotificationPresentationOptions.badge])
        
    }
    
    //MARK:- Function will call when application in active state
    func userNotificationCenter(_ center: UNUserNotificationCenter,willPresent notification: UNNotification,withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
        let userInfo = notification.request.content.userInfo as! [String: Any]
        print(userInfo)
        
        //let type = DataManager.getVal(userInfo["type"]) as! String
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        UserDefaults.standard.set(0, forKey: "SelectedCategory")
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    
    func showFirstPage(){
        if (UIDevice.current.userInterfaceIdiom == .pad){
            initialViewController = IpadStoryBoard.instantiateViewController(withIdentifier: "SignIn_IpadVC") as! SignIn_IpadVC
        }else{
            initialViewController = storyboard.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
        }
        let navigationController = UINavigationController(rootViewController: initialViewController!)
        window?.rootViewController = navigationController
        navigationController.isNavigationBarHidden = true
    }
    
    func showMain(){
        if let isIntroSkipped = deafults.value(forKey: "isIntroSkipped") as? Bool, isIntroSkipped == true {
            if let userLoggedIn = Config().AppUserDefaults.value(forKey:"isCurrentUser") as? Bool, userLoggedIn == true {
                noteStr = "OldNewEnter"
                let defaults = UserDefaults.standard
                defaults.setValue(noteStr, forKey: "EnterFirst")
                defaults.synchronize()
                if (UIDevice.current.userInterfaceIdiom == .pad){
                    initialViewController = IpadStoryBoard.instantiateViewController(withIdentifier: "TabBar_IpadVC") as! UITabBarController
                }else{
                    initialViewController = storyboard.instantiateViewController(withIdentifier: "tabbar") as! UITabBarController
                }
            } else{
                if (UIDevice.current.userInterfaceIdiom == .pad){
                    initialViewController = IpadStoryBoard.instantiateViewController(withIdentifier: "SignIn_IpadVC") as! SignIn_IpadVC
                }else{
                    initialViewController = storyboard.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
                }
            }
        } else{
            noteStr = "FirstNewEnter"
            let defaults = UserDefaults.standard
            defaults.setValue(noteStr, forKey: "EnterFirst")
            defaults.setValue("FirstShow", forKey: "videoSkipped")
            defaults.synchronize()
            if (UIDevice.current.userInterfaceIdiom == .pad){
                initialViewController = IpadStoryBoard.instantiateViewController(withIdentifier: "Introduction_IpadVC") as! Introduction_IpadVC
            }else{
                initialViewController = storyboard.instantiateViewController(withIdentifier: "IntroductionVC") as! IntroductionVC
            }
        }
        navigationController = UINavigationController.init(rootViewController: initialViewController!)
        navigationController.navigationBar.isHidden = true
        self.window?.rootViewController = navigationController
        self.window?.makeKeyAndVisible()
    }
    
    func checkCameraPermission(completionHandler:@escaping (Bool) -> ()) {
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.authorized {
            completionHandler(true)
            // Already Authorized
        } else {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted: Bool) -> Void in
                if granted == true {
                    completionHandler(true)
                    // User granted
                } else {
                    //                    self.TabLogin.selectedIndex = self.selectTab
                    completionHandler(false)
                    let alert:UIAlertController=UIAlertController(title: "Permissions", message: "App doesn't have camera access permissions. Please go to settings and allow Holy Reads for camera access permissions.", preferredStyle: UIAlertController.Style.alert)
                    
                    let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                            return
                        }
                        
                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                    print("Settings opened: \(success)") // Prints true
                                })
                            } else {
                                // Fallback on earlier versions
                            }
                        }
                    }
                    alert.addAction(settingsAction)
                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
                    {
                        UIAlertAction in
                        
                    }
                    // Add the actions
                    alert.addAction(cancelAction)
                    self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                    // User Rejected
                }
            })
        }
    }
    
    //MARK: - checkGalleryPermission
    
    func checkGalleryPermission(completionHandler:@escaping (Bool) -> ())
    {
        let status: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        // check the status for PHAuthorizationStatusAuthorized or ALAuthorizationStatusDenied e.g
        if status == PHAuthorizationStatus.notDetermined
        {
            PHPhotoLibrary.requestAuthorization({ (statusinner) in
                if statusinner != PHAuthorizationStatus.authorized {
                    //show alert for asking the user to give permission
                    completionHandler(false)
                    let alert:UIAlertController=UIAlertController(title: "Permissions", message: "App doesn't have gallery access permissions. Please go to settings and allow Holy Reads for gallery access permissions.", preferredStyle: UIAlertController.Style.alert)
                    
                    let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                            return
                        }
                        
                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            if #available(iOS 10.0, *) {
                                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                    print("Settings opened: \(success)") // Prints true
                                })
                            } else {
                                // Fallback on earlier versions
                            }
                        }
                    }
                    alert.addAction(settingsAction)
                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) {
                        UIAlertAction in
                    }
                    // Add the actions
                    alert.addAction(cancelAction)
                    self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                }
                else {
                    completionHandler(true)
                }
            })
        }
        else if status != PHAuthorizationStatus.authorized {
            //show alert for asking the user to give permission
            completionHandler(false)
            let alert:UIAlertController=UIAlertController(title: "Permissions", message: "App doesn't have gallery access permissions. Please go to settings and allow Holy Reads for gallery access permissions.", preferredStyle: UIAlertController.Style.alert)
            
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            print("Settings opened: \(success)") // Prints true
                        })
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }
            alert.addAction(settingsAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel)
            {
                UIAlertAction in
            }
            // Add the actions
            alert.addAction(cancelAction)
            self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        } else {
            completionHandler(true)
        }
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    
}



