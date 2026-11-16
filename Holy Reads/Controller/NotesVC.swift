//
//  NotesVC.swift
//  Holy Reads
//
//  Created by mac-14 on 03/01/20.
//  Copyright © 2020 Ajeet singh Rawat. All rights reserved.
//

import UIKit
import RealmSwift
import SDWebImage

class NotesVC: UIViewController,UITextViewDelegate {
    
    //MARK:- IBOutlets
    
    @IBOutlet weak var imgBook: UIImageView!
    @IBOutlet weak var lblBookName: UILabel!
    @IBOutlet weak var lblAuthorName: UILabel!
    @IBOutlet weak var lblNoNotesFound: UILabel!
    @IBOutlet weak var tblNotes: UITableView!
    @IBOutlet weak var lblHighlight: UILabel!
    @IBOutlet var viewAddNotes: UIView!
    @IBOutlet weak var addbtn:UIButton!
    @IBOutlet var CloseAddNotesPopUp: UITapGestureRecognizer!
    @IBOutlet weak var txtNote: UITextView!
    // MARK: - Variable
    
    var book_Id = Int()
    var higlightedId = ""
    var dictNotes = [String:Any] ()
    var dictBookDetails = [String:Any] ()
    var arrNotes =  [String]()
    var dicTemp = [String:Any] ()
    var isEditHighlight = false
    var highlight = Highlight()
    private var folioReader = FolioReader()
    private var readerConfig = FolioReaderConfig()

    
    // MARK: - ViewLifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getNotes()
        // Do any additional setup after loading the view.
        txtNote.layer.cornerRadius = 5
        txtNote.layer.borderWidth = 1
        txtNote.text = "Please add your note here."
        txtNote.textColor = UIColor.lightGray
        txtNote.delegate = self
        txtNote.layer.borderColor = UIColor(red: 255/255, green: 142/255, blue: 50/255, alpha: 1.0).cgColor
        CloseAddNotesPopUp = UITapGestureRecognizer(target: self, action: #selector(ClosePopUp))
        viewAddNotes.addGestureRecognizer(CloseAddNotesPopUp)
        self.addbtn.isHidden = true
        self.addbtn.layer.cornerRadius = 5
     }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // as @nhgrif suggested, we can skip the string manipulations if
        // the beginning of the textView.text is not touched.
        guard range.location == 0 else {
            return true
        }

