//
//  FolioReaderCenter.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 08/04/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit
import ZFDragableModalTransition
import JavaScriptCore
import CoreData

/// Protocol which is used from `FolioReaderCenter`s.
@objc public protocol FolioReaderCenterDelegate: class {

    /// Notifies that a page appeared. This is triggered when a page is chosen and displayed.
    ///
    /// - Parameter page: The appeared page
    @objc optional func pageDidAppear(_ page: FolioReaderPage)

    /// Passes and returns the HTML content as `String`. Implement this method if you want to modify the HTML content of a `FolioReaderPage`.
    ///
    /// - Parameters:
    ///   - page: The `FolioReaderPage`.
    ///   - htmlContent: The current HTML content as `String`.
    /// - Returns: The adjusted HTML content as `String`. This is the content which will be loaded into the given `FolioReaderPage`.
    @objc optional func htmlContentForPage(_ page: FolioReaderPage, htmlContent: String) -> String
    
    /// Notifies that a page changed. This is triggered when collection view cell is changed.
    ///
    /// - Parameter pageNumber: The appeared page item
    @objc optional func pageItemChanged(_ pageNumber: Int)

}

/// The base reader class
open class FolioReaderCenter: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    /// This delegate receives the events from the current `FolioReaderPage`s delegate.
    open weak var delegate: FolioReaderCenterDelegate?

    /// This delegate receives the events from current page
    open weak var pageDelegate: FolioReaderPageDelegate?

    /// The base reader container
    open weak var readerContainer: FolioReaderContainer?

    /// The current visible page on reader
    open fileprivate(set) var currentPage: FolioReaderPage?

    /// The collection view with pages
    open var collectionView: UICollectionView!
    
    let collectionViewLayout = UICollectionViewFlowLayout()
    var loadingView: UIActivityIndicatorView!
    var pages: [String]!
    var totalPages: Int = 0
    var tempFragment: String?
    var animator: ZFModalTransitionAnimator!
    var pageIndicatorView: FolioReaderPageIndicator?
    var pageIndicatorHeight: CGFloat = 20
    var recentlyScrolled = false
    var recentlyScrolledDelay = 2.0 // 2 second delay until we clear recentlyScrolled
    var recentlyScrolledTimer: Timer!
    var scrollScrubber: ScrollScrubber?
    var activityIndicator = UIActivityIndicatorView()
    var isScrolling = false
    var pageScrollDirection = ScrollDirection()
    var nextPageNumber: Int = 0
    var previousPageNumber: Int = 0
    var currentPageNumber: Int = 0
    var pageWidth: CGFloat = 0.0
    var pageHeight: CGFloat = 0.0
    let btnMarkComplete  =  UIButton()
    var VideoData:[String: Any]!
    var defaults:UserDefaults!
    var pagenew:Int!
    var idnew:String!
    var opennew:String!
    var arrHighlightedMarkedBooks = [[String:Any]]()
    var dictBookDetails = [String: Any]()
    fileprivate var screenBounds: CGRect!
    fileprivate var pointNow = CGPoint.zero
    fileprivate var pageOffsetRate: CGFloat = 0
    fileprivate var tempReference: FRTocReference?
    fileprivate var isFirstLoad = true
    fileprivate var currentWebViewScrollPositions = [Int: CGPoint]()
    fileprivate  var highlights = [Highlight]()
    fileprivate var currentOrientation: UIInterfaceOrientation?
    var window:UIWindow?
    var context = JSContext()
    var note:String!
    var rangy:String!
    var Apiboovalue:Bool = false
    fileprivate var readerConfig: FolioReaderConfig {
        guard let readerContainer = readerContainer else { return FolioReaderConfig() }
        return readerContainer.readerConfig
    }

    fileprivate var book: FRBook {
        guard let readerContainer = readerContainer else { return FRBook() }
        return readerContainer.book
    }

    fileprivate var folioReader: FolioReader {
        guard let readerContainer = readerContainer else { return FolioReader() }
        return readerContainer.folioReader
    }

    // MARK: - Init

    init(withContainer readerContainer: FolioReaderContainer) {
        self.readerContainer = readerContainer
        super.init(nibName: nil, bundle: Bundle.frameworkBundle())

        self.initialization()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("This class doesn't support NSCoding.")
    }

    /**
     Common Initialization
     */
    fileprivate func initialization() {

        if (self.readerConfig.hideBars == true) {
            self.pageIndicatorHeight = 0
        }
        
        self.totalPages = book.spine.spineReferences.count

        // Loading indicator
        let style: UIActivityIndicatorView.Style = folioReader.isNight(.white, .gray)
        loadingView = UIActivityIndicatorView(style: style)
        loadingView.hidesWhenStopped = true
        loadingView.startAnimating()
        self.view.addSubview(loadingView)
    }

    // MARK: - View life cicle

    override open func viewDidLoad() {
        super.viewDidLoad()
       
        defaults = UserDefaults.standard
        VideoData = defaults.dictionary(forKey: "VideoData")
        pagenew = defaults.integer(forKey: "PAGENew")
        idnew = defaults.value(forKey: "IdNew") as? String
        opennew = defaults.value(forKey: "OpenPage") as? String
        if opennew == "Note" {
            self.changePageWith1(page: pagenew, andFragment: idnew)
           // self.currentWebViewScrollPositions[pagenew - 1] = CGPoint(x: 0, y: 1100)
        
        }else {
           
            print("Ashish")
        }
        
        if self.Apiboovalue == false {
           self.getReadingBook()
        }else{
            
        }
    
//        // Specify the path to the jssource.js file.
//        if let jsSourcePath = Bundle.main.path(forResource: "Bridge", ofType: "js") {
//            do {
//                // Load its contents to a String variable.
//                let jsSourceContents = try String(contentsOfFile: jsSourcePath)
//                let html = jsSourceContents.appendingPathExtension("getHTML()")
//                print(html)
//                // Add the Javascript code that currently exists in the jsSourceContents to the Javascript Runtime through the jsContext object.
//                self.context!.evaluateScript(jsSourceContents)
//            }
//            catch {
//                print(error.localizedDescription)
//            }
//        }

        screenBounds = self.getScreenBounds()
        
        setPageSize(UIApplication.shared.statusBarOrientation)

        // Layout
        collectionViewLayout.sectionInset = UIEdgeInsets.zero
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.minimumInteritemSpacing = 0
        collectionViewLayout.scrollDirection = .direction(withConfiguration: self.readerConfig)
        
        let background = folioReader.isNight(self.readerConfig.nightModeBackground, UIColor.white)
        view.backgroundColor = background

        // CollectionView
        collectionView = UICollectionView(frame: screenBounds, collectionViewLayout: collectionViewLayout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = background
        collectionView.decelerationRate = UIScrollView.DecelerationRate.fast
        enableScrollBetweenChapters(scrollEnabled: true)
        view.addSubview(collectionView)
        
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
        }

        // Activity Indicator
        self.activityIndicator.style = .gray
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator = UIActivityIndicatorView(frame: CGRect(x: screenBounds.size.width/2, y: screenBounds.size.height/2, width: 30, height: 30))
        self.activityIndicator.backgroundColor = UIColor.gray
        self.view.addSubview(self.activityIndicator)
        self.view.bringSubviewToFront(self.activityIndicator)

        if #available(iOS 10.0, *) {
            collectionView.isPrefetchingEnabled = false
        }

        // Register cell classes
        collectionView?.register(FolioReaderPage.self, forCellWithReuseIdentifier: kReuseCellIdentifier)

        // Configure navigation bar and layout
        automaticallyAdjustsScrollViewInsets = false
        extendedLayoutIncludesOpaqueBars = true
        configureNavBar()

        // Page indicator view
        if (self.readerConfig.hidePageIndicator == false) {
            let frame = self.frameForPageIndicatorView()
            pageIndicatorView = FolioReaderPageIndicator(frame: frame, readerConfig: readerConfig, folioReader: folioReader)
            if let pageIndicatorView = pageIndicatorView {
                view.addSubview(pageIndicatorView)
            }
        }

        guard let readerContainer = readerContainer else { return }
        self.scrollScrubber = ScrollScrubber(frame: frameForScrollScrubber(), withReaderContainer: readerContainer)
        self.scrollScrubber?.delegate = self
        if let scrollScrubber = scrollScrubber {
            view.addSubview(scrollScrubber.slider)
        }

    }
    

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

       
        NotificationCenter.default.addObserver(self, selector: #selector(self.currencyConvert1(_:)), name: NSNotification.Name("OpenHigh"), object: nil)
        
     
        
        
        
          self.navigationController?.isNavigationBarHidden = false
        configureNavBar()
        
        // Update pages
        pagesForCurrentPage(currentPage)
        
        pageIndicatorView?.reloadView(updateShadow: true)
        if #available(iOS 11.0, *) {
            topSafeArea = Double(view.safeAreaInsets.top)
            bottomSafeArea = Double(view.safeAreaInsets.bottom)
        } else {
            topSafeArea = Double(topLayoutGuide.length)
            bottomSafeArea = Double(bottomLayoutGuide.length)
        }
       
       
        // currentPageNumber = pagenew
        // print(self.currentPageNumber)
