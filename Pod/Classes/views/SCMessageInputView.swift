//
//  SCMessageInputView.swift
//  SwiftChatKit
//
//  Created by 麦志泉 on 15/9/2.
//  Copyright (c) 2015年 CocoaPods. All rights reserved.
//

import UIKit

/**
*  工具条代理
*/
@objc protocol SCMessageInputViewDelegate: AnyObject {
 
    /**
    *  松开手指完成录音
    */
    optional func didFinishRecoingVoiceAction(voiceData: NSData, voicePath: String, voiceDuration: Float)
    
    /**
    点击多媒体按钮
    
    - parameter inputView:
    - parameter sender:
    */
    optional func didMediaButtonPress(inputView: SCMessageInputView)
}

class SCMessageInputView: UIImageView, UITextViewDelegate {
    
    /**
    *  用于输入文本消息的输入框
    */
    var inputTextView: SCMessageTextView!
    
    
    /**
    *  是否允许发送语音
    */
    var allowsSendVoice: Bool = true // default is YES
    
    /**
    *  是否允许发送多媒体
    */
    var allowsSendMultiMedia: Bool = true // default is YES
    
    /**
    *  是否支持发送表情
    */
    var allowsSendFace: Bool = true // default is YES
    
    /**
    *  切换文本和语音的按钮
    */
    var voiceChangeButton: UIButton!
    
    /**
    *  +号按钮
    */
    var multiMediaSendButton: UIButton!
    
    /**
    *  第三方表情按钮
    */
    var faceSendButton: UIButton!
    
    /**
    *  语音录制按钮
    */
    var holdDownButton: UIButton!
    
    /**
    *  是否取消錄音
    */
    var isCancelled: Bool? = false
    
    /**
    *  是否正在錄音
    */
    var isRecording: Bool? = false
    
    /**
    *  获取输入框内容字体行高
    *
    */
    var textViewLineHeight: Float = 36.0
    
    /**
    *  录音工具
    */
    var voiceRecord: VoiceRecord!
    
    /// 显示录音状态
    var recordingHUD: SCProgressHUD!
    
    weak var delegate: SCMessageInputViewDelegate?
    /**
    *  获取最大行数
    *
    *  @return 返回最大行数
    */
    var maxLines: Float {
        if UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Phone {
            return 3.0
        } else {
            return 8.0
        }
    }
    
    //文本输入框的高度约束，用于动态调整高度
    var inputTextHeightConstraints: NSLayoutConstraint!
    var currentTextHeight: Float?
    
    /**
    *  获取根据最大行数和每行高度计算出来的最大显示高度
    *
    *  @return 返回最大显示高度
    */
    var maxHeight: Float {
        return (self.maxLines + 1.0) * self.textViewLineHeight;
    }
    

    
    // MARK:初始化方法
    
    /**
    配置UI的初始化值
    */
    func setupUI() {
        
        // 默认设置
        self.userInteractionEnabled = true
        self.allowsSendVoice = true
        self.allowsSendFace = true
        self.allowsSendMultiMedia = true
        
        
        // 配置输入工具条的样式和布局

        
        // 水平间隔
        let horizontalPadding = 8
        
        // 垂直间隔
        let verticalPadding = 5
        
        // 输入框
        let textViewLeftMargin = 6.0
        
        // 按钮对象消息
        var button: UIButton;
        
        var textView: SCMessageTextView
        
        // 允许发送语音
        if (self.allowsSendVoice) {
            
            button = self.createButtonWithImage(UIImage(named: "voice"), hlImage: UIImage(named: "voice_HL"))
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: "toggleMessageOrVoiceButton", forControlEvents: UIControlEvents.TouchUpInside)
            button.setBackgroundImage(UIImage(named: "keyboard"), forState: UIControlState.Selected)
            self.voiceChangeButton = button
            self.addSubview(button)
            
            //水平布局
            self.addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat(
                    "H:|-\(horizontalPadding)-[voiceChangeButton(\(self.textViewLineHeight))]",
                    options: NSLayoutFormatOptions(),
                    metrics: nil,
                    views:["voiceChangeButton": self.voiceChangeButton]))
            
