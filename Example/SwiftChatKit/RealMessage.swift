//
//  RealMessage.swift
//  SwiftChatKit
//
//  Created by 麦志泉 on 15/10/17.
//  Copyright © 2015年 CocoaPods. All rights reserved.
//

import RealmSwift
import AVFoundation

class RealMessage: Object {
    
    dynamic var messageUUID = NSUUID().UUIDString
    
    dynamic var messageId: Int = 0
    
    dynamic var text: String = ""
    
    
    //消息发送者的头像
    //头像地址
    dynamic var avatarUrl: String = ""
    //发送者的id
    dynamic var senderId: String = ""
    //发送者的名字
    dynamic var senderName: String = ""
    
    //发送时间
    dynamic var timestamp: NSDate = NSDate(timeIntervalSince1970: 1)
    
    //是否显示用户名字
    dynamic var shouldShowUserName: Bool = true
    
    //是否发送了
    dynamic var sended: Bool = false
    
    //是否出错
    dynamic var isError: Bool = false
    
    //错误信息
    dynamic var error: String = ""
    
    //消息来源类型
    var messageSourceType: SCMessageSourceType {
        get {
           return SCMessageSourceType(rawValue: self.sourceType)!
        }
        set {
            self.sourceType = newValue.rawValue
        }
    }
    
    dynamic var sourceType: Int = 0
    
    //消息媒体类型
    var messageMediaType: SCMessageMediaType {
        get {
            return SCMessageMediaType(rawValue: self.mediaType)!
        }
        set {
            self.mediaType = newValue.rawValue
        }
    }
    
    dynamic var mediaType: Int = 0
    
    //是否已读
    dynamic var isRead: Bool = false
    
    /********** 图像相关 **********/
    
    dynamic var voicePath: String = ""
    dynamic var voiceUrl: String = ""
    dynamic var voiceDuration: String = ""
    
    /********** 图像相关 **********/
    
    dynamic var thumbnailUrl: String = ""
    dynamic var originPhotoPath: String = ""
    dynamic var originPhotoUrl: String = ""
    
    /********** 视频相关 **********/
    
    dynamic var videoPath: String = ""
    dynamic var videoUrl: String = ""
    dynamic var videoDuration: String = ""
    
    override static func primaryKey() -> String? {
        return "messageUUID"
    }
    
    override static func ignoredProperties() -> [String] {
        return [
            "messageSourceType",
            "messageMediaType"
        ]
    }
    
    convenience init(message: SCMessage) {
        self.init()
        self.messageMediaType = message.messageMediaType
        self.voicePath = message.voicePath ?? ""
        self.voiceDuration = message.voiceDuration ?? ""
        self.originPhotoUrl = message.originPhotoUrl ?? ""
        self.thumbnailUrl = message.thumbnailUrl ?? ""
        self.originPhotoPath = message.originPhotoPath ?? ""
        self.videoUrl = message.videoUrl ?? ""
        self.videoDuration = message.videoDuration ?? ""
        self.videoPath = message.videoPath ?? ""
        self.text = message.text ?? ""
        self.messageSourceType = message.messageSourceType
        self.senderId = message.senderId ?? ""
        self.senderName = message.senderName ?? ""
        self.avatarUrl = message.avatarUrl ?? ""
        self.sended = message.sended
        self.timestamp = message.timestamp
        self.isError = message.isError
        self.error = message.error
    }

    
    func convertToSCMessage() -> SCMessage {
        let scMessage = SCMessage()
        let realmMessage = self
        scMessage.messageUUID = realmMessage.messageUUID
        scMessage.messageMediaType = realmMessage.messageMediaType
        scMessage.voicePath = realmMessage.voicePath
        scMessage.voiceDuration = realmMessage.voiceDuration
        scMessage.originPhotoUrl = realmMessage.originPhotoUrl
        scMessage.thumbnailUrl = realmMessage.thumbnailUrl
        scMessage.originPhotoPath = realmMessage.originPhotoPath
        scMessage.videoUrl = realmMessage.videoUrl
        scMessage.videoDuration = realmMessage.videoDuration
        scMessage.videoPath = realmMessage.videoPath
        scMessage.text = realmMessage.text
        scMessage.messageSourceType = realmMessage.messageSourceType
        scMessage.senderId = realmMessage.senderId
        scMessage.senderName = realmMessage.senderName
        scMessage.avatarUrl = realmMessage.avatarUrl
        scMessage.timestamp = realmMessage.timestamp
        scMessage.sended = realmMessage.sended
        scMessage.isError = realmMessage.isError
        scMessage.error = realmMessage.error
        
        if !realmMessage.videoPath.isEmpty {
            scMessage.setThumbnailPhotoByVideoPath(realmMessage.videoPath)
        }
        
        return scMessage
    }
}