//        let newhigh = UserDefaults.standard.value(forKey: "HIghNew") as? String
//        if newhigh == "HighLight"{
//            //self.addd()
//             currentPageNumber = 0
//             let config = FolioReaderConfig()
//             var strbook = String()
//             defaults = UserDefaults.standard
//             strbook = defaults.value(forKey: "NewBook") as! String
//             self.highlights = Highlight.allByBookId(withConfiguration: config, bookId: strbook)
//             var index = Int()
//             index =  defaults.integer(forKey: "NEWIndex")
//             guard let highlight = highlights[safe: index] else { return }
//             print(highlight)
//             self.folioReader.readerCenter?.changePageWithNew(page: highlight.page, andFragment: highlight.highlightId)
//        }else {

      //  }
       
            // safe area values are now available to use

         
    }
    
    @objc func currencyConvert1(_ pNotification: Notification?) {
         let strbook = UserDefaults.standard.value(forKey: "NewBook") as? String
         let index = UserDefaults.standard.integer(forKey: "NEWIndex")
         let config = FolioReaderConfig()
         self.highlights = Highlight.allByBookId(withConfiguration: config, bookId: strbook!)
         guard let highlight = highlights[safe: index] else { return }
         self.folioReader.readerCenter?.changePageWith(page: highlight.page, andFragment: highlight.highlightId)
    }
    
    
   

    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        screenBounds = self.getScreenBounds()
        loadingView.center = view.center

        setPageSize(UIApplication.shared.statusBarOrientation)
        updateSubviewFrames()
    }

    // MARK: Layout

    /**
     Enable or disable the scrolling between chapters (`FolioReaderPage`s). If this is enabled it's only possible to read the current chapter. If another chapter should be displayed is has to be triggered programmatically with `changePageWith`.

     - parameter scrollEnabled: `Bool` which enables or disables the scrolling between `FolioReaderPage`s.
     */
    open func enableScrollBetweenChapters(scrollEnabled: Bool) {
        self.collectionView.isScrollEnabled = scrollEnabled
    }

    fileprivate func updateSubviewFrames() {
        self.pageIndicatorView?.frame = self.frameForPageIndicatorView()
        self.scrollScrubber?.frame = self.frameForScrollScrubber()
    }

    fileprivate func frameForPageIndicatorView() -> CGRect {
        var bounds = CGRect(x: 0, y: screenBounds.size.height-pageIndicatorHeight, width: screenBounds.size.width, height: pageIndicatorHeight)
        
        if #available(iOS 11.0, *) {
            bounds.size.height = bounds.size.height + view.safeAreaInsets.bottom
        }
         return bounds
    }

    fileprivate func frameForScrollScrubber() -> CGRect {
        let scrubberY: CGFloat = ((self.readerConfig.shouldHideNavigationOnTap == true || self.readerConfig.hideBars == true) ? 50 : 74)
        return CGRect(x: self.pageWidth + 10, y: scrubberY, width: 40, height: (self.pageHeight - 100))
    }

    func configureNavBar() {
        let navBackground = folioReader.isNight(self.readerConfig.nightModeNavBackground, self.readerConfig.daysModeNavBackground)
        let tintColor = readerConfig.tintColor
        let navText = folioReader.isNight(UIColor.white, UIColor.black)
        let font = UIFont(name: "Avenir-Light", size: 17)!
        setTranslucentNavigation(color: navBackground, tintColor: tintColor, titleColor: navText, andFont: font)
    }

    func configureNavBarButtons() {
        
       // let closeImage = self.readerConfig.quoteCustomLogoImage
        
        // Navbar buttons
        let shareIcon = UIImage(readerImageNamed: "headphones")?.ignoreSystemTint(withConfiguration: self.readerConfig)
        let audioIcon = UIImage(readerImageNamed: "play")?.ignoreSystemTint(withConfiguration: self.readerConfig) //man-speech-icon
        let closeIcon = UIImage(readerImageNamed: "icon-navbar-close")?.ignoreSystemTint(withConfiguration: self.readerConfig)
        let tocIcon = UIImage(readerImageNamed: "index")?.ignoreSystemTint(withConfiguration: self.readerConfig)
        let fontIcon = UIImage(readerImageNamed: "icon-font-big")?.ignoreSystemTint(withConfiguration: self.readerConfig)
        let DownloadIcon = UIImage(readerImageNamed: "download (8)")?.ignoreSystemTint(withConfiguration: self.readerConfig)
        let Shicon = UIImage(readerImageNamed: "icon-navbar-share")?.ignoreSystemTint(withConfiguration: self.readerConfig)
        let space = 70 as CGFloat

        let menu = UIBarButtonItem(image: closeIcon, style: .plain, target: self, action:#selector(closeReader(_:)))
        let toc = UIBarButtonItem(image: tocIcon, style: .plain, target: self, action:#selector(presentChapterList(_:)))
       // let audio = UIBarButtonItem(image: audioIcon, style: .plain, target: self, action:#selector(presentPlayerMenu(_:)))
        

        navigationItem.leftBarButtonItems = [menu, toc]
        
        var rightBarIcons = [UIBarButtonItem]()
        
        if self.book.hasAudio || self.readerConfig.enableTTS || (self.readerConfig.allowSharing == true)   {
            
             rightBarIcons.append(UIBarButtonItem(image: fontIcon, style: .plain, target: self, action:#selector(presentFontsMenu)))
            
             rightBarIcons.append(UIBarButtonItem(image: audioIcon, style: .plain, target: self, action:#selector(presentPlayerMenu(_:))))
            
            rightBarIcons.append(UIBarButtonItem(image: shareIcon, style: .plain, target: self, action:#selector(shareChapter(_:))))
            
             rightBarIcons.append(UIBarButtonItem(image: DownloadIcon, style: .plain, target: self, action:#selector(downloadBookOffline(_:))))
            
             rightBarIcons.append(UIBarButtonItem(image: Shicon, style: .plain, target: self, action:#selector(shareChapter1(_:))))
            
            
            
        }
        
//        if (self.readerConfig.allowSharing == true) {
//
//            rightBarIcons.append(UIBarButtonItem(image: DownloadIcon, style: .plain, target: self, action:#selector(downloadBookOffline(_:))))
//
//            rightBarIcons.append(UIBarButtonItem(image: shareIcon, style: .plain, target: self, action:#selector(shareChapter(_:))))
//        }
//

        
        
     
        
//        let offlineDownload = UIBarButtonItem(image: UIImage.init(named: "download2"), style: .plain, target: self, action: #selector(downloadBookOffline(_:)))
//        if DataManager.isConnectedToNetwork() {
//            offlineDownload.isEnabled = true
//        } else {
//            offlineDownload.isEnabled = false
//        }

//        let font = UIBarButtonItem(image: fontIcon, style: .plain, target: self, action: #selector(presentFontsMenu))
        
      //  let Share = UIBarButtonItem(image: Shicon, style: .plain, target: self, action: #selector(shareChapter1))
        
        
       // font.width = space
       // rightBarIcons.append(contentsOf: [font])
       // rightBarIcons.append(contentsOf: [font,offlineDownload])
        navigationItem.rightBarButtonItems = rightBarIcons
        
        if(self.readerConfig.displayTitle){
            navigationItem.title = book.title
        }
    }

    func reloadData() {
        self.loadingView.stopAnimating()
        self.totalPages = book.spine.spineReferences.count
        self.collectionView.reloadData()
        self.configureNavBarButtons()
        self.setCollectionViewProgressiveDirection()

        if self.readerConfig.loadSavedPositionForCurrentBook {
            guard let position = folioReader.savedPositionForCurrentBook, let pageNumber = position["pageNumber"] as? Int, pageNumber > 0 else {
                self.currentPageNumber = 1
                return
            }

            self.changePageWith(page: pageNumber)
            self.currentPageNumber = pageNumber
        }
        
        let newhigh = UserDefaults.standard.value(forKey: "HIghNew") as? String
        if newhigh == "HighLight"{
            //self.addd()
            //            currentPageNumber = 0
            // let config = FolioReaderConfig()
            var HiID = String()
            defaults = UserDefaults.standard
            HiID = defaults.value(forKey: "IdNew") as! String
            //  self.highlights = Highlight.allByBookId(withConfiguration: config, bookId: strbook)
            var page = Int()
            page =  defaults.integer(forKey: "PAGENew")
            //let highlight = highlights[safe: index]
            //  print(highlight!)
            self.folioReader.readerCenter?.changePageWithNew(page: page, andFragment: HiID)
        }else {
            
        }
    }

    // MARK: Change page progressive direction

    private func transformViewForRTL(_ view: UIView?) {
        if folioReader.needsRTLChange {
            view?.transform = CGAffineTransform(scaleX: -1, y: 1)
        } else {
            view?.transform = CGAffineTransform.identity
        }
    }

    func setCollectionViewProgressiveDirection() {
        self.transformViewForRTL(self.collectionView)
    }

    func setPageProgressiveDirection(_ page: FolioReaderPage) {
        self.transformViewForRTL(page)
    }

    // MARK: Change layout orientation

    /// Get internal page offset before layout change
    private func updatePageOffsetRate() {
        guard let currentPage = self.currentPage, let webView = currentPage.webView else {
            return
        }
        let pageScrollView = webView.scrollView
        let contentSize = pageScrollView.contentSize.forDirection(withConfiguration: self.readerConfig)
        let contentOffset = pageScrollView.contentOffset.forDirection(withConfiguration: self.readerConfig)
        self.pageOffsetRate = (contentSize != 0 ? (contentOffset / contentSize) : 0)
    }

    func setScrollDirection(_ direction: FolioReaderScrollDirection) {
        guard let currentPage = self.currentPage, let webView = currentPage.webView else {
            return
        }

        let pageScrollView = webView.scrollView

        // Get internal page offset before layout change
        self.updatePageOffsetRate()
        // Change layout
        self.readerConfig.scrollDirection = direction
        self.collectionViewLayout.scrollDirection = .direction(withConfiguration: self.readerConfig)
        self.currentPage?.setNeedsLayout()
        self.collectionView.collectionViewLayout.invalidateLayout()
        self.collectionView.setContentOffset(frameForPage(self.currentPageNumber).origin, animated: false)

        // Page progressive direction
        self.setCollectionViewProgressiveDirection()
        delay(0.2) { self.setPageProgressiveDirection(currentPage) }

        /**
         *  This delay is needed because the page will not be ready yet
         *  so the delay wait until layout finished the changes.
         */
        delay(0.1) {
            var pageOffset = (pageScrollView.contentSize.forDirection(withConfiguration: self.readerConfig) * self.pageOffsetRate)
            // Fix the offset for paged scroll
            if (self.readerConfig.scrollDirection == .horizontal && self.pageWidth != 0) {
                let page = round(pageOffset / self.pageWidth)
                pageOffset = (page * self.pageWidth)
            }
            let pageOffsetPoint = self.readerConfig.isDirection(CGPoint(x: 0, y: pageOffset), CGPoint(x: pageOffset, y: 0), CGPoint(x: 0, y: pageOffset))
            pageScrollView.setContentOffset(pageOffsetPoint, animated: true)
        }
    }

    // MARK: Status bar and Navigation bar

    func hideBars() {
        guard self.readerConfig.shouldHideNavigationOnTap == true else {
            return
        }

        self.updateBarsStatus(true)
    }

    func showBars() {
        self.configureNavBar()
        self.updateBarsStatus(false)
    }

    func toggleBars() {
        guard self.readerConfig.shouldHideNavigationOnTap == true else {
            return
        }
        let shouldHide = !self.navigationController!.isNavigationBarHidden
        if shouldHide == false {
            self.configureNavBar()
        }

        self.updateBarsStatus(shouldHide)
    }

    private func updateBarsStatus(_ shouldHide: Bool, shouldShowIndicator: Bool = false) {
        guard let readerContainer = readerContainer else { return }
        readerContainer.shouldHideStatusBar = shouldHide

        UIView.animate(withDuration: 0.25, animations: {
            readerContainer.setNeedsStatusBarAppearanceUpdate()

            // Show minutes indicator
            if (shouldShowIndicator == true) {
                self.pageIndicatorView?.minutesLabel.alpha = shouldHide ? 0 : 1
            }
        })
        self.navigationController?.setNavigationBarHidden(shouldHide, animated: true)
    }

    // MARK: UICollectionViewDataSource

    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalPages
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reuseableCell = collectionView.dequeueReusableCell(withReuseIdentifier: kReuseCellIdentifier, for: indexPath) as? FolioReaderPage
        return self.configure(readerPageCell: reuseableCell, atIndexPath: indexPath)
        
        
    }
    func getHighlightBookListingApiCall() {
        self.showHud()
        let parameterDictionary = NSMutableDictionary()
        let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        let book_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "book_id")) as! String
        
        parameterDictionary.setValue(user_id, forKey: "user_id")
        parameterDictionary.setValue(book_id, forKey: "book_id")
        
        let methodName = "getHighlightListSecond"
        
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
            
            if status == "1" {
                if let response  = DataManager.getVal(responseData?["data"]) as? [[String:Any]] {
                    self.arrHighlightedMarkedBooks = response
                    print(self.arrHighlightedMarkedBooks)
//                    var dict = NSDictionary()
//                    dict = self.arrHighlightedMarkedBooks[0] as NSDictionary
//                    self.higforsts = dict["highlight_form"] as? Int
                }
                
            }else {
            }
            self.clearHud()
        }
    }
    

    private func configure(readerPageCell cell: FolioReaderPage?, atIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = cell, let readerContainer = readerContainer else {
            return UICollectionViewCell()
        }
        
        cell.setup(withReaderContainer: readerContainer)
        cell.pageNumber = indexPath.row+1
        cell.webView?.scrollView.delegate = self
        if #available(iOS 11.0, *) {
            cell.webView?.scrollView.contentInsetAdjustmentBehavior = .never
        }
        cell.webView?.setupScrollDirection()
        cell.webView?.frame = cell.webViewFrame()
        cell.delegate = self
        cell.backgroundColor = .clear
        setPageProgressiveDirection(cell)
        
        // Configure the cell
        let resource = self.book.spine.spineReferences[indexPath.row].resource
        guard var html = try? String(contentsOfFile: resource.fullHref, encoding: String.Encoding.utf8) else {
            return cell
        }

        let mediaOverlayStyleColors = "\"\(self.readerConfig.mediaOverlayColor.hexString(false))\", \"\(self.readerConfig.mediaOverlayColor.highlightColor().hexString(false))\""

        // rangy
        let jsFilePathRangy = Bundle.frameworkBundle().path(forResource: "rangy-core", ofType: "js")
        let jsFilePathhilighter = Bundle.frameworkBundle().path(forResource: "rangy-highlighter", ofType: "js")
        let jsFilePathClassapplier = Bundle.frameworkBundle().path(forResource: "rangy-classapplier", ofType: "js")
        let jsFilePathserializer = Bundle.frameworkBundle().path(forResource: "rangy-serializer", ofType: "js")
        let jsFilerangyfix = Bundle.frameworkBundle().path(forResource: "rangefix", ofType: "js")
        let jsFileredimcfi = Bundle.frameworkBundle().path(forResource: "readium-cfi.umd", ofType: "js")
        let jsFileFace = Bundle.frameworkBundle().path(forResource: "jsface.min", ofType: "js")
        let jsFileJquery = Bundle.frameworkBundle().path(forResource: "jquery-3.1.1.min", ofType: "js")
        // Inject CSS
        let jsFilePath = Bundle.frameworkBundle().path(forResource: "Bridge", ofType: "js")
        let cssFilePath = Bundle.frameworkBundle().path(forResource: "Style", ofType: "css")
        let cssTag = "<link rel=\"stylesheet\" type=\"text/css\" href=\"\(cssFilePath!)\">"
//        let jsTag = "<script type=\"text/javascript\" src=\"\(jsFilePath!)\"></script>" +
//        "<script type=\"text/javascript\">setMediaOverlayStyleColors(\(mediaOverlayStyleColors))</script>"
        
       
        
        let jsTag =  "<script type=\"text/javascript\" src=\"\(jsFileFace!)\"></script>" +
            "<script type=\"text/javascript\" src=\"\(jsFileJquery!)\"></script>" +
            "<script type=\"text/javascript\" src=\"\(jsFilePathRangy!)\"></script>" +
            "<script type=\"text/javascript\" src=\"\(jsFilePathhilighter!)\"></script>" +
            "<script type=\"text/javascript\" src=\"\(jsFilePathClassapplier!)\"></script>" +
            "<script type=\"text/javascript\" src=\"\(jsFilePathserializer!)\"></script>" +
            "<script type=\"text/javascript\" src=\"\(jsFilePath!)\"></script>" +
            "<script type=\"text/javascript\" src=\"\(jsFilerangyfix!)\"></script>" +
            "<script type=\"text/javascript\" src=\"\(jsFileredimcfi!)\"></script>" +
           "<script type=\"text/javascript\">setMediaOverlayStyleColors(\(mediaOverlayStyleColors))</script>"
            //+
           // "<script type=\"text/javascript\">setTimeout(() => { setHighlightByRangy(JSON.stringify('\(typeIdArrayString2)'))}, 2000);</script>"
        
        print(jsTag)
        
        let toInject = "\n\(cssTag)\n\(jsTag)\n</head>"
        html = html.replacingOccurrences(of: "</head>", with: toInject)
        
        
        // Font class name
        var classes = folioReader.currentFont.cssIdentifier
        classes += " " + folioReader.currentMediaOverlayStyle.className()

        // Night mode
        if folioReader.nightMode {
            classes += " nightMode"
        }

        // Font Size
        classes += " \(folioReader.currentFontSize.cssIdentifier)"

        html = html.replacingOccurrences(of: "<html ", with: "<html class=\"\(classes)\"")

        // Let the delegate adjust the html string
        if let modifiedHtmlContent = self.delegate?.htmlContentForPage?(cell, htmlContent: html) {
            html = modifiedHtmlContent
        }
//        var newhlml:String!
//        newhlml = html.replacingOccurrences(of: "\n", with: "")
//        let page = UserDefaults.standard.integer(forKey: "PAGENew")
//        let identi = UserDefaults.standard.value(forKey: "IdNew") as? String
//        let book_title = UserDefaults.standard.value(forKey: "NewBook") as? String
//        let match = Highlight.MatchingHighlight(text: newhlml, id: identi!, startOffset: "0", endOffset: "0", bookId: book_title!, currentPage: page)
//        let highlightq = Highlight.matchHighlight(match)
//        highlightq?.persist(withConfiguration: self.readerConfig)

        cell.loadHTMLString(html, baseURL: URL(fileURLWithPath: resource.fullHref.deletingLastPathComponent))
//        let newhigh = UserDefaults.standard.value(forKey: "HIghNew") as? String
//        if newhigh == "HighLight"{
//            //self.addd()
////            currentPageNumber = 0
//           // let config = FolioReaderConfig()
//            var HiID = String()
//            defaults = UserDefaults.standard
//            HiID = defaults.value(forKey: "IdNew") as! String
//          //  self.highlights = Highlight.allByBookId(withConfiguration: config, bookId: strbook)
//            var page = Int()
//            page =  defaults.integer(forKey: "PAGENew")
//            //let highlight = highlights[safe: index]
//          //  print(highlight!)
//            self.folioReader.readerCenter?.changePageWithNew(page: page, andFragment: HiID)
//        }else {
//
//        }
        
        return cell
    }
    
   

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var size = CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
        
        if #available(iOS 11.0, *) {
            let orientation = UIDevice.current.orientation
            
            if orientation == .portrait || orientation == .portraitUpsideDown {
                if readerConfig.scrollDirection == .horizontal {
                    size.height = size.height - view.safeAreaInsets.bottom
                }
            }
        }
        
        return size
    }
    
    // MARK: - Device rotation

    override open func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        guard folioReader.isReaderReady else { return }

        setPageSize(toInterfaceOrientation)
        updateCurrentPage()

        if self.currentOrientation == nil || (self.currentOrientation?.isPortrait != toInterfaceOrientation.isPortrait) {
            var pageIndicatorFrame = pageIndicatorView?.frame
            pageIndicatorFrame?.origin.y = ((screenBounds.size.height < screenBounds.size.width) ? (self.collectionView.frame.height - pageIndicatorHeight) : (self.collectionView.frame.width - pageIndicatorHeight))
            pageIndicatorFrame?.origin.x = 0
            pageIndicatorFrame?.size.width = ((screenBounds.size.height < screenBounds.size.width) ? (self.collectionView.frame.width) : (self.collectionView.frame.height))
            pageIndicatorFrame?.size.height = pageIndicatorHeight

            var scrollScrubberFrame = scrollScrubber?.slider.frame;
            scrollScrubberFrame?.origin.x = ((screenBounds.size.height < screenBounds.size.width) ? (screenBounds.size.width - 100) : (screenBounds.size.height + 10))
            scrollScrubberFrame?.size.height = ((screenBounds.size.height < screenBounds.size.width) ? (self.collectionView.frame.height - 100) : (self.collectionView.frame.width - 100))

            self.collectionView.collectionViewLayout.invalidateLayout()

            UIView.animate(withDuration: duration, animations: {
                // Adjust page indicator view
                if let pageIndicatorFrame = pageIndicatorFrame {
                    self.pageIndicatorView?.frame = pageIndicatorFrame
                    self.pageIndicatorView?.reloadView(updateShadow: true)
                }

                // Adjust scroll scrubber slider
                if let scrollScrubberFrame = scrollScrubberFrame {
                    self.scrollScrubber?.slider.frame = scrollScrubberFrame
                }

                // Adjust collectionView
                self.collectionView.contentSize = self.readerConfig.isDirection(
                    CGSize(width: self.pageWidth, height: self.pageHeight * CGFloat(self.totalPages)),
                    CGSize(width: self.pageWidth * CGFloat(self.totalPages), height: self.pageHeight),
                    CGSize(width: self.pageWidth * CGFloat(self.totalPages), height: self.pageHeight)
                )
                self.collectionView.setContentOffset(self.frameForPage(self.currentPageNumber).origin, animated: false)
                self.collectionView.collectionViewLayout.invalidateLayout()

                // Adjust internal page offset
                self.updatePageOffsetRate()
            })
        }

        self.currentOrientation = toInterfaceOrientation
    }

    override open func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        guard folioReader.isReaderReady == true, let currentPage = currentPage else {
            return
        }

        // Update pages
        pagesForCurrentPage(currentPage)
        currentPage.refreshPageMode()

        scrollScrubber?.setSliderVal()

        // After rotation fix internal page offset
        var pageOffset = (currentPage.webView?.scrollView.contentSize.forDirection(withConfiguration: self.readerConfig) ?? 0) * pageOffsetRate

        // Fix the offset for paged scroll
        if (self.readerConfig.scrollDirection == .horizontal && self.pageWidth != 0) {
            let page = round(pageOffset / self.pageWidth)
            pageOffset = page * self.pageWidth
        }

        let pageOffsetPoint = self.readerConfig.isDirection(CGPoint(x: 0, y: pageOffset), CGPoint(x: pageOffset, y: 0), CGPoint(x: 0, y: pageOffset))
        currentPage.webView?.scrollView.setContentOffset(pageOffsetPoint, animated: true)
    }

    override open func willAnimateRotation(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        guard folioReader.isReaderReady else {
            return
        }

        self.collectionView.scrollToItem(at: IndexPath(row: self.currentPageNumber - 1, section: 0), at: UICollectionView.ScrollPosition(), animated: false)
        if (self.currentPageNumber + 1) >= totalPages {
            UIView.animate(withDuration: duration, animations: {
                self.collectionView.setContentOffset(self.frameForPage(self.currentPageNumber).origin, animated: false)
            })
        }
    }

    // MARK: - Page

    func setPageSize(_ orientation: UIInterfaceOrientation) {
        guard orientation.isPortrait else {
            if screenBounds.size.width > screenBounds.size.height {
                self.pageWidth = screenBounds.size.width
                self.pageHeight = screenBounds.size.height
            } else {
                self.pageWidth = screenBounds.size.height
                self.pageHeight = screenBounds.size.width
            }
            return
        }

        if screenBounds.size.width < screenBounds.size.height {
            self.pageWidth = screenBounds.size.width
            self.pageHeight = screenBounds.size.height
        } else {
            self.pageWidth = screenBounds.size.height
            self.pageHeight = screenBounds.size.width
        }
    }
    
    
  

    func updateCurrentPage(_ page: FolioReaderPage? = nil, completion: (() -> Void)? = nil) {
        if let page = page {
            currentPage = page
            self.previousPageNumber = page.pageNumber-1
            self.currentPageNumber = page.pageNumber
        } else {
            let currentIndexPath = getCurrentIndexPath()
            currentPage = collectionView.cellForItem(at: currentIndexPath) as? FolioReaderPage

            self.previousPageNumber = currentIndexPath.row
            self.currentPageNumber = currentIndexPath.row+1
            
        }

        self.nextPageNumber = (((self.currentPageNumber + 1) <= totalPages) ? (self.currentPageNumber + 1) : self.currentPageNumber)
        let defaults = UserDefaults.standard
        defaults.setValue(self.currentPageNumber, forKey: "PageNO")
        defaults.synchronize()

        if currentPageNumber == totalPages {
           // NotificationCenter.default.post(name: NSNotification.Name(rawValue: "CompletedBookNotification"), object: self, userInfo: nil)
            self.getCompletedBookStatus()
            let cgFloat: CGFloat = CGFloat(bottomSafeArea)
            if screenHeight == 896 { // 11 pro max ,Xr
                btnMarkComplete.frame = CGRect(x: screenWidth - 170.00, y: screenHeight - 34 - 80 , width: 165.00, height: 45.00)
            } else if screenHeight == 812 { // X ,11pro
                btnMarkComplete.frame = CGRect(x: screenWidth - 170.00, y: screenHeight - 34 - 80 , width: 165.00, height: 45.00)
            } else if screenHeight == 667 { // 6, 7 ,8
                btnMarkComplete.frame = CGRect(x: screenWidth - 170.00, y: screenHeight - 0 - 100 , width: 165.00, height: 45.00)
            } else if screenHeight == 736 {  // 6+, 7+, 8+
                btnMarkComplete.frame = CGRect(x: screenWidth - 170.00, y: screenHeight - 0 - 110 , width: 165.00, height: 45.00)
            }else if screenHeight == 926 {  // iphone12 pro max
                btnMarkComplete.frame = CGRect(x: screenWidth - 170.00, y: screenHeight - 0 - 130 , width: 165.00, height: 45.00)
            }else if screenHeight == 568 {  // iphone SE
                btnMarkComplete.frame = CGRect(x: screenWidth - 170.00, y: screenHeight - 40 - 80 , width: 165.00, height: 45.00)
            }else{
                
                btnMarkComplete.frame = CGRect(x: screenWidth - 170.00, y: screenHeight - 34 - 80 , width: 165.00, height: 45.00)
            }
            //btnMarkComplete.backgroundColor = UIColor.systemOrange
            btnMarkComplete.layer.masksToBounds = true
            btnMarkComplete.layer.cornerRadius = 22
            btnMarkComplete.layer.shadowColor = UIColor.darkGray.cgColor
            btnMarkComplete.layer.shadowOffset = CGSize(width: 2, height: 2)
            btnMarkComplete.layer.shadowRadius = 8
            btnMarkComplete.layer.shadowOpacity = 1.0
            btnMarkComplete.clipsToBounds = false
            self.view.addSubview(btnMarkComplete)
            
            btnMarkComplete.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
            print("PageEnd")
        } else {
            for locView in self.view.subviews {
                if locView.isKind(of: UIButton.self) {
                    locView.removeFromSuperview()
                }
            }
             //self.view.removeFromSuperview()
             print("PageEnd")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "ReadingBookNotification"), object: self, userInfo: nil)
            
        }
        
        // Set pages
        guard let currentPage = currentPage else {
            completion?()
            return
        }

        scrollScrubber?.setSliderVal()

        if let readingTime = currentPage.webView?.js("getReadingTime()") {
            pageIndicatorView?.totalMinutes = Int(readingTime)!
        } else {
            pageIndicatorView?.totalMinutes = 0
        }
        pagesForCurrentPage(currentPage)
        delegate?.pageDidAppear?(currentPage)
        delegate?.pageItemChanged?(self.getCurrentPageItemNumber())
        
        completion?()
    }
    
   
    
    @objc func completeButtonTapped(_ sender : UIButton)  {
        if btnMarkComplete.isSelected{ return }else {
            self.CompletedBook()
        }
     }
   
    //MARK:- Get Completed Book Status Api Calling

    func getCompletedBookStatus() {
           let parameterDictionary = NSMutableDictionary()
           let bookId  = UserDefaults.standard.value(forKey: "book_id") as? Int
           let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        
            parameterDictionary.setValue(user_id, forKey: "user_id")
            parameterDictionary.setValue(bookId, forKey: "book_id")
            let methodName = "getCompletedStatus"
           
           DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
               let status  = DataManager.getVal(responseData?["status"]) as! String
               let completedStatus  = DataManager.getVal(responseData?["completed_status"]) as! String
               let message  = DataManager.getVal(responseData?["message"]) as! String
               if status == "1" {
                   if completedStatus == "1" {
                       self.btnMarkComplete.isSelected = true
                       self.btnMarkComplete.backgroundColor = #colorLiteral(red: 0.9703825116, green: 0.6403394938, blue: 0, alpha: 1)
                       self.btnMarkComplete.setTitle("Completed", for: .normal)
                   }  else {
                       self.btnMarkComplete.backgroundColor = #colorLiteral(red: 0.2107718289, green: 0.6397333741, blue: 0.8450053334, alpha: 1)
                       self.btnMarkComplete.setTitle("Mark Completed", for: .normal)
                       self.btnMarkComplete.isSelected = false
                   }
               }else {
                   print(message)
               }
           }
       }
    
    //MARK:- Completed Book Api Calling

    func CompletedBook() {
        let parameterDictionary = NSMutableDictionary()
        let bookId  = UserDefaults.standard.value(forKey: "book_id") as? Int
        let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        parameterDictionary.setValue(user_id, forKey: "user_id")
        parameterDictionary.setValue(bookId, forKey: "book_id")
        let methodName = "completedReading"
        
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let completedStatus  = DataManager.getVal(responseData?["completed_status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
            if status == "1" {
                if completedStatus == "1" {
                    self.btnMarkComplete.isSelected = true
                    self.btnMarkComplete.backgroundColor = #colorLiteral(red: 0.9703825116, green: 0.6403394938, blue: 0, alpha: 1)
                    self.btnMarkComplete.setTitle("Completed", for: .normal)
                }  else {
                    self.btnMarkComplete.backgroundColor = #colorLiteral(red: 0.2107718289, green: 0.6397333741, blue: 0.8450053334, alpha: 1)
                    self.btnMarkComplete.setTitle("Mark Completed", for: .normal)
                    self.btnMarkComplete.isSelected = false
                }
            } else {
                print(message)
            }
        }
    }
    
     func pagesForCurrentPage(_ page: FolioReaderPage?) {
        guard let page = page, let webView = page.webView else { return }

        let pageSize = self.readerConfig.isDirection(pageHeight, self.pageWidth, pageHeight)
        let contentSize = page.webView?.scrollView.contentSize.forDirection(withConfiguration: self.readerConfig) ?? 0
        self.pageIndicatorView?.totalPages = ((pageSize != 0) ? Int(ceil(contentSize / pageSize)) : 0)

        let pageOffSet = self.readerConfig.isDirection(webView.scrollView.contentOffset.x, webView.scrollView.contentOffset.x, webView.scrollView.contentOffset.y)
        let webViewPage = pageForOffset(pageOffSet, pageHeight: pageSize)

        self.pageIndicatorView?.currentPage = webViewPage
    }

    func pageForOffset(_ offset: CGFloat, pageHeight height: CGFloat) -> Int {
        guard (height != 0) else {
            return 0
        }

        let page = Int(ceil(offset / height))+1
        return page
    }

    func getCurrentIndexPath() -> IndexPath {
        let indexPaths = collectionView.indexPathsForVisibleItems
        var indexPath = IndexPath()

        if indexPaths.count > 1 {
            let first = indexPaths.first!
            let last = indexPaths.last!

            switch self.pageScrollDirection {
            case .up, .left:
                if first.compare(last) == .orderedAscending {
                    indexPath = last
                } else {
                    indexPath = first
                }
            default:
                if first.compare(last) == .orderedAscending {
                    indexPath = first
                } else {
                    indexPath = last
                }
            }
        } else {
            indexPath = indexPaths.first ?? IndexPath(row: 0, section: 0)
        }

        return indexPath
    }

    func frameForPage(_ page: Int) -> CGRect {
        return self.readerConfig.isDirection(
            CGRect(x: 0, y: self.pageHeight * CGFloat(page-1), width: self.pageWidth, height: self.pageHeight),
            CGRect(x: self.pageWidth * CGFloat(page-1), y: 0, width: self.pageWidth, height: self.pageHeight),
            CGRect(x: 0, y: self.pageHeight * CGFloat(page-1), width: self.pageWidth, height: self.pageHeight)
        )
    }
    
    
    func changePageWithNew(page: Int, andFragment fragment: String, animated: Bool = false, completion: (() -> Void)? = nil) {
        
        
        if (self.currentPageNumber == page) {
            if let currentPage = currentPage , fragment != "" {
                currentPage.handleAnchor(fragment, avoidBeginningAnchors: true, animated: animated)
            }
            completion?()
        } else {
            
            tempFragment = fragment
            changePageWith1(page: page, animated: animated, completion: { () -> Void in
                self.updateCurrentPage {
                    completion?()
                }
            })
        }
    }
    
    func changePageWith1(page: Int, andFragment fragment: String, animated: Bool = false, completion: (() -> Void)? = nil) {
        
        
        
//        folioReader.saveReaderState()
//
//        let chapter = FolioReaderChapterList(folioReader: folioReader, readerConfig: readerConfig, book: book, delegate: self)
//        let highlight = FolioReaderHighlightList(folioReader: folioReader, readerConfig: readerConfig)
//        let pageController = PageViewController(folioReader: folioReader, readerConfig: readerConfig)
//
//        pageController.viewControllerOne = chapter
//        pageController.viewControllerTwo = highlight
//        pageController.segmentedControlItems = [readerConfig.localizedContentsTitle, readerConfig.localizedHighlightsTitle]
//
//        let nav = UINavigationController(rootViewController: pageController)
//        window?.rootViewController = nav
//        window?.makeKeyAndVisible()
       // present(nav, animated: true, completion: nil)
        
//        if (self.currentPageNumber == page) {
//            if let currentPage = currentPage , fragment != "" {
//                currentPage.handleAnchor(fragment, avoidBeginningAnchors: true, animated: animated)
//            }
//            completion?()
//        } else {
//            tempFragment = fragment
//            changePageWith(page: page, animated: animated, completion: { () -> Void in
//                self.updateCurrentPage {
//                    completion?()
//                }
//            })
//        }
        
//        let strbook = UserDefaults.standard.value(forKey: "NewBook") as? String
//        let index = UserDefaults.standard.integer(forKey: "NEWIndex")
//        let config = FolioReaderConfig()
//        self.highlights = Highlight.allByBookId(withConfiguration: config, bookId: strbook!)
//        guard let highlight = highlights[safe: index+1] else { return }
//        self.folioReader.readerCenter?.changePageWith1(page: highlight.page, andFragment: highlight.highlightId)
    }
    

    open func changePageWith(page: Int, andFragment fragment: String, animated: Bool = false, completion: (() -> Void)? = nil) {
    
        if (self.currentPageNumber == page) {
            if let currentPage = currentPage , fragment != "" {
                currentPage.handleAnchor(fragment, avoidBeginningAnchors: true, animated: animated)
            }
            completion?()
        } else {
            
            tempFragment = fragment
            changePageWith(page: page, animated: animated, completion: { () -> Void in
                self.updateCurrentPage {
                    completion?()
                }
            })
        }
    }

    open func changePageWith(href: String, animated: Bool = false, completion: (() -> Void)? = nil) {
        let item = findPageByHref(href)
        let indexPath = IndexPath(row: item, section: 0)
        changePageWith(indexPath: indexPath, animated: animated, completion: { () -> Void in
            self.updateCurrentPage {
                completion?()
            }
        })
    }

    open func changePageWith(href: String, andAudioMarkID markID: String) {
        if recentlyScrolled { return } // if user recently scrolled, do not change pages or scroll the webview
        guard let currentPage = currentPage else { return }

        let item = findPageByHref(href)
        let pageUpdateNeeded = item+1 != currentPage.pageNumber
        let indexPath = IndexPath(row: item, section: 0)
        changePageWith(indexPath: indexPath, animated: true) { () -> Void in
            if pageUpdateNeeded {
                self.updateCurrentPage {
                    currentPage.audioMarkID(markID)
                }
            } else {
                currentPage.audioMarkID(markID)
            }
        }
    }
    
//    open func changePageWith1(indexPath: IndexPath, animated: Bool = false, completion: (() -> Void)? = nil) {
//        guard indexPathIsValid1(indexPath) else {
//            print("ERROR: Attempt to scroll to invalid index path")
//            completion?()
//            return
//        }
//
//        UIView.animate(withDuration: animated ? 0.3 : 0, delay: 0, options: UIView.AnimationOptions(), animations: { () -> Void in
//            self.collectionView.scrollToItem(at: indexPath, at: .direction(withConfiguration: self.readerConfig), animated: false)
//        }) { (finished: Bool) -> Void in
//            completion?()
//        }
//    }

    open func changePageWith(indexPath: IndexPath, animated: Bool = false, completion: (() -> Void)? = nil) {
        guard indexPathIsValid(indexPath) else {
            print("ERROR: Attempt to scroll to invalid index path")
            completion?()
            return
        }
        

        UIView.animate(withDuration: animated ? 0.3 : 0, delay: 0, options: UIView.AnimationOptions(), animations: { () -> Void in
            self.collectionView.scrollToItem(at: indexPath, at: .direction(withConfiguration: self.readerConfig), animated: false)
        }) { (finished: Bool) -> Void in
            completion?()
        }
    }
    
    open func changePageWith1(indexPath: IndexPath, animated: Bool = false, completion: (() -> Void)? = nil) {
        guard indexPathIsValid(indexPath) else {
            print("ERROR: Attempt to scroll to invalid index path")
            completion?()
            return
        }
        
        
        UIView.animate(withDuration: animated ? 0.3 : 0, delay: 0, options: UIView.AnimationOptions(), animations: { () -> Void in
            self.collectionView.scrollToItem(at: indexPath, at: .direction(withConfiguration: self.readerConfig), animated: false)
        }) { (finished: Bool) -> Void in
            completion?()
        }
    }
    
    
    
    open func changePageWith(href: String, pageItem: Int, animated: Bool = false, completion: (() -> Void)? = nil) {
        changePageWith(href: href, animated: animated) {
            self.changePageItem(to: pageItem)
        }
    }

    func indexPathIsValid(_ indexPath: IndexPath) -> Bool {
        let section = indexPath.section
        let row = indexPath.row
        let lastSectionIndex = numberOfSections(in: collectionView) - 1

        //Make sure the specified section exists
        if section > lastSectionIndex {
            return false
        }

        let rowCount = self.collectionView(collectionView, numberOfItemsInSection: indexPath.section) - 1
        return row <= rowCount
    }
    
//    func indexPathIsValid1(_ indexPath: IndexPath) -> Bool {
//        let section = indexPath.section
//        let row = indexPath.row
//        let lastSectionIndex = numberOfSections(in: collectionView) - 1
//
//        //Make sure the specified section exists
//        if section > lastSectionIndex {
//            return false
//        }
//
//        let rowCount = self.collectionView(collectionView, numberOfItemsInSection: indexPath.section) - 1
//        return row <= rowCount
//    }

    open func isLastPage() -> Bool{
        return (currentPageNumber == self.nextPageNumber)
    }

    public func changePageToNext(_ completion: (() -> Void)? = nil) {
        changePageWith(page: self.nextPageNumber, animated: true) { () -> Void in
            completion?()
        }
    }

    public func changePageToPrevious(_ completion: (() -> Void)? = nil) {
        changePageWith(page: self.previousPageNumber, animated: true) { () -> Void in
            completion?()
        }
    }
    
    public func changePageItemToNext(_ completion: (() -> Void)? = nil) {
        // TODO: It was implemented for horizontal orientation.
        // Need check page orientation (v/h) and make correct calc for vertical
        guard
            let cell = collectionView.cellForItem(at: getCurrentIndexPath()) as? FolioReaderPage,
            let contentOffset = cell.webView?.scrollView.contentOffset,
            let contentOffsetXLimit = cell.webView?.scrollView.contentSize.width else {
                completion?()
                return
        }
        
        let cellSize = cell.frame.size
        let contentOffsetX = contentOffset.x + cellSize.width
        
        if contentOffsetX >= contentOffsetXLimit {
            changePageToNext(completion)
        } else {
            cell.scrollPageToOffset(contentOffsetX, animated: true)
        }
        
        completion?()
    }

    public func getCurrentPageItemNumber() -> Int {
        guard let page = currentPage, let webView = page.webView else { return 0 }
        
        let pageSize = readerConfig.isDirection(pageHeight, pageWidth, pageHeight)
        let pageOffSet = readerConfig.isDirection(webView.scrollView.contentOffset.x, webView.scrollView.contentOffset.x, webView.scrollView.contentOffset.y)
        let webViewPage = pageForOffset(pageOffSet, pageHeight: pageSize)
        
        return webViewPage
    }
    
    public func getCurrentPageProgress() -> Float {
        guard let page = currentPage else { return 0 }
        
        let pageSize = self.readerConfig.isDirection(pageHeight, self.pageWidth, pageHeight)
        let contentSize = page.webView?.scrollView.contentSize.forDirection(withConfiguration: self.readerConfig) ?? 0
        let totalPages = ((pageSize != 0) ? Int(ceil(contentSize / pageSize)) : 0)
        let currentPageItem = getCurrentPageItemNumber()
        
        if totalPages > 0 {
            var progress = Float((currentPageItem * 100) / totalPages)
            
            if progress < 0 { progress = 0 }
            if progress > 100 { progress = 100 }
            
            return progress
        }
        
        return 0
    }

    public func changePageItemToPrevious(_ completion: (() -> Void)? = nil) {
        // TODO: It was implemented for horizontal orientation.
        // Need check page orientation (v/h) and make correct calc for vertical
        guard
            let cell = collectionView.cellForItem(at: getCurrentIndexPath()) as? FolioReaderPage,
            let contentOffset = cell.webView?.scrollView.contentOffset else {
                completion?()
                return
        }
        
        let cellSize = cell.frame.size
        let contentOffsetX = contentOffset.x - cellSize.width
        
        if contentOffsetX < 0 {
            changePageToPrevious(completion)
        } else {
            cell.scrollPageToOffset(contentOffsetX, animated: true)
        }
        
        completion?()
    }

    public func changePageItemToLast(animated: Bool = true, _ completion: (() -> Void)? = nil) {
        // TODO: It was implemented for horizontal orientation.
        // Need check page orientation (v/h) and make correct calc for vertical
        guard
            let cell = collectionView.cellForItem(at: getCurrentIndexPath()) as? FolioReaderPage,
            let contentSize = cell.webView?.scrollView.contentSize else {
                completion?()
                return
        }
        
        let cellSize = cell.frame.size
        var contentOffsetX: CGFloat = 0.0
        
        if contentSize.width > 0 && cellSize.width > 0 {
            contentOffsetX = (cellSize.width * (contentSize.width / cellSize.width)) - cellSize.width
        }
        
        if contentOffsetX < 0 {
            contentOffsetX = 0
        }
        
        cell.scrollPageToOffset(contentOffsetX, animated: animated)
        
        completion?()
    }

    public func changePageItem(to: Int, animated: Bool = true, completion: (() -> Void)? = nil) {
        // TODO: It was implemented for horizontal orientation.
        // Need check page orientation (v/h) and make correct calc for vertical
        guard
            let cell = collectionView.cellForItem(at: getCurrentIndexPath()) as? FolioReaderPage,
            let contentSize = cell.webView?.scrollView.contentSize else {
                delegate?.pageItemChanged?(getCurrentPageItemNumber())
                completion?()
                return
        }
        
        let cellSize = cell.frame.size
        var contentOffsetX: CGFloat = 0.0
        
        if contentSize.width > 0 && cellSize.width > 0 {
            contentOffsetX = (cellSize.width * CGFloat(to)) - cellSize.width
        }
        
        if contentOffsetX > contentSize.width {
            contentOffsetX = contentSize.width - cellSize.width
        }
        
        if contentOffsetX < 0 {
            contentOffsetX = 0
        }
        
        UIView.animate(withDuration: animated ? 0.3 : 0, delay: 0, options: UIView.AnimationOptions(), animations: { () -> Void in
            cell.scrollPageToOffset(contentOffsetX, animated: animated)
        }) { (finished: Bool) -> Void in
            self.updateCurrentPage {
                completion?()
            }
        }
    }

    /**
     Find a page by FRTocReference.
     */
    public func findPageByResource(_ reference: FRTocReference) -> Int {
        var count = 0
        for item in self.book.spine.spineReferences {
            if let resource = reference.resource, item.resource == resource {
                return count
            }
            count += 1
        }
        return count
    }

    /**
     Find a page by href.
     */
    public func findPageByHref(_ href: String) -> Int {
        var count = 0
        for item in self.book.spine.spineReferences {
            if item.resource.href == href {
                return count
            }
            count += 1
        }
        return count
    }

    /**
     Find and return the current chapter resource.
     */
    public func getCurrentChapter() -> FRResource? {
        var foundResource: FRResource?

        func search(_ items: [FRTocReference]) {
            for item in items {
                guard foundResource == nil else { break }

                if let reference = book.spine.spineReferences[safe: (currentPageNumber - 1)], let resource = item.resource, resource == reference.resource {
                    foundResource = resource
                    break
                } else if let children = item.children, children.isEmpty == false {
                    search(children)
                }
            }
        }
        search(book.flatTableOfContents)

        return foundResource
    }

    /**
     Return the current chapter progress based on current chapter and total of chapters.
     */
    public func getCurrentChapterProgress() -> CGFloat {
        let total = totalPages
        let current = currentPageNumber
        
        if total == 0 {
            return 0
        }
        
        return CGFloat((100 * current) / total)
    }

    /**
     Find and return the current chapter name.
     */
    public func getCurrentChapterName() -> String? {
        var foundChapterName: String?
        
        func search(_ items: [FRTocReference]) {
            for item in items {
                guard foundChapterName == nil else { break }
                
                if let reference = self.book.spine.spineReferences[safe: (self.currentPageNumber - 1)],
                    let resource = item.resource,
                    resource == reference.resource,
                    let title = item.title {
                    foundChapterName = title
                } else if let children = item.children, children.isEmpty == false {
                    search(children)
                }
            }
        }
        search(self.book.flatTableOfContents)
        
        return foundChapterName
    }

    // MARK: Public page methods

    /**
     Changes the current page of the reader.

     - parameter page: The target page index. Note: The page index starts at 1 (and not 0).
     - parameter animated: En-/Disables the animation of the page change.
     - parameter completion: A Closure which is called if the page change is completed.
     */
    public func changePageWith(page: Int, animated: Bool = false, completion: (() -> Void)? = nil) {
        if page > 0 && page-1 < totalPages {
            let indexPath = IndexPath(row: page-1, section: 0)
            changePageWith(indexPath: indexPath, animated: animated, completion: { () -> Void in
                self.updateCurrentPage {
                    completion?()
                }
            })
        }
    }
    
    
    public func changePageWith1(page: Int, animated: Bool = false, completion: (() -> Void)? = nil) {
        if page > 0 && page-1 < totalPages {
            let indexPath = IndexPath(row: page-1, section: 0)
            changePageWith1(indexPath: indexPath, animated: animated, completion: { () -> Void in
                self.updateCurrentPage {
                    completion?()
                }
            })
        }
    }
    
    
//    public func changePageWith1(page: Int, animated: Bool = false, completion: (() -> Void)? = nil) {
//        if page > 0 && page-1 < 12 {
//            let indexPath = IndexPath(row: page-1, section: 0)
//            changePageWith1(indexPath: indexPath, animated: animated, completion: { () -> Void in
//                self.updateCurrentPage {
//                    completion?()
//                }
//            })
//        }
//    }
    
    // MARK: - Audio Playing

    func audioMark(href: String, fragmentID: String) {
        changePageWith(href: href, andAudioMarkID: fragmentID)
    }
    
    
    
    @objc func shareChapter1(_ sender: UIBarButtonItem) {
        
                guard let currentPage = currentPage else { return }
        
                if let chapterText = currentPage.webView?.js("getBodyText()") {
                    let htmlText = chapterText.replacingOccurrences(of: "[\\n\\r]+", with: "<br />", options: .regularExpression)
                    var subject = readerConfig.localizedShareChapterSubject
                    var html = ""
                    var text = ""
                    var bookTitle = ""
                    var chapterName = ""
                    var authorName = ""
                    var shareItems = [AnyObject]()
        
                    // Get book title
                    if let title = self.book.title {
                        bookTitle = title
                        subject += " “\(title)”"
                    }
        
                    // Get chapter name
                    if let chapter = getCurrentChapterName() {
                        chapterName = chapter
                    }
        
                    // Get author name
                    if let author = self.book.metadata.creators.first {
                        authorName = author.name
                    }
        
                    // Sharing html and text
                    html = "<html><body>"
                    html += "<br /><hr> <p>\(htmlText)</p> <hr><br />"
                    html += "<center><p style=\"color:gray\">"+readerConfig.localizedShareAllExcerptsFrom+"</p>"
                    html += "<b>\(bookTitle)</b><br />"
                    html += readerConfig.localizedShareBy+" <i>\(authorName)</i><br />"
        
                    if let bookShareLink = readerConfig.localizedShareWebLink {
                        html += "<a href=\"\(bookShareLink.absoluteString)\">\(bookShareLink.absoluteString)</a>"
                        shareItems.append(bookShareLink as AnyObject)
                    }
        
                    html += "</center></body></html>"
                    text = "\(chapterName)\n\n“\(chapterText)” \n\n\(bookTitle) \n\(readerConfig.localizedShareBy) \(authorName)"
        
                    let act = FolioReaderSharingProvider(subject: subject, text: text, html: html)
                    shareItems.insert(contentsOf: [act, "" as AnyObject], at: 0)
        
                    let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
                    activityViewController.excludedActivityTypes = [UIActivity.ActivityType.print, UIActivity.ActivityType.postToVimeo]
        
                    // Pop style on iPad
                    if let actv = activityViewController.popoverPresentationController {
                        actv.barButtonItem = sender
                    }
        
                    present(activityViewController, animated: true, completion: nil)
                }
    }
    

    // MARK: - Sharing

    /**
     Sharing chapter method.
     */
    
    
    @objc func shareChapter(_ sender: UIBarButtonItem) {
      //  dismiss()
       // folioReader.close()
        self.dictBookDetails = UserDefaults.standard.dictionary(forKey: "VideoData")!
       // if let userSubscription = dictBookDetails["user_subscription_type"] as? Int{
           // if userSubscription == 1 {
               // self.view.makeToast(message: "Please Upgrade your plan to listen audio.")
            //}else if userSubscription == 2 {
                if DataManager.isConnectedToNetwork() {
                    if (UIDevice.current.userInterfaceIdiom == .pad){
                        let story = UIStoryboard(name: "Main", bundle: nil)
                        let obj = story.instantiateViewController(withIdentifier: "ListinMusic_IpadVC") as! ListinMusic_IpadVC
                        obj.pagenumbernew = self.currentPageNumber
                        obj.dictBookDetails = self.dictBookDetails
                        self.navigationController?.pushViewController(obj, animated: true)
                    }else{
                        let story = UIStoryboard(name: "Main", bundle: nil)
                        let obj = story.instantiateViewController(withIdentifier: "ListinMusicVC") as! ListinMusicVC
                        obj.pagenumbernew = self.currentPageNumber
                        obj.dictBookDetails = self.dictBookDetails
                        self.navigationController?.pushViewController(obj, animated: true)
                    }
                    
               // } else {
                 //   self.view.makeToast(message: "No Internet Connection.")
               // }
            }else {
                if DataManager.isConnectedToNetwork() {
                    if (UIDevice.current.userInterfaceIdiom == .pad){

                    let story = UIStoryboard(name: "Main", bundle: nil)
                    let obj = story.instantiateViewController(withIdentifier: "ListinMusic_IpadVC") as! ListinMusic_IpadVC
                    obj.pagenumbernew = self.currentPageNumber
                    obj.dictBookDetails = self.dictBookDetails
                    self.navigationController?.pushViewController(obj, animated: true)
                    }else{
                        let story = UIStoryboard(name: "Main", bundle: nil)
                        let obj = story.instantiateViewController(withIdentifier: "ListinMusicVC") as! ListinMusicVC
                        obj.pagenumbernew = self.currentPageNumber
                        obj.dictBookDetails = self.dictBookDetails
                        self.navigationController?.pushViewController(obj, animated: true)
                    }
                } else {
                    self.view.makeToast(message: "No Internet Connection.")
                }
            }
            
            
       // }
       /// NotificationCenter.default.post(name: NSNotification.Name("AudioPlayer"), object: nil)
        
//        guard let currentPage = currentPage else { return }
//
//        if let chapterText = currentPage.webView?.js("getBodyText()") {
//            let htmlText = chapterText.replacingOccurrences(of: "[\\n\\r]+", with: "<br />", options: .regularExpression)
//            var subject = readerConfig.localizedShareChapterSubject
//            var html = ""
//            var text = ""
//            var bookTitle = ""
//            var chapterName = ""
//            var authorName = ""
//            var shareItems = [AnyObject]()
//
//            // Get book title
//            if let title = self.book.title {
//                bookTitle = title
//                subject += " “\(title)”"
//            }
//
//            // Get chapter name
//            if let chapter = getCurrentChapterName() {
//                chapterName = chapter
//            }
//
//            // Get author name
//            if let author = self.book.metadata.creators.first {
//                authorName = author.name
//            }
//
//            // Sharing html and text
//            html = "<html><body>"
//            html += "<br /><hr> <p>\(htmlText)</p> <hr><br />"
//            html += "<center><p style=\"color:gray\">"+readerConfig.localizedShareAllExcerptsFrom+"</p>"
//            html += "<b>\(bookTitle)</b><br />"
//            html += readerConfig.localizedShareBy+" <i>\(authorName)</i><br />"
//
//            if let bookShareLink = readerConfig.localizedShareWebLink {
//                html += "<a href=\"\(bookShareLink.absoluteString)\">\(bookShareLink.absoluteString)</a>"
//                shareItems.append(bookShareLink as AnyObject)
//            }
//
//            html += "</center></body></html>"
//            text = "\(chapterName)\n\n“\(chapterText)” \n\n\(bookTitle) \n\(readerConfig.localizedShareBy) \(authorName)"
//
//            let act = FolioReaderSharingProvider(subject: subject, text: text, html: html)
//            shareItems.insert(contentsOf: [act, "" as AnyObject], at: 0)
//
//            let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
//            activityViewController.excludedActivityTypes = [UIActivity.ActivityType.print, UIActivity.ActivityType.postToVimeo]
//
//            // Pop style on iPad
//            if let actv = activityViewController.popoverPresentationController {
//                actv.barButtonItem = sender
//            }
//
//            present(activityViewController, animated: true, completion: nil)
//        }
    }
    
    func addd() {
        folioReader.saveReaderState()
        
        let chapter = FolioReaderChapterList(folioReader: folioReader, readerConfig: readerConfig, book: book, delegate: self)
        let highlight = FolioReaderHighlightList(folioReader: folioReader, readerConfig: readerConfig)
        let pageController = PageViewController(folioReader: folioReader, readerConfig: readerConfig)
        
       // pageController.viewControllerOne = chapter
        pageController.viewControllerTwo = highlight
        pageController.segmentedControlItems = [readerConfig.localizedContentsTitle, readerConfig.localizedHighlightsTitle]
        let defaults = UserDefaults.standard
        defaults.set("ONE", forKey: "PAGEC")
        defaults.synchronize()
        let nav = UINavigationController(rootViewController: pageController)
        present(nav, animated: true, completion: nil)
    }
    
    
    
    func getReadingBook() {
        let parameterDictionary = NSMutableDictionary()
        let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
        parameterDictionary.setValue(user_id, forKey: "user_id")
        let methodName = "getReadingBook"
        
        
        DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
            let status  = DataManager.getVal(responseData?["status"]) as! String
            let message  = DataManager.getVal(responseData?["message"]) as! String
            
            if status == "1" {
                if let response  = DataManager.getVal(responseData?["data"]) as? [[String:Any]] {
                    if response.count == 2 {
                      //  self.rateApp()
                    }else if response.count == 3 {
                        self.rateApp()
                        self.Apiboovalue = true
                    }else {
                        
                    }
                }
            }  else {
            }
        }
    }
    
    
    
    
       //MARK: - OFFLINE BOOK DOWNLOAD
    
    @objc func downloadBookOffline(_ sender: UIBarButtonItem) {
        let downloadwifiStatus = UserDefaults.standard.value(forKey: "DownloadUsingWifi") as? Bool ?? true
        if downloadwifiStatus == false {
            if checkWiFi() {
                //self.view.makeToast(message: "Turn ON download using wifi from settings")
            } else {
                var dictBookDetails = [String: Any]()
                self.showHud()
                let parameterDictionary = NSMutableDictionary()
                let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
                let bookId = DataManager.getVal(Config().AppUserDefaults.value(forKey: "book_id")) as! String
                
                parameterDictionary.setValue(user_id, forKey: "user_id")
                parameterDictionary.setValue(bookId, forKey: "book_id")
                let methodName = "getBookDetail"
                
                DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
                    let status  = DataManager.getVal(responseData?["status"]) as! String
                    let message  = DataManager.getVal(responseData?["message"]) as! String
                    
                    if status == "1" {
                        if let response = DataManager.getVal(responseData?["data"]) as? [String: Any]{
                            dictBookDetails = response
                            
                            var dic = [String:Any]()
                            if let id = dictBookDetails["book_id"] as? Int {
                                dic["book_id"] = Int64(id)
                            }
                            dic["book_title"] = dictBookDetails["book_title"] as? String
                            if let authorName = dictBookDetails["author"] as? String {
                                dic["author"] = authorName
                            }
                            
                            if let descr = dictBookDetails["overview"] as? String {
                                let trimmed2 = descr.replacingOccurrences(of: "<p>", with: "")
                                let trimmed = trimmed2.replacingOccurrences(of: "</p>", with: "")
                                dic["descript"] = trimmed
                            }
                            
                            
                            if let coverImage =  dictBookDetails["cover_image"] as? String {
                                let coverImageUrl = URL(string: coverImage)
                                let coverImageData = try! Data(contentsOf: coverImageUrl!)
                                dic["book_image"]  =  coverImageData
                            }
                            if let id = dictBookDetails["book_id"] as? Int {
                                dic["book_id"] = Int64(id)
                            }
                            dic["contains_Book"] = true
                            DownloadEnitity.shared.saveData(dict: dic)
                            self.sendDownloadNotification(bookName: dic["book_title"] as? String ?? "")

                        }
                        self.view.makeToast(message: "Downloaded Successfully")
                        //self.rateApp()
                    }else {
                        print("Book not saved sucessfully")
                    }
                    self.clearHud()
                }
            }} else {
            var dictBookDetails = [String: Any]()
            self.showHud()
            let parameterDictionary = NSMutableDictionary()
            let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
            let bookId = DataManager.getVal(Config().AppUserDefaults.value(forKey: "book_id")) as! String
            
            parameterDictionary.setValue(user_id, forKey: "user_id")
            parameterDictionary.setValue(bookId, forKey: "book_id")
            let methodName = "getBookDetail"
            
            DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
                let status  = DataManager.getVal(responseData?["status"]) as! String
                let message  = DataManager.getVal(responseData?["message"]) as! String
                
                if status == "1" {
                    if let response = DataManager.getVal(responseData?["data"]) as? [String: Any]{
                        dictBookDetails = response
                        
                        var dic = [String:Any]()
                        if let id = dictBookDetails["book_id"] as? Int {
                            dic["book_id"] = Int64(id)
                        }
                        dic["book_title"] = dictBookDetails["book_title"] as? String
                        if let authorName = dictBookDetails["author"] as? String {
                            dic["author"] = authorName
                        }
                        
                        if let descr = dictBookDetails["overview"] as? String {
                            let trimmed2 = descr.replacingOccurrences(of: "<p>", with: "")
                            let trimmed = trimmed2.replacingOccurrences(of: "</p>", with: "")
                            dic["descript"] = trimmed
                        }
                        
                        
                        if let coverImage =  dictBookDetails["cover_image"] as? String {
                            let coverImageUrl = URL(string: coverImage)
                            let coverImageData = try! Data(contentsOf: coverImageUrl!)
                            dic["book_image"]  =  coverImageData
                        }
                        if let id = dictBookDetails["book_id"] as? Int {
                            dic["book_id"] = Int64(id)
                        }
                        dic["contains_Book"] = true
                        DownloadEnitity.shared.saveData(dict: dic)
                        self.sendDownloadNotification(bookName: dic["book_title"] as? String ?? "")

                    }
                    self.view.makeToast(message: "Downloaded Successfully")
                    //self.rateApp()
                }else {
                    print("Book not saved sucessfully")
                }
                self.clearHud()
            }
        }
        
    }
    
    //MARK: - Book Audio Download Notification

      func sendDownloadNotification(bookName: String) {
           let parameterDictionary = NSMutableDictionary()
           let user_id = DataManager.getVal(Config().AppUserDefaults.value(forKey: "user_id")) as! String
           parameterDictionary.setValue(user_id, forKey: "user_id")
           parameterDictionary.setValue(bookName, forKey: "book_name")
           parameterDictionary.setValue("summary", forKey: "DownloadType")
           
           print(parameterDictionary)
           
           //        "book_name":"A Young Woman's Guide to Making Right Decision",
           //               "user_id":309,"DownloadType":"video"
           let methodName = "sendDownloadNotification"
           
           DataManager.getAPIResponse(parameterDictionary , methodName: methodName){(responseData,error)-> Void in
               let status = DataManager.getVal(responseData?["status"]) as! String
               let message = DataManager.getVal(responseData?["message"]) as! String
               if status == "1" {
                   
               } else{
                   
               }
           }
       }
    /**
     Sharing highlight method.
     */
    
    
    func fetchdatabyid() {
        self.rangy = UserDefaults.standard.value(forKey: "RangeNE") as? String
        let appDelegate =   (UIApplication.shared.delegate) as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FolioReaderdatabase")
                request.predicate = NSPredicate(format: "rangy = %@", rangy)
                request.returnsObjectsAsFaults = false
                do {
                    let result = try managedContext.fetch(request)
                    for data in result as! [NSManagedObject] {
                    self.note = data.value(forKey: "note") as? String
              }
                    
                } catch {
                    
                    print("Failed")
                }
    }
    
    func shareHighlight(_ string: String, rect: CGRect) {
        var subject = readerConfig.localizedShareHighlightSubject
        var html = ""
        var text = ""
        var bookTitle = ""
        var chapterName = ""
        var authorName = ""
        var shareItems = [AnyObject]()

        // Get book title
        if let title = self.book.title {
            bookTitle = title
            subject += " “\(title)”"
        }

        // Get chapter name
        if let chapter = getCurrentChapterName() {
            chapterName = chapter
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
        
        
        
        // get note
        self.fetchdatabyid()

        // Sharing html and text
        html = "<html><body>"
        html += "<br /><hr> <p>\(chapterName)</p>"
        html += "<p>\(string)</p> <hr><br />"
        html += "<center><p style=\"color:gray\">"+readerConfig.localizedShareAllExcerptsFrom+"</p>"
        html += "<b>\(bookTitle)</b><br />"
        html += readerConfig.localizedShareBy+" <i>\(authorName)</i><br />"

        if let bookShareLink = readerConfig.localizedShareWebLink {
            html += "<a href=\"\(bookShareLink.absoluteString)\">\(bookShareLink.absoluteString)</a>"
            shareItems.append(bookShareLink as AnyObject)
        }
        let newbook = bookTitle.replacingOccurrences(of: "summary", with: "")
        let booknew =  "\"\(newbook)\""
        let newnote  = "\"\(self.note ?? "")\""
        if newnote == "\"\"" || newnote == nil || newnote == "" {
            html += "</center></body></html>"
            text = "\("This excerpt is brought to you by HolyReads.com from the summary of " + booknew + " by " + authorName + ".")\n\n“\(string)”\n\n \("Subscribe to Holy Reads to read, listen, or watch the summaries of bestselling Christian books.") \n\n\("Happy Reading!") \n\n\(readerConfig.localizedShareBy)"
        }else {
            html += "</center></body></html>"
            text = "\("This excerpt is brought to you by HolyReads.com from the summary of " + booknew + " by " + authorName + ".")\n\n“\(string)”\n\n \("Here’s my note about this excerpt:" + "  " + newnote)\n\n \("Subscribe to Holy Reads to read, listen, or watch the summaries of bestselling Christian books.") \n\n\("Happy Reading!") \n\n\(readerConfig.localizedShareBy)"
        }
        

        let act = FolioReaderSharingProvider(subject: subject, text: text, html: html)
        shareItems.insert(contentsOf: [act, "" as AnyObject], at: 0)

        let activityViewController = UIActivityViewController(activityItems: shareItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivity.ActivityType.print, UIActivity.ActivityType.postToVimeo]

        // Pop style on iPad
        if let actv = activityViewController.popoverPresentationController {
            actv.sourceView = currentPage
            actv.sourceRect = rect
        }

        present(activityViewController, animated: true, completion: nil)
    }

    // MARK: - ScrollView Delegate

    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.isScrolling = true
        clearRecentlyScrolled()
        recentlyScrolled = true
        pointNow = scrollView.contentOffset
        
        if (scrollView is UICollectionView) {
            scrollView.isUserInteractionEnabled = false
        }

        if let currentPage = currentPage {
           // currentPage.webView?.createMenu(options: true)
            currentPage.webView?.setMenuVisible(false)
        }

        scrollScrubber?.scrollViewWillBeginDragging(scrollView)
    }

    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if (navigationController?.isNavigationBarHidden == false) {
            self.toggleBars()
        }

        scrollScrubber?.scrollViewDidScroll(scrollView)

        let isCollectionScrollView = (scrollView is UICollectionView)
        let scrollType: ScrollType = ((isCollectionScrollView == true) ? .chapter : .page)

        // Update current reading page
        if (isCollectionScrollView == false), let page = currentPage, let webView = page.webView {

            let pageSize = self.readerConfig.isDirection(self.pageHeight, self.pageWidth, self.pageHeight)
            let contentOffset = webView.scrollView.contentOffset.forDirection(withConfiguration: self.readerConfig)
            let contentSize = webView.scrollView.contentSize.forDirection(withConfiguration: self.readerConfig)
            if (contentOffset + pageSize <= contentSize) {

                let webViewPage = pageForOffset(contentOffset, pageHeight: pageSize)

                if (readerConfig.scrollDirection == .horizontalWithVerticalContent) {
                    let currentIndexPathRow = (page.pageNumber - 1)
                    // if the cell reload doesn't save the top position offset
                    if let oldOffSet = self.currentWebViewScrollPositions[currentIndexPathRow], (abs(oldOffSet.y - scrollView.contentOffset.y) > 100) {
                        // Do nothing
                    } else {
                        self.currentWebViewScrollPositions[currentIndexPathRow] = scrollView.contentOffset
                    }
                }

                if (pageIndicatorView?.currentPage != webViewPage) {
                    pageIndicatorView?.currentPage = webViewPage
                }
                
                self.delegate?.pageItemChanged?(webViewPage)
            }
        }

        self.updatePageScrollDirection(inScrollView: scrollView, forScrollType: scrollType)
    }

    private func updatePageScrollDirection(inScrollView scrollView: UIScrollView, forScrollType scrollType: ScrollType) {

        let defaults = UserDefaults.standard
        defaults.set("nospace", forKey: "SPACE")
        defaults.synchronize()
        
        
        let scrollViewContentOffsetForDirection = scrollView.contentOffset.forDirection(withConfiguration: self.readerConfig, scrollType: scrollType)
        let pointNowForDirection = pointNow.forDirection(withConfiguration: self.readerConfig, scrollType: scrollType)
        // The movement is either positive or negative. This happens if the page change isn't completed. Toggle to the other scroll direction then.
        let isCurrentlyPositive = (self.pageScrollDirection == .left || self.pageScrollDirection == .up)

        if (scrollViewContentOffsetForDirection < pointNowForDirection) {
            self.pageScrollDirection = .negative(withConfiguration: self.readerConfig, scrollType: scrollType)
        } else if (scrollViewContentOffsetForDirection > pointNowForDirection) {
            self.pageScrollDirection = .positive(withConfiguration: self.readerConfig, scrollType: scrollType)
        } else if (isCurrentlyPositive == true) {
            self.pageScrollDirection = .negative(withConfiguration: self.readerConfig, scrollType: scrollType)
        } else {
            self.pageScrollDirection = .positive(withConfiguration: self.readerConfig, scrollType: scrollType)
        }
    }

    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.isScrolling = false
        
        if (scrollView is UICollectionView) {
            scrollView.isUserInteractionEnabled = true
        }

        // Perform the page after a short delay as the collection view hasn't completed it's transition if this method is called (the index paths aren't right during fast scrolls).
        delay(0.2, closure: { [weak self] in
            if (self?.readerConfig.scrollDirection == .horizontalWithVerticalContent),
                let cell = ((scrollView.superview as? UIWebView)?.delegate as? FolioReaderPage) {
                let currentIndexPathRow = cell.pageNumber - 1
                self?.currentWebViewScrollPositions[currentIndexPathRow] = scrollView.contentOffset
            }

            if (scrollView is UICollectionView) {
                guard let instance = self else {
                    return
                }
                
                if instance.totalPages > 0 {
                    instance.updateCurrentPage()
                    instance.delegate?.pageItemChanged?(instance.getCurrentPageItemNumber())
                }
            } else {
                self?.scrollScrubber?.scrollViewDidEndDecelerating(scrollView)
            }
        })
    }

    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        recentlyScrolledTimer = Timer(timeInterval:recentlyScrolledDelay, target: self, selector: #selector(FolioReaderCenter.clearRecentlyScrolled), userInfo: nil, repeats: false)
        RunLoop.current.add(recentlyScrolledTimer, forMode: RunLoop.Mode.common)
    }

    @objc func clearRecentlyScrolled() {
        if(recentlyScrolledTimer != nil) {
            recentlyScrolledTimer.invalidate()
            recentlyScrolledTimer = nil
        }
        recentlyScrolled = false
    }

    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollScrubber?.scrollViewDidEndScrollingAnimation(scrollView)
    }

    // MARK: NavigationBar Actions

    @objc func closeReader(_ sender: UIBarButtonItem) {
        dismiss()
        folioReader.close()
        NotificationCenter.default.post(name: NSNotification.Name("closevideo"), object: nil)
    }

    /**
     Present chapter list
     */
    @objc func presentChapterList(_ sender: UIBarButtonItem) {
        folioReader.saveReaderState()

        let chapter = FolioReaderChapterList(folioReader: folioReader, readerConfig: readerConfig, book: book, delegate: self)
        let highlight = FolioReaderHighlightList(folioReader: folioReader, readerConfig: readerConfig)
        let pageController = PageViewController(folioReader: folioReader, readerConfig: readerConfig)

        pageController.viewControllerOne = chapter
        pageController.viewControllerTwo = highlight
        pageController.segmentedControlItems = [readerConfig.localizedContentsTitle, readerConfig.localizedHighlightsTitle]
        let defaults = UserDefaults.standard
        defaults.set("TWO", forKey: "PAGEC")
        defaults.synchronize()
        let nav = UINavigationController(rootViewController: pageController)
        present(nav, animated: true, completion: nil)
    }

    /**
     Present fonts and settings menu
     */
    @objc func presentFontsMenu() {
        folioReader.saveReaderState()
        hideBars()

        let menu = FolioReaderFontsMenu(folioReader: folioReader, readerConfig: readerConfig)
        menu.modalPresentationStyle = .custom

        animator = ZFModalTransitionAnimator(modalViewController: menu)
        animator.isDragable = false
        animator.bounces = false
        animator.behindViewAlpha = 1
        animator.behindViewScale = 1
        animator.transitionDuration = 0.6
        animator.direction = ZFModalTransitonDirection.bottom

        menu.transitioningDelegate = animator
        self.present(menu, animated: true, completion: nil)
    }

    /**
     Present audio player menu
     */
    @objc func presentPlayerMenu(_ sender: UIBarButtonItem) {
//        dismiss()
//        folioReader.close()
//        NotificationCenter.default.post(name: NSNotification.Name("VideoPlayer"), object: nil)
         self.dictBookDetails = UserDefaults.standard.dictionary(forKey: "VideoData")!
        if (UIDevice.current.userInterfaceIdiom == .pad){
            let story = UIStoryboard(name: "Main", bundle: nil)
            let obj = story.instantiateViewController(withIdentifier: "WatchVideo_IpadVC") as! WatchVideo_IpadVC
            obj.dictBookDetails = self.dictBookDetails
            self.navigationController?.pushViewController(obj, animated: true)
        }else{
            let story = UIStoryboard(name: "Main", bundle: nil)
            let obj = story.instantiateViewController(withIdentifier: "WatchVideoVC") as! WatchVideoVC
            obj.dictBookDetails = self.dictBookDetails
            self.navigationController?.pushViewController(obj, animated: true)
        }
//        if let userSubscription = dictBookDetails["user_subscription_type"] as? Int{
//            if userSubscription == 1 {
//                self.view.makeToast(message: "Please Upgrade your plan to watch video.")
//            } else if userSubscription == 2 {
//                self.view.makeToast(message: "Please Upgrade your planwatch video.")
//            }
//            else{
//                if (UIDevice.current.userInterfaceIdiom == .pad){
//                    let story = UIStoryboard(name: "Main", bundle: nil)
//                    let obj = story.instantiateViewController(withIdentifier: "WatchVideo_IpadVC") as! WatchVideo_IpadVC
//                    obj.dictBookDetails = self.dictBookDetails
//                    self.navigationController?.pushViewController(obj, animated: true)
//                }else{
//                    let story = UIStoryboard(name: "Main", bundle: nil)
//                    let obj = story.instantiateViewController(withIdentifier: "WatchVideoVC") as! WatchVideoVC
//                    obj.dictBookDetails = self.dictBookDetails
//                    self.navigationController?.pushViewController(obj, animated: true)
//                }
//
//            }
//        }
//        folioReader.saveReaderState()
//        hideBars()
//
//        let menu = FolioReaderPlayerMenu(folioReader: folioReader, readerConfig: readerConfig)
//        menu.modalPresentationStyle = .custom
//
//        animator = ZFModalTransitionAnimator(modalViewController: menu)
//        animator.isDragable = true
//        animator.bounces = false
//        animator.behindViewAlpha = 0.4
//        animator.behindViewScale = 1
//        animator.transitionDuration = 0.6
//        animator.direction = ZFModalTransitonDirection.bottom
//
//        menu.transitioningDelegate = animator
//
//
//        present(menu, animated: true, completion: nil)
        

    }

    /**
     Present Quote Share
     */
    func presentQuoteShare(_ string: String) {
        let quoteShare = FolioReaderQuoteShare(initWithText: string, readerConfig: readerConfig, folioReader: folioReader, book: book)
        let nav = UINavigationController(rootViewController: quoteShare)

        if UIDevice.current.userInterfaceIdiom == .pad {
            nav.modalPresentationStyle = .formSheet
        }
        present(nav, animated: true, completion: nil)
    }
    
    /**
     Present add highlight note
     */
    func presentAddHighlightNote(_ highlight: Highlight, edit: Bool) {
        let addHighlightView = FolioReaderAddHighlightNote(withHighlight: highlight, folioReader: folioReader, readerConfig: readerConfig)
        addHighlightView.isEditHighlight = edit
        let nav = UINavigationController(rootViewController: addHighlightView)
        nav.modalPresentationStyle = .formSheet
        present(nav, animated: true, completion: nil)
    }
}

