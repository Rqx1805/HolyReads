//
//  Discover_IpadVC.swift
//  Holy Reads
//
//  Created by Ashish Soni on 20/07/20.
//  Copyright © 2020 Ajeet singh Rawat. All rights reserved.
//

import UIKit
import SDWebImage
import IQKeyboardManagerSwift
import CoreData
class Discover_IpadVC: UIViewController, UITableViewDataSource, UITableViewDelegate,UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    
    // MARK: - IBOutlet
    @IBOutlet weak var lblCategoryTitle: UILabel!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var tblDiscover: UITableView!
    @IBOutlet weak var CategoriesCollectionView: UICollectionView!
    // @IBOutlet weak var lblSelectedCategoryTitle: UILabel!
    @IBOutlet weak var lblNoBookFound: UILabel!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var tblDiscoverHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var scroll_view: UIScrollView!
    // MARK: - Variable
    
    var arrBooksCategories = [[String:Any]]()
    var arrCategorizedBooksList = [[String:Any]]()
    var categoryId = String()
    var arrSearch = [[String:Any]]()
    var newString = ""
    var searched = false
    var selectedIndex = 0
    var setIndexToZero = Bool()
    let refreshControl = UIRefreshControl()
    var BookIdArray = [Int]()
    // MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        refreshControl.addTarget(self, action:  #selector(sortArray), for: .valueChanged)
        self.scroll_view.addSubview(refreshControl)
        setIndexToZero = true
        self.tblDiscover.rowHeight = UITableView.automaticDimension
        self.tblDiscover.estimatedRowHeight = 60
        
        let CategoriesLiberaryLayOut = UICollectionViewFlowLayout()
        CategoriesLiberaryLayOut.itemSize = CGSize(width: screenWidth/4.6, height: 150)
        CategoriesLiberaryLayOut.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        CategoriesLiberaryLayOut.minimumInteritemSpacing = 0
        CategoriesLiberaryLayOut.minimumLineSpacing = 2
        CategoriesLiberaryLayOut.scrollDirection = .horizontal
        CategoriesCollectionView.collectionViewLayout = CategoriesLiberaryLayOut
        
    }
    @objc func sortArray() {
        if selectedIndex == 0 {
           self.getCategorisedBookData(categoryID: "0")
        } else {
            let s = String(selectedIndex)
            self.getCategorisedBookData(categoryID: s)
        }
    }
    // MARK: - ViewWillAppear
    
    override func viewWillAppear(_ animated: Bool) {
        // IQKeyboardManager.shared.enableAutoToolbar = false
        if setIndexToZero {
            selectedIndex = UserDefaults.standard.value(forKey: "SelectedCategory") as? Int ?? 0
            // selectedIndex = UserDefaults.standard.value(forKey: "SelectedCategory") as? Int ?? 0
        } else {
            //           UserDefaults.standard.set(0, forKey: "SelectedCategory")
            //        selectedIndex = UserDefaults.standard.value(forKey: "SelectedCategory") as? Int ?? 0
        }
        
        if arrBooksCategories.count != 0 {
            self.CategoriesCollectionView.scrollToItem(at:IndexPath(item: selectedIndex, section: 0), at: .centeredHorizontally, animated: false)
        }
        self.getCategoriesData()
        if selectedIndex == 0 {
            self.getCategorisedBookData(categoryID: "0")
        } else {
            let s = String(selectedIndex)
            self.getCategorisedBookData(categoryID: s)
        }
        if DataManager.isConnectedToNetwork() != true {
            self.view.makeToast(message: "No Internet Connection.")
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
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    override func viewDidLayoutSubviews () {
        super.viewDidLayoutSubviews()
        if arrBooksCategories.count != 0 {
            self.CategoriesCollectionView.scrollToItem(at:IndexPath(item: selectedIndex, section: 0), at: .centeredHorizontally, animated: false)
        }
        
    }
    // MARK: - IBAction
    
    @IBAction func btnSearch_DidSelect(_ sender: UIButton) {
        self.getSeachBook()
    }
    
    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrBooksCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Category_IpadCell", for: indexPath) as! Category_IpadCell
        cell.layer.cornerRadius = 8
        if indexPath.row ==  selectedIndex {
            cell.viewBackground.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 0.3115903253)
            //            cell.layer.borderWidth = 2
            //            cell.layer.borderColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        } else{
            cell.viewBackground.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            //            cell.layer.borderWidth = 1
            //            cell.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
        if arrBooksCategories.count != 0 {
            if let dict = arrBooksCategories[indexPath.row] as? [String:AnyObject] {
                if let title =  dict["title"] as? String{
                   // cell.lblTitle.text = title
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.hyphenationFactor = 1.0
                    paragraphStyle.alignment = .center
                    let attributedString = NSMutableAttributedString(string: title, attributes: [
                        NSAttributedString.Key.paragraphStyle: paragraphStyle
                    ])
                    
                    cell.lblTitle?.attributedText = attributedString
                }
                if let bookThumbnail =  dict["thumbnail_image"] as? String {
                    cell.imgBookThumbnail.sd_imageIndicator = SDWebImageActivityIndicator.gray
                    cell.imgBookThumbnail.startAnimating()
                    let url = URL.init(string: bookThumbnail)
                    cell.imgBookThumbnail.sd_setImage(with: url, placeholderImage: UIImage.init(named: ""), options: .refreshCached, completed: { (img, error, cacheType, url) in
                    })
                    cell.imgBookThumbnail.stopAnimating()
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
       // self.txtSearch.text = ""
        UserDefaults.standard.set(selectedIndex, forKey: "SelectedCategory")
        if let dict = DataManager.getVal(self.arrBooksCategories[indexPath.row]) as? [String:Any]{
            if let title = dict["title"] as? String{
                self.lblCategoryTitle.text = title
            }
            if let categoryId = dict["category_id"] as? Int{
                self.categoryId = String(categoryId)
                self.getCategorisedBookData(categoryID: self.categoryId)
            }else {
                 self.categoryId = ""
                 self.getCategorisedBookData(categoryID: self.categoryId)
                
            }
        }
        collectionView.reloadData()
        //        let obj = self.storyboard?.instantiateViewController(withIdentifier: "DiscoverDetailsVC") as! DiscoverDetailsVC
        //        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searched == true {
            return self.arrSearch.count
        } else{
            return self.arrCategorizedBooksList.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Psychology_IpadCell", for: indexPath) as! Psychology_IpadCell
        if self.arrCategorizedBooksList.count != 0 {
            if let dict = arrCategorizedBooksList[indexPath.row] as? [String:AnyObject] {
                //                    let height = cell.bounds.height
                //                    print(height)
                self.tblDiscover.isHidden = false
                self.lblNoBookFound.isHidden = true
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
//                    let strOne =  description.replacingOccurrences(of: "<p>", with: "")
//                    let strTwo = strOne.replacingOccurrences(of: "</p>", with: "\n")
                    let htmlData2 = NSString(string: description).data(using: String.Encoding.utf8.rawValue)
                    let options2 = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
                    let attributedString2 = try! NSAttributedString(data: htmlData2!,
                                                                   options: options2,
                                                                   documentAttributes: nil)

                    let perfectcode2 = attributedString2.string
                    cell.lblDescription.text = perfectcode2
                }
            }
        } else{
            self.tblDiscover.reloadData()
            self.tblDiscover.isHidden = true
            self.lblNoBookFound.isHidden = false
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let dict = DataManager.getVal(self.arrCategorizedBooksList[indexPath.row]) as? [String:Any]{
            if let bookId = dict["book_id"] as? Int{
                let obj = UIStoryboard(name: "MainStoryboard_iPad", bundle: nil).instantiateViewController(withIdentifier: "DiscoverDetail_IpadVC") as! DiscoverDetail_IpadVC
                setIndexToZero = true
                obj.bookId = bookId
                var idarr =  UserDefaults.standard.array(forKey: "BookIdAr")  as? [Int]
                if idarr == nil || idarr?.count == 0 {
                    if BookIdArray.count >= 5 {
                        print("Ashish Jai")
                    }else{
                        BookIdArray.append(bookId)
                    }
                    
                    let bookaryy = self.BookIdArray.uniqued()
                    obj.BookIdNewArray = bookaryy
                    let defaults = UserDefaults.standard
                    defaults.setValue(bookaryy, forKey: "BookIdAr")
                    defaults.synchronize()
                }else{
                    if idarr!.count >= 5 {
                        print("Ashish Jai")
                    }else{
                        idarr!.append(bookId)
                    }
                    let bookaryy = idarr!.uniqued()
                    obj.BookIdNewArray = bookaryy
                    let defaults = UserDefaults.standard
                    defaults.setValue(bookaryy, forKey: "BookIdAr")
                    defaults.synchronize()
                }
                self.navigationController?.pushViewController(obj, animated: true)
            }
        }
    }
    
    //    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    //      let editAction = UITableViewRowAction(style: .normal, title: "") { (rowAction, indexPath) in
    //          print("edit clicked")
    //
    //       }
    ////        let img: UIImage = UIImage.init(named: "Del")!   //#imageLiteral(resourceName: "Delete-1")
    ////        let imgSize: CGSize = tableView.frame.size
    ////        UIGraphicsBeginImageContext(imgSize)
    ////        img.draw(in: CGRect(x: 10, y: 40, width: 60, height: 60))
    ////        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    ////        UIGraphicsEndImageContext()
    ////        editAction.backgroundColor = UIColor(patternImage: newImage)
    //
    //
    //      return [editAction]
    //    }
    
    // MARK: - Textfield Delegate
    
    //    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    //
    //        if textField == txtSearch{
    //            self.newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
    //            arrSearch = arrCategorizedBooksList.filter{(object) -> Bool in
    //                if let allBook = object as? [String:Any] {
    //                    if let filtered = allBook["book_title"] as? String {
    //                        return filtered.lowercased().contains(newString)
    //                    }
    //                }
    //                return false
    //            }
    //            if newString == ""{
    //                searched = false
    //            } else{
    //                searched = true
    //            }
    //            tblDiscover.reloadData()
    //            print("SearchedArray\(arrSearch)")
    //            print("SearchedArrayCount\(arrSearch.count)")
    //            // getSeachBook()
    //        }
    //        return true
    //    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.view.endEditing(true)
        if textField == self.txtSearch {
            self.getSeachBook()
        }
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        if textField == self.txtSearch {
            self.getSeachBook()
        }
        return true
    }
    
    
    // MARK: - API CALLING (Book Category Type )
    func getCategoriesData(){
        self.showHud()
        let parameterDictionary = NSMutableDictionary()
        let methodName = "getBookCategories"
        
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
            
            if status == "1" {
                var response = DataManager.getVal(responseData?["data"]) as! [[String: Any]]
                let dict = ["category_id":"0","thumbnail_image":"https://devnode.devtechnosys.tech/holyreads/webroot/front/img/book@3x.png","title":"All Summaries"]
                response.insert(dict, at: 0)
                self.arrBooksCategories = response
                if let dict = self.arrBooksCategories[self.selectedIndex] as? [String:Any] {
                    if let title =  dict["title"] as? String{
                        self.lblCategoryTitle.text = title
                    }
                }
                self.CategoriesCollectionView.reloadData()
            } else{
                self.view.makeToast(message: message)
            }
            self.clearHud()
        }
    }
    
    // MARK: - API CALLING (Book Categorised Book Data)
    func getCategorisedBookData(categoryID: String){
        self.showHud()
        let parameterDictionary = NSMutableDictionary()
        parameterDictionary.setValue(categoryID, forKey: "category_id")
        let methodName = "getBooksAccCategories"
        
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message = DataManager.getVal(responseData?["message"]) as! String
            self.arrCategorizedBooksList.removeAll()
            if status == "1" {
                let response = DataManager.getVal(responseData?["data"]) as! [[String: Any]]
                self.arrCategorizedBooksList = response
                let count = self.arrCategorizedBooksList.count
                let height = CGFloat(180 * count )
                self.tblDiscoverHeightConstraint.constant = height
                self.tblDiscover.reloadData()
                let newoff = UserDefaults.standard.value(forKey: "OF") as? String
                if newoff == "off" {
                    self.fetchItemRecordFromDB()
                }else {
                    print("Ashish")
                }
            } else{
                self.tblDiscover.reloadData()
                self.tblDiscover.isHidden = true
                self.lblNoBookFound.isHidden = false
                self.view.makeToast(message: message)
            }
            self.refreshControl.endRefreshing()
            self.clearHud()
        }
    }
    
    // MARK: - API CALLING (Search Book)
    func getSeachBook() {
        self.showHud()
        self.view.endEditing(true)
        let parameterDictionary = NSMutableDictionary()
        var searchResult:String!
        searchResult = txtSearch.text
        var finalseach:String!
        finalseach = searchResult.trimmingCharacters(in: .whitespacesAndNewlines)
        parameterDictionary.setValue(finalseach, forKey: "search")
        if categoryId == ""{
            parameterDictionary.setValue("0", forKey: "category_id")
        }else{
           // parameterDictionary.setValue(categoryId, forKey: "category_id")
            parameterDictionary.setValue("0", forKey: "category_id")
        }
        let methodName = "searchResults"
        
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message = DataManager.getVal(responseData?["message"]) as! String
            self.arrCategorizedBooksList.removeAll()
            if status == "1" {
                let response = DataManager.getVal(responseData?["data"]) as! [[String: Any]]
                self.arrCategorizedBooksList = response
                self.selectedIndex = 0
                self.getCategoriesData()
                self.tblDiscover.reloadData()
                let count = self.arrCategorizedBooksList.count
                let height = CGFloat(180 * count )
                self.tblDiscoverHeightConstraint.constant = height
            } else{
                self.tblDiscover.reloadData()
                self.tblDiscover.isHidden = true
                self.lblNoBookFound.isHidden = false
              //  self.view.makeToast(message: message)
                self.tblDiscoverHeightConstraint.constant = 0
            }
            self.clearHud()
        }
    }
}





