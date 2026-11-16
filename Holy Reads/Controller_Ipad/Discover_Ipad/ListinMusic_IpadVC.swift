//
//  ListinMusic_IpadVC.swift
//  Holy Reads
//
//  Created by Ashish Soni on 20/07/20.
//  Copyright © 2020 Ajeet singh Rawat. All rights reserved.
//

import UIKit
import SDWebImage
import AVFoundation
import MediaPlayer

class ListinMusic_IpadVC: UIViewController, UITableViewDataSource, UITableViewDelegate,AVAudioPlayerDelegate {
    
    //MARK :- Outlets
    
    @IBOutlet weak var lblAuthor: UILabel!
    @IBOutlet weak var lblBookTitle: UILabel!
    @IBOutlet weak var imgCover: UIImageView!
    @IBOutlet weak var imgBook: UIImageView!
    @IBOutlet var viewPlaylist: UIView!
    @IBOutlet weak var tblPlaylist: UITableView!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var musicPlayerSlider: UISlider!
    @IBOutlet weak var lblStartTime: UILabel!
    @IBOutlet weak var lblEndTime: UILabel!
    @IBOutlet weak var btnMute: UIButton!
    @IBOutlet weak var lblTotalCount: UILabel!
    @IBOutlet weak var lblShowSelectedMusic: UILabel!
    @IBOutlet weak var btnMarkComplete: UIButton!
    @IBOutlet weak var lblPlayingCount: UILabel!
    @IBOutlet weak var lblSelectedSection: UILabel!
    @IBOutlet weak var btnDownload: UIButton!
    
    //MARK :- Variable
    var dictBookDetails = [String: Any]()
    var arrMusic = [String]()
    var audioPlayer = AVAudioPlayer()
    var currentAudioPath:URL!
    var audioLength = 0.0
    var audioData = Data()
    var timer:Timer!
    var timer1:Timer!
    var selectedMusic = 0
    var bookId = Int()
    var completedStatus = Int()
    var lastSongPlayed = false
    var isOffline = Bool()
    var dictOfflineDownloads = DownloadEnitity()
    var isMute = false
    var ContainsAudioFiles = false
    var pagenumbernew:Int!
    var chapname:[String]!
    // MARK: - ViewLifeCycle
    var audioshareurl:String!
    override func viewDidLoad() {
        super.viewDidLoad()
         self.navigationController?.isNavigationBarHidden = true
        self.showHud()
        // showWaitOverlay()
    }
    
