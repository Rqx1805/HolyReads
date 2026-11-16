//
//  FolioReaderQuoteShare.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 8/11/16.
//  Copyright (c) 2016 Folio Reader. All rights reserved.
//

import UIKit

class FolioReaderQuoteShare: UIViewController {
    var quoteText: String!
    var filterImage: UIView!
    var imageView: UIImageView!
    var quoteLabel: UILabel!
    var titleLabel: UILabel!
    var authorLabel: UILabel!
    var logoImageView: UIImageView!
    var ReadImageView: UIImageView!
    var VideoImageView: UIImageView!
    var collectionView: UICollectionView!
    var collectionNewView: UICollectionView!
    let collectionViewLayout = UICollectionViewFlowLayout()
    let collectionViewLayout1 = UICollectionViewFlowLayout()
    let itemSize: CGFloat = 90
    var dataSource = [QuoteImage]()
    let imagePicker = UIImagePickerController()
    var selectedIndex = 0
    var selectedIndexNew = 0
    var ImageArray = ["bg_01","bg_02","bg_03","bg_04","bg_05","bg_06","bg_07","bg_08","bg_09","bg_10","bg_11","bg_12","bg_13","bg_14"]
    var ImageData = NSMutableArray()
    var allimage = NSArray()
    fileprivate var book: FRBook
    fileprivate var folioReader: FolioReader
    fileprivate var readerConfig: FolioReaderConfig

    // MARK: Init