// MARK: FolioPageDelegate

extension FolioReaderCenter: FolioReaderPageDelegate {

    public func pageDidLoad(_ page: FolioReaderPage) {
        if self.readerConfig.loadSavedPositionForCurrentBook, let position = folioReader.savedPositionForCurrentBook {
            let pageNumber = position["pageNumber"] as? Int
            let offset = self.readerConfig.isDirection(position["pageOffsetY"], position["pageOffsetX"], position["pageOffsetY"]) as? CGFloat
            let pageOffset = offset
             if isFirstLoad {
                updateCurrentPage(page)
                isFirstLoad = false

                if (self.currentPageNumber == pageNumber && pageOffset > 0) {
                    page.scrollPageToOffset(pageOffset!, animated: false)
                }
            } else if (self.isScrolling == false && folioReader.needsRTLChange == true) {
                page.scrollPageToBottom()
            }
        } else if isFirstLoad {
            updateCurrentPage(page)
            isFirstLoad = false
        }

        // Go to fragment if needed
        if let fragmentID = tempFragment, let currentPage = currentPage , fragmentID != "" {
            currentPage.handleAnchor(fragmentID, avoidBeginningAnchors: true, animated: true)
            tempFragment = nil
        }
        
        if (readerConfig.scrollDirection == .horizontalWithVerticalContent),
            let offsetPoint = self.currentWebViewScrollPositions[page.pageNumber - 1] {
            page.webView?.scrollView.setContentOffset(offsetPoint, animated: false)
        }
        
        // Pass the event to the centers `pageDelegate`
        pageDelegate?.pageDidLoad?(page)
    }
    
