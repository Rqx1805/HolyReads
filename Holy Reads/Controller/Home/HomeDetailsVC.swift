//
//  HomeDetailsVC.swift
//  Holy Reads
//
//  Created by mac-14 on 06/01/20.
//  Copyright © 2020 Ajeet singh Rawat. All rights reserved.
//

import UIKit
import SDWebImage

class HomeDetailsVC: UIViewController {
    
    var arrCompletedBooks = [[String:Any]]()
    // MARK: - IBOutlet
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var CategoryDetailedCollectionView: UICollectionView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var lblNoData: UILabel!
    
    // MARK: - Variable
    var arrCategoryDetailedBooks = [[String:Any]]()
    var Tittle = ""
    var apiMethod = ""
    let refreshControl = UIRefreshControl()
    var BookIdArray = [Int]()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshControl.addTarget(self, action:  #selector(sortArray), for: .valueChanged)
        self.CategoryDetailedCollectionView.addSubview(refreshControl)
        // Do any additional setup after loading the view.
        let LibariryLayOut = UICollectionViewFlowLayout()
        LibariryLayOut.itemSize = CGSize(width: screenWidth/2 - 40, height: 304)
        LibariryLayOut.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 10)
        LibariryLayOut.minimumInteritemSpacing = 10
        LibariryLayOut.minimumLineSpacing = 10
        LibariryLayOut.scrollDirection = .vertical
        
        CategoryDetailedCollectionView.collectionViewLayout = LibariryLayOut
        self.lblTitle.text = Tittle
    }
    override func viewWillAppear(_ animated: Bool) {
        self.getHighlightBookListingApiCall()
    }
    
    @objc func sortArray() {
          self.getHighlightBookListingApiCall()
    }
    
    
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getHighlightBookListingApiCall() {
        self.showHud()
        let parameterDictionary = NSMutableDictionary()
        let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        parameterDictionary.setValue(user_id, forKey: "user_id")
        parameterDictionary.setValue(apiMethod, forKey: "type")
        
        let methodName = "getPerticularHomeData"
        
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
            if status == "1" {
                if let response = DataManager.getVal(responseData?["data"]) as? [[String:Any]] {
                    self.arrCategoryDetailedBooks = response
                    if self.arrCategoryDetailedBooks.count  == 0 {
                        self.lblNoData.isHidden = false
                    }
                    else {
                        self.lblNoData.isHidden = true
                    }
                    self.CategoryDetailedCollectionView.reloadData()
                }
            } else {
                self.view.makeToast(message: message)
            }
            self.clearHud()
            self.refreshControl.endRefreshing()
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
// MARK: - UICollectionViewDelegate
extension HomeDetailsVC : UICollectionViewDelegate, UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrCategoryDetailedBooks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteCell", for: indexPath) as! FavoriteCell
        cell.tag = indexPath.row
        cell.layer.cornerRadius = 8
        let dict = arrCategoryDetailedBooks[indexPath.row] as [String:Any]
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
        //  cell.btnLike.tag = indexPath.row
        //cell.btnLike.addTarget(self, action:#selector(markBookFav) , for: .touchUpInside)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // selectedCell = indexPath.row
        if let dict = DataManager.getVal(self.arrCategoryDetailedBooks[indexPath.row]) as? [String:Any]{
            if let bookId = dict["book_id"] as? Int{
                let obj = self.storyboard?.instantiateViewController(withIdentifier: "DiscoverDetailsVC") as! DiscoverDetailsVC
                obj.bookId = bookId
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
                self.navigationController?.pushViewController(obj, animated: false)
            }
        }
    }
}
