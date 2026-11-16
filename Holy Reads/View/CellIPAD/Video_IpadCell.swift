//
//  Video_IpadCell.swift
//  Holy Reads
//
//  Created by Ashish Soni on 20/07/20.
//  Copyright © 2020 Ajeet singh Rawat. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class Video_IpadCell: UICollectionViewCell {
    
    @IBOutlet weak var VideoImgView: UIImageView!
       
       @IBOutlet weak var viewVideo: UIView!
       var avpController = AVPlayerViewController()
       var player = AVPlayer()
}