            //垂直布局
            self.addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat(
                    "V:|-\(verticalPadding)-[voiceChangeButton(\(self.textViewLineHeight))]",
                    options: NSLayoutFormatOptions(),
                    metrics: nil,
                    views:["voiceChangeButton": self.voiceChangeButton]))
        }
        
        //创建输入框
        textView = SCMessageTextView();
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.returnKeyType = UIReturnKeyType.Send;
        textView.enablesReturnKeyAutomatically = true; // UITextView内部判断send按钮是否可以用
        textView.placeHolder = "发送新消息";
        textView.delegate = self;
        
        self.addSubview(textView)
        self.inputTextView = textView
        self.inputTextView.layer.borderColor = UIColor(white: 0.8, alpha: 1.0).CGColor
        self.inputTextView.layer.borderWidth = 0.65;
        self.inputTextView.layer.cornerRadius = 6.0;
        
        //输入框的高度约束
        self.inputTextHeightConstraints = NSLayoutConstraint(
            item: self.inputTextView,
            attribute: NSLayoutAttribute.Height,
            relatedBy: NSLayoutRelation.Equal,
            toItem: nil,
            attribute: NSLayoutAttribute.NotAnAttribute,
            multiplier: 1,
            constant: CGFloat(self.textViewLineHeight))
        
        self.inputTextView.addConstraint(self.inputTextHeightConstraints)
        
        //垂直布局
        self.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|-\(verticalPadding)-[inputTextView]-\(verticalPadding)-|",
                options: NSLayoutFormatOptions(),
                metrics: nil,
                views:["inputTextView": self.inputTextView]))
        
        self.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:[voiceChangeButton]-\(textViewLeftMargin)-[inputTextView]",
                options: NSLayoutFormatOptions(),
                metrics: nil,
                views:["voiceChangeButton": self.voiceChangeButton,
                    "inputTextView": self.inputTextView]))
        
        // 允许发送多媒体消息，为什么不是先放表情按钮呢？因为布局的需要！
        if (self.allowsSendMultiMedia) {
            button = self.createButtonWithImage(UIImage(named: "multiMedia"), hlImage: UIImage(named: "multiMedia_HL"))
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addTarget(self, action: "handleMediaButtonPress", forControlEvents: UIControlEvents.TouchUpInside)
            button.tag = 2
            self.multiMediaSendButton = button
            self.addSubview(button)
            
            //水平布局
            self.addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat(
                    "H:[inputTextView]-\(textViewLeftMargin)-[multiMediaSendButton(\(self.textViewLineHeight))]-\(horizontalPadding)-|",
                    options: NSLayoutFormatOptions(),
                    metrics: nil,
                    views:["inputTextView": self.inputTextView,
                        "multiMediaSendButton": self.multiMediaSendButton]))
            
            //垂直布局
            self.addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat(
                    "V:|-\(verticalPadding)-[multiMediaSendButton(\(self.textViewLineHeight))]",
                    options: NSLayoutFormatOptions(),
                    metrics: nil,
                    views:["multiMediaSendButton": self.multiMediaSendButton]))
            
        }
        
        
        //        水平布局
        //        self.addConstraints(
        //            NSLayoutConstraint.constraintsWithVisualFormat(
        //                "H:|-\(horizontalPadding)-[voiceChangeButton(\(self.textViewLineHeight))]-\(textViewLeftMargin)-[inputTextView]-[multiMediaSendButton(\(self.textViewLineHeight))]",
        //                options: NSLayoutFormatOptions.allZeros,
        //                metrics: nil,
        //                views:["voiceChangeButton": self.voiceChangeButton,
        //                    "inputTextView": self.inputTextView,
        //                    "multiMediaSendButton": self.multiMediaSendButton]))
        
        // 允许发送表情
        /*
        if (self.allowsSendFace) {
        button = [self createButtonWithImage:[UIImage imageNamed:@"face"] HLImage:[UIImage imageNamed:@"face_HL"]];
        button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [button setBackgroundImage:[UIImage imageNamed:@"keyboard"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(messageStyleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = 1;
        buttonFrame = button.frame;
        if (self.allowsSendMultiMedia) {
        buttonFrame.origin = CGPointMake(CGRectGetMinX(self.multiMediaSendButton.frame) - CGRectGetWidth(buttonFrame) - horizontalPadding, verticalPadding);
        allButtonWidth += CGRectGetWidth(buttonFrame) + horizontalPadding * 1.5;
        } else {
        buttonFrame.origin = CGPointMake(CGRectGetWidth(self.bounds) - horizontalPadding - CGRectGetWidth(buttonFrame), verticalPadding);
        allButtonWidth += CGRectGetWidth(buttonFrame) + horizontalPadding * 2.5;
        }
        button.frame = buttonFrame;
        [self addSubview:button];
        
        self.faceSendButton = button;
        }
        */
        
        //背景颜色
        self.backgroundColor = UIColor.whiteColor();
        self.image = UIImage(named: "input-bar-flat")?.resizableImageWithCapInsets(UIEdgeInsetsMake(2.0, 0.0, 0.0, 0.0),
            resizingMode: UIImageResizingMode.Tile)
        
        
        // 如果是可以发送语言的，那就需要一个按钮录音的按钮，事件可以在外部添加
        if (self.allowsSendVoice) {
            
            let edgeInsets = UIEdgeInsetsMake(9, 9, 9, 9);
            button = self.createButtonWithImage(
                UIImage(named: "VoiceBtn_black")?.resizableImageWithCapInsets(edgeInsets, resizingMode: UIImageResizingMode.Stretch), hlImage: UIImage(named: "VoiceBtn_blackHL")?.resizableImageWithCapInsets(edgeInsets, resizingMode: UIImageResizingMode.Stretch))
            button.setTitleColor(
                UIColor.darkGrayColor(),
                forState: UIControlState.Normal)
            button.titleLabel?.font = UIFont.boldSystemFontOfSize(17)
            button.setTitle("按住 说话", forState: UIControlState.Normal)
            button.setTitle("松开 结束", forState: UIControlState.Highlighted)
            button.hidden = !self.voiceChangeButton.selected;
            
            //添加触发事件
            button.addTarget(self, action: "beginRecordVoice", forControlEvents: UIControlEvents.TouchDown)
            button.addTarget(self, action: "endRecordVoice", forControlEvents: UIControlEvents.TouchUpInside)
            button.addTarget(self, action: "cancelRecordVoice", forControlEvents: [UIControlEvents.TouchUpOutside, UIControlEvents.TouchCancel])
            button.addTarget(self, action: "remindDragExit", forControlEvents: UIControlEvents.TouchDragExit)
            button.addTarget(self, action: "remindDragEnter", forControlEvents: UIControlEvents.TouchDragEnter)
            
            self.holdDownButton = button
            self.addSubview(button)
            self.holdDownButton.translatesAutoresizingMaskIntoConstraints = false
            
            //垂直布局
            self.addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat(
                    "V:|[holdDownButton]|",
                    options: NSLayoutFormatOptions(),
                    metrics: nil,
                    views:["holdDownButton": self.holdDownButton]))
            
            self.addConstraints(
                NSLayoutConstraint.constraintsWithVisualFormat(
                    "H:[voiceChangeButton]-\(textViewLeftMargin)-[holdDownButton]-[multiMediaSendButton]",
                    options: NSLayoutFormatOptions(),
                    metrics: nil,
                    views:["voiceChangeButton": self.voiceChangeButton,
                        "holdDownButton": self.holdDownButton,
                    "multiMediaSendButton": self.multiMediaSendButton]))
        }
        
        self.recordingHUD = SCProgressHUD(frame: CGRectMake(0, 0, 140, 140))
        
        //初始化录音工具，并设定音量改变时的处理
        self.voiceRecord = VoiceRecord(minRecordTime: 1.0, powerForChannel: {
            [unowned self](lowPassResults) -> Void in
            //调整音量的图片显示
            self.recordingHUD.configRecordingHUDImageWithPeakPower(CGFloat(lowPassResults))
        })
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupUI()
    }
    
    //MARK：私有方法
    
    /**
    设置按钮图片
    
    - parameter image:
    - parameter hlImage:
    
    - returns:
    */
    private func createButtonWithImage(image: UIImage?, hlImage: UIImage?) -> UIButton {
        let button = UIButton()
        if let mImage = image {
            button.setBackgroundImage(mImage, forState: UIControlState.Normal)
        }
        
        if let mImage = hlImage {
            button.setBackgroundImage(mImage, forState: UIControlState.Highlighted)
        }
        
        return button
    }
    
    //MARK:按钮控制方法
    
    /**
    文本或语音切换按钮
    */
    func toggleMessageOrVoiceButton() {
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.voiceChangeButton.selected = !self.voiceChangeButton.selected
            self.holdDownButton.hidden = !self.voiceChangeButton.selected
            self.inputTextView.hidden = self.voiceChangeButton.selected
            
            if self.voiceChangeButton.selected {
                self.inputTextHeightConstraints.constant = CGFloat(self.textViewLineHeight);
                //收回键盘
                self.inputTextView.resignFirstResponder()
                
            } else {
//                self.inputTextHeightConstraints.constant = CGFloat(self.currentTextHeight!)
                //弹出键盘
                self.inputTextView.becomeFirstResponder()
            }
            
            self.layoutIfNeeded()
        })
    }
    
    /**
    点击多媒体按钮
    */
    func handleMediaButtonPress() {
        self.delegate?.didMediaButtonPress?(self)
    }
    
    //闭包函数测试
    func printMessage(sender:() -> Void) {
        sender()
        print("printMessage")
    }
    
    
    
}

