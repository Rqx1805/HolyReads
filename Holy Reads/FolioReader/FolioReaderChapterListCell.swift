//
//  FolioReaderChapterListCell.swift
//  FolioReaderKit
//
//  Created by Heberti Almeida on 07/05/15.
//  Copyright (c) 2015 Folio Reader. All rights reserved.
//

import UIKit

class FolioReaderChapterListCell: UITableViewCell {
    var indexLabel: UILabel?
    var countLabel: UILabel?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.indexLabel = UILabel()
        self.countLabel = UILabel()
    }

    func setup(withConfiguration readerConfig: FolioReaderConfig) {

        self.indexLabel?.lineBreakMode = .byWordWrapping
        self.indexLabel?.numberOfLines = 0
        self.indexLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.indexLabel?.font = UIFont(name: "Avenir-Heavy", size: 19)
        self.indexLabel?.textColor = readerConfig.menuTextColor
        //Count OF CHAPTERS
        self.countLabel?.textColor = readerConfig.menuTextColor
        //self.countLabel?.backgroundColor = UIColor.red
        self.countLabel?.numberOfLines = 1
        self.countLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.countLabel?.font = UIFont(name: "Avenir-Heavy", size: 19)
        self.countLabel?.textColor = readerConfig.menuTextColor

        if let label = self.indexLabel {
            self.contentView.addSubview(label)

            // Configure cell contraints
            var constraints = [NSLayoutConstraint]()
            let views = ["label": label]

            NSLayoutConstraint.constraints(withVisualFormat: "H:|-50-[label]-50-|", options: [], metrics: nil, views: views).forEach {
                constraints.append($0 as NSLayoutConstraint)
            }

            NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[label]-16-|", options: [], metrics: nil, views: views).forEach {
                constraints.append($0 as NSLayoutConstraint)
            }

            self.contentView.addConstraints(constraints)
        }
        
        if let label = self.countLabel {
                 self.contentView.addSubview(label)

                 // Configure cell contraints
                 var constraints = [NSLayoutConstraint]()
                 let views = ["labels": label]

                 NSLayoutConstraint.constraints(withVisualFormat: "H:|-15-[labels]|", options: [], metrics: nil, views: views).forEach {
                                constraints.append($0 as NSLayoutConstraint)
                            }

                 NSLayoutConstraint.constraints(withVisualFormat: "V:|-16-[labels]", options: [], metrics: nil, views: views).forEach {
                     constraints.append($0 as NSLayoutConstraint)
                 }
            
           // V:|-23-[appNameLabel]

                 self.contentView.addConstraints(constraints)
             }
        
        
        
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("storyboards are incompatible with truth and beauty")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // As the `setup` is called at each reuse, make sure the label is added only once to the view hierarchy.
        self.indexLabel?.removeFromSuperview()
    }
}
