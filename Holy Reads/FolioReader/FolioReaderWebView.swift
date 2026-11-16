//
//  FolioReaderWebView.swift
//  FolioReaderKit
//
//  Created by Hans Seiffert on 21.09.16.
//  Copyright (c) 2016 Folio Reader. All rights reserved.
//

import UIKit
import RealmSwift
import CoreData
import MenuItemKit
import WebKit
/// The custom WebView used in each page

open class FolioReaderWebView: UIWebView {
    var isColors = false
    var isShare = false
    var isOneWord = false
    var ishighlight = true
    var isspace = false
    var iscolorImage = true
    var colourvalue:Int!
    var higidl:String!
    var pageNumber:Int!
    var rangyArray = [String]()
    var contentArray = [String]()
    var appidArray = [String]()
    var arr_bookList : [NSManagedObject] = []
    var app_id:String!
    var content:String!
    var note:String!
    var bookid:String!
    var userid:String!
    var chaptername:String!
    var rangy:String!
    var pagenumber:String!
    var typem:String!
    var newrangy = String()
    var newapp_id:String!
    var newapp_id1:String!
    var oldrangy:String!
    var oldrangy1:String!
    var authorname:String!
    fileprivate var tocItems = [FRTocReference]()
    fileprivate weak var readerContainer: FolioReaderContainer?
    open fileprivate(set) var currentPage: FolioReaderPage?
    fileprivate var readerConfig: FolioReaderConfig {
        guard let readerContainer = readerContainer else { return FolioReaderConfig() }
       
        return readerContainer.readerConfig
    }

    fileprivate var book: FRBook {
        guard let readerContainer = readerContainer else { return FRBook() }
        return readerContainer.book
    }
    

    fileprivate var folioReader: FolioReader {
        guard let readerContainer = readerContainer else { return FolioReader() }
        return readerContainer.folioReader
    }

    override init(frame: CGRect) {
        fatalError("use init(frame:readerConfig:book:) instead.")
    }

