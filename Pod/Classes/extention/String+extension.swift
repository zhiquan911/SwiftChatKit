//
//  String+extension.swift
//  SwiftChatKit
//
//  Created by 麦志泉 on 15/9/4.
//  Copyright (c) 2015年 CocoaPods. All rights reserved.
//

import Foundation

extension String {
    
    /// 字符串长度
    var length: Int {
        return self.characters.count;
    }  // Swift 1.2

    /**
    计算文字的高度
    
    - parameter font:
    - parameter size:
    
    - returns:
    */
    func textSizeWithFont(font: UIFont, constrainedToSize size:CGSize) -> CGSize {
        var textSize:CGSize!
        let newStr = NSString(string: self)
        if CGSizeEqualToSize(size, CGSizeZero) {
            let attributes = [NSFontAttributeName: font]
            textSize = newStr.sizeWithAttributes(attributes)
        } else {
            let option = NSStringDrawingOptions.UsesLineFragmentOrigin
            let attributes = [NSFontAttributeName: font]
            let stringRect = newStr.boundingRectWithSize(size, options: option, attributes: attributes, context: nil)
            textSize = stringRect.size
        }
        return textSize
    }
}