    public func pageWillLoad(_ page: FolioReaderPage) {
        // Pass the event to the centers `pageDelegate`
        pageDelegate?.pageWillLoad?(page)
    }
    
    public func pageTap(_ recognizer: UITapGestureRecognizer) {
        // Pass the event to the centers `pageDelegate`
        pageDelegate?.pageTap?(recognizer)
    }
    
}

// MARK: FolioReaderChapterListDelegate

extension FolioReaderCenter: FolioReaderChapterListDelegate {
    
    func chapterList(_ chapterList: FolioReaderChapterList, didSelectRowAtIndexPath indexPath: IndexPath, withTocReference reference: FRTocReference) {
        let item = findPageByResource(reference)
        
        if item < totalPages {
            let indexPath = IndexPath(row: item, section: 0)
            changePageWith(indexPath: indexPath, animated: false, completion: { () -> Void in
                self.updateCurrentPage()
            })
            tempReference = reference
        } else {
            print("Failed to load book because the requested resource is missing.")
        }
    }
    
    func chapterList(didDismissedChapterList chapterList: FolioReaderChapterList) {
        updateCurrentPage()
        
        // Move to #fragment
        if let reference = tempReference {
            if let fragmentID = reference.fragmentID, let currentPage = currentPage , fragmentID != "" {
                currentPage.handleAnchor(reference.fragmentID!, avoidBeginningAnchors: true, animated: true)
            }
            tempReference = nil
        }
    }
    
    func getScreenBounds() -> CGRect {
        var bounds = view.frame
        
        if #available(iOS 11.0, *) {
            bounds.size.height = bounds.size.height - view.safeAreaInsets.bottom
        }
        
        return bounds
    }
    
}