    init(initWithText shareText: String, readerConfig: FolioReaderConfig, folioReader: FolioReader, book: FRBook) {
        self.folioReader = folioReader
        self.readerConfig = readerConfig
        self.quoteText = shareText.stripLineBreaks().stripHtml()
        self.book = book

        super.init(nibName: nil, bundle: Bundle.frameworkBundle())
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    // MARK: - ViewWillAppear

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
         self.getQuoteImages()
        self.setCloseButton(withConfiguration: self.readerConfig)
        configureNavBar()
       
        let titleAttrs = [NSAttributedString.Key.foregroundColor: self.readerConfig.tintColor]
        let share = UIBarButtonItem(title: self.readerConfig.localizedShare, style: .plain, target: self, action: #selector(shareQuote(_:)))
        share.setTitleTextAttributes(titleAttrs, for: UIControl.State())
        navigationItem.rightBarButtonItem = share

        let isPad = (UIDevice.current.userInterfaceIdiom == .pad)
        if (isPad == true) {
            preferredContentSize = CGSize(width: 400, height: 600)
        }
        let screenBounds = (isPad == true ? preferredContentSize : UIScreen.main.bounds.size)

        self.filterImage = UIView(frame: CGRect(x: 0, y: 0, width: screenBounds.width, height: screenBounds.width))
        self.filterImage.backgroundColor = self.readerConfig.menuSeparatorColor
        view.addSubview(self.filterImage)

        imageView = UIImageView(frame: filterImage.bounds)
        filterImage.addSubview(imageView)

        quoteLabel = UILabel()
        quoteLabel.text = quoteText
        quoteLabel.textAlignment = .center
        quoteLabel.font = UIFont(name: "Andada-Regular", size: 26)
       // quoteLabel.textColor = UIColor.white
        quoteLabel.numberOfLines = 0
        quoteLabel.baselineAdjustment = .alignCenters
        quoteLabel.translatesAutoresizingMaskIntoConstraints = false
        quoteLabel.adjustsFontSizeToFitWidth = true
        quoteLabel.minimumScaleFactor = 0.3
        quoteLabel.setContentCompressionResistancePriority(UILayoutPriority(100), for: .vertical)
        filterImage.addSubview(quoteLabel)

        var bookTitle = ""
        var authorName = ""

        if let title = self.book.title {
            bookTitle = title
        }

        if let author = self.book.metadata.creators.first {
            authorName = author.name
        }
        let attrs1 = [NSAttributedString.Key.font: UIFont(name: "Lato-Italic", size: 15)!]
        let text1 = "An excerpt from the Summary" + " of \n" + bookTitle + "" + " by Holy Reads."
        let range = (text1 as NSString).range(of: bookTitle)
        let attributedString1 = NSMutableAttributedString(string: text1)

        attributedString1.addAttributes(attrs1, range: range)
        
        titleLabel = UILabel()
        titleLabel.attributedText = attributedString1
       // titleLabel.font = UIFont(name: "Lato-Regular", size: 15)
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor.white
        titleLabel.numberOfLines = 2
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8
        titleLabel.setContentCompressionResistancePriority(UILayoutPriority(600), for: .vertical)
        filterImage.addSubview(titleLabel)

        // Attributed author
        let attrs = [NSAttributedString.Key.font: UIFont(name: "Lato-Italic", size: 15)!]
        let attributedString = NSMutableAttributedString(string:"\(self.readerConfig.localizedShareBy) ", attributes: attrs)
        //attributedString.append(boldString)
        

        authorLabel = UILabel()
        authorLabel.attributedText = attributedString
        authorLabel.textAlignment = .center
        authorLabel.textColor = UIColor.white
        authorLabel.numberOfLines = 1
        authorLabel.translatesAutoresizingMaskIntoConstraints = false
        authorLabel.adjustsFontSizeToFitWidth = true
        authorLabel.minimumScaleFactor = 0.5
        filterImage.addSubview(authorLabel)
        
        
       // let logoImage1 = UIImage(named: "book(1)")
        let logoImage1 = UIImage(named: "")
        
        let logoHeight1 = logoImage1?.size.height ?? 0
        ReadImageView = UIImageView(image: logoImage1)
        ReadImageView.contentMode = .scaleAspectFit
        ReadImageView.translatesAutoresizingMaskIntoConstraints = false
        filterImage.addSubview(ReadImageView)

       // let logoImage = self.readerConfig.quoteCustomLogoImage
        let logoImage = UIImage(named: "")
        let logoHeight = logoImage?.size.height ?? 0
        logoImageView = UIImageView(image: logoImage)
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        filterImage.addSubview(logoImageView)
        
        
        let logoImage2 = UIImage(named: "")
       // let logoImage2 = UIImage(named: "play-button")
        let logoHeight2 = logoImage2?.size.height ?? 0
        VideoImageView = UIImageView(image: logoImage2)
        VideoImageView.contentMode = .scaleAspectFit
        VideoImageView.translatesAutoresizingMaskIntoConstraints = false
        filterImage.addSubview(VideoImageView)

        // Configure layout contraints
        var constraints = [NSLayoutConstraint]()
        let views = [
            "quoteLabel": self.quoteLabel,
            "titleLabel": self.titleLabel,
            "authorLabel": self.authorLabel,
            "ReadImageView": self.ReadImageView,
            "logoImageView": self.logoImageView,
            "VideoImageView": self.VideoImageView
            ] as [String : Any]

        NSLayoutConstraint.constraints(withVisualFormat: "V:|-40-[quoteLabel]-20-[titleLabel]", options: [], metrics: nil, views: views).forEach { constraints.append($0) }
        NSLayoutConstraint.constraints(withVisualFormat: "V:[titleLabel]-0-[authorLabel]", options: [], metrics: nil, views: views).forEach { constraints.append($0) }
        
        NSLayoutConstraint.constraints(withVisualFormat: "V:[authorLabel]-25-[ReadImageView(\(Int(logoHeight1)))]-16-|", options: [], metrics: nil, views: views).forEach { constraints.append($0) }
        
        NSLayoutConstraint.constraints(withVisualFormat: "V:[authorLabel]-25-[logoImageView(\(Int(logoHeight)))]-18-|", options: [], metrics: nil, views: views).forEach { constraints.append($0) }
        
        NSLayoutConstraint.constraints(withVisualFormat: "V:[authorLabel]-25-[VideoImageView(\(Int(logoHeight2)))]-14-|", options: [], metrics: nil, views: views).forEach { constraints.append($0) }

        NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[quoteLabel]-15-|", options: [], metrics: nil, views: views).forEach { constraints.append($0) }
        NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[titleLabel]-15-|", options: [], metrics: nil, views: views).forEach { constraints.append($0) }
        NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[authorLabel]-15-|", options: [], metrics: nil, views: views).forEach { constraints.append($0) }
        
        NSLayoutConstraint.constraints(withVisualFormat: "H:|-(-80)-[ReadImageView]-15-|", options: [], metrics: nil, views: views).forEach { constraints.append($0) }
        
        NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[logoImageView]-15-|", options: [], metrics: nil, views: views).forEach { constraints.append($0) }
       
        NSLayoutConstraint.constraints(withVisualFormat: "H:|-100-[VideoImageView]-15-|", options: [], metrics: nil, views: views).forEach { constraints.append($0) }

        filterImage.addConstraints(constraints)

        // Layout
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        collectionViewLayout.minimumLineSpacing = 15
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionViewLayout.scrollDirection = .horizontal
        
        // Layout
        collectionViewLayout1.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        collectionViewLayout1.minimumLineSpacing = 15
        collectionViewLayout1.minimumInteritemSpacing = 0
        collectionViewLayout1.scrollDirection = .horizontal

        let background = self.folioReader.isNight(self.readerConfig.nightModeBackground, UIColor.white)
        view.backgroundColor = background

        // CollectionView
        let collectionFrame = CGRect(x: 0, y: filterImage.frame.height+15, width: screenBounds.width, height: itemSize)
        collectionView = UICollectionView(frame: collectionFrame, collectionViewLayout: collectionViewLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = background
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        view.addSubview(collectionView)
        
        // CollectionView
        let collectionFramenew = CGRect(x: 0, y: filterImage.frame.height+100, width: screenBounds.width, height: itemSize)
        collectionNewView = UICollectionView(frame: collectionFramenew, collectionViewLayout: collectionViewLayout1)
        collectionNewView.delegate = self
        collectionNewView.dataSource = self
        collectionNewView.showsHorizontalScrollIndicator = false
        collectionNewView.backgroundColor = background
        collectionNewView.decelerationRate = UIScrollView.DecelerationRate.fast
        view.addSubview(collectionNewView)

        if (UIDevice.current.userInterfaceIdiom == .phone) {
            collectionView.autoresizingMask = [.flexibleWidth]
        }
        
        if (UIDevice.current.userInterfaceIdiom == .phone) {
            collectionNewView.autoresizingMask = [.flexibleWidth]
        }

        
        
        // Register cell classes
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: kReuseCellIdentifier)
        
        collectionNewView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: kReuseCellIdentifier1)

        // Create images
        dataSource = self.readerConfig.quoteCustomBackgrounds
        if (self.readerConfig.quotePreserveDefaultBackgrounds == true) {
            createDefaultImages()
        }

        // Picker delegate
        imagePicker.delegate = self
       // selectIndex1(0)
        // Select first item
      
    }

