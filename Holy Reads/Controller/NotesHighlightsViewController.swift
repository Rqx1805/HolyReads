//
//  NotesHighlightsViewController.swift
//  Holy Reads
//
//  Created by Ashish Soni on 28/05/20.
//  Copyright © 2020 Ajeet singh Rawat. All rights reserved.
//

import UIKit
import SDWebImage
import PMAlertController
import Realm
import RealmSwift
import JavaScriptCore
import CoreData

@objc protocol FolioReaderChapterListDelegate1: class {
    /**
     Notifies when the user selected some item on menu.
     */
    func chapterList(_ chapterList: NotesHighlightsViewController, didSelectRowAtIndexPath indexPath: IndexPath, withTocReference reference: FRTocReference)
    
    /**
     Notifies when chapter list did totally dismissed.
     */
    func chapterList(didDismissedChapterList chapterList: FolioReaderChapterList)
    
    
}

class NotesHighlightsViewController: UIViewController,UITextFieldDelegate {
    
    fileprivate weak var readerContainer: FolioReaderContainer?
    fileprivate var readerConfig: FolioReaderConfig {
        guard let readerContainer = readerContainer else { return FolioReaderConfig() }

        return readerContainer.readerConfig
        
        
    }

    @IBOutlet weak var noteTableview: UITableView!
    var arrHighlightedMarkedBooks = [[String:Any]]()
    let tableRefreshController = UIRefreshControl()
    var config =  FolioReaderConfig()
    var bookName = String()
    fileprivate  var highlights = [Highlight]()
    fileprivate var folioReader = FolioReader()
    @IBOutlet weak var textsearch: UITextField!
     weak var delegate: FolioReaderChapterListDelegate1?
     fileprivate var tocItems = [FRTocReference]()
    var htlmnew:String!
    var realm:Realm!
    var newappid:String!
    override func viewDidLoad() {
        super.viewDidLoad()
        realm = try! Realm(configuration: readerConfig.realmConfiguration)
        realm.beginWrite()
        self.tableRefreshController.addTarget(self, action: #selector(RefreshTablePage), for: .valueChanged)
        self.noteTableview.addSubview(tableRefreshController)
        textsearch.delegate = self
        self.getHighlightBookListingApiCall()
        NotificationCenter.default.addObserver(self, selector: #selector(self.currencyConvert1(_:)), name: NSNotification.Name("callnote"), object: nil)
        
       
        
        // Do any additional setup after loading the view.
    }
    
    @objc func currencyConvert1(_ pNotification: Notification?) {
        self.getHighlightBookListingApiCall()
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//       super.viewWillDisappear(animated)
//
//
//           let currentPage = folioReader1.readerCenter?.currentPage
//           let html = currentPage!.webView?.js("getHTML()")
//           htlmnew = html
//
//
//   }
    
    
    @objc func RefreshTablePage ()  {
        self.textsearch.text = ""
        self.getHighlightBookListingApiCall()
    }
    
    
    func getHighlightBookListingApiCall() {
        self.showHud()
        let parameterDictionary = NSMutableDictionary()
        let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        let book_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "book_id")) as! String
        parameterDictionary.setValue(user_id, forKey: "user_id")
        parameterDictionary.setValue(book_id, forKey: "book_id")
        
        let methodName = "getHighlightListSecond"
        
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
            
            if status == "1" {
                if let response  = DataManager.getVal(responseData?["data"]) as? [[String:Any]] {
                    self.arrHighlightedMarkedBooks = response
                    let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.noteTableview.frame.size.width, height: self.noteTableview.frame.size.height))
                    label.textColor = .black
                    label.textAlignment = .center
                    label.text = ""
                    self.noteTableview.backgroundView = label
                    self.noteTableview.reloadData()
                    self.tableRefreshController.endRefreshing()
                } }else {
                self.arrHighlightedMarkedBooks.removeAll()
                self.noteTableview.reloadData()
                
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.noteTableview.frame.size.width, height: self.noteTableview.frame.size.height))
                
                label.textColor = .black
                label.textAlignment = .center
                label.text = "No Highlight found."
                self.noteTableview.backgroundView = label
                self.tableRefreshController.endRefreshing()
            }
            self.clearHud()
        }
    }
    
    
    //MARK: - UITextField Delegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.endEditing(true)
        if textField == textsearch {
            self.getSeachBook()
        }else {
            self.getHighlightBookListingApiCall()
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        if textField == textsearch {
            self.getSeachBook()
        }else {
            self.getHighlightBookListingApiCall()
        }
        return true
    }
    
    func getSeachBook() {
        self.showHud()
        
        self.view.endEditing(true)
        let parameterDictionary = NSMutableDictionary()
        let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        let book_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "book_id")) as! String
        parameterDictionary.setValue(textsearch.text, forKey: "selection")
        parameterDictionary.setValue(user_id, forKey: "user_id")
        parameterDictionary.setValue(book_id, forKey: "book_id")
        
        let methodName = "searchHighlightSecond"
        
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message = DataManager.getVal(responseData?["message"]) as! String
            self.arrHighlightedMarkedBooks.removeAll()
            if status == "1" {
                let response = DataManager.getVal(responseData?["data"]) as! [[String: Any]]
                self.arrHighlightedMarkedBooks = response
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.noteTableview.frame.size.width, height: self.noteTableview.frame.size.height))
                label.textColor = .black
                label.textAlignment = .center
                label.text = ""
                self.noteTableview.backgroundView = label
                self.noteTableview.reloadData()
            } else {
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.noteTableview.frame.size.width, height: self.noteTableview.frame.size.height))
                label.textColor = .black
                label.textAlignment = .center
               // label.text = "No Highlight book found."
                label.text = "No results found"
                self.noteTableview.backgroundView = label
                self.noteTableview.reloadData()
                //self.view.makeToast(message: message)
            }
            self.clearHud()
        }
    }
    
  
    
    @IBAction func BackbtnAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func searchBtnAction(_ sender: Any) {
        self.getSeachBook()
    }
    
    @objc func shareHighlight(_ sender: UIButton) {
        if DataManager.isConnectedToNetwork() {
        if let dic = arrHighlightedMarkedBooks[sender.tag] as? [String:Any]{
            if let hilightedText =  dic["selection"] as? String{
                let authorName = dic["author"] as? String
                let book_title = dic["book_title"] as? String
                let chapter_name = dic["chapter_name"] as? String
                let text:String!
                text = "\(chapter_name ?? "")\n\n“\(hilightedText)” \n\n\(book_title ?? "")  \n\(authorName ?? "") \n\(readerConfig.localizedShareBy)"
                let firstActivityItem = text
                let activityViewController : UIActivityViewController = UIActivityViewController(
                    activityItems: [firstActivityItem ?? ""], applicationActivities: nil)
                
                // This lines is for the popover you need to show in iPad
                activityViewController.popoverPresentationController?.sourceView = (sender as! UIButton)
                
                // This line remove the arrow of the popover to show in iPad
                activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.any
                activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
                
                // Anything you want to exclude
                activityViewController.excludedActivityTypes = [
                    UIActivity.ActivityType.postToWeibo,
                    UIActivity.ActivityType.print,
                    UIActivity.ActivityType.assignToContact,
                    UIActivity.ActivityType.saveToCameraRoll,
                    UIActivity.ActivityType.addToReadingList,
                    UIActivity.ActivityType.postToFlickr,
                    UIActivity.ActivityType.postToVimeo,
                    UIActivity.ActivityType.postToTencentWeibo
                ]
                self.present(activityViewController, animated: true, completion: nil)
            }
        }
        }else {
            self.view.makeToast(message: "No Internet Connection.")
        }
    }
    
    @objc func showNotes(_ sender: UIButton) {
        if DataManager.isConnectedToNetwork() {
            let dic = arrHighlightedMarkedBooks[sender.tag]
            if let highlightedId =  dic["app_id"] as? String{
                if let bookid = dic["book_id"] as? Int{
                    let obj = self.storyboard?.instantiateViewController(withIdentifier: "NotesVC") as! NotesVC
                    obj.book_Id = bookid
                    obj.higlightedId = highlightedId
                    self.navigationController?.present(obj, animated: true, completion: nil)
                }
            }
        }else {
            self.view.makeToast(message: "No Internet Connection.")
        }
       
    }
    
    
    
    @objc func deleteHighlight(_ sender: UIButton) {
        if DataManager.isConnectedToNetwork() {
        
        let myAlert = PMAlertController(title: "Holy Reads", description: "Are you sure you want to delete the highlight", image: UIImage(named: "welcome_logo"), style: .alert)
           
        
        myAlert.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () -> Void in
            print("Cancel")
            
           
        }))
        myAlert.addAction(PMAlertAction(title: "Yes", style: .default, action: { () in
            if let dic = self.arrHighlightedMarkedBooks[sender.tag] as? [String:Any]{
                if let highlightedId =  dic["app_id"] as? String{
                    if let bookid = dic["book_id"] as? Int{
                        self.deleteHighlightApiCall(HighlightedId: highlightedId, BookID: bookid)
                        Highlight.removeById(withConfiguration: self.config, highlightId: highlightedId)
                    }
                }
            }
        }))
        self.present(myAlert, animated: true, completion: nil)
        }else {
            self.view.makeToast(message: "No Internet Connection.")
        }
        
