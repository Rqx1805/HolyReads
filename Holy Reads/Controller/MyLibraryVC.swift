//
//  MyLibraryVC.swift
//  Holy Reads
//
//  Created by mac-14 on 31/08/19.
//  Copyright © 2019 Ajeet singh Rawat. All rights reserved.
//

import UIKit
import SDWebImage
import CoreData
enum MyLibraryType : String {
    case Completed
    case Reading
    case MyFavourites
}

class MyLibraryVC: UIViewController, UITextFieldDelegate {
    
    // MARK: - IBOutlet
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var LibariryTypeCollectionView: UICollectionView!
    @IBOutlet weak var LibariryCollectionView: UICollectionView!
    @IBOutlet weak var tblMyNotesHighlights: UITableView!
    @IBOutlet weak var txtSearch: UITextField!
    
    // MARK: - Variable
    var arrTypes = [String]()
    var arrCompletedBooks = [[String:Any]]()
    var arrReadingBooks = [[String:Any]]()
    var arrFavMarkedBooks = [[String:Any]]()
    var arrHighlightedMarkedBooks = [[String:Any]]()
    let refreshController = UIRefreshControl()
    let tableRefreshController = UIRefreshControl()
    
    fileprivate var selectedCell: Int = 0
    var Liked = Bool()
    var bookId = Int()
    var LibraryApiType = MyLibraryType.Completed
    let config =  FolioReaderConfig()
    
