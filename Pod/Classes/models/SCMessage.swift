//
//  SCMessage.swift
//  Pods
//
//  Created by 麦志泉 on 15/9/1.
//
//

import Foundation
import UIKit
import AVFoundation

/**
消息媒体类型

- Text:          文本
- Photo:         图像
- Video:         视频
- Voice:         语音
- Emotion:       表情
- LocalPosition: 地理位置
*/
public enum SCMessageMediaType: Int {
    case Text, Photo, Video, Voice
    //, Emotion, LocalPosition
}

public enum SCMessageSourceType: Int {
    case Send, Receive
}

public class SCMessage: NSObject {
    
    var messageId: Int = 0
    
    var messageUUID = ""
    
    var text: String = ""
    

    //消息发送者的头像
    var avatar: UIImage?
    //头像地址
    var avatarUrl: String = ""
    //发送者的id
    var senderId: String = ""
    //发送者的名字
    var senderName: String = ""
    
    //发送时间
    var timestamp: NSDate = NSDate(timeIntervalSince1970: 1)
    
    //是否显示用户名字
    var shouldShowUserName: Bool = true
    
    //是否发送了
    var sended: Bool = false
    
    //是否出错
    var isError: Bool = false
    
    //错误信息
    var error: String = ""
    
    //消息来源类型
    var messageSourceType: SCMessageSourceType!
    
    //消息媒体类型
    var messageMediaType: SCMessageMediaType!
    
    //是否已读
    var isRead: Bool = false
    
    /************ 语音相关 ************/
    var voicePath: String!
    var voiceUrl: String!
    var voiceDuration: String!
    
    /************ 图像相关 ************/
    var photo: UIImage!
    var thumbnailPhoto: UIImage!
    var thumbnailUrl: String!
    var originPhotoUrl: String!
    var originPhotoPath: String! {
        didSet {
            let file = SCConstants.photoFileFolder.URLByAppendingPathComponent(self.originPhotoPath)
            let image = UIImage(contentsOfFile: file.path!)
            self.thumbnailPhoto = image
            self.photo = image
        }
    }
    
    /************ 视频相关 ************/
    var videoPath: String!
    var videoUrl: String!
    var videoDuration: String!
    
    convenience init(videoPath: String) {
        self.init()
        self.messageMediaType = SCMessageMediaType.Video
        self.videoPath = videoPath
        self.setThumbnailPhotoByVideoPath(self.videoPath)
    }
    
    func setThumbnailPhotoByVideoPath(videoPath: String) {
        var newImage: UIImage?
        do {
            let asset = AVURLAsset(URL: SCConstants.videoFileFolder.URLByAppendingPathComponent(self.videoPath))
            let assetImageGenerator = AVAssetImageGenerator(asset: asset)
            assetImageGenerator.appliesPreferredTrackTransform = true
            assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels
            
            let thumbnailImageRef: CGImageRef
            let thumbnailImageTime: Int64  = 0;
            
            thumbnailImageRef = try assetImageGenerator.copyCGImageAtTime(CMTimeMake(thumbnailImageTime, 60), actualTime: nil)
            
            newImage = UIImage(CGImage: thumbnailImageRef)
        } catch let error as NSError  {
            NSLog("setThumbnailPhotoByVideoPath error: \(error)")
        }
        if newImage != nil {
            self.thumbnailPhoto =  newImage
        }
    }
    
}