//
//  FolioReaderHighlightList.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 01/09/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit
import CoreData

class FolioReaderHighlightList: UITableViewController {

    fileprivate var highlights = [Highlight]()
    fileprivate var readerConfig: FolioReaderConfig
    fileprivate var folioReader: FolioReader
    fileprivate weak var readerContainer1: FolioReaderContainer?
    var arr_bookList : [NSManagedObject] = []
    var daten:Date?
    init(folioReader: FolioReader, readerConfig: FolioReaderConfig) {
        self.readerConfig = readerConfig
        self.folioReader = folioReader

        super.init(style: UITableView.Style.plain)
    }
    
    func datasttt(){
        var  abcu :String!
        abcu = "saveAll"
        abcu.append("Data")
        print(abcu ?? "")
        
    }

    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init with coder not supported")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: kReuseCellIdentifier)
        self.tableView.separatorInset = UIEdgeInsets.zero
        self.tableView.backgroundColor = self.folioReader.isNight(self.readerConfig.nightModeMenuBackground, self.readerConfig.menuBackgroundColor)
        self.tableView.separatorColor = self.folioReader.isNight(self.readerConfig.nightModeSeparatorColor, self.readerConfig.menuSeparatorColor)

        guard let bookId = (self.folioReader.readerContainer?.book.name as NSString?)?.deletingPathExtension else {
            self.highlights = []
            return
        }
        
