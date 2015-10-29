//
//  ChatTableView.swift
//  SwiftChatKit
//
//  Created by 麦志泉 on 15/9/17.
//  Copyright © 2015年 CocoaPods. All rights reserved.
//

import UIKit

class ChatTableView: UITableView {

    override var contentSize: CGSize {
        get {
            return super.contentSize
        }
        set {
            
            if (!CGSizeEqualToSize(self.contentSize, CGSizeZero)) {
                if (newValue.height > self.contentSize.height) {
                    var offset: CGPoint = self.contentOffset;
                    offset.y += (newValue.height - self.contentSize.height);
                    self.contentOffset = offset;
                }
            }
            super.contentSize = newValue
        }
    }

}