// MARK: - 录音相关方法
extension SCMessageInputView {
    
    /**
    按下开始录音
    */
    func beginRecordVoice() {
        self.isCancelled = false;
        self.isRecording = false;
        self.recordingHUD.startReocordingHUD(self.superview!)
        self.voiceRecord.startRecord {
            [unowned self]() -> Void in
            self.isRecording = true
        }
    }
    
    /**
    手指松开停止录音
    */
    func endRecordVoice() {
        self.voiceRecord.stopRecord {
            [unowned self](isRecordSuccess, voiceData, voicePath, voiceDuration) -> Void in
            self.isRecording = false
            
            //如果记录成功
            if isRecordSuccess {
                //成功回调
                self.recordingHUD.stopRecordingHUD()
                if (voiceData != nil) {
                    //发送语音数据
                    self.delegate?.didFinishRecoingVoiceAction?(voiceData!, voicePath: voicePath, voiceDuration: voiceDuration)
                }
                
            } else {
                //失败回调
                self.recordingHUD.showMessageTooShortTip()
            }
        }
    }
    
    /**
    取消录音
    */
    func cancelRecordVoice() {
        if self.isRecording! {
            self.recordingHUD.cancelRecordingHUD()
            self.voiceRecord.cancelRecord({
                [unowned self]() -> Void in
                self.isRecording = false
                })
        } else {
            self.isCancelled = true
        }
    }
    
    /**
    手指移出按钮
    */
    func remindDragExit() {
        //暂停录音，只是显示效果，其实还在录音
        self.recordingHUD.pauseRecordingHUD()
    }
    
    /**
    手指再次移进按钮
    */
    func remindDragEnter() {
        //继续显示录音
        self.recordingHUD.resumeRecordingHUD()
    }
    
}
