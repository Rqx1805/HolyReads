//
//  FolioReaderAddHighlightNote.swift
//  FolioReaderKit
//
//  Created by ShuichiNagao on 2018/05/06.
//

import UIKit
import RealmSwift
import IQKeyboardManagerSwift
import CoreData
class FolioReaderAddHighlightNote: UIViewController {

    var textView: IQTextView!
    var addedNotesTextView: IQTextView!

    var highlightLabel: UILabel!
    var scrollView: UIScrollView!
    var containerView = UIView()
    var highlight: Highlight!
    var highlightSaved = false
    var isEditHighlight = false
    var resizedTextView = false
    var savebutton:UIButton!
    private var folioReader: FolioReader
    private var readerConfig: FolioReaderConfig
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
    var highnote:String!
    init(withHighlight highlight: Highlight, folioReader: FolioReader, readerConfig: FolioReaderConfig) {
        self.folioReader = folioReader
        self.highlight = highlight
        self.readerConfig = readerConfig
         super.init(nibName: nil, bundle: Bundle.frameworkBundle())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    // MARK: - life cycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.highnote = UserDefaults.standard.value(forKey: "highNote") as? String
        if highnote == "withnote" {
            fetchdatabyidapp()
        }else {
            let typhi = UserDefaults.standard.value(forKey: "TypeHilgh") as? String
            if typhi == "rangy" {
                fetchdatabyid()
            }else {
                fetchdatabyidapp()
            }
            
        }
        
        setCloseButton(withConfiguration: readerConfig)
        prepareScrollView()
        configureTextView()
      //  configureSaveButton()
       // configureShowAddedNotesTextView()
        configureNavBar()
        configureLabel()
        configureKeyboardObserver()
      //  scrollView.isScrollEnabled = false
        self.view.backgroundColor = .white
       // fetchItemRecordFromDB()
        
        //self.getNotes()
    }
    
    func fetchdatabyid() {
        self.rangy = UserDefaults.standard.value(forKey: "appID") as? String
        let appDelegate =   (UIApplication.shared.delegate) as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FolioReaderdatabase")
                request.predicate = NSPredicate(format: "rangy = %@", rangy)
                request.returnsObjectsAsFaults = false
                do {
                    let result = try managedContext.fetch(request)
                    for data in result as! [NSManagedObject] {
                    self.content = data.value(forKey: "content") as? String
                    self.note = data.value(forKey: "note") as? String
                    self.pagenumber = data.value(forKey: "page_number") as? String
                    self.content = data.value(forKey: "content") as? String
                    self.bookid = data.value(forKey: "book_id") as? String
                    self.userid = data.value(forKey: "user_id") as? String
                    self.rangy = data.value(forKey: "rangy") as? String
                    self.app_id = data.value(forKey: "app_id") as? String
                    self.typem = data.value(forKey: "type") as? String
                    self.chaptername = data.value(forKey: "chapter_name") as? String
                        
              }
                    
                } catch {
                    
                    print("Failed")
                }
    }
    
