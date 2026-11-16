//
//  DiscoverDetail_IpadVC.swift
//  Holy Reads
//
//  Created by Ashish Soni on 20/07/20.
//  Copyright © 2020 Ajeet singh Rawat. All rights reserved.
//

import UIKit
import SDWebImage
import IQKeyboardManagerSwift
import PMAlertController
import JJFloatingActionButton
import CoreData
//enum Epub: Int {
//    case bookOne = 0
//    case bookTwo
//
//    var name: String {
//        switch self {
//        case .bookOne: return "The" // standard eBook
//        case .bookTwo: return "The Silver Chair" // audio-eBook
//        }
//    }
//
//    var shouldHideNavigationOnTap: Bool {
//        switch self {
//        case .bookOne: return false
//        case .bookTwo: return true
//        }
//    }
//
//    var scrollDirection: FolioReaderScrollDirection {
//        switch self {
//        case .bookOne: return .vertical
//        case .bookTwo: return .horizontal
//        }
//    }
//
//    var bookPath: String? {
//        let a = Bundle.main.path(forResource: "A Love Worth Giving", ofType: "epub")
//        print(a)
//        // let url = URL(string: "https://d0.awsstatic.com/whitepapers/KMS-Cryptographic-Details.pdf")!
//        return a
//    }
//
//    var readerIdentifier: String {
//        switch self {
//        case .bookOne: return "READER_ONE"
//        case .bookTwo: return "READER_TWO"
//        }
//    }
//}


class DiscoverDetail_IpadVC: UIViewController,URLSessionDownloadDelegate {
    
    // MARK: - IBOutlet
    
    
    
    //Initialize HHFloatingView
    fileprivate var floatingView: HHFloatingView = {
        let floatingViewSize: CGFloat = 100.0
        let padding: CGFloat = 10.0
        let hhfv = HHFloatingView.init(frame: CGRect.init(origin: CGPoint.init(x: UIScreen.main.bounds.size.width - (floatingViewSize + padding), y: UIScreen.main.bounds.size.height - (floatingViewSize + padding)), size: CGSize.init(width: floatingViewSize, height: floatingViewSize)))
        return hhfv
    }()
    
    //MARK: Add Floating View.
    internal func addFloatingView() {
        floatingView.delegate = self
        floatingView.datasource = self
        view.addSubview(floatingView)
        floatingView.reload()
    }
    
    
    @IBOutlet weak var tblDiscoverDetails: UITableView!
    @IBOutlet weak var imgBook: UIImageView!
    @IBOutlet weak var imgBookCover: UIImageView!
    @IBOutlet weak var lblBookTitle: UILabel!
    @IBOutlet weak var lblAuthorNAme: UILabel!
    @IBOutlet weak var tblHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lblOverView: UILabel!
    @IBOutlet weak var lblOverViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var btnBookFav: UIButton!
    @IBOutlet weak var lblShortDescription: UILabel!
    @IBOutlet weak var lblBookIsFor: UILabel!
    @IBOutlet weak var lblAboutAuthor: UILabel!
    @IBOutlet weak var btnRead: UIButton!
    @IBOutlet weak var btnListin: UIButton!
    @IBOutlet weak var btnWatch: UIButton!
    
    var bookId = Int()
    var dictBookDetails = [String: Any]()
    let folioReader = FolioReader()
    var cat_id = String()
    var bookName = String()
    var arrMusic = [String]()
    var downloadtype:String!
    // MARK: - ViewLifeCycle
    var arrDownloadDetails = [DownloadEnitity]()
    var arrHighlightedMarkedBooks = [[String:Any]]()
    fileprivate  var highlights = [Highlight]()
    var higforsts:Int!
    @IBOutlet var progressView: UIView!
    @IBOutlet weak var progressbar: UIProgressView!
    @IBOutlet weak var startlbl: UILabel!
    @IBOutlet weak var endLbl: UILabel!
    @IBOutlet var CloseAddNotesPopUp: UITapGestureRecognizer!
    @IBOutlet weak var downloadtypeLbl: UILabel!
    let progress = Progress(totalUnitCount: 10)
    
    var progress1: Float = 0.0
    var localhighArray = NSMutableArray()
    
    var task: URLSessionTask!
    var currentDate:String!
    var increaseCount:Int = 0

    var percentageWritten:Float = 0.0
    var taskTotalBytesWritten = 0
    var taskTotalBytesExpectedToWrite = 0
    var BookIdNewArray = [Int]()
    lazy var session : URLSession = {
        let config = URLSessionConfiguration.default
        // config.allowsCellularAccess = false
        let session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
        return session
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CloseAddNotesPopUp = UITapGestureRecognizer(target: self, action: #selector(ClosePopUp))
        progressView.addGestureRecognizer(CloseAddNotesPopUp)
        //getHighlightBookListingApiCall()
     //   increaseCount = UserDefaults.standard.integer(forKey: "Count")
        if DataManager.isConnectedToNetwork() {
            Config().deleteAllRecords(tbaleName: "FolioReaderdatabase")
        }else{
            print("Ashish")
        }
        self.getHighlightBookListingApiCall1()
//        Config().deleteAllRecords(tbaleName: "FolioReaderdatabase")
        let freests = UserDefaults.standard.value(forKey: "FREESTS") as? String
        let substs = UserDefaults.standard.value(forKey: "SUBSTS") as? String
        if substs == "1" {
            addFloatingView()
        }else {
            if freests == "1" {
                addFloatingView()
            }else {
                print("Ashish")
            }
        }
        // Do any additional setup after loading the view.
        
        //        tblDiscoverDetails.rowHeight = UITableView.automaticDimension
        //        tblDiscoverDetails.estimatedRowHeight = 70
        UserDefaults.standard.setValue(bookId, forKey: "book_id")
        UIAccessibility.requestGuidedAccessSession(enabled: true){
            success in
            print("Request guided access success \(success)")
        }
        //        NotificationCenter.default.addObserver(self, selector: #selector(CompletedBookNotification(_:)), name: NSNotification.Name(rawValue: "CompletedBookNotification"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ReadingBookNotification(_:)), name: NSNotification.Name(rawValue: "ReadingBookNotification"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.currencyItemChosen1(_:)), name: NSNotification.Name("AudioPlayer"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.currencyItemChosen(_:)), name: NSNotification.Name("VideoPlayer"), object: nil)
        
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy hh:mm a"
        currentDate = formatter.string(from: date)
        
        
    }
    func getHighlightBookListingApiCall1() {
        self.showHud()
        let parameterDictionary = NSMutableDictionary()
        let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        
        parameterDictionary.setValue(user_id, forKey: "user_id")
        parameterDictionary.setValue(bookId, forKey: "book_id")
        
        let methodName = "getHighlightListSecond"
        
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
            
            if status == "1" {
                if let response  = DataManager.getVal(responseData?["data"]) as? NSMutableArray {
                    self.localhighArray = response
                }
                
            }else {
            }
            self.clearHud()
        }
    }
    @objc func ClosePopUp (_ sender: UITapGestureRecognizer) {
       self.progressView.removeFromSuperview()
   }
    
    func MbHud() {
        var hud =  MBProgressHUD.showAdded(to: self.view, animated: true)
        // Set the bar determinate mode to show task progress.
        progress1 = 0.0
        hud?.mode = MBProgressHUDMode.determinateHorizontalBar
        hud?.isUserInteractionEnabled = true;
        hud?.labelText = NSLocalizedString("Downloading...", comment: "HUD loading title")
        DispatchQueue.global(qos: .default).async(execute: {() -> Void in
            // Do something useful in the background and update the HUD periodically.
            self.doSomeWorkWithProgress()
            DispatchQueue.main.async(execute: {() -> Void in
                //hud?.hide(true)
                hud?.labelText = NSLocalizedString("Just Wait...", comment: "HUD loading title")
            })
        })
    }
    
    //MARK:- share video
    func doSomeWorkWithProgress() {
        // This just increases the progress indicator in a loop.
        while progress1 < 1.0 {
            DispatchQueue.main.async(execute: {() -> Void in
                // Instead we could have also passed a reference to the HUD
                // to the HUD to myProgressTask as a method parameter.
                print(self.progress)
                MBProgressHUD(for: self.view).progress = self.progress1
            })
            usleep(50000)
        }
    }
    
