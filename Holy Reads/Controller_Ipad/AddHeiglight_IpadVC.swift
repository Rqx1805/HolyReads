//
//  AddHeiglight_IpadVC.swift
//  Holy Reads
//
//  Created by Ashish Soni on 20/07/20.
//  Copyright © 2020 Ajeet singh Rawat. All rights reserved.
//

import UIKit
import RealmSwift
import IQKeyboardManagerSwift

class AddHeiglight_IpadVC: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var btnAddNotes: UIButton!
    
    @IBOutlet weak var lblHighlight: UILabel!
    
    @IBOutlet weak var txtAddNotes: UITextView!
    
    
    var textView: IQTextView!
    var addedNotesTextView: IQTextView!
    var highlightLabel: UILabel!
    var scrollView: UIScrollView!
    var containerView = UIView()
    var highlight: Highlight!
    var highlightSaved = false
    var isEditHighlight = false
    var resizedTextView = false
    
    private var folioReader = FolioReader()
    private var readerConfig = FolioReaderConfig()
    
    
    // MARK: - life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setCloseButton(withConfiguration: readerConfig)
        // prepareScrollView()
        configureTextView()
        // configureShowAddedNotesTextView()
        // configureLabel()
        //  configureNavBar()
        //  configureKeyboardObserver()
        //self.getNotes()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
//        if !highlightSaved && !isEditHighlight {
//            guard let currentPage = folioReader.readerCenter?.currentPage else { return }
//            currentPage.webView?.js("removeThisHighlight()")
//        }
    }
    
    @IBAction func Save(_ sender: Any) {
        let realm = try! Realm(configuration: readerConfig.realmConfiguration)
        realm.beginWrite()
        highlight.noteForHighlight = "Ajeet"
        highlightSaved = true
        try! realm.commitWrite()
        saveHighlightNote(HighlightedId: highlight.highlightId, HighlightedText: "highlight.noteForHighlight" ?? "")
    }
    
    
    private func configureTextView(){
        txtAddNotes = IQTextView()
        txtAddNotes.delegate = self
        txtAddNotes.translatesAutoresizingMaskIntoConstraints = false
        txtAddNotes.textColor = .black
        txtAddNotes.backgroundColor = .clear
        txtAddNotes.font = UIFont.boldSystemFont(ofSize: 15)
        if isEditHighlight {
            lblHighlight.text = highlight.noteForHighlight!
        }
    }
    
    @objc private func saveNote(_ sender: UIBarButtonItem) {
        if !txtAddNotes.text.isEmpty {
            if isEditHighlight {
                let realm = try! Realm(configuration: readerConfig.realmConfiguration)
                realm.beginWrite()
                highlight.noteForHighlight = txtAddNotes.text
                highlightSaved = true
                try! realm.commitWrite()
                saveHighlightNote(HighlightedId: highlight.highlightId, HighlightedText: highlight.noteForHighlight ?? "")
            } else {
                highlight.noteForHighlight = txtAddNotes.text
                highlight.persist(withConfiguration: readerConfig)
                highlightSaved = true
                saveHighlightNote(HighlightedId: highlight.highlightId, HighlightedText: highlight.noteForHighlight ?? "")
            }
        }
        dismiss()
    }
    //MARK:-  SaveHighlightTextApiCall
    func saveHighlightNote(HighlightedId: String, HighlightedText: String) {
        self.view.endEditing(true)
        self.showHud()
        let parameterDictionary = NSMutableDictionary()
        //        let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        //        parameterDictionary.setValue(DataManager.getVal(user_id) as! String, forKey: "user_id")
        parameterDictionary.setObject( HighlightedId, forKey: "app_id" as NSCopying)
        parameterDictionary.setObject( HighlightedText, forKey: "text" as NSCopying)
        print(parameterDictionary)
        //        "app_id":519,
        //               "text":"This is teh text"
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
    //MARK:- Api Call(Get Notes)
    
    func getNotes() {
        self.view.endEditing(true)
        self.showHud()
        let parameterDictionary = NSMutableDictionary()
        let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        let book_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "book_id")) as! String
        
        parameterDictionary.setValue(DataManager.getVal(user_id) as! String, forKey: "user_id")
        parameterDictionary.setValue(DataManager.getVal(book_id) as! String, forKey: "book_id")
        parameterDictionary.setValue(DataManager.getVal(highlight.highlightId) as! String, forKey: "app_id")
        print(parameterDictionary)
        
        let methodName = "getAllNotes"
        
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
            if status == "1" {
                if let response = DataManager.getVal(responseData?["data"]) as? [String: Any] {
                    if let note = response["notes"] as? [String]{
                        if note.count == 0 {
                            self.clearHud()
                            self.addedNotesTextView.text = "No notes found"
                            return
                        } else {
                            var arrNotes = [String]()
                            for i in 0...note.count-1 {
                                arrNotes.append(note[i])
                            }
                            let stringRepresentation =  arrNotes.joined(separator: "\n\n\n")
                            self.addedNotesTextView.text = stringRepresentation
                            print(stringRepresentation)
                        }
                    }
                    // self.setNotesDetails()
                }
            } else{
                self.addedNotesTextView.text = "No notes found"
                // self.view.makeToast(message: message)
            }
            self.clearHud()
        }
    }
}