    func getQuoteImages() {
               let parameterDictionary = NSMutableDictionary()
               let methodName = "getShareImages"
               
               DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
                   let status  = DataManager.getVal(responseData?["status"]) as! String
                   let message  = DataManager.getVal(responseData?["message"]) as! String
                   if status == "1" {
                    self.ImageData = responseData?.value(forKey: "data") as! NSMutableArray
                    self.allimage = self.ImageData.value(forKey: "image") as! NSArray
                    self.collectionView.reloadData()
                    self.selectIndex(0)
                   } else {
                       print(message)
                   }
               }
           }
    
    func configureNavBar() {
        let navBackground = self.folioReader.isNight(self.readerConfig.nightModeNavBackground, self.readerConfig.daysModeNavBackground)
        let tintColor = self.readerConfig.tintColor
        let navText = self.folioReader.isNight(UIColor.white, UIColor.black)
        let font = UIFont(name: "Avenir-Light", size: 17)!
        setTranslucentNavigation(false, color: navBackground, tintColor: tintColor, titleColor: navText, andFont: font)
    }

    func createDefaultImages() {
       // let color1 = QuoteImage(withColor: UIColor(rgba: "#FA7B67"))
//         let color1 = QuoteImage(withImage: UIImage(named: "bg_01.jpg")!)
//         let color2 = QuoteImage(withImage: UIImage(named: "bg_02.jpg")!)
//         let color3 = QuoteImage(withImage: UIImage(named: "bg_03.jpg")!)
//         let color4 = QuoteImage(withImage: UIImage(named: "bg_04.jpg")!)
//         let color5 = QuoteImage(withImage: UIImage(named: "bg_05.jpg")!)
//         let color6 = QuoteImage(withImage: UIImage(named: "bg_06.jpg")!)
//         let color7 = QuoteImage(withImage: UIImage(named: "bg_07.jpg")!)
//         let color8 = QuoteImage(withImage: UIImage(named: "bg_08.jpg")!)
//         let color9 = QuoteImage(withImage: UIImage(named: "bg_09.jpg")!)
//         let color10 = QuoteImage(withImage: UIImage(named: "bg_10.jpg")!)
//         let color11 = QuoteImage(withImage: UIImage(named: "bg_11.jpg")!)
//         let color12 = QuoteImage(withImage: UIImage(named: "bg_12.jpg")!)
//         let color13 = QuoteImage(withImage: UIImage(named: "bg_13.jpg")!)
//         let color14 = QuoteImage(withImage: UIImage(named: "bg_14.jpg")!)
         let color15 = QuoteImage(withColor: UIColor(rgba: "#78CAB6"))
         let color16 = QuoteImage(withColor: UIColor(rgba: "#71B630"))
         let color17 = QuoteImage(withColor: UIColor(rgba: "#4D5B49"))
         let color18 = QuoteImage(withColor: UIColor(rgba: "#959D92"), textColor: UIColor(rgba: "#4D5B49"))

         var gradient = CAGradientLayer()
         gradient.colors = [UIColor(rgba: "#2989C9").cgColor, UIColor(rgba: "#21B8C2").cgColor]
         gradient.startPoint = CGPoint(x: 0, y: 1)
         gradient.endPoint = CGPoint(x: 1, y: 0)
         let gradient1 = QuoteImage(withGradient: gradient)

         gradient = CAGradientLayer()
         gradient.colors = [UIColor(rgba: "#FAD961").cgColor, UIColor(rgba: "#F76B1C").cgColor]
         let gradient2 = QuoteImage(withGradient: gradient)

         gradient = CAGradientLayer()
         gradient.colors = [UIColor(rgba: "#B4EC51").cgColor, UIColor(rgba: "#429321").cgColor]
         let gradient3 = QuoteImage(withGradient: gradient)
         dataSource.append(contentsOf: [color15,color16,color17,color18,gradient1,gradient2,gradient3])
         //dataSource.append(contentsOf: [color1, color2, color3, color4, color5,color6,color7,color8,color9,color10,color11,color12,color13,color14,color15,color16,color17,color18,gradient1,gradient2,gradient3])
    }

    func selectIndex(_ index: Int) {
        let row = index+1
        var dict = NSDictionary()
        dict = self.ImageData.object(at: index) as! NSDictionary
        if let imgUrl = URL(string: dict.value(forKey: "image") as? String ?? "") {
            
            //Replace with your imageView outlet
            imageView.sd_setImage(with: imgUrl, placeholderImage: UIImage(named: ""), options: .lowPriority)
            print(imgUrl)
            
        }else{
            imageView.image = nil;
        }

        var colourcode:String!
        colourcode = dict.value(forKey: "font_color") as? String
        quoteLabel.text = quoteText
        quoteLabel.textAlignment = .center
        quoteLabel.font = UIFont(name: "Andada-Regular", size: 26)
        quoteLabel.textColor = UIColor(rgba: colourcode)
        quoteLabel.numberOfLines = 0
        quoteLabel.baselineAdjustment = .alignCenters
        quoteLabel.translatesAutoresizingMaskIntoConstraints = false
        quoteLabel.adjustsFontSizeToFitWidth = true
        quoteLabel.minimumScaleFactor = 0.3
        quoteLabel.setContentCompressionResistancePriority(UILayoutPriority(100), for: .vertical)
        filterImage.addSubview(quoteLabel)
        
        let prevSelectedIndex = selectedIndexNew
        selectedIndexNew = row

        guard prevSelectedIndex != selectedIndexNew else { return }

        collectionView.performBatchUpdates({
            self.collectionView.reloadItems(at: [
                IndexPath(item: self.selectedIndexNew, section: 0),
                IndexPath(item: prevSelectedIndex, section: 0)
                ])
        }, completion: nil)
    }
    
    func selectIndex1(_ index: Int) {
        let quoteImage = dataSource[index]
        let row = index+1
        
                filterImage.backgroundColor = quoteImage.backgroundColor
                imageView.alpha = quoteImage.alpha
        
                UIView.transition(with: filterImage, duration: 0.4, options: .transitionCrossDissolve, animations: {
                    self.imageView.image = quoteImage.image
                    self.quoteLabel.textColor = quoteImage.textColor
                    self.titleLabel.textColor = quoteImage.textColor
                    self.authorLabel.textColor = quoteImage.textColor
                    self.logoImageView.image = self.logoImageView.image?.imageTintColor(quoteImage.textColor)
                }, completion: nil)
        
       
        
        let prevSelectedIndex = selectedIndex
        selectedIndex = row
        
        guard prevSelectedIndex != selectedIndex else { return }
        
        collectionNewView.performBatchUpdates({
            self.collectionNewView.reloadItems(at: [
                IndexPath(item: self.selectedIndex, section: 0),
                IndexPath(item: prevSelectedIndex, section: 0)
                ])
        }, completion: nil)
    }

    // MARK: Share

    @objc func shareQuote(_ sender: UIBarButtonItem) {
        var subject = self.readerConfig.localizedShareHighlightSubject
        var text = ""
        var bookTitle = ""
        var authorName = ""
        var shareItems = [AnyObject]()

        // Get book title
        if let title = self.book.title {
            bookTitle = title
            subject += " “\(title)”"
        }

        // Get author name
        if let author = self.book.metadata.creators.first {
            authorName = author.name
        }
        
        if authorName == "" {
            let authorN = UserDefaults.standard.value(forKey: "NameAuth") as? String
            authorName = authorN ?? ""
        }else {
            
        }

        text = "\(bookTitle) \n\(self.readerConfig.localizedShareBy) \(authorName)"

        let imageQuote = UIImage.imageWithView(filterImage)
        shareItems.append(imageQuote)

//        if let bookShareLink = self.readerConfig.localizedShareWebLink {
//            text += "\n\(bookShareLink.absoluteString)"
//        }
//
//        let act = FolioReaderSharingProvider(subject: subject, text: text)
//        shareItems.insert(act, at: 0)

        let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.print, UIActivity.ActivityType.postToVimeo]

        // Pop style on iPad
        if let actv = activityViewController.popoverPresentationController {
            actv.barButtonItem = sender
        }

        present(activityViewController, animated: true, completion: nil)
    }

    // MARK: Status Bar

    override var preferredStatusBarStyle : UIStatusBarStyle {
        return self.folioReader.isNight(.lightContent, .default)
    }

    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .portrait
    }

    override var shouldAutorotate : Bool {
        return false
    }
}