    //MARK:- URL Session delegat
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        print("downloaded \(100*totalBytesWritten/totalBytesExpectedToWrite)")
        taskTotalBytesWritten = Int(totalBytesWritten)
        taskTotalBytesExpectedToWrite = Int(totalBytesExpectedToWrite)
        percentageWritten = Float(taskTotalBytesWritten) / Float(taskTotalBytesExpectedToWrite)
        print(percentageWritten)
        //  let x = Double(percentageWritten).rounded(toPlaces: 2)
        let x = String(format:"%.2f", percentageWritten)
        print(x)
        self.progress1 = Float(x)!
        print(progress1)

    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
        // unused in this example
    }



    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("completed: error: \(String(describing: error))")
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("Finished downloading!")
        DispatchQueue.main.async(execute: {() -> Void in
            MBProgressHUD.hide(for: self.view, animated: true)
        })
       
    }
    
    
   
    @IBAction func cancelBtnAction(_ sender: UIButton) {
        self.arrDownloadDetails = DownloadEnitity.shared.fetchData()
        let dict = arrDownloadDetails[sender.tag] as DownloadEnitity
        var idnew:String!
        idnew = dict.book_name
        var id:Int64!
        id = dict.id
        self.progressView.removeFromSuperview()
       // Config().deleteAllRecords(tbaleName: "DownloadEnitity")
        self.DeleteBookDocumentDirectory(arrFolderNames: idnew)
        self.DeleteDataMeal(id:id)
        
        let defaults = UserDefaults.standard
        defaults.setValue(idnew, forKey: "bookNID")
        defaults.setValue(id, forKey: "booki")
        defaults.setValue("delete", forKey: "MyDown")
        defaults.synchronize()
    }
    
    
    func DeleteDataMeal(id: Int64) {
        let appDelegate         =   (UIApplication.shared.delegate) as! AppDelegate
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DownloadEnitity")
        let context      =   appDelegate.persistentContainer.viewContext
        request.predicate = NSPredicate(format: "id = %d", id)
        do{
          let test = try! context.fetch(request)
          if test.count != 0{
              let objupdate = test[0] as! NSManagedObject
                 do{
                  try! context.delete(objupdate)
                    print("Data Deleted Data saved.")
                }
            }
            else{
                return
            }
        }
    }
    
    func DeleteBookDocumentDirectory(arrFolderNames:String) {
            let documentsDirectoryURL = appDelegate.DocumentDirectoryUrl!
            let BookFolderPath = documentsDirectoryURL.appendingPathComponent("\(arrFolderNames)")
             do {
                try FileManager.default.removeItem(at: BookFolderPath)
                print("Book Directory Deleted Successfully")
            }catch{
                print(error.localizedDescription)
            }
        
    }
    
    @objc func currencyItemChosen(_ pNotification: Notification?) {
        let freests = UserDefaults.standard.value(forKey: "FREESTS") as? String
        let substs = UserDefaults.standard.value(forKey: "SUBSTS") as? String
       // if let userSubscription = dictBookDetails["user_subscription_type"] as? Int{
            if substs == "1" {
                self.view.makeToast(message: "Please Upgrade your plan to watch video.")
            } else if substs == "2" {
                self.view.makeToast(message: "Please Upgrade your planwatch video.")
            }
            else{
                let obj = self.storyboard?.instantiateViewController(withIdentifier: "WatchVideo_IpadVC") as! WatchVideo_IpadVC
                obj.dictBookDetails = self.dictBookDetails
                self.navigationController?.pushViewController(obj, animated: true)
            }
       // }
        
    }
    
    @objc func currencyItemChosen1(_ pNotification: Notification?) {
        let freests = UserDefaults.standard.value(forKey: "FREESTS") as? String
        let substs = UserDefaults.standard.value(forKey: "SUBSTS") as? String
       // if let userSubscription = dictBookDetails["user_subscription_type"] as? Int{
            if substs == "1" {
                self.view.makeToast(message: "Please Upgrade your plan to listen audio.")
            }else if substs == "2" {
                if DataManager.isConnectedToNetwork() {
                    let obj = self.storyboard?.instantiateViewController(withIdentifier: "ListinMusic_IpadVC") as! ListinMusic_IpadVC
                    obj.dictBookDetails = self.dictBookDetails
                    self.navigationController?.pushViewController(obj, animated: true)
                } else {
                    self.view.makeToast(message: "No Internet Connection.")
                }
            }else {
                if DataManager.isConnectedToNetwork() {
                    let obj = self.storyboard?.instantiateViewController(withIdentifier: "ListinMusic_IpadVC") as! ListinMusic_IpadVC
                    obj.dictBookDetails = self.dictBookDetails
                    self.navigationController?.pushViewController(obj, animated: true)
                } else {
                    self.view.makeToast(message: "No Internet Connection.")
                }
            }
            
            
        //}
    }
    // MARK: - ViewWillAppear
    
    override func viewWillAppear(_ animated: Bool) {
        self.getBookDetail()
    }
    
    func open(epub: Epub) {
        // self.getBookFromLocal()
        guard let bookPath = epub.bookPath else {
            return
        }
        let readerConfiguration = self.readerConfiguration(forEpub: epub)
        folioReader.presentReader(parentViewController: self, withEpubPath: bookPath, andConfig: readerConfiguration, shouldRemoveEpub: false)
        self.ReadingBookApi()
        
    }
    private func readerConfiguration(forEpub epub: Epub) -> FolioReaderConfig {
        let config = FolioReaderConfig(withIdentifier: epub.readerIdentifier)
        config.shouldHideNavigationOnTap = epub.shouldHideNavigationOnTap
        config.scrollDirection = epub.scrollDirection
        config.tintColor = UIColor.init(red: 85.0/255.0, green: 150.0/255.0, blue: 202.0/255.0, alpha: 1.0)
        config.menuTextColor = UIColor.init(red: 85.0/255.0, green: 150.0/255.0, blue: 202.0/255.0, alpha: 1.0)
        config.menuTextColorSelected = UIColor.init(red: 85.0/255.0, green: 150.0/255.0, blue: 202.0/255.0, alpha: 1.0)
        config.quoteCustomLogoImage = UIImage.init(named: "headphones")
        // config.closeButtonImage = UIImage.init(named: "text")
        //        config.nightModeBackground = UIColor.yellow
        //        config.nightModeSeparatorColor = UIColor.red
        //        config.nightModeMenuBackground = UIColor.brown
        config.shouldHideNavigationOnTap = false
        config.hidePageIndicator = false
        //        config.canChangeScrollDirection = false
        //        config.enableTTS = false
        //        config.displayTitle = true
        //        config.allowSharing = false
        //        config.tintColor = UIColor.blue
        //        config.toolBarTintColor = UIColor.redColor()
        //        config.menuBackgroundColor = UIColor.purple
        //        config.menuTextColor = UIColor.brownColor()
        //        config.menuBackgroundColor = UIColor.lightGrayColor()
        //        config.hidePageIndicator = true
        //        config.realmConfiguration = Realm.Configuration(fileURL: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("1573544615_summary_"))
        
        // Custom sharing quote background
        
        config.quoteCustomBackgrounds = []
        if let image = UIImage(named: "demo-bg") {
            let customImageQuote = QuoteImage(withImage: image, alpha: 0.6, backgroundColor: UIColor.black)
            config.quoteCustomBackgrounds.append(customImageQuote)
        }
        let textColor = UIColor(red:0.86, green:0.73, blue:0.70, alpha:1.0)
        let customColor = UIColor(red:0.30, green:0.26, blue:0.20, alpha:1.0)
        let customQuote = QuoteImage(withColor: customColor, alpha: 1.0, textColor: textColor)
        config.quoteCustomBackgrounds.append(customQuote)
        return config
    }
    
    func highlightBook(){
        var dict = NSDictionary()
        dict = self.arrHighlightedMarkedBooks[0] as NSDictionary
        var book_id:Int!
        book_id = dict["book_id"] as? Int
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
            guard let highlight = highlights[safe: 0] else {
                let hiligh = arrHighlightedMarkedBooks[0]
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
                
                
               
//                let match = Highlight.MatchingHighlight(text: selectio!, id: app_id!, startOffset: String(start_obj), endOffset: String(end_obj), bookId: book_title!,                                 currentPage: pagenum+1)
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
                defaults.set(0, forKey: "NEWIndex")
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
                
                //self.higligh(book_id: bookid, pagenumber: pagenum+1, book_title: book_title, Chapter_name: chaptername, app_id: app_id, Content: selectio, userid: userid,StattOffset: start_obj,EndOffset: end_obj)
                NotificationCenter.default.post(name: NSNotification.Name("OpenHigh"), object: nil)
                folioReader.presentReader(parentViewController: self, withEpubPath: bookPath!, andConfig: config)
                return }
            print(self.highlights)
            print(highlight)
           
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
    
    
    // MARK: - NavigationBar Buttons
    @IBAction func btnBack_DidSelect(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func Test(BookName: String)  {
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
            let defaults = UserDefaults.standard
            defaults.setValue(self.dictBookDetails, forKey: "VideoData")
            defaults.synchronize()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "APIHilgiCAll"), object: self, userInfo: nil)
            let folioReader = FolioReader()
            folioReader.readerCenter?.arrHighlightedMarkedBooks  = self.arrHighlightedMarkedBooks
            folioReader.presentReader(parentViewController: self, withEpubPath: bookPath!, andConfig: config)
        }
    }
    func DownloadBook(bookName: String, boookUrl : String) {
        //let book = "https://i.devtechnosys.tech:8084/holyreads/webroot/summary/pdf/Harry_1575868129_summary_.epub"
        let bookUrl = URL.init(string: boookUrl)
        
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        // lets create your destination file url
        let destinationUrl = documentsDirectoryURL.appendingPathComponent("\(bookName).epub")
        print(destinationUrl)
        // to check if it exists before downloading it
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            print("The file already exists at path")
            // if the file doesn't exist
        } else {
            // you can use NSURLSession.sharedSession to download the data asynchronously
            URLSession.shared.downloadTask(with: bookUrl!, completionHandler: { (location, response, error) -> Void in
                guard let location = location, error == nil else { return }
                do {
                    // after downloading your file you need to move it to your destination url
                    try FileManager.default.moveItem(at: location, to: destinationUrl)
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
    
    
    // MARK: - IBAction
    @IBAction func BtnUploadKindle(_ sender: UIButton) {
        let freests = UserDefaults.standard.value(forKey: "FREESTS") as? String
        let substs = UserDefaults.standard.value(forKey: "SUBSTS") as? String
        
        if substs == "1" {
            if  dictBookDetails["kindle_status"] as? Int == 1 {
                self.UploadBookToKindle()
            } else {
                let obj = self.storyboard?.instantiateViewController(withIdentifier: "Kindle_IpadVC") as! Kindle_IpadVC
                self.navigationController?.pushViewController(obj, animated: true)
            }
        }else {
            if freests == "1" {
                if  dictBookDetails["kindle_status"] as? Int == 1 {
                    self.UploadBookToKindle()
                } else {
                    let obj = self.storyboard?.instantiateViewController(withIdentifier: "Kindle_IpadVC") as! Kindle_IpadVC
                    self.navigationController?.pushViewController(obj, animated: true)
                }
            }else {
                let myAlert = PMAlertController(title: "Holy Reads", description: "Please purchase a plan.", image: UIImage(named: "welcome_logo"), style: .alert) //Image by freepik.com, taken on flaticon.com
                                
                myAlert.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () -> Void in
                    print("Cancel")
                }))
                
                myAlert.addAction(PMAlertAction(title: "Yes", style: .default, action: { () in
                    let obj = self.storyboard?.instantiateViewController(withIdentifier: "MembershipPlanVCNewIPAD") as! MembershipPlanVCNewIPAD
                    self.navigationController?.pushViewController(obj, animated: true)
                }))
//                let myAlert = UIAlertController(title: "Holy Reads", message:"Please buy a plan", preferredStyle: UIAlertController.Style.alert);
//                let okAction = UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler:nil)
//
//                let sayhi = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler:  { action in
//                    let obj = self.storyboard?.instantiateViewController(withIdentifier: "MembershipPlanVCNewIPAD") as! MembershipPlanVCNewIPAD
//                    self.navigationController?.pushViewController(obj, animated: true)
//
//                })
//                myAlert.addAction(okAction);
//                myAlert.addAction(sayhi);
                
                self.present(myAlert, animated: true, completion: nil)
            }
        }
        
//        if  dictBookDetails["kindle_status"] as? Int == 1 {
//            self.UploadBookToKindle()
//        } else {
//            let obj = self.storyboard?.instantiateViewController(withIdentifier: "Kindle_IpadVC") as! Kindle_IpadVC
//            self.navigationController?.pushViewController(obj, animated: true)
//        }
    }
    
    @IBAction func btnFavourite_DidSelect(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.markBookFavourite()
        if sender.isSelected {
            print("True")
        } else{
            print("False")
        }
    }
    
    @IBAction func btnRead_DidSelect(_ sender: UIButton) {
        let freests = UserDefaults.standard.value(forKey: "FREESTS") as? String
        let substs = UserDefaults.standard.value(forKey: "SUBSTS") as? String
        
        if substs == "1" {
            let shwod = UserDefaults.standard.value(forKey: "videoSkipped") as? String
            if shwod == "FirstShow" {
                let defaults = UserDefaults.standard
                defaults.set("Read", forKey: "OpenPage")
                defaults.setValue("BookOutR", forKey: "PositionV")
                defaults.synchronize()
                let obj = self.storyboard?.instantiateViewController(withIdentifier: "AvViewController_IPad") as! AvViewController_IPad
                obj.dictBookDetails = self.dictBookDetails
                obj.bookName = bookName
                self.navigationController?.pushViewController(obj, animated: true)
            }else {
                let defaults = UserDefaults.standard
                defaults.set("Read", forKey: "OpenPage")
                defaults.setValue("BookOutR", forKey: "PositionV")
                defaults.synchronize()
                Config().deleteAllRecords(tbaleName: "FolioReaderdatabase")
                getHighlightBookListingApiCall()
                self.Test(BookName: bookName)
                
            }
        }else {
            if freests == "1" {
                let shwod = UserDefaults.standard.value(forKey: "videoSkipped") as? String
                if shwod == "FirstShow" {
                    let defaults = UserDefaults.standard
                    defaults.set("Read", forKey: "OpenPage")
                    defaults.setValue("BookOutR", forKey: "PositionV")
                    defaults.synchronize()
                    let date = Date()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd-MM-yyyy"
                  //  let formatter1 = DateFormatter()
                  //  formatter1.dateFormat = "dd-MM-yyyy"
                    let dateN = formatter.string(from: date)
                   // let dateNe = formatter1.string(from: date)
                   // let dateX = formatter1.date(from: dateNe)!
                    
                    let oldDate = UserDefaults.standard.value(forKey: "oldDate") as? String
                    if oldDate == nil {
                        print("Date not done")
                    }else{
                        if currentDate == oldDate {
                            print("Date Chnaged")
                        }else{
                            self.BookIdNewArray.removeAll()
                            UserDefaults.standard.removeObject(forKey: "BookIdAr")
                        }
                    }
                    let idarr =  UserDefaults.standard.array(forKey: "BookIdAr")  as? [Int]
                    if BookIdNewArray.contains(self.bookId) || idarr!.contains(self.bookId) {
                        let defaults = UserDefaults.standard
                        defaults.set("Read", forKey: "OpenPage")
                        defaults.setValue("BookOutR", forKey: "PositionV")
                        defaults.setValue(dateN, forKey: "oldDate")
                        defaults.synchronize()
                        Config().deleteAllRecords(tbaleName: "FolioReaderdatabase")
                        getHighlightBookListingApiCall()
                        let obj = self.storyboard?.instantiateViewController(withIdentifier: "AvViewController_IPad") as! AvViewController_IPad
                        obj.dictBookDetails = self.dictBookDetails
                        obj.bookName = bookName
                        self.navigationController?.pushViewController(obj, animated: true)
                    }else{
                        let obj = self.storyboard?.instantiateViewController(withIdentifier: "AvViewController_IPad") as! AvViewController_IPad
                        obj.dictBookDetails = self.dictBookDetails
                        obj.bookName = bookName
                        self.navigationController?.pushViewController(obj, animated: true)
                    }
                    
                }else {
//                    let date = Date()
//                    let formatter = DateFormatter()
//                    formatter.dateFormat = "dd-MM-yyyy hh:mm a"
//                    let dateN = formatter.string(from: date)
//                    let newdate = dateN + " " + "23:59 PM"
//                    if currentDate == newdate {
//                        increaseCount = 0
//                        self.getReadingBook()
//                    }else{
//                       // increaseCount += 1
//                        self.getReadingBook()
//                        let defaults1 = UserDefaults.standard
//                        defaults1.setValue(increaseCount, forKey: "Count")
//                        defaults1.synchronize()
//                    }
                    
                    let date = Date()
                    let formatter = DateFormatter()
                    formatter.dateFormat = "dd-MM-yyyy"
                  //  let formatter1 = DateFormatter()
                  //  formatter1.dateFormat = "dd-MM-yyyy"
                    let dateN = formatter.string(from: date)
                   // let dateNe = formatter1.string(from: date)
                   // let dateX = formatter1.date(from: dateNe)!
                    
                    let oldDate = UserDefaults.standard.value(forKey: "oldDate") as? String
                    if oldDate == nil {
                        print("Date not done")
                    }else{
                        if currentDate == oldDate {
                            print("Date Chnaged")
                        }else{
                            self.BookIdNewArray.removeAll()
                            UserDefaults.standard.removeObject(forKey: "BookIdAr")
                        }
                    }
                    let idarr =  UserDefaults.standard.array(forKey: "BookIdAr")  as? [Int]
                    if BookIdNewArray.contains(self.bookId) || idarr!.contains(self.bookId) {
                        let defaults = UserDefaults.standard
                        defaults.set("Read", forKey: "OpenPage")
                        defaults.setValue("BookOutR", forKey: "PositionV")
                        defaults.setValue(dateN, forKey: "oldDate")
                        defaults.synchronize()
                        Config().deleteAllRecords(tbaleName: "FolioReaderdatabase")
                        getHighlightBookListingApiCall()
                        self.Test(BookName: bookName)
                    }else{
                        let myAlert = PMAlertController(title: "Holy Reads", description: "You have reached your daily limit in trial mode. Please buy a plan to unlock unlimited access.", image: UIImage(named: "welcome_logo"), style: .alert)
                              myAlert.addAction(PMAlertAction(title: "OK", style: .default, action: { () in

                              }))
                            self.present(myAlert, animated: true, completion: nil)
                    }
                    
                   
//                    if increaseCount > 5 {
//                        let myAlert = PMAlertController(title: "Holy Reads", description: "You have reached your daily limit in trial mode. Please buy a plan to proceed..!!!", image: UIImage(named: "welcome_logo"), style: .alert)
//                              myAlert.addAction(PMAlertAction(title: "OK", style: .default, action: { () in
//
//                              }))
//                            self.present(myAlert, animated: true, completion: nil)
//                       // self.view.makeToast(message: "No Book Available.")
//                    }else {
//                        let defaults = UserDefaults.standard
//                        defaults.set("Read", forKey: "OpenPage")
//                        defaults.setValue("BookOutR", forKey: "PositionV")
//                        defaults.synchronize()
//                        Config().deleteAllRecords(tbaleName: "FolioReaderdatabase")
//                        getHighlightBookListingApiCall()
//                        self.Test(BookName: bookName)
//                    }
//
                    
                    
                }
            }else {
                let myAlert = PMAlertController(title: "Holy Reads", description: "Please purchase a plan.", image: UIImage(named: "welcome_logo"), style: .alert) //Image by freepik.com, taken on flaticon.com
                                
                myAlert.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () -> Void in
                    print("Cancel")
                }))
                
                myAlert.addAction(PMAlertAction(title: "Yes", style: .default, action: { () in
                    let obj = self.storyboard?.instantiateViewController(withIdentifier: "MembershipPlanVCNewIPAD") as! MembershipPlanVCNewIPAD
                    self.navigationController?.pushViewController(obj, animated: true)
                }))
//                let myAlert = UIAlertController(title: "Holy Reads", message:"Please buy a plan", preferredStyle: UIAlertController.Style.alert);
//                let okAction = UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler:nil)
//
//                let sayhi = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler:  { action in
//                    let obj = self.storyboard?.instantiateViewController(withIdentifier: "MembershipPlanVCNewIPAD") as! MembershipPlanVCNewIPAD
//                    self.navigationController?.pushViewController(obj, animated: true)
//
//                })
//                myAlert.addAction(okAction);
//                myAlert.addAction(sayhi);
                
                self.present(myAlert, animated: true, completion: nil)
            }
        }
        
