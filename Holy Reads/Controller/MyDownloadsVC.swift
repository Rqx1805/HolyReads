//
//  MyDownloadsVC.swift
//  Holy Reads
//
//  Created by mac-14 on 02/09/19.
//  Copyright © 2019 Ajeet singh Rawat. All rights reserved.
 
import UIKit
import CoreData
import PMAlertController

class MyDownloadsVC: UIViewController,UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - IBOutlet
    @IBOutlet weak var tblMyDownloads: UITableView!
    @IBOutlet weak var btnSelectAll: UIButton!
    @IBOutlet weak var lblDownloadUsingWifi: UILabel!  
    //@IBOutlet weak var switchDownloadWifi: UIButton!
    @IBOutlet weak var btnDownloadSwitch: UISwitch!
    
    var arrDownloadDetails = [DownloadEnitity]()
    var dicSelectedBooks = [String:Any]()
    var arrSelectedBooks = [Int]()
    
    
    var select_type_array = NSMutableArray()
    

    var isClick: Bool = false
    var isClick1: Bool = false
    var isClick2: Bool = false
    
    var readcheck = ""
    var videocheck = ""
    var audiocheck = ""
    var arrMusic = [String]()
    var lastobsts:String!
    var selIndex:Int!
    var selIndex1:Int!
    var selIndex2:Int!
    var downtype:String!
    
    var read_check_array = NSMutableArray()
    var video_check_array = NSMutableArray()
    var audio_check_array = NSMutableArray()
    var book_id:String!
    // MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        downtype = UserDefaults.standard.value(forKey: "MyDown") as? String
        if downtype == "delete" {
            let bookid = UserDefaults.standard.value(forKey: "bookNID") as? String
            var id :Int64!
            id  = Int64(UserDefaults.standard.integer(forKey: "booki"))
            self.DeleteDataMeal(id:id)
        }else{
            
        }
        
        
        self.tblMyDownloads.rowHeight = UITableView.automaticDimension
        self.tblMyDownloads.estimatedRowHeight = 50
        self.arrDownloadDetails = DownloadEnitity.shared.fetchData()
        print(arrDownloadDetails)
        arrDownloadDetails  =  arrDownloadDetails.reversed()
        print(arrDownloadDetails)
        
        readcheck = "No"
        videocheck = "No"
        audiocheck = "No"
        lastobsts = ""
        if arrDownloadDetails.count == 0 {
            self.btnSelectAll.isHidden = true
            self.lblDownloadUsingWifi.isHidden = false
           // self.switchDownloadWifi.isHidden = false
        } else {
            self.btnSelectAll.isHidden = true
            self.lblDownloadUsingWifi.isHidden = false
            //self.switchDownloadWifi.isHidden = false
        }
        
        if UserDefaults.standard.value(forKey: "DownloadUsingWifi") as? Bool ?? true  {
            self.btnDownloadSwitch.isOn = true
        } else {
            self.btnDownloadSwitch.isOn = false
        }
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
                    UserDefaults.standard.removeObject(forKey: "MyDown")
                }
            }
            else{
                return
            }
        }
    }
    
    // MARK: - NavigationBar Buttons
    @IBAction func btnBack_DidSelect(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - IBAction
    
    
    @IBAction func switchDownloadTapped(_ sender: UISwitch) {
        if sender.isOn {
            UserDefaults.standard.set( true, forKey: "DownloadUsingWifi")
         } else {
            UserDefaults.standard.set( false, forKey: "DownloadUsingWifi")
        }
    }
    
    @IBAction func btnSelectAll(_ sender: UIButton) {
        if (!isClick) {
            isClick = true
            self.btnSelectAll.setImage(UIImage(named: "check"), for: .normal)
            // self.btnSelectAll.setTitle("  RemoveAll", for: .normal)
            for index in 0..<self.arrDownloadDetails.count{
                let a = arrDownloadDetails[index] as DownloadEnitity
                let id = a.id
                self.select_type_array.add(id)
            }
            self.tblMyDownloads.reloadData()
        } else {
            isClick = false
            self.btnSelectAll.setImage(UIImage(named: "uncheck"), for: .normal)
            //self.btnSelectAll.setTitle(" RemoveAll", for: .normal)
            self.select_type_array.removeAllObjects()
            self.tblMyDownloads.reloadData()
        }
        print(select_type_array)
    }
    
    @IBAction func btnDelete_DidSelect(_ sender: UIButton) {
        var arrNames = [String]()
        let swiftArray = select_type_array as NSArray as! [Int64]
        print(swiftArray)
        arrDownloadDetails.filter { (val) -> Bool in
            if swiftArray.contains(val.id) {
                let name = val.book_name!
                arrNames.append(name)
                return true
            }
            return false
        }
        print(arrNames)
        
        if swiftArray.count != 0 {
            self.DeleteSelectedID(arrDelete: swiftArray)
            self.DeleteBookDocumentDirectory(arrFolderNames: arrNames)
        } else {
            self.view.makeToast(message: "No book selected")
        }
    }
    
   
    func DeleteBookDocumentDirectory(arrFolderNames:[String]) {
        for i in 0...arrFolderNames.count-1 {
            let documentsDirectoryURL = appDelegate.DocumentDirectoryUrl!
            let BookFolderPath = documentsDirectoryURL.appendingPathComponent("\(arrFolderNames[i])")
             do {
                try FileManager.default.removeItem(at: BookFolderPath)
                print("Book Directory Deleted Successfully")
            }catch{
                print(error.localizedDescription)
            }
        }
    }
    
    
    
    
    
    func DeleteSelectedID(arrDelete :[Int64]) {
        let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "DownloadEnitity")
        // let request:NSFetchRequest<UserDetails> = UserDetails.fetchRequest()
        for id in arrDelete {
            request.predicate = NSPredicate(format: "id = %ld", id)
            do{
                let test = try! context?.fetch(request)
                let objupdate = test![0] as! NSManagedObject
                do{
                    context?.delete(objupdate)
                    print("Data Deleted Data saved.")
                    select_type_array.remove(id)
                    self.arrDownloadDetails = DownloadEnitity.shared.fetchData()
                    if self.arrDownloadDetails.count == 0 {
                        self.btnSelectAll.isHidden = true
                    }
                }
            } catch let error {
                print("Detele all data in  error :", error)
            }
            self.tblMyDownloads.reloadData()
        }
    }
    
    // MARK: - Cheking Device Connected using wifi or not
  
    @objc func playAudioOffline(_ Sender : UIButton) {
        let tag = Sender.tag
        //dictBookDetails
        let a  = arrDownloadDetails[tag] as DownloadEnitity
        if a.contains_Audio {
            let obj = self.storyboard?.instantiateViewController(withIdentifier: "ListinMusicVC") as! ListinMusicVC
            obj.dictOfflineDownloads = a
            obj.isOffline = true
            self.navigationController?.pushViewController(obj, animated: true)
        }else{
            self.view.makeToast(message: "No downloaded audio found")
        }
        
    }
    
    @objc func playOfflineVideo(_ Sender : UIButton) {
        let tag = Sender.tag
        let a  = arrDownloadDetails[tag] as DownloadEnitity
        if a.contains_Video {
            let obj = self.storyboard?.instantiateViewController(withIdentifier: "WatchVideoVC") as! WatchVideoVC
            //dictBookDetails
            
            obj.dictOfflineDownloads = a
            obj.isOffline = true
            self.navigationController?.pushViewController(obj, animated: true)
        } else{
            self.view.makeToast(message: "No downloaded video found")
        }
    }
    
    @objc func markCheck(_ sender : UIButton) {
        let a  = arrDownloadDetails[sender.tag] as DownloadEnitity
               let id = a.id
               if select_type_array.contains(id) {
                   select_type_array.remove(id)
                   isClick = false
                   self.btnSelectAll.setImage(UIImage(named: "uncheck"), for: .normal)
               } else {
                   select_type_array.add(id)
                   isClick = true
                   if select_type_array.count == arrDownloadDetails.count {
                       self.btnSelectAll.setImage(UIImage(named: "check"), for: .normal)
                       //self.btnSelectAll.setTitle("  RemoveAll", for: .normal)
                   } else {
                       print("Ashish")
                   }
               }
               print(select_type_array)
               self.tblMyDownloads.reloadData()
    }
    
    @objc func readBookOffline(_ Sender : UIButton) {
        let tag = Sender.tag
        let a  = arrDownloadDetails[tag] as DownloadEnitity
        let b = a.id
//        let vcc = a.arr_highlight
//        print(vcc)
        if DataManager.isConnectedToNetwork() {
            Config().deleteAllRecords(tbaleName: "FolioReaderdatabase")
            getHighlightBookListingApiCall(bookId: String(b))
        }else{
           print("No")
        }
        let strb = String(b)
        let defaults = UserDefaults.standard
        defaults.setValue(b, forKey: "bookid")
        defaults.setValue(strb, forKey: "book_id")
       // defaults.setValue(vcc, forKey: "highar")
       // defaults.setValue("D", forKey: "downloadby")
        defaults.synchronize()
        if a.contains_Book {
            if let bookName = a.book_name as? String {
                let bookTitle =  bookName.replacingOccurrences(of: " ", with: "")
                self.Test(BookName: bookTitle)
            }
        } else{
            self.view.makeToast(message: "No downloaded book found")
        }
    }
    
    
    
    func getHighlightBookListingApiCall(bookId:String) {
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
                        self.updateMyJobsappid(app_id: app_id, Note: note, Content: selection, ChapterName: chapter_name, PageNumber: page_number, BookId: String(bookId), Rangy: rangy, Typem: type, UserId: user_id)
                        
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
    //MARK:- MatchDataFor_CoreDataRecord
    func matchDataDeal(tableName: String, tableId : String) -> [NSManagedObject]{
        var newArr                  =   [NSManagedObject]()
        if #available(iOS 10.0, *) {
            let appDelegate         =   (UIApplication.shared.delegate) as! AppDelegate
            let context             =   appDelegate.persistentContainer.viewContext
            let request             =   NSFetchRequest<NSFetchRequestResult>(entityName:tableName)
            let checkPredicate      =   NSPredicate(format: "book_id == %@", tableId)
            request.predicate       =   checkPredicate;
            newArr                  =   try! context.fetch(request) as! [NSManagedObject]
            return newArr
        } else {
            // Fallback on earlier versions
            return newArr
        }
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
    
    func updateMyJobsappid(app_id: String,Note:String!,Content:String!,ChapterName:String!,PageNumber:String!,BookId:String!,Rangy:String!,Typem:String!,UserId:String!){
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FolioReaderdatabase")
        let predicate = NSPredicate(format: "(app_id = %@)", app_id)
        fetchRequest.predicate = predicate
        let result = try? managedContext.fetch(fetchRequest)
        let resultData = result as! [NSManagedObject]
        for object in resultData {
            print(object.value(forKey: "app_id")!)
            object.setValue(app_id, forKey: "app_id")
            object.setValue(Note, forKey: "note")
            object.setValue(Content, forKey: "content")
            object.setValue(ChapterName, forKey: "chapter_name")
            object.setValue(PageNumber, forKey: "page_number")
            if DataManager.isConnectedToNetwork() {
                object.setValue(BookId, forKey: "book_id")
            }else{
                object.setValue(BookId, forKey: "book_id")
            }
            
            object.setValue(UserId, forKey: "user_id")
            object.setValue(Rangy, forKey: "rangy")
            object.setValue(Typem, forKey: "type")
        }
        do {
            try managedContext.save()
            print("saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int
        {
            var numOfSections: Int = 0
            if arrDownloadDetails.count>0
            {
                tableView.separatorStyle = .none
                numOfSections            = 1
                tableView.backgroundView = nil
            }
            else
            {
                let noDataLabel: UILabel     = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
                noDataLabel.text = "No Downloads Available."
                noDataLabel.textColor     = UIColor(red: 255/255, green: 150/255, blue: 67/255, alpha: 1.0)
                noDataLabel.textAlignment = .center
                tableView.backgroundView  = noDataLabel
                tableView.separatorStyle  = .none
            }
            return numOfSections
        }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrDownloadDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DownloadCell", for: indexPath) as! DownloadCell
        cell.btnVideo.tag = indexPath.row
        cell.btnRead.tag = indexPath.row
        cell.btnAudio.tag = indexPath.row
       // cell.btnCheck.tag = indexPath.row
        
        let dict = arrDownloadDetails[indexPath.row] as DownloadEnitity
        if dict.contains_Video {
            cell.videoCheck.isHidden = false
            cell.btnVideo.isHidden  = false
            cell.videocheckview.isHidden  = false
            cell.viewopenview.isHidden  = false
        }else {
            cell.videoCheck.isHidden = true
            cell.btnVideo.isHidden  = true
            cell.videocheckview.isHidden  = true
            cell.viewopenview.isHidden  = true
        }
        
        if dict.contains_Audio {
            cell.audioChcek.isHidden = false
            cell.btnAudio.isHidden  = false
            cell.audioopenview.isHidden  = false
            cell.audiocheckview.isHidden  = false
        }else {
            cell.audioChcek.isHidden = true
            cell.btnAudio.isHidden  = true
            cell.audioopenview.isHidden  = true
            cell.audiocheckview.isHidden  = true
        }
        
        if dict.contains_Book {
            cell.readCheck.isHidden = false
            cell.btnRead.isHidden  = false
            cell.bookopenview.isHidden  = false
            cell.bookchcekview.isHidden = false
        }else {
            cell.readCheck.isHidden = true
            cell.btnRead.isHidden  = true
            cell.bookopenview.isHidden  = true
            cell.bookchcekview.isHidden = true
        }
        
        cell.lblBookAuthor.text =  dict.author_name
        let des = dict.descript
       
        let htmlData = NSString(string: des!).data(using: String.Encoding.utf8.rawValue)
        let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
        let attributedString = try! NSAttributedString(data: htmlData!,
                                                       options: options,
                                                       documentAttributes: nil)

        let perfectcode = attributedString.string
        cell.descriptionLbl.text = perfectcode
       // cell.descriptionLbl.text = dict.descript
        
        let property_id = dict.id
        if self.select_type_array.contains(property_id){
            cell.btnCheck.setImage(UIImage.init(named: "check"), for: .normal)
        }else{
            cell.btnCheck.setImage(UIImage.init(named: "uncheck"), for: .normal)
        }
        cell.lblBookName.text = dict.book_name
        if let img = dict.book_image as? Data {
            cell.imgBook.image =  UIImage(data: img)
        }
        if arrDownloadDetails.count == 0 {
            self.btnSelectAll.isHidden = true
            self.lblDownloadUsingWifi.isHidden = false
         //  self.switchDownloadWifi.isHidden = false
        } else {
            self.btnSelectAll.isHidden = true
            self.lblDownloadUsingWifi.isHidden = false
          //  self.switchDownloadWifi.isHidden = false
         }
        cell.btnVideo.addTarget(self, action: #selector(playOfflineVideo) , for: .touchUpInside)
        cell.btnRead.addTarget(self, action: #selector(readBookOffline) , for: .touchUpInside)
        cell.btnAudio.addTarget(self, action: #selector(playAudioOffline) , for: .touchUpInside)
        //cell.btnCheck.tag = indexPath.row
        //cell.btnCheck.addTarget(self, action: #selector(markCheck) , for: .touchUpInside)
        
//        if self.readcheck == "yes" {
//            cell.readCheck.setImage(UIImage(named: "check"), for: .normal)
//        }else {
//            cell.readCheck.setImage(UIImage(named: "uncheck"), for: .normal)
//        }
//
//        if self.videocheck == "yes" {
//            cell.videoCheck.setImage(UIImage(named: "check"), for: .normal)
//        }else {
//            cell.videoCheck.setImage(UIImage(named: "uncheck"), for: .normal)
//        }
//
//        if self.audiocheck == "yes" {
//            cell.audioChcek.setImage(UIImage(named: "check"), for: .normal)
//        }else {
//            cell.audioChcek.setImage(UIImage(named: "uncheck"), for: .normal)
//        }
        
//        if indexPath.row == selIndex {
//            cell.readCheck.setImage(UIImage(named: "check"), for: .normal)
//        }else {
//            cell.readCheck.setImage(UIImage(named: "uncheck"), for: .normal)
//        }
//
//        if indexPath.row == selIndex1 {
//            cell.videoCheck.setImage(UIImage(named: "check"), for: .normal)
//        }else {
//            cell.videoCheck.setImage(UIImage(named: "uncheck"), for: .normal)
//        }
//
//        if indexPath.row == selIndex2 {
//            cell.audioChcek.setImage(UIImage(named: "check"), for: .normal)
//        }else {
//            cell.audioChcek.setImage(UIImage(named: "uncheck"), for: .normal)
//        }
        //MARK:- Read check button
        if self.read_check_array.contains(indexPath.row){
            
            cell.readCheck.setImage(UIImage(named: "check"), for: .normal)
        }else{
            if indexPath.row  == selIndex1 || indexPath.row == selIndex || indexPath.row == selIndex2{
                print("Read")
            }else {
                self.video_check_array.removeAllObjects()
                self.audio_check_array.removeAllObjects()
            }
            cell.readCheck.setImage(UIImage(named: "uncheck"), for: .normal)
        }
        //MARK:- Video check button
        if self.video_check_array.contains(indexPath.row){
           
            cell.videoCheck.setImage(UIImage(named: "check"), for: .normal)
        }else{
            if indexPath.row  == selIndex1 || indexPath.row == selIndex || indexPath.row == selIndex2{
                print("Read")
            }else {
                self.video_check_array.removeAllObjects()
                self.audio_check_array.removeAllObjects()
            }
            cell.videoCheck.setImage(UIImage(named: "uncheck"), for: .normal)
        }
        //MARK:- Audio check button
        if self.audio_check_array.contains(indexPath.row){
            
            cell.audioChcek.setImage(UIImage(named: "check"), for: .normal)
        }else{
            if indexPath.row  == selIndex1 || indexPath.row == selIndex || indexPath.row == selIndex2{
                print("Read")
            }else {
                self.video_check_array.removeAllObjects()
                self.audio_check_array.removeAllObjects()
            }
            cell.audioChcek.setImage(UIImage(named: "uncheck"), for: .normal)
        }

        cell.readCheck.tag = indexPath.row
        cell.videoCheck.tag = indexPath.row
        cell.audioChcek.tag = indexPath.row
        cell.deleteBtnNew.tag = indexPath.row
        cell.readCheck.addTarget(self, action: #selector(readCheck) , for: .touchUpInside)
        cell.videoCheck.addTarget(self, action: #selector(videoCheck) , for: .touchUpInside)
        cell.audioChcek.addTarget(self, action: #selector(audioCheck) , for: .touchUpInside)
        cell.deleteBtnNew.addTarget(self, action: #selector(deletenewCheck) , for: .touchUpInside)
        
        

        
        return cell
    }
    
    @objc func readCheck(_ sender : UIButton) {
//        let indexPath = NSIndexPath(row: sender.tag, section: 0)
//        let cell = tblMyDownloads.cellForRow(at: indexPath as IndexPath) as! DownloadCell
        let dict = arrDownloadDetails[sender.tag] as DownloadEnitity
        let category_id = dict.id
        if self.read_check_array.contains(sender.tag){
            self.read_check_array.remove(sender.tag)
            readcheck = "No"

        }else{
            self.read_check_array.removeAllObjects()
            self.read_check_array.add(sender.tag)
            readcheck = "yes"

        }
        selIndex = sender.tag
        selIndex1 = 0
        selIndex2 = 0
        
        self.tblMyDownloads.reloadData()
//        if (!isClick){
//            sender.setImage(UIImage(named: "check"), for: .normal)
//            isClick=true
//            readcheck = "yes"
//            selIndex = sender.tag
//            tblMyDownloads.reloadRows(at: [IndexPath(row: (sender.tag), section: 0)], with: .none)
//
//        }
//        else
//        {
//            sender.setImage(UIImage(named: "uncheck"), for: .normal)
//            isClick=false
//            readcheck = "No"
//            selIndex = nil
//            tblMyDownloads.reloadRows(at: [IndexPath(row: (sender.tag), section: 0)], with: .none)
//
//        }
      
    }
    @objc func videoCheck(_ sender : UIButton) {
        
        let dict = arrDownloadDetails[sender.tag] as DownloadEnitity
        let category_id = dict.id
        if self.video_check_array.contains(sender.tag){
            self.video_check_array.remove(sender.tag)
            videocheck = "No"

        }else{
            self.video_check_array.removeAllObjects()
            self.video_check_array.add(sender.tag)
            videocheck = "yes"

        }
        selIndex1 = sender.tag
        selIndex = 0
        selIndex2 = 0
        self.tblMyDownloads.reloadData()
//        if (!isClick1){
//            sender.setImage(UIImage(named: "check"), for: .normal)
//            isClick1=true
//            videocheck = "yes"
//            selIndex1 = sender.tag
//            tblMyDownloads.reloadRows(at: [IndexPath(row: (sender.tag), section: 0)], with: .none)
//
//        }
//        else
//        {
//            sender.setImage(UIImage(named: "uncheck"), for: .normal)
//            isClick1=false
//            videocheck = "No"
//            selIndex1 = nil
//            tblMyDownloads.reloadRows(at: [IndexPath(row: (sender.tag), section: 0)], with: .none)
//
//        }
        
    }
    @objc func audioCheck(_ sender : UIButton) {
        
        let dict = arrDownloadDetails[sender.tag] as DownloadEnitity
        let category_id = dict.id
        if self.audio_check_array.contains(sender.tag){
            self.audio_check_array.remove(sender.tag)
            audiocheck = "No"
        }else{
            self.audio_check_array.removeAllObjects()
            self.audio_check_array.add(sender.tag)
            audiocheck = "yes"
        }
        selIndex2 = sender.tag
        selIndex = 0
        selIndex1 = 0
        self.tblMyDownloads.reloadData()
        
//        if (!isClick2){
//            sender.setImage(UIImage(named: "check"), for: .normal)
//            isClick2=true
//            audiocheck = "yes"
//            selIndex2 = sender.tag
//            tblMyDownloads.reloadRows(at: [IndexPath(row: (sender.tag), section: 0)], with: .none)
//
//        }
//        else
//        {
//            sender.setImage(UIImage(named: "uncheck"), for: .normal)
//            isClick2=false
//            audiocheck = "No"
//            selIndex2 = nil
//            tblMyDownloads.reloadRows(at: [IndexPath(row: (sender.tag), section: 0)], with: .none)
//
//        }
        
    }
    @objc func deletenewCheck(_ Sender : UIButton) {
        let dict = arrDownloadDetails[Sender.tag] as DownloadEnitity
        if readcheck == "yes" && videocheck == "No" && audiocheck == "No" {
            
           let myAlert = PMAlertController(title: "Holy Reads", description: "Do you permanently want to delete the summary?", image: UIImage(named: "welcome_logo"), style: .alert)
           myAlert.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () -> Void in
               print("Cancel")
           }))
           
           myAlert.addAction(PMAlertAction(title: "Yes", style: .default, action: { () in
            print("delete book")
          //  self.arrDownloadDetails = DownloadEnitity.shared.fetchData()
            print(self.arrDownloadDetails)
            let dict = self.arrDownloadDetails[Sender.tag] as DownloadEnitity
            let property_id = dict.id
            let containvideo = dict.contains_Video
            print(containvideo)
            let containaudio = dict.contains_Audio
            print(containaudio)
            
            if containvideo == false && containaudio == false {
                let a  = self.arrDownloadDetails[Sender.tag] as DownloadEnitity
                let id = a.id
                self.select_type_array.add(id)
                var arrNames = [String]()
                let swiftArray = self.select_type_array as NSArray as! [Int64]
                print(swiftArray)
                
                self.arrDownloadDetails.filter { (val) -> Bool in
                    if swiftArray.contains(val.id) {
                        let name = val.book_name!
                        arrNames.append(name)
                        return true
                    }
                    return false
                }
                print(arrNames)
                
                if swiftArray.count != 0 {
                    self.DeleteSelectedID(arrDelete: swiftArray)
                    self.DeleteBookDocumentDirectory(arrFolderNames: arrNames)
                } else {
                    self.view.makeToast(message: "No book selected")
                }
                print("delete video and audio,book")
            }else {
                var dic = [String:Any]()
                dic["book_id"] = property_id
                dic["contains_Book"] = false
                self.readcheck = "No"
                DownloadEnitity.shared.saveData(dict: dic)
                self.tblMyDownloads.reloadData()
            }
           }))

           
           self.present(myAlert, animated: true, completion: nil)
            
           
       
           
        }else if videocheck == "yes" && readcheck == "No" && audiocheck == "No" {
            let myAlert = PMAlertController(title: "Holy Reads", description: "Do you permanently want to delete the video?", image: UIImage(named: "welcome_logo"), style: .alert)
            myAlert.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () -> Void in
                print("Cancel")
            }))
            
            myAlert.addAction(PMAlertAction(title: "Yes", style: .default, action: { () in
            print("delete video")
           // self.arrDownloadDetails = DownloadEnitity.shared.fetchData()
                print(self.arrDownloadDetails)
                let dict = self.arrDownloadDetails[Sender.tag] as DownloadEnitity
            let property_id = dict.id
            let containaudio = dict.contains_Audio
            print(containaudio)
            let containbook = dict.contains_Book
            print(containbook)
            if containbook == false && containaudio == false {
                let a  = self.arrDownloadDetails[Sender.tag] as DownloadEnitity
                let id = a.id
                self.select_type_array.add(id)
                var arrNames = [String]()
                let swiftArray = self.select_type_array as NSArray as! [Int64]
                print(swiftArray)
                
                self.arrDownloadDetails.filter { (val) -> Bool in
                    if swiftArray.contains(val.id) {
                        let name = val.book_name!
                        arrNames.append(name)
                        return true
                    }
                    return false
                }
                print(arrNames)
                
                if swiftArray.count != 0 {
                    self.DeleteSelectedID(arrDelete: swiftArray)
                    self.DeleteBookDocumentDirectory(arrFolderNames: arrNames)
                   
                } else {
                    self.view.makeToast(message: "No book selected")
                }
                print("delete video and audio,book")
            }else {
                var dic = [String:Any]()
                dic["book_id"] = property_id
                dic["contains_Video"] = false
                self.videocheck = "No"
                DownloadEnitity.shared.saveData(dict: dic)
                self.tblMyDownloads.reloadData()
            }
            }))

            
            self.present(myAlert, animated: true, completion: nil)
            
        }else if  audiocheck == "yes" && readcheck == "No" && videocheck == "No" {
            let myAlert = PMAlertController(title: "Holy Reads", description: "Do you permanently want to delete the audio?", image: UIImage(named: "welcome_logo"), style: .alert)
            myAlert.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () -> Void in
                print("Cancel")
            }))
            
            myAlert.addAction(PMAlertAction(title: "Yes", style: .default, action: { () in
                print("delete audio")
               // self.arrDownloadDetails = DownloadEnitity.shared.fetchData()
                print(self.arrDownloadDetails)
                let dict = self.arrDownloadDetails[Sender.tag] as DownloadEnitity
                let property_id = dict.id
                let containvideo = dict.contains_Video
                print(containvideo)
                let containbook = dict.contains_Book
                print(containbook)
                if containbook == false && containvideo == false {
                    let a  = self.arrDownloadDetails[Sender.tag] as DownloadEnitity
                    let id = a.id
                    self.select_type_array.add(id)
                    var arrNames = [String]()
                    let swiftArray = self.select_type_array as NSArray as! [Int64]
                    print(swiftArray)
                    
                    self.arrDownloadDetails.filter { (val) -> Bool in
                        if swiftArray.contains(val.id) {
                            let name = val.book_name!
                            arrNames.append(name)
                            return true
                        }
                        return false
                    }
                    print(arrNames)
                    
                    if swiftArray.count != 0 {
                        self.DeleteSelectedID(arrDelete: swiftArray)
                        self.DeleteBookDocumentDirectory(arrFolderNames: arrNames)
                    } else {
                        self.view.makeToast(message: "No book selected")
                    }
                    print("delete video and audio,book")
                }else {
                    var dic = [String:Any]()
                    dic["book_id"] = property_id
                    dic["arr_Audio"] = ""
                    dic["contains_Audio"] = false
                    DownloadEnitity.shared.saveData(dict: dic)
                    self.audiocheck = "No"
                    self.tblMyDownloads.reloadData()
                }
            }))

            
            self.present(myAlert, animated: true, completion: nil)
           //arr_Audio
        }else if readcheck == "yes" && videocheck == "yes" && audiocheck == "No" {
            
            let myAlert = PMAlertController(title: "Holy Reads", description: "Do you permanently want to delete the summary and video?", image: UIImage(named: "welcome_logo"), style: .alert)
            myAlert.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () -> Void in
                print("Cancel")
            }))
            
            myAlert.addAction(PMAlertAction(title: "Yes", style: .default, action: { () in
            print("delete book and video")
           // self.arrDownloadDetails = DownloadEnitity.shared.fetchData()
                print(self.arrDownloadDetails)
                let dict = self.arrDownloadDetails[Sender.tag] as DownloadEnitity
            let property_id = dict.id
            let containvideo = dict.contains_Video
            print(containvideo)
            let containbook = dict.contains_Book
            print(containbook)
            if containbook == true && containvideo == true {
                let a  = self.arrDownloadDetails[Sender.tag] as DownloadEnitity
                let id = a.id
                self.select_type_array.add(id)
                var arrNames = [String]()
                let swiftArray = self.select_type_array as NSArray as! [Int64]
                print(swiftArray)
                
                self.arrDownloadDetails.filter { (val) -> Bool in
                    if swiftArray.contains(val.id) {
                        let name = val.book_name!
                        arrNames.append(name)
                        return true
                    }
                    return false
                }
                print(arrNames)
                
                if swiftArray.count != 0 {
                    self.DeleteSelectedID(arrDelete: swiftArray)
                    self.DeleteBookDocumentDirectory(arrFolderNames: arrNames)
                } else {
                    self.view.makeToast(message: "No book selected")
                }
                print("delete video and audio,book")
            }else {
                var dic = [String:Any]()
                dic["book_id"] = property_id
                dic["contains_Book"] = false
                dic["contains_Video"] = false
                self.videocheck = "No"
                self.readcheck = "No"
                DownloadEnitity.shared.saveData(dict: dic)
                self.lastobsts = "audio"
                self.tblMyDownloads.reloadData()
            }
            }))

            
            self.present(myAlert, animated: true, completion: nil)
            
        }else if readcheck == "yes" && audiocheck == "yes" && videocheck == "No" {
            let myAlert = PMAlertController(title: "Holy Reads", description: "Do you permanently want to delete the summary and audio?", image: UIImage(named: "welcome_logo"), style: .alert)
            myAlert.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () -> Void in
                print("Cancel")
            }))
            
            myAlert.addAction(PMAlertAction(title: "Yes", style: .default, action: { () in
            print("delete book and audio")
            //self.arrDownloadDetails = DownloadEnitity.shared.fetchData()
                print(self.arrDownloadDetails)
                let dict = self.arrDownloadDetails[Sender.tag] as DownloadEnitity
            let property_id = dict.id
            let containaudio = dict.contains_Audio
            print(containaudio)
            let containbook = dict.contains_Book
            print(containbook)
            if containbook == true && containaudio == true {
                let a  = self.arrDownloadDetails[Sender.tag] as DownloadEnitity
                let id = a.id
                self.select_type_array.add(id)
                var arrNames = [String]()
                let swiftArray = self.select_type_array as NSArray as! [Int64]
                print(swiftArray)
                
                self.arrDownloadDetails.filter { (val) -> Bool in
                    if swiftArray.contains(val.id) {
                        let name = val.book_name!
                        arrNames.append(name)
                        return true
                    }
                    return false
                }
                print(arrNames)
                
                if swiftArray.count != 0 {
                    self.DeleteSelectedID(arrDelete: swiftArray)
                    self.DeleteBookDocumentDirectory(arrFolderNames: arrNames)
                } else {
                    self.view.makeToast(message: "No book selected")
                }
                print("delete video and audio,book")
            }else {
                var dic = [String:Any]()
                dic["book_id"] = property_id
                dic["contains_Book"] = false
                dic["arr_Audio"] = ""
                dic["contains_Audio"] = false
                self.readcheck = "No"
                self.audiocheck = "No"
                DownloadEnitity.shared.saveData(dict: dic)
                self.lastobsts = "video"
                self.tblMyDownloads.reloadData()
            }
            }))

            
            self.present(myAlert, animated: true, completion: nil)
            
        }else if  audiocheck == "yes" && videocheck == "yes" && readcheck == "No" {
            let myAlert = PMAlertController(title: "Holy Reads", description: "Do you permanently want to delete the video and audio?", image: UIImage(named: "welcome_logo"), style: .alert)
            myAlert.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () -> Void in
                print("Cancel")
            }))
            
            myAlert.addAction(PMAlertAction(title: "Yes", style: .default, action: { () in
            print("delete video and audio")
          //  self.arrDownloadDetails = DownloadEnitity.shared.fetchData()
                print(self.arrDownloadDetails)
                let dict = self.arrDownloadDetails[Sender.tag] as DownloadEnitity
            let property_id = dict.id
            let containaudio = dict.contains_Audio
            print(containaudio)
            let containvideo = dict.contains_Video
            print(containvideo)
            if containaudio == true && containvideo == true {
                let a  = self.arrDownloadDetails[Sender.tag] as DownloadEnitity
                let id = a.id
                self.select_type_array.add(id)
                var arrNames = [String]()
                let swiftArray = self.select_type_array as NSArray as! [Int64]
                print(swiftArray)
                
                self.arrDownloadDetails.filter { (val) -> Bool in
                    if swiftArray.contains(val.id) {
                        let name = val.book_name!
                        arrNames.append(name)
                        return true
                    }
                    return false
                }
                print(arrNames)
                
                if swiftArray.count != 0 {
                    self.DeleteSelectedID(arrDelete: swiftArray)
                    self.DeleteBookDocumentDirectory(arrFolderNames: arrNames)
                } else {
                    self.view.makeToast(message: "No book selected")
                }
                print("delete video and audio,book")
            }else {
                var dic = [String:Any]()
                dic["book_id"] = property_id
                dic["contains_Video"] = false
                self.videocheck = "No"
                dic["arr_Audio"] = ""
                dic["contains_Audio"] = false
                self.audiocheck = "No"
                DownloadEnitity.shared.saveData(dict: dic)
                self.lastobsts = "book"
                self.tblMyDownloads.reloadData()
            }
            }))

            
            self.present(myAlert, animated: true, completion: nil)
            
        }else if readcheck == "yes" && audiocheck == "yes" && videocheck == "yes"  {
            let myAlert = PMAlertController(title: "Holy Reads", description: "Do you permanently want to delete the summary,audio and video?", image: UIImage(named: "welcome_logo"), style: .alert)
            myAlert.addAction(PMAlertAction(title: "Cancel", style: .cancel, action: { () -> Void in
                print("Cancel")
            }))
            
            myAlert.addAction(PMAlertAction(title: "Yes", style: .default, action: { () in
                let a  = self.arrDownloadDetails[Sender.tag] as DownloadEnitity
            let id = a.id
                self.select_type_array.add(id)
            var arrNames = [String]()
                let swiftArray = self.select_type_array as NSArray as! [Int64]
            print(swiftArray)
            
                self.arrDownloadDetails.filter { (val) -> Bool in
                if swiftArray.contains(val.id) {
                    let name = val.book_name!
                    arrNames.append(name)
                    return true
                }
                return false
            }
            print(arrNames)
            
            if swiftArray.count != 0 {
                self.DeleteSelectedID(arrDelete: swiftArray)
                self.DeleteBookDocumentDirectory(arrFolderNames: arrNames)
            } else {
                self.view.makeToast(message: "No book selected")
            }
            print("delete video and audio,book")
            }))

            
            self.present(myAlert, animated: true, completion: nil)
            
        }else {
            self.view.makeToast(message: "Please choose at least one option to delete the summary, video, and audio.")
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let a  = arrDownloadDetails[indexPath.row] as DownloadEnitity
//        let id = a.id
//        if select_type_array.contains(id) {
//            select_type_array.remove(id)
//            isClick = false
//            self.btnSelectAll.setImage(UIImage(named: "uncheck"), for: .normal)
//        } else {
//            select_type_array.add(id)
//            isClick = true
//            if select_type_array.count == arrDownloadDetails.count {
//                self.btnSelectAll.setImage(UIImage(named: "check"), for: .normal)
//                //self.btnSelectAll.setTitle("  RemoveAll", for: .normal)
//            } else {
//                print("Ashish")
//            }
//        }
//        print(select_type_array)
//        self.tblMyDownloads.reloadData()
//
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
            config.menuTextColor = UIColor.init(red: 85.0/255.0, green: 150.0/255.0, blue: 202.0/255.0, alpha: 1.0)
            config.menuTextColorSelected = UIColor.init(red: 85.0/255.0, green: 150.0/255.0, blue: 202.0/255.0, alpha: 1.0)
            config.quoteCustomLogoImage = UIImage.init(named: "headphones")
            config.shouldHideNavigationOnTap = false
            config.hidePageIndicator = true
            let defaults = UserDefaults.standard
            let dictBookDetails = [String: Any]()
            defaults.set(dictBookDetails, forKey: "VideoData")
            defaults.synchronize()
            let bookPath = Bundle.path(forResource: BookName, ofType: "epub", inDirectory: documentsPathString)
            let folioReader = FolioReader()
            folioReader.presentReader(parentViewController: self, withEpubPath: bookPath!, andConfig: config)
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
