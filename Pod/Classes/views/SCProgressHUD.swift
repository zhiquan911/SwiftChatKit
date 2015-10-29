//
//  SCProgressHUD.swift
//  SwiftChatKit
//
//  Created by 麦志泉 on 15/9/8.
//  Copyright (c) 2015年 CocoaPods. All rights reserved.
//

import UIKit

class SCProgressHUD: UIView {
    
    @IBOutlet var labelTip: UILabel!
    @IBOutlet var imageViewPowerOfVoice: UIImageView!
    @IBOutlet var imageViewCancel: UIImageView!
    @IBOutlet var imageViewmicroPhone: UIImageView!
    @IBOutlet var imageViewMessageTooShort: UIImageView!
    var parentView: UIView?
    
    /**
    配置UI
    */
    private func setupUI() {
        
        self.backgroundColor = UIColor(white: 0, alpha: 0.7);
        self.layer.masksToBounds = true;
        self.layer.cornerRadius = 10;
        
        if(self.labelTip == nil) {
            /// 文字提示信息
            let labelTip = UILabel();
            labelTip.textColor = UIColor.whiteColor()
            labelTip.font = UIFont.systemFontOfSize(13)
            labelTip.layer.masksToBounds = true
            labelTip.layer.cornerRadius = 4
            labelTip.autoresizingMask = [UIViewAutoresizing.FlexibleRightMargin, UIViewAutoresizing.FlexibleBottomMargin]
            labelTip.backgroundColor = UIColor.clearColor()
            labelTip.text = "手指上滑，取消发送";
            labelTip.textAlignment = NSTextAlignment.Center
            labelTip.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(labelTip)
            self.labelTip = labelTip
        }
        
        if (self.imageViewmicroPhone == nil) {
            let imageViewmicroPhone = UIImageView()
            imageViewmicroPhone.image = UIImage(named: "RecordingBkg")
            imageViewmicroPhone.translatesAutoresizingMaskIntoConstraints = false
            imageViewmicroPhone.contentMode = UIViewContentMode.ScaleToFill
            self.addSubview(imageViewmicroPhone)
            self.imageViewmicroPhone = imageViewmicroPhone;
        }
        
        if (self.imageViewPowerOfVoice == nil) {
            let imageViewPowerOfVoice = UIImageView()
            imageViewPowerOfVoice.image = UIImage(named: "RecordingSignal001")
            imageViewPowerOfVoice.translatesAutoresizingMaskIntoConstraints = false
            imageViewPowerOfVoice.contentMode = UIViewContentMode.ScaleToFill
            self.addSubview(imageViewPowerOfVoice)
            self.imageViewPowerOfVoice = imageViewPowerOfVoice;
        }
        
        if (self.imageViewCancel == nil) {
            let imageViewCancel = UIImageView()
            imageViewCancel.image = UIImage(named: "RecordCancel")
            imageViewCancel.hidden = true
            imageViewCancel.translatesAutoresizingMaskIntoConstraints = false
            imageViewCancel.contentMode = UIViewContentMode.ScaleToFill
            self.addSubview(imageViewCancel)
            self.imageViewCancel = imageViewCancel;
        }
        
        if (self.imageViewMessageTooShort == nil) {
            let imageViewMessageTooShort = UIImageView()
            imageViewMessageTooShort.image = UIImage(named: "MessageTooShort")
            imageViewMessageTooShort.hidden = true
            imageViewMessageTooShort.translatesAutoresizingMaskIntoConstraints = false
            imageViewMessageTooShort.contentMode = UIViewContentMode.ScaleToFill
            self.addSubview(imageViewMessageTooShort)
            self.imageViewMessageTooShort = imageViewMessageTooShort;
        }
        
        
        self.setupConstraints()
    }
    