//        let shwod = UserDefaults.standard.value(forKey: "videoSkipped") as? String
//        if shwod == "FirstShow" {
//            let defaults = UserDefaults.standard
//            defaults.set("Read", forKey: "OpenPage")
//            defaults.synchronize()
//            let obj = self.storyboard?.instantiateViewController(withIdentifier: "AvViewController_IPad") as! AvViewController_IPad
//            obj.dictBookDetails = self.dictBookDetails
//            obj.bookName = bookName
//            self.navigationController?.pushViewController(obj, animated: true)
//        }else {
//            let defaults = UserDefaults.standard
//            defaults.set("Read", forKey: "OpenPage")
//            defaults.synchronize()
//            self.Test(BookName: bookName)
//
//        }
        
//        let defaults = UserDefaults.standard
//        defaults.set("Read", forKey: "OpenPage")
//        defaults.synchronize()
//        self.Test(BookName: bookName)
        
        //        guard let epub = Epub(rawValue: 1) else {
        //            return
        //        }
        //        self.open(epub: epub)
        
    }
    
    func getReadingBook() {
        let parameterDictionary = NSMutableDictionary()
        let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        parameterDictionary.setValue(user_id, forKey: "user_id")
        let methodName = "getReadingBook"
        
        
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
            
            if status == "1" {
                if let response  = DataManager.getVal(responseData?["data"]) as? [[String:Any]] {
                    if response.count == 5 {
                        self.increaseCount = 5
                    }else if response.count == 0 {
                        self.increaseCount = 0
                    }else {
                        
                    }
                }
            }  else {
            }
        }
    }
    
    func getHighlightBookListingApiCall() {
        self.showHud()
        let parameterDictionary = NSMutableDictionary()
        let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        
        parameterDictionary.setValue(user_id, forKey: "user_id")
        parameterDictionary.setValue(bookId, forKey: "book_id")
        
        let methodName = "getHighlightListSecond"
        
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
            
            if status == "1" {
                if let response  = DataManager.getVal(responseData?["data"]) as? NSMutableArray {
                   // self.arrHighlightedMarkedBooks = response
                   
                    for i in 0..<response.count {
                        var dict = NSDictionary()
                        dict = response[i] as! NSDictionary
                        var app_id:String!
                        app_id = DataManager.getVal(dict.value(forKey: "app_id")) as? String
                        var type:String!
                        type = DataManager.getVal(dict.value(forKey: "android_highlight_type")) as? String
                        var book_id:String!
                        book_id = DataManager.getVal(dict.value(forKey: "book_id")) as? String
                        var page_number:String!
                        page_number = DataManager.getVal(dict.value(forKey: "page_number")) as? String
                        var selection:String!
                        selection = DataManager.getVal(dict.value(forKey: "selection")) as? String
                        var rangy:String!
                        rangy = DataManager.getVal(dict.value(forKey: "rangy")) as? String
                        var note:String!
                        note = DataManager.getVal(dict.value(forKey: "note")) as? String
                        var chapter_name:String!
                        chapter_name = DataManager.getVal(dict.value(forKey: "chapter_name")) as? String
                        self.saveItemInToModel(bookid: book_id, userid: user_id, appid: app_id, chaptername: chapter_name, pagenmuber: page_number, note: note, rangy: rangy, content: selection, type: type)
                        
                    }
                    print(response)
                    var ns = NSMutableArray()
                    ns = response
                    UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject: ns), forKey: "NEWDATA")
                }
                
            }else {
            }
            self.clearHud()
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
        var newEntity           =   NSManagedObject()
        newEntity            =   NSManagedObject(entity: entity,insertInto: managedContext)
        self.saveManagedObjectData(newEntity: newEntity,item: item)
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func saveManagedObjectData(newEntity: NSManagedObject, item: itemModel) {
        
        //first
        newEntity.setValue(item.app_id!, forKey: "app_id")
        newEntity.setValue(item.book_id!, forKey: "book_id")
        newEntity.setValue(item.user_id!, forKey: "user_id")
        newEntity.setValue(item.chapter_name, forKey: "chapter_name")
        newEntity.setValue(item.note!, forKey: "note")
        newEntity.setValue(item.rangy!, forKey: "rangy")
        newEntity.setValue(item.content!, forKey: "content")
        newEntity.setValue(item.page_number, forKey: "page_number")
        newEntity.setValue(item.type, forKey: "type")
       
    }
    
    
    @IBAction func btnListin_DidSelect(_ sender: UIButton) {
        let freests = UserDefaults.standard.value(forKey: "FREESTS") as? String
        let substs = UserDefaults.standard.value(forKey: "SUBSTS") as? String
        
        if substs == "1" {
            if DataManager.isConnectedToNetwork() {
                let obj = self.storyboard?.instantiateViewController(withIdentifier: "ListinMusic_IpadVC") as! ListinMusic_IpadVC
                obj.dictBookDetails = self.dictBookDetails
                self.navigationController?.pushViewController(obj, animated: true)
            } else {
                self.view.makeToast(message: "No Internet Connection.")
            }
        }else{
            if freests == "1" {
                if DataManager.isConnectedToNetwork() {
                    let obj = self.storyboard?.instantiateViewController(withIdentifier: "ListinMusic_IpadVC") as! ListinMusic_IpadVC
                    obj.dictBookDetails = self.dictBookDetails
                    self.navigationController?.pushViewController(obj, animated: true)
                } else {
                    self.view.makeToast(message: "No Internet Connection.")
                }
            }else {
                let myAlert = PMAlertController(title: "Holy Reads", description: "Please purchase a plan.", image: UIImage(named: "welcome_logo"), style: .alert) //Image by freepik.com, taken on flaticon.com
                                
                myAlert.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () -> Void in
                    print("Cancel")
                }))
                
                myAlert.addAction(PMAlertAction(title: "Yes", style: .default, action: { () in
                    let obj = self.storyboard?.instantiateViewController(withIdentifier: "MembershipPlanVCNewIPAD") as! MembershipPlanVCNewIPAD
                    self.navigationController?.pushViewController(obj, animated: true)
                }))