// MARK: UICollectionViewDataSource

extension FolioReaderQuoteShare: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == collectionNewView{
            return dataSource.count + 1
        }else {
            return ImageData.count + 1
        }
        
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collectionNewView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kReuseCellIdentifier1, for: indexPath)
            let imageView: UIImageView!
            let tag = 9999
            
            cell.backgroundColor = UIColor.clear
            cell.contentView.backgroundColor = UIColor.clear
            cell.contentView.layer.borderWidth = 1
            
            if let view = cell.contentView.viewWithTag(tag) as? UIImageView {
                imageView = view
            } else {
                imageView = UIImageView(frame: cell.bounds)
                imageView.tag = tag
                cell.contentView.addSubview(imageView)
            }
            // Camera
            guard ((indexPath as NSIndexPath).row > 0) else {
                
                // Image color
                let normalColor = UIColor(white: 0.5, alpha: 0.7)
                let camera = UIImage(readerImageNamed: "icon-camera")
                let dash = UIImage(readerImageNamed: "border-dashed-pattern")
                let cameraNormal = camera?.imageTintColor(normalColor)
                
                imageView.contentMode = .center
                imageView.image = cameraNormal
                if let dashNormal = dash?.imageTintColor(normalColor) {
                    cell.contentView.layer.borderColor = UIColor(patternImage: dashNormal).cgColor
                }
                return cell
            }
            
            if (selectedIndex == (indexPath as NSIndexPath).row) {
                cell.contentView.layer.borderColor = self.readerConfig.tintColor.cgColor
                cell.contentView.layer.borderWidth = 3
            } else {
                cell.contentView.layer.borderColor = UIColor(white: 0.5, alpha: 0.2).cgColor
            }
            
            let quoteImage = dataSource[(indexPath as NSIndexPath).row-1]
            imageView.image = quoteImage.image
            imageView.alpha = quoteImage.alpha
            imageView.contentMode = .scaleToFill
            
            // cell.contentView.backgroundColor = quoteImage.backgroundColor
            return cell
        }else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kReuseCellIdentifier, for: indexPath)
            let imageView: UIImageView!
            let tag = 9999
            
            cell.backgroundColor = UIColor.clear
            cell.contentView.backgroundColor = UIColor.clear
            cell.contentView.layer.borderWidth = 1
            
            if let view = cell.contentView.viewWithTag(tag) as? UIImageView {
                imageView = view
            } else {
                imageView = UIImageView(frame: cell.bounds)
                imageView.tag = tag
                cell.contentView.addSubview(imageView)
            }
            if indexPath.item == 0 {
                cell.contentView.isHidden = true
            }else {
                cell.contentView.isHidden = false
            }
            
            
            // Camera
            guard ((indexPath as NSIndexPath).row > 0) else {
                // Image color
                let normalColor = UIColor(white: 0.5, alpha: 0.7)
                let camera = UIImage(readerImageNamed: "icon-camera")
                let dash = UIImage(readerImageNamed: "border-dashed-pattern")
                let cameraNormal = camera?.imageTintColor(normalColor)
                
                imageView.contentMode = .center
                imageView.image = cameraNormal
                if let dashNormal = dash?.imageTintColor(normalColor) {
                    cell.contentView.layer.borderColor = UIColor(patternImage: dashNormal).cgColor
                }
                return cell
            }
            
            if (selectedIndexNew == (indexPath as NSIndexPath).row) {
                cell.contentView.layer.borderColor = self.readerConfig.tintColor.cgColor
                cell.contentView.layer.borderWidth = 3
            } else {
                cell.contentView.layer.borderColor = UIColor(white: 0.5, alpha: 0.2).cgColor
            }
            var dict = NSDictionary()
            dict = self.ImageData.object(at: indexPath.row-1) as! NSDictionary
            if let imgUrl = URL(string: dict.value(forKey: "image") as? String ?? "") {
                
                //Replace with your imageView outlet
                imageView.sd_setImage(with: imgUrl, placeholderImage: UIImage(named: ""), options: .lowPriority)
                print(imgUrl)
                
            }else{
                imageView.image = nil;
            }
            //        let quoteImage = dataSource[(indexPath as NSIndexPath).row-1]
            //        imageView.image = quoteImage.image
            //        imageView.alpha = quoteImage.alpha
            // imageView.image = allimage[indexPath.item] as? UIImage
            imageView.contentMode = .scaleToFill
            
            // cell.contentView.backgroundColor = quoteImage.backgroundColor
            return cell
        }
        
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        if collectionView == collectionNewView {
            return CGSize(width: itemSize, height: itemSize)
        }else {
            return CGSize(width: itemSize, height: itemSize)
        }
        
    }
}