    /**
    配置view的约束
    */
    private func setupConstraints() {
        
        /*************** labelTip的布局约束 ***************/
        self.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:[labelTip(21)]-5-|",
                options: NSLayoutFormatOptions(),
                metrics: nil,
                views:["labelTip": self.labelTip]))
        
        self.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|-5-[labelTip]-5-|",
                options: NSLayoutFormatOptions(),
                metrics: nil,
                views:["labelTip": self.labelTip]))
        
        /*************** imageViewmicroPhone的布局约束 ***************/
        
        self.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|-8-[imageViewmicroPhone(99)]",
                options: NSLayoutFormatOptions(),
                metrics: nil,
                views:["imageViewmicroPhone": self.imageViewmicroPhone]))
        
        self.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|-27-[imageViewmicroPhone(50)]",
                options: NSLayoutFormatOptions(),
                metrics: nil,
                views:["imageViewmicroPhone": self.imageViewmicroPhone]))
        
        /*************** imageViewPowerOfVoice的布局约束 ***************/
        
        self.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|-34-[imageViewPowerOfVoice(61)]",
                options: NSLayoutFormatOptions(),
                metrics: nil,
                views:["imageViewPowerOfVoice": self.imageViewPowerOfVoice]))
        
        self.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:[imageViewmicroPhone]-5-[imageViewPowerOfVoice(18)]",
                options: NSLayoutFormatOptions(),
                metrics: nil,
                views:["imageViewmicroPhone": self.imageViewmicroPhone,
                    "imageViewPowerOfVoice": self.imageViewPowerOfVoice]))
        
        /*************** imageViewCancel的布局约束 ***************/
        
        self.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|-7-[imageViewCancel(100)]",
                options: NSLayoutFormatOptions(),
                metrics: nil,
                views:["imageViewCancel": self.imageViewCancel]))
        
        self.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|-19-[imageViewCancel(100)]",
                options: NSLayoutFormatOptions(),
                metrics: nil,
                views:["imageViewCancel": self.imageViewCancel]))
        
        
        /*************** imageViewMessageTooShort的布局约束 ***************/
        
        self.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|-7-[imageViewMessageTooShort(100)]",
                options: NSLayoutFormatOptions(),
                metrics: nil,
                views:["imageViewMessageTooShort": self.imageViewMessageTooShort]))
        
        self.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|-19-[imageViewMessageTooShort(100)]",
                options: NSLayoutFormatOptions(),
                metrics: nil,
                views:["imageViewMessageTooShort": self.imageViewMessageTooShort]))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
        //        loadViewFromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupUI()
        //        loadViewFromNib()
    }
    
    /**
    开始录音
    */
    func startReocordingHUD(view: UIView) {
        dispatch_async(dispatch_get_main_queue(), {
            let center: CGPoint = CGPointMake(CGRectGetWidth(view.frame) / 2.0, CGRectGetHeight(view.frame) / 2.0);
            self.center = center;
            self.parentView = view
            view.addSubview(self)
            self.toggleRecording(true)
        })
    }
    
    /**
    开关是否正在录音
    
    - parameter recording:
    */
    private func toggleRecording(recording: Bool) {
        self.imageViewmicroPhone.hidden = !recording
        self.imageViewPowerOfVoice.hidden = !recording
        self.imageViewCancel.hidden = recording
        self.imageViewMessageTooShort.hidden = true
        
        if recording {
            self.labelTip.backgroundColor = UIColor.clearColor();
            self.labelTip.text = "手指上滑，取消发送";
        } else {
            self.labelTip.backgroundColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.63);
            self.labelTip.text = "松开手指，取消发送";
        }
    }
    
    /**
    暂停录音
    */
    func pauseRecordingHUD() {
        self.toggleRecording(false)
    }
    
    /**
    继续录音
    */
    func resumeRecordingHUD() {
        self.toggleRecording(true)
    }
    
    /**
    显示录音时间太短
    
    - parameter view:
    */
    func showMessageTooShortTip() {
        
        self.imageViewmicroPhone.hidden = true
        self.imageViewPowerOfVoice.hidden = true
        self.imageViewCancel.hidden = true
        self.imageViewMessageTooShort.hidden = false
        self.labelTip.backgroundColor = UIColor.clearColor();
        self.labelTip.text = "说话时间太短";
        
        let time: NSTimeInterval = 1.0
        let delay = dispatch_time(DISPATCH_TIME_NOW,
            Int64(time * Double(NSEC_PER_SEC)))
        dispatch_after(delay, dispatch_get_main_queue()) {
            self.dismiss()
        }

    }
    
    /**
    停止录音
    */
    func stopRecordingHUD() {
        self.dismiss()
    }
    
    /**
    取消录音
    */
    func cancelRecordingHUD() {
        self.dismiss()
    }
    
    private func dismiss() {
        self.removeFromSuperview()
    }
    
    /**
    控制音量高低
    
    - parameter peakPower:
    */
    func configRecordingHUDImageWithPeakPower(peakPower: CGFloat) {
        var imageName: String = "RecordingSignal00";
        if (peakPower >= 0 && peakPower <= 0.1) {
            imageName = imageName + "1"
        } else if (peakPower > 0.1 && peakPower <= 0.2) {
            imageName = imageName + "2"
        } else if (peakPower > 0.3 && peakPower <= 0.4) {
            imageName = imageName + "3"
        } else if (peakPower > 0.4 && peakPower <= 0.5) {
            imageName = imageName + "4"
        } else if (peakPower > 0.5 && peakPower <= 0.6) {
            imageName = imageName + "5"
        } else if (peakPower > 0.7 && peakPower <= 0.8) {
            imageName = imageName + "6"
        } else if (peakPower > 0.8 && peakPower <= 0.9) {
            imageName = imageName + "7"
        } else if (peakPower > 0.9 && peakPower <= 1.0) {
            imageName = imageName + "8"
        }
        self.imageViewPowerOfVoice.image = UIImage(named: imageName);
    }
    
}

