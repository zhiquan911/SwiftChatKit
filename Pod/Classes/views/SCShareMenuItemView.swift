//
//  SCShareMenuItemView.swift
//  SwiftChatKit
//
//  Created by 麦志泉 on 15/10/6.
//  Copyright © 2015年 CocoaPods. All rights reserved.
//

import UIKit

class SCShareMenuItemView: UIView {

    var lableMenuTitle: UILabel!
    var buttonMenuItem: UIButton!
    var menuItemImage: UIImage!
    var menuItem: String!
    
    private func setupUI() {
        
        if buttonMenuItem == nil {
            let button = UIButton(type: UIButtonType.Custom)
            button.frame = CGRectMake(0, 0, menuItemImage.size.width, menuItemImage.size.height)
            button.setImage(menuItemImage, forState: UIControlState.Normal)
            button.backgroundColor = UIColor.clearColor()
            button.translatesAutoresizingMaskIntoConstraints = false
            button.setBackgroundImage(UIImage(named: "VoiceBtn_black"), forState: UIControlState.Normal)
            button.setBackgroundImage(UIImage(named: "VoiceBtn_blackHL"), forState: UIControlState.Highlighted)
            self.addSubview(button)
            
            self.buttonMenuItem = button
        }
        
        if lableMenuTitle == nil {
            let label = UILabel()
            label.text = self.menuItem
            label.backgroundColor = UIColor.clearColor()
            label.textColor = UIColor.darkGrayColor()
            label.font = UIFont.systemFontOfSize(13)
            label.textAlignment = NSTextAlignment.Center
            label.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(label)
            
            self.lableMenuTitle = label;
        }
        
        //水平布局
        self.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[buttonMenuItem]|",
                options: NSLayoutFormatOptions(),
                metrics: nil,
                views:["buttonMenuItem": self.buttonMenuItem]))
        
        //水平布局
        self.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|-0-[lableMenuTitle]-0-|",
                options: NSLayoutFormatOptions(),
                metrics: nil,
                views:["lableMenuTitle": self.lableMenuTitle]))
        
        //垂直布局
        self.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|[buttonMenuItem(\(menuItemImage.size.height))]",
                options: NSLayoutFormatOptions(),
                metrics: nil,
                views:["buttonMenuItem": self.buttonMenuItem]))
        
        //垂直布局
        self.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:[lableMenuTitle(20)]|",
                options: NSLayoutFormatOptions(),
                metrics: nil,
                views:["lableMenuTitle": self.lableMenuTitle]))
        
    }
    
    override func awakeFromNib() {
        self.setupUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupUI()
    }
    
    convenience init(image: UIImage, title: String) {
        self.init()
        self.menuItemImage = image
        self.menuItem = title
        self.setupUI()
    }

}