        if DataManager.isConnectedToNetwork() {
            self.fetchItemRecordFromDB()
        }else {
           // self.fetchdatabyid111()
            self.fetchdatabyidnew1()
          //  self.fetchItemRecordFromDB()
        }
        
       
       //self.highlights = Highlight.allByBookId(withConfiguration: self.readerConfig, bookId: bookId)
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
//            for data in resArr {
//                arr_bookList.append(data)
//                print(arr_bookList)
//
//            }
        }catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func fetchdatabyid111() {
        let bookId = DataManager.getVal(Config().AppUserDefaults.value(forKey: "bookid")) as! String
        let appDelegate =   (UIApplication.shared.delegate) as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let request     =   NSFetchRequest<NSManagedObject>(entityName:"FolioReaderdatabase")
        request.predicate = NSPredicate(format: "book_id = %@", bookId)
        request.returnsObjectsAsFaults = false
                do {
                    var resArr          =   [NSManagedObject]()
                    resArr              =   try managedContext.fetch(request)
                    print("PharmacyArr = ", resArr)
                    print(resArr.count)
                    arr_bookList = resArr
                    
                } catch {
                    
                    print("Failed")
                }
    }
    
    func fetchdatabyidnew1() {
        var newBookId:String!
        let bookId = DataManager.getVal(Config().AppUserDefaults.value(forKey: "bookid")) as! String
        let book_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "book_id")) as! String
        if bookId == "" || bookId == nil {
            newBookId = book_id
        }else{
            newBookId = bookId
        }
     
        let appDelegate =   (UIApplication.shared.delegate) as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FolioReaderdatabase")
                 request.predicate = NSPredicate(format: "book_id = %@", newBookId)
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
                   arr_bookList = result as! [NSManagedObject]
                    
                } catch {
                    
                    print("Failed")
                }
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arr_bookList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: kReuseCellIdentifier, for: indexPath)
        cell.backgroundColor = UIColor.clear

        let highlight = arr_bookList[indexPath.row]
         // Format date
       
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self.readerConfig.localizedHighlightsDateFormat
       // let dateString = dateFormatter.string(from: daten!)
        

        // Date
        var dateLabel: UILabel!
        if cell.contentView.viewWithTag(456) == nil {
            dateLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width-40, height: 16))
            dateLabel.tag = 456
            dateLabel.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
            dateLabel.font = UIFont(name: "Avenir-Medium", size: 12)
            cell.contentView.addSubview(dateLabel)
        } else {
            dateLabel = cell.contentView.viewWithTag(456) as? UILabel
        }

        dateLabel.text = ""
       // dateLabel.text = dateString.uppercased()
        dateLabel.textColor = self.folioReader.isNight(UIColor(white: 5, alpha: 0.3), UIColor.lightGray)
        dateLabel.frame = CGRect(x: 20, y: 20, width: view.frame.width-40, height: dateLabel.frame.height)

        // Text
        let content = highlight.value(forKey: "content") as? String
        let contentN = content?.replacingOccurrences(of: "\t", with: "")
        let cleanString = contentN!.stripHtml().truncate(250, trailing: "...").stripLineBreaks()
        let text = NSMutableAttributedString(string: cleanString)
        let range = NSRange(location: 0, length: text.length)
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 3
        let textColor = self.folioReader.isNight(self.readerConfig.menuTextColor, UIColor.black)

        

        text.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraph, range: range)
        text.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Avenir-Light", size: 16)!, range: range)
        text.addAttribute(NSAttributedString.Key.foregroundColor, value: textColor, range: range)
        
        let type = highlight.value(forKey: "type") as? String
        var typen:Int!
        if type == "highlight_yellow" {
            typen = 0
        }else if type == "highlight_green" {
            typen = 1
        }else if type == "highlight_blue" {
            typen = 2
        }else if type == "highlight_pink" {
            typen = 3
        }else if type == "highlight_underline" {
            typen = 4
        }else {
            typen = 0
        }
        if (typen == HighlightStyle.underline.rawValue) {
            text.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.clear, range: range)
            text.addAttribute(NSAttributedString.Key.underlineColor, value: HighlightStyle.colorForStyle(typen, nightMode: self.folioReader.nightMode), range: range)
            text.addAttribute(NSAttributedString.Key.underlineStyle, value: NSNumber(value: NSUnderlineStyle.single.rawValue as Int), range: range)
        } else {
            text.addAttribute(NSAttributedString.Key.backgroundColor, value: HighlightStyle.colorForStyle(typen, nightMode: self.folioReader.nightMode), range: range)
        }

        // Text
        var highlightLabel: UILabel!
        if cell.contentView.viewWithTag(123) == nil {
            highlightLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width-40, height: 0))
            highlightLabel.tag = 123
            highlightLabel.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
            highlightLabel.numberOfLines = 0
            highlightLabel.textColor = UIColor.black
            cell.contentView.addSubview(highlightLabel)
        } else {
            highlightLabel = cell.contentView.viewWithTag(123) as? UILabel
        }

        highlightLabel.attributedText = text
        highlightLabel.sizeToFit()
        highlightLabel.frame = CGRect(x: 20, y: 46, width: view.frame.width-40, height: highlightLabel.frame.height)
        
        // Note text if it exists
        if let note = highlight.value(forKey: "note") as? String {
            var noteLabel: UILabel!
            if cell.contentView.viewWithTag(789) == nil {
                noteLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width-40, height: 0))
                noteLabel.tag = 789
                noteLabel.font = UIFont.systemFont(ofSize: 14)
                noteLabel.autoresizingMask = UIView.AutoresizingMask.flexibleWidth
                noteLabel.numberOfLines = 3
                noteLabel.textColor = UIColor.gray
                cell.contentView.addSubview(noteLabel)
            } else {
                noteLabel = cell.contentView.viewWithTag(789) as? UILabel
            }
            noteLabel.text = note
            noteLabel.sizeToFit()
            noteLabel.frame = CGRect(x: 20, y: 46 + highlightLabel.frame.height + 10, width: view.frame.width-40, height: noteLabel.frame.height)
        } else {
            cell.contentView.viewWithTag(789)?.removeFromSuperview()
        }

        cell.layoutMargins = UIEdgeInsets.zero
        cell.preservesSuperviewLayoutMargins = false
        
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let highlight = arr_bookList[indexPath.row]
        let content = highlight.value(forKey: "content") as? String
        let contentN = content?.replacingOccurrences(of: "\t", with: "")
        let cleanString = contentN!.stripHtml().truncate(250, trailing: "...").stripLineBreaks()
        let text = NSMutableAttributedString(string: cleanString)
        let range = NSRange(location: 0, length: text.length)
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 3
        text.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraph, range: range)
        text.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Avenir-Light", size: 16)!, range: range)

        let s = text.boundingRect(with: CGSize(width: view.frame.width-40, height: CGFloat.greatestFiniteMagnitude),
                                  options: [NSStringDrawingOptions.usesLineFragmentOrigin, NSStringDrawingOptions.usesFontLeading],
                                  context: nil)
         var totalHeight = s.size.height + 66
        
        if let note = highlight.value(forKey: "note") as? String {
            let noteLabel = UILabel()
            noteLabel.frame = CGRect(x: 20, y: 46 , width: view.frame.width-40, height: CGFloat.greatestFiniteMagnitude)
            noteLabel.text = note
            noteLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
            noteLabel.numberOfLines = 0
            noteLabel.font = UIFont.systemFont(ofSize: 14)
            
            noteLabel.sizeToFit()
            totalHeight += noteLabel.frame.height
        }
         return totalHeight
    }
    
    //MARK:-  SaveHighlightTextApiCall
     func saveHighlightNote(HighlightedId: String, HighlightedText: String) {
        self.view.endEditing(true)
        self.showHud()
        let parameterDictionary = NSMutableDictionary()
        parameterDictionary.setObject( HighlightedId, forKey: "app_id" as NSCopying)
        parameterDictionary.setObject( HighlightedText, forKey: "text" as NSCopying)
        print(parameterDictionary)
        let methodName = "saveHighlightNote"
        
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
            if status == "1" {
               self.view.makeToast(message: message)
            } else{
                self.view.makeToast(message: message)
            }
            self.clearHud()
        }
    }
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let Edit = UITableViewRowAction(style: .normal, title: "Edit") { action, index in
            let highlightnew = self.arr_bookList[index.row]
            let appid = highlightnew.value(forKey: "app_id") as? String
            let highlightId = highlightnew.value(forKey: "rangy") as? String
            let selection = highlightnew.value(forKey: "content") as? String
            let Note = highlightnew.value(forKey: "note") as? String
            let highlightNote = Highlight()
            highlightNote.highlightId = highlightId

            let defaults = UserDefaults.standard
            defaults.setValue(highlightId, forKey: "appID")
            defaults.setValue(selection, forKey: "cont")
            defaults.setValue(Note, forKey: "notea")
            defaults.setValue("updatenote", forKey: "highNote")
            defaults.synchronize()
            self.dismiss(animated: true, completion: {
                self.folioReader.readerCenter?.presentAddHighlightNote(highlightNote, edit: false)
            })
           

        }
        Edit.backgroundColor = UIColor.blue

        let Delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            let highlightnew = self.arr_bookList[index.row]
            let appid = highlightnew.value(forKey: "app_id") as? String
            let bookIdNew = highlightnew.value(forKey: "book_id") as? String

            self.DeleteDataDeal(id: appid!)
            self.arr_bookList.remove(at: index.row)
            tableView.reloadData()
            self.deleteHighlightApiCall(HighlightedId: appid!, BookID: Int(bookIdNew!)!)
        }
        Delete.backgroundColor = .red

        return [Delete, Edit]

    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       // guard let highlight = highlights[safe: indexPath.row] else { return }
        let highlight = arr_bookList[indexPath.row]
        let page = highlight.value(forKey: "page_number") as? String
        let appid = highlight.value(forKey: "app_id") as? String
        let rangy = highlight.value(forKey: "rangy") as? String
        let pageno:Int!
        pageno = Int(page!)
        let defaults = UserDefaults.standard
        defaults.set("HighLightOut", forKey: "HIghNew")
        defaults.set("hilo", forKey: "newscreen")
        defaults.setValue("exact", forKey: "position")
        defaults.setValue(rangy, forKey: "rangeex")
        defaults.setValue("BookIn", forKey: "PositionV")
        defaults.synchronize()
        self.folioReader.readerCenter?.changePageWith(page: pageno+1, andFragment: appid!)
        
        self.dismiss()
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
         if editingStyle == .delete {
            let highlightnew = arr_bookList[indexPath.row]
            let appid = highlightnew.value(forKey: "app_id") as? String
            let bookIdNew = highlightnew.value(forKey: "book_id") as? String
            
            DeleteDataDeal(id: appid!)
            self.arr_bookList.remove(at: indexPath.row)
            tableView.reloadData()
            self.deleteHighlightApiCall(HighlightedId: appid!, BookID: Int(bookIdNew!)!)
            
//            guard let highlight = highlights[safe: indexPath.row] else { return }
//
//            if (highlight.page == self.folioReader.readerCenter?.currentPageNumber),
//                let page = self.folioReader.readerCenter?.currentPage {
//                Highlight.removeFromHTMLById(withinPage: page, highlightId: highlight.highlightId) // Remove from HTML
//            }
//            let bookId  = UserDefaults.standard.value(forKey: "book_id") as? Int
//            self.deleteHighlightApiCall(HighlightedId: highlight.highlightId, BookID: bookId!)
//
//            highlight.remove(withConfiguration: self.readerConfig) // Remove from Database
//            highlights.remove(at: indexPath.row)
//            tableView.deleteRows(at: [indexPath], with: .fade)
            
            
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
                self.tableView.reloadData()
                NotificationCenter.default.post(name: NSNotification.Name("calldatabase"), object: nil)
                
            }else {
                self.view.makeToast(message: message)
            }
            self.clearHud()
        }
    }
    
    // MARK: - Handle rotation transition
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        tableView.reloadData()
    }
}