    init(frame: CGRect, readerContainer: FolioReaderContainer) {
        self.readerContainer = readerContainer
        super.init(frame: frame)
       
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    


    // MARK: - UIMenuController
    
    open override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        
        guard readerConfig.useReaderMenuController else {
            return super.canPerformAction(action, withSender: sender)

        }
        
        
      //  print(action)
        if isShare {
            return false
        }else if isspace {
            return false
        }else if isColors {
            return false
        }else if isOneWord {
            if (action == #selector(define(_:)) && isOneWord)
            {
                return true
            }
            return false
        }
        else {
            if action == #selector(highlight(_:))
                || action == #selector(highlightWithNote(_:))
                || action == #selector(updateHighlightNote(_:))
                || (action == #selector(define(_:)) && isOneWord)
                || (action == #selector(play(_:)) && (book.hasAudio || readerConfig.enableTTS))
                || (action == #selector(share(_:)) && readerConfig.allowSharing)
               // || (action == #selector(copy(_:)) && readerConfig.allowSharing)
                 {
                return true
            }
            return false
          
            
        }

    }
    
    func JSONStringify(value: AnyObject,prettyPrinted:Bool = false) -> String{
            
            let options = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions(rawValue: 0)
            if JSONSerialization.isValidJSONObject(value) {
                do{
                    let data = try JSONSerialization.data(withJSONObject: value, options: options)
                    if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                        return string as String
                    }
                }catch {
                    print("error")
                }
            }
            return ""
        }
    
    func getHighlightBookListingApiCall(pagenumber:String!) {
        
        if DataManager.isConnectedToNetwork() {
            let parameterDictionary = NSMutableDictionary()
            let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
            let bookId = DataManager.getVal(Config().AppUserDefaults.value(forKey: "book_id")) as! String
            parameterDictionary.setValue(user_id, forKey: "user_id")
            parameterDictionary.setValue(bookId, forKey: "book_id")
            parameterDictionary.setValue(pagenumber, forKey: "page_number")
            
            let methodName = "getHighlightListByPageNumber"
            
            DataManager.getAPIResponseNwe(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
                let status  = DataManager.getVal(responseData?["status"]) as! String
                let message  = DataManager.getVal(responseData?["message"]) as! String
                
                if status == "1" {
                    if let response  = DataManager.getVal(responseData?["data"]) as? [[String: Any]] {
                      
                        
                        var rangy:String!
                        var content:String!
                        var appid:String!
                        
                        for i in 0..<response.count {
                            var dict = NSDictionary()
                            dict = response[i] as NSDictionary
                            rangy = dict.value(forKey: "rangy") as? String
                            content = dict.value(forKey: "selection") as? String
                            appid = dict.value(forKey: "app_id") as? String
                            self.rangyArray.append(rangy)
                           // self.contentArray.append(content)
                            self.appidArray.append(appid)
                        }
    //
                        print(self.rangyArray)
                       
                        self.fetchItemRecordFromDB()

                    
                        let  typeIdArrayString2 = self.JSONStringify(value: response as AnyObject)
                        print(typeIdArrayString2)
                        if response.count == 0 {
                            print("Ashish")
                        }else {
                            let vc = self.js("setHighlightByRangy('\(typeIdArrayString2)')")
                            print(vc ?? "")
                            let postionV = UserDefaults.standard.value(forKey: "PositionV") as? String
                            if postionV == "BookOut" {
                                let rangy = UserDefaults.standard.value(forKey: "rangeex") as? String
                                let position = self.js("goToHighlight('\(rangy ?? "")')")
                                print(position ?? "")
                            }else  if postionV == "BookIn" {
                                let rangy = UserDefaults.standard.value(forKey: "rangeex") as? String
                                let position = self.js("goToHighlight('\(rangy ?? "")')")
                                print(position ?? "")
                            }else {
                                print("Ashish")
                            }
                        }
                    }else {
                    
                    }
                    
                    Config().deleteAllRecords(tbaleName: "FolioReaderdatabase")
                    self.getHighlightBookListingApiCall()
                    
                }else {
                }
            }
        }else{
           //
           // self.fetchdatabyid111()
           // self.fetchdatabyidn()
           // let vc = UserDefaults.standard.value(forKey: "SAV") as? String
            //if vc == "save" {
               // self.fetchdatabyidnew1(pagenumber: pagenumber)
           // }else{
                self.fetchItemRecordFromDB()
               // self.fetchdatabyidnew1(pagenumber: pagenumber)
               
            
                self.fetchdatabyidnew(pagenumber: pagenumber)
           // }
            
           
        }
        
       
    }
    
    func fetchdatabyidnew(pagenumber:String!) {
        let bookId = DataManager.getVal(Config().AppUserDefaults.value(forKey: "bookid")) as! String
        let appDelegate =   (UIApplication.shared.delegate) as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FolioReaderdatabase")
        request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [NSPredicate(format: "page_number = %@", pagenumber),NSPredicate(format: "book_id = %@", bookId)])
      //  request.predicate = NSPredicate(format: "page_number = %@", pagenumber)
      //  request.predicate = NSPredicate(format: "book_id = %@", bookId)
                request.returnsObjectsAsFaults = false
                do {
                    let result = try managedContext.fetch(request)
                    let mutableArray = NSMutableArray()
                    for data in result as! [NSManagedObject] {
                        var content:String!
                        var note:String!
                        var pagenumber:String!
                        var bookid:String!
                        var userid:String!
                        var rangy:String!
                        var app_id:String!
                        var typem:String!
                        var chaptername:String!
                        content = data.value(forKey: "content") as? String
                        note = data.value(forKey: "note") as? String
                        pagenumber = data.value(forKey: "page_number") as? String

                        bookid = data.value(forKey: "book_id") as? String
                        userid = data.value(forKey: "user_id") as? String
                        rangy = data.value(forKey: "rangy") as? String
                        app_id = data.value(forKey: "app_id") as? String
                        typem = data.value(forKey: "type") as? String
                        chaptername = data.value(forKey: "chapter_name") as? String
                        let dict = ["content":content,"note":note,"page_number":pagenumber,"book_id":bookid,"user_id":userid,"rangy":rangy,"app_id":app_id,"type":typem,"chapter_name":chaptername]
                        mutableArray.add(dict)
              }
                    let  typeIdArrayString2 = self.JSONStringify(value: mutableArray as AnyObject)
                    print(typeIdArrayString2)
                    
                    if arr_bookList.count == 0 {
                        print("Ashish")
                    }else {
                        let vc = self.js("setHighlightByRangy('\(typeIdArrayString2)')")
                        print(vc ?? "")
                        let postionV = UserDefaults.standard.value(forKey: "PositionV") as? String
                        if postionV == "BookOut" {
                            let rangy = UserDefaults.standard.value(forKey: "rangeex") as? String
                            let position = self.js("goToHighlight('\(rangy ?? "")')")
                            print(position ?? "")
                        }else  if postionV == "BookIn" {
                            let rangy = UserDefaults.standard.value(forKey: "rangeex") as? String
                            let position = self.js("goToHighlight('\(rangy ?? "")')")
                            print(position ?? "")
                        }else {
                            print("Ashish")
                        }
                    }
                    
                } catch {
                    
                    print("Failed")
                }
    }
    
    func fetchdatabyidnew1(pagenumber:String!) {
        let bookId = DataManager.getVal(Config().AppUserDefaults.value(forKey: "bookid")) as! String
        let appDelegate =   (UIApplication.shared.delegate) as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FolioReaderdatabase")
                //request.predicate = NSPredicate(format: "page_number = %@", pagenumber)
                 request.predicate = NSPredicate(format: "book_id = %@", bookId)
                request.returnsObjectsAsFaults = false
                do {
                    let result = try managedContext.fetch(request)
                    let mutableArray = NSMutableArray()
//                    var dictUsersDetails  = NSManagedObject()
//                    for i in 0..<result.count {
//                        if let dict = result as? [NSManagedObject] {
//                            dictUsersDetails  =  dict[i]
//                            print(dictUsersDetails)
//                            mutableArray.add(dict)
//                        }
//                    }
                    for data in result as! [NSManagedObject] {
                        var content:String!
                        var note:String!
                        var pagenumber:String!
                        var bookid:String!
                        var userid:String!
                        var rangy:String!
                        var app_id:String!
                        var typem:String!
                        var chaptername:String!
                        content = data.value(forKey: "content") as? String
                        note = data.value(forKey: "note") as? String
                        pagenumber = data.value(forKey: "page_number") as? String

                        bookid = data.value(forKey: "book_id") as? String
                        userid = data.value(forKey: "user_id") as? String
                        rangy = data.value(forKey: "rangy") as? String
                        app_id = data.value(forKey: "app_id") as? String
                        typem = data.value(forKey: "type") as? String
                        chaptername = data.value(forKey: "chapter_name") as? String
                        let dict = ["content":content,"note":note,"page_number":pagenumber,"book_id":bookid,"user_id":userid,"rangy":rangy,"app_id":app_id,"type":typem,"chapter_name":chaptername]
                        mutableArray.add(dict)
              }
                    let  typeIdArrayString2 = self.JSONStringify(value: mutableArray as AnyObject)
                    print(typeIdArrayString2)
                    if typeIdArrayString2 == "[]" || typeIdArrayString2 == "" {
                        let defaults = UserDefaults.standard
                        defaults.setValue("pageChangeNewBook", forKey: "PGTxt")
                        defaults.synchronize()
                    }else{
                        
                    }
                    if mutableArray.count == 0 {
                        print("Ashish")
                    }else {
                        let vc = self.js("setHighlightByRangy('\(typeIdArrayString2)')")
                        print(vc ?? "")
                        let postionV = UserDefaults.standard.value(forKey: "PositionV") as? String
                        if postionV == "BookOut" {
                            let rangy = UserDefaults.standard.value(forKey: "rangeex") as? String
                            let position = self.js("goToHighlight('\(rangy ?? "")')")
                            print(position ?? "")
                        }else  if postionV == "BookIn" {
                            let rangy = UserDefaults.standard.value(forKey: "rangeex") as? String
                            let position = self.js("goToHighlight('\(rangy ?? "")')")
                            print(position ?? "")
                        }else {
                            print("Ashish")
                        }
                    }
                    
                } catch {
                    
                    print("Failed")
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
            arr_bookList = resArr
            if DataManager.isConnectedToNetwork() {
                print("Ashish")
            }else {
//                let mutableArray = NSMutableArray()
//                for data in resArr {
//                    var content:String!
//                    var note:String!
//                    var pagenumber:String!
//                    var bookid:String!
//                    var userid:String!
//                    var rangy:String!
//                    var app_id:String!
//                    var typem:String!
//                    var chaptername:String!
//                    content = data.value(forKey: "content") as? String
//                    note = data.value(forKey: "note") as? String
//                    pagenumber = data.value(forKey: "page_number") as? String
//
//                    bookid = data.value(forKey: "book_id") as? String
//                    userid = data.value(forKey: "user_id") as? String
//                    rangy = data.value(forKey: "rangy") as? String
//                    app_id = data.value(forKey: "app_id") as? String
//                    typem = data.value(forKey: "type") as? String
//                    chaptername = data.value(forKey: "chapter_name") as? String
//                    let dict = ["content":content,"note":note,"page_number":pagenumber,"book_id":bookid,"user_id":userid,"rangy":rangy,"app_id":app_id,"type":typem,"chapter_name":chaptername]
//                    mutableArray.add(dict)
//                }
//                let  typeIdArrayString2 = self.JSONStringify(value: mutableArray as AnyObject)
//                print(typeIdArrayString2)
//                if arr_bookList.count == 0 {
//                    print("Ashish")
//                }else {
//                    let vc = self.js("setHighlightByRangy('\(typeIdArrayString2)')")
//                    print(vc ?? "")
//                    let postionV = UserDefaults.standard.value(forKey: "PositionV") as? String
//                    if postionV == "BookOut" {
//                        let rangy = UserDefaults.standard.value(forKey: "rangeex") as? String
//                        let position = self.js("goToHighlight('\(rangy ?? "")')")
//                        print(position ?? "")
//                    }else  if postionV == "BookIn" {
//                        let rangy = UserDefaults.standard.value(forKey: "rangeex") as? String
//                        let position = self.js("goToHighlight('\(rangy ?? "")')")
//                        print(position ?? "")
//                    }else {
//                        print("Ashish")
//                    }
//
//
//                }
            }
        }catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func convertToJSONString(value: AnyObject) -> String? {
            if JSONSerialization.isValidJSONObject(value) {
                do{
                    let data = try JSONSerialization.data(withJSONObject: value, options: [])
                    if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                        return string as String
                    }
                }catch{
                }
            }
            return nil
        }
    
    // MARK: - UIMenuController - Actions

    @objc func share(_ sender: UIMenuController) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let shareImage = UIAlertAction(title: self.readerConfig.localizedShareImageQuote, style: .default, handler: { (action) -> Void in
            self.isShare = true
            if self.isShare{
                if let textToShare = self.js("getHighlightContent()") {
                    self.folioReader.readerCenter?.presentQuoteShare(textToShare)
                }
            
            } else {
                if let textToShare = self.js("getSelectedText()") {
                    self.folioReader.readerCenter?.presentQuoteShare(textToShare)
                    self.clearTextSelection()
                }
            }
            self.setMenuVisible(false)
        })

        let shareText = UIAlertAction(title: self.readerConfig.localizedShareTextQuote, style: .default) { (action) -> Void in
            self.isShare = true
            if self.isShare{
                if let textToShare = self.js("getHighlightContent()") {
                    let highlightId = self.js("getHighlightId()")
                    print(highlightId ?? "")
                    let defaults = UserDefaults.standard
                    defaults.setValue(highlightId, forKey: "RangeNE")
                    defaults.synchronize()
                    self.folioReader.readerCenter?.shareHighlight(textToShare, rect: sender.menuFrame)
                }
            } else {
                if let textToShare = self.js("getSelectedText()") {
                    self.folioReader.readerCenter?.shareHighlight(textToShare, rect: sender.menuFrame)
                }
            }
            self.setMenuVisible(false)
        }

        let cancel = UIAlertAction(title: self.readerConfig.localizedCancel, style: .cancel, handler: nil)

        alertController.addAction(shareImage)
        alertController.addAction(shareText)
        alertController.addAction(cancel)
        
        shareImage.setValue(UIColor.white, forKey: "titleTextColor")
        shareText.setValue(UIColor.white, forKey: "titleTextColor")
        cancel.setValue(UIColor(red: 252/255, green: 140/255, blue: 49/255, alpha: 1.0), forKey: "titleTextColor")
       
        
        var subview = UIView()
        subview = (alertController.view.subviews.first?.subviews.first?.subviews.first!)! as UIView
        subview.layer.cornerRadius = 1
        subview.backgroundColor = UIColor(red: (0/255.0), green: (155/255.0), blue: (216/255.0), alpha: 1.0)
       // alertController.view.tintColor = UIColor.white
        
     

        if let alert = alertController.popoverPresentationController {
            alert.sourceView = self.folioReader.readerCenter?.currentPage
            alert.sourceRect = sender.menuFrame
        }

        self.folioReader.readerCenter?.present(alertController, animated: true, completion: nil)
    }

    func colors(_ sender: UIMenuController?) {
        isColors = true
        createMenu(options: false)
        setMenuVisible(true)
    }

    func remove(_ sender: UIMenuController?) {
        let pagen:Int!
        pagen = UserDefaults.standard.integer(forKey: "PageNO")
        var rangy = js("getHighlightId()")
        print(rangy ?? "")
        let newRangy = js("removeHighlightByRangy()")
        print(newRangy ?? "")
        if rangy == "" || rangy ==  nil {
            print("Ashish")
        }else {
            oldrangy = newRangy
            oldrangy1 = rangy
            fetchdatabyid()
            fetchdatabyid1()
            
            if newapp_id == "" || newapp_id == nil || newapp_id1 != "" || newapp_id1 != nil {
                self.deleteHighlight(appId: "", Rangy: rangy, PageNo: String(pagen-1))
                self.DeleteDataDealRangy(rangy: rangy!)
            }else {
                self.deleteHighlight(appId: newapp_id, Rangy: "", PageNo: "")
                self.DeleteDataDeal(id: newapp_id)
            }
            setMenuVisible(false)
        }
       
    }
    
    //MARK:- Delete Data For ID
      func DeleteDataDeal(id: String) {
          let appDelegate         =   (UIApplication.shared.delegate) as! AppDelegate
          let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FolioReaderdatabase")
          let context      =   appDelegate.persistentContainer.viewContext
          request.predicate = NSPredicate(format: "app_id = %@", id)
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
    
    //MARK:- Delete Data For ID
      func DeleteDataDealRangy(rangy: String) {
          let appDelegate         =   (UIApplication.shared.delegate) as! AppDelegate
          let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FolioReaderdatabase")
          let context      =   appDelegate.persistentContainer.viewContext
          request.predicate = NSPredicate(format: "rangy = %@", rangy)
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
    
    func deleteHighlight(appId:String!,Rangy:String!,PageNo:String!) {
        let parameterDictionary = NSMutableDictionary()
        let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        let book_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "book_id")) as! String
                
                  parameterDictionary.setValue(DataManager.getVal(user_id) as! String, forKey: "user_id")
                  parameterDictionary.setValue(DataManager.getVal(book_id) as! String, forKey: "book_id")
                  parameterDictionary.setValue(DataManager.getVal(appId) as! String, forKey: "app_id")
                  parameterDictionary.setValue(DataManager.getVal(Rangy) as! String, forKey: "rangy")
                  parameterDictionary.setValue(DataManager.getVal(PageNo) as! String, forKey: "page_number")
    
                  print(parameterDictionary)
                  
                  let methodName = "deleteHighlight"
                  DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
                      let status  = DataManager.getVal(responseData?["status"]) as! String
                      let message  = DataManager.getVal(responseData?["message"]) as! String
                      let pagenumber  = DataManager.getVal(responseData?["page_number"]) as! String
                      if status == "1" {
                        print("Successfully Deleted the highlighted text.")
                        self.currentPage?.webView?.reload()
//                        var page:Int!
//                        page  = Int(pagenumber)
//                        let jsn = self.js("getHTML()")
//                        let vc = FolioReaderPage()
//                        let resource = self.book.spine.spineReferences[page].resource
//                        vc.loadHTMLString(jsn, baseURL: URL(fileURLWithPath: resource.fullHref.deletingLastPathComponent))
                      }
                      else{
                          print("Error in Deleted the highlighted text.")
                      }
                  }
    }
    

    
    func setselction(){
        print("Hello")
    }
    
