//
//  ShapedImageView.swift
//  SwiftChatKit
//
//  Created by 麦志泉 on 15/10/8.
//  Copyright © 2015年 CocoaPods. All rights reserved.
//

import UIKit


class BubblePhotoImageView: UIView {
    
    let photoSize = CGSize(width: 100.0, height: 133.0)
    
    var messageType: SCMessageSourceType!

    var contentLayer: CALayer!
    var backgroundLayer: CALayer!
    var maskLayer: CAShapeLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        let rect = self.bounds
        self.maskLayer = CAShapeLayer()
        self.maskLayer.fillColor = UIColor.blackColor().CGColor
        self.maskLayer.strokeColor = UIColor.clearColor().CGColor
        self.maskLayer.frame = rect
        self.maskLayer.contentsCenter = CGRectMake(0.5, 0.6, 0.1, 0.1)
        self.maskLayer.contentsScale = UIScreen.mainScreen().scale
        self.setMask(false)
        self.contentLayer = CALayer()
        self.contentLayer.mask = self.maskLayer
        self.contentLayer.frame = rect
        self.layer.addSublayer(self.contentLayer)
    
//        let borderLayer = CAShapeLayer()
//        borderLayer.path = self.maskLayer.path
//        borderLayer.fillColor  = UIColor.clearColor().CGColor
//        borderLayer.strokeColor = UIColor.redColor().CGColor
//        borderLayer.lineWidth = 1
//        borderLayer.mask = self.maskLayer
//        self.contentLayer.addSublayer(borderLayer)
    }
    
    
    
    func setImage(image: UIImage) {
        let aspectScaledToFitImage = image.af_imageAspectScaledToFillSize(photoSize)
        self.contentLayer.contents = aspectScaledToFitImage.CGImage;
    }
    
    func setMask(isMask: Bool) {
        if self.messageType == SCMessageSourceType.Send {
            if isMask {
                self.maskLayer.contents = UIImage(named: "SenderImageNodeMask")?.CGImage
            } else {
                self.maskLayer.contents = UIImage(named: "SenderImageNodeSolid")?.CGImage
            }
            
        } else {
            if isMask {
                self.maskLayer.contents = UIImage(named: "ReceiverImageNodeMask")?.CGImage
            } else {
                self.maskLayer.contents = UIImage(named: "ReceiverImageNodeSolid")?.CGImage
            }
            
            
        }
    }

}