   // var imgarr = ["Completed","Reading Now 2","My favourite 2","Notes& Heighlights 2"]
     var imgarr = ["Reading Now","Notes& Heighlights 2","My favourite 2","Completed 2"]
    // MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        self.refreshController.addTarget(self, action: #selector(RefreshPage), for: .valueChanged)
        self.tableRefreshController.addTarget(self, action: #selector(RefreshTablePage), for: .valueChanged)
         
        self.LibariryCollectionView.addSubview(refreshController)
        self.tblMyNotesHighlights.addSubview(tableRefreshController)
        
        tblMyNotesHighlights.rowHeight = UITableView.automaticDimension
        tblMyNotesHighlights.estimatedRowHeight = 35
        
        let LibariryTypeLayOut = UICollectionViewFlowLayout()
        LibariryTypeLayOut.itemSize = CGSize(width: screenWidth/4.1, height: 70)
        LibariryTypeLayOut.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        LibariryTypeLayOut.minimumInteritemSpacing = 0
        LibariryTypeLayOut.minimumLineSpacing = 2
        LibariryTypeLayOut.scrollDirection = .horizontal
        LibariryTypeCollectionView.isScrollEnabled = true
        LibariryTypeCollectionView.collectionViewLayout = LibariryTypeLayOut
        
        let LibariryLayOut = UICollectionViewFlowLayout()
        LibariryLayOut.itemSize = CGSize(width: screenWidth/2 - 20, height: 304)
        LibariryLayOut.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        LibariryLayOut.minimumInteritemSpacing = 0
        LibariryLayOut.minimumLineSpacing = 5
        LibariryLayOut.scrollDirection = .vertical
        
        LibariryCollectionView.collectionViewLayout = LibariryLayOut
        
       // arrTypes = ["COMPLETED","READING NOW","MY FAVORITES","MY NOTES AND HIGHLIGHTS"]
        arrTypes = ["READING NOW","NOTES & HIGHLIGHTS","MY FAVORITES","COMPLETED"]
    }
    override func viewWillAppear(_ animated: Bool) {
        print(selectedCell)
        if selectedCell == 0 {
            LibraryApiType = MyLibraryType.Reading
            self.LibariryCollectionView.isHidden = false
            self.tblMyNotesHighlights.isHidden = true
            self.getMarkBookFavourite()
        } else if selectedCell == 1 {
            self.LibariryCollectionView.isHidden = true
            self.tblMyNotesHighlights.isHidden = false
            self.getHighlightBookListingApiCall()
        }else if selectedCell == 2 {
            LibraryApiType = MyLibraryType.MyFavourites
            self.LibariryCollectionView.isHidden = false
            self.tblMyNotesHighlights.isHidden = true
            self.getMarkBookFavourite()
        } else {
            LibraryApiType = MyLibraryType.Completed
            self.LibariryCollectionView.isHidden = false
            self.tblMyNotesHighlights.isHidden = true
            self.getMarkBookFavourite()
        }
    }
    func fetchItemRecordFromDB(){
        let appDelegate =   (UIApplication.shared.delegate) as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let request     =   NSFetchRequest<NSManagedObject>(entityName:"FolioReaderdatabase")
        do{
            var resArr          =   [NSManagedObject]()
            resArr              =   try managedContext.fetch(request)
            print("PharmacyArr = ", resArr)
            print(resArr.count)
            for data in resArr {
                let content = data.value(forKey: "content") as? String
                let note = data.value(forKey: "note") as? String
                let pagenumber = data.value(forKey: "page_number") as? String
                let bookid = data.value(forKey: "book_id") as? String
                let userid = data.value(forKey: "user_id") as? String
                let rangy = data.value(forKey: "rangy") as? String
                let app_id = data.value(forKey: "app_id") as? String
                let typem = data.value(forKey: "type") as? String
                let chaptername = data.value(forKey: "chapter_name") as? String
                self.localdatasave(Content: content, Note: note, PageNumber: pagenumber, BookId: bookid, UserId: userid, Rangy: rangy, App_Id: app_id, Type: typem, ChapterName: chaptername)
            }
            
            UserDefaults.standard.removeObject(forKey: "OF")
            
        }catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func localdatasave(Content:String!,Note:String!,PageNumber:String!,BookId:String!,UserId:String!,Rangy:String!,App_Id:String!,Type:String!,ChapterName:String!) {
        let parameterDictionary = NSMutableDictionary()
        var highlighclass:String!
        if Type == "highlight_yellow" {
            highlighclass = "highlight_span_yellow"
        }else if Type == "highlight_green" {
            highlighclass = "highlight_span_lime"
        }else if Type == "highlight_blue" {
            highlighclass = "highlight_span_blue"
        }else if Type == "highlight_pink" {
            highlighclass = "highlight_span_pink"
        }else if Type == "highlight_underline" {
            highlighclass = "highlight_span_underline"
        }
        var NewPage:Int!
        NewPage = Int(PageNumber)
        parameterDictionary.setValue(DataManager.getVal(App_Id) as! String, forKey: "app_id")
        parameterDictionary.setValue(DataManager.getVal(UserId) as! String, forKey: "user_id")
        parameterDictionary.setValue(DataManager.getVal(NewPage) as! String, forKey: "page_number")
        parameterDictionary.setValue(DataManager.getVal(BookId) as! String, forKey: "book_id")
        parameterDictionary.setValue(DataManager.getVal(Note) as! String, forKey: "note")
        
        parameterDictionary.setValue(DataManager.getVal(Content) as! String, forKey: "selection")
        parameterDictionary.setValue(DataManager.getVal(ChapterName) as! String, forKey: "chapter_name")
        parameterDictionary.setValue(DataManager.getVal(highlighclass) as! String, forKey: "highlight_class")
        parameterDictionary.setValue(DataManager.getVal(Type) as! String, forKey: "android_highlight_type")
        parameterDictionary.setObject(Rangy!, forKey: "rangy" as NSCopying)
        parameterDictionary.setObject("3", forKey: "highlight_form" as NSCopying)
        print(parameterDictionary)
        let methodName = "saveHighlight"
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
        let status  = DataManager.getVal(responseData?["status"]) as! String
        let message  = DataManager.getVal(responseData?["message"]) as! String
        if status == "1" {
            self.saveHighlightNote(HighlightedId: App_Id, HighlightedText: Note)
            print("Successfully Saved the highlighted text.")
        }
        else{
            print("Error in saving the highlighted text.")
        }
    }
    }
    