//        let normalAlert = UIAlertController(title: "Holy reads", message: "Are you sure you want to delete the highlight.", preferredStyle: .alert)
//        normalAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
//            if let dic = self.arrHighlightedMarkedBooks[sender.tag] as? [String:Any]{
//                if let highlightedId =  dic["app_id"] as? String{
//                    if let bookid = dic["book_id"] as? Int{
//                        self.deleteHighlightApiCall(HighlightedId: highlightedId, BookID: bookid)
//                        Highlight.removeById(withConfiguration: self.config, highlightId: highlightedId)
//                    }
//                }
//            }
//        }))
//        normalAlert.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: nil))
//
//        self.present(normalAlert, animated: true, completion: nil)
    }
    
    func deleteHighlightApiCall(HighlightedId : String,BookID : Int) {
        self.showHud()
        let parameterDictionary = NSMutableDictionary()
        let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        parameterDictionary.setValue(user_id, forKey: "user_id")
        parameterDictionary.setValue(HighlightedId, forKey: "app_id")
        parameterDictionary.setValue(BookID, forKey: "book_id")
        
        let methodName = "deleteHighlight"
        
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
            if status == "1" {
                self.getHighlightBookListingApiCall()
            }else {
                self.view.makeToast(message: message)
            }
            self.clearHud()
        }
    }
    
    
    func Test(BookName: String)  {
        if let documentsPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let AddPicture_url: NSURL = NSURL(string: documentsPathString)!
            let directoryContents = try! FileManager.default.contentsOfDirectory(at: AddPicture_url as URL, includingPropertiesForKeys: nil)
            // print(directoryContents)
            
            // if you want to filter the directory contents you can do like this:
           // getBookFromLocal()
            let mp3Files = directoryContents.filter{ $0.pathExtension == "epub" }
            var arrFiles = [String]()
            for i in 0..<mp3Files.count{
                let str = mp3Files[i]
                let s =  str.absoluteString
                arrFiles.append(s)
            }
            print(arrFiles)
            var strBookName:String!
            strBookName = BookName.replacingOccurrences(of: " ", with: "")
            let name = arrFiles.filter{ $0.contains(strBookName)}
            
            print("mp3 urls:",name)
            if name.count == 0 {
                print("No Book Found")
                return
            }
            //This gives you the string formed path
            let config = FolioReaderConfig()
            config.scrollDirection = .horizontalWithVerticalContent
            ///config.shouldHideNavigationOnTap = epub.shouldHideNavigationOnTap
            //config.scrollDirection = epub.scrollDirection
            config.tintColor = UIColor.init(red: 85.0/255.0, green: 150.0/255.0, blue: 202.0/255.0, alpha: 1.0)
            //config.menuTextColor = UIColor.init(red: 85.0/255.0, green: 150.0/255.0, blue: 202.0/255.0, alpha: 1.0)
            config.menuTextColor = UIColor.init(red: 32.0/255.0, green: 52.0/255.0, blue: 75.0/255.0, alpha: 1.0)
            config.menuSeparatorColor = UIColor.init(red: 235.0/255.0, green: 237.0/255.0, blue: 239.0/255.0, alpha: 1.0)
            config.menuBackgroundColor = UIColor.init(red: 244.0/255.0, green: 246.0/255.0, blue: 245.0/255.0, alpha: 1.0)
            config.menuTextColorSelected = UIColor.init(red: 85.0/255.0, green: 150.0/255.0, blue: 202.0/255.0, alpha: 1.0)
            config.quoteCustomLogoImage = UIImage.init(named: "headphones")
            config.shouldHideNavigationOnTap = false
            config.hidePageIndicator = true
            var strbook:String!
            strbook = bookName.replacingOccurrences(of: " ", with: "")
            let bookPath = Bundle.path(forResource: strbook, ofType: "epub", inDirectory: documentsPathString)
            let folioReader = FolioReader()
            folioReader.presentReader(parentViewController: self, withEpubPath: bookPath!, andConfig: config)
        }
    }
    
    func DownloadBook(bookName: String, boookUrl : String) {
        //let book = "https://i.devtechnosys.tech:8084/holyreads/webroot/summary/pdf/Harry_1575868129_summary_.epub"
        let bookUrl = URL.init(string: boookUrl)
        
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        // lets create your destination file url
        let destinationUrl = documentsDirectoryURL.appendingPathComponent("\(bookName).epub")
        var newUrl:String!
        newUrl = destinationUrl.absoluteString
        var finalUrl:String!
        finalUrl = newUrl.replacingOccurrences(of: "%20", with: "")
        print(finalUrl!)
        let fileUrl = URL(string: finalUrl)
        print(fileUrl!)
        // to check if it exists before downloading it
        if FileManager.default.fileExists(atPath: fileUrl!.path) {
            print("The file already exists at path")
            // if the file doesn't exist
        } else {
            // you can use NSURLSession.sharedSession to download the data asynchronously
            URLSession.shared.downloadTask(with: bookUrl!, completionHandler: { (location, response, error) -> Void in
                guard let location = location, error == nil else { return }
                do {
                    // after downloading your file you need to move it to your destination url
                    try FileManager.default.moveItem(at: location, to: fileUrl!)
                    //self.clearHud()
                    // self.view.makeToast(message: "Downloaded Successfully")
                    print("File moved to documents folder")
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
            }).resume()
        }
    }
    
    func getBookFromLocal()  {
        let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            // Get the directory contents urls (including subfolders urls)
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil)
            print(directoryContents)
            // if you want to filter the directory contents you can do like this:
            let mp3Files = directoryContents.filter{ $0.pathExtension == "epub" }
            print("mp3 urls:",mp3Files)
            let mp3FileNames = mp3Files.map{ $0.deletingPathExtension().lastPathComponent }
            print("mp3 list:", mp3FileNames)
        } catch {
            print(error)
        }
    }

}