        let newString = (textView.text as NSString).replacingCharacters(in: range, with: text) as NSString
        return newString.rangeOfCharacter(from: NSCharacterSet.whitespacesAndNewlines).location != 0
    }
    
        func textViewDidBeginEditing(_ textView: UITextView) {
            if txtNote.textColor == UIColor.lightGray {
                txtNote.text = ""
                txtNote.textColor = UIColor.black
            }
        }
    
        func textViewDidEndEditing(_ textView: UITextView) {
            if txtNote.text.isEmpty {
                txtNote.text = "Please add your note here."
                txtNote.textColor = UIColor.lightGray
            }
        }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
     @objc func ClosePopUp (_ sender: UITapGestureRecognizer) {
        self.viewAddNotes.removeFromSuperview()
    }
    // MARK: - IBActions
    
    @IBAction func addNotes(_ sender: UIButton) {
        
//        let realm = try! Realm(configuration: readerConfig.realmConfiguration)
//        realm.beginWrite()
//        highlight.noteForHighlight = self.txtNote.text
//        try! realm.commitWrite()
        if txtNote.text == "Please add your note here." || txtNote.text == "" {
            self.view.makeToast(message: "Please enter notes before saving")
        }else {
            saveHighlightNote(HighlightedId: highlight.highlightId, HighlightedText: self.highlight.noteForHighlight ?? "")
            self.dismiss(animated: true, completion: nil)
        }
        
     }
 
    @IBAction func btnClose(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func setNotesDetails () {
        if let bookName = dictNotes["book_title"] as? String {
            self.lblBookName.text = bookName
        }
        if let authorName = dictNotes["author"] as? String {
            self.lblAuthorName.text = authorName
        }
        if let selection = dictNotes["highlight_text"] as? String {
            // let s = ""\(selection)""
            self.lblHighlight.text = "\"\(selection)\""
        }
        
        if let bookThumbnail = dictNotes["cover_image"] as? String {
            self.imgBook.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.imgBook.startAnimating()
            let url = URL.init(string: bookThumbnail)
            self.imgBook.sd_setImage(with: url, placeholderImage: UIImage.init(named: ""), options: .refreshCached, completed: { (img, error, cacheType, url) in
            })
            self.imgBook.stopAnimating()
        }
        //        if let note = dictNotes["notes"] as? [String] {
        //            if note.count == 0 {
        //                self.lblNoNotesFound.isHidden = false
        //                return
        //            } else {
        //                self.lblNoNotesFound.isHidden = true
        //                for i in 0...note.count-1 {
        //                    self.arrNotes.append(note[i])
        //                }
        //                self.tblNotes.reloadData()
        //             }
        //         }
        if let  dictNote = dictNotes["notes"] as? [[String:Any]] {
            if dictNote.count == 0 {
              //  self.lblNoNotesFound.isHidden = false
                self.addbtn.isHidden = false
                return
            } else {
                for i in 0...dictNote.count-1 {
                    if let val = dictNote[i] as? [String:Any]{
                        self.arrNotes.append(val["text"] as? String ?? "")
                    }
                }
                self.tblNotes.reloadData()
            }
        }
 
    }
    
    
    func setBookData(){
        highlight = Highlight()
        let bookid = dictBookDetails["bookId"]
        let content = dictBookDetails["content"]
        let contentPost = dictBookDetails["contentPost"]
        let contentPre = dictBookDetails["contentPre"]
        
        //let date = dictNotes["date"]
        let endOffset = dictBookDetails["endOffset"]
        let highlightId = dictBookDetails["highlightId"]
        let noteForHighlight = dictBookDetails["noteForHighlight"]
        let page = dictBookDetails["page"]
        let startOffset = dictBookDetails["startOffset"]
        let type = dictBookDetails["type"]
        
        
        self.highlight.bookId = bookid as? String ?? ""
        self.highlight.content = content as? String ?? ""
        self.highlight.contentPre = contentPre as? String ?? ""
        //self.highlight.date = "2020-01-20 06:57:07 +0000"
        self.highlight.highlightId = highlightId as? String ?? ""
        self.highlight.page = page as? Int ?? -1
        self.highlight.type = type as? Int ?? -1
        self.highlight.startOffset = startOffset as? Int ?? -1
        self.highlight.endOffset = endOffset as? Int ?? -1
        self.highlight.noteForHighlight = noteForHighlight as? String ?? ""
        
        self.isEditHighlight = true
        if isEditHighlight {
            self.txtNote.text = self.highlight.noteForHighlight!
        }
        
    }
    
    //MARK:- Api Call(Get Notes)
    
    func getNotes() {
        self.view.endEditing(true)
        self.showHud()
        let parameterDictionary = NSMutableDictionary()
        let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        parameterDictionary.setValue(DataManager.getVal(user_id) as! String, forKey: "user_id")
        parameterDictionary.setValue(DataManager.getVal(book_Id) as! String, forKey: "book_id")
        parameterDictionary.setValue(DataManager.getVal(higlightedId) as! String, forKey: "app_id")
        print(parameterDictionary)
        
        let methodName = "getAllNotes"
        
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
            if status == "1" {
                if let response = DataManager.getVal(responseData?["data"]) as? [String: Any] {
                    self.dictNotes = response
                    self.imgBook.isHidden = false
                    self.lblBookName.isHidden = false
                    self.lblAuthorName.isHidden = false
                    self.setNotesDetails()
                 }
                if let BookData = DataManager.getVal(responseData?["ajeet"]) as? [String: Any] {
                    self.dictBookDetails = BookData
                    self.setBookData()
                }
             } else{
                self.view.makeToast(message: message)
            }
            self.clearHud()
        }
    }
   
    @objc func DeleteNote (_ sender : UIButton) {
        if let text = arrNotes[sender.tag] as? String {
        self.DeleteHighlightNote(HighlightedId: self.higlightedId, HighlightedText: text)
            self.arrNotes.remove(at: sender.tag)
        }
     }
    @objc func EditNote (_ sender : UIButton) {
        self.viewAddNotes.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        self.view.addSubview(viewAddNotes)
    }
    
    @IBAction func btnaddnote(_ sender: UIButton) {
        self.viewAddNotes.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        self.view.addSubview(viewAddNotes)
    }
    
    
     //MARK:-  Delete Highlighted Note ApiCall
        
        func DeleteHighlightNote(HighlightedId: String, HighlightedText: String) {
            self.view.endEditing(true)
            self.showHud()
            let parameterDictionary = NSMutableDictionary()
            parameterDictionary.setObject( HighlightedId, forKey: "app_id" as NSCopying)
            parameterDictionary.setObject( HighlightedText, forKey: "text" as NSCopying)
            print(parameterDictionary)

            let methodName = "deleteHighlightNote"
            
            DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
                let status  = DataManager.getVal(responseData?["status"]) as! String
                let message  = DataManager.getVal(responseData?["message"]) as! String
                if status == "1" {
                    self.getNotes()
                    self.tblNotes.reloadData()
                 } else{
                    self.view.makeToast(message: message)
                }
                self.clearHud()
            }
        }
    
    //MARK:-  SaveHighlightTextApiCall
         func saveHighlightNote(HighlightedId: String, HighlightedText: String) {
            self.view.endEditing(true)
            self.showHud()
            let parameterDictionary = NSMutableDictionary()
    //        let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
    //        parameterDictionary.setValue(DataManager.getVal(user_id) as! String, forKey: "user_id")
            parameterDictionary.setObject( highlight.highlightId, forKey: "app_id" as NSCopying)
            parameterDictionary.setObject( self.txtNote.text, forKey: "text" as NSCopying)
            print(parameterDictionary)
     //        "app_id":519,
    //          "text":"This is teh text"
            let methodName = "saveHighlightNote"
            
            DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
                let status  = DataManager.getVal(responseData?["status"]) as! String
                let message  = DataManager.getVal(responseData?["message"]) as! String
                if status == "1" {
                   self.view.makeToast(message: message)
                   NotificationCenter.default.post(name: NSNotification.Name("callnote"), object: nil)
                } else{
                    self.view.makeToast(message: message)
                }
                self.clearHud()
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
extension NotesVC : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrNotes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotesCell", for: indexPath) as! NotesCell
       // cell.lblCount.text = String(indexPath.row + 1)
        cell.lblCount.isHidden = true
        cell.lblNotes.text = arrNotes[indexPath.row]
        if cell.lblNotes.text == "" {
            cell.btnDelete.isHidden = true
            cell.btnEditNote.isHidden = true
            self.tblNotes.isHidden = true
        }else{
            self.tblNotes.isHidden = false
            cell.btnDelete.isHidden = false
            cell.btnEditNote.isHidden = false
            cell.btnDelete.tag = indexPath.row
            cell.btnDelete.addTarget(self, action: #selector(DeleteNote(_:)) , for: .touchUpInside)
            cell.btnEditNote.addTarget(self, action: #selector(EditNote(_:)) , for: .touchUpInside)
        }
        
        

        return cell
    }
    
    //       func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    //           return true
    //       }
    //       func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    //           if editingStyle == .delete {
    //               self.arrNotes.remove(at: indexPath.row)
    //               self.tblNotes.deleteRows(at: [(indexPath)], with: .fade)
    //               self.tblNotes.reloadData()
    //           }
    //       }
    
    
}
