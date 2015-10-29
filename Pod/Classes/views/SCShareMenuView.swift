//
//  SCShareMenuView.swift
//  SwiftChatKit
//
//  Created by 麦志泉 on 15/10/6.
//  Copyright © 2015年 CocoaPods. All rights reserved.
//

import UIKit

@objc protocol SCShareMenuViewDelegate {
    
    func numberOfShareMenuItem() -> Int
    
    func menuItemViewForIndex(index: Int) -> SCShareMenuItemView
    
    //点击多媒体菜单按钮
    optional func didSelectShareMenuItem(itemView: SCShareMenuItemView, atIndex: Int)
}

class SCShareMenuView: UIView {

    var shareMenuItems = [SCShareMenuItemView]()
    var scrollViewShareMenu: UIScrollView!
    var pageControlShareMenu: UIPageControl!
    var delegate: SCShareMenuViewDelegate?
    
    let kPageControlHeight: Float = 30
    let kMenuItemViewWidth: Float = 60
    let kMenuItemViewHeight: Float = 80
    let kMenuItemViewColum: Float = 4
    let KMenuItemViewRow: Float = 2
    
    private func setupUI() {
    
        if scrollViewShareMenu == nil {
            let shareMenuScrollView = UIScrollView()
            shareMenuScrollView.translatesAutoresizingMaskIntoConstraints = false
//            shareMenuScrollView.delegate = self
            shareMenuScrollView.canCancelContentTouches = false
            shareMenuScrollView.delaysContentTouches = true
            shareMenuScrollView.backgroundColor = self.backgroundColor
            shareMenuScrollView.showsHorizontalScrollIndicator = false
            shareMenuScrollView.showsVerticalScrollIndicator = false
            shareMenuScrollView.scrollsToTop = false
            shareMenuScrollView.pagingEnabled = true;
            self.addSubview(shareMenuScrollView)
            self.scrollViewShareMenu = shareMenuScrollView;
        }
        
        if pageControlShareMenu == nil {
            let shareMenuPageControl = UIPageControl()
            shareMenuPageControl.translatesAutoresizingMaskIntoConstraints = false
            shareMenuPageControl.backgroundColor = self.backgroundColor;
            shareMenuPageControl.hidesForSinglePage = true;
            shareMenuPageControl.defersCurrentPageDisplay = true;
            self.addSubview(shareMenuPageControl)
            
            self.pageControlShareMenu = shareMenuPageControl;
        }
        
        let views = [
            "scrollViewShareMenu": self.scrollViewShareMenu,
            "pageControlShareMenu": self.pageControlShareMenu
        ]
        
        //水平布局
        self.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[scrollViewShareMenu]|",
                options: NSLayoutFormatOptions(),
                metrics: nil,
                views:views))
        
        //水平布局
        self.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[pageControlShareMenu]|",
                options: NSLayoutFormatOptions(),
                metrics: nil,
                views:views))
        
        //垂直布局
        self.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|[scrollViewShareMenu]-[pageControlShareMenu(\(kPageControlHeight))]|",
                options: NSLayoutFormatOptions(),
                metrics: nil,
                views:views))
        
    }
    
    override func awakeFromNib() {
        self.setupUI()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupUI()
    }
    
    convenience init(itemImage: UIImage, title: String) {
        self.init()
        self.setupUI()
    }
    
    /**
    刷新数据
    */
    func reloadData() {
        let count = self.delegate!.numberOfShareMenuItem()
        for subview in self.scrollViewShareMenu.subviews {
            subview.removeFromSuperview()
        }
        self.shareMenuItems.removeAll()
        
        //计算每个单元均匀分隔的pading
        let totalWidth = Float(self.bounds.width)
        let totalHeight = Float(self.bounds.height)
        let totalXMargin: Float = totalWidth - (kMenuItemViewColum * kMenuItemViewWidth)
        let perXMargin = totalXMargin / (kMenuItemViewColum + 1)
        let totalYMargin = totalHeight - kPageControlHeight - (KMenuItemViewRow * kMenuItemViewHeight)
        let perYMargin = totalYMargin / (KMenuItemViewRow + 1)
        
        var itemX: Float = perXMargin
        var itemY: Float = perYMargin
        for var i = 0; i<count; i++ {
            let itemView = self.delegate!.menuItemViewForIndex(i)
            self.shareMenuItems.append(itemView)
            self.scrollViewShareMenu.addSubview(itemView)
            itemX = Float(i) * (kMenuItemViewWidth + perXMargin) + perXMargin
            let row = i / Int(kMenuItemViewColum)
            itemY = Float(row) * (kMenuItemViewHeight + perYMargin) + perYMargin
            //配置按钮的位置
            let itemFrame = CGRectMake(CGFloat(itemX), CGFloat(itemY), CGFloat(kMenuItemViewWidth), CGFloat(kMenuItemViewHeight))
            itemView.frame = itemFrame
            
            //增加点击事件
            itemView.buttonMenuItem.addTarget(self, action: "handleShareMenuButtonPress:", forControlEvents: UIControlEvents.TouchUpInside)
        }
    }
    
    /**
    点击按钮事件
    
    - parameter sender:
    */
    func handleShareMenuButtonPress(sender: UIButton) {
        let array = NSArray(array: self.shareMenuItems)
        let index = array.indexOfObject(sender.superview!)
        self.delegate?.didSelectShareMenuItem?(sender.superview as! SCShareMenuItemView, atIndex: index)
    }

}

//class SCShareMenuView: UIScrollViewDelegate {
//
//}
