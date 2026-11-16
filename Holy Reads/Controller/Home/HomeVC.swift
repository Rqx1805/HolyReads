//
//  HomeVC.swift
//  Holy Reads
//
//  Created by mac-14 on 30/08/19.
//  Copyright © 2019 Ajeet singh Rawat. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import SDWebImage
import Alamofire
import AdSupport
import PMAlertController
import CoreData
class HomeVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
 
    // MARK: - IBOutlet
    
   // @IBOutlet weak var VideoCollectionView: UICollectionView!
    @IBOutlet weak var DailyBreedCollectionView: UICollectionView!
    @IBOutlet weak var CategoriesCollectionView: UICollectionView!
    @IBOutlet weak var RecommendedCollectionView: UICollectionView!
    @IBOutlet weak var CuratedCollectionView: UICollectionView!
    @IBOutlet weak var MostPopularCollectionView: UICollectionView!
    @IBOutlet weak var LatestCollectionView: UICollectionView!
    @IBOutlet weak var viewRecommenedHeight: NSLayoutConstraint!
    @IBOutlet weak var lblRecommendedHeight: NSLayoutConstraint!
    @IBOutlet weak var btnViewAllRecommended: UIButton!
    @IBOutlet weak var lblNotificationCount: UILabel!
 
    @IBOutlet weak var viewNotifiaction: UIView!
    @IBOutlet weak var scroll_View: UIScrollView!
    // MARK: - Variable
    let identifierManager = ASIdentifierManager.shared()
    var arrDailyBreed = [[String:Any]] ()
    var arrBooksCategories = [[String:Any]] ()
    var arrBooksRecommended = [[String:Any]] ()
    var arrCuratedBookList = [[String:Any]] ()
    var arrLatestBook = [[String:Any]] ()
    var arrMostPopularBook = [[String:Any]] ()
    let refreshControl = UIRefreshControl()
    var deviceId:String!
    var BookIdArray = [Int]()
     // MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.tabBarController?.delegate = self
        self.viewNotifiaction.isHidden = true
        refreshControl.addTarget(self, action:  #selector(sortArray), for: .valueChanged)
        self.scroll_View.addSubview(refreshControl)
        
        self.createThumbnailOfVideoFromRemoteUrl(url: "http://i.devtechnosys.tech:8083/holyreads/webroot/summary/video/1568703681_summary_.mp4")
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        let LiberaryLayOut = UICollectionViewFlowLayout()
        LiberaryLayOut.itemSize = CGSize(width: screenWidth/1.2, height: 167)
        LiberaryLayOut.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        LiberaryLayOut.minimumInteritemSpacing = 0
        LiberaryLayOut.minimumLineSpacing = 2
        LiberaryLayOut.scrollDirection = .horizontal
        DailyBreedCollectionView.collectionViewLayout = LiberaryLayOut
        
        let CategoriesLiberaryLayOut = UICollectionViewFlowLayout()
        CategoriesLiberaryLayOut.itemSize = CGSize(width: screenWidth/3.3, height: 150)
        CategoriesLiberaryLayOut.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        CategoriesLiberaryLayOut.minimumInteritemSpacing = 0
        CategoriesLiberaryLayOut.minimumLineSpacing = 2
        CategoriesLiberaryLayOut.scrollDirection = .horizontal
        CategoriesCollectionView.collectionViewLayout = CategoriesLiberaryLayOut

        let RecommendedLiberaryLayOut = UICollectionViewFlowLayout()
        RecommendedLiberaryLayOut.itemSize = CGSize(width: screenWidth/2.6, height: 275)
        RecommendedLiberaryLayOut.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        RecommendedLiberaryLayOut.minimumInteritemSpacing = 0
        RecommendedLiberaryLayOut.minimumLineSpacing = 0
        RecommendedLiberaryLayOut.scrollDirection = .horizontal
        RecommendedCollectionView.collectionViewLayout = RecommendedLiberaryLayOut
        
        let CuratedLiberaryLayOut = UICollectionViewFlowLayout()
        CuratedLiberaryLayOut.itemSize = CGSize(width: screenWidth/1.2, height: 285)
        CuratedLiberaryLayOut.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        CuratedLiberaryLayOut.minimumInteritemSpacing = 0
        CuratedLiberaryLayOut.minimumLineSpacing = 2
        CuratedLiberaryLayOut.scrollDirection = .horizontal
        CuratedCollectionView.collectionViewLayout = CuratedLiberaryLayOut
     
        let MostPopularLiberaryLayOut = UICollectionViewFlowLayout()
        MostPopularLiberaryLayOut.itemSize = CGSize(width: screenWidth/2.6, height: 275)
        MostPopularLiberaryLayOut.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        MostPopularLiberaryLayOut.minimumInteritemSpacing = 0
        MostPopularLiberaryLayOut.minimumLineSpacing = 0
        MostPopularLiberaryLayOut.scrollDirection = .horizontal
        MostPopularCollectionView.collectionViewLayout = MostPopularLiberaryLayOut
        
        let LatestLiberaryLayOut = UICollectionViewFlowLayout()
        LatestLiberaryLayOut.itemSize = CGSize(width: screenWidth/2.6, height: 275)
        LatestLiberaryLayOut.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        LatestLiberaryLayOut.minimumInteritemSpacing = 0
        LatestLiberaryLayOut.minimumLineSpacing = 0
        LatestLiberaryLayOut.scrollDirection = .horizontal
        LatestCollectionView.collectionViewLayout = LatestLiberaryLayOut
        
    
    }
    
    @objc func sortArray() {
        if DataManager.isConnectedToNetwork() {
            self.scroll_View.isHidden = false
            self.getHomeData()
        }else {
            self.scroll_View.isHidden = true
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
            UserDefaults.standard.removeObject(forKey: "OF")
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
            UserDefaults.standard.removeObject(forKey: "OF")
              //self.view.makeToast(message: message)
           } else{
              // self.view.makeToast(message: message)
           }
       }
       
   }
    
    // MARK: - ViewWillAppear

    override func viewWillAppear(_ animated: Bool) {
        deviceId = UserDefaults.standard.value(forKey: "Devicetoken") as? String
        self.RecommendedCollectionView.delegate = self
        self.RecommendedCollectionView.dataSource = self
        
        if DataManager.isConnectedToNetwork() {
            self.scroll_View.isHidden = false
            self.getHomeData()
        }else {
            self.scroll_View.isHidden = true
            let nextview = EditNotView.intitiateFromNib()
            let model = BackModel()
            nextview.buttonDoneHandler = {
                let obj = self.storyboard?.instantiateViewController(withIdentifier: "MyDownloadsVC") as! MyDownloadsVC
                self.navigationController?.pushViewController(obj, animated: true)
                model.closewithAnimation()
                
            }
            nextview.buttonCancelHandler = {
                model.closewithAnimation()
            }
            model.show(view: nextview)
//            let alert = UIAlertController(title: "Holy Reads", message: "No Internet Connection Available. Check “My Download” section to access your downloaded content offline.", preferredStyle: UIAlertController.Style.alert)
//
//            let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction!) in
//                let obj = self.storyboard?.instantiateViewController(withIdentifier: "MyDownloadsVC") as! MyDownloadsVC
//                self.navigationController?.pushViewController(obj, animated: true)
//                        // Code in this block will trigger when OK button tapped.
//                print("Ok button tapped");
//
//            }
//            alert.addAction(OKAction)
//
//                    // Create Cancel button
//            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction!) in
//                print("Cancel button tapped");
//            }
//            alert.addAction(cancelAction)
//            self.present(alert, animated: true, completion: nil)
           // self.view.makeToast(message: "The Internet connection appears to be offline. ")
        }
       // self.getHomeData()
        
        if arrDailyBreed.count != 0 {
            self.DailyBreedCollectionView.scrollToItem(at:IndexPath(item: 0, section: 0), at: .right, animated: false)
        }
        if arrBooksCategories.count != 0 {
            self.CategoriesCollectionView.scrollToItem(at:IndexPath(item: 0, section: 0), at: .right, animated: false)
        }
        if arrBooksRecommended.count != 0 {
            self.RecommendedCollectionView.scrollToItem(at:IndexPath(item: 0, section: 0), at: .right, animated: false)
        }
        if arrCuratedBookList.count != 0 {
            self.CuratedCollectionView.scrollToItem(at:IndexPath(item: 0, section: 0), at: .right, animated: false)
        }
        if arrMostPopularBook.count != 0 {
            self.MostPopularCollectionView.scrollToItem(at:IndexPath(item: 0, section: 0), at: .right, animated: false)
        }
        if arrLatestBook.count != 0 {
            self.LatestCollectionView.scrollToItem(at:IndexPath(item: 0, section: 0), at: .right, animated: false)
        }
        
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: "HomeVC")
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
        
        
    }
 
    // MARK: - NavigationBar Buttons
    
    @IBAction func btnNotification_DidSelect(_ sender: UIButton) {
        let obj = self.storyboard?.instantiateViewController(withIdentifier: "NotificationVC") as! NotificationVC
         
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    // MARK: - IBAction
    @IBAction func btnViewAllCategories(_ sender: UIButton) {
        let obj = self.storyboard?.instantiateViewController(withIdentifier: "tabbar") as! UITabBarController
        obj.selectedIndex = 1
        self.navigationController?.pushViewController(obj, animated: true)
        
//        if let navController = self.tabBarController?.viewControllers?[1] as? UINavigationController{
//            if let testController = navController.children.first as? DiscoverVC{
//                testController.selectedIndex = 0
//                self.tabBarController?.selectedIndex = 1
//            }
//        }
    }
    
    @IBAction func btnViewAllRecommended(_ sender: UIButton) {
        let obj = self.storyboard?.instantiateViewController(withIdentifier: "HomeDetailsVC") as! HomeDetailsVC
        obj.Tittle = "Recommended"
        obj.apiMethod = "recommended"
        self.navigationController?.pushViewController(obj, animated: true)
    }
    
    @IBAction func btnViewAllMost_Popular(_ sender: UIButton) {
        let obj = self.storyboard?.instantiateViewController(withIdentifier: "HomeDetailsVC") as! HomeDetailsVC
        obj.Tittle = "Most Popular"
        obj.apiMethod = "most_popular"
        self.navigationController?.pushViewController(obj, animated: true)
    }
 
    @IBAction func btnViewAllLatest(_ sender: UIButton) {
        let obj = self.storyboard?.instantiateViewController(withIdentifier: "HomeDetailsVC") as! HomeDetailsVC
        obj.Tittle = "Latest"
        obj.apiMethod = "new_added"
        self.navigationController?.pushViewController(obj, animated: true)        
    }
    
     // MARK: - UICollectionViewDelegate
   func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
          if collectionView == CategoriesCollectionView {
              return arrBooksCategories.count
          } else if collectionView == CuratedCollectionView  {
              return arrCuratedBookList.count
          } else if collectionView == RecommendedCollectionView  {
              return arrBooksRecommended.count
          } else if collectionView == LatestCollectionView  {
              return arrLatestBook.count
          } else if collectionView == MostPopularCollectionView  {
              return arrMostPopularBook.count
          } else {
            return arrDailyBreed.count
          }
      }
      
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == DailyBreedCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as! VideoCell
            let dict = arrDailyBreed[indexPath.row]
            if let bookThumbnail =  dict["banner_image"] as? String {
                cell.VideoImgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                cell.VideoImgView.startAnimating()
                let url = URL.init(string: bookThumbnail)
                cell.VideoImgView.sd_setImage(with: url, placeholderImage: UIImage.init(named: ""), options: .refreshCached, completed: { (img, error, cacheType, url) in
                })
                cell.VideoImgView.stopAnimating()
            }
            // cell.layer.borderWidth = 0.1
             //cell.layer.borderColor = #colorLiteral(red: 0.8901960784, green: 0.9098039216, blue: 0.9176470588, alpha: 1)
             //cell.layer.cornerRadius = 8
            return cell
        } else if collectionView == RecommendedCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecommendedCell", for: indexPath) as! RecommendedCell
           // cell.layer.borderWidth = 1
           // cell.layer.borderColor = #colorLiteral(red: 0.8901960784, green: 0.9098039216, blue: 0.9176470588, alpha: 1)
           // cell.layer.cornerRadius = 8
            if let dict = self.arrBooksRecommended[indexPath.row] as? [String:Any] {
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
//                     let strOne =  description.replacingOccurrences(of: "<p>", with: "")
//                     let strTwo = strOne.replacingOccurrences(of: "</p>", with: "\n")
//                     cell.lblDescription.text = strTwo
                    
                    let htmlData = NSString(string: description).data(using: String.Encoding.utf8.rawValue)
                    let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
                    let attributedString = try! NSAttributedString(data: htmlData!,
                                                                   options: options,
                                                                   documentAttributes: nil)

                    let perfectcode = attributedString.string
                    cell.lblDescription.text = perfectcode
                }
            }
            return cell
        }
    