    func saveHighlightNote(HighlightedId: String, HighlightedText: String) {
       self.view.endEditing(true)
       let parameterDictionary = NSMutableDictionary()
       parameterDictionary.setObject( HighlightedId, forKey: "app_id" as NSCopying)
       parameterDictionary.setObject( HighlightedText, forKey: "text" as NSCopying)
       print(parameterDictionary)
       let methodName = "saveHighlightNote"
       DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
           let status  = DataManager.getVal(responseData?["status"]) as! String
           let message  = DataManager.getVal(responseData?["message"]) as! String
           if status == "1" {
              //self.view.makeToast(message: message)
           } else{
              // self.view.makeToast(message: message)
           }
       }
       
   }
     //MARK: - IBAction
    
    @IBAction func btnSearch(_ sender: UIButton) {
        self.getSeachBook()
    }
    
    @objc func RefreshPage ()  {
        self.getMarkBookFavourite()
        
    }
    @objc func RefreshTablePage ()  {
        self.txtSearch.text = ""
        self.getHighlightBookListingApiCall()
    }
    
    //MARK: - UITextField Delegate
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.endEditing(true)
        if textField == txtSearch {
            self.getSeachBook()
        }else {
            self.getHighlightBookListingApiCall()
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        if textField == txtSearch {
            self.getSeachBook()
        }else {
            self.getHighlightBookListingApiCall()
        }
        return true
    }
    
    //MARK: - getMarkBookFavourite API Call
    
    func getMarkBookFavourite() {
       // self.showHud()
        self.showHud1()
        let parameterDictionary = NSMutableDictionary()
        let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        parameterDictionary.setValue(user_id, forKey: "user_id")
        var methodName = ""
        if LibraryApiType == MyLibraryType.Completed {
            methodName = "getCompletedBooks"
        } else if LibraryApiType == MyLibraryType.Reading {
            methodName = "getReadingBook"
        } else if LibraryApiType == MyLibraryType.MyFavourites {
            methodName = "getFav"
        }
        
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
            
            if status == "1" {
                if let response  = DataManager.getVal(responseData?["data"]) as? [[String:Any]] {
                    self.arrFavMarkedBooks = response
                    let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.LibariryCollectionView.frame.size.width, height: self.LibariryCollectionView.frame.size.height))
                    label.textColor = .black
                    label.textAlignment = .center
                    label.text = ""
                    self.LibariryCollectionView.backgroundView = label
                    if self.selectedCell == 3 {
                        self.LibariryCollectionView.isHidden = false
                        self.tblMyNotesHighlights.isHidden = true
                    }else  if self.selectedCell == 2 {
                        self.LibariryCollectionView.isHidden = false
                        self.tblMyNotesHighlights.isHidden = true
                    }else  if self.selectedCell == 1 {
                        self.LibariryCollectionView.isHidden = true
                        self.tblMyNotesHighlights.isHidden = false
                    }
                    else{
                        self.LibariryCollectionView.isHidden = false
                        self.tblMyNotesHighlights.isHidden = true
                    }
                    self.LibariryTypeCollectionView.reloadData()
                    self.LibariryCollectionView.reloadData()
                    self.refreshController.endRefreshing()
                }
                let newoff = UserDefaults.standard.value(forKey: "OF") as? String
                if newoff == "off" {
                    self.fetchItemRecordFromDB()
                }else {
                    print("Ashish")
                }
            }  else {
                self.arrFavMarkedBooks.removeAll()
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.LibariryCollectionView.frame.size.width, height: self.LibariryCollectionView.frame.size.height))
                label.textColor = .black
                label.textAlignment = .center
                if self.LibraryApiType == MyLibraryType.Completed {
                    label.text = "No completed summary found."
                } else if self.LibraryApiType == MyLibraryType.Reading {
                    label.text = "No reading summary found."
                } else if self.LibraryApiType == MyLibraryType.MyFavourites {
                    label.text = "No favorite summary found."
                }
                // view.addSubview(label)
                self.LibariryCollectionView.backgroundView = label
                self.LibariryCollectionView.reloadData()
                if self.selectedCell == 3 {
                    self.LibariryCollectionView.isHidden = false
                    self.tblMyNotesHighlights.isHidden = true
                }else  if self.selectedCell == 2 {
                    self.LibariryCollectionView.isHidden = false
                    self.tblMyNotesHighlights.isHidden = true
                }else  if self.selectedCell == 1 {
                    self.LibariryCollectionView.isHidden = true
                    self.tblMyNotesHighlights.isHidden = false
                }
                else{
                    self.LibariryCollectionView.isHidden = false
                    self.tblMyNotesHighlights.isHidden = true
                }
                self.refreshController.endRefreshing()
                
            }
            self.clearHud()
        }
    }
    
    @objc func markBookFav(_ sender: UIButton) {
        if let dic = arrFavMarkedBooks[sender.tag] as? [String:Any]{
            if let bookid =  dic["book_id"] as? Int{
                markBookFavouriteApiCall(bookId: bookid)
            }
        }
    }
    
    @objc func shareHighlight(_ sender: UIButton) {
        if let dic = arrHighlightedMarkedBooks[sender.tag] as? [String:Any]{
            if let hilightedText =  dic["selection"] as? String{
                let firstActivityItem = hilightedText
                 let activityViewController : UIActivityViewController = UIActivityViewController(
                    activityItems: [firstActivityItem], applicationActivities: nil)
                
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
    }
    
    @objc func deleteHighlight(_ sender: UIButton) {
        let normalAlert = UIAlertController(title: "Holy reads", message: "Are you sure you want to delete the highlight.", preferredStyle: .alert)
        normalAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if let dic = self.arrHighlightedMarkedBooks[sender.tag] as? [String:Any]{
                if let highlightedId =  dic["app_id"] as? String{
                    if let bookid = dic["book_id"] as? Int{
                        self.deleteHighlightApiCall(HighlightedId: highlightedId, BookID: bookid)
                        Highlight.removeById(withConfiguration: self.config, highlightId: highlightedId)
                     }
                 }
            }
        }))
        normalAlert.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: nil))
        
        self.present(normalAlert, animated: true, completion: nil)
    }
    
    @objc func showNotes(_ sender: UIButton) {
        let dic = arrHighlightedMarkedBooks[sender.tag]
        if let highlightedId =  dic["app_id"] as? String{
            if let bookid = dic["book_id"] as? Int{
                let obj = self.storyboard?.instantiateViewController(withIdentifier: "NotesVC") as! NotesVC
                obj.book_Id = bookid
                obj.higlightedId = highlightedId
                self.navigationController?.present(obj, animated: true, completion: nil)
            }
        }
    }
    //    func markHighlightBookAgain() {
    //        if let dic = arrHighlightedMarkedBooks[sender.tag] as? [String:Any]{
    //            if let highlightedId =  dic["app_id"] as? String{
    //                Highlight.updateById(withConfiguration: config, highlightId: highlightedId, type: .yellow)
    //             }
    //        }
    //    }
    
    
    
    //MARK: - Open E-Pub From Locally Saved File
    
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
            config.menuTextColor = UIColor.init(red: 85.0/255.0, green: 150.0/255.0, blue: 202.0/255.0, alpha: 1.0)
            config.menuTextColorSelected = UIColor.init(red: 85.0/255.0, green: 150.0/255.0, blue: 202.0/255.0, alpha: 1.0)
            config.quoteCustomLogoImage = UIImage.init(named: "headphones")
            config.shouldHideNavigationOnTap = false
            config.loadSavedPositionForCurrentBook = true
            config.hidePageIndicator = false
            
            let bookPath = Bundle.path(forResource: BookName, ofType: "epub", inDirectory: documentsPathString)
            let folioReaders = FolioReader()
            //folioReaders.readerCenter?.changePageWith(page: 10)
            //folioReaders.readerCenter?.changePageWith(page: <#T##Int#>, andFragment: <#T##String#>, animated: <#T##Bool#>, completion: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
            //folioReaders.readerCenter?.changePageWith(page: 2, andFragment: "9221F768-187A-EBF0-37F1-E01B99D84572")
            folioReaders.readerCenter?.changePageWith(page: 2, andFragment: "9221F768-187A-EBF0-37F1-E01B99D84572", animated: true, completion: {
                print("Yes")
            })
            ///working       //self.folioReader.readerContainer?.centerViewController?.changePageWith(page: 15)
            
            
            //self.folioReader.readerContainer?.centerViewController?.changePageWith(page: 15, andFragment: "898507D4-E735-6FB2-AE3E-F73AA4C0AB4B")
            //   folioReader.readerContainer?.centerViewController?.changePageWith(page: 19, andFragment: "0B2BF74A-944F-DAC4-0563-78C679497EF0")
            //folioReader.readerCenter?.changePageWith(page: 19, andFragment: "0B2BF74A-944F-DAC4-0563-78C679497EF0B")
            // self.readerContainer!.centerViewController?.changePageWith(page: 19, andFragment: "0B2BF74A-944F-DAC4-0563-78C679497EF0B")
            
            folioReaders.presentReader(parentViewController: self, withEpubPath: bookPath!, andConfig: config)
        }
    }
    
    // MARK: - API CALLING (Search Highlighted Book)
    func getSeachBook() {
       // self.showHud()
        self.showHud1()
        self.view.endEditing(true)
        let parameterDictionary = NSMutableDictionary()
        let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        parameterDictionary.setValue(txtSearch.text, forKey: "selection")
        parameterDictionary.setValue(user_id, forKey: "user_id")
        
        let methodName = "searchHighlight"
        
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message = DataManager.getVal(responseData?["message"]) as! String
            self.arrHighlightedMarkedBooks.removeAll()
            if status == "1" {
                let response = DataManager.getVal(responseData?["data"]) as! [[String: Any]]
                self.arrHighlightedMarkedBooks = response
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.tblMyNotesHighlights.frame.size.width, height: self.tblMyNotesHighlights.frame.size.height))
                label.textColor = .black
                label.textAlignment = .center
                label.text = ""
                self.tblMyNotesHighlights.backgroundView = label
                self.tblMyNotesHighlights.reloadData()
            } else {
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.tblMyNotesHighlights.frame.size.width, height: self.tblMyNotesHighlights.frame.size.height))
                label.textColor = .black
                label.textAlignment = .center
                label.text = "No Highlight book found."
                self.tblMyNotesHighlights.backgroundView = label
                self.tblMyNotesHighlights.reloadData()
               // self.view.makeToast(message: message)
            }
            self.clearHud()
        }
    }
    
    //MARK: - Mark Book Favourite API Call
    
    func markBookFavouriteApiCall(bookId :Int) {
        //self.showHud()
        self.showHud1()
        let parameterDictionary = NSMutableDictionary()
        let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        parameterDictionary.setValue(user_id, forKey: "user_id")
        parameterDictionary.setValue(bookId, forKey: "book_id")
        
        let methodName = "addFav"
        
        
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
            
            if status == "1" {
                self.getMarkBookFavourite()
                //self.view.makeToast(message: message)
            } else{
                self.view.makeToast(message: message)
            }
            self.clearHud()
        }
    }
    //MARK: - Get maked Highlight Book Listing API Call
    
    func getHighlightBookListingApiCall() {
      //  self.showHud()
        self.showHud1()
        let parameterDictionary = NSMutableDictionary()
        let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        parameterDictionary.setValue(user_id, forKey: "user_id")
        
        let methodName = "getHighlightListing"
        
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
            
            if status == "1" {
                if let response  = DataManager.getVal(responseData?["data"]) as? [[String:Any]] {
                    self.arrHighlightedMarkedBooks = response
                    let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.tblMyNotesHighlights.frame.size.width, height: self.tblMyNotesHighlights.frame.size.height))
                    label.textColor = .black
                    label.textAlignment = .center
                    label.text = ""
                    self.tblMyNotesHighlights.backgroundView = label
                    self.tblMyNotesHighlights.reloadData()
                    self.tableRefreshController.endRefreshing()
                    let newoff = UserDefaults.standard.value(forKey: "OF") as? String
                    if newoff == "off" {
                        self.fetchItemRecordFromDB()
                    }else {
                        print("Ashish")
                    }
                } }else {
                self.arrHighlightedMarkedBooks.removeAll()
                self.tblMyNotesHighlights.reloadData()
                
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.tblMyNotesHighlights.frame.size.width, height: self.tblMyNotesHighlights.frame.size.height))
                
                label.textColor = .black
                label.textAlignment = .center
                label.text = "No Highlight book found."
                self.tblMyNotesHighlights.backgroundView = label
                self.tableRefreshController.endRefreshing()
            }
            self.clearHud()
        }
    }
    
    
    func getHighlightDelete() {
        let parameterDictionary = NSMutableDictionary()
        let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        parameterDictionary.setValue(user_id, forKey: "user_id")
        
        let methodName = "deleteAllHighlightNote"
        
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
            
            if status == "1" {
                print("All Delete")
                let defaults = UserDefaults.standard
                defaults.setValue("OldNewEnter", forKey: "EnterFirst")
                defaults.synchronize()
                
                self.tblMyNotesHighlights.reloadData()
                
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.tblMyNotesHighlights.frame.size.width, height: self.tblMyNotesHighlights.frame.size.height))
                
                label.textColor = .black
                label.textAlignment = .center
                label.text = "No Highlight book found."
                self.tblMyNotesHighlights.backgroundView = label
                self.tableRefreshController.endRefreshing()
                
            }else {
                print("Something went worng.")
            }
        }
    }
    
    //MARK: - Delete maked highlight API Call
    
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
}



