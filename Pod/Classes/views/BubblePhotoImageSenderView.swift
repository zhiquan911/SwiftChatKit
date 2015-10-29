//
//  BubblePhotoImageSenderView.swift
//  SwiftChatKit
//
//  Created by 麦志泉 on 15/10/8.
//  Copyright © 2015年 CocoaPods. All rights reserved.
//

import UIKit

class BubblePhotoImageSenderView: BubblePhotoImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.messageType = SCMessageSourceType.Send
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.messageType = SCMessageSourceType.Send
        self.setup()
    }
}