//        else if collectionView == RecommendedCollectionView {
//            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecommendedCell", for: indexPath) as! RecommendedCell
//            cell.layer.borderWidth = 1
//            cell.layer.borderColor = #colorLiteral(red: 0.8901960784, green: 0.9098039216, blue: 0.9176470588, alpha: 1)
//            cell.layer.cornerRadius = 8
//            return cell
//        }
        
        else if collectionView == CategoriesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
//            cell.layer.borderWidth = 1
//            cell.layer.borderColor = #colorLiteral(red: 0.8901960784, green: 0.9098039216, blue: 0.9176470588, alpha: 1)
//            cell.layer.cornerRadius = 8
            if let dict = arrBooksCategories[indexPath.row] as? [String:Any] {
                if let title =  dict["title"] as? String {
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.hyphenationFactor = 0.2
                    paragraphStyle.alignment = .center
                    let attributedString = NSMutableAttributedString(string: title, attributes: [
                        NSAttributedString.Key.paragraphStyle: paragraphStyle
                    ])
                    
                    cell.lblTitle?.attributedText = attributedString
                    //cell.lblTitle.text = title
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
            return cell
        } else if collectionView == CuratedCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CuratedCell", for: indexPath) as! CuratedCell
          //  cell.layer.cornerRadius = 8
            cell.btnNext.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
            cell.btnPrevious.addTarget(self, action: #selector(previousButtonTapped), for: .touchUpInside)
            if let dict = arrCuratedBookList[indexPath.row] as? [String:Any] {
                // To hide Arrows of left & right
                if indexPath.row + 1 == arrCuratedBookList.count {
                    cell.btnNext.isHidden = true
                } else {
                    cell.btnNext.isHidden = true
                }
                if indexPath.row == 0 {
                    cell.btnPrevious.isHidden = true
                } else {
                    cell.btnPrevious.isHidden = true
                }
                if let title =  dict["title"] as? String{
                    cell.lblBookTitle.text = title
                }
                // Setting Data
                
                if let bookThumbnail =  dict["banner_image"] as? String {
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
                
                if let description =  dict["short_description"] as? String{
                    let strOne =  description.replacingOccurrences(of: "<p>", with: "")
                    let strTwo = strOne.replacingOccurrences(of: "</p>", with: "\n")
                    cell.lblDescription.text = strTwo
                }
//                if let description =  dict["short_description"] as? String{
//                     cell.lblDescription.text = description
//                }
            }
            return cell
        } else if collectionView == MostPopularCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecommendedCell", for: indexPath) as! RecommendedCell
         //   cell.layer.borderWidth = 1
          //  cell.layer.borderColor = #colorLiteral(red: 0.8901960784, green: 0.9098039216, blue: 0.9176470588, alpha: 1)
          //  cell.layer.cornerRadius = 8
            
            if let dict = arrMostPopularBook[indexPath.row] as? [String:Any] {
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
//                     let strOne =  description.replacingOccurrences(of: "<p>", with: "")
//                     let strTwo = strOne.replacingOccurrences(of: "</p>", with: "\n")
//                     cell.lblDescription.text = strTwo
                    
                    let htmlData = NSString(string: description).data(using: String.Encoding.utf8.rawValue)
                    let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
                    let attributedString = try! NSAttributedString(data: htmlData!,
                                                                   options: options,
                                                                   documentAttributes: nil)

                    let perfectcode = attributedString.string
                    cell.lblDescription.text = perfectcode
                }
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecommendedCell", for: indexPath) as! RecommendedCell
//            cell.layer.cornerRadius = 8
//            cell.layer.borderWidth = 1
//            cell.layer.borderColor = #colorLiteral(red: 0.8901960784, green: 0.9098039216, blue: 0.9176470588, alpha: 1)
            
            if let dict = arrLatestBook[indexPath.row] as? [String:Any] {
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
//                    cell.lblDescription.text = strTwo
                    
                    let htmlData = NSString(string: description).data(using: String.Encoding.utf8.rawValue)
                    let options = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
                    let attributedString = try! NSAttributedString(data: htmlData!,
                                                                   options: options,
                                                                   documentAttributes: nil)

                    let perfectcode = attributedString.string
                    cell.lblDescription.text = perfectcode
                }
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == DailyBreedCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as! VideoCell
            cell.player.play()
        }
    }
 
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var book_id = Int()
        if collectionView == CategoriesCollectionView {
//             if let navController = self.tabBarController?.viewControllers?[1] as? UINavigationController {
//                if let testController = navController.children.first as? DiscoverVC {
//                    testController.selectedIndex = indexPath.item
//                    self.tabBarController?.selectedIndex = 1
//                    }
//            }
            UserDefaults.standard.set(indexPath.item, forKey: "SelectedCategory")
             let obj = self.storyboard?.instantiateViewController(withIdentifier: "tabbar") as! UITabBarController
            obj.selectedIndex = 1
            self.navigationController?.pushViewController(obj, animated: true)
//        }
        }
        if collectionView == RecommendedCollectionView{
                if let dict = DataManager.getVal(self.arrBooksRecommended[indexPath.row]) as? [String:Any]{
                    if let bookId = dict["book_id"] as? Int{
                        book_id  = bookId
                        let obj = self.storyboard?.instantiateViewController(withIdentifier: "DiscoverDetailsVC") as! DiscoverDetailsVC
                        obj.bookId = book_id
                        
                        if BookIdArray.count >= 5 {
                            print("Ashish Jai")
                        }else{
                            BookIdArray.append(book_id)
                        }
                        
                        let bookaryy = self.BookIdArray.uniqued()
                        obj.BookIdNewArray = bookaryy
                        let defaults = UserDefaults.standard
                        defaults.setValue(bookaryy, forKey: "BookIdAr")
                        defaults.synchronize()
                        self.navigationController?.pushViewController(obj, animated: false)
                    }
                }
            
            
           
        }
        if collectionView == CuratedCollectionView {
            if let dict = DataManager.getVal(self.arrCuratedBookList[indexPath.row]) as? [String:Any]{
                let obj = self.storyboard?.instantiateViewController(withIdentifier: "CuratedListVC") as! CuratedListVC
                obj.dictCuratedList = dict
                self.navigationController?.pushViewController(obj, animated: true)
            }
        }
        
        if collectionView == MostPopularCollectionView {
            if let dict = DataManager.getVal(self.arrMostPopularBook[indexPath.row]) as? [String:Any]{
                if let bookId = dict["book_id"] as? Int{
                    book_id  = bookId
                    let obj = self.storyboard?.instantiateViewController(withIdentifier: "DiscoverDetailsVC") as! DiscoverDetailsVC
                    obj.bookId = book_id
                    if BookIdArray.count >= 5 {
                        print("Ashish Jai")
                    }else{
                        BookIdArray.append(book_id)
                    }
                    
                    let bookaryy = self.BookIdArray.uniqued()
                    obj.BookIdNewArray = bookaryy
                    let defaults = UserDefaults.standard
                    defaults.setValue(bookaryy, forKey: "BookIdAr")
                    defaults.synchronize()
                     self.navigationController?.pushViewController(obj, animated: true)
                }
            }
        }
         if collectionView == LatestCollectionView{
            if let dict = DataManager.getVal(self.arrLatestBook[indexPath.row]) as? [String:Any]{
                if let bookId = dict["book_id"] as? Int{
                    book_id  = bookId
                    let obj = self.storyboard?.instantiateViewController(withIdentifier: "DiscoverDetailsVC") as! DiscoverDetailsVC
                    obj.bookId = book_id
                    if BookIdArray.count >= 5 {
                        print("Ashish Jai")
                    }else{
                        BookIdArray.append(book_id)
                    }
                    
                    let bookaryy = self.BookIdArray.uniqued()
                    obj.BookIdNewArray = bookaryy
                    let defaults = UserDefaults.standard
                    defaults.setValue(bookaryy, forKey: "BookIdAr")
                    defaults.synchronize()
                    self.navigationController?.pushViewController(obj, animated: false)
                }
            }
        }
        else if collectionView == DailyBreedCollectionView {
         if let dict = DataManager.getVal(self.arrDailyBreed[indexPath.row]) as? [String:Any]{
            if let bookId = dict["id"] as? Int{
                let obj = self.storyboard?.instantiateViewController(withIdentifier: "DailyBreedDetailsVC") as! DailyBreedDetailsVC
                obj.dictDailyBreed = dict
                self.navigationController?.pushViewController(obj, animated: false)
            }
        }
    }
    }
     
    
    //        if collectionView == CategoriesCollectionView{
    //            if let dict = DataManager.getVal(self.arrBooksCategories[indexPath.row]) as? [String:Any]{
    //                if let bookId = dict["category_id"] as? Int{
    //                    book_id  = bookId
    //                    let obj = self.storyboard?.instantiateViewController(withIdentifier: "DiscoverDetailsVC") as! DiscoverDetailsVC
    //                    obj.bookId = book_id
    //                    self.navigationController?.pushViewController(obj, animated: true)
    //                }
    //            }
    //        }
    
    //    }
    
    @objc func nextButtonTapped(_ sender : UIButton) {
        let visibleItems: NSArray = self.CuratedCollectionView.indexPathsForVisibleItems as NSArray
        let currentItem: IndexPath = visibleItems.object(at: 0) as! IndexPath
        let nextItem: IndexPath = IndexPath(item: currentItem.item + 1, section: 0)
        if nextItem.row < arrCuratedBookList.count {
            self.CuratedCollectionView.scrollToItem(at: nextItem, at: .left, animated: true)
        }
    }
    @objc func previousButtonTapped(_ sender : UIButton) {
        let visibleItems: NSArray = self.CuratedCollectionView.indexPathsForVisibleItems as NSArray
        let currentItem: IndexPath = visibleItems.object(at: 0) as! IndexPath
        let nextItem: IndexPath = IndexPath(item: currentItem.item - 1, section: 0)
        if nextItem.row < arrCuratedBookList.count && nextItem.row >= 0{
            self.CuratedCollectionView.scrollToItem(at: nextItem, at: .right, animated: true)
        }
    }
    
    func createThumbnailOfVideoFromRemoteUrl(url: String) -> UIImage? {
        let asset = AVAsset(url: URL(string:url )!)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        //Can set this to improve performance if target size is known before hand
        //assetImgGenerate.maximumSize = CGSize(width,height)
        let time = CMTimeMakeWithSeconds(1.0, preferredTimescale: 600)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    
    func LogoutAPI() {
        let parameterDictionary = NSMutableDictionary()
        let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        let deviceiD = self.identifierManager.advertisingIdentifier.uuidString
        parameterDictionary.setValue(DataManager.getVal(user_id) as! String, forKey: "user_id")
        parameterDictionary.setValue(DataManager.getVal(deviceiD) as! String, forKey: "phone_device_id")
        print(parameterDictionary)
        
        let methodName = "logout"
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
            if status == "1" {
                DataManager.ClearUserDetails()
                self.appDelegate.showFirstPage()
            } else{
                //self.view.makeToast(message: message)
            }
        }
    }
    
    // MARK: - Home API CALLING
    
    func getHomeData() {
        //self.showHud()
        self.showHud1()
        let parameterDictionary = NSMutableDictionary()
        let methodName = "getHomeData"
        let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        parameterDictionary.setValue(user_id, forKey: "user_id")
        
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
            let notificationCount  = DataManager.getVal(responseData?["notification_count"]) as? String ?? "0"
            let free_trial_status  = DataManager.getVal(responseData?["free_trial_status"]) as? String ?? "0"
            let subscribed_status  = DataManager.getVal(responseData?["subscribed_status"]) as? String ?? "0"
            var deviceArray = [String]()
            deviceArray  = DataManager.getVal(responseData?["devices_logged_in"]) as! [String]
            let defaults = UserDefaults.standard
            defaults.setValue(free_trial_status, forKey: "FREESTS")
            defaults.setValue(subscribed_status, forKey: "SUBSTS")
            defaults.synchronize()
            if status == "1" {
                let response = DataManager.getVal(responseData?["data"]) as! [String: Any]
                let deviceid = response["device_id"] as? String
                let deviceiD = self.identifierManager.advertisingIdentifier.uuidString
                    if deviceArray.contains(deviceiD) {
                        print("Ashish")
                    }else {
                        self.LogoutAPI()
                    }
//                if deviceid == self.deviceId {
//                    print("Ashish")
//                }else {
//                    self.LogoutAPI()
//                }
                if var categories = response["categories"] as? [[String:Any]] {
                    let dict = ["category_id":"0","thumbnail_image":"https://devnode.devtechnosys.tech/holyreads/webroot/front/img/book@3x.png","title":"All Summaries"]
                    categories.insert(dict, at: 0)
                    self.arrBooksCategories = categories
                    self.CategoriesCollectionView.reloadData()
                }
                if let recommended = response["recommended"] as? [[String:Any]] {
                    self.arrBooksRecommended = recommended
                    if self.arrBooksRecommended.count == 0 {
                        self.viewRecommenedHeight.constant = 0
                        self.lblRecommendedHeight.constant = 0
                        self.btnViewAllRecommended.isHidden = true
                        self.RecommendedCollectionView.reloadData()
                    } else {
                        self.viewRecommenedHeight.constant = 275
                        self.lblRecommendedHeight.constant = 29.5
                        self.btnViewAllRecommended.isHidden = false
                        self.RecommendedCollectionView.reloadData()
                    }
                 }
                if let curatedList = response["curated_list"] as? [[String:Any]] {
                    self.arrCuratedBookList = curatedList
                    self.CuratedCollectionView.reloadData()
                }
                if let latest = response["latest"] as? [[String:Any]] {
                    self.arrLatestBook = latest
                    self.LatestCollectionView.reloadData()
                }
                if let mostPopular = response["most_popular"] as? [[String:Any]] {
                    self.arrMostPopularBook = mostPopular
                    self.MostPopularCollectionView.reloadData()
                 }
                if let dailyBreed = response["daily_breed"] as? [[String:Any]] {
                    self.arrDailyBreed = dailyBreed
                    self.DailyBreedCollectionView.reloadData()
                   
                }
                
                if notificationCount == "0" {
                    self.viewNotifiaction.isHidden = true
                } else {
                    self.viewNotifiaction.isHidden = false
                    self.lblNotificationCount.text = notificationCount
                }
                let newoff = UserDefaults.standard.value(forKey: "OF") as? String
                if newoff == "off" {
                    self.fetchItemRecordFromDB()
                }else {
                    print("Ashish")
                }
            } else{
                self.view.makeToast(message: message)
            }
            self.refreshControl.endRefreshing()
            self.clearHud()
        }
    }
}




extension Sequence where Element: Hashable {
    func uniqued() -> [Element] {
        var set = Set<Element>()
        return filter { set.insert($0).inserted }
    }
}