//                let myAlert = UIAlertController(title: "Holy Reads", message:"Please buy a plan", preferredStyle: UIAlertController.Style.alert);
//                let okAction = UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler:nil)
//
//                let sayhi = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler:  { action in
//                    let obj = self.storyboard?.instantiateViewController(withIdentifier: "MembershipPlanVCNewIPAD") as! MembershipPlanVCNewIPAD
//                    self.navigationController?.pushViewController(obj, animated: true)
//
//                })
//                myAlert.addAction(okAction);
//                myAlert.addAction(sayhi);
                
                self.present(myAlert, animated: true, completion: nil)
            }
        }
        
//        if let userSubscription = dictBookDetails["user_subscription_type"] as? Int{
//            if userSubscription == 1 {
//                self.view.makeToast(message: "Please Upgrade your plan to listen audio.")
//            }else if userSubscription == 2 {
//                if DataManager.isConnectedToNetwork() {
//                    let obj = self.storyboard?.instantiateViewController(withIdentifier: "ListinMusic_IpadVC") as! ListinMusic_IpadVC
//                    obj.dictBookDetails = self.dictBookDetails
//                    self.navigationController?.pushViewController(obj, animated: true)
//                } else {
//                    self.view.makeToast(message: "The Internet connection appears to be offline. ")
//                }
//            }else {
//                if DataManager.isConnectedToNetwork() {
//                    let obj = self.storyboard?.instantiateViewController(withIdentifier: "ListinMusic_IpadVC") as! ListinMusic_IpadVC
//                    obj.dictBookDetails = self.dictBookDetails
//                    self.navigationController?.pushViewController(obj, animated: true)
//                } else {
//                    self.view.makeToast(message: "The Internet connection appears to be offline. ")
//                }
//            }
//
//
//        }
        
        
    }
    @IBAction func btnWatch_DidSelect(_ sender: UIButton) {
        
        let freests = UserDefaults.standard.value(forKey: "FREESTS") as? String
        let substs = UserDefaults.standard.value(forKey: "SUBSTS") as? String
        
        if substs == "1" {
            let obj = self.storyboard?.instantiateViewController(withIdentifier: "WatchVideo_IpadVC") as! WatchVideo_IpadVC
            obj.dictBookDetails = self.dictBookDetails
            self.navigationController?.pushViewController(obj, animated: true)
        }else {
            if freests == "1" {
                let obj = self.storyboard?.instantiateViewController(withIdentifier: "WatchVideo_IpadVC") as! WatchVideo_IpadVC
                obj.dictBookDetails = self.dictBookDetails
                self.navigationController?.pushViewController(obj, animated: true)
            }else {
                let myAlert = PMAlertController(title: "Holy Reads", description: "Please purchase a plan.", image: UIImage(named: "welcome_logo"), style: .alert) //Image by freepik.com, taken on flaticon.com
                                
                myAlert.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () -> Void in
                    print("Cancel")
                }))
                
                myAlert.addAction(PMAlertAction(title: "Yes", style: .default, action: { () in
                    let obj = self.storyboard?.instantiateViewController(withIdentifier: "MembershipPlanVCNewIPAD") as! MembershipPlanVCNewIPAD
                    self.navigationController?.pushViewController(obj, animated: true)
                }))
