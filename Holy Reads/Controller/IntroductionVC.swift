//
//  IntroductionVC.swift
//  Holy Reads
//
//  Created by mac-14 on 04/09/19.
//  Copyright © 2019 Ajeet singh Rawat. All rights reserved.
//

import UIKit

class IntroductionVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    //MARK:- Outlets
    @IBOutlet weak var colIntro: UICollectionView!
    @IBOutlet weak var pageIndicator: UIPageControl!
    
    //MARK:- Variabels

    //MARK:- View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        colIntro.register(UINib(nibName: "SlideCell", bundle: nil), forCellWithReuseIdentifier: "SlideCell")
        pageIndicator.numberOfPages = createIntroSlides().count
        pageIndicator.currentPage = 0
        
    }
    // MARK: - ViewWillAppear

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
        pageIndicator.isHidden = true
    }
    
    //MARK:- Setup Slide Views
    func createIntroSlides() -> [[String : Any]] {
        var slide1 = [String : Any]()
        slide1["image"] = UIImage.init(named: "Walkthrough1")
        slide1["heading"] = "Life-changing summaries in under 20 minutes"
        slide1["content"] = "Discover a world of new ideas from a host of Christian authors"
        slide1["pagecount"] = UIImage.init(named: "pg1")
        slide1["buttonTop"] = "NEXT"
        slide1["buttonBottom"] = "Skip"
        
        var slide2 = [String : Any]()
        slide2["image"] = UIImage.init(named: "Walkthrough2")
        slide2["heading"] = "Listen to the essentials"
        slide2["content"] = "Relax while hearing the crucial ideas you need to succeed in the Christian life"
        slide2["pagecount"] = UIImage.init(named: "pg2")
        slide2["buttonTop"] = "NEXT"
        slide2["buttonBottom"] = "Skip"
        
        var slide3 = [String : Any]()
        slide3["image"] = UIImage.init(named: "Walkthrough3")
        slide3["heading"] = "Watch the big ideas"
        slide3["content"] = "Visual learning through video summaries illuminates complex concepts and helps you remember them later"
        slide3["pagecount"] = UIImage.init(named: "pg3")
        slide3["buttonTop"] = "SIGN UP"
        slide3["buttonBottom"] = "Skip"
        
        return [slide1, slide2, slide3]
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SlideCell", for: indexPath) as! SlideCell
        
        let dicSlide = createIntroSlides()[indexPath.item]
        cell.imgIntro.image = dicSlide["image"] as? UIImage
        cell.lblHeading.text = dicSlide["heading"] as? String
        cell.lblContent.text = dicSlide["content"] as? String
        cell.imgSelectedPage.image = dicSlide["pagecount"] as? UIImage
        cell.btnNext.setTitle(dicSlide["buttonTop"] as? String, for: .normal)
        if indexPath.item == 0 {
           cell.btnSkip.setTitleColor(UIColor(red: 32/255, green: 52/255, blue: 75/255, alpha: 1), for: .normal)
            cell.btnSkip.isHidden = false
            cell.signBtn.isHidden = true
        }else if indexPath.item == 1
        {
         cell.btnSkip.setTitleColor(UIColor(red: 32/255, green: 52/255, blue: 75/255, alpha: 1), for: .normal)
            cell.btnSkip.isHidden = false
            cell.signBtn.isHidden = true
        }else {
          cell.btnSkip.setTitleColor(UIColor(red: 254/255, green: 153/255, blue: 37/255, alpha: 1), for: .normal)
            cell.btnSkip.isHidden = true
            cell.signBtn.isHidden = false
        }
        cell.signBtn.tag = indexPath.item
        cell.btnSkip.setTitle(dicSlide["buttonBottom"]as? String, for: .normal)
        cell.btnNext.addTarget(self, action: #selector(actionBtnNext(_:)), for: .touchUpInside)
        cell.btnSkip.addTarget(self, action: #selector(actionBtnSkip(_:)), for: .touchUpInside)
        cell.signBtn.addTarget(self, action: #selector(actionBtnSkip1(_:)), for: .touchUpInside)
        return cell
    }
    
    //MARK:- Button Action Methods
    @objc func actionBtnSkip(_ sender: UIButton) {
        if pageIndicator.currentPage == 0{
        let objVC = self.storyboard?.instantiateViewController(withIdentifier: "WelcomeVC") as! WelcomeVC
        self.navigationController?.pushViewController(objVC, animated: true)
        }else if pageIndicator.currentPage == 1{
            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "WelcomeVC") as! WelcomeVC
            self.navigationController?.pushViewController(objVC, animated: true)
        }else {
            let obj = self.storyboard?.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
            self.navigationController?.pushViewController(obj, animated: true)
            UserDefaults.standard.set(true, forKey: "isIntroSkipped")
            UserDefaults.standard.synchronize()
        }
//          /  appDelegate.showMain()
//        } else if pageIndicator.currentPage == 1{
//            for cell in colIntro.visibleCells {
//                let indexPath: IndexPath? = colIntro.indexPath(for: cell)
//                if ((indexPath?.row)! < createIntroSlides().count + 1){
//                    let indexPath1: IndexPath?
//                    indexPath1 = IndexPath.init(row: (indexPath?.row)! - 1, section: (indexPath?.section)!)
//
//                    colIntro.scrollToItem(at: indexPath1!, at: .right, animated: true)
//                }
//
//            }} else if pageIndicator.currentPage == 2{
//            for cell in colIntro.visibleCells {
//                let indexPath: IndexPath? = colIntro.indexPath(for: cell)
//                if ((indexPath?.row)! < createIntroSlides().count + 1){
//                    let indexPath1: IndexPath?
//                    indexPath1 = IndexPath.init(row: (indexPath?.row)! - 1, section: (indexPath?.section)!)
//
//                    colIntro.scrollToItem(at: indexPath1!, at: .right, animated: true)
//                }
//
//            }}
//        }
        
    }
    
    //MARK:- Button Action Methods
    @objc func actionBtnSkip1(_ sender: UIButton) {
        if pageIndicator.currentPage == 0{
            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "WelcomeVC") as! WelcomeVC
            self.navigationController?.pushViewController(objVC, animated: true)
        }else if pageIndicator.currentPage == 1{
            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "WelcomeVC") as! WelcomeVC
            self.navigationController?.pushViewController(objVC, animated: true)
        }else {
            let obj = self.storyboard?.instantiateViewController(withIdentifier: "SignInVC") as! SignInVC
            self.navigationController?.pushViewController(obj, animated: true)
            UserDefaults.standard.set(true, forKey: "isIntroSkipped")
            UserDefaults.standard.synchronize()
        }
    }
    
    
    @objc func actionBtnNext(_ sender: UIButton) {
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
            let objVC = self.storyboard?.instantiateViewController(withIdentifier: "WelcomeVC") as! WelcomeVC
            self.navigationController?.pushViewController(objVC, animated: true)
            
        }
}
//    func startTimer() {
//
//        let timer =  Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.scrollAutomatically), userInfo: nil, repeats: false)
//    }


//    @objc func scrollAutomatically(_ timer1: Timer) {
//
//        if let coll  = colIntro {
//            for cell in coll.visibleCells {
//                let indexPath: IndexPath? = coll.indexPath(for: cell)
//                if ((indexPath?.row)! < createIntroSlides().count - 1){
//                    let indexPath1: IndexPath?
//                    indexPath1 = IndexPath.init(row: (indexPath?.row)! + 1, section: (indexPath?.section)!)
//
//                    coll.scrollToItem(at: indexPath1!, at: .right, animated: true)
//                }
//                else{
//                    let indexPath1: IndexPath?
//                    indexPath1 = IndexPath.init(row: 0, section: (indexPath?.section)!)
//                    coll.scrollToItem(at: indexPath1!, at: .left, animated: true)
//                }
//
//            }
//        }
//    }
}
