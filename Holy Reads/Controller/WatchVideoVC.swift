//
//  WatchVideoVC.swift
//  Holy Reads
//
//  Created by mac-14 on 31/08/19.
//  Copyright © 2019 Ajeet singh Rawat. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class WatchVideoVC: UIViewController, AVPlayerViewControllerDelegate {
    
    
    // MARK: - IBOutlet
    @IBOutlet weak var imgVideo: UIImageView!
    @IBOutlet weak var btnDownloadOffline: UIButton!
    @IBOutlet weak var viewVideo: UIView!
    @IBOutlet weak var btnMarkComplete: UIButton!
    
    @IBOutlet weak var TitleLbl: UILabel!
    // MARK: - Variable
    var avpController = AVPlayerViewController()
    var player = AVPlayer()
    var dictBookDetails = [String: Any]()
    var bookId = Int()
    var completedStatus = Int()
    var isOffline = Bool()
    var dictOfflineDownloads = DownloadEnitity()
 
    // MARK: - ViewLifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
         self.navigationController?.isNavigationBarHidden = true
        //let dict = DownloadEnitity.shared.fetchDataForId(BookId: 88) as! DownloadEnitity
        self.btnMarkComplete.isHidden = true
        self.viewVideo.layer.cornerRadius = 10
        self.viewVideo.layer.masksToBounds = true
        self.TitleLbl.text = dictBookDetails["book_title"] as? String
        if isOffline {
            print(dictOfflineDownloads)
            self.btnDownloadOffline.isHidden = true
            let documentsDirectoryURL = appDelegate.DocumentDirectoryUrl!
            var bookName = String()
            bookName = dictOfflineDownloads.book_name!
            let BookFolderPath = documentsDirectoryURL.appendingPathComponent("/\(bookName)")
            let videoUrl = bookName.replacingOccurrences(of: " ", with: "")
            let VideoPath = BookFolderPath.appendingPathComponent("\(videoUrl)_Video.mp4")
            print(VideoPath)
            
            self.player = AVPlayer(url: VideoPath)
            self.avpController = AVPlayerViewController()
            self.avpController.player = self.player
            avpController.view.frame.size.width = viewVideo.frame.size.width
            avpController.view.frame.size.height = viewVideo.frame.size.height
            self.addChild(avpController)
            self.viewVideo.addSubview(avpController.view)
            if(player.timeControlStatus == AVPlayer.TimeControlStatus.playing) {
                player.pause()
            } else if(player.timeControlStatus == AVPlayer.TimeControlStatus.paused) {
                player.play()
            }
        } else {
            self.btnDownloadOffline.isHidden = false
            self.getCompletedBookStatus()
            if let url = dictBookDetails["video"] as? String {
                let videoURL = URL(string: url)!
                self.player = AVPlayer(url: videoURL)
                self.avpController = AVPlayerViewController()
                self.avpController.player = self.player
                avpController.view.frame.size.width = viewVideo.frame.size.width
                avpController.view.frame.size.height = viewVideo.frame.size.height
                self.addChild(avpController)
                self.viewVideo.addSubview(avpController.view)
            }
            if let bookId = dictBookDetails["book_id"] as? Int {
                self.bookId = bookId
            }
            if(player.timeControlStatus == AVPlayer.TimeControlStatus.playing) {
                player.pause()
            }
            else if(player.timeControlStatus == AVPlayer.TimeControlStatus.paused) {
                player.play()
            }
            NotificationCenter.default.addObserver(self, selector: #selector(audioPlayerDidFinishPlaying(_:successfully:)), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        }
        
        //        if let completedStatus = dictBookDetails["completed_status"] as? Int {
        //            if completedStatus == 1 {
        //                self.btnMarkComplete.isHidden = false
        //                self.btnMarkComplete.isSelected = true
        //                self.btnMarkComplete.backgroundColor = #colorLiteral(red: 0.9703825116, green: 0.6403394938, blue: 0, alpha: 1)
        //                self.btnMarkComplete.setTitle("Completed", for: .normal)
        //            } else {
        //                self.btnMarkComplete.isHidden = true
        //                self.btnMarkComplete.backgroundColor = #colorLiteral(red: 0.2107718289, green: 0.6397333741, blue: 0.8450053334, alpha: 1)
        //                self.btnMarkComplete.setTitle("Mark Completed", for: .normal)
        //                self.btnMarkComplete.isSelected = false
        //
        //            }
        //        }
        
        
        
    }
    // MARK: - ViewWillAppear
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    // MARK: - NavigationBar Buttons
    
    @IBAction func btnBack_DidSelect(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnDownload_DidSelect(_ sender: UIButton) {
        if DataManager.isConnectedToNetwork() {
        let downloadwifiStatus = UserDefaults.standard.value(forKey: "DownloadUsingWifi") as? Bool ?? true
        if downloadwifiStatus == false {
            if checkWiFi() {
                //self.view.makeToast(message: "Turn ON download using wifi from settings")
            } else {
                self.showHud()
                var dic = [String:Any]()
                if let videoUrl =  dictBookDetails["video"] as? String {
                    let localUrl =   self.saveVideoDocumentDirectory(strVideoUrl: videoUrl)
                    print(localUrl)
                }
                if let id = dictBookDetails["book_id"] as? Int {
                    dic["book_id"] = Int64(id)
                }
                dic["book_title"] = dictBookDetails["book_title"] as? String
                if let authorName = dictBookDetails["author"] as? String {
                    dic["author"] = authorName
                }
                 if let coverImage =  dictBookDetails["cover_image"] as? String {
                    let coverImageUrl = URL(string: coverImage)
                    let coverImageData = try! Data(contentsOf: coverImageUrl!)
                    dic["book_image"]  =  coverImageData
                }
                if let id = dictBookDetails["book_id"] as? Int {
                    dic["book_id"] = Int64(id)
                }
                
                dic["contains_Video"] = true
                DownloadEnitity.shared.saveData(dict: dic)
                
                
            }
         }else {
            self.showHud()
            var dic = [String:Any]()
            if let videoUrl =  dictBookDetails["video"] as? String {
                let localUrl =   self.saveVideoDocumentDirectory(strVideoUrl: videoUrl)
                print(localUrl)
            }
            if let id = dictBookDetails["book_id"] as? Int {
                dic["book_id"] = Int64(id)
            }
            dic["book_title"] = dictBookDetails["book_title"] as? String
            if let authorName = dictBookDetails["author"] as? String {
                dic["author"] = authorName
            }
             if let coverImage =  dictBookDetails["cover_image"] as? String {
                let coverImageUrl = URL(string: coverImage)
                let coverImageData = try! Data(contentsOf: coverImageUrl!)
                dic["book_image"]  =  coverImageData
            }
            if let id = dictBookDetails["book_id"] as? Int {
                dic["book_id"] = Int64(id)
            }
            dic["contains_Video"] = true
            DownloadEnitity.shared.saveData(dict: dic)
           
         }
        } else {
            self.view.makeToast(message: "Make sure your device is connected to the internet.")
        }
    }
        @IBAction func btnMarkComplete(_ sender: UIButton) {
            if sender.isSelected {return}  else {
                sender.isSelected = true
                self.btnMarkComplete.backgroundColor = #colorLiteral(red: 0.9703825116, green: 0.6403394938, blue: 0, alpha: 1)
                self.btnMarkComplete.setTitle("Completed", for: .normal)
                self.completedWatchingVideo()
            }
        }
        
        @objc func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
            print("Video Ended")
            self.btnMarkComplete.isHidden = false
        }
        
        func saveVideoDocumentDirectory(strVideoUrl : String) -> String {
            // URL of the file that is to be saved
            let Url = URL(string:strVideoUrl)!
            // Documnet Directory Base Url
            let documentsDirectoryURL = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
            
            var bookName = String()
            bookName = dictBookDetails["book_title"] as? String ?? "doodle"
            let BookFolderPath =  documentsDirectoryURL + "/\(bookName)"
            
            // Creating our own directory with name(BookFolderPath)
            if !FileManager.default.fileExists(atPath: BookFolderPath) {
                do {
                    try FileManager.default.createDirectory(atPath: BookFolderPath, withIntermediateDirectories: false, attributes: nil)
                } catch let error {
                    print(error.localizedDescription)
                }
            } else {
                print("Book Folder not Created")
            }
            // Creating file path inside our created  directory
            
            let bookname = bookName.replacingOccurrences(of: " ", with: "")
            let bookFilePath = URL(fileURLWithPath: BookFolderPath.appending("/\(bookname)_Video.mp4"))
            
            if FileManager.default.fileExists(atPath: bookFilePath.absoluteString) {
                print("The file already exists at path")
                self.clearHud()
                // if the file doesn't exist
            } else {
                // Downloading File From Server & Saving
                URLSession.shared.downloadTask(with: Url, completionHandler: { (location, response, error) -> Void in
                    guard let location = location, error == nil else {
                        self.clearHud()
                        return }
                    do {
                        // after downloading your file you need to move it to your destination url
                        try FileManager.default.moveItem(at: location, to: bookFilePath)
                        if error == nil {
                            DispatchQueue.main.async {
                                self.sendDownloadNotification(bookName: bookName)
                                self.view.makeToast(message: "Downloaded Successfully")
                                self.clearHud()
                                //self.rateApp()
                            }
                            print("File moved to documents folder")
                        }else {
                            self.clearHud()
                        }
                         // self.view.makeToast(message: "Downloaded Successfully")
                        
                    } catch let error as NSError {
                         print(error.localizedDescription)
                        if error.code == 516 {
                             DispatchQueue.main.async {
                            self.view.makeToast(message: "Video Already exist")
                            self.clearHud()
                            //self.rateApp()
                            }
                        }
                         self.clearHud()
                    }
                }).resume()
            }
            return bookFilePath.absoluteString
            //Original
            //        let Url = URL(string:strVideoUrl)!
            //        // then lets create your document folder url
            //        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            //        // lets create your destination file url
            //
            //        var name = String()
            //        name = dictBookDetails["book_title"] as? String ?? "doodle"
            //        let bookname = name.replacingOccurrences(of: " ", with: "")
            //        let destinationUrl = documentsDirectoryURL.appendingPathComponent("\(bookname)_Video.mp4")
            //        print(destinationUrl)
            //        // to check if it exists before downloading it
            //        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            //            print("The file already exists at path")
            //            // if the file doesn't exist
            //        } else {
            //            // you can use NSURLSession.sharedSession to download the data asynchronously
            //            URLSession.shared.downloadTask(with: Url, completionHandler: { (location, response, error) -> Void in
            //                guard let location = location, error == nil else { return }
            //                do {
            //                    // after downloading your file you need to move it to your destination url
            //                    try FileManager.default.moveItem(at: location, to: destinationUrl)
            //                    print("File moved to documents folder")
            //                    self.view.makeToast(message: "Downloaded Successfully")
            //
            //                } catch let error as NSError {
            //                    print(error.localizedDescription)
            //                }
            //            }).resume()
            //        }
            //
            //        let strUrl = destinationUrl.absoluteString
            //        return strUrl
          }
      //MARK: - Book Video Download Notification
    func sendDownloadNotification(bookName: String) {
        let parameterDictionary = NSMutableDictionary()
        let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        parameterDictionary.setValue(user_id, forKey: "user_id")
        parameterDictionary.setValue(bookName, forKey: "book_name")
        parameterDictionary.setValue("video", forKey: "DownloadType")
        
        print(parameterDictionary)
        
        //        "book_name":"A Young Woman's Guide to Making Right Decision",
        //               "user_id":309,"DownloadType":"video"
        let methodName = "sendDownloadNotification"
        
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status = DataManager.getVal(responseData?["status"]) as! String
            let message = DataManager.getVal(responseData?["message"]) as! String
            if status == "1" {
                
            } else{
                
            }
        }
    }
    
    
    
    //MARK: - Completed Book API
        func completedWatchingVideo() {
            let parameterDictionary = NSMutableDictionary()
            let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
            parameterDictionary.setValue(user_id, forKey: "user_id")
            parameterDictionary.setValue(bookId, forKey: "book_id")
            let methodName = "completedReading"
            
            DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
                let status  = DataManager.getVal(responseData?["status"]) as! String
                let message  = DataManager.getVal(responseData?["message"]) as! String
                if status == "1" {
                    self.getCompletedBookStatus()
                } else{
                    print(message)
                }
            }
        }
        
        func getCompletedBookStatus() {
            let parameterDictionary = NSMutableDictionary()
            let bookId  = UserDefaults.standard.value(forKey: "book_id") as? Int
            let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
            
            parameterDictionary.setValue(user_id, forKey: "user_id")
            parameterDictionary.setValue(bookId, forKey: "book_id")
            let methodName = "getCompletedStatus"
            
            DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
                let status  = DataManager.getVal(responseData?["status"]) as! String
                let completedStatus  = DataManager.getVal(responseData?["completed_status"]) as! String
                let message  = DataManager.getVal(responseData?["message"]) as! String
                if status == "1" {
                    if completedStatus == "1" {
                        self.completedStatus = Int(completedStatus) ?? 1
                        self.btnMarkComplete.isSelected = true
                        self.btnMarkComplete.backgroundColor = #colorLiteral(red: 0.9703825116, green: 0.6403394938, blue: 0, alpha: 1)
                        self.btnMarkComplete.setTitle("Completed", for: .normal)
                    } else {
                        self.completedStatus = Int(completedStatus) ?? 0
                        self.btnMarkComplete.backgroundColor = #colorLiteral(red: 0.2107718289, green: 0.6397333741, blue: 0.8450053334, alpha: 1)
                        self.btnMarkComplete.setTitle("Mark Completed", for: .normal)
                        self.btnMarkComplete.isSelected = false
                    }
                } else {
                    print(message)
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
        
}


