//
//  PMAlertAction.swift
//  PMAlertController
//
//  Created by Paolo Musolino on 07/05/16.
//  Copyright © 2018 Codeido. All rights reserved.
//

import UIKit

@objc public enum PMAlertActionStyle : Int {
    
    case `default`
    case cancel
}

@objc open class PMAlertAction: UIButton {
    
    @objc fileprivate var action: (() -> Void)?
    
    open var actionStyle : PMAlertActionStyle
    
    open var separator = UIImageView()
    open var buty = UIButton()
    
    init(){
        self.actionStyle = .cancel
        super.init(frame: CGRect.zero)
    }
    
    @objc public convenience init(title: String?, style: PMAlertActionStyle, action: (() -> Void)? = nil){
        self.init()
//        self.buty.frame = CGRect(x: 15, y: 5, width: 100, height: 50)
//        self.buty.layer.cornerRadius = 5
//        self.buty.backgroundColor = UIColor(red: 252/255, green: 140/255, blue: 49/255, alpha: 1.0)
        //self.buty.addTarget(self, action: #selector(PMAlertAction.tapped(_:)), for: .touchUpInside)
        //  self.addSubview(self.buty)
        
        
        self.action = action
        self.addTarget(self, action: #selector(PMAlertAction.tapped(_:)), for: .touchUpInside)
        self.setTitle(title, for: UIControl.State())
        self.titleLabel?.font = UIFont(name: "Avenir-Next", size: 17)
        self.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
       // self.titleLabel?.adjustsFontSizeToFitWidth = true
       // self.titleLabel?.textColor = UIColor(red: 252/255, green: 140/255, blue: 49/255, alpha: 1.0)
       
//        self.titleLabel?.layer.cornerRadius = 5
      // self.titleLabel?.backgroundColor = UIColor(red: 252/255, green: 140/255, blue: 49/255, alpha: 1.0)
       
        self.actionStyle = style
        style == .default ? (self.setTitleColor(UIColor(red: 252.0/255.0, green: 140.0/255.0, blue: 49.0/255.0, alpha: 1.0), for: UIControl.State())) : (self.setTitleColor(UIColor(red: 252.0/255.0, green: 140.0/255.0, blue: 49.0/255.0, alpha: 1.0), for: UIControl.State()))
        
        self.addSeparator()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    @objc func tapped1(_ sender: PMAlertAction) {
//        //Action need to be fired after alert dismiss
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
//            let vc =  PMAlertController(title: "Holy Reads", description: "", image: UIImage(named: "welcome_logo"), style: .alert)
//            vc.dismis(self!.actionStyle)
//        }
//    }
    
    @objc func tapped(_ sender: PMAlertAction) {
        //Action need to be fired after alert dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.action?()
        }
    }
    
    @objc fileprivate func addSeparator(){
        separator.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        self.addSubview(separator)
        
        // Autolayout separator
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        separator.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor, constant: 8).isActive = true
        separator.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor, constant: -8).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
}
