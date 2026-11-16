//
//  Extention.swift
//  Holy Reads
//
//  Created by mac-14 on 31/08/19.
//  Copyright © 2019 Ajeet singh Rawat. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD
import NotificationBannerSwift
import StoreKit

 

extension UILabel{

public var requiredHeight: CGFloat {
    let label = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: CGFloat.greatestFiniteMagnitude))
    label.numberOfLines = 0
    label.lineBreakMode = NSLineBreakMode.byWordWrapping
    label.font = font
    label.text = text
    label.attributedText = attributedText
    label.sizeToFit()
    return label.frame.height
  }
}

extension UIView {
     
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func addShadowView(width:CGFloat = 0.2, height:CGFloat = 1, Opacidade:Float = 20, maskToBounds:Bool = false, radius:CGFloat = 1){
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: width, height: height)
        self.layer.shadowRadius = radius
        self.layer.shadowOpacity = Opacidade
        self.layer.masksToBounds = maskToBounds
    }
}
extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

extension String {
    var html2AttributedString: NSAttributedString? {
        return Data(utf8).html2AttributedString
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
    
    
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
extension UIImageView {
    public func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let maskPath = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: corners,
                                    cornerRadii: CGSize(width: radius, height: radius))
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        layer.mask = shape
    }
}

extension UIViewController{
    
