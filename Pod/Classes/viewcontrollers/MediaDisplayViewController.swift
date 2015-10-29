//
//  MediaDisplayViewController.swift
//  SwiftChatKit
//
//  Created by 麦志泉 on 15/10/10.
//  Copyright © 2015年 CocoaPods. All rights reserved.
//

import UIKit
import AlamofireImage
import MediaPlayer

public class MediaDisplayViewController: UIViewController {
    
    var imageViewPhoto: UIImageView!
    var message: SCMessage!
    var progressView: UIActivityIndicatorView!
    var moviePlayerController: MPMoviePlayerController!
    var buttonClose: UIButton!
    
    func setupUI() {
        self.view.backgroundColor = UIColor.blackColor()
        if self.imageViewPhoto == nil {
            self.imageViewPhoto = UIImageView(frame: self.view.bounds)
            self.imageViewPhoto.userInteractionEnabled = true
            self.imageViewPhoto.translatesAutoresizingMaskIntoConstraints = false
            self.imageViewPhoto.contentMode = UIViewContentMode.ScaleAspectFit
            self.imageViewPhoto.clipsToBounds = true
            self.imageViewPhoto.hidden = true
            self.view.addSubview(self.imageViewPhoto)
        }
        
        if self.progressView == nil {
            self.progressView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
            self.progressView.translatesAutoresizingMaskIntoConstraints = false
            self.progressView.hidesWhenStopped = true
            self.view.addSubview(self.progressView)
        }
        
        if self.moviePlayerController == nil {
            self.moviePlayerController = MPMoviePlayerController()
            self.moviePlayerController.repeatMode = MPMovieRepeatMode.One
            self.moviePlayerController.scalingMode = MPMovieScalingMode.AspectFit
            self.moviePlayerController.view.frame = self.view.frame
            self.moviePlayerController.view.hidden = true
            self.view.addSubview(self.moviePlayerController.view)
        }
        
        if self.buttonClose == nil {
            self.buttonClose = UIButton(type: UIButtonType.Custom)
            self.buttonClose.translatesAutoresizingMaskIntoConstraints = false
            self.buttonClose.setImage(UIImage(named: "cancel_White"), forState: UIControlState.Normal)
            self.buttonClose.backgroundColor = UIColor(white: 0, alpha: 0.55)
            self.buttonClose.addTarget(self, action: "handleCloseButtonPress:", forControlEvents: UIControlEvents.TouchUpInside)
            self.buttonClose.layer.cornerRadius = 15
            self.buttonClose.layer.masksToBounds = true
            self.view.addSubview(self.buttonClose)
        }
        
        let views = [
            "imageViewPhoto": self.imageViewPhoto,
            "progressView": self.progressView,
            "buttonClose": self.buttonClose
        ]
        
        //水平布局
        self.view.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[imageViewPhoto]|",
                options: NSLayoutFormatOptions(),
                metrics: nil,
                views:views))
        
        //垂直布局
        self.view.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|[imageViewPhoto]|",
                options: NSLayoutFormatOptions(),
                metrics: nil,
                views:views))
        
        //水平布局
        self.view.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|[progressView]|",
                options: NSLayoutFormatOptions(),
                metrics: nil,
                views:views))
        
        //垂直布局
        self.view.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|[progressView]|",
                options: NSLayoutFormatOptions(),
                metrics: nil,
                views:views))
        
        //水平布局
        self.view.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "H:[buttonClose(30)]-15-|",
                options: NSLayoutFormatOptions(),
                metrics: nil,
                views:views))
        
        //垂直布局
        self.view.addConstraints(
            NSLayoutConstraint.constraintsWithVisualFormat(
                "V:|-20-[buttonClose(30)]",
                options: NSLayoutFormatOptions(),
                metrics: nil,
                views:views))
        
//        //水平布局
//        self.view.addConstraints(
//            NSLayoutConstraint.constraintsWithVisualFormat(
//                "H:|[moviePlayerController]|",
//                options: NSLayoutFormatOptions(),
//                metrics: nil,
//                views:views))
//        
//        //垂直布局
//        self.view.addConstraints(
//            NSLayoutConstraint.constraintsWithVisualFormat(
//                "V:|[moviePlayerController]|",
//                options: NSLayoutFormatOptions(),
//                metrics: nil,
//                views:views))
        
        //图片添加点击事件
        let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "singleTapGestureRecognizerHandle:")
        self.imageViewPhoto.addGestureRecognizer(tapGestureRecognizer)

    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        self.loadMedia()
    }
    
    deinit {
        if self.message.messageMediaType == SCMessageMediaType.Video {
            self.moviePlayerController.stop()
        }
    }
    
    /**
    加载图片
    */
    func loadMedia () {
        switch message.messageMediaType! {
        case SCMessageMediaType.Photo:
            self.imageViewPhoto.hidden = false
            self.moviePlayerController.view.hidden = true
            if message.photo != nil {
                self.imageViewPhoto.image = message.photo
            } else {
                let filter = AspectScaledToFitSizeWithRoundedCornersFilter(
                    size: self.view.bounds.size,
                    radius: 0.0
                )
                
                self.imageViewPhoto.af_setImageWithURL(NSURL(string: message.originPhotoUrl)!, placeholderImage: SCMessageTableViewCell.kDefaultImage, filter: filter)
            }
        case SCMessageMediaType.Video:
        self.imageViewPhoto.hidden = true
        self.moviePlayerController.view.hidden = false
        if message.videoPath.isEmpty {
            self.moviePlayerController.contentURL = NSURL(string: message.videoUrl)
        } else {
            self.moviePlayerController.contentURL = SCConstants.videoFileFolder.URLByAppendingPathComponent(message.videoPath)
        }
        
        self.moviePlayerController.play()
        default:break
        }
    }
    
    /**
    点击关闭按钮
    
    - parameter sender:
    */
    func handleCloseButtonPress(sender: AnyObject?) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    /**
    点击事件
    
    - parameter tapGestureRecognizer:
    */
    func singleTapGestureRecognizerHandle(tapGestureRecognizer: UITapGestureRecognizer) {
        
        if tapGestureRecognizer.state == UIGestureRecognizerState.Ended {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    override public func prefersStatusBarHidden() -> Bool {
        return true
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

//增加一个图片加载完后的过滤
public struct AspectScaledToFitSizeWithRoundedCornersFilter: CompositeImageFilter {

    public init(size: CGSize, radius: CGFloat, divideRadiusByImageScale: Bool = false) {
        self.filters = [
            AspectScaledToFitSizeFilter(size: size),
            RoundedCornersFilter(radius: radius, divideRadiusByImageScale: divideRadiusByImageScale)
        ]
    }
    
    /// The image filters to apply to the image in sequential order.
    public let filters: [ImageFilter]
}