//                let myAlert = UIAlertController(title: "Holy Reads", message:"Please buy a plan", preferredStyle: UIAlertController.Style.alert);
//                let okAction = UIAlertAction(title: "No", style: UIAlertAction.Style.cancel, handler:nil)
//
//                let sayhi = UIAlertAction(title: "Yes", style: UIAlertAction.Style.default, handler:  { action in
//                    let obj = self.storyboard?.instantiateViewController(withIdentifier: "MembershipPlanVCNewIPAD") as! MembershipPlanVCNewIPAD
//                    self.navigationController?.pushViewController(obj, animated: true)
//
//                })
//                myAlert.addAction(okAction);
//                myAlert.addAction(sayhi);
                
                self.present(myAlert, animated: true, completion: nil)
            }
        }
//        if let userSubscription = dictBookDetails["user_subscription_type"] as? Int{
//            if userSubscription == 1 {
//                self.view.makeToast(message: "Please Upgrade your plan to watch video.")
//            } else if userSubscription == 2 {
//                self.view.makeToast(message: "Please Upgrade your planwatch video.")
//            }
//            else{
//                let obj = self.storyboard?.instantiateViewController(withIdentifier: "WatchVideo_IpadVC") as! WatchVideo_IpadVC
//                obj.dictBookDetails = self.dictBookDetails
//                self.navigationController?.pushViewController(obj, animated: true)
//            }
//        }
        
    }
    
    // MARK: - UITableView Delegate
    
    //    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //        return 3
    //    }
    //
    //    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    //        let cell = tableView.dequeueReusableCell(withIdentifier: "IntroductionCell", for: indexPath) as! IntroductionCell
    //        if indexPath.row == 0 {
    //            //               cell.lblTitle.text = "The short description of the book"
    //            //                  if let description =  dictBookDetails["description"] as? String {
    //            //                   let strOne =  description.replacingOccurrences(of: "<p>", with: "")
    //            //                   let strTwo = strOne.replacingOccurrences(of: "</p>", with: "\n")
    //            //                    cell.lblDescription.text = strTwo
    //            //                  }
    //            //              } else if indexPath.row == 1 {
    //            //                cell.lblTitle.text = "Who is this book for"
    //            //                  if let description =  dictBookDetails["who_is_this_for"] as? String {
    //            //                    let strOne =  description.replacingOccurrences(of: "<p>", with: "")
    //            //                    let strTwo = strOne.replacingOccurrences(of: "</p>", with: "\n")
    //            //                             cell.lblDescription.text = strTwo
    //            //                  }
    //            //              } else if indexPath.row == 2 {
    //            //               cell.lblTitle.text = "About the author"
    //            //                  if let description =  dictBookDetails["about_the_author"] as? String {
    //            //                    let strOne =  description.replacingOccurrences(of: "<p>", with: "")
    //            //                    let strTwo = strOne.replacingOccurrences(of: "</p>", with: "\n")
    //            //                    cell.lblDescription.text = strTwo
    //            //                  }
    //        }
    //
    //        return cell
    //    }
    //
    //    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    //
    //
    //    }
    
    //MARK:- Get Book Detail Api Calling
    
    func getBookDetail() {
        self.showHud()
        let parameterDictionary = NSMutableDictionary()
        let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        parameterDictionary.setValue(user_id, forKey: "user_id")
        parameterDictionary.setValue(bookId, forKey: "book_id")
        let methodName = "getBookDetail"
        
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
            
            if status == "1" {
                if let response = DataManager.getVal(responseData?["data"]) as? [String: Any]{
                    self.dictBookDetails = response
                    self.setBookDetails()
                    //self.tblDiscoverDetails.reloadData()
                    //var HeightOne = CGFloat()
                    //var HeightTwo = CGFloat()
                    //var HeightThree = CGFloat()
                    //var sum = CGFloat()
                    //
                    //                    if let description =  self.dictBookDetails["description"] as? String {
                    //                        let indexPath = IndexPath(row: 0, section: 0)
                    //                        let cell = self.tblDiscoverDetails.cellForRow(at: indexPath) as! IntroductionCell
                    //                        let strOne =  description.replacingOccurrences(of: "<p>", with: "")
                    //                        let strTwo = strOne.replacingOccurrences(of: "</p>", with: "\n")
                    //                        cell.lblDescription.text = strTwo
                    //                        cell.lblTitle.text = "The short description of the book"
                    //                        HeightOne = cell.lblDescription.requiredHeight
                    //
                    //                    }
                    //                    if let description =  self.dictBookDetails["who_is_this_for"] as? String {
                    //                        let indexPath = IndexPath(row: 1, section: 0)
                    //                        let cell = self.tblDiscoverDetails.cellForRow(at: indexPath) as! IntroductionCell
                    //                        let strOne =  description.replacingOccurrences(of: "<p>", with: "")
                    //                        let strTwo = strOne.replacingOccurrences(of: "</p>", with: "\n")
                    //                        cell.lblDescription.text = strTwo
                    //                        cell.lblTitle.text = "Who is this book for"
                    //                        HeightTwo = cell.lblDescription.requiredHeight
                    //
                    //                    }
                    //                    if let description =  self.dictBookDetails["about_the_author"] as? String {
                    //                        let indexPath = IndexPath(row: 1, section: 0)
                    //                        let cell = self.tblDiscoverDetails.cellForRow(at: indexPath) as! IntroductionCell
                    //                        let strOne =  description.replacingOccurrences(of: "<p>", with: "")
                    //                        let strTwo = strOne.replacingOccurrences(of: "</p>", with: "\n")
                    //                        cell.lblDescription.text = strTwo
                    //                        cell.lblTitle.text = "About the author"
                    //                        HeightThree = cell.lblDescription.requiredHeight
                    //                    }
                    //                    if let overview =  self.dictBookDetails["overview"] as? String {
                    //                        var height = CGFloat()
                    //                        self.lblOverView.text = overview
                    //                        height = self.lblOverView.requiredHeight + 5
                    //                        self.lblOverViewHeightConstraint.constant = height
                    //
                    //                    }
                    //
                    //                    sum = HeightOne + HeightTwo + HeightThree
                    //                    let totalSum = sum + 50
                    //                    self.tblHeightConstraint.constant = totalSum
                    //                    self.tblDiscoverDetails.reloadData()
                }} else{
                self.view.makeToast(message: message)
            }
            self.clearHud()
        }
    }
    
    func setBookDetails() {
        if let title =  dictBookDetails["book_title"] as? String{
            self.lblBookTitle.text = title
            let bookTitle =  title.replacingOccurrences(of: " ", with: "")
            //let bookTitle = title.trimmingCharacters(in: .whitespaces)
            self.bookName = bookTitle
        }
        if let author = dictBookDetails["author"] as? String {
            self.lblAuthorNAme.text = author
            let defaults = UserDefaults.standard
            defaults.setValue(author, forKey: "NameAuth")
            defaults.synchronize()
        }
        if let epubUrl =  dictBookDetails["pdf"] as? String{
            //self.showHud()
            self.DownloadBook(bookName: bookName, boookUrl: epubUrl)
        }
        
        if let bookThumbnail =  dictBookDetails["cover_image"] as? String {
            self.imgBook.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.imgBook.startAnimating()
            let url = URL.init(string: bookThumbnail)
            self.imgBook.sd_setImage(with: url, placeholderImage: UIImage.init(named: ""), options: .refreshCached, completed: { (img, error, cacheType, url) in
            })
            self.imgBookCover.sd_setImage(with: url, placeholderImage: UIImage.init(named: ""), options: .refreshCached, completed: { (img, error, cacheType, url) in
            })
            self.imgBook.stopAnimating()
        }
        
//        if let description =  dictBookDetails["overview"] as? String {
//            let strOne =  description.replacingOccurrences(of: "<p>", with: "")
//            let strTwo = strOne.replacingOccurrences(of: "</p>", with: "")
//            self.lblShortDescription.text = strTwo
//        }
        
        
        let description =  dictBookDetails["overview"] as? String
        self.lblShortDescription.attributedText = description?.htmlAttributed(family: "Verdana", size: 13, color: .darkGray)
//        let htmlData = NSString(string: description!).data(using: String.Encoding.utf8.rawValue)
//        let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
//        let attributedString = try! NSAttributedString(data: htmlData!,
//                                                       options: options,
//                                                       documentAttributes: nil)
//
//        let perfectcode = attributedString.string
//        self.lblShortDescription.text = perfectcode
        
        
//        if let description =  dictBookDetails["who_is_this_for"] as? String {
//            let strOne =  description.replacingOccurrences(of: "<p>", with: "")
//            let strTwo = strOne.replacingOccurrences(of: "</p>", with: "")
//            self.lblBookIsFor.text = strTwo
//        }
        
        
        if let description1 =  dictBookDetails["who_is_this_for"] as? String {
            // webView.loadHTMLString(description, baseURL: nil)
            
            if description1.contains("<ul>\r\n<li>") || description1.contains("<ul> <li>") {
               
                var trimmed:String!
                if description1.contains("\r\n") {
                     trimmed = description1.replacingOccurrences(of: "\r\n", with: "")
                }else {
                     trimmed = description1.replacingOccurrences(of: "\n", with: "")
                }
                let strOnN =  trimmed!.replacingOccurrences(of: "&rsquo;", with: "")
                let strOn =  strOnN.replacingOccurrences(of: "<p>", with: "")
                let strOne1 =  strOn.replacingOccurrences(of: "<ul>", with: "")
                let strOne2 =  strOne1.replacingOccurrences(of: "</ul>", with: "")
                let strOne =  strOne2.replacingOccurrences(of: "\n<li>", with: "")
              //  let strTwo =  strOne.replacingOccurrences(of: "</li>", with: "")
                let strTwo1 =  strOne.replacingOccurrences(of: "<li>", with: "")
                let strTwo2 = strTwo1.replacingOccurrences(of: "&rsquo;", with: "'")
                let trimmed2 = strTwo2.replacingOccurrences(of: "<ul><li>", with: "")
                let trimmed23 = trimmed2.replacingOccurrences(of: "<ul> <li>", with: "")
                let trimmed25 = trimmed23.replacingOccurrences(of: "</li>\n<li>", with: "")
                let trimmed27 = trimmed25.replacingOccurrences(of: "</li>\n</ul>", with: "")
                let trimmed26 = trimmed27.replacingOccurrences(of: "<ul>\n<li>", with: "")
                let trimmed1 = trimmed26.replacingOccurrences(of: "</li> <li>", with: "")
                let trimmed3 = trimmed1.replacingOccurrences(of: "</li><li>", with: "")
                let trimmed4 = trimmed3.replacingOccurrences(of: "</strong>", with: "")
                let trimmed5 = trimmed4.replacingOccurrences(of: "<strong>&nbsp;", with: " ")
                
                
                
               // let fullNameArr = trimmed5.components(separatedBy: ".")
                let fullNameArr = trimmed5.components(separatedBy: "</li>")
                var s = [String]()
                
                for i in 0..<fullNameArr.count-1 {
                    s.append(fullNameArr[i])
                }
                
                self.lblBookIsFor.attributedText = addBulletToString1(stringList: s, font: UIFont.systemFont(ofSize: 14), bullet: "●")
            }else {
                let strOne1 =  description1.replacingOccurrences(of: "<ul>", with: "")
                let strOne =  strOne1.replacingOccurrences(of: "\n<li>", with: "")
                let strTwo =  strOne.replacingOccurrences(of: "</li>", with: "")
                let htmlData1 = NSString(string: strTwo).data(using: String.Encoding.utf8.rawValue)
                let options1 = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
                let attributedString1 = try! NSAttributedString(data: htmlData1!,
                                                               options: options1,
                                                               documentAttributes: nil)
        
                let perfectcode1 = attributedString1.string
                self.lblBookIsFor.text = perfectcode1
            }
            
            
            
            
        }
//
//        let description1 =  dictBookDetails["who_is_this_for"] as? String
//        let strOne1 =  description1!.replacingOccurrences(of: "<ul>", with: "")
//        let strOne =  strOne1.replacingOccurrences(of: "\n<li>", with: "")
//        let strTwo =  strOne.replacingOccurrences(of: "</li>", with: "")
//        let htmlData1 = NSString(string: strTwo).data(using: String.Encoding.utf8.rawValue)
//        let options1 = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
//        let attributedString1 = try! NSAttributedString(data: htmlData1!,
//                                                       options: options1,
//                                                       documentAttributes: nil)
//
//        let perfectcode1 = attributedString1.string
//        self.lblBookIsFor.text = perfectcode1
        
//        if let description =  dictBookDetails["about_the_author"] as? String {
//            let strOne =  description.replacingOccurrences(of: "<p>", with: "")
//            let strTwo = strOne.replacingOccurrences(of: "</p>", with: "")
//            self.lblAboutAuthor.text = strTwo
//        }
        
        let description2 =  dictBookDetails["about_the_author"] as? String
        let htmlData2 = NSString(string: description2!).data(using: String.Encoding.utf8.rawValue)
        let options2 = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
        let attributedString2 = try! NSAttributedString(data: htmlData2!,
                                                       options: options2,
                                                       documentAttributes: nil)

        let perfectcode2 = attributedString2.string
        self.lblAboutAuthor.text = perfectcode2
        
        if let overview =  dictBookDetails["overview"] as? String {
            var height = CGFloat()
            let strOne =  overview.replacingOccurrences(of: "<p>", with: "")
            let strTwo = strOne.replacingOccurrences(of: "</p>", with: "")
            self.lblOverView.text = strTwo
            height = self.lblOverView.requiredHeight + 5
            //self.lblOverViewHeightConstraint.constant = height
            self.lblOverViewHeightConstraint.constant = 0
        }
        if let fav =  dictBookDetails["fav_status"] as? Int {
            if fav == 0 {
                self.btnBookFav.isSelected = false
            } else {
                self.btnBookFav.isSelected = true
            }
        }
        //        if let userSubscription = dictBookDetails["user_subscription_type"] as? Int{
        //            if userSubscription == 1 {
        //                self.btnRead.isEnabled = true
        //                self.btnListin.isEnabled = false
        //                self.btnWatch.isEnabled = false
        //            } else if userSubscription == 2 {
        //                self.btnRead.isEnabled = true
        //                self.btnListin.isEnabled = true
        //                self.btnWatch.isEnabled = false
        //            }
        //            else if userSubscription == 3 {
        //                self.btnRead.isEnabled = true
        //                self.btnListin.isEnabled = true
        //                self.btnWatch.isEnabled = true
        //            }
        //        }
        
    }
    
    
    func saveAudioDocumentDirectory(arrAudioUrl : [String]) -> [String] {
        self.downloadtypeLbl.text = "Download Audio"
        progressbar.progress = 0.0
        progress.completedUnitCount = 0

        // 2
        Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { (timer) in
            guard self.progress.isFinished == false else {
                timer.invalidate()
                return
            }
            
            // 3
            self.progress.completedUnitCount += 1
            self.progressbar.setProgress(Float(self.progress.fractionCompleted), animated: true)

            self.startlbl.text = "\(Int(self.progress.fractionCompleted * 100))%"
            self.endLbl.text = "\(Int(self.progress.fractionCompleted * 100))/100"
        }

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
                        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                            if i == arrAudioUrl.count-1 {
                                self.clearHud()
                            }
                            self.downloadtype = "audio"
                            self.sendDownloadNotification(bookName: bookName)
                            self.view.makeToast(message: "Downloaded Successfully")
                            self.progressView.removeFromSuperview()
                            self.clearHud()
                            if self.startlbl.text == "100%" {
                                    self.progressView.removeFromSuperview()
                                }else {
                               }
                           // self.rateApp()
                         }
                         print("File moved to documents folder")
                        // self.view.makeToast(message: "Downloaded Successfully")
                        
                    } catch let error as NSError {
                        if i == arrAudioUrl.count-1 {
                            DispatchQueue.main.async {
                                self.view.makeToast(message: "Audio Downloaded Successfully.")
                                self.progressView.removeFromSuperview()
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
    
    func saveVideoDocumentDirectory(strVideoUrl : String) -> String {
        self.downloadtypeLbl.text = "Download Video"
        progressbar.progress = 0.0
        progress.completedUnitCount = 0

        // 2
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { (timer) in
            guard self.progress.isFinished == false else {
                timer.invalidate()
                return
            }
            
            // 3
            self.progress.completedUnitCount += 1
            self.progressbar.setProgress(Float(self.progress.fractionCompleted), animated: true)

            self.startlbl.text = "\(Int(self.progress.fractionCompleted * 100))%"
            self.endLbl.text = "\(Int(self.progress.fractionCompleted * 100))/100"
        }

        let url = NSURL(string:strVideoUrl)!
        let req = NSMutableURLRequest(url:url as URL)
        let config = URLSessionConfiguration.default
        let task = self.session.downloadTask(with: req as URLRequest)
        self.task = task
        task.resume()
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
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                            self.downloadtype = "video"
                            self.sendDownloadNotification(bookName: bookName)
                            self.view.makeToast(message: "Downloaded Successfully")
                            self.progressView.removeFromSuperview()
                            self.clearHud()
                           // self.rateApp()
                        }
                        print("File moved to documents folder")
                    }else {
                        self.progressView.removeFromSuperview()
                        self.clearHud()
                    }
                     // self.view.makeToast(message: "Downloaded Successfully")
                    
                } catch let error as NSError {
                     print(error.localizedDescription)
                    if error.code == 516 {
                         DispatchQueue.main.async {
                        self.view.makeToast(message: "Video Downloaded Successfully.")
                            self.progressView.removeFromSuperview()
                        self.clearHud()
                        //self.rateApp()
                        }
                    }
                    self.progressView.removeFromSuperview()
                     self.clearHud()
                }
            }).resume()
        }
        return bookFilePath.absoluteString
      }
    
    func sendDownloadNotification(bookName: String) {
        let parameterDictionary = NSMutableDictionary()
        let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        parameterDictionary.setValue(user_id, forKey: "user_id")
        parameterDictionary.setValue(bookName, forKey: "book_name")
        parameterDictionary.setValue(downloadtype, forKey: "DownloadType")
        
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
    
    
    
    //MARK: - Add Favourite Book API
    
    func markBookFavourite() {
        self.showHud()
        let parameterDictionary = NSMutableDictionary()
        let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        parameterDictionary.setValue(user_id, forKey: "user_id")
        parameterDictionary.setValue(bookId, forKey: "book_id")
        let methodName = "addFav"
        
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
            if status == "1" {
                
            } else{
                self.view.makeToast(message: message)
            }
            self.clearHud()
        }
    }
    
    //MARK: - Reading Book Book API
    
    @objc func ReadingBookNotification(_ notification:Notification) {
        self.ReadingBookApi()
    }
    
    func ReadingBookApi() {
        let parameterDictionary = NSMutableDictionary()
        let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        parameterDictionary.setValue(user_id, forKey: "user_id")
        parameterDictionary.setValue(bookId, forKey: "book_id")
        let methodName = "readingNow"
        
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
            if status == "1" {
                
            } else{
                print(message)
            }
        }
    }
    
    func UploadBookToKindle() {
        self.showHud()
        let parameterDictionary = NSMutableDictionary()
        let userId = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        parameterDictionary.setValue(userId, forKey: "user_id")
        parameterDictionary.setValue(bookId, forKey: "book_id")
        let methodName = "sendKindleEmail"
        
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
            if status == "1" {
                self.view.makeToast(message: message)
            }else{
                self.view.makeToast(message: message)
            }
            self.clearHud()
        }
    }
    
    
    
    
    //MARK: - Completed Book API
    
    //    @objc func CompletedBookNotification(_ notification:Notification) {
    //        self.CompletedBook()
    //    }
    //    func CompletedBook(){
    //        let parameterDictionary = NSMutableDictionary()
    //        let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
    //        parameterDictionary.setValue(user_id, forKey: "user_id")
    //        parameterDictionary.setValue(bookId, forKey: "book_id")
    //        let methodName = "completedReading"
    //
    //        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
    //            let status  = DataManager.getVal(responseData?["status"]) as! String
    //            let completedStatus  = DataManager.getVal(responseData?["completed_status"]) as! String
    //            let message  = DataManager.getVal(responseData?["message"]) as! String
    //            if status == "1" {
    //
    //            } else{
    //                print(message)
    //            }
    //        }
    //    }
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
    
    open func presentReader(parentViewController: UIViewController, withEpubPath epubPath: String, unzipPath: String? = nil, andConfig config: FolioReaderConfig, shouldRemoveEpub: Bool = true, animated:
        Bool = true) {
        let readerContainer = FolioReaderContainer(withConfig: config, folioReader: self, epubPath: epubPath, unzipPath: unzipPath, removeEpub: shouldRemoveEpub)
        self.readerContainer = readerContainer
        parentViewController.present(readerContainer, animated: animated, completion: nil)
    }
}

