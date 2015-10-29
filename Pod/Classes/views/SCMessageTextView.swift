//
//  SCMessageTextView.swift
//  SwiftChatKit
//
//  Created by 麦志泉 on 15/9/2.
//  Copyright (c) 2015年 CocoaPods. All rights reserved.
//

import UIKit

class SCMessageTextView: UITextView {
    
    /**
    *  提示用户输入的标语
    */
    var placeHolderText: NSString = ""
    var placeHolder: String {
        set {
            if placeHolderText == newValue {
                return
            }
            var newPlaceHolder: String = newValue
            let maxChars = SCMessageTextView.maxCharactersPerLine
            if newPlaceHolder.length > maxChars {
                let index = newPlaceHolder.startIndex.advancedBy(maxChars - 8)
                newPlaceHolder = newPlaceHolder.substringToIndex(index);
                newPlaceHolder = newPlaceHolder.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).stringByAppendingString("...")
            }
            
            placeHolderText = newPlaceHolder;
            self.setNeedsDisplay()
        }
        get {
            return String(placeHolderText) 
        }
    }
    
    /**
    *  标语文本的颜色
    */
    var placeHolderTextColor: UIColor = UIColor.clearColor()
    var placeHolderColor: UIColor {
        set {
            if placeHolderTextColor == newValue {
                return;
            }
            
            placeHolderTextColor = newValue
            self.setNeedsDisplay()
        }
        
        get {
            return placeHolderTextColor
        }
    }
    
    /**
    *  获取自身文本占据有多少行
    *
    *  @return 返回行数
    */
    var numberOfLinesOfText: Int {
        return SCMessageTextView.numberOfLinesForMessage(self.text);
    }
    
    /**
    *  获取每行的高度
    *
    *  @return 根据iPhone或者iPad来获取每行字体的高度
    */
    class var maxCharactersPerLine: Int {
        return UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone ? 33:109
    }
    
    /**
    *  获取某个文本占据自身适应宽带的行数
    *
    *  @param text 目标文本
    *
    *  @return 返回占据行数
    */
    class func numberOfLinesForMessage(text: String) -> Int {
        
        return (text.length / SCMessageTextView.maxCharactersPerLine) + 1;
    }
    
    
    // mark - Notifications
    
    func didReceiveTextDidChangeNotification(notification: NSNotification) {
        self.setNeedsDisplay()
    }
    
    func setupUI() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didReceiveTextDidChangeNotification:", name: UITextViewTextDidChangeNotification, object: self)
        
        placeHolderTextColor = UIColor.lightGrayColor()
        self.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        self.scrollIndicatorInsets = UIEdgeInsetsMake(10.0, 0.0, 10.0, 8.0)
        self.contentInset = UIEdgeInsetsZero;
        self.scrollEnabled = true;
        self.scrollsToTop = false;
        self.userInteractionEnabled = true;
        self.font = UIFont.systemFontOfSize(16);
        self.textColor = UIColor.blackColor();
        self.backgroundColor = UIColor.whiteColor();
        self.keyboardAppearance = UIKeyboardAppearance.Default;
        self.keyboardType = UIKeyboardType.Default;
        self.returnKeyType = UIReturnKeyType.Default;
        self.textAlignment = NSTextAlignment.Left;
    }
    
    
    override func awakeFromNib() {
        self.setupUI()
    }
    
    init() {
        super.init(frame: CGRectZero, textContainer: nil)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        if (self.text.length == 0) && self.placeHolder != "" {
            
            let placeHolderRect: CGRect = CGRectMake(10.0,7.0,
                rect.size.width,
                rect.size.height);
            
            self.placeHolderTextColor.set()
            
            let paragraphStyle = NSMutableParagraphStyle();
            paragraphStyle.lineBreakMode = NSLineBreakMode.ByTruncatingTail;
            paragraphStyle.alignment = self.textAlignment;
            
            let textFontAttributes = [
                NSFontAttributeName: self.font!,
                NSForegroundColorAttributeName: self.placeHolderTextColor,
                NSParagraphStyleAttributeName: paragraphStyle
            ]
            
            self.placeHolderText.drawInRect(
                placeHolderRect,
                withAttributes: textFontAttributes)
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UITextViewTextDidChangeNotification, object: self)
    }
    
    
}