extension NotesHighlightsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrHighlightedMarkedBooks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NoteHighCell", for: indexPath) as! NoteHighCell
        if arrHighlightedMarkedBooks.count != 0 {
            let dict  = arrHighlightedMarkedBooks[indexPath.row]
            
            if let bookNameNew = dict["book_title"] as? String{
                cell.lblBokName.text = bookNameNew
                self.bookName = bookNameNew
            }
            
            
            if let bookName = dict["author"] as? String{
                cell.lblAuthorName.text = bookName
                let defaults = UserDefaults.standard
                defaults.setValue(bookName, forKey: "NameAuth")
                defaults.synchronize()
            }
            
            if let chaptername = dict["chapter_name"] as? String{
                cell.chapterNameLbl.text = chaptername
            }
            if let bookName = dict["selection"] as? String{
                cell.lblHighlight.text = bookName
            }
            if let epubUrl =  dict["pdf"] as? String{
                //self.showHud()
                self.DownloadBook(bookName:  self.bookName, boookUrl: epubUrl)
            }
            
            
            if let bookThumbnail = dict["cover_image"] as? String {
                cell.imgBook.sd_imageIndicator = SDWebImageActivityIndicator.gray
                cell.imgBook.startAnimating()
                let url = URL.init(string: bookThumbnail)
                cell.imgBook.sd_setImage(with: url, placeholderImage: UIImage.init(named: ""), options: .refreshCached, completed: { (img, error, cacheType, url) in
                })
                cell.imgBook.stopAnimating()
            }
            cell.btnShare.tag = indexPath.row
            cell.btnDelete.tag = indexPath.row
            cell.btnComment.tag = indexPath.row
            cell.btnShare.addTarget(self, action: #selector(shareHighlight(_:)), for: .touchUpInside)
            cell.btnDelete.addTarget(self, action: #selector(deleteHighlight(_:)), for: .touchUpInside)
            cell.btnComment.addTarget(self, action: #selector(showNotes(_:)), for: .touchUpInside)
        }
        return cell
    }
    
    func Test1(BookName: String)  {
        if let documentsPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let AddPicture_url: NSURL = NSURL(string: documentsPathString)!
            let directoryContents = try! FileManager.default.contentsOfDirectory(at: AddPicture_url as URL, includingPropertiesForKeys: nil)
            // print(directoryContents)
            
            // if you want to filter the directory contents you can do like this:
            
            let mp3Files = directoryContents.filter{ $0.pathExtension == "epub" }
            var arrFiles = [String]()
            for i in 0..<mp3Files.count{
                let str = mp3Files[i]
                let s =  str.absoluteString
                arrFiles.append(s)
            }
            print(arrFiles)
            let name = arrFiles.filter{ $0.contains(BookName)}
            
            print("mp3 urls:",name)
            if name.count == 0 {
                print("No Book Found")
                return
            }
            //This gives you the string formed path
            let config = FolioReaderConfig()
            config.scrollDirection = .horizontalWithVerticalContent
            ///config.shouldHideNavigationOnTap = epub.shouldHideNavigationOnTap
            //config.scrollDirection = epub.scrollDirection
            config.tintColor = UIColor.init(red: 85.0/255.0, green: 150.0/255.0, blue: 202.0/255.0, alpha: 1.0)
            //config.menuTextColor = UIColor.init(red: 85.0/255.0, green: 150.0/255.0, blue: 202.0/255.0, alpha: 1.0)
            config.menuTextColor = UIColor.init(red: 32.0/255.0, green: 52.0/255.0, blue: 75.0/255.0, alpha: 1.0)
            config.menuSeparatorColor = UIColor.init(red: 235.0/255.0, green: 237.0/255.0, blue: 239.0/255.0, alpha: 1.0)
            config.menuBackgroundColor = UIColor.init(red: 244.0/255.0, green: 246.0/255.0, blue: 245.0/255.0, alpha: 1.0)
            config.menuTextColorSelected = UIColor.init(red: 85.0/255.0, green: 150.0/255.0, blue: 202.0/255.0, alpha: 1.0)
            config.quoteCustomLogoImage = UIImage.init(named: "headphones")
            config.shouldHideNavigationOnTap = false
            config.hidePageIndicator = true
            let bookPath = Bundle.path(forResource: bookName, ofType: "epub", inDirectory: documentsPathString)
//            let defaults = UserDefaults.standard
//            defaults.set(self.dictBookDetails, forKey: "VideoData")
//            defaults.synchronize()
            //UserDefaults.standard.set(self.dictBookDetails, forKey: "VideoData")
            let folioReader = FolioReader()
            folioReader.presentReader(parentViewController: self, withEpubPath: bookPath!, andConfig: config)
        }
    }
    
    func saveItemInToModel(bookid:String!,userid:String!,appid:String!,chaptername:String!,pagenmuber:String!,note:String!,rangy:String!,content:String!,type:String!) {
        let storeData =  itemModel.init(book_id: bookid, user_id: userid, app_id: appid, chapter_name: chaptername, note: note, page_number: pagenmuber, rangy: rangy, content: content, type: type)
        print(storeData)
//first
        let saveData  =  itemModel.init(book_id: bookid, user_id: userid, app_id: appid, chapter_name: chaptername, note: note, page_number: pagenmuber, rangy: rangy, content: content, type: type)
        print(saveData)
        self.saveItemInDataBase(item: saveData)
    }
    
    func saveItemInDataBase(item: itemModel) {
        let appDelegate         =   (UIApplication.shared.delegate) as! AppDelegate
        let managedContext      =   appDelegate.persistentContainer.viewContext
        let entity              =   NSEntityDescription.entity(forEntityName: "FolioReaderdatabase",in: managedContext)!
        //var Appid : String    =   ""
       
        var newEntity           =   NSManagedObject()
        
        let resArr              =   Config().matchData(tableName: "FolioReaderdatabase", AppId: newappid)
        if resArr.count > 0{
            print(resArr)
            newEntity            =   resArr[0]
        }else{
            newEntity            =   NSManagedObject(entity: entity,insertInto: managedContext)
        }
        self.saveManagedObjectData(newEntity: newEntity,item: item)
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func saveManagedObjectData(newEntity: NSManagedObject, item: itemModel) {
        newEntity.setValue(item.app_id!, forKey: "app_id")
        newEntity.setValue(item.book_id!, forKey: "book_id")
        newEntity.setValue(item.user_id!, forKey: "user_id")
        newEntity.setValue(item.rangy, forKey: "rangy")
        newEntity.setValue(item.page_number!, forKey: "page_number")
        newEntity.setValue(item.note!, forKey: "note")
        newEntity.setValue(item.chapter_name, forKey: "chapter_name")
        newEntity.setValue(item.content, forKey: "content")
        newEntity.setValue(item.type, forKey: "type")
       
       
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      
       let dict  = arrHighlightedMarkedBooks[indexPath.row]
       let bookTitle = dict["book_title"] as? String
       var book_id:Int!
       book_id = dict["book_id"] as? Int
       self.bookName = bookTitle!
       var high_Form:Int!
       high_Form = dict["highlight_form"] as? Int
       var note:String!
       note = dict["note"] as? String
       var appid:String!
       appid = dict["app_id"] as? String
       newappid = appid
       var chaptername:String!
       chaptername = dict["chapter_name"] as? String
       var pageno:Int!
       pageno = dict["page_number"] as? Int
       var rangy:String!
       rangy = dict["rangy"] as? String
       var selection:String!
       selection = dict["selection"] as? String
       var typen:String!
       typen = dict["android_highlight_type"] as? String
       var notnew:String!
       if note == nil {
            notnew = ""
       }else {
            notnew = note
       }
        
       
        
       let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
       self.saveItemInToModel(bookid: String(book_id), userid: user_id, appid: appid, chaptername: chaptername, pagenmuber: String(pageno-1), note: notnew, rangy: rangy, content: selection, type: typen)
        let defaults = UserDefaults.standard
        defaults.setValue("BookOut", forKey: "PositionV")
        defaults.setValue(rangy, forKey: "rangeex")
        
        defaults.synchronize()
        
        if high_Form == 3 {
           
                if let documentsPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
                    let AddPicture_url: NSURL = NSURL(string: documentsPathString)!
                    let directoryContents = try! FileManager.default.contentsOfDirectory(at: AddPicture_url as URL, includingPropertiesForKeys: nil)
                    // print(directoryContents)
                    
                    // if you want to filter the directory contents you can do like this:
                    // getBookFromLocal()
                    let mp3Files = directoryContents.filter{ $0.pathExtension == "epub" }
                    var arrFiles = [String]()
                    for i in 0..<mp3Files.count{
                        let str = mp3Files[i]
                        let s =  str.absoluteString
                        arrFiles.append(s)
                    }
                    print(arrFiles)
                    var strBookName:String!
                    strBookName =  self.bookName.replacingOccurrences(of: " ", with: "")
                    let name = arrFiles.filter{ $0.contains(strBookName)}
                    
                    print("mp3 urls:",name)
                    if name.count == 0 {
                        print("No Book Found")
                        return
                    }
                    //This gives you the string formed path
                    var config = FolioReaderConfig()
                    config.scrollDirection = .horizontalWithVerticalContent
                    ///config.shouldHideNavigationOnTap = epub.shouldHideNavigationOnTap
                    //config.scrollDirection = epub.scrollDirection
                    config.tintColor = UIColor.init(red: 85.0/255.0, green: 150.0/255.0, blue: 202.0/255.0, alpha: 1.0)
                    //config.menuTextColor = UIColor.init(red: 85.0/255.0, green: 150.0/255.0, blue: 202.0/255.0, alpha: 1.0)
                    config.menuTextColor = UIColor.init(red: 32.0/255.0, green: 52.0/255.0, blue: 75.0/255.0, alpha: 1.0)
                    config.menuSeparatorColor = UIColor.init(red: 235.0/255.0, green: 237.0/255.0, blue: 239.0/255.0, alpha: 1.0)
                    config.menuBackgroundColor = UIColor.init(red: 244.0/255.0, green: 246.0/255.0, blue: 245.0/255.0, alpha: 1.0)
                    config.menuTextColorSelected = UIColor.init(red: 85.0/255.0, green: 150.0/255.0, blue: 202.0/255.0, alpha: 1.0)
                    config.quoteCustomLogoImage = UIImage.init(named: "headphones")
                    config.shouldHideNavigationOnTap = false
                    config.hidePageIndicator = true
                    var strbook:String!
                    strbook = bookName.replacingOccurrences(of: " ", with: "")
                    let bookPath = Bundle.path(forResource: strbook, ofType: "epub", inDirectory: documentsPathString)
                    var folioReader = FolioReader()
                    
                    var newbookid:String!
                    newbookid = String(book_id)
                    
                    self.highlights = Highlight.allByBookId(withConfiguration: config, bookId: strbook)
                   
                    //self.highlights = Highlight.allByBookId(withConfiguration: self.config, bookId: strbook, andPage: page as NSNumber?)
                    guard let highlight = highlights[safe: indexPath.row] else {
                        let hiligh = arrHighlightedMarkedBooks[indexPath.row]
                        let pagenum = (hiligh["page_number"] as? Int)!
                        let bookid = (hiligh["book_id"] as? Int)!
                        let userid = (hiligh["user_id"] as? Int)!
                        let app_id = hiligh["app_id"] as? String
                        let book_title = hiligh["book_title"] as? String
                        let chaptername = hiligh["chapter_name"] as? String
                        let selectio = hiligh["selection"] as? String
                        let start_obj = (hiligh["startOffset"] as? Int)!
                        let end_obj = (hiligh["endOffset"] as? Int)!
                        let type = (hiligh["type"] as? Int)!
                        let notfor = hiligh["noteForHighlight"] as? String
                        let notN = hiligh["note"] as? String
                        let contentpre = hiligh["contentPre"] as? String
                        let contentpost = hiligh["contentPost"] as? String
                        let android_highlight_type = hiligh["android_highlight_type"] as? String
    
                        let highlight = Highlight()
                        highlight.highlightId = app_id
                        highlight.type = type
                        highlight.noteForHighlight = notN
                        highlight.date = Date()
                        highlight.content = selectio
                        highlight.contentPre = "then it will be easier to tell which is more effective"
                        highlight.contentPost = "articles for an internet encyclopedia"
                        highlight.page = pagenum+1
                        highlight.bookId = book_title
                        highlight.startOffset = start_obj
                        highlight.endOffset = end_obj
    
    
    
        //                let match = Highlight.MatchingHighlight(text: selectio!, id: app_id!, startOffset: String(start_obj), endOffset: String(end_obj), bookId: book_title!, currentPage: pagenum+1)
        //                let highlight1 = Highlight.matchHighlight(match)
        //                highlight1?.persist(withConfiguration: config)
        //                print(highlight1!)
        //                let realm = try! Realm(configuration: readerConfig.realmConfiguration)
        //
        //                try! realm.write {
        //                    realm.add(highlight, update: .all)
        //                }
    
                        let defaults = UserDefaults.standard
                        defaults.set(pagenum+1, forKey: "PAGENew")
                        defaults.set(app_id, forKey: "IdNew")
                        defaults.set(notN, forKey: "notN")
                        defaults.set("Note", forKey: "OpenPage")
                        defaults.set(strbook, forKey: "NewBook")
                        defaults.set(indexPath.row, forKey: "NEWIndex")
                        defaults.set("HighLight", forKey: "HIghNew")
                        defaults.set(end_obj, forKey: "EndOffset")
                        defaults.set(start_obj, forKey: "StartOffset")
                        defaults.set(type, forKey: "style")
                        defaults.setValue("web", forKey: "Hiogli")
                        defaults.setValue(selectio, forKey: "select")
                        defaults.setValue(notfor, forKey: "noteForHighlight")
                        defaults.setValue(contentpre, forKey: "conpre")
                        defaults.setValue(contentpost, forKey: "conpost")
                        defaults.setValue(android_highlight_type, forKey: "AndHighType")
    
                        defaults.synchronize()
                        NotificationCenter.default.post(name: NSNotification.Name("OpenHigh"), object: nil)
                        folioReader.presentReader(parentViewController: self, withEpubPath: bookPath!, andConfig: config)
                        return }
                    print(self.highlights)
                    print(highlight)
//                    let realm = try! Realm(configuration: readerConfig.realmConfiguration)
//                    realm.beginWrite()
                   // realm.add(highlight, update: .all)
                        
                    highlight.noteForHighlight = note
                    print(highlight)
                    print(highlight)
                    let defaults = UserDefaults.standard
                    defaults.set(highlight.page, forKey: "PAGENew")
                    defaults.set(highlight.highlightId, forKey: "IdNew")
                    defaults.set("Note", forKey: "OpenPage")
                    defaults.set(strbook, forKey: "NewBook")
                    defaults.set(indexPath.row, forKey: "NEWIndex")
                    defaults.set("HighLight", forKey: "HIghNew")
                    defaults.setValue("app", forKey: "Hiogli")
                    defaults.setValue(highlight.endOffset, forKey: "EndOffset")
                    defaults.setValue(highlight.startOffset, forKey: "StartOffset")
                    
                    defaults.synchronize()
                    NotificationCenter.default.post(name: NSNotification.Name("OpenHigh"), object: nil)
                    folioReader.presentReader(parentViewController: self, withEpubPath: bookPath!, andConfig: config)
                   // self.folioReader.readerCenter?.changePageWith1(page: highlight.page, andFragment: highlight.highlightId)
                
                }

            

        }else {
            if let documentsPathString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
                let AddPicture_url: NSURL = NSURL(string: documentsPathString)!
                let directoryContents = try! FileManager.default.contentsOfDirectory(at: AddPicture_url as URL, includingPropertiesForKeys: nil)
                // print(directoryContents)
                
                // if you want to filter the directory contents you can do like this:
                // getBookFromLocal()
                let mp3Files = directoryContents.filter{ $0.pathExtension == "epub" }
                var arrFiles = [String]()
                for i in 0..<mp3Files.count{
                    let str = mp3Files[i]
                    let s =  str.absoluteString
                    arrFiles.append(s)
                }
                print(arrFiles)
                var strBookName:String!
                strBookName =  self.bookName.replacingOccurrences(of: " ", with: "")
                let name = arrFiles.filter{ $0.contains(strBookName)}
                
                print("mp3 urls:",name)
                if name.count == 0 {
                    print("No Book Found")
                    return
                }
                //This gives you the string formed path
                var config = FolioReaderConfig()
                config.scrollDirection = .horizontalWithVerticalContent
                ///config.shouldHideNavigationOnTap = epub.shouldHideNavigationOnTap
                //config.scrollDirection = epub.scrollDirection
                config.tintColor = UIColor.init(red: 85.0/255.0, green: 150.0/255.0, blue: 202.0/255.0, alpha: 1.0)
                //config.menuTextColor = UIColor.init(red: 85.0/255.0, green: 150.0/255.0, blue: 202.0/255.0, alpha: 1.0)
                config.menuTextColor = UIColor.init(red: 32.0/255.0, green: 52.0/255.0, blue: 75.0/255.0, alpha: 1.0)
                config.menuSeparatorColor = UIColor.init(red: 235.0/255.0, green: 237.0/255.0, blue: 239.0/255.0, alpha: 1.0)
                config.menuBackgroundColor = UIColor.init(red: 244.0/255.0, green: 246.0/255.0, blue: 245.0/255.0, alpha: 1.0)
                config.menuTextColorSelected = UIColor.init(red: 85.0/255.0, green: 150.0/255.0, blue: 202.0/255.0, alpha: 1.0)
                config.quoteCustomLogoImage = UIImage.init(named: "headphones")
                config.shouldHideNavigationOnTap = false
                config.hidePageIndicator = true
                var strbook:String!
                strbook = bookName.replacingOccurrences(of: " ", with: "")
                let bookPath = Bundle.path(forResource: strbook, ofType: "epub", inDirectory: documentsPathString)
                var folioReader = FolioReader()
                
                var newbookid:String!
                newbookid = String(book_id)
                
                self.highlights = Highlight.allByBookId(withConfiguration: config, bookId: strbook)
               
                //self.highlights = Highlight.allByBookId(withConfiguration: self.config, bookId: strbook, andPage: page as NSNumber?)
                guard let highlight = highlights[safe: indexPath.row] else {
                    let hiligh = arrHighlightedMarkedBooks[indexPath.row]
                    let pagenum = (hiligh["page_number"] as? Int)!
                    let bookid = (hiligh["book_id"] as? Int)!
                    let userid = (hiligh["user_id"] as? Int)!
                    let app_id = hiligh["app_id"] as? String
                    let book_title = hiligh["book_title"] as? String
                    let chaptername = hiligh["chapter_name"] as? String
                    let selectio = hiligh["selection"] as? String
                    let start_obj = (hiligh["startOffset"] as? Int)!
                    let end_obj = (hiligh["endOffset"] as? Int)!
                    let type = (hiligh["type"] as? Int)!
                    let notfor = hiligh["noteForHighlight"] as? String
                    let notN = hiligh["note"] as? String
                    let contentpre = hiligh["contentPre"] as? String
                    let contentpost = hiligh["contentPost"] as? String
                    let android_highlight_type = hiligh["android_highlight_type"] as? String
                    
                    let highlight = Highlight()
                    highlight.highlightId = app_id
                    highlight.type = type
                    highlight.noteForHighlight = notN
                    highlight.date = Date()
                    highlight.content = selectio
                    highlight.contentPre = ""
                    highlight.contentPost = ""
                    highlight.page = pagenum+1
                    highlight.bookId = book_title
                    highlight.startOffset = start_obj
                    highlight.endOffset = end_obj
                    
                    
                  //  realm.add(highlight, update: .all)
                    print(highlight)
    

                    let defaults = UserDefaults.standard
                    defaults.set(pagenum+1, forKey: "PAGENew")
                    defaults.set(app_id, forKey: "IdNew")
                    defaults.set(notN, forKey: "notN")
                    defaults.set("Note", forKey: "OpenPage")
                    defaults.set(strbook, forKey: "NewBook")
                    defaults.set(indexPath.row, forKey: "NEWIndex")
                    defaults.set("HighLight", forKey: "HIghNew")
                    defaults.set(end_obj, forKey: "EndOffset")
                    defaults.set(start_obj, forKey: "StartOffset")
                    defaults.set(type, forKey: "style")
                    defaults.setValue("web", forKey: "Hiogli")
                    defaults.setValue(selectio, forKey: "select")
                    defaults.setValue(notfor, forKey: "noteForHighlight")
                    defaults.setValue(contentpre, forKey: "conpre")
                    defaults.setValue(contentpost, forKey: "conpost")
                    defaults.setValue(android_highlight_type, forKey: "AndHighType")
                    defaults.setValue("BookOut", forKey: "PositionV")
                    defaults.synchronize()
                    
                    //self.higligh(book_id: bookid, pagenumber: pagenum+1, book_title: book_title, Chapter_name: chaptername, app_id: app_id, Content: selectio, userid: userid,StattOffset: start_obj,EndOffset: end_obj)
                    NotificationCenter.default.post(name: NSNotification.Name("OpenHigh"), object: nil)
                    folioReader.presentReader(parentViewController: self, withEpubPath: bookPath!, andConfig: config)
                    return }
                print(self.highlights)
                print(highlight)
//                let realm = try! Realm(configuration: readerConfig.realmConfiguration)
//                realm.beginWrite()
                
//                let defaults = UserDefaults.standard
//                defaults.set(highlight.page, forKey: "PAGENew")
//                defaults.set(highlight.highlightId, forKey: "IdNew")
//                defaults.set("Note", forKey: "OpenPage")
//                defaults.set(strbook, forKey: "NewBook")
//                defaults.set(indexPath.row, forKey: "NEWIndex")
//                defaults.set("HighLight", forKey: "HIghNew")
//                defaults.setValue("app", forKey: "Hiogli")
//                defaults.setValue(highlight.endOffset, forKey: "EndOffset")
//                defaults.setValue(highlight.startOffset, forKey: "StartOffset")
//                defaults.synchronize()
//                NotificationCenter.default.post(name: NSNotification.Name("OpenHigh"), object: nil)
//                folioReader.presentReader(parentViewController: self, withEpubPath: bookPath!, andConfig: config)
               // self.folioReader.readerCenter?.changePageWith1(page: highlight.page, andFragment: highlight.highlightId)
            
            }

        }
        
                
        
     
       
        
        
        func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                guard let highlight = highlights[safe: indexPath.row] else { return }
                 let folioReader = FolioReader()
                if (highlight.page == folioReader.readerCenter?.currentPageNumber),
                    let page = folioReader.readerCenter?.currentPage {
                    Highlight.removeFromHTMLById(withinPage: page, highlightId: highlight.highlightId) // Remove from HTML
                }
                
                highlight.remove(withConfiguration: self.config) // Remove from Database
                highlights.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        }
        
       

       //self.Test(BookName:  self.bookName)