//MARK: HHFloatingViewDatasource
extension DiscoverDetail_IpadVC: HHFloatingViewDatasource {
    func floatingViewConfiguration(floatingView: HHFloatingView) -> HHFloatingViewConfiguration {
        let configure = HHFloatingViewConfiguration.init()
        configure.animationTimerDuration = 0.1
        configure.internalAnimationTimerDuration = 0.1
        configure.optionsDisplayDirection = .top
        configure.numberOfOptions = 3
        configure.handlerSize = CGSize.init(width: 50.0, height: 50.0)
        configure.optionsSize = CGSize.init(width: 40.0, height: 40.0)
        configure.initialMargin = 20.0
        configure.internalMargin = 10.0
        configure.handlerImage = #imageLiteral(resourceName: "download")
        configure.handlerColor = UIColor.clear
        configure.optionImages = [#imageLiteral(resourceName: "video"),#imageLiteral(resourceName: "audio"),#imageLiteral(resourceName: "book")]
        configure.optionColors = [UIColor.red.withAlphaComponent(0.5),
                                  UIColor.purple.withAlphaComponent(0.5),
                                  UIColor.blue.withAlphaComponent(0.5)]
        configure.isDraggable = true
        return configure
    }
}

//MARK: HHFloatingViewDelegate
extension DiscoverDetail_IpadVC: HHFloatingViewDelegate {
    func floatingView(floatingView: HHFloatingView, didSelectOption index: Int) {
        print("HHFloatingView: Button Selected: \(index)")
        if index == 1 {
            if DataManager.isConnectedToNetwork() {
            let downloadwifiStatus = UserDefaults.standard.value(forKey: "DownloadUsingWifi") as? Bool ?? true
            if downloadwifiStatus == false {
                if self.checkWiFi() {
                   // self.view.makeToast(message: "Turn ON download using wifi from settings")
                } else {
//                    self.showHud()
                   // self.MbHud()
                    var dic = [String:Any]()
                    if let videoUrl =  self.dictBookDetails["video"] as? String {
                        let localUrl =   self.saveVideoDocumentDirectory(strVideoUrl: videoUrl)
                        print(localUrl)
                    }
                    if let id = self.dictBookDetails["book_id"] as? Int {
                        dic["book_id"] = Int64(id)
                    }
                    dic["book_title"] = self.dictBookDetails["book_title"] as? String
                    if let authorName = self.dictBookDetails["author"] as? String {
                        dic["author"] = authorName
                    }
                    if let descr = self.dictBookDetails["description"] as? String {
                        let trimmed2 = descr.replacingOccurrences(of: "<p>", with: "")
                        let trimmed = trimmed2.replacingOccurrences(of: "</p>", with: "")
                        dic["descript"] = trimmed
                    }
                    if let coverImage =  self.dictBookDetails["cover_image"] as? String {
                        let coverImageUrl = URL(string: coverImage)
                        let coverImageData = try! Data(contentsOf: coverImageUrl!)
                        dic["book_image"]  =  coverImageData
                    }
                    if let id = self.dictBookDetails["book_id"] as? Int {
                        dic["book_id"] = Int64(id)
                    }

                    dic["contains_Video"] = true
                    DownloadEnitity.shared.saveData(dict: dic)


                }
             }else {
//                self.showHud()
               // self.MbHud()
                var dic = [String:Any]()
                if let videoUrl =  self.dictBookDetails["video"] as? String {
                    let localUrl =   self.saveVideoDocumentDirectory(strVideoUrl: videoUrl)
                    print(localUrl)
                }
                if let id = self.dictBookDetails["book_id"] as? Int {
                    dic["book_id"] = Int64(id)
                }
                dic["book_title"] = self.dictBookDetails["book_title"] as? String
                if let authorName = self.dictBookDetails["author"] as? String {
                    dic["author"] = authorName
                }
                if let descr = self.dictBookDetails["description"] as? String {
                    let trimmed2 = descr.replacingOccurrences(of: "<p>", with: "")
                    let trimmed = trimmed2.replacingOccurrences(of: "</p>", with: "")
                    dic["descript"] = trimmed
                }
                if let coverImage =  self.dictBookDetails["cover_image"] as? String {
                    let coverImageUrl = URL(string: coverImage)
                    let coverImageData = try! Data(contentsOf: coverImageUrl!)
                    dic["book_image"]  =  coverImageData
                }
                if let id = self.dictBookDetails["book_id"] as? Int {
                    dic["book_id"] = Int64(id)
                }
                dic["contains_Video"] = true
                DownloadEnitity.shared.saveData(dict: dic)

             }
            } else {
                self.view.makeToast(message: "Make sure your device is connected to the internet.")
            }

        }else if index == 2 {
            if DataManager.isConnectedToNetwork(){
                let downloadwifiStatus = UserDefaults.standard.value(forKey: "DownloadUsingWifi") as? Bool ?? true
                if downloadwifiStatus == false {
                    if self.checkWiFi() {
                      //  self.view.makeToast(message: "Turn ON download using wifi from settings")
                    } else {
                        self.showHud()
                        var dic = [String:Any]()
                        var arrchapterUrl = [String]()
                        var arrchapterUrl1 = [String]()
                        if let arrAudio = self.dictBookDetails["audio"] as? [[String:Any]] {
                            arrAudio.filter { (val) -> Bool in
                                if let Url = val["audio"] as? String{
                                    let chapterUrl = Url
                                    arrchapterUrl.append(chapterUrl)
                                }
                                return true
                            }
                            print(arrchapterUrl)
                            self.arrMusic.append(contentsOf: arrchapterUrl)
                            if self.arrMusic.count != 0 {
                            }
                            let LocalUrl = self.saveAudioDocumentDirectory(arrAudioUrl: arrchapterUrl)
                            dic["arr_Audio"] = LocalUrl
//
                            print(LocalUrl)
                        }
                        
                        if let chapter_name = self.dictBookDetails["chapter_name"] as? [[String:Any]] {
                            chapter_name.filter { (val) -> Bool in
                                if let Url = val["chapter_name"] as? String{
                                    let chapterUrl = Url
                                    arrchapterUrl1.append(chapterUrl)
                                }
                                return true
                            }
                            print(arrchapterUrl1)
//                            self.arrMusic.append(contentsOf: arrchapterUrl)
//                            if self.arrMusic.count != 0 {
//                            }
                            let defaults = UserDefaults.standard
                            defaults.set(arrchapterUrl1, forKey: "ChapterArray")
                            defaults.synchronize()
                            let LocalUrl1 = arrchapterUrl1
                            dic["chapter_name"] = LocalUrl1
                            print(LocalUrl1)
                        }
                        
                        
                        
                        if let id = self.dictBookDetails["book_id"] as? Int {
                            dic["book_id"] = Int64(id)
                        }
                        dic["book_title"] = self.dictBookDetails["book_title"] as? String
                        if let authorName = self.dictBookDetails["author"] as? String {
                            dic["author"] = authorName
                        }
                        if let descr = self.dictBookDetails["description"] as? String {
                            let trimmed2 = descr.replacingOccurrences(of: "<p>", with: "")
                            let trimmed = trimmed2.replacingOccurrences(of: "</p>", with: "")
                            dic["descript"] = trimmed
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
                    var arrchapterUrl1 = [String]()
                    if let arrAudio = self.dictBookDetails["audio"] as? [[String:Any]] {
                        arrAudio.filter { (val) -> Bool in
                            if let Url = val["audio"] as? String{
                                let chapterUrl = Url
                                arrchapterUrl.append(chapterUrl)
                            }
                            return true
                        }
                        print(arrchapterUrl)
                        self.arrMusic.append(contentsOf: arrchapterUrl)
                        if self.arrMusic.count != 0 {
                        }

                        let LocalUrl = self.saveAudioDocumentDirectory(arrAudioUrl: arrchapterUrl)
                        dic["arr_Audio"] = LocalUrl
                        
                        print(LocalUrl)
                    }
                    
                    if let chapter_name = self.dictBookDetails["audio"] as? [[String:Any]] {
                        chapter_name.filter { (val) -> Bool in
                            if let Url = val["chapter_name"] as? String{
                                let chapterUrl = Url
                                arrchapterUrl1.append(chapterUrl)
                            }
                            return true
                        }
                        print(arrchapterUrl1)
                        //self.arrMusic.append(contentsOf: arrchapterUrl)
//                        if self.arrMusic.count != 0 {
//                        }
                        let defaults = UserDefaults.standard
                        defaults.set(arrchapterUrl1, forKey: "ChapterArray")
                        defaults.synchronize()
                        let LocalUrl1 = arrchapterUrl1
                        dic["chapter_name"] = LocalUrl1
                        print(LocalUrl1)
                    }
                    
                    if let id = self.dictBookDetails["book_id"] as? Int {
                        dic["book_id"] = Int64(id)
                    }
                    dic["book_title"] = self.dictBookDetails["book_title"] as? String
                    if let authorName = self.dictBookDetails["author"] as? String {
                        dic["author"] = authorName
                    }
                    
                    if let descr = self.dictBookDetails["description"] as? String {
                        let trimmed2 = descr.replacingOccurrences(of: "<p>", with: "")
                        let trimmed = trimmed2.replacingOccurrences(of: "</p>", with: "")
                        dic["descript"] = trimmed
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
        }else {
            let downloadwifiStatus = UserDefaults.standard.value(forKey: "DownloadUsingWifi") as? Bool ?? true
            if downloadwifiStatus == false {
                if checkWiFi() {
                   // self.view.makeToast(message: "Turn ON download using wifi from settings")
                } else {
                    var dictBookDetails = [String: Any]()
                    self.showHud()
                    let parameterDictionary = NSMutableDictionary()
                    let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
                    let bookId = DataManager.getVal(Config().AppUserDefaults.value(forKey: "book_id")) as! String
                    
                    parameterDictionary.setValue(user_id, forKey: "user_id")
                    parameterDictionary.setValue(bookId, forKey: "book_id")
                    let methodName = "getBookDetail"
                    
                    DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
                        let status  = DataManager.getVal(responseData?["status"]) as! String
                        let message  = DataManager.getVal(responseData?["message"]) as! String
                        
                        if status == "1" {
                            if let response = DataManager.getVal(responseData?["data"]) as? [String: Any]{
                                dictBookDetails = response
                                
                                var dic = [String:Any]()
                                if let id = dictBookDetails["book_id"] as? Int {
                                    dic["book_id"] = Int64(id)
                                }
                                dic["book_title"] = dictBookDetails["book_title"] as? String
                                if let authorName = dictBookDetails["author"] as? String {
                                    dic["author"] = authorName
                                }
                                
                                if let descr = dictBookDetails["description"] as? String {
                                    let trimmed2 = descr.replacingOccurrences(of: "<p>", with: "")
                                    let trimmed = trimmed2.replacingOccurrences(of: "</p>", with: "")
                                    dic["descript"] = trimmed
                                }
                                let data = NSKeyedArchiver.archivedData(withRootObject: self.localhighArray)
                                dic["arr_highlight"] = data
                                
                                
                                if let coverImage =  dictBookDetails["cover_image"] as? String {
                                    let coverImageUrl = URL(string: coverImage)
                                    let coverImageData = try! Data(contentsOf: coverImageUrl!)
                                    dic["book_image"]  =  coverImageData
                                }
                                if let id = dictBookDetails["book_id"] as? Int {
                                    dic["book_id"] = Int64(id)
                                }
                                dic["contains_Book"] = true
                                DownloadEnitity.shared.saveData(dict: dic)
                                self.downloadtype = "summary"
                                self.sendDownloadNotification(bookName: dic["book_title"] as? String ?? "")
                                Config().deleteAllRecords(tbaleName: "FolioReaderdatabase")
                                self.getHighlightBookListingApiCall()
                            }
                            self.view.makeToast(message: "Downloaded Successfully")
                            //self.rateApp()
                        }else {
                            print("Book not saved sucessfully")
                        }
                        self.clearHud()
                    }
                }} else {
                var dictBookDetails = [String: Any]()
                self.showHud()
                let parameterDictionary = NSMutableDictionary()
                let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
                let bookId = DataManager.getVal(Config().AppUserDefaults.value(forKey: "book_id")) as! String
                
                parameterDictionary.setValue(user_id, forKey: "user_id")
                parameterDictionary.setValue(bookId, forKey: "book_id")
                let methodName = "getBookDetail"
                
                DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
                    let status  = DataManager.getVal(responseData?["status"]) as! String
                    let message  = DataManager.getVal(responseData?["message"]) as! String
                    
                    if status == "1" {
                        if let response = DataManager.getVal(responseData?["data"]) as? [String: Any]{
                            dictBookDetails = response
                            
                            var dic = [String:Any]()
                            if let id = dictBookDetails["book_id"] as? Int {
                                dic["book_id"] = Int64(id)
                            }
                            dic["book_title"] = dictBookDetails["book_title"] as? String
                            if let authorName = dictBookDetails["author"] as? String {
                                dic["author"] = authorName
                            }
                            
                            if let descr = dictBookDetails["description"] as? String {
                                let trimmed2 = descr.replacingOccurrences(of: "<p>", with: "")
                                let trimmed = trimmed2.replacingOccurrences(of: "</p>", with: "")
                                dic["descript"] = trimmed
                            }
                            
                            let data = NSKeyedArchiver.archivedData(withRootObject: self.localhighArray)
                            dic["arr_highlight"] = data
                            
                            if let coverImage =  dictBookDetails["cover_image"] as? String {
                                let coverImageUrl = URL(string: coverImage)
                                let coverImageData = try! Data(contentsOf: coverImageUrl!)
                                dic["book_image"]  =  coverImageData
                            }
                            if let id = dictBookDetails["book_id"] as? Int {
                                dic["book_id"] = Int64(id)
                            }
                            dic["contains_Book"] = true
                            DownloadEnitity.shared.saveData(dict: dic)
                            self.downloadtype = "summary"
                            self.sendDownloadNotification(bookName: dic["book_title"] as? String ?? "")
                            Config().deleteAllRecords(tbaleName: "FolioReaderdatabase")
                            self.getHighlightBookListingApiCall()

                        }
                        self.view.makeToast(message: "Downloaded Successfully")
                        //self.rateApp()
                    }else {
                        print("Book not saved sucessfully")
                    }
                    self.clearHud()
                }
            }
        }
        floatingView.close()
    }
}