    // MARK: - ViewWillAppear
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if self.pagenumbernew == nil {
            
        }else {
            self.selectedMusic = self.pagenumbernew - 1
        }
       // self.selectedMusic = self.pagenumbernew - 1
        if isOffline {
            self.btnDownload.isHidden = true
            let documentsDirectoryURL = appDelegate.DocumentDirectoryUrl!
            var bookName = String()
            bookName = dictOfflineDownloads.book_name!
            chapname = dictOfflineDownloads.chapter_name
            let BookFolderPath = documentsDirectoryURL.appendingPathComponent("/\(bookName)")
            let AudioPath = BookFolderPath.appendingPathComponent("\(dictOfflineDownloads.arr_Audio![self.selectedMusic])")
            print(AudioPath)
         //   self.btnPlay.setImage(#imageLiteral(resourceName: "play_music"), for: .normal)
            self.setBookDetails()
            //self.arrMusic = dictOfflineDownloads.arr_Audio!
            print(AudioPath)
            self.prepareMusicPlayer(url: AudioPath)
            self.playAudio()
            ContainsAudioFiles = true
        } else{
            if DataManager.isConnectedToNetwork() {
                self.btnDownload.isHidden = false
                DispatchQueue.main.async { () -> Void in
                    self.setBookDetails()
                    self.playAudio()
                    //self.btnPlay.setImage(#imageLiteral(resourceName: "play_music"), for: .normal)
                    self.ContainsAudioFiles = false
                    //                if self.audioPlayer.isPlaying {
                    //                    self.btnPlay.setImage(#imageLiteral(resourceName: "ic_pause_circle_filled"), for: .normal)
                    //                } else {
                    //                    self.btnPlay.setImage(#imageLiteral(resourceName: "play_music"), for: .normal)
                    //                }
                }
            } else {
                self.view.makeToast(message: "No Internet Connection.")
            }
            NotificationCenter.default.addObserver(self, selector: #selector(audioPlayerDidFinishPlaying(_:successfully:)), name: .AVPlayerItemDidPlayToEndTime, object: audioPlayer)}
    }
    
    
    func setBookDetails() {
        if isOffline {
            let title =  dictOfflineDownloads.book_name
            lblBookTitle.text = title
            
            let author =  dictOfflineDownloads.author_name
            lblAuthor.text = author
            
            if let bookThumbnail =  dictOfflineDownloads.book_image as? Data {
                self.imgBook.image = UIImage(data: bookThumbnail)
                self.imgCover.image = UIImage(data: bookThumbnail)
            }
            let documentsDirectoryURL = appDelegate.DocumentDirectoryUrl!
            var bookName = String()
            bookName = dictOfflineDownloads.book_name!
            self.arrMusic.removeAll()
            let BookFolderPath = documentsDirectoryURL.appendingPathComponent("/\(bookName)")
            for i in 0...dictOfflineDownloads.arr_Audio!.count-1 {
                let bookname = bookName.replacingOccurrences(of: " ", with: "")
                let u = BookFolderPath.appendingPathComponent("\(bookname)_Audio\(i+1).mp3")
                let strUrl = u.absoluteString
                arrMusic.append(strUrl)
            }
            print(arrMusic)
//            self.lblPlayingCount.text = "\(selectedMusic + 1)/\(String(self.arrMusic.count))"
//            self.lblTotalCount.text = "\(selectedMusic + 1)/\(String(self.arrMusic.count))"
            if selectedMusic == 0 {
                self.lblPlayingCount.text = "Section Overview"
                self.lblTotalCount.text = "Section Overview"

                self.lblSelectedSection.text = "Section Overview"
            }else {
                self.lblPlayingCount.text = "\(selectedMusic)/\(String(self.arrMusic.count-1))"
                self.lblTotalCount.text = "\(selectedMusic)/\(String(self.arrMusic.count-1))"

                self.lblSelectedSection.text = "Section \(self.selectedMusic )/\(String(self.arrMusic.count-1))"
            }
//            self.lblSelectedSection.text = "Section \(self.selectedMusic + 1)/\(String(self.arrMusic.count))"
//            self.lblPlayingCount.text = "1/\(String(arrMusic.count))"
//            self.lblTotalCount.text = "1/\(String(arrMusic.count))"
//            self.lblSelectedSection.text = "Section 1/\(String(arrMusic.count))"
        } else{
            if let title =  dictBookDetails["book_title"] as? String{
                lblBookTitle.text = title
            }
            if let bookId = dictBookDetails["book_id"] as? Int {
                self.bookId = bookId
            }
            if let author =  dictBookDetails["author"] as? String{
                lblAuthor.text = author
            }
            if let bookThumbnail =  dictBookDetails["cover_image"] as? String {
                self.imgBook.sd_imageIndicator = SDWebImageActivityIndicator.gray
                self.imgBook.startAnimating()
                let url = URL.init(string: bookThumbnail)
                self.imgBook.sd_setImage(with: url, placeholderImage: UIImage.init(named: ""), options: .refreshCached, completed: { (img, error, cacheType, url) in
                })
                self.imgCover.sd_setImage(with: url, placeholderImage: UIImage.init(named: ""), options: .refreshCached, completed: { (img, error, cacheType, url) in
                })
                self.imgBook.stopAnimating()
            }
            if let audioUrl = dictBookDetails["audio"] as? [[String:Any]] {
                audioUrl.filter{(dict) in
                    self.arrMusic.append(dict["audio"] as! String)
                    return true
                }
                if let dictAudio = audioUrl[self.selectedMusic] as? [String:Any] {
                    if let strAudioUrl = dictAudio["audio"] as? String{
                        self.audioshareurl = strAudioUrl
                        let strUrl = NSURL.init(string: strAudioUrl)!
                        self.downloadFileFromURL(url: strUrl)
                    }
                }
            }
//            self.lblPlayingCount.text = "1/\(String(arrMusic.count))"
//            self.lblTotalCount.text = "1/\(String(arrMusic.count))"
//            self.lblSelectedSection.text = "Section 1/\(String(arrMusic.count))"
//            self.lblPlayingCount.text = "\(selectedMusic + 1)/\(String(self.arrMusic.count))"
//            self.lblTotalCount.text = "\(selectedMusic + 1)/\(String(self.arrMusic.count))"
            if selectedMusic == 0 {
                self.lblPlayingCount.text = "Section Overview"
                self.lblTotalCount.text = "Section Overview"
                self.lblSelectedSection.text = "Section Overview"
            }else{
                self.lblPlayingCount.text = "\(selectedMusic)/\(String(self.arrMusic.count-1))"
                self.lblTotalCount.text = "\(selectedMusic)/\(String(self.arrMusic.count-1))"
                self.lblSelectedSection.text = "Section \(self.selectedMusic )/\(String(self.arrMusic.count-1))"
            }
//            self.lblSelectedSection.text = "Section \(self.selectedMusic + 1)/\(String(self.arrMusic.count))"
            
        }
        
        //        self.lblTotalCount.text = "\(selectedMusic)\(arrMusic.count)"
        // removeAllOverlays()
    }
    
    func downloadFileFromURL(url:NSURL) {
        if DataManager.isConnectedToNetwork() {
            var downloadTask:URLSessionDownloadTask
            downloadTask = URLSession.shared.downloadTask(with: url as URL, completionHandler: { [weak self](URL, response, error) -> Void in
                if error == nil {
                    self?.prepareMusicPlayer(url: URL!)
                }else {
                    self?.clearHud()
                }
            })
            downloadTask.resume()
        }  else {
            self.clearHud()
            self.view.makeToast(message: "Make sure your device is connected to the internet.")
        }
    }
    
    @objc func ShowLoader(_ timer: Timer){
        timer1.invalidate()
        self.clearHud()
    }
    
    // MARK: - NavigationBar Buttons
    
    @IBAction func btnBack_DidSelect(_ sender: Any) {
        self.stopTimer()
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - IBAction
    
    @IBAction func btnClosePlaylist(_ sender: UIButton) {
        self.viewPlaylist.removeFromSuperview()
    }
    @IBAction func btnMute_DidSelect(_ sender: UIButton) {
        if self.audioPlayer.volume == 0.0 {
            self.btnMute.setImage(#imageLiteral(resourceName: "Unmute"), for: .normal)
            self.isMute = false
            self.audioPlayer.volume = 1.0
        } else {
            self.btnMute.setImage(#imageLiteral(resourceName: "Mute"), for: .normal)
            self.isMute = true
            self.audioPlayer.volume = 0.0
        }
    }
    @IBAction func btnMarkComplete(_ sender: UIButton) {
        if sender.isSelected {return}  else {
            sender.isSelected = true
            self.btnMarkComplete.backgroundColor = #colorLiteral(red: 0.9703825116, green: 0.6403394938, blue: 0, alpha: 1)
            self.btnMarkComplete.setTitle("Completed", for: .normal)
            self.completedListingAudio()
        }
    }
    
    @IBAction func HideMusicList(_ sender: UIButton) {
        self.viewPlaylist.removeFromSuperview()
    }
    
    @IBAction func btnShowMusicList_DidSelect(_ sender: UIButton) {
        //        let obj = self.storyboard?.instantiateViewController(withIdentifier: "AudioListVC") as! AudioListVC
        //        self.navigationController?.present(obj, animated: true, completion: nil)
        // self.lblShowSelectedMusic.text = "\(selectedMusic)\(arrMusic.count)"
        
        viewPlaylist.frame = CGRect(x: 0.0, y: -200.0, width: screenWidth, height: screenHeight)
        self.view.addSubview(viewPlaylist)
    }
    
    @IBAction func btnSkipBackword30SecondsPressed(_ sender: UIButton) {
        if DataManager.isConnectedToNetwork() {
            let seekDuration: Float64 = 10
            let duration  = audioPlayer.duration
            let playerCurrentTime = audioPlayer.currentTime
            let newTime = playerCurrentTime - seekDuration
            if newTime < duration {
                audioPlayer.currentTime = newTime
            }
        } else {
            self.view.makeToast(message: "No Internet Connection.")
        }
    }
    
    @IBAction func btnSkipForsdward30SecondsPressed(_ sender: UIButton) {
        if DataManager.isConnectedToNetwork() {
            let seekDuration: Float64 = 10
            let duration  = audioPlayer.duration
            let playerCurrentTime = audioPlayer.currentTime
            let newTime = playerCurrentTime + seekDuration
            if newTime < duration {
                audioPlayer.currentTime = newTime
            }
        } else {
            self.view.makeToast(message: "No Internet Connection.")
        }
    }
    @IBAction func btnNext(_ sender: UIButton) {
        
        if isOffline {
            if self.dictOfflineDownloads.arr_Audio!.count-1 > self.selectedMusic {
            let documentsDirectoryURL = appDelegate.DocumentDirectoryUrl!
            var bookName = String()
            bookName = dictOfflineDownloads.book_name!
          //  chapname = dictOfflineDownloads.chapter_name
            let BookFolderPath = documentsDirectoryURL.appendingPathComponent("/\(bookName)")
            self.audioPlayer.pause()
            self.selectedMusic = self.selectedMusic+1
//                if ((dictOfflineDownloads.arr_Audio?.last) != nil) {
//                    self.lastSongPlayed = true
//                }else{
//
               // }
            let AudioPath = BookFolderPath.appendingPathComponent("\(dictOfflineDownloads.arr_Audio![self.selectedMusic])")
            print(AudioPath)
                if let strAudioUrl = self.arrMusic[self.selectedMusic] as? String {
                   if self.arrMusic.last == strAudioUrl {
                       self.lastSongPlayed = true
                       print("it is the last Song")
                   }
                }
           // self.btnPlay.setImage(#imageLiteral(resourceName: "play_music"), for: .normal)
            self.setBookDetails()
            //self.arrMusic = dictOfflineDownloads.arr_Audio!
            print(AudioPath)
            if self.selectedMusic == 0 {
                self.lblPlayingCount.text = "Section Overview"
                self.lblTotalCount.text = "Section Overview"
                self.lblSelectedSection.text = "Section Overview"
            }else{
                self.lblPlayingCount.text = "\(self.selectedMusic)/\(String(self.dictOfflineDownloads.arr_Audio!.count-1))"
                self.lblTotalCount.text = "\(self.selectedMusic)/\(String(self.dictOfflineDownloads.arr_Audio!.count-1))"
                self.lblSelectedSection.text = "Section \(self.selectedMusic )/\(String(self.dictOfflineDownloads.arr_Audio!.count-1))"
            }
            self.prepareMusicPlayer(url: AudioPath)
            self.playAudio()
            ContainsAudioFiles = true
            self.btnPlay.setImage(#imageLiteral(resourceName: "ic_pause_circle_filled"), for: .normal)
            self.tblPlaylist.reloadData()
            }else {
                self.view.makeToast(message: "No more next chapters present")
            }
        }else {
            self.showHud()
            DispatchQueue.main.async() {
                if self.arrMusic.count-1 > self.selectedMusic {
                    self.audioPlayer.pause()
                    self.selectedMusic = self.selectedMusic+1
    //                self.lblPlayingCount.text = "\(self.selectedMusic + 1 )/\(String(self.arrMusic.count))"
    //                self.lblTotalCount.text = "\(self.selectedMusic + 1 )/\(String(self.arrMusic.count))"
                   // self.lblSelectedSection.text = "Section \(self.selectedMusic + 1 )/\(String(self.arrMusic.count))"
                    if self.selectedMusic == 0 {
                        self.lblPlayingCount.text = "Section Overview"
                        self.lblTotalCount.text = "Section Overview"
                        self.lblSelectedSection.text = "Section Overview"
                    }else{
                        self.lblPlayingCount.text = "\(self.selectedMusic)/\(String(self.arrMusic.count-1))"
                        self.lblTotalCount.text = "\(self.selectedMusic)/\(String(self.arrMusic.count-1))"
                        self.lblSelectedSection.text = "Section \(self.selectedMusic )/\(String(self.arrMusic.count-1))"
                    }
                    
                    if let strAudioUrl = self.arrMusic[self.selectedMusic] as? String {
                        if self.arrMusic.last == strAudioUrl {
                            self.lastSongPlayed = true
                            print("it is the last Song")
                        }
                        
                        let strUrl = NSURL.init(string: strAudioUrl)!
                        self.downloadFileFromURL(url: strUrl)
                        self.btnPlay.setImage(#imageLiteral(resourceName: "ic_pause_circle_filled"), for: .normal)
                        
                        self.tblPlaylist.reloadData()
                        //self.prepareMusicPlayer()
                    }} else {
                    self.clearHud()
                    self.view.makeToast(message: "No more next chapters present")
                    print("Error")
                }
            }
        }
        
       
    }
    
    @IBAction func btnPrev(_ sender: UIButton) {
        
        if isOffline {
            if self.selectedMusic > 0 {
            let documentsDirectoryURL = appDelegate.DocumentDirectoryUrl!
            var bookName = String()
            bookName = dictOfflineDownloads.book_name!
           // chapname = dictOfflineDownloads.chapter_name
            let BookFolderPath = documentsDirectoryURL.appendingPathComponent("/\(bookName)")
            self.audioPlayer.pause()
            self.selectedMusic = self.selectedMusic-1
            let AudioPath = BookFolderPath.appendingPathComponent("\(dictOfflineDownloads.arr_Audio![self.selectedMusic])")
            print(AudioPath)
            if self.selectedMusic == 1 {
                self.lblPlayingCount.text = "Section Overview"
                self.lblTotalCount.text = "Section Overview"
                self.lblSelectedSection.text = "Section Overview"
            }else{
                self.lblPlayingCount.text = "\(self.selectedMusic-1)/\(String(self.dictOfflineDownloads.arr_Audio!.count-1))"
                self.lblTotalCount.text = "\(self.selectedMusic-1)/\(String(self.dictOfflineDownloads.arr_Audio!.count-1))"
                self.lblSelectedSection.text = "Section \(self.selectedMusic-1)/\(String(self.dictOfflineDownloads.arr_Audio!.count-1))"
            }
           // self.btnPlay.setImage(#imageLiteral(resourceName: "play_music"), for: .normal)
            self.setBookDetails()
            self.prepareMusicPlayer(url: AudioPath)
            self.playAudio()
            ContainsAudioFiles = true
            self.btnPlay.setImage(#imageLiteral(resourceName: "ic_pause_circle_filled"), for: .normal)
            self.tblPlaylist.reloadData()
            }else{
                self.view.makeToast(message: "No more previous chapters present")
            }
            
        }else {
            if self.selectedMusic > 0 {
                self.showHud()
                DispatchQueue.main.async {
                    self.audioPlayer.pause()
                    self.selectedMusic = self.selectedMusic-1
                    if let strAudioUrl = self.arrMusic[self.selectedMusic] as? String{
                        //                let mediaUrl =  URL.init(string: strAudioUrl)
                        //                self.audioData = try! Data.init(contentsOf: mediaUrl!)
                        let strUrl = NSURL.init(string: strAudioUrl)!
                        self.downloadFileFromURL(url: strUrl)
                        self.btnPlay.setImage(#imageLiteral(resourceName: "ic_pause_circle_filled"), for: .normal)
                        self.tblPlaylist.reloadData()
                        //self.prepareMusicPlayer()
                    }}
    //            self.lblPlayingCount.text = "\(self.selectedMusic)/\(String(self.arrMusic.count))"
    //            self.lblTotalCount.text = "\(self.selectedMusic)/\(String(self.arrMusic.count))"
                if self.selectedMusic == 1 {
                    self.lblPlayingCount.text = "Section Overview"
                    self.lblTotalCount.text = "Section Overview"
                    self.lblSelectedSection.text = "Section Overview"
                }else{
                    self.lblPlayingCount.text = "\(self.selectedMusic-1)/\(String(self.arrMusic.count-1))"
                    self.lblTotalCount.text = "\(self.selectedMusic-1)/\(String(self.arrMusic.count-1))"
                    self.lblSelectedSection.text = "Section \(self.selectedMusic-1)/\(String(self.arrMusic.count-1))"
                }
               // self.lblSelectedSection.text = "Section \(self.selectedMusic)/\(String(self.arrMusic.count))"
            } else {
                self.view.makeToast(message: "No more previous chapters present")
            }
        }
        
    }
    
    @IBAction func btnPlay(_ sender: UIButton) {
        if DataManager.isConnectedToNetwork() {
            if audioPlayer.isPlaying{
                self.pauseAudio()
                self.btnPlay.setImage(#imageLiteral(resourceName: "play_music"), for: .normal)
            } else{
                self.playAudio()
                self.btnPlay.setImage(#imageLiteral(resourceName: "ic_pause_circle_filled"), for: .normal)
            }
        } else {
            if self.ContainsAudioFiles {
                if audioPlayer.isPlaying{
                    self.pauseAudio()
                    self.btnPlay.setImage(#imageLiteral(resourceName: "play_music"), for: .normal)
                } else{
                    self.playAudio()
                    self.btnPlay.setImage(#imageLiteral(resourceName: "ic_pause_circle_filled"), for: .normal)
                }
            }
        }
    }
    
    @IBAction func audioSlider(_ sender : UISlider) {
        audioPlayer.currentTime = TimeInterval(sender.value)
        //print(sender.value)
    }
    
    @IBAction func shareBtnAction(_ sender: Any) {
        var urlnew:String!
        let logstr = String(self.bookId)
        let longstring = logstr
        if let data = (longstring).data(using: String.Encoding.utf8) {
            let base64 = data.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
            print(base64)// dGVzdDEyMw==\n
           
            urlnew = "https://holyreads.com/pages/listen/" + base64 + "?audio=" + String(self.selectedMusic+1)
        }
//        let textToShare = [ audioshareurl ]
        let textToShare = [ urlnew ]
        let activityViewController = UIActivityViewController(activityItems: textToShare as [Any], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
        activityViewController.popoverPresentationController?.sourceRect = self.navigationController?.navigationBar.frame ?? CGRect.zero
        activityViewController.popoverPresentationController?.sourceView = self.navigationController?.navigationBar
        self.present(activityViewController, animated: true)
     }
    
    @IBAction func DownloadAudio(_ sender: UIButton) {
        if DataManager.isConnectedToNetwork(){
            let downloadwifiStatus = UserDefaults.standard.value(forKey: "DownloadUsingWifi") as? Bool ?? true
            if downloadwifiStatus == false {
                if checkWiFi() {
                    //self.view.makeToast(message: "Turn ON download using wifi from settings")
                } else {
                    self.showHud()
                    var dic = [String:Any]()
                    var arrchapterUrl = [String]()
                    if let arrAudio = self.dictBookDetails["audio"] as? [[String:Any]] {
                        arrAudio.filter { (val) -> Bool in
                            if let Url = val["audio"] as? String{
                                let chapterUrl = Url
                                arrchapterUrl.append(chapterUrl)
                            }
                            return true
                        }
                        print(arrchapterUrl)
                        if self.arrMusic.count != 0 {
                        }
                        let LocalUrl = self.saveAudioDocumentDirectory(arrAudioUrl: arrchapterUrl)
                        dic["arr_Audio"] = LocalUrl
                        print(LocalUrl)
                    }
                    if let id = self.dictBookDetails["book_id"] as? Int {
                        dic["book_id"] = Int64(id)
                    }
                    dic["book_title"] = self.dictBookDetails["book_title"] as? String
                    if let authorName = self.dictBookDetails["author"] as? String {
                        dic["author"] = authorName
                    }
                    if let coverImage =  self.dictBookDetails["cover_image"] as? String {
                        if DataManager.isConnectedToNetwork() {
                            let coverImageUrl = URL(string: coverImage)
                            let coverImageData = try! Data(contentsOf: coverImageUrl!)
                            dic["book_image"]  =  coverImageData
                        } else {
                            self.clearHud()
                            return
                        }
                    }
                    if let id = self.dictBookDetails["book_id"] as? Int {
                        dic["book_id"] = Int64(id)
                    }
                    dic["contains_Audio"] = true
                    DownloadEnitity.shared.saveData(dict: dic)
                }
            } else {
                self.showHud()
                var dic = [String:Any]()
                var arrchapterUrl = [String]()
                if let arrAudio = self.dictBookDetails["audio"] as? [[String:Any]] {
                    arrAudio.filter { (val) -> Bool in
                        if let Url = val["audio"] as? String{
                            let chapterUrl = Url
                            arrchapterUrl.append(chapterUrl)
                        }
                        return true
                    }
                    print(arrchapterUrl)
                    if self.arrMusic.count != 0 {
                    }
                    
                    let LocalUrl = self.saveAudioDocumentDirectory(arrAudioUrl: arrchapterUrl)
                    dic["arr_Audio"] = LocalUrl
                    print(LocalUrl)
                }
                if let id = self.dictBookDetails["book_id"] as? Int {
                    dic["book_id"] = Int64(id)
                }
                dic["book_title"] = self.dictBookDetails["book_title"] as? String
                if let authorName = self.dictBookDetails["author"] as? String {
                    dic["author"] = authorName
                }
                
                if let coverImage =  self.dictBookDetails["cover_image"] as? String {
                    if DataManager.isConnectedToNetwork() {
                        let coverImageUrl = URL(string: coverImage)
                        let coverImageData = try! Data(contentsOf: coverImageUrl!)
                        dic["book_image"]  =  coverImageData
                    } else {
                        self.clearHud()
                        return
                    }
                }
                if let id = self.dictBookDetails["book_id"] as? Int {
                    dic["book_id"] = Int64(id)
                }
                dic["contains_Audio"] = true
                DownloadEnitity.shared.saveData(dict: dic)
                
            }
        }
        else {
            self.view.makeToast(message: "Please make sure that you are connected to internet.")
        }
    }
    
    func saveAudioDocumentDirectory(arrAudioUrl : [String]) -> [String] {
        var arrLocalAudioUrl = [String]()
        // URL of the file that is to be saved
        for  i  in 0...arrAudioUrl.count-1 {
            let Url = URL(string:arrAudioUrl[i])!
            // Documnet Directory Base Url
            let documentsDirectoryURL = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
            
            var bookName = String()
            bookName = dictBookDetails["book_title"] as? String ?? "NoName"
            let BookFolderPath =  documentsDirectoryURL + "/\(bookName)"
            
            // Creating our own directory with name(BookFolderPath)
            if !FileManager.default.fileExists(atPath: BookFolderPath) {
                do {
                    try FileManager.default.createDirectory(atPath: BookFolderPath, withIntermediateDirectories: false, attributes: nil)
                } catch let error {
                    if i == arrAudioUrl.count-1 {
                        self.clearHud()
                    }
                    print(error.localizedDescription)
                }
            } else {
                print("Book Folder not Created")
            }
            // Creating file path inside our created  directory
            
            let bookname = bookName.replacingOccurrences(of: " ", with: "")
            let bookFilePath = URL(fileURLWithPath: BookFolderPath.appending("/\(bookname)_Audio\(i+1).mp3"))
            arrLocalAudioUrl.append("\(bookname)_Audio\(i+1).mp3")
            
            if FileManager.default.fileExists(atPath: bookFilePath.absoluteString) {
                if i == arrAudioUrl.count-1 {
                    self.clearHud()
                }
                print("The file already exists at path")
                // if the file doesn't exist
            } else {
                // Downloading File From Server & Saving
                URLSession.shared.downloadTask(with: Url, completionHandler: { (location, response, error) -> Void in
                    guard let location = location, error == nil else {  self.clearHud()
                        return }
                    do {
                        // after downloading your file you need to move it to your destination url
                        try FileManager.default.moveItem(at: location, to: bookFilePath)
                        DispatchQueue.main.async {
                            if i == arrAudioUrl.count-1 {
                                self.clearHud()
                            }
                            self.sendDownloadNotification(bookName: bookName)
                            self.view.makeToast(message: "Downloaded Successfully")
                            self.clearHud()
                           // self.rateApp()
                        }
                        print("File moved to documents folder")
                        // self.view.makeToast(message: "Downloaded Successfully")
                        
                    } catch let error as NSError {
                        if i == arrAudioUrl.count-1 {
                            DispatchQueue.main.async {
                                self.view.makeToast(message: "Audio Already exist")
                                self.clearHud()
                                //self.rateApp()
                            }
                        }
                        print(error.localizedDescription)
                    }
                }).resume()
            }
        }
        return arrLocalAudioUrl
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMusic.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReadList_IpadCell", for: indexPath) as! ReadList_IpadCell
        if isOffline {
//            cell.lblAudioName.text = "\(chapname[indexPath.row])\(indexPath.row + 1)"
            if chapname ==  nil {
                let defaults = UserDefaults.standard
                let myarray = defaults.stringArray(forKey: "ChapterArray") ?? [String]()
                cell.lblAudioName.text = myarray[indexPath.row]
            }else {
                cell.lblAudioName.text = chapname[indexPath.row]
            }
            cell.lblAudioName.text = chapname[indexPath.row]
            if self.selectedMusic == indexPath.row {
                cell.imgMusic.isHidden = false
                 cell.lblAudioName.textColor =  UIColor(red: 254/255, green: 153/255, blue: 37/255, alpha: 1)
            } else {
                cell.imgMusic.isHidden = true
                 cell.lblAudioName.textColor =  UIColor.white
            }
            if indexPath.row == 0 {
                let attachment = NSTextAttachment()
                attachment.image = UIImage(named: "bookmark (1)")

                let attachmentString = NSAttributedString(attachment: attachment)

                let myString = NSMutableAttributedString(string: "")
                myString.append(attachmentString)

                cell.lblAudioCount.attributedText = myString
            }else {
                cell.lblAudioCount.text = String(indexPath.row)
            }
           // cell.lblAudioCount.text = String(indexPath.row + 1)
        } else{
            let dict =  dictBookDetails["audio"] as! [[String:Any]]
            if let name = dict[indexPath.row] as? [String:Any]{
                cell.lblAudioName.text = name["chapter_name"] as? String
            }
            if self.selectedMusic == indexPath.row {
                cell.imgMusic.isHidden = false
                 cell.lblAudioName.textColor =  UIColor(red: 254/255, green: 153/255, blue: 37/255, alpha: 1)
            } else {
                cell.imgMusic.isHidden = true
                 cell.lblAudioName.textColor =  UIColor.white
            }
            if indexPath.row == 0 {
                let attachment = NSTextAttachment()
                attachment.image = UIImage(named: "bookmark (1)")

                let attachmentString = NSAttributedString(attachment: attachment)

                let myString = NSMutableAttributedString(string: "")
                myString.append(attachmentString)

                cell.lblAudioCount.attributedText = myString
            }else {
                cell.lblAudioCount.text = String(indexPath.row)
            }
            //cell.lblAudioCount.text = String(indexPath.row + 1)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isOffline {
            let documentsDirectoryURL = appDelegate.DocumentDirectoryUrl!
            var bookName = String()
            bookName = dictOfflineDownloads.book_name!
          //  chapname = dictOfflineDownloads.chapter_name
            let BookFolderPath = documentsDirectoryURL.appendingPathComponent("/\(bookName)")
            self.audioPlayer.pause()
            self.selectedMusic  =  indexPath.row
            let AudioPath = BookFolderPath.appendingPathComponent("\(dictOfflineDownloads.arr_Audio![self.selectedMusic])")
            print(AudioPath)
            
           // self.btnPlay.setImage(#imageLiteral(resourceName: "play_music"), for: .normal)
            //self.setBookDetails()
            if let strAudioUrl = self.arrMusic[self.selectedMusic] as? String {
               if self.arrMusic.last == strAudioUrl {
                   self.lastSongPlayed = true
                   print("it is the last Song")
               }
            }
            //self.arrMusic = dictOfflineDownloads.arr_Audio!
            print(AudioPath)
            if self.selectedMusic == 0 {
                self.lblPlayingCount.text = "Section Overview"
                self.lblTotalCount.text = "Section Overview"
                self.lblSelectedSection.text = "Section Overview"
            }else{
                self.lblPlayingCount.text = "\(self.selectedMusic)/\(String(self.dictOfflineDownloads.arr_Audio!.count-1))"
                self.lblTotalCount.text = "\(self.selectedMusic)/\(String(self.dictOfflineDownloads.arr_Audio!.count-1))"
                self.lblSelectedSection.text = "Section \(self.selectedMusic )/\(String(self.dictOfflineDownloads.arr_Audio!.count-1))"
            }
           // self.downloadFileFromURL(url: AudioPath as NSURL)
            self.prepareMusicPlayer(url: AudioPath)
            self.playAudio()
            ContainsAudioFiles = true
            self.tblPlaylist.reloadData()
            self.btnPlay.setImage(#imageLiteral(resourceName: "ic_pause_circle_filled"), for: .normal)
            self.viewPlaylist.removeFromSuperview()
        }else{
        //self.showWaitOverlay()
        self.showHud()
        DispatchQueue.main.async {
            self.selectedMusic  =  indexPath.row
//            self.lblPlayingCount.text = "\(indexPath.row + 1)/\(String(self.arrMusic.count))"
//            self.lblTotalCount.text = "\(indexPath.row + 1)/\(String(self.arrMusic.count))"
            if indexPath.row == 0 {
                self.lblPlayingCount.text = "Section Overview"
                self.lblTotalCount.text = "Section Overview"
                self.lblSelectedSection.text = "Section Overview"
            }else{
                self.lblPlayingCount.text = "\(indexPath.row)/\(String(self.arrMusic.count-1))"
                self.lblTotalCount.text = "\(indexPath.row)/\(String(self.arrMusic.count-1))"
                self.lblSelectedSection.text = "Section \(indexPath.row)/\(String(self.arrMusic.count-1))"
            }
           
            
            let index =  indexPath.row
            if let strAudioUrl = self.arrMusic[index] as? String {
                // let mediaUrl =  URL.init(string: AudioUrl)
                //self.audioData = try! Data.init(contentsOf: mediaUrl!)
                if self.arrMusic.last == strAudioUrl {
                    self.lastSongPlayed = true
                }
                self.btnPlay.setImage(#imageLiteral(resourceName: "play_music"), for: .normal)
                self.tblPlaylist.reloadData()
                self.audioshareurl = strAudioUrl
                let strUrl = NSURL.init(string: strAudioUrl)!
                self.downloadFileFromURL(url: strUrl)
            }
            self.viewPlaylist.removeFromSuperview()
            //self.prepareMusicPlayer()
        }
        }
        //self.removeAllOverlays()
    }
    // MARK: - AV Player Methods
    func prepareMusicPlayer(url : URL) {
                do {
                    try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
                } catch _ {
        
                }
                do {
                    try AVAudioSession.sharedInstance().setActive(true)
                } catch _ {
        
                }
        //        UIApplication.shared.beginReceivingRemoteControlEvents()
        //
        //self.audioPlayer = try! AVAudioPlayer.init(data: self.audioData, fileTypeHint: "mp3")\
        self.clearHud()
        
        if url == nil {
            self.clearHud()
            self.navigationController?.popViewController(animated: true)
        } else {
            self.audioPlayer = try! AVAudioPlayer.init(contentsOf: url, fileTypeHint: "mp3")
        }
        self.audioPlayer.delegate = self
        self.audioLength = self.audioPlayer.duration
        DispatchQueue.main.async {
            self.musicPlayerSlider.maximumValue = CFloat(self.audioPlayer.duration)
            self.musicPlayerSlider.minimumValue = 0.0
            self.lblStartTime.text = "00:00"
            self.musicPlayerSlider.value = 0.0
            self.audioPlayer.prepareToPlay()
            if self.isMute {
                self.btnMute.setImage(#imageLiteral(resourceName: "Mute"), for: .normal)
                self.audioPlayer.volume = 0.0
            } else {
                self.btnMute.setImage(#imageLiteral(resourceName: "Unmute"), for: .normal)
                self.audioPlayer.volume = 1.0
            }
            self.calculateSongLength()
            self.audioPlayer.play()
        }
    }
    
    func playAudio() {
        startTimer()
        audioPlayer.play()
    }
    func pauseAudio() {
        audioPlayer.pause()
    }
    
    func calculateSongLength(){
        let time = calculateTimeFromNSTimeInterval(audioLength)
        lblEndTime.text = "\(time.minute):\(time.second)"
    }
    
    func startTimer() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(update(_:)), userInfo: nil,repeats: true)
            timer.fire()
        }
    }
    
    @objc func update(_ timer: Timer){
        if !audioPlayer.isPlaying{
            return
        }
        let time = calculateTimeFromNSTimeInterval(audioPlayer.currentTime)
        lblStartTime.text  = "\(time.minute):\(time.second)"
        //print("time is \(lblStartTime.text)")
        musicPlayerSlider.value = CFloat(audioPlayer.currentTime)
        UserDefaults.standard.set(musicPlayerSlider.value , forKey: "playerProgressSliderValue")
    }
    
    func calculateTimeFromNSTimeInterval(_ duration:TimeInterval) ->(minute:String, second:String){
        //let hour_   = abs(Int(duration)/3600)
        let minute_ = abs(Int((duration/60).truncatingRemainder(dividingBy: 60)))
        let second_ = abs(Int(duration.truncatingRemainder(dividingBy: 60)))
        
        //var hour = hour_ > 9 ? "\(hour_)" : "0\(hour_)"
        let minute = minute_ > 9 ? "\(minute_)" : "0\(minute_)"
        let second = second_ > 9 ? "\(second_)" : "0\(second_)"
        return (minute,second)
    }
    
    func stopTimer(){
        if timer != nil {
            timer!.invalidate()
        }
    }
    
    func retrievePlayerProgressSliderValue() {
        let playerProgressSliderValue =  UserDefaults.standard.float(forKey: "playerProgressSliderValue")
        if playerProgressSliderValue != 0 {
            musicPlayerSlider.value  = playerProgressSliderValue
            audioPlayer.currentTime = TimeInterval(playerProgressSliderValue)
            
            let time = calculateTimeFromNSTimeInterval(audioPlayer.currentTime)
            lblStartTime.text  = "\(time.minute):\(time.second)"
            musicPlayerSlider.value = CFloat(audioPlayer.currentTime)
            
        } else{
            musicPlayerSlider.value = 0.0
            audioPlayer.currentTime = 0.0
            lblStartTime.text = "00:00"
        }
    }
    
    // MARK:- AVAudioPlayer Delegate's Callback method
    
    @objc func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool){
        print( "Player Flag\(flag)")
        if isOffline {
            if self.lastSongPlayed == true {
                if self.completedStatus == 1 {
                    self.btnMarkComplete.isHidden = false
                    self.btnMarkComplete.isSelected = true
                    self.btnMarkComplete.backgroundColor = #colorLiteral(red: 0.9703825116, green: 0.6403394938, blue: 0, alpha: 1)
                    self.btnMarkComplete.setTitle("Completed", for: .normal)
                } else {
                    self.btnMarkComplete.isHidden = false
                    self.btnMarkComplete.backgroundColor = #colorLiteral(red: 0.2107718289, green: 0.6397333741, blue: 0.8450053334, alpha: 1)
                    self.btnMarkComplete.setTitle("Mark Completed", for: .normal)
                    self.btnMarkComplete.isSelected = false
                    self.getCompletedBookStatus()
                }
                self.btnPlay.setImage(#imageLiteral(resourceName: "play_music"), for: .normal)
                let time = self.calculateTimeFromNSTimeInterval(self.audioLength)
                self.lblStartTime.text = "\(time.minute):\(time.second)"
            }
            else {
              //  self.btnPlay.setImage(#imageLiteral(resourceName: "play_music"), for: .normal)
                if lastSongPlayed == true {
                   print("Ashish")
                }else {
                    self.btnNext(UIButton())
                }
               
            }
        } else {
            if self.lastSongPlayed == true {
                if self.completedStatus == 1 {
                    self.btnMarkComplete.isHidden = false
                    self.btnMarkComplete.isSelected = true
                    self.btnMarkComplete.backgroundColor = #colorLiteral(red: 0.9703825116, green: 0.6403394938, blue: 0, alpha: 1)
                    self.btnMarkComplete.setTitle("Completed", for: .normal)
                } else {
                    self.btnMarkComplete.isHidden = false
                    self.btnMarkComplete.backgroundColor = #colorLiteral(red: 0.2107718289, green: 0.6397333741, blue: 0.8450053334, alpha: 1)
                    self.btnMarkComplete.setTitle("Mark Completed", for: .normal)
                    self.btnMarkComplete.isSelected = false
                    self.getCompletedBookStatus()
                }
                self.btnPlay.setImage(#imageLiteral(resourceName: "play_music"), for: .normal)
                let time = self.calculateTimeFromNSTimeInterval(self.audioLength)
                self.lblStartTime.text = "\(time.minute):\(time.second)"
            }
            else {
                //self.btnPlay.setImage(#imageLiteral(resourceName: "play_music"), for: .normal)
                if lastSongPlayed == true {
                   print("Ashish")
                }else {
                    self.btnNext(UIButton())
                }
                //self.btnNext(UIButton())
            }
        }
    }
    
    //MARK: - Book Audio Download Notification
    
    func sendDownloadNotification(bookName: String) {
        let parameterDictionary = NSMutableDictionary()
        let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        parameterDictionary.setValue(user_id, forKey: "user_id")
        parameterDictionary.setValue(bookName, forKey: "book_name")
        parameterDictionary.setValue("audio", forKey: "DownloadType")
        
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
    func completedListingAudio() {
        let parameterDictionary = NSMutableDictionary()
        let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        parameterDictionary.setValue(user_id, forKey: "user_id")
        parameterDictionary.setValue(bookId, forKey: "book_id")
        let methodName = "completedReading"
        
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let completedStatus  = DataManager.getVal(responseData?["completed_status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
            if status == "1" {
                self.completedStatus = Int(completedStatus)!
            } else{
                print(message)
            }
        }
    }
    //MARK: - Get Completed Book Status API
    
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
                }  else {
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
    
}