    @objc func spacen(_ sender: UIMenuController?) {
        self.makeToast(message: "Space are not allowed to Highlight & Note")
    }
 //MARK:- Highlight Api Call
    @objc func highlight(_ sender: UIMenuController?) {
        let highlighttext = js("getSelectedText()")
        print(highlighttext)
        let vc = js("getHTML()")
        print(vc)
        print(rangyArray)
        let rangy = js("getRangyByLibrary('\(HighlightStyle.classForStyle(self.folioReader.currentHighlightStyle))')")
        print(rangy!)
        if rangy == "\"undefined is not an object (evaluating 'a.length')\"" || rangy == "" || rangy ==  nil {
        self.makeToast(message: "Space are not allowed in Highlight & Note")
        }else {
            let jsonData = rangy?.data(using: String.Encoding.utf8)
            let json = try! JSONSerialization.jsonObject(with: jsonData!, options: []) as! NSDictionary
            //let dic = json.firstObject as! [String: String]
            var rangysel:String!
            rangysel  = json["rangy"] as? String
            var selection:String!
            selection  = json["selection"] as? String
            var rangynew:String!
            rangynew = rangysel?.replacingOccurrences(of: "type:textContent|", with: "")
            let array = rangynew.components(separatedBy: "|")
            print(array)
            var differencerangy:String!
            let filteredArray = array.filter{ !rangyArray.contains($0) }
            print(filteredArray)
            differencerangy = filteredArray.last
            print(differencerangy!)
            let rangySplit = differencerangy.split(separator: "$")
            var tosetrangy:String!
            tosetrangy = differencerangy

            for i in 0..<rangyArray.count {
                var rangy:String!
                rangy = rangyArray[i] as? String
                let serverHiglightSplit = rangy.split(separator: "$")
                print(serverHiglightSplit)
                if rangySplit.first == serverHiglightSplit.first || rangySplit[1] == serverHiglightSplit.first || rangySplit[0] == serverHiglightSplit[1] || rangySplit[1] == serverHiglightSplit[1] {
                    let ser = String(serverHiglightSplit[1])
                    let rang = String(rangySplit[1])
                    let rang2 = String(rangySplit[2])
                    let rang3 = String(rangySplit[3])
                    let rang0 = String(rangySplit[0])
                    let ser0 = String(serverHiglightSplit[0])
                    if rangySplit[0] == serverHiglightSplit[0] {
                     tosetrangy = ser + "$" + rang + "$" + rang2 + "$" + rang3 + "$"
                    }else if rangySplit[1] == serverHiglightSplit[1] {
                     tosetrangy = rang0 + "$" + ser0 + "$" + rang2 + "$" + rang3 + "$"
                    }
                }

            }
            
            print(tosetrangy)
            let identifier = js("guid()")
            print(identifier!)

            let pageid = js("getpageid()")
            print(pageid!)

            let start = "<title>"
            let range1 = (pageid as NSString?)?.range(of: start)

            let end = "</title>"
            let range2 = (pageid as NSString?)?.range(of: end)

            let subString = (pageid as NSString?)?.substring(with: NSRange(location: (range1?.location ?? 0) + 7, length: (range2?.location ?? 0) - (range1?.location ?? 0) - 7))
            print("substring is \(subString ?? "")")
            
            var newpageid:String!
            newpageid = subString! + ".xhtml"

            do {
                
                let rect = js("getRectForSelectedText()")
                print(rect!)
                let rect1 = NSCoder.cgRect(for: rect!)
              //  createMenu(options: true)
                setMenuVisible(true, andRect:rect1)

              
                
                let pageNumber = folioReader.readerCenter?.currentPageNumber ?? 0
                self.tocItems = self.book.flatTableOfContents

                let page:Int!
                if pageNumber == 0 {
                    page = 1
                }else {
                    page = pageNumber-1
                }
                //let tocReference = tocItems[pageNumber]
                let tocReference = tocItems[page]
                    let ChapterName =  tocReference.title.trimmingCharacters(in: .whitespacesAndNewlines)
                    print(ChapterName)
                    
                    let parameterDictionary = NSMutableDictionary()
                    let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
                    let book_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "book_id")) as! String
                    var highlighclass:String!
                    var android_highlight_type:String!

                    if self.folioReader.currentHighlightStyle == 0 {
                        highlighclass = "highlight_span_yellow"
                        android_highlight_type = "highlight_yellow"
                    }else if self.folioReader.currentHighlightStyle == 1 {
                        highlighclass = "highlight_span_lime"
                        android_highlight_type = "highlight_green"
                    }else if self.folioReader.currentHighlightStyle == 2 {
                        highlighclass = "highlight_span_blue"
                        android_highlight_type = "highlight_blue"
                    }else if self.folioReader.currentHighlightStyle == 3 {
                        highlighclass = "highlight_span_pink"
                        android_highlight_type = "highlight_pink"
                    }else if self.folioReader.currentHighlightStyle == 4 {
                        highlighclass = "highlight_span_underline"
                        android_highlight_type = "highlight_underline"
                    }else{
                        highlighclass = "highlight_span_yellow"
                        android_highlight_type = "highlight_yellow"
                    }
                    var deviceType:String!
                    if (UIDevice.current.userInterfaceIdiom == .pad){
                        deviceType = "Ipad"
                        print("Ipad")
                    }else {
                        deviceType = "Iphone"
                        print("Iphone")
                    }
                    self.setMenuVisible(false)
                    parameterDictionary.setValue(DataManager.getVal(identifier) as! String, forKey: "app_id")
                    parameterDictionary.setValue(DataManager.getVal(user_id) as! String, forKey: "user_id")
                    parameterDictionary.setValue(DataManager.getVal(pageNumber-1) as! String, forKey: "page_number")
                    parameterDictionary.setValue(DataManager.getVal(book_id) as! String, forKey: "book_id")
                    parameterDictionary.setValue(DataManager.getVal(highlighttext) as! String, forKey: "selection")
                    parameterDictionary.setValue(DataManager.getVal(ChapterName) as! String, forKey: "chapter_name")
                    parameterDictionary.setValue(DataManager.getVal(highlighclass) as! String, forKey: "highlight_class")
                    parameterDictionary.setValue(DataManager.getVal(android_highlight_type) as! String, forKey: "android_highlight_type")
                    parameterDictionary.setObject(differencerangy!, forKey: "rangy" as NSCopying)
                    parameterDictionary.setObject(newpageid!, forKey: "page_id" as NSCopying)
                    parameterDictionary.setObject(newpageid!, forKey: "location" as NSCopying)
                    parameterDictionary.setObject("3", forKey: "highlight_form" as NSCopying)
                    parameterDictionary.setObject(deviceType!, forKey: "device_choose" as NSCopying)
                    print(parameterDictionary)
                    let methodName = "saveHighlight"
                
                if DataManager.isConnectedToNetwork() {
                    DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
                        let status  = DataManager.getVal(responseData?["status"]) as! String
                        let message  = DataManager.getVal(responseData?["message"]) as! String
                        self.higidl = DataManager.getVal(responseData?["highlight_id"]) as? String
                        if status == "1" {
                            print("Successfully Saved the highlighted text.")
                            self.saveItemInToModel(bookid: book_id, userid: user_id, appid: identifier, chaptername: ChapterName, pagenmuber: String(pageNumber-1), note: "", rangy: tosetrangy, content: highlighttext, type: android_highlight_type)
                            let pagen:Int!
                            pagen = UserDefaults.standard.integer(forKey: "PageNO")
                            self.getHighlightBookListingApiCall(pagenumber: String(pagen-1))
//                            Config().deleteAllRecords(tbaleName: "FolioReaderdatabase")
//                            self.getHighlightBookListingApiCall()
                            
                            
                        }
                        else{
                            print("Error in saving the highlighted text.")
                        }
                    }
                }else {
                    self.saveItemInToModel(bookid: book_id, userid: user_id, appid: identifier, chaptername: ChapterName, pagenmuber: String(pageNumber-1), note: "", rangy: tosetrangy, content: highlighttext, type: android_highlight_type)
                    let pagen:Int!
                    pagen = UserDefaults.standard.integer(forKey: "PageNO")
                    let defaults = UserDefaults.standard
                    defaults.setValue("off", forKey: "OF")
                    defaults.setValue("save", forKey: "SAV")
                    defaults.synchronize()
                  
                    self.getHighlightBookListingApiCall(pagenumber: String(pagen-1))
                    
                }
                   
                
               // }
            } catch {
                print("Could not receive JSON")
            }
        }
        
    }
    
    
    func getHighlightBookListingApiCall() {
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
    
    func highlupdate(style:HighlightStyle!,updadateid:String!,highlightclass:String!,andhilgttype:String) {
        if style.rawValue == 0 {
            self.folioReader.currentHighlightStyle = 0
        }else if style.rawValue == 1 {
            self.folioReader.currentHighlightStyle = 1
        }else if style.rawValue == 2 {
            self.folioReader.currentHighlightStyle = 2
        }else if style.rawValue == 3 {
            self.folioReader.currentHighlightStyle = 3
        }else if style.rawValue == 4 {
            self.folioReader.currentHighlightStyle = 4
        }
        let pagen:Int!
        pagen = UserDefaults.standard.integer(forKey: "PageNO")
        let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        let book_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "book_id")) as! String
        let parameterDictionary = NSMutableDictionary()
        parameterDictionary.setValue(DataManager.getVal(updadateid) as! String, forKey: "highlight_id")
        parameterDictionary.setValue(DataManager.getVal(newrangy) as! String, forKey: "rangy")
        parameterDictionary.setValue(DataManager.getVal(oldrangy) as! String, forKey: "old_rangy")
        parameterDictionary.setValue(DataManager.getVal(highlightclass) as! String, forKey: "highlight_class")
        parameterDictionary.setValue(DataManager.getVal(andhilgttype) as! String, forKey: "android_highlight_type")
        parameterDictionary.setValue(DataManager.getVal(pagen-1) as! String, forKey: "page_number")
        parameterDictionary.setValue(DataManager.getVal(user_id) as! String, forKey: "user_id")
        parameterDictionary.setValue(DataManager.getVal(book_id) as! String, forKey: "book_id")
        print(parameterDictionary)
                     
       let methodName = "updateHighlightRangy"
        if DataManager.isConnectedToNetwork() {
            DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
                let status  = DataManager.getVal(responseData?["status"]) as! String
                let message  = DataManager.getVal(responseData?["message"]) as! String
             
                var pagen = DataManager.getVal(responseData?["page_number"]) as! String
                if pagen == "" {
                 
                }else{
                 var pageno:Int!
                 pageno = Int(pagen)
                 var pageno1:Int!
                 pageno1 = pageno+1
               }
               
                if status == "1" {
                 self.updateMyJobsID(rangy: self.newrangy,AndType:andhilgttype)
                 print("Successfully Saved the highlighted text.")
                 self.getHighlightBookListingApiCall(pagenumber: pagen)
                }
                else{
                    print("Error in saving the highlighted text.")
                }
            }
        }else {
            self.updateMyJobsID(rangy: self.newrangy,AndType:andhilgttype)
            let pageNumber = folioReader.readerCenter?.currentPageNumber ?? 0
            self.getHighlightBookListingApiCall(pagenumber: String(pageNumber-1))
        }
      

    }
    
    func updateMyJobsID(rangy: String,AndType:String!){
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FolioReaderdatabase")
        let predicate = NSPredicate(format: "(rangy = %@)", oldrangy)
        fetchRequest.predicate = predicate
        let result = try? managedContext.fetch(fetchRequest)
        let resultData = result as! [NSManagedObject]
        for object in resultData {
            print(object.value(forKey: "app_id")!)
            object.setValue(self.newapp_id, forKey: "app_id")
            object.setValue(self.note, forKey: "note")
            object.setValue(self.content, forKey: "content")
            object.setValue(self.chaptername, forKey: "chapter_name")
            object.setValue(self.pagenumber, forKey: "page_number")
            object.setValue(self.bookid, forKey: "book_id")
            object.setValue(self.userid, forKey: "user_id")
            object.setValue(rangy, forKey: "rangy")
            object.setValue(AndType, forKey: "type")
        }
        do {
            try managedContext.save()
            print("saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
   
    
    func fetchdatabyid() {
        let appDelegate =   (UIApplication.shared.delegate) as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FolioReaderdatabase")
                request.predicate = NSPredicate(format: "rangy = %@",  oldrangy)
                request.returnsObjectsAsFaults = false
                do {
                    let result = try managedContext.fetch(request)
                    for data in result as! [NSManagedObject] {
                    self.newapp_id = data.value(forKey: "app_id") as? String
                    self.content = data.value(forKey: "content") as? String
                    self.note = data.value(forKey: "note") as? String
                    self.pagenumber = data.value(forKey: "page_number") as? String
                    self.bookid = data.value(forKey: "book_id") as? String
                    self.userid = data.value(forKey: "user_id") as? String
                    self.rangy = data.value(forKey: "rangy") as? String
                    self.typem = data.value(forKey: "type") as? String
                    self.chaptername = data.value(forKey: "chapter_name") as? String
                    print(self.newapp_id!)
                   
              }
                    
                } catch {
                    
                    print("Failed")
                }
    }
    
    func fetchdatabyid1() {
        let appDelegate =   (UIApplication.shared.delegate) as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FolioReaderdatabase")
                request.predicate = NSPredicate(format: "rangy = %@",  oldrangy1)
                request.returnsObjectsAsFaults = false
                do {
                    let result = try managedContext.fetch(request)
                    for data in result as! [NSManagedObject] {
                    self.newapp_id1 = data.value(forKey: "app_id") as? String
                    self.content = data.value(forKey: "content") as? String
                    self.note = data.value(forKey: "note") as? String
                    self.pagenumber = data.value(forKey: "page_number") as? String
                    self.bookid = data.value(forKey: "book_id") as? String
                    self.userid = data.value(forKey: "user_id") as? String
                    self.rangy = data.value(forKey: "rangy") as? String
                    self.typem = data.value(forKey: "type") as? String
                    self.chaptername = data.value(forKey: "chapter_name") as? String
                    print(self.newapp_id1!)
                   
              }
                    
                } catch {
                    
                    print("Failed")
                }
    }
    
    @objc func highlightWithNote(_ sender: UIMenuController?) {
        let highlighttext = js("getSelectedText()")
        print(highlighttext)
        print(rangyArray)
        let rangy = js("getRangyByLibrary('\(HighlightStyle.classForStyle(self.folioReader.currentHighlightStyle))')")
        print(rangy!)
        if rangy == "\"undefined is not an object (evaluating 'a.length')\"" || rangy == "" || rangy ==  nil {
            self.makeToast(message: "Space are not allowed in Highlight & Note")
        }else {
            let jsonData = rangy?.data(using: String.Encoding.utf8)
            let json = try! JSONSerialization.jsonObject(with: jsonData!, options: []) as! NSDictionary
            //let dic = json.firstObject as! [String: String]
            var rangysel:String!
            rangysel  = json["rangy"] as? String
            var selection:String!
            selection  = json["selection"] as? String
            var rangynew:String!
            rangynew = rangysel?.replacingOccurrences(of: "type:textContent|", with: "")
            let array = rangynew.components(separatedBy: "|")
            print(array)
            var differencerangy:String!
            let filteredArray = array.filter{ !rangyArray.contains($0) }
            print(filteredArray)
            differencerangy = filteredArray.last
            print(differencerangy!)
            
            let rangySplit = differencerangy.split(separator: "$")
            var tosetrangy:String!
            tosetrangy = differencerangy

            for i in 0..<rangyArray.count {
                var rangy:String!
                rangy = rangyArray[i] as? String
                let serverHiglightSplit = rangy.split(separator: "$")
                print(serverHiglightSplit)
                if rangySplit.first == serverHiglightSplit.first || rangySplit[1] == serverHiglightSplit.first || rangySplit[0] == serverHiglightSplit[1] || rangySplit[1] == serverHiglightSplit[1] {
                    let ser = String(serverHiglightSplit[1])
                    let rang = String(rangySplit[1])
                    let rang2 = String(rangySplit[2])
                    let rang3 = String(rangySplit[3])
                    let rang0 = String(rangySplit[0])
                    let ser0 = String(serverHiglightSplit[0])
                    if rangySplit[0] == serverHiglightSplit[0] {
                     tosetrangy = ser + "$" + rang + "$" + rang2 + "$" + rang3 + "$"
                    }else if rangySplit[1] == serverHiglightSplit[1] {
                     tosetrangy = rang0 + "$" + ser0 + "$" + rang2 + "$" + rang3 + "$"
                    }
                }

            }
            
            print(tosetrangy)
            let identifier = js("guid()")
            print(identifier!)

            let pageid = js("getpageid()")
            print(pageid!)

            let start = "<title>"
            let range1 = (pageid as NSString?)?.range(of: start)

            let end = "</title>"
            let range2 = (pageid as NSString?)?.range(of: end)

            let subString = (pageid as NSString?)?.substring(with: NSRange(location: (range1?.location ?? 0) + 7, length: (range2?.location ?? 0) - (range1?.location ?? 0) - 7))
            print("substring is \(subString ?? "")")
            
            var newpageid:String!
            newpageid = subString! + ".xhtml"

            do {
                
                let rect = js("getRectForSelectedText()")
                print(rect!)
                let rect1 = NSCoder.cgRect(for: rect!)
               // createMenu(options: true)
                //setMenuVisible(true, andRect:rect1)

                self.clearTextSelection()
                let pageNumber = folioReader.readerCenter?.currentPageNumber ?? 0
                self.tocItems = self.book.flatTableOfContents
                let page:Int!
               if pageNumber == 0 {
                   page = 1
               }else {
                   page = pageNumber-1
               }
                let tocReference = tocItems[page]

                
                    let ChapterName =  tocReference.title.trimmingCharacters(in: .whitespacesAndNewlines)
                    print(ChapterName)
                    
                    
                    let parameterDictionary = NSMutableDictionary()
                    let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
                    let book_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "book_id")) as! String
                    var highlighclass:String!
                    var android_highlight_type:String!

                    if self.folioReader.currentHighlightStyle == 0 {
                        highlighclass = "highlight_span_yellow"
                        android_highlight_type = "highlight_yellow"
                    }else if self.folioReader.currentHighlightStyle == 1 {
                        highlighclass = "highlight_span_lime"
                        android_highlight_type = "highlight_green"
                    }else if self.folioReader.currentHighlightStyle == 2 {
                        highlighclass = "highlight_span_blue"
                        android_highlight_type = "highlight_blue"
                    }else if self.folioReader.currentHighlightStyle == 3 {
                        highlighclass = "highlight_span_pink"
                        android_highlight_type = "highlight_pink"
                    }else if self.folioReader.currentHighlightStyle == 4 {
                        highlighclass = "highlight_span_underline"
                        android_highlight_type = "highlight_underline"
                    }else{
                        highlighclass = "highlight_span_yellow"
                        android_highlight_type = "highlight_yellow"
                    }
                    var deviceType:String!
                    if (UIDevice.current.userInterfaceIdiom == .pad){
                        deviceType = "Ipad"
                        print("Ipad")
                    }else {
                        deviceType = "Iphone"
                        print("Iphone")
                    }
                    parameterDictionary.setValue(DataManager.getVal(identifier) as! String, forKey: "app_id")
                    parameterDictionary.setValue(DataManager.getVal(user_id) as! String, forKey: "user_id")
                    parameterDictionary.setValue(DataManager.getVal(pageNumber-1) as! String, forKey: "page_number")
                    parameterDictionary.setValue(DataManager.getVal(book_id) as! String, forKey: "book_id")
                    parameterDictionary.setValue(DataManager.getVal(highlighttext) as! String, forKey: "selection")
                    parameterDictionary.setValue(DataManager.getVal(ChapterName) as! String, forKey: "chapter_name")
                    parameterDictionary.setValue(DataManager.getVal(highlighclass) as! String, forKey: "highlight_class")
                    parameterDictionary.setValue(DataManager.getVal(android_highlight_type) as! String, forKey: "android_highlight_type")
                    parameterDictionary.setObject(differencerangy!, forKey: "rangy" as NSCopying)
                    parameterDictionary.setObject(newpageid!, forKey: "page_id" as NSCopying)
                    parameterDictionary.setObject(newpageid!, forKey: "location" as NSCopying)
                    parameterDictionary.setObject("3", forKey: "highlight_form" as NSCopying)
                    parameterDictionary.setObject(deviceType!, forKey: "device_choose" as NSCopying)
                    print(parameterDictionary)
                    let methodName = "saveHighlight"
                if DataManager.isConnectedToNetwork() {
                    DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
                        let status  = DataManager.getVal(responseData?["status"]) as! String
                        let message  = DataManager.getVal(responseData?["message"]) as! String
                        self.higidl = DataManager.getVal(responseData?["highlight_id"]) as? String
                        if status == "1" {
                            print("Successfully Saved the highlighted text.")
                            
                            self.saveItemInToModel(bookid: book_id, userid: user_id, appid: self.higidl, chaptername: ChapterName, pagenmuber: String(pageNumber-1), note: "", rangy: tosetrangy, content: highlighttext, type: android_highlight_type)
                            let highlightNote = Highlight()
                            highlightNote.highlightId = self.higidl
                            let defaults = UserDefaults.standard
                            defaults.setValue(self.higidl, forKey: "appID")
                            defaults.setValue("withnote", forKey: "highNote")
                            defaults.synchronize()
                            var strpage:Int!
                            strpage = pageNumber-1
                            var pagen:String!
                            pagen = String(strpage)
                            self.getHighlightBookListingApiCall(pagenumber: pagen)
                            self.folioReader.readerCenter?.presentAddHighlightNote(highlightNote, edit: false)
                            
                           
                        }
                        else{
                            print("Error in saving the highlighted text.")
                        }
                    }
                }else {
                    self.saveItemInToModel(bookid: book_id, userid: user_id, appid: identifier, chaptername: ChapterName, pagenmuber: String(pageNumber-1), note: "", rangy: tosetrangy, content: highlighttext, type: android_highlight_type)
                    let highlightNote = Highlight()
                    highlightNote.highlightId = self.higidl
                    let defaults = UserDefaults.standard
                    defaults.setValue(identifier, forKey: "appID")
                    defaults.setValue("withnote", forKey: "highNote")
                    defaults.setValue("off", forKey: "OF")
                    defaults.setValue("save", forKey: "SAV")
                    defaults.synchronize()
                    var strpage:Int!
                    strpage = pageNumber-1
                    var pagen:String!
                    pagen = String(strpage)
                    self.getHighlightBookListingApiCall(pagenumber: pagen)
                    self.folioReader.readerCenter?.presentAddHighlightNote(highlightNote, edit: false)
                }
                    
               // }
            } catch {
                print("Could not receive JSON")
            }
        }
        
    }
    
    
    
    @objc func updateHighlightNote (_ sender: UIMenuController?) {
        print("Ashish")
        let highlightId = js("getHighlightId()")
        print(highlightId ?? "")
//        let highlightId = js("getHighlightIdNew()")
//        print(highlightId ?? "")
        if highlightId == nil || highlightId == "" {
            print("Ashish")
        }else {
            if highlightId!.contains("highlight") {
                let defaults = UserDefaults.standard
                defaults.setValue("rangy", forKey: "TypeHilgh")
                defaults.synchronize()
            }else {
                let defaults = UserDefaults.standard
                defaults.setValue("appid", forKey: "TypeHilgh")
                defaults.synchronize()
            }
         //  guard let highlightId = js("getHighlightId()") else { return }
    //        guard let highlightNote = Highlight.getById(withConfiguration: readerConfig, highlightId: highlightId!) else {
    //            return }
            
            let highlightNote = Highlight()
            highlightNote.highlightId = highlightId
            let defaults = UserDefaults.standard
            defaults.setValue(highlightId, forKey: "appID")
            defaults.setValue("updatenote", forKey: "highNote")
            defaults.synchronize()
            self.folioReader.readerCenter?.presentAddHighlightNote(highlightNote, edit: false)
        }
        
    }

    @objc func define(_ sender: UIMenuController?) {
        guard let selectedText = js("getSelectedText()") else {
            return
        }

        self.setMenuVisible(false)
        self.clearTextSelection()

        let vc = UIReferenceLibraryViewController(term: selectedText)
        vc.view.tintColor = self.readerConfig.tintColor
        guard let readerContainer = readerContainer else { return }
        readerContainer.show(vc, sender: nil)
    }

    @objc func play(_ sender: UIMenuController?) {
        self.folioReader.readerAudioPlayer?.play()

        self.clearTextSelection()
    }

    func setYellow(_ sender: UIMenuController?) {
        let defaults = UserDefaults.standard
        defaults.set("Y", forKey: "Colour")
        defaults.synchronize()
        colourvalue = 0
        changeHighlightStyle(sender, style: .yellow)
    }

    func setGreen(_ sender: UIMenuController?) {
        let defaults = UserDefaults.standard
        defaults.set("G", forKey: "Colour")
        defaults.synchronize()
        colourvalue = 1
       
        changeHighlightStyle1(sender, style: .green)
    }

    func setBlue(_ sender: UIMenuController?) {
        let defaults = UserDefaults.standard
        defaults.set("B", forKey: "Colour")
        defaults.synchronize()
        colourvalue = 2
        changeHighlightStyle2(sender, style: .blue)
    }

    func setPink(_ sender: UIMenuController?) {
        let defaults = UserDefaults.standard
        defaults.set("P", forKey: "Colour")
        defaults.synchronize()
        colourvalue = 3
        changeHighlightStyle3(sender, style: .pink)
    }

    func setUnderline(_ sender: UIMenuController?) {
        let defaults = UserDefaults.standard
        defaults.set("U", forKey: "Colour")
        defaults.synchronize()
        colourvalue = 4
        changeHighlightStyle4(sender, style: .underline)
        
    }
    
    
   
    

    func changeHighlightStyle(_ sender: UIMenuController?, style: HighlightStyle) {
        self.folioReader.currentHighlightStyle = 0
        let defaults = UserDefaults.standard
        defaults.set(self.folioReader.currentHighlightStyle, forKey: "StyleNew")
        defaults.set(0, forKey: "StyleNewZero")
        defaults.synchronize()
       // if let updateId = js("setHighlightStyle('\(HighlightStyle.classForStyle(style.rawValue))')") {
          //  Highlight.updateById(withConfiguration: self.readerConfig, highlightId: updateId, type: style)
            var highlighclass:String!
            var android_highlight_type:String!
            highlighclass = "highlight_span_yellow"
            android_highlight_type = "highlight_yellow"
//            let rangy = js("getRangyByLibrary('\(style)')")
//            print(rangy!)
            let rangy = js("getHighlightId()")
            print(rangy ?? "")
        let rangynew = js("getHighlightIdNew()")
        print(rangynew ?? "")
        if rangy == "" || rangy == nil {
         print("wronge text")
        }else {
            
            oldrangy = rangy
            oldrangy1 = rangynew
        
           
            var hilgt:String!
            if let index = rangy!.range(of: "_")?.lowerBound {
                let substring = rangy![..<index]                 // "ora"
                // or  let substring = word.prefix(upTo: index) // "ora"
                // (see picture below) Using the prefix(upTo:) method is equivalent to using a partial half-open range as the collection’s subscript.
                // The subscript notation is preferred over prefix(upTo:).

                let string = String(substring)
                print(string)  // "ora"
                hilgt = string
            }
            let indexn = (android_highlight_type.range(of: "_")?.upperBound)
            
            let afterEqualsTo = String(android_highlight_type.suffix(from: indexn!))
            
            newrangy = hilgt + "_" + afterEqualsTo + "$"
            print(newrangy)
           // fetchdatabyid()
            fetchdatabyid()
           // fetchdatabyid1()
            let updateId:String!
            updateId = ""
//            if newapp_id == "" || newapp_id == nil {
//                highlupdate(style: style, updadateid: newapp_id1,highlightclass: highlighclass,andhilgttype: android_highlight_type)
//            }else {
//                highlupdate(style: style, updadateid: newapp_id,highlightclass: highlighclass,andhilgttype: android_highlight_type)
//            }
            highlupdate(style: style, updadateid: updateId,highlightclass: highlighclass,andhilgttype: android_highlight_type)
       // }
       
        //FIX: https://github.com/FolioReader/FolioReaderKit/issues/316
        setMenuVisible(false)
        }
    }
    
    func changeHighlightStyle1(_ sender: UIMenuController?, style: HighlightStyle) {
        self.folioReader.currentHighlightStyle = 1
        let defaults = UserDefaults.standard
        defaults.set(self.folioReader.currentHighlightStyle, forKey: "StyleNew")
        defaults.set(1, forKey: "StyleNewOne")
        defaults.synchronize()
        //if let updateId = js("setHighlightStyle('\(HighlightStyle.classForStyle(style.rawValue))')") {
           // Highlight.updateById(withConfiguration: self.readerConfig, highlightId: updateId, type: style)
            var highlighclass:String!
            var android_highlight_type:String!

            highlighclass = "highlight_span_lime"
            android_highlight_type = "highlight_green"
            let rangy = js("getHighlightId()")
            print(rangy ?? "")
        let rangynew = js("getHighlightIdNew()")
        print(rangynew ?? "")
        if rangy == "" || rangy == nil {
         print("wronge text")
        }else {
            oldrangy = rangy
            oldrangy1 = rangynew
            var hilgt:String!
            if let index = rangy!.range(of: "_")?.lowerBound {
                let substring = rangy![..<index]                 // "ora"
                // or  let substring = word.prefix(upTo: index) // "ora"
                // (see picture below) Using the prefix(upTo:) method is equivalent to using a partial half-open range as the collection’s subscript.
                // The subscript notation is preferred over prefix(upTo:).

                let string = String(substring)
                print(string)  // "ora"
                hilgt = string
            }
            let indexn = (android_highlight_type.range(of: "_")?.upperBound)
            
            let afterEqualsTo = String(android_highlight_type.suffix(from: indexn!))
            
            newrangy = hilgt + "_" + afterEqualsTo + "$"
            print(newrangy)
           // fetchdatabyid()
            fetchdatabyid()
            //fetchdatabyid1()
            let updateId:String!
            updateId = ""
//            if newapp_id == "" || newapp_id == nil {
//                highlupdate(style: style, updadateid: newapp_id1,highlightclass: highlighclass,andhilgttype: android_highlight_type)
//            }else {
//                highlupdate(style: style, updadateid: newapp_id,highlightclass: highlighclass,andhilgttype: android_highlight_type)
//            }
            highlupdate(style: style, updadateid: updateId,highlightclass: highlighclass,andhilgttype: android_highlight_type)
        //}
        
        //FIX: https://github.com/FolioReader/FolioReaderKit/issues/316
        setMenuVisible(false)
        }
    }
    
    func changeHighlightStyle2(_ sender: UIMenuController?, style: HighlightStyle) {
        self.folioReader.currentHighlightStyle = 2
        let defaults = UserDefaults.standard
        defaults.set(self.folioReader.currentHighlightStyle, forKey: "StyleNew")
        defaults.set(2, forKey: "StyleNewTwo")
        defaults.synchronize()
        //if let updateId = js("setHighlightStyle('\(HighlightStyle.classForStyle(style.rawValue))')") {
          //  Highlight.updateById(withConfiguration: self.readerConfig, highlightId: updateId, type: style)
            var highlighclass:String!
            var android_highlight_type:String!

            highlighclass = "highlight_span_blue"
            android_highlight_type = "highlight_blue"
            let rangy = js("getHighlightId()")
            print(rangy ?? "")
        let rangynew = js("getHighlightIdNew()")
        print(rangynew ?? "")
        if rangy == "" || rangy == nil {
         print("wronge text")
        }else {
            oldrangy = rangy
            oldrangy1 = rangynew
        
            var hilgt:String!
            if let index = rangy!.range(of: "_")?.lowerBound {
                let substring = rangy![..<index]                 // "ora"
                // or  let substring = word.prefix(upTo: index) // "ora"
                // (see picture below) Using the prefix(upTo:) method is equivalent to using a partial half-open range as the collection’s subscript.
                // The subscript notation is preferred over prefix(upTo:).

                let string = String(substring)
                print(string)  // "ora"
                hilgt = string
            }
            let indexn = (android_highlight_type.range(of: "_")?.upperBound)
            
            let afterEqualsTo = String(android_highlight_type.suffix(from: indexn!))
            
            newrangy = hilgt + "_" + afterEqualsTo + "$"
            print(newrangy)
            //fetchdatabyid()
            fetchdatabyid()
           // fetchdatabyid1()
            let updateId:String!
            updateId = ""
//            if newapp_id == "" || newapp_id == nil {
//                highlupdate(style: style, updadateid: newapp_id1,highlightclass: highlighclass,andhilgttype: android_highlight_type)
//            }else {
//                highlupdate(style: style, updadateid: newapp_id,highlightclass: highlighclass,andhilgttype: android_highlight_type)
//            }
            highlupdate(style: style, updadateid: updateId,highlightclass: highlighclass,andhilgttype: android_highlight_type)
      //  }
        
        //FIX: https://github.com/FolioReader/FolioReaderKit/issues/316
        setMenuVisible(false)
        }
    }
    
    func changeHighlightStyle3(_ sender: UIMenuController?, style: HighlightStyle) {
        self.folioReader.currentHighlightStyle = 3
        let defaults = UserDefaults.standard
        defaults.set(self.folioReader.currentHighlightStyle, forKey: "StyleNew")
        defaults.set(3, forKey: "StyleNewThree")
        defaults.synchronize()
       // if let updateId = js("setHighlightStyle('\(HighlightStyle.classForStyle(style.rawValue))')") {
          //  Highlight.updateById(withConfiguration: self.readerConfig, highlightId: updateId, type: style)
            var highlighclass:String!
            var android_highlight_type:String!

            highlighclass = "highlight_span_pink"
            android_highlight_type = "highlight_pink"
            let rangy = js("getHighlightId()")
            print(rangy ?? "")
        let rangynew = js("getHighlightIdNew()")
        print(rangynew ?? "")
             if rangy == "" || rangy == nil {
              print("wronge text")
             }else {
            oldrangy = rangy
            oldrangy1 = rangynew
            
            var hilgt:String!
            if let index = rangy!.range(of: "_")?.lowerBound {
                let substring = rangy![..<index]                 // "ora"
                // or  let substring = word.prefix(upTo: index) // "ora"
                // (see picture below) Using the prefix(upTo:) method is equivalent to using a partial half-open range as the collection’s subscript.
                // The subscript notation is preferred over prefix(upTo:).

                let string = String(substring)
                print(string)  // "ora"
                hilgt = string
            }
            let indexn = (android_highlight_type.range(of: "_")?.upperBound)
            
            let afterEqualsTo = String(android_highlight_type.suffix(from: indexn!))
            
            newrangy = hilgt + "_" + afterEqualsTo + "$"
            print(newrangy)
           // fetchdatabyid()
                fetchdatabyid()
                //fetchdatabyid1()
                let updateId:String!
                updateId = ""
//                if newapp_id == "" || newapp_id == nil {
//                    highlupdate(style: style, updadateid: newapp_id1,highlightclass: highlighclass,andhilgttype: android_highlight_type)
//                }else {
//                    highlupdate(style: style, updadateid: newapp_id,highlightclass: highlighclass,andhilgttype: android_highlight_type)
//                }
           
            highlupdate(style: style, updadateid: updateId,highlightclass: highlighclass,andhilgttype: android_highlight_type)
       // }
        
        //FIX: https://github.com/FolioReader/FolioReaderKit/issues/316
        setMenuVisible(false)
        }
            
    }
    
    func changeHighlightStyle4(_ sender: UIMenuController?, style: HighlightStyle) {
        self.folioReader.currentHighlightStyle = 4
        let defaults = UserDefaults.standard
        defaults.set(self.folioReader.currentHighlightStyle, forKey: "StyleNew")
        defaults.set(4, forKey: "StyleNewFour")
        defaults.synchronize()
       // if let updateId = js("setHighlightStyle('\(HighlightStyle.classForStyle(style.rawValue))')") {
          //  Highlight.updateById(withConfiguration: self.readerConfig, highlightId: updateId, type: style)
            var highlighclass:String!
            var android_highlight_type:String!

            highlighclass = "highlight_span_underline"
            android_highlight_type = "highlight_underline"
            let rangy = js("getHighlightId()")
            print(rangy ?? "")
        let rangynew = js("getHighlightIdNew()")
        print(rangynew ?? "")
        if rangy == "" || rangy == nil {
         print("wronge text")
        }else {
            oldrangy = rangy
            oldrangy1 = rangynew
        
            var hilgt:String!
            if let index = rangy!.range(of: "_")?.lowerBound {
                let substring = rangy![..<index]                 // "ora"
                // or  let substring = word.prefix(upTo: index) // "ora"
                // (see picture below) Using the prefix(upTo:) method is equivalent to using a partial half-open range as the collection’s subscript.
                // The subscript notation is preferred over prefix(upTo:).

                let string = String(substring)
                print(string)  // "ora"
                hilgt = string
            }
            let indexn = (android_highlight_type.range(of: "_")?.upperBound)
            
            let afterEqualsTo = String(android_highlight_type.suffix(from: indexn!))
            
            newrangy = hilgt + "_" + afterEqualsTo + "$"
            print(newrangy)
            //fetchdatabyid()
            fetchdatabyid()
           // fetchdatabyid1()
            let updateId:String!
            updateId = ""
//            if newapp_id == "" || newapp_id == nil {
//                highlupdate(style: style, updadateid: newapp_id1,highlightclass: highlighclass,andhilgttype: android_highlight_type)
//            }else {
//                highlupdate(style: style, updadateid: newapp_id,highlightclass: highlighclass,andhilgttype: android_highlight_type)
//            }
            highlupdate(style: style, updadateid: updateId,highlightclass: highlighclass,andhilgttype: android_highlight_type)
      //  }
        
        //FIX: https://github.com/FolioReader/FolioReaderKit/issues/316
        setMenuVisible(false)
        }
    }

    // MARK: - Create and show menu
    @objc func highlight1234(_ sender: UIMenuItem?) {
        let highlighttext = js("getSelectedText()")
        print(highlighttext)
        let vc = js("getHTML()")
        print(vc)
        print(rangyArray)
        let rangy = js("getRangyByLibrary('\(HighlightStyle.classForStyle(self.folioReader.currentHighlightStyle))')")
        print(rangy!)
        if rangy == "\"undefined is not an object (evaluating 'a.length')\"" || rangy == "" || rangy ==  nil {
        self.makeToast(message: "Space are not allowed in Highlight & Note")
        }else {
            let jsonData = rangy?.data(using: String.Encoding.utf8)
            let json = try! JSONSerialization.jsonObject(with: jsonData!, options: []) as! NSDictionary
            //let dic = json.firstObject as! [String: String]
            var rangysel:String!
            rangysel  = json["rangy"] as? String
            var selection:String!
            selection  = json["selection"] as? String
            var rangynew:String!
            rangynew = rangysel?.replacingOccurrences(of: "type:textContent|", with: "")
            let array = rangynew.components(separatedBy: "|")
            print(array)
            var differencerangy:String!
            let filteredArray = array.filter{ !rangyArray.contains($0) }
            print(filteredArray)
            differencerangy = filteredArray.last
            print(differencerangy!)
            let rangySplit = differencerangy.split(separator: "$")
            var tosetrangy:String!
            tosetrangy = differencerangy

            for i in 0..<rangyArray.count {
                var rangy:String!
                rangy = rangyArray[i] as? String
                let serverHiglightSplit = rangy.split(separator: "$")
                print(serverHiglightSplit)
                if rangySplit.first == serverHiglightSplit.first || rangySplit[1] == serverHiglightSplit.first || rangySplit[0] == serverHiglightSplit[1] || rangySplit[1] == serverHiglightSplit[1] {
                    let ser = String(serverHiglightSplit[1])
                    let rang = String(rangySplit[1])
                    let rang2 = String(rangySplit[2])
                    let rang3 = String(rangySplit[3])
                    let rang0 = String(rangySplit[0])
                    let ser0 = String(serverHiglightSplit[0])
                    if rangySplit[0] == serverHiglightSplit[0] {
                     tosetrangy = ser + "$" + rang + "$" + rang2 + "$" + rang3 + "$"
                    }else if rangySplit[1] == serverHiglightSplit[1] {
                     tosetrangy = rang0 + "$" + ser0 + "$" + rang2 + "$" + rang3 + "$"
                    }
                }

            }
            
            print(tosetrangy)
            let identifier = js("guid()")
            print(identifier!)

            let pageid = js("getpageid()")
            print(pageid!)

            let start = "<title>"
            let range1 = (pageid as NSString?)?.range(of: start)

            let end = "</title>"
            let range2 = (pageid as NSString?)?.range(of: end)

            let subString = (pageid as NSString?)?.substring(with: NSRange(location: (range1?.location ?? 0) + 7, length: (range2?.location ?? 0) - (range1?.location ?? 0) - 7))
            print("substring is \(subString ?? "")")
            
            var newpageid:String!
            newpageid = subString! + ".xhtml"

            do {
                
                let rect = js("getRectForSelectedText()")
                print(rect!)
                let rect1 = NSCoder.cgRect(for: rect!)
              //  createMenu(options: true)
                setMenuVisible(true, andRect:rect1)

              
                
                let pageNumber = folioReader.readerCenter?.currentPageNumber ?? 0
                self.tocItems = self.book.flatTableOfContents

                let page:Int!
                if pageNumber == 0 {
                    page = 1
                }else {
                    page = pageNumber-1
                }
                //let tocReference = tocItems[pageNumber]
                let tocReference = tocItems[page]
                    let ChapterName =  tocReference.title.trimmingCharacters(in: .whitespacesAndNewlines)
                    print(ChapterName)
                    
                    let parameterDictionary = NSMutableDictionary()
                    let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
                    let book_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "book_id")) as! String
                    var highlighclass:String!
                    var android_highlight_type:String!

                    if self.folioReader.currentHighlightStyle == 0 {
                        highlighclass = "highlight_span_yellow"
                        android_highlight_type = "highlight_yellow"
                    }else if self.folioReader.currentHighlightStyle == 1 {
                        highlighclass = "highlight_span_lime"
                        android_highlight_type = "highlight_green"
                    }else if self.folioReader.currentHighlightStyle == 2 {
                        highlighclass = "highlight_span_blue"
                        android_highlight_type = "highlight_blue"
                    }else if self.folioReader.currentHighlightStyle == 3 {
                        highlighclass = "highlight_span_pink"
                        android_highlight_type = "highlight_pink"
                    }else if self.folioReader.currentHighlightStyle == 4 {
                        highlighclass = "highlight_span_underline"
                        android_highlight_type = "highlight_underline"
                    }else{
                        highlighclass = "highlight_span_yellow"
                        android_highlight_type = "highlight_yellow"
                    }
                    var deviceType:String!
                    if (UIDevice.current.userInterfaceIdiom == .pad){
                        deviceType = "Ipad"
                        print("Ipad")
                    }else {
                        deviceType = "Iphone"
                        print("Iphone")
                    }
                    self.setMenuVisible(false)
                    parameterDictionary.setValue(DataManager.getVal(identifier) as! String, forKey: "app_id")
                    parameterDictionary.setValue(DataManager.getVal(user_id) as! String, forKey: "user_id")
                    parameterDictionary.setValue(DataManager.getVal(pageNumber-1) as! String, forKey: "page_number")
                    parameterDictionary.setValue(DataManager.getVal(book_id) as! String, forKey: "book_id")
                    parameterDictionary.setValue(DataManager.getVal(highlighttext) as! String, forKey: "selection")
                    parameterDictionary.setValue(DataManager.getVal(ChapterName) as! String, forKey: "chapter_name")
                    parameterDictionary.setValue(DataManager.getVal(highlighclass) as! String, forKey: "highlight_class")
                    parameterDictionary.setValue(DataManager.getVal(android_highlight_type) as! String, forKey: "android_highlight_type")
                    parameterDictionary.setObject(differencerangy!, forKey: "rangy" as NSCopying)
                    parameterDictionary.setObject(newpageid!, forKey: "page_id" as NSCopying)
                    parameterDictionary.setObject(newpageid!, forKey: "location" as NSCopying)
                    parameterDictionary.setObject("3", forKey: "highlight_form" as NSCopying)
                    parameterDictionary.setObject(deviceType!, forKey: "device_choose" as NSCopying)
                    print(parameterDictionary)
                    let methodName = "saveHighlight"
                    DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
                        let status  = DataManager.getVal(responseData?["status"]) as! String
                        let message  = DataManager.getVal(responseData?["message"]) as! String
                        self.higidl = DataManager.getVal(responseData?["highlight_id"]) as? String
                        if status == "1" {
                            print("Successfully Saved the highlighted text.")
                            self.saveItemInToModel(bookid: book_id, userid: user_id, appid: identifier, chaptername: ChapterName, pagenmuber: String(pageNumber-1), note: "", rangy: tosetrangy, content: highlighttext, type: android_highlight_type)
                            let pagen:Int!
                            pagen = UserDefaults.standard.integer(forKey: "PageNO")
                            self.getHighlightBookListingApiCall(pagenumber: String(pagen-1))
                            Config().deleteAllRecords(tbaleName: "FolioReaderdatabase")
                            self.getHighlightBookListingApiCall()
                        }
                        else{
                            print("Error in saving the highlighted text.")
                        }
                    }
               // }
            } catch {
                print("Could not receive JSON")
            }
        }

    }
    func createMenu(options: Bool) {
        guard (self.readerConfig.useReaderMenuController == true) else {
            return
        }

       // isShare = options

        let colors = UIImage(readerImageNamed: "colors-marker")
        let icon = UIImage(readerImageNamed: "icon-camera")
        let share = UIImage(readerImageNamed: "share-marker")
        let remove = UIImage(readerImageNamed: "no-marker")
        let yellow = UIImage(readerImageNamed: "yellow-marker")
        let green = UIImage(readerImageNamed: "green-marker")
        let blue = UIImage(readerImageNamed: "blue-marker")
        let pink = UIImage(readerImageNamed: "pink-marker")
        let underline = UIImage(readerImageNamed: "underline-marker")
        

        let menuController = UIMenuController.shared
       // let sapceitem = UIMenuItem(title: "Space", action: #selector(spacen(_:)))
        let highlightItem = UIMenuItem(title: self.readerConfig.localizedHighlightMenu, action: #selector(highlight(_:)))
        let highlightNoteItem = UIMenuItem(title: self.readerConfig.localizedHighlightNote, action: #selector(highlightWithNote(_:)))
        let editNoteItem = UIMenuItem(title: self.readerConfig.localizedHighlightNote, action: #selector(updateHighlightNote(_:)))
        let playAudioItem = UIMenuItem(title: self.readerConfig.localizedPlayMenu, action: #selector(play(_:)))
        let defineItem = UIMenuItem(title: self.readerConfig.localizedDefineMenu, action: #selector(define(_:)))
        
        let colorsItem = UIMenuItem(title: "C", image: colors) { [weak self] _ in
            self?.colors(menuController)
        }
        
        
        let shareItem = UIMenuItem(title: "S", image: share) { [weak self] _ in
            self?.share(menuController)
        }
        let removeItem = UIMenuItem(title: "R", image: remove) { [weak self] _ in
            self?.remove(menuController)
        }
        let yellowItem = UIMenuItem(title: "Y", image: yellow) { [weak self] _ in
            self?.setYellow(menuController)
        }
        let greenItem = UIMenuItem(title: "G", image: green) { [weak self] _ in
            self?.setGreen(menuController)
        }
        let blueItem = UIMenuItem(title: "B", image: blue) { [weak self] _ in
            self?.setBlue(menuController)
        }
        let pinkItem = UIMenuItem(title: "P", image: pink) { [weak self] _ in
            self?.setPink(menuController)
        }
        let underlineItem = UIMenuItem(title: "U", image: underline) { [weak self] _ in
            self?.setUnderline(menuController)
        }
        
        let colorsItemNew = UIMenuItem(title: "Highlight", image: colors) { [weak self] _ in
            self?.highlight(menuController)
            
            
        }
       
       
        //let conty = UIMenuItem(title: "Highlight", image: colors, action: highlight1234(_:))
       // let highlightL = UIMenuItem(title: "", image: colors, action: <#T##MenuItemAction##MenuItemAction##(UIMenuItem) -> Void#>)
       
        var menuItems: [UIMenuItem] = []
        if options == true {
            ishighlight = true
        }else {
            ishighlight = false
        }
       
        // menu on existing highlight
        if isShare {
            menuItems = [colorsItem, editNoteItem, removeItem]
            
            if (self.readerConfig.allowSharing == true) {
                menuItems.append(shareItem)
            }
            isShare = false
        } else if isColors {
            // menu for selecting highlight color
            menuItems = [yellowItem, greenItem, blueItem, pinkItem, underlineItem]
        }
        else if ishighlight {
            menuItems = [colorsItem, editNoteItem, removeItem]

            if (self.readerConfig.allowSharing == true) {
                menuItems.append(shareItem)
            }
            ishighlight = false
        }
        else if isOneWord == true{
            menuItems = [defineItem]
           // isOneWord = false
        }
        else {
            // default menu
            //menuItems = [conty,colorsItemNew,highlightItem, defineItem, highlightNoteItem]
            menuItems = [highlightItem, defineItem, highlightNoteItem]

            if self.book.hasAudio || self.readerConfig.enableTTS {
               // menuItems.insert(playAudioItem, at: 0)
            }
//            if (self.readerConfig.allowSharing == true) {
//                menuItems.append(shareItem)
//            }
        }
        
        menuController.menuItems = menuItems
    }
    
    
    open func setMenuVisible(_ menuVisible: Bool, animated: Bool = true, andRect rect: CGRect = CGRect.zero) {
        if !menuVisible && isShare || !menuVisible && isColors {
            isColors = false
            isShare = false
        }
        
        if menuVisible  {
            if !rect.equalTo(CGRect.zero) {
                UIMenuController.shared.setTargetRect(rect, in: self)
            }
        }
        
        
        UIMenuController.shared.setMenuVisible(menuVisible, animated: animated)
    }
    
    // MARK: - Java Script Bridge
    
    @discardableResult open func js(_ script: String) -> String? {
        let callback = self.stringByEvaluatingJavaScript(from: script)
       // print("Callaback String\(callback)")
        if callback!.isEmpty { return nil }
        return callback
    }
    
    // MARK: WebView
    
    func clearTextSelection() {
        // Forces text selection clearing
        // @NOTE: this doesn't seem to always work
        
        self.isUserInteractionEnabled = false
        self.isUserInteractionEnabled = true
    }
    
    func setupScrollDirection() {
        switch self.readerConfig.scrollDirection {
        case .vertical, .defaultVertical, .horizontalWithVerticalContent:
            scrollView.isPagingEnabled = false
            paginationMode = .unpaginated
            scrollView.bounces = true
            break
        case .horizontal:
            scrollView.isPagingEnabled = true
            paginationMode = .leftToRight
            paginationBreakingMode = .page
            scrollView.bounces = false
            break
        }
    }
}
extension NSManagedObject {
  func toJSON() -> String? {
    let keys = Array(self.entity.attributesByName.keys)
    let dict = self.dictionaryWithValues(forKeys: keys)
    do {
        let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        let reqJSONStr = String(data: jsonData, encoding: .utf8)
        return reqJSONStr
    }
    catch{}
    return nil
  }
}