// MARK: - UICollectionViewDelegate
extension MyLibraryVC : UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == LibariryTypeCollectionView {
            return arrTypes.count
        } else{
            return arrFavMarkedBooks.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == LibariryTypeCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyLibraryCell", for: indexPath) as! MyLibraryCell
            cell.lblTy.text = arrTypes[indexPath.row]
            cell.tag = indexPath.row
         //   self.selectedCell = indexPath.row
            cell.ImageViewNew.image = UIImage(named: imgarr[indexPath.row])
//            if selectedCell == 0 {
//                if indexPath.row == 0 {
//                    imgarr = ["Completed","Reading Now 2","My favourite 2","Notes& Heighlights 2"]
//                    cell.ImageViewNew.image = UIImage(named: imgarr[indexPath.row])
//                    //cell.ImageViewNew.image = UIImage(named: "Completed")
//                }else {
//                    imgarr = ["Completed","Reading Now","My favourite","Notes& Heighlights"]
//                    cell.ImageViewNew.image = UIImage(named: imgarr[indexPath.row])
//                    cell.ImageViewNew.image = UIImage(named: "Completed 2")
//                }
//            }
//
//            if selectedCell == 1 {
//                if indexPath.row == 1 {
//                    cell.ImageViewNew.image = UIImage(named: "Reading Now")
//                }else {
//                    cell.ImageViewNew.image = UIImage(named: "Reading Now 2")
//                }
//            }
//
//            if selectedCell == 2 {
//                if indexPath.row == 2 {
//                    cell.ImageViewNew.image = UIImage(named: "My favourite")
//                }else {
//                    cell.ImageViewNew.image = UIImage(named: "My favourite 2")
//                }
//            }
//
//            if selectedCell == 3 {
//                if indexPath.row == 3 {
//                    cell.ImageViewNew.image = UIImage(named: "Notes& Heighlights")
//                }else {
//                    cell.ImageViewNew.image = UIImage(named: "Notes& Heighlights 2")
//                }
//            }
            if selectedCell == indexPath.row{
                cell.lblTy.textColor = #colorLiteral(red: 0.9960784314, green: 0.6, blue: 0.1450980392, alpha: 1)
            }else{
                cell.lblTy.textColor = #colorLiteral(red: 0.1644093692, green: 0.2676883936, blue: 0.3667172194, alpha: 1)
            }
            
           // cell.Sel_Btn.tag = indexPath.row
//            if selectedCell == indexPath.row {
//
//                // cell.Sel_Btn.setImage(UIImage(named: self.new1), for: .normal)
//               // cell.lblType.textColor = #colorLiteral(red: 0.9960784314, green: 0.6, blue: 0.1450980392, alpha: 1)
//              //  cell.viewLibraryType.layer.borderColor = #colorLiteral(red: 0.9960784314, green: 0.6, blue: 0.1450980392, alpha: 1)
//                //cell.shadowView.shadowColor = #colorLiteral(red: 0.9960784314, green: 0.6, blue: 0.1450980392, alpha: 1)
//            } else {
//
//                // cell.Sel_Btn.setBackgroundImage(UIImage(named: self.new1), for: .normal)
//               // cell.lblType.textColor = #colorLiteral(red: 0.1644093692, green: 0.2676883936, blue: 0.3667172194, alpha: 1)
//               // cell.viewLibraryType.layer.borderColor = #colorLiteral(red: 0.1644093692, green: 0.2676883936, blue: 0.3667172194, alpha: 1)
//               // cell.shadowView.shadowColor = UIColor(red: 55/255, green: 148/255, blue: 201/255, alpha: 1.0)
//            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteCell", for: indexPath) as! FavoriteCell
            cell.tag = indexPath.row
            if Liked == true{
                cell.btnLike.isHidden = false
            }else{
                cell.btnLike.isHidden = true
            }
            cell.layer.cornerRadius = 8
            let dict = arrFavMarkedBooks[indexPath.row] as [String:Any]
            if let title =  dict["book_title"] as? String{
                cell.lblBookTitle.text = title
            }
            if let bookThumbnail =  dict["cover_image"] as? String {
                cell.imgBook.sd_imageIndicator = SDWebImageActivityIndicator.gray
                cell.imgBook.startAnimating()
                let url = URL.init(string: bookThumbnail)
                cell.imgBook.sd_setImage(with: url, placeholderImage: UIImage.init(named: ""), options: .refreshCached, completed: { (img, error, cacheType, url) in
                })
                cell.imgBook.stopAnimating()
            }
            if let authorName =  dict["author"] as? String{
                cell.lblAuthorNAme.text = authorName
            }
            if let description =  dict["description"] as? String{
                let strOne =  description.replacingOccurrences(of: "<p>", with: "")
                let strTwo = strOne.replacingOccurrences(of: "</p>", with: "\n")
                cell.lblDescription.text = strTwo
            }
            cell.btnLike.tag = indexPath.row
            cell.btnLike.addTarget(self, action:#selector(markBookFav) , for: .touchUpInside)
            
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       // let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyLibraryCell", for: indexPath) as! MyLibraryCell
       //  cell.tag = indexPath.row
        if collectionView == LibariryTypeCollectionView {
            selectedCell = indexPath.row
            self.LibariryTypeCollectionView.reloadData()
            if indexPath.row == 0 {
                self.Liked = false
                self.tblMyNotesHighlights.isHidden = true
                self.viewSearch.isHidden = true
                self.LibariryCollectionView.isHidden = true
                self.LibraryApiType = MyLibraryType.Reading
                self.getMarkBookFavourite()
                self.arrFavMarkedBooks.removeAll()
                self.LibariryCollectionView.reloadData()
                imgarr =  ["Reading Now","Notes& Heighlights 2","My favourite 2","Completed 2"]
               // cell.ImageViewNew.image  = UIImage(named: "Completed 2")
                
            } else if indexPath.row == 1{
                self.Liked = false
                self.tblMyNotesHighlights.isHidden = false
                self.viewSearch.isHidden = false
                self.LibariryCollectionView.isHidden = true
                let notedata = UserDefaults.standard.value(forKey: "EnterFirst") as? String
                if notedata == "FirstNewEnter" {
                    //self.getHighlightDelete()
                    self.getHighlightBookListingApiCall()
                }else {
                    self.getHighlightBookListingApiCall()
                }
                self.LibariryCollectionView.reloadData()
                self.tblMyNotesHighlights.reloadData()
                
                 imgarr =  ["Reading Now 2","Notes& Heighlights","My favourite 2","Completed 2"]
               // cell.ImageViewNew.image  = UIImage(named: "Reading Now 2")
                
            } else if indexPath.row == 2{
                self.Liked = true
                self.tblMyNotesHighlights.isHidden = true
                self.viewSearch.isHidden = true
                self.LibariryCollectionView.isHidden = true
                self.LibraryApiType = MyLibraryType.MyFavourites
                self.getMarkBookFavourite()
                self.LibariryCollectionView.reloadData()
                 imgarr = ["Reading Now 2","Notes& Heighlights 2","My favourite","Completed 2"]
              //  cell.ImageViewNew.image  = UIImage(named: "My favourite 2")
            } else if indexPath.row == 3{
                self.Liked = false
                self.tblMyNotesHighlights.isHidden = true
                self.viewSearch.isHidden = true
                self.LibariryCollectionView.isHidden = true
                self.LibraryApiType = MyLibraryType.Completed
                self.getMarkBookFavourite()
                self.arrFavMarkedBooks.removeAll()
                self.LibariryCollectionView.reloadData()
                imgarr =  ["Reading Now 2","Notes& Heighlights 2","My favourite 2","Completed"]
              //  cell.ImageViewNew.image  = UIImage(named: "Notes& Heighlights 2")
            }
        } else {
            if let dict = DataManager.getVal(self.arrFavMarkedBooks[indexPath.row]) as? [String:Any]{
                if let bookId = dict["book_id"] as? Int{
                    let obj = self.storyboard?.instantiateViewController(withIdentifier: "DiscoverDetailsVC") as! DiscoverDetailsVC
                    obj.bookId = bookId
                    
                    self.navigationController?.pushViewController(obj, animated: false)
                }
            }
        }
    }
}

