//
//  AVViewController.swift
//  PIXXIDUST
//
//  Created by Tarun Nagar on 28/06/18.
//  Copyright © 2018 Tarun Nagar. All rights reserved.
//

import UIKit
import AVFoundation

class AVViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
var player: AVPlayer?
 @IBOutlet weak var videoViewContainer: UIView!

    var window: UIWindow?
    var navController : UINavigationController?
    var deafults: UserDefaults!
    var Language: String!
    var bookName:String!
    var dictBookDetails = [String: Any]()
    @IBOutlet weak var skipBtn:UIButton!
    @IBOutlet weak var colIntro: UICollectionView!
    @IBOutlet weak var pageIndicator: UIPageControl!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        colIntro.register(UINib(nibName: "ReadSlideCell", bundle: nil), forCellWithReuseIdentifier: "ReadSlideCell")
        pageIndicator.numberOfPages = createIntroSlides().count
        pageIndicator.currentPage = 0
//        deafults = UserDefaults.standard
//        bookName = deafults.value(forKey: "NewBookName") as? String
//        dictBookDetails = UserDefaults.standard.dictionary(forKey: "VideoData")!
//        let jeremyGif = UIImage.gifImageWithName("bookread")
//        let imageView = UIImageView(image: jeremyGif)
//        imageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
//        view.addSubview(imageView)
//        view.addSubview(skipBtn)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.currencyConvert1(_:)), name: NSNotification.Name("closevideo"), object: nil)
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 12.3) {
//            self.move()
//
//        }
   
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        pageIndicator.isHidden = true
    }
    
    //MARK:- Setup Slide Views
    func createIntroSlides() -> [[String : Any]] {
        var slide1 = [String : Any]()
        slide1["image"] = UIImage.init(named: "img02")
        slide1["heading"] = "Here’s a quick tutorial on how to use the “Read” section."
        slide1["pagecount"] = UIImage.init(named: "1 pg")
        slide1["buttonTop"] = "Next"
        
        var slide2 = [String : Any]()
        slide2["image"] = UIImage.init(named: "img021")
        slide2["heading"] = "Select a text to highlight, add notes, or share with a friend."
        slide2["pagecount"] = UIImage.init(named: "2 pg")
        slide2["buttonTop"] = "Next"
        
        var slide3 = [String : Any]()
        slide3["image"] = UIImage.init(named: "img01")
        slide3["heading"] = "Change the color of the selected text or underline it."
        slide3["pagecount"] = UIImage.init(named: "3 pg")
        slide3["buttonTop"] = "Next"
        
        var slide4 = [String : Any]()
        slide4["image"] = UIImage.init(named: "img03")
        slide4["heading"] = "Select a word to look it up in the dictionary."
        slide4["pagecount"] = UIImage.init(named: "4 pg")
        slide4["buttonTop"] = "Got it"
        
        return [slide1, slide2, slide3,slide4]
    }
    
    @objc func currencyConvert1(_ pNotification: Notification?) {
        navigationController?.popViewController(animated: true)
    }
    
    
    //MARK:- Collection View Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return createIntroSlides().count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        pageIndicator.currentPage = indexPath.item
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ReadSlideCell", for: indexPath) as! ReadSlideCell
        
        let dicSlide = createIntroSlides()[indexPath.item]
        cell.imgIntro.image = dicSlide["image"] as? UIImage
        cell.lblHeading.text = dicSlide["heading"] as? String
        cell.imgSelectedPage.image = dicSlide["pagecount"] as? UIImage
        cell.nextBtn.setTitle(dicSlide["buttonTop"] as? String, for: .normal)
        cell.btnSkip.addTarget(self, action: #selector(skipBtnActionNew(_:)), for: .touchUpInside)
        cell.nextBtn.tag = indexPath.item
        cell.nextBtn.addTarget(self, action: #selector(NextBtnNew(_:)), for: .touchUpInside)
        return cell
    }
    
    @objc  func NextBtnNew(_ sender:UIButton) {
        
        if pageIndicator.currentPage == 0{
            for cell in colIntro.visibleCells {
                let indexPath: IndexPath? = colIntro.indexPath(for: cell)
                if ((indexPath?.row)! < createIntroSlides().count + 1){
                    let indexPath1: IndexPath?
                    indexPath1 = IndexPath.init(row: (indexPath?.row)! + 1, section: (indexPath?.section)!)
                    
                    colIntro.scrollToItem(at: indexPath1!, at: .right, animated: true)
                }
                
            }} else if pageIndicator.currentPage == 1{
            for cell in colIntro.visibleCells {
                let indexPath: IndexPath? = colIntro.indexPath(for: cell)
                if ((indexPath?.row)! < createIntroSlides().count + 1){
                    let indexPath1: IndexPath?
                    indexPath1 = IndexPath.init(row: (indexPath?.row)! + 1, section: (indexPath?.section)!)
                    
                    colIntro.scrollToItem(at: indexPath1!, at: .right, animated: true)
                }
                
            }} else if pageIndicator.currentPage == 2{
                for cell in colIntro.visibleCells {
                    let indexPath: IndexPath? = colIntro.indexPath(for: cell)
                    if ((indexPath?.row)! < createIntroSlides().count + 1){
                        let indexPath1: IndexPath?
                        indexPath1 = IndexPath.init(row: (indexPath?.row)! + 1, section: (indexPath?.section)!)
                        
                        colIntro.scrollToItem(at: indexPath1!, at: .right, animated: true)
                    }
                    
                }
            }else {
                UserDefaults.standard.set("LastShow", forKey: "videoSkipped")
                self.Test(BookName: bookName)
            }
    }
   
    @objc  func skipBtnActionNew(_ sender:UIButton) {
        UserDefaults.standard.set("LastShow", forKey: "videoSkipped")
        self.Test(BookName: bookName)
    }
    
    
    @IBAction func skipBtnAction(_ sender:UIButton) {
        UserDefaults.standard.set("LastShow", forKey: "videoSkipped")
        self.Test(BookName: bookName)
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
            //config.menuTextColor = UIColor.init(red: 85.0/255.0, green: 150.0/255.0, blue: 202.0/255.0, alpha: 1.0)
            config.menuTextColor = UIColor.init(red: 32.0/255.0, green: 52.0/255.0, blue: 75.0/255.0, alpha: 1.0)
            config.menuSeparatorColor = UIColor.init(red: 235.0/255.0, green: 237.0/255.0, blue: 239.0/255.0, alpha: 1.0)
            config.menuBackgroundColor = UIColor.init(red: 244.0/255.0, green: 246.0/255.0, blue: 245.0/255.0, alpha: 1.0)
            config.menuTextColorSelected = UIColor.init(red: 85.0/255.0, green: 150.0/255.0, blue: 202.0/255.0, alpha: 1.0)
            config.quoteCustomLogoImage = UIImage.init(named: "headphones")
            config.shouldHideNavigationOnTap = false
            config.hidePageIndicator = true
            
            let bookPath = Bundle.path(forResource: bookName, ofType: "epub", inDirectory: documentsPathString)
            let defaults = UserDefaults.standard
            defaults.set(dictBookDetails, forKey: "VideoData")
            defaults.synchronize()
            //UserDefaults.standard.set(self.dictBookDetails, forKey: "VideoData")
            let folioReader = FolioReader()
            folioReader.presentReader(parentViewController: self, withEpubPath: bookPath!, andConfig: config)
        }
    }
    
    func move() {
        
        deafults = UserDefaults.standard
        let LoginLogOutStatus = deafults.string(forKey: "Logoutstatus") as NSString?
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