//        if let dict = DataManager.getVal(self.arrHighlightedMarkedBooks[indexPath.row]) as? [String:Any]{
//            if let bookId = dict["book_id"] as? Int {
//                //self.Test(BookName: bookName)
//                let obj = self.storyboard?.instantiateViewController(withIdentifier: "DiscoverDetailsVC") as! DiscoverDetailsVC
//                obj.bookId = bookId
//
//                self.navigationController?.pushViewController(obj, animated: true)
//            }
//        }
    }
   
    
    
    
}

extension FolioReader {
    
    /// Present a Folio Reader Container modally on a Parent View Controller.
    ///
    /// - Parameters:
    ///   - parentViewController: View Controller that will present the reader container.
    ///   - epubPath: String representing the path on the disk of the ePub file. Must not be nil nor empty string.
    ///   - unzipPath: Path to unzip the compressed epub.
    ///   - config: FolioReader configuration.
    ///   - shouldRemoveEpub: Boolean to remove the epub or not. Default true.
    ///   - animated: Pass true to animate the presentation; otherwise, pass false.
    
    open func presentReader1(parentViewController: UIViewController, withEpubPath epubPath: String, unzipPath: String? = nil, andConfig config: FolioReaderConfig, shouldRemoveEpub: Bool = true, animated:
        Bool = true) {
        let readerContainer = FolioReaderContainer(withConfig: config, folioReader: self, epubPath: epubPath, unzipPath: unzipPath, removeEpub: shouldRemoveEpub)
        self.readerContainer = readerContainer
        parentViewController.present(readerContainer, animated: animated, completion: nil)
    }
}