    func fetchdatabyidapp() {
        self.app_id = UserDefaults.standard.value(forKey: "appID") as? String
        let appDelegate =   (UIApplication.shared.delegate) as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FolioReaderdatabase")
        request.predicate = NSPredicate(format: "app_id = %@", self.app_id)
                request.returnsObjectsAsFaults = false
                do {
                    let result = try managedContext.fetch(request)
                    for data in result as! [NSManagedObject] {
                    self.content = data.value(forKey: "content") as? String
                    self.note = data.value(forKey: "note") as? String
                    self.pagenumber = data.value(forKey: "page_number") as? String
                    self.content = data.value(forKey: "content") as? String
                    self.bookid = data.value(forKey: "book_id") as? String
                    self.userid = data.value(forKey: "user_id") as? String
                    self.rangy = data.value(forKey: "rangy") as? String
                    self.app_id = data.value(forKey: "app_id") as? String
                    self.typem = data.value(forKey: "type") as? String
                    self.chaptername = data.value(forKey: "chapter_name") as? String
                        
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
//            for data in resArr {
//                arr_bookList.append(data)
//                print(arr_bookList)
//
//            }
        }catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
       // textView.becomeFirstResponder()
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        scrollView.frame = view.bounds
        containerView.frame = view.bounds
        scrollView.contentSize = view.bounds.size
        containerView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
//        if !highlightSaved && !isEditHighlight {
//            guard let currentPage = folioReader.readerCenter?.currentPage else { return }
//            currentPage.webView?.js("removeThisHighlight()")
//        }
    }
    
    // MARK: - private methods
    
    private func prepareScrollView(){
        scrollView = UIScrollView()
        scrollView.delegate = self as UIScrollViewDelegate
        scrollView.contentSize = CGSize.init(width: view.frame.width, height: view.frame.height )
        scrollView.bounces = false
        scrollView.isScrollEnabled = true
        scrollView.isPagingEnabled = true
        containerView = UIView()
        containerView.backgroundColor = .white
        scrollView.addSubview(containerView)
        view.addSubview(scrollView)
        
        let leftConstraint = NSLayoutConstraint(item: scrollView!, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1.0, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: scrollView!, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1.0, constant: 0)
        let topConstraint = NSLayoutConstraint(item: scrollView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0)
        let botConstraint = NSLayoutConstraint(item: scrollView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        
        view.addConstraints([leftConstraint, rightConstraint, topConstraint, botConstraint])
    }
    
//    private func configureTextView(){
//        textView = IQTextView()
//        textView.delegate = self
//        textView.translatesAutoresizingMaskIntoConstraints = false
//        textView.textColor = .black
//        textView.backgroundColor =  #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.7023758562)
//        textView.font = UIFont.boldSystemFont(ofSize: 15)
//        textView.placeholder = "Add Notes"
//        containerView.addSubview(textView)
//
//        if isEditHighlight {
//             textView.text = highlight.noteForHighlight
//        }
//
//        let leftConstraint = NSLayoutConstraint(item: textView!, attribute: .left, relatedBy: .equal, toItem: containerView, attribute: .left, multiplier: 1.0, constant: 20)
//        let rightConstraint = NSLayoutConstraint(item: textView!, attribute: .right, relatedBy: .equal, toItem: containerView, attribute: .right, multiplier: 1.0, constant: -20)
//        let topConstraint = NSLayoutConstraint(item: textView, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .centerY, multiplier: 1, constant: 0)
//        let heiConstraint = NSLayoutConstraint(item: textView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: view.frame.height)
//        containerView.addConstraints([leftConstraint, rightConstraint, topConstraint, heiConstraint])
//    }
    
    private func configureSaveButton() {
        savebutton = UIButton()
        if (UIDevice.current.userInterfaceIdiom == .pad){
            savebutton.frame = CGRect(x: 210, y: 480, width: 100, height: 40)
        }else {
            savebutton.frame = CGRect(x: 150, y: 568, width: 100, height: 40)
        }

        savebutton.contentMode = .center
       
        savebutton.backgroundColor = UIColor(red: 255/255, green: 142/255, blue: 50/255, alpha: 1.0)
        savebutton.setTitle("Save", for: .normal)
        savebutton.setTitleColor(UIColor.white, for: .normal)
        savebutton.cornerRadius = 5
        savebutton.addTarget(self, action: #selector(SaveButtonAction(_:)), for: .touchUpInside)
        containerView.addSubview(savebutton)
        
//        let leftConstraint = NSLayoutConstraint(item: savebutton!, attribute: .left, relatedBy: .equal, toItem: containerView, attribute: .left, multiplier: 1.0, constant: 20)
//        let rightConstraint = NSLayoutConstraint(item: savebutton!, attribute: .right, relatedBy: .equal, toItem: containerView, attribute: .right, multiplier: 1.0, constant: 20)
//        let topConstraint = NSLayoutConstraint(item: savebutton!, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1, constant: 400)
//        let heiConstraint = NSLayoutConstraint(item: savebutton!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 300)
//        let b = NSLayoutConstraint(item: self.savebutton!, attribute: .bottom,
//                                   relatedBy: .equal, toItem: self.containerView, attribute: .bottom, multiplier: 1.0, constant: 100.0)
//        containerView.addConstraints([leftConstraint, rightConstraint, topConstraint, heiConstraint,b])
    }
    
//    //MARK:- Update Data
//    func updateData() {
//        guard
//        let appDelegate = UIApplication.shared.delegate as? AppDelegate
//        else {
//            return
//        }
//        let managedContext = appDelegate.persistentContainer.viewContext
//        let entity = NSEntityDescription.entity(forEntityName: "FolioReaderdatabase", in : managedContext)
//        let request = NSFetchRequest < NSFetchRequestResult > ()
//        request.entity = entity
//        let predicate = NSPredicate(format: "(app_id = %@)", app_id)
//        request.predicate = predicate
//        do {
//            let results = try managedContext.fetch(request)
//            let objectUpdate = results[0] as!NSManagedObject
//            objectUpdate.setValue(self.bookid, forKey: "book_id")
//            objectUpdate.setValue(self.userid, forKey: "user_id")
//            objectUpdate.setValue(self.content, forKey: "content")
//            objectUpdate.setValue(self.chaptername, forKey: "chapter_name")
//            objectUpdate.setValue(self.rangy, forKey: "rangy")
//            objectUpdate.setValue(self.typem, forKey: "type")
//            objectUpdate.setValue(self.textView.text , forKey: "note")
//            objectUpdate.setValue(self.pagenumber, forKey: "page_number")
//            do {
//                try managedContext.save()
//                print("Record Updated!")
//            } catch
//            let error as NSError {}
//        } catch
//        let error as NSError {}
//    }
    
    func updateMyJobs(app_id: String){
        let bookId = DataManager.getVal(Config().AppUserDefaults.value(forKey: "bookid")) as! String
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FolioReaderdatabase")
        let predicate = NSPredicate(format: "(rangy = %@)", app_id)
        fetchRequest.predicate = predicate
        let result = try? managedContext.fetch(fetchRequest)
        let resultData = result as! [NSManagedObject]
        for object in resultData {
            print(object.value(forKey: "app_id")!)
            object.setValue(self.app_id, forKey: "app_id")
            object.setValue(self.textView.text, forKey: "note")
            object.setValue(self.content, forKey: "content")
            object.setValue(self.chaptername, forKey: "chapter_name")
            object.setValue(self.pagenumber, forKey: "page_number")
            if DataManager.isConnectedToNetwork() {
                object.setValue(self.bookid, forKey: "book_id")
            }else{
                object.setValue(bookId, forKey: "book_id")
            }
            object.setValue(self.userid, forKey: "user_id")
            object.setValue(self.rangy, forKey: "rangy")
            object.setValue(self.typem, forKey: "type")
        }
        do {
            try managedContext.save()
            print("saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func updateMyJobsappid(app_id: String){
        let bookId = DataManager.getVal(Config().AppUserDefaults.value(forKey: "bookid")) as! String
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedContext = appDelegate!.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FolioReaderdatabase")
        let predicate = NSPredicate(format: "(app_id = %@)", app_id)
        fetchRequest.predicate = predicate
        let result = try? managedContext.fetch(fetchRequest)
        let resultData = result as! [NSManagedObject]
        for object in resultData {
            print(object.value(forKey: "app_id")!)
            object.setValue(self.app_id, forKey: "app_id")
            object.setValue(self.textView.text, forKey: "note")
            object.setValue(self.content, forKey: "content")
            object.setValue(self.chaptername, forKey: "chapter_name")
            object.setValue(self.pagenumber, forKey: "page_number")
            if DataManager.isConnectedToNetwork() {
                object.setValue(self.bookid, forKey: "book_id")
            }else{
                object.setValue(bookId, forKey: "book_id")
            }
            
            object.setValue(self.userid, forKey: "user_id")
            object.setValue(self.rangy, forKey: "rangy")
            object.setValue(self.typem, forKey: "type")
        }
        do {
            try managedContext.save()
            print("saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    
    @objc func SaveButtonAction(_ sender:UIButton){
        if checkValidation() {
            if highnote == "withnote" {
                self.updateMyJobsappid(app_id: self.app_id)
            }else {
                self.updateMyJobs(app_id: self.rangy)
            }
            saveHighlightNote(HighlightedId: app_id, HighlightedText: textView.text ?? "")
//            if isEditHighlight {
//                let realm = try! Realm(configuration: readerConfig.realmConfiguration)
//                realm.beginWrite()
//                highlight.noteForHighlight = textView.text
//                highlightSaved = true
//                try! realm.commitWrite()
//                saveHighlightNote(HighlightedId: highlight.highlightId, HighlightedText: highlight.noteForHighlight ?? "")
//             } else {
//                highlight.noteForHighlight = textView.text
//                highlight.persist(withConfiguration: readerConfig)
//                highlightSaved = true
//                saveHighlightNote(HighlightedId: highlight.highlightId, HighlightedText: highlight.noteForHighlight ?? "")
//             }
            dismiss()
        }
    }
    
    private func configureTextView() {
        textView = IQTextView()
        textView.delegate = self
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textColor = .black
        textView.backgroundColor = .clear
        textView.layer.cornerRadius = 5
        textView.layer.borderWidth = 1
        textView.placeholder = "Please add your note here."
        textView.layer.borderColor =  UIColor(red: 255/255, green: 142/255, blue: 50/255, alpha: 1.0).cgColor
        textView.font = UIFont.boldSystemFont(ofSize: 15)
        containerView.addSubview(textView)
        textView.text = self.note
        
//        if isEditHighlight {
//             //textView.text = highlight.noteForHighlight
//            textView.text = self.note
//            
//        }
        
        if (UIDevice.current.userInterfaceIdiom == .pad){
            let leftConstraint = NSLayoutConstraint(item: textView!, attribute: .left, relatedBy: .equal, toItem: containerView, attribute: .left, multiplier: 1.0, constant: 20)
           let rightConstraint = NSLayoutConstraint(item: textView!, attribute: .right, relatedBy: .equal, toItem: containerView, attribute: .right, multiplier: 1.0, constant: -20)
           let topConstraint = NSLayoutConstraint(item: textView, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1, constant: 200)
          // let heiConstraint = NSLayoutConstraint(item: textView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: view.frame.height - 100) Comment by Ashish
           let heiConstraint = NSLayoutConstraint(item: textView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 250)
           containerView.addConstraints([leftConstraint, rightConstraint, topConstraint, heiConstraint])
        }else {
            let leftConstraint = NSLayoutConstraint(item: textView!, attribute: .left, relatedBy: .equal, toItem: containerView, attribute: .left, multiplier: 1.0, constant: 20)
           let rightConstraint = NSLayoutConstraint(item: textView!, attribute: .right, relatedBy: .equal, toItem: containerView, attribute: .right, multiplier: 1.0, constant: -20)
           let topConstraint = NSLayoutConstraint(item: textView, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1, constant: 220)
          // let heiConstraint = NSLayoutConstraint(item: textView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: view.frame.height - 100) Comment by Ashish
           let heiConstraint = NSLayoutConstraint(item: textView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 250)
           containerView.addConstraints([leftConstraint, rightConstraint, topConstraint, heiConstraint])
        }
        
        
    }
    
     private func configureLabel() {
        highlightLabel = UILabel()
        highlightLabel.translatesAutoresizingMaskIntoConstraints = false
        highlightLabel.numberOfLines = 0
        highlightLabel.font = UIFont(name: "Andada-Italic", size: 15)
        //highlightLabel.font = UIFont.systemFont(ofSize: 15)
       // highlightLabel.text = highlight.content.stripHtml().truncate(250, trailing: "...").stripLineBreaks()
        if content == nil || content == ""{
            highlightLabel.text = "No Highlight Found"
            self.textView.isHidden = true
            self.savebutton.isHidden = true
        }else{
            highlightLabel.text = content
            self.textView.isHidden = false
            self.savebutton.isHidden = false
        }
      
        
        containerView.addSubview(self.highlightLabel!)
        
        if (UIDevice.current.userInterfaceIdiom == .pad){
            let leftConstraint = NSLayoutConstraint(item: highlightLabel!, attribute: .left, relatedBy: .equal, toItem: containerView, attribute: .left, multiplier: 1.0, constant: 20)
            let rightConstraint = NSLayoutConstraint(item: highlightLabel!, attribute: .right, relatedBy: .equal, toItem: containerView, attribute: .right, multiplier: 1.0, constant: -20)
            let topConstraint = NSLayoutConstraint(item: highlightLabel, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1, constant: 10)
            let heiConstraint = NSLayoutConstraint(item: highlightLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 180)
            
            containerView.addConstraints([leftConstraint, rightConstraint, topConstraint, heiConstraint])
        }else {
            let leftConstraint = NSLayoutConstraint(item: highlightLabel!, attribute: .left, relatedBy: .equal, toItem: containerView, attribute: .left, multiplier: 1.0, constant: 20)
            let rightConstraint = NSLayoutConstraint(item: highlightLabel!, attribute: .right, relatedBy: .equal, toItem: containerView, attribute: .right, multiplier: 1.0, constant: -20)
            let topConstraint = NSLayoutConstraint(item: highlightLabel, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1, constant: 10)
            let heiConstraint = NSLayoutConstraint(item: highlightLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 200)
            
            containerView.addConstraints([leftConstraint, rightConstraint, topConstraint, heiConstraint])
        }
        
        
    }
    private func configureShowAddedNotesTextView() {
        
        addedNotesTextView = IQTextView()
        addedNotesTextView.delegate = self
        addedNotesTextView.translatesAutoresizingMaskIntoConstraints = false
        addedNotesTextView.textColor = .black
        addedNotesTextView.backgroundColor = .clear
        addedNotesTextView.font = UIFont.boldSystemFont(ofSize: 15)
        addedNotesTextView.isScrollEnabled = true
        addedNotesTextView.isEditable = false
        addedNotesTextView.isSelectable = true
        containerView.addSubview(addedNotesTextView)
        addedNotesTextView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.7023758562)
       
       
        let leftConstraint = NSLayoutConstraint(item: addedNotesTextView!, attribute: .left, relatedBy: .equal, toItem: containerView, attribute: .left, multiplier: 1.0, constant: 20)
        let rightConstraint = NSLayoutConstraint(item: addedNotesTextView!, attribute: .right, relatedBy: .equal, toItem: containerView, attribute: .right, multiplier: 1.0, constant: -20)
        let topConstraint = NSLayoutConstraint(item: addedNotesTextView, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1, constant: 100)
        let heiConstraint = NSLayoutConstraint(item: addedNotesTextView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: screenHeight/2-160)
        containerView.addConstraints([leftConstraint, rightConstraint, topConstraint, heiConstraint])
    }
    
    private func configureNavBar() {
        let navBackground = folioReader.isNight(self.readerConfig.nightModeNavBackground, self.readerConfig.daysModeNavBackground)
        let tintColor = readerConfig.tintColor
        let navText = folioReader.isNight(UIColor.white, UIColor.black)
        let font = UIFont(name: "Avenir-Light", size: 17)!
        setTranslucentNavigation(false, color: navBackground, tintColor: tintColor, titleColor: navText, andFont: font)
        
       // let titleAttrs = [NSAttributedString.Key.foregroundColor: readerConfig.tintColor]
       // let saveButton = UIBarButtonItem(title: readerConfig.localizedSave, style: .plain, target: self, action: #selector(saveNote(_:)))
        savebutton = UIButton()
        savebutton.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        savebutton.contentMode = .center
       
        savebutton.backgroundColor = UIColor(red: 255/255, green: 142/255, blue: 50/255, alpha: 1.0)
        savebutton.setTitle("Save", for: .normal)
        savebutton.setTitleColor(UIColor.white, for: .normal)
        savebutton.cornerRadius = 5
        savebutton.addTarget(self, action: #selector(SaveButtonAction(_:)), for: .touchUpInside)
      //  saveButton.setTitleTextAttributes(titleAttrs, for: UIControl.State())
        let rightBarButton = UIBarButtonItem(customView: savebutton)

        navigationItem.rightBarButtonItem = rightBarButton // Comment by ashish
    }
    
    private func configureKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        //give room at the bottom of the scroll view, so it doesn't cover up anything the user needs to tap
        var userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.scrollView.contentInset
        contentInset.bottom = keyboardFrame.size.height
        self.scrollView.contentInset = contentInset
    }
    
    @objc private func keyboardWillHide(notification:NSNotification){
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        self.scrollView.contentInset = contentInset
    }
    func checkValidation() -> Bool {
        if textView.text == "" {
            self.view.makeToast(message: "Please enter notes before saving")
            return false
        }
//        else if textView.text.count > 250 {
//          self.view.makeToast(message: "Notes count must be less than 250 characters.")
//            return false
//        }
        else {
            return true
        }
        
    }
    
    @objc private func saveNote(_ sender: UIBarButtonItem) {
        if checkValidation() {
            if highnote == "withnote" {
                self.updateMyJobsappid(app_id: self.app_id)
            }else {
                self.updateMyJobs(app_id: self.rangy)
            }
            saveHighlightNote(HighlightedId: app_id, HighlightedText: textView.text ?? "")
            dismiss()
        }
        
        
//        if checkValidation() {
//            if isEditHighlight {
//                let realm = try! Realm(configuration: readerConfig.realmConfiguration)
//                realm.beginWrite()
//                highlight.noteForHighlight = textView.text
//                highlightSaved = true
//                try! realm.commitWrite()
//                saveHighlightNote(HighlightedId: highlight.highlightId, HighlightedText: highlight.noteForHighlight ?? "")
//             } else {
//                highlight.noteForHighlight = textView.text
//                highlight.persist(withConfiguration: readerConfig)
//                highlightSaved = true
//                saveHighlightNote(HighlightedId: highlight.highlightId, HighlightedText: highlight.noteForHighlight ?? "")
//             }
//            dismiss()
//        } Ashish
         
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

// MARK: - UITextViewDelegate
extension FolioReaderAddHighlightNote: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // as @nhgrif suggested, we can skip the string manipulations if
        // the beginning of the textView.text is not touched.
        guard range.location == 0 else {
            return true
        }

        let newString = (textView.text as NSString).replacingCharacters(in: range, with: text) as NSString
        return newString.rangeOfCharacter(from: NSCharacterSet.whitespacesAndNewlines).location != 0
    }
    
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        if textView.textColor == UIColor.lightGray {
//            textView.text = ""
//            textView.textColor = UIColor.black
//        }
//    }
//    
//    func textViewDidEndEditing(_ textView: UITextView) {
//        if textView.text.isEmpty {
//            textView.text = "Here's a note i wanted to add."
//            textView.textColor = UIColor.lightGray
//        }
//    }
    
//    func textViewDidChange(_ textView: UITextView) {
//        let fixedWidth = textView.frame.size.width
//        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
//        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
//        var newFrame = textView.frame
//        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height + 15)
//        textView.frame = newFrame;
//    }
//    
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        textView.frame.size.height = textView.frame.height + 30
//
//        if resizedTextView {
//            scrollView.scrollRectToVisible(textView.frame, animated: true)
//        }
//        else{
//            resizedTextView = true
//        }
//        return true
//    }
}