    func showAlert(_ message: String, _ clickAction: Selector?) {
             DispatchQueue.main.async {
              self.appDelegate.window?.endEditing(true)
                 let normalAlert = UIAlertController(title: "Holy reads", message: message, preferredStyle: .alert)
                 if clickAction == nil {
                     normalAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                 } else {
                     normalAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                         self.perform(clickAction)
                     }))
                 }
                 
                 self.navigationController?.present(normalAlert, animated: true, completion: nil)
             }
         }
    
    func checkWiFi() -> Bool {
           let networkStatus = Reachability().connectionStatus()
           switch networkStatus {
           case .Unknown, .Offline:
               return false
           case .Online(.WWAN):
               print("Connected via WWAN")
               return false
           case .Online(.WiFi):
               print("Connected via WiFi")
               return true
           }
       }
   
    func showHud()  {
        SVProgressHUD.show()
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.setRingThickness(2.0)
        SVProgressHUD.setBackgroundColor(UIColor.white)
        
    }
    
    func showHud1()  {
        SVProgressHUD.show()
        SVProgressHUD.setDefaultMaskType(.clear)
        SVProgressHUD.setRingThickness(0.0)
        SVProgressHUD.setBackgroundColor(UIColor.clear)

        
    }
    
    func clearHud()  {
        SVProgressHUD.dismiss()
    }
   
    var appDelegate:AppDelegate
    {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func resize(_ image: UIImage) -> UIImage {
        var actualHeight = Float(image.size.height)
        var actualWidth = Float(image.size.width)
        let maxHeight: Float = Float(screenHeight)
        let maxWidth: Float = Float(screenWidth)
        var imgRatio: Float = actualWidth / actualHeight
        let maxRatio: Float = maxWidth / maxHeight
        let CompressionQuality: Float = 0.5
        //50 percent compression
        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            }
            else if imgRatio > maxRatio {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            }
            else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }
        let rect = CGRect(x: 0.0, y: 0.0, width: CGFloat(actualWidth), height: CGFloat(actualHeight))
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        let imageData = img?.jpegData(compressionQuality: CGFloat(CompressionQuality))
        UIGraphicsEndImageContext()
        return UIImage(data: imageData!) ?? UIImage()
        
    }
    
    func onShowFloatingBanner(title : String?,message : String?) {
        // hideBanner()
        let banner = FloatingNotificationBanner(title: title, subtitle: message, titleFont: UIFont.systemFont(ofSize: 20), titleColor: UIColor.white, titleTextAlign: NSTextAlignment.center, subtitleFont: UIFont.systemFont(ofSize: 18), subtitleColor: UIColor.white, subtitleTextAlign: NSTextAlignment.center, leftView: nil, rightView: nil, style: .info, colors: nil, iconPosition: .center)
        //let banner = NotificationBanner(title: title,subtitle: message,style: .info)
        banner.delegate = self as? NotificationBannerDelegate
        banner.duration = 3
        banner.show(queuePosition: .front, bannerPosition: .top)
    }
    
    func topViewController(_ viewController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = viewController as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = viewController as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = viewController?.presentedViewController {
            return topViewController(presented)
        }
        return viewController
    }
    
    func addBulletToString1(stringList: [String],
                              font: UIFont,
                              bullet: String = "\u{2022}",
                              indentation: CGFloat = 20,
                              lineSpacing: CGFloat = 1,
                              paragraphSpacing: CGFloat = 8,
                              textColor: UIColor = .darkGray,
                              bulletColor: UIColor = UIColor.orange) -> NSAttributedString {
           
           let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: textColor]
           let bulletAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: bulletColor]
          

           let paragraphStyle = NSMutableParagraphStyle()
           let nonOptions = [NSTextTab.OptionKey: Any]()
           paragraphStyle.tabStops = [
               NSTextTab(textAlignment: .left, location: indentation, options: nonOptions)]
           paragraphStyle.defaultTabInterval = indentation
           //paragraphStyle.firstLineHeadIndent = 0
           //paragraphStyle.headIndent = 20
           //paragraphStyle.tailIndent = 1
           paragraphStyle.lineSpacing = lineSpacing
           paragraphStyle.paragraphSpacing = paragraphSpacing
           paragraphStyle.headIndent = indentation
           
           let bulletList = NSMutableAttributedString()
           for string in stringList {
               let formattedString = "\(bullet)\t\(string)\n"
               let attributedString = NSMutableAttributedString(string: formattedString)
               
               attributedString.addAttributes(
                   [NSAttributedString.Key.paragraphStyle : paragraphStyle],
                   range: NSMakeRange(0, attributedString.length))
               
               attributedString.addAttributes(
                   textAttributes,
                   range: NSMakeRange(0, attributedString.length))
               
               let string:NSString = NSString(string: formattedString)
               let rangeForBullet:NSRange = string.range(of: bullet)
               attributedString.addAttributes(bulletAttributes, range: rangeForBullet)
               bulletList.append(attributedString)
           }
           
           return bulletList
       }
    
    func addBulletToString(stringList: [String],
                              font: UIFont,
                              bullet: String = "\u{2022}",
                              indentation: CGFloat = 20,
                              lineSpacing: CGFloat = 2,
                              paragraphSpacing: CGFloat = 12,
                              textColor: UIColor = .gray,
                              bulletColor: UIColor = UIColor.orange) -> NSAttributedString {
           
           let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: textColor]
           let bulletAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: bulletColor]
          

           let paragraphStyle = NSMutableParagraphStyle()
           let nonOptions = [NSTextTab.OptionKey: Any]()
           paragraphStyle.tabStops = [
               NSTextTab(textAlignment: .left, location: indentation, options: nonOptions)]
           paragraphStyle.defaultTabInterval = indentation
           //paragraphStyle.firstLineHeadIndent = 0
           //paragraphStyle.headIndent = 20
           //paragraphStyle.tailIndent = 1
           paragraphStyle.lineSpacing = lineSpacing
           paragraphStyle.paragraphSpacing = paragraphSpacing
           paragraphStyle.headIndent = indentation
           
           let bulletList = NSMutableAttributedString()
           for string in stringList {
               let formattedString = "\(bullet)\t\(string)\n"
               let attributedString = NSMutableAttributedString(string: formattedString)
               
               attributedString.addAttributes(
                   [NSAttributedString.Key.paragraphStyle : paragraphStyle],
                   range: NSMakeRange(0, attributedString.length))
               
               attributedString.addAttributes(
                   textAttributes,
                   range: NSMakeRange(0, attributedString.length))
               
               let string:NSString = NSString(string: formattedString)
               let rangeForBullet:NSRange = string.range(of: bullet)
               attributedString.addAttributes(bulletAttributes, range: rangeForBullet)
               bulletList.append(attributedString)
           }
           
           return bulletList
       }
    
    func addBulletToStringNew(stringList: [String],
                              font: UIFont,
                              bullet: String = "\u{2022}",
                              indentation: CGFloat = 20,
                              lineSpacing: CGFloat = 2,
                              paragraphSpacing: CGFloat = 12,
                              textColor: UIColor = .gray,
                              bulletColor: UIColor = UIColor.orange) -> NSAttributedString {
           
           let textAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: textColor]
           let bulletAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: font, NSAttributedString.Key.foregroundColor: bulletColor]
          

           let paragraphStyle = NSMutableParagraphStyle()
           let nonOptions = [NSTextTab.OptionKey: Any]()
           paragraphStyle.tabStops = [
               NSTextTab(textAlignment: .left, location: indentation, options: nonOptions)]
           paragraphStyle.defaultTabInterval = indentation
           //paragraphStyle.firstLineHeadIndent = 0
           //paragraphStyle.headIndent = 20
           //paragraphStyle.tailIndent = 1
           paragraphStyle.lineSpacing = lineSpacing
           paragraphStyle.paragraphSpacing = paragraphSpacing
           paragraphStyle.headIndent = indentation
           
           let bulletList = NSMutableAttributedString()
           for string in stringList {
            
               let formattedString = "\(bullet)\t\(string)\n"
               let ranget = UserDefaults.standard.value(forKey: "Tl") as? String ?? ""
               let range = (formattedString as NSString).range(of: ranget)
               let attributedString = NSMutableAttributedString(string: formattedString)
             // attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: range)

               attributedString.addAttributes(
                   [NSAttributedString.Key.paragraphStyle : paragraphStyle],
                   range: NSMakeRange(0, attributedString.length))
            
               
               attributedString.addAttributes(
                   textAttributes,
                   range: NSMakeRange(0, attributedString.length))
               
               let string:NSString = NSString(string: formattedString)
               let rangeForBullet:NSRange = string.range(of: bullet)
               attributedString.addAttributes(bulletAttributes, range: rangeForBullet)
            attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: range)
            let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 15)]
            attributedString.addAttributes(attrs, range: range)
           
               bulletList.append(attributedString)
           }
           
           return bulletList
       }
    
    func getCreatePostTime(strdate:String) -> String
       {
           let datesendFormate = DateFormatter()
           datesendFormate.locale = NSLocale(localeIdentifier:"en_US_POSIX") as Locale?
           datesendFormate.dateFormat = "yyyy-MM-dd HH:mm:ss"
           datesendFormate.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
           let datesend = datesendFormate.date(from: strdate)
           datesendFormate.timeZone = NSTimeZone.system
           //datesendFormate.dateFormat = "MM/dd/yyyy"
           var strSendtime = datesendFormate.string(from: datesend!)
           let datetime = datesendFormate.date(from: strSendtime)
           if datetime != nil
           {
               strSendtime = timeAgo(datetime!)
           }
           return strSendtime
       }
       func timeAgo(_ compareDate: Date) -> String {
           let timeInterval: TimeInterval = -compareDate.timeIntervalSinceNow
           var temp: Int = 0
           var result: String
           if timeInterval < 60 {
               result = "Just now"
           }
               //less than a minute
               //else if timeInterval < 60 {
               //result = [NSString stringWithFormat:@"%d sec Ago",temp]   //less than a minute
               // }
           else
           {
               temp = Int(timeInterval / 60.0)
               if temp < 60
               {
                   result = "\(temp) min Ago"
               }
               else
               {
                   temp = temp / 60
                   
                   if temp < 24 {
                       
                       if temp > 1 {
                           result = "\(temp) hours Ago"
                           //hours ago
                       }
                       else {
                           result = "\(temp) hour Ago"
                           //hours ago
                       }
                   }
                   else
                   {
                       temp = temp / 24
                       
                       if temp < 7
                       {
                           if temp > 1
                           {
                               result = "\(temp) days Ago" //days ago
                               
                           }
                           else
                           {
                               result = "\(temp) day Ago" //days ago
                           }
                       }
                       else
                       {
                           let dateFormatter = DateFormatter()
                           dateFormatter.dateFormat = "MMMM dd"
                           result = "\(dateFormatter.string(from: compareDate))" //7 days ago
                       }
                   }
               }
           }
           return result
       }
    
    func mul (val :Int )-> [Int] {
        var arrdata = [Int]()
        arrdata.append(val)
        arrdata.append(val*3)
        arrdata.append(val*12)
        return  arrdata
    }
     func rateApp() {
        if #available(iOS 10.3, *) {
            SKStoreReviewController.requestReview()

        } else if let url = URL(string: "itms-apps://itunes.apple.com/app/" + "appId") {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)

            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}



