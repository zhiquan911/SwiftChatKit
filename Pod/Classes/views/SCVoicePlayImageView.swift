//
//  SCVoicePlayImageView.swift
//  SwiftChatKit
//
//  Created by 麦志泉 on 15/9/28.
//  Copyright © 2015年 CocoaPods. All rights reserved.
//

import UIKit

class SCVoicePlayImageView: UIImageView {
    
    var sourceType: SCMessageSourceType!
    
    /**
    设置语音播放图片和动画图片
    
    - parameter sourceType:
    */
    func setupImageSourceType(sourceType: SCMessageSourceType) {
        self.sourceType = sourceType
        var imageSepatorName = ""
        if self.sourceType == SCMessageSourceType.Send {
            imageSepatorName = "Sender"
        } else {
            imageSepatorName = "Receiver"
        }
        var images = [UIImage]();
        for var i = 0; i < 4; i++ {
            let image = UIImage(named: "\(imageSepatorName)VoiceNodePlaying00\(i)")
            if image != nil {
                images.append(image!)
            }
        }
        
        self.image = UIImage(named: "\(imageSepatorName)VoiceNodePlaying")
        self.animationImages = images;
        self.animationDuration = 1.0;
        self.stopAnimating()
    }

}
