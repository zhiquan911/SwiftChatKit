//
//  SCMessageTableViewCell.swift
//  SwiftChatKit
//
//  Created by 麦志泉 on 15/9/6.
//  Copyright (c) 2015年 CocoaPods. All rights reserved.
//

import UIKit

@objc protocol SCMessageTableViewCellDelegate {
    
    /**
    点击单元格
    
    - parameter indexPath:
    - parameter cell:
    */
    optional func singleDidSelectMessageCell(indexPath: NSIndexPath, cell: SCMessageTableViewCell)
}

class SCMessageTableViewCell: UITableViewCell {
    
    static let kDefaultImage = UIImage(named: "PhotoDownload")!
    
    @IBOutlet var labelTimeStamp:UILabel!
    @IBOutlet var labelUserName:UILabel!
    @IBOutlet var labelMessageText:UILabel!
    @IBOutlet var buttonUserAvatar:UIButton!
    @IBOutlet var viewBubble:UIView!
    @IBOutlet var viewTimeStamp:UIView!
    @IBOutlet var progressView: UIActivityIndicatorView!
    @IBOutlet var imageViewVoicePlayed: UIImageView!
    @IBOutlet var buttonError: UIButton!
    @IBOutlet var labelVoiceDuration: UILabel!
    @IBOutlet var imageViewAnimationVoice: SCVoicePlayImageView!
    @IBOutlet var imageViewPhoto: BubblePhotoImageView!
    @IBOutlet var labelProgress: UILabel!
    weak var delegate: SCMessageTableViewCellDelegate?
    var indexPath: NSIndexPath!
    
    //布局约束
    @IBOutlet var viewTimestampLeftMarginContraints: NSLayoutConstraint!
    @IBOutlet var viewTimestampRightMarginContraints: NSLayoutConstraint!
    @IBOutlet var viewTimestampTopMarginContraints: NSLayoutConstraint!
    @IBOutlet var viewTimestampBottomMarginContraints: NSLayoutConstraint!
    @IBOutlet var bubbleViewWidthContraints: NSLayoutConstraint!
    
    
    //语音消息的背景长度根据语音时长正比变化，最大宽为200，最小宽为66，最大录音时长60秒
    let maxBubbleVoiceWdith: Float = 200
    let minBubbleVoiceWdith: Float = 66
    let maxVoiceDuration: Float = 60.0

    override func awakeFromNib() {
        super.awakeFromNib()
        viewTimeStamp.layer.cornerRadius = 3;
        viewTimeStamp.layer.masksToBounds = true;
        progressView.hidesWhenStopped = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    /**
    根据时长设置背景的长度
    
    - parameter duration: 
    */
    func setVoiceDurationWidth(duration: Float) {
        let rate: Float = maxBubbleVoiceWdith/maxVoiceDuration
        var width = rate * duration * 2
        if width < 66 {
            width = 66
        }
        if width > maxBubbleVoiceWdith {
            width = maxBubbleVoiceWdith
        }
        self.bubbleViewWidthContraints.constant = CGFloat(width)
        self.layoutIfNeeded()
    }
    
    
    /**
    配置单元格的事件
    
    - parameter indexPath:
    - parameter message:   
    */
    func configMessageCellTouchEvent(indexPath: NSIndexPath, message: SCMessage) {
        
        self.indexPath = indexPath
        if self.viewBubble.gestureRecognizers != nil {
            for gesTureRecognizer in self.viewBubble.gestureRecognizers! {
                self.viewBubble.removeGestureRecognizer(gesTureRecognizer)
            }
        }
        
        switch message.messageMediaType! {
        case SCMessageMediaType.Text:        //文本消息
            let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "doubleTapGestureRecognizerHandle:")
            tapGestureRecognizer.numberOfTapsRequired = 2
            self.viewBubble.addGestureRecognizer(tapGestureRecognizer)
            break
        case SCMessageMediaType.Voice:       //语音消息
            self.imageViewAnimationVoice.setupImageSourceType(message.messageSourceType)
            let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "singleTapGestureRecognizerHandle:")
            self.viewBubble.addGestureRecognizer(tapGestureRecognizer)
            break
        case SCMessageMediaType.Photo, SCMessageMediaType.Video:       //视频或图片消息
            let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "singleTapGestureRecognizerHandle:")
            self.viewBubble.addGestureRecognizer(tapGestureRecognizer)
            break
        default: break
        }

    }
    
    /**
    点击事件
    
    - parameter tapGestureRecognizer:
    */
    func singleTapGestureRecognizerHandle(tapGestureRecognizer: UITapGestureRecognizer) {
        
        if tapGestureRecognizer.state == UIGestureRecognizerState.Ended {
            self.delegate?.singleDidSelectMessageCell?(self.indexPath, cell: self)
        }
    }
    
    /**
    双击事件
    
    - parameter tapGestureRecognizer:
    */
    func doubleTapGestureRecognizerHandle(tapGestureRecognizer: UITapGestureRecognizer) {
        if tapGestureRecognizer.state == UIGestureRecognizerState.Ended {
            
        }
    }
   
}