extension MyLibraryVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrHighlightedMarkedBooks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlanCell", for: indexPath) as! PlanCell
        if arrHighlightedMarkedBooks.count != 0 {
            let dict  = arrHighlightedMarkedBooks[indexPath.row]
            
            if let bookName = dict["book_title"] as? String{
                cell.lblBokName.text = bookName
            }
            
            let bookDes = dict["description"] as? String
            let htmlData2 = NSString(string: bookDes ?? "").data(using: String.Encoding.utf8.rawValue)
            let options2 = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
            let attributedString2 = try! NSAttributedString(data: htmlData2!,
                                                           options: options2,
                                                           documentAttributes: nil)

            let perfectcode2 = attributedString2.string
            cell.lblHighlight.text = perfectcode2
            
//            if let bookDes = dict["description"] as? String{
//                let strOne =  bookDes.replacingOccurrences(of: "<p>", with: "")
//                let strTwo = strOne.replacingOccurrences(of: "</p>", with: "\n")
//                cell.lblHighlight.text = strTwo
//            }
            
            if let bookName = dict["author"] as? String{
                cell.lblAuthorName.text = bookName
            }
            if let bookName = dict["selection"] as? String{
                cell.lblHighlight.text = bookName
            }
            if let bookThumbnail = dict["cover_image"] as? String {
                cell.imgBook.sd_imageIndicator = SDWebImageActivityIndicator.gray
                cell.imgBook.startAnimating()
                let url = URL.init(string: bookThumbnail)
                cell.imgBook.sd_setImage(with: url, placeholderImage: UIImage.init(named: ""), options: .refreshCached, completed: { (img, error, cacheType, url) in
                })
                cell.imgBook.stopAnimating()
            }
//            cell.btnShare.tag = indexPath.row
//            cell.btnDelete.tag = indexPath.row
//            cell.btnComment.tag = indexPath.row
//            cell.btnShare.addTarget(self, action: #selector(shareHighlight(_:)), for: .touchUpInside)
//            cell.btnDelete.addTarget(self, action: #selector(deleteHighlight(_:)), for: .touchUpInside)
//            cell.btnComment.addTarget(self, action: #selector(showNotes(_:)), for: .touchUpInside)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //Test(BookName: "HopeintheDark")
        // guard let highlight = arrHighlightedMarkedBooks[safe: indexPath.row] else { return }
        //self.folioReader.readerCenter?.changePageWith(page: 19, andFragment: "0B2BF74A-944F-DAC4-0563-78C679497EF0B")
        
        //self.folioReader.readerCenter?.changePageWith(page: highlight.page, andFragment: highlight.highlightId)
        if let dict = DataManager.getVal(self.arrHighlightedMarkedBooks[indexPath.row]) as? [String:Any]{
            if let bookId = dict["book_id"] as? Int {
                //self.Test(BookName: bookName)
                let obj = self.storyboard?.instantiateViewController(withIdentifier: "NotesHighlightsViewController") as! NotesHighlightsViewController
                //obj.bookId = bookId
                let defaults = UserDefaults.standard
                defaults.setValue(bookId, forKey: "book_id")
                defaults.synchronize()
                
                self.navigationController?.pushViewController(obj, animated: true)
            }
        }
    }
}