// MARK: UICollectionViewDelegate

extension FolioReaderQuoteShare: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == collectionNewView {
            guard (indexPath as NSIndexPath).row > 0 else {
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                let takePhoto = UIAlertAction(title: self.readerConfig.localizedTakePhoto, style: .default, handler: { (action) -> Void in
                    self.imagePicker.sourceType = .camera
                    self.imagePicker.allowsEditing = true
                    self.present(self.imagePicker, animated: true, completion: nil)
                })
                
                let existingPhoto = UIAlertAction(title: self.readerConfig.localizedChooseExisting, style: .default) { (action) -> Void in
                    self.imagePicker.sourceType = .photoLibrary
                    self.imagePicker.allowsEditing = true
                    self.present(self.imagePicker, animated: true, completion: nil)
                }
                
                let cancel = UIAlertAction(title: self.readerConfig.localizedCancel, style: .cancel, handler: nil)
                
                alertController.addAction(takePhoto)
                alertController.addAction(existingPhoto)
                alertController.addAction(cancel)
                
                present(alertController, animated: true, completion: nil)
                return
            }
            selectIndex1((indexPath as NSIndexPath).row-1)
            selectedIndexNew = 0
            self.collectionView.reloadData()
            
        }else
        {
            guard (indexPath as NSIndexPath).row > 0 else {
                print("Error")
                return
            }
            selectIndex((indexPath as NSIndexPath).row-1)
            selectedIndex = 0
            self.collectionNewView.reloadData()
        }
       
    }
}

// MARK: ImagePicker delegate

extension FolioReaderQuoteShare: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        if let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage {

            let quoteImage = QuoteImage(withImage: image, alpha: 0.6, backgroundColor: UIColor.black)

            collectionNewView.performBatchUpdates({
                self.dataSource.insert(quoteImage, at: 0)
                self.collectionNewView.insertItems(at: [IndexPath(item: 1, section: 0)])
                self.collectionNewView.reloadItems(at: [IndexPath(item: self.selectedIndexNew, section: 0)])
            }, completion: { (finished) in
                self.selectIndex1(0)
                self.selectedIndexNew = 0
                self.collectionView.reloadData()
                self.collectionNewView.reloadData()
                
            })
        }
        
        self.dismiss(animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
