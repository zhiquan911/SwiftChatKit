//
//  ViewController.swift
//  SwiftChatKit
//
//  Created by 麦志泉 on 09/01/2015.
//  Copyright (c) 2015 麦志泉. All rights reserved.
//

import UIKit
import RealmSwift
import AVOSCloudIM

class ChatViewController: SwiftChatTableViewController {
    
    var userName: String!
    var userId: String!
    var chatToId: String!
    var chatToName: String!
    var imClient = AVIMClient()
    var conversation: AVIMConversation?
    let pageSize: UInt = 7
    
    //使用数据缓存时需要用到的
    var DB: Realm!
    var perPageSize: Int = 7      //每页数量
    var messageOffset = 0   //当前加载数据的位置
    var realMessages: Results<RealMessage>!
    var enableDBCache = false
    
    var voiceFileFolder: NSURL {
        
        let fileManager = NSFileManager.defaultManager()
        var directoryURL = fileManager.URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)[0]
        directoryURL = directoryURL.URLByAppendingPathComponent("swiftchatCache")
        directoryURL = directoryURL.URLByAppendingPathComponent("voice")
        
        do {
            try NSFileManager.defaultManager().createDirectoryAtURL(directoryURL, withIntermediateDirectories: true, attributes: nil)
        }
        catch let error as NSError {
            error.description
        }
        
        return directoryURL
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.shareMenuView.delegate = self
        self.messageSender = self.userId
        self.navigationItem.title = self.userName
        //使用数据库缓存
        self.enableDBCacheMode(self.messageSender)
        //创建对话
        self.setLoadingMore(true)
        self.initConversion(self.userId, clients: [self.chatToId])
    }
    
    deinit {
        self.imClient.closeWithCallback {
            (isSuccess, error) -> Void in
            NSLog("退出会话")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: - 聊天控制器代理方法
extension ChatViewController {
    
    /**
     读取全部聊天记录数据数据
     */
    func enableDBCacheMode(messageSender: String) {
        NSLog("使用本地数据库缓存")
        self.messageSender = messageSender
        self.DB = DBHelper.getUserDB(self.messageSender)
        self.realMessages = DB.objects(RealMessage).sorted("timestamp", ascending: false)
    }
    
    /**
     把数据分页显示到UI
     */
    func loadMoreRealMessageToUI(
        toPosition: String = "top",
        isScrollToBottom: Bool = true
        ) {
            if self.realMessages.count == 0 {
                self.setLoadingMore(false)
                return
            }
            
            let start = self.messageOffset
            self.messageOffset = self.messageOffset + self.perPageSize
            if self.messageOffset > self.realMessages.count {
                self.messageOffset = self.realMessages.count
            }
            let end  = self.messageOffset
            
            
            
            var newMessages = [SCMessage]()
            //把数据转为NSObject的对象
            for var i = start; i < end; i++ {
                let message = self.realMessages[i].convertToSCMessage()
                //self.messages.append(message)
                newMessages.insert(message, atIndex: 0)
            }
            self.setLoadingMore(true)
            //插入新数据到顶部
            self.addChatMessage(newMessages, toPosition: toPosition, isScrollToBottom: isScrollToBottom, delayLoad:0.4)
    }
    
    //插入新消息到本地数据库中
    func insertNewMessageToRealmDB(chatMessages: [SCMessage]) {
        try! self.DB.write {
            for message in chatMessages {
                let realmMessage = RealMessage(message: message)
                let uuid = NSUUID().UUIDString
                realmMessage.messageUUID = uuid
                message.messageUUID = uuid
                self.DB.add(realmMessage)
            }
        }
        self.messageOffset = self.messageOffset + chatMessages.count
    }
    
    //更新消息状态
    func updateMessageStatus(message: SCMessage) {
        
        try! self.DB.write {
            self.DB.create(
                RealMessage.self,
                value: [
                    "sended": message.sended,
                    "messageUUID": message.messageUUID
                ],
                update: true)
        }
        
    }
    
    func configureCell(cell: SCMessageTableViewCell, indexPath: NSIndexPath) {
        let message = self.messages[indexPath.row]
        if message.senderId == self.userId {
            cell.labelUserName.text = self.userName
        } else {
            cell.labelUserName.text = self.chatToName
        }
    }
    
    func didSendMessage(messages: [SCMessage]) {
        
        //插入新消息
        self.addChatMessage(messages, toPosition: "bottom", isScrollToBottom: true)
        //插入数据库
        self.insertNewMessageToRealmDB(messages)
        
        for message in messages {
            let learnCloundMessge: AVIMTypedMessage
            switch message.messageMediaType! {
            case SCMessageMediaType.Text:
                let textMessage = AVIMTextMessage(text: message.text, attributes: nil)
                learnCloundMessge = textMessage
                break
            case SCMessageMediaType.Voice:
                let voiceMessage = AVIMAudioMessage(
                    text: message.voicePath,
                    attachedFilePath: SCConstants.voiceFileFolder.URLByAppendingPathComponent(message.voicePath).path!,
                    attributes: nil)
                learnCloundMessge = voiceMessage
            case SCMessageMediaType.Photo:
                let photoMessage = AVIMImageMessage(
                    text: message.originPhotoPath,
                    attachedFilePath: SCConstants.photoFileFolder.URLByAppendingPathComponent(message.originPhotoPath).path!,
                    attributes: nil)
                learnCloundMessge = photoMessage
            case SCMessageMediaType.Video:
                let videoMessage = AVIMVideoMessage(
                    text: message.videoPath,
                    attachedFilePath: SCConstants.videoFileFolder.URLByAppendingPathComponent(message.videoPath).path!,
                    attributes: nil)
                learnCloundMessge = videoMessage
  
            }
            
            //发送消息给对方
            self.conversation?.sendMessage(learnCloundMessge, callback:
                {
                    [unowned self](succeeded, error) -> Void in
                    if succeeded {
                        message.sended = true
                    }
                    
                    self.updateMessageStatus(message)

                    //发送完更新消息状态
                    let newIndexPath = NSIndexPath(forRow: self.messages.indexOf(message)!, inSection: 0)
                    self.tableView.reloadRowsAtIndexPaths([newIndexPath], withRowAnimation: UITableViewRowAnimation.None)
                })
        }
    }
    
    
    func shouldLoadMoreMessagesScrollToTop() -> Bool {
        return true
    }
    
    func loadMoreMessagesScrollTotop() {
        if self.messages.count == 0 {
            return
        } else {
            if (!self.loadingMoreData) {
                
                if enableDBCache {
                    self.loadMoreRealMessageToUI("top", isScrollToBottom: false)
                } else {
                    let message = self.messages[0]
                    let timestamp = Int64(message.timestamp.timeIntervalSince1970 * 1000)
                    self.loadMessageByLearnCloud(timestamp)
                }     
            }
        }
    }
    
    /**
    聊天单元格点击事件
    
    - parameter indexPath:
    - parameter cell:
    */
    func singleDidSelectMessageCell(indexPath: NSIndexPath, cell: SCMessageTableViewCell) {
        let message = self.messages[indexPath.row]
        if message.messageMediaType == SCMessageMediaType.Voice {
            self.playVoiceMessage(message, cell: cell)
            
            //更新已读
            try! self.DB.write {
                () -> Void in
                self.DB.create(
                    RealMessage.self,
                    value: [
                        "isRead": message.isRead,
                        "messageUUID": message.messageUUID
                    ],
                    update: true)
            }
            
        } else if message.messageMediaType == SCMessageMediaType.Photo {
            message.isRead = true
            let vc = MediaDisplayViewController()
            vc.message = message
            self.presentViewController(vc, animated: true, completion: nil)
        } else if message.messageMediaType == SCMessageMediaType.Video {
            message.isRead = true
            let vc = MediaDisplayViewController()
            vc.message = message
            self.presentViewController(vc, animated: true, completion: nil)
        }
    }
}

// MARK: - 控制器私有方法
extension ChatViewController {
    
    /**
    保存新的消息记录
    
    - parameter message:
    */
    func saveNewMessage(message: SCMessage) {
        let newMessage = AVObject(className: "SCMessage");
        newMessage.setObject(message.senderName, forKey: "senderName")
        newMessage.setObject("\(message.sended.hashValue)", forKey: "sended")
        newMessage.setObject("\(message.messageMediaType.hashValue)", forKey: "messageMediaType")
        newMessage.setObject(message.text, forKey: "text")
        newMessage.setObject("\(message.messageSourceType.hashValue)", forKey: "messageSourceType")
        newMessage.setObject("\(message.timestamp)", forKey: "timestamp")
        newMessage.save()
    }
    
    /**
    从云端把数据拉到本地
    
    - parameter file:
    - parameter fileName:
    */
    func fetchDataFromCloud(file: AVFile,filePath: NSURL, fileName: String) -> String? {
        let path = filePath.URLByAppendingPathComponent(fileName)
        var error: NSError?
        let data = file.getData(&error)
        if error == nil {
            data.writeToURL(path, atomically: true)
            return path.path;
        }
        return nil;
    }
    
    /**
    把learnCloud的消息转为框架的消息类型
    
    - parameter typeMessage:
    
    - returns:
    */
    func converMessageToSCMessage(typeMessage: AVIMTypedMessage) -> SCMessage {
        
        var scMessage = SCMessage()
        let msgType = typeMessage.mediaType
        
        switch msgType {
        case kAVIMMessageMediaTypeAudio:

            scMessage.messageMediaType = SCMessageMediaType.Voice;
            //保存音频文件到本地
            self.fetchDataFromCloud(typeMessage.file, filePath: SCConstants.voiceFileFolder, fileName: typeMessage.text)
            scMessage.voicePath = typeMessage.text
            scMessage.voiceDuration = String(Int((typeMessage as! AVIMAudioMessage).duration))
            break
        case kAVIMMessageMediaTypeImage:

            scMessage.messageMediaType = SCMessageMediaType.Photo
            scMessage.originPhotoUrl = typeMessage.file.url
            scMessage.thumbnailUrl = typeMessage.file.url

            break
        case kAVIMMessageMediaTypeVideo:
            
            //保存音频文件到本地
            self.fetchDataFromCloud(typeMessage.file,filePath: SCConstants.videoFileFolder, fileName: typeMessage.text)
            scMessage = SCMessage(videoPath: typeMessage.text)
            scMessage.messageMediaType = SCMessageMediaType.Video
            break
        default:
            scMessage.messageMediaType = SCMessageMediaType.Text;
            scMessage.text = typeMessage.text;
            break
        }
        
        scMessage.senderId = typeMessage.clientId
        if typeMessage.clientId == self.userId {
            scMessage.messageSourceType = SCMessageSourceType.Send
            scMessage.senderName = self.userName
        } else {
            scMessage.messageSourceType = SCMessageSourceType.Receive
            scMessage.senderName = self.chatToName
        }
        
        scMessage.sended = true;
        scMessage.timestamp = NSDate(timeIntervalSince1970: NSTimeInterval(typeMessage.sendTimestamp/1000))
        
        return scMessage
    }
    
    /**
    获取最近的聊天信息
    */
    func loadMessageByLearnCloud() {
        self.setLoadingMore(true)
        self.conversation?.queryMessagesWithLimit(pageSize, callback: {
            [unowned self](oldMessages, error) -> Void in
            var chatMessages = [SCMessage]()
            for message in oldMessages {
                let oldMessage = message as! AVIMTypedMessage
                let scMessage = self.converMessageToSCMessage(oldMessage)
                chatMessages.append(scMessage)
            }
            
            self.addChatMessage(chatMessages, toPosition: "top", isScrollToBottom: true, delayLoad: 1)
            
            
            })
    }
    
    
    
    /**
    获取时间戳之前的消息
    
    - parameter beforeTimestamp:
    */
    func loadMessageByLearnCloud(beforeTimestamp: Int64) {
        self.setLoadingMore(true)
        self.conversation?.queryMessagesBeforeId(
            nil,
            timestamp: beforeTimestamp,
            limit: pageSize,
            callback: {
                [unowned self](oldMessages, error) -> Void in
                var chatMessages = [SCMessage]()
                if oldMessages != nil && oldMessages.count > 0 {
                    for message in oldMessages {
                        let oldMessage = message as! AVIMTypedMessage
                        let scMessage = self.converMessageToSCMessage(oldMessage)
                        chatMessages.append(scMessage)
                    }
                }
                
                self.addChatMessage(chatMessages, toPosition: "top", isScrollToBottom: false, delayLoad: 1)
                
            })
        
    }
}

// MARK: - learnCloud相关方法
extension ChatViewController: AVIMClientDelegate {
    
    /**
    初始化会话
    
    - returns:
    */
    private func initConversion(userId: String, clients: [String]) {
        self.imClient.delegate = self
        
        
        self.imClient.openWithClientId(userId, callback: {
            [unowned self](succeeded, error) -> Void in
            if (error != nil) {
                // 出错了，可能是网络问题无法连接 LeanCloud 云端，请检查网络之后重试。
                // 此时聊天服务不可用。
                let view = UIAlertView(title: "聊天不可用！", message: error.description, delegate: self, cancelButtonTitle: "OK")
                
                view.show()
                self.setLoadingMore(false)
            } else {
                
                //先查询是否有历史对话
                let query: AVIMConversationQuery = self.imClient.conversationQuery()
                query.whereKey(kAVIMKeyMember, containsAllObjectsInArray: [self.chatToId])
                
                query.findConversationsWithCallback({
                    [unowned self](conversations, error) -> Void in
                    if error == nil {
                        if conversations != nil && conversations.count > 0 {
                            self.conversation = conversations[conversations.count-1] as? AVIMConversation
                            if self.enableDBCache {
                                self.loadMoreRealMessageToUI()
                            } else {
                                self.loadMessageByLearnCloud()
                            }
                            

                        } else {
                            self.setLoadingMore(false)
                            //建立与对方会话
                            self.imClient.createConversationWithName(nil, clientIds: clients, attributes: ["type" : "1"], options: AVIMConversationOption.None, callback: {
                                [unowned self](conversation, error) -> Void in
                                if (error == nil) {
                                    NSLog("建立会话成功")
                                    self.conversation = conversation
                                }
                                })
                        }
                    }
                    })
                
            }
            })
    }
    
    
    /**
    接收多媒体消息
    
    - parameter conversation:
    - parameter message:
    */
    func conversation(conversation: AVIMConversation!, didReceiveTypedMessage message: AVIMTypedMessage!) {
        NSLog("接收到新消息：\(message.content)")
        let scMessage = self.converMessageToSCMessage(message)
        self.addChatMessage([scMessage], toPosition: "bottom", isScrollToBottom: false)
    }
    
}


extension ChatViewController: SCShareMenuViewDelegate {
    
    func numberOfShareMenuItem() -> Int {
        return 4
    }
    
    func menuItemViewForIndex(index: Int) -> SCShareMenuItemView {
        let shareMenuItem: SCShareMenuItemView
        switch index {
        case 0:
            shareMenuItem = SCShareMenuItemView(
                image: UIImage(named: "sharemore_pic")!, title: "照片")
        case 1:
            shareMenuItem = SCShareMenuItemView(
                image: UIImage(named: "sharemore_video")!, title: "拍照")
        case 2:
            shareMenuItem = SCShareMenuItemView(
                image: UIImage(named: "sharemore_videovoip")!, title: "视频")
        case 3:
            shareMenuItem = SCShareMenuItemView(
                image: UIImage(named: "sharemore_location")!, title: "位置")
        case 4:
            shareMenuItem = SCShareMenuItemView(
                image: UIImage(named: "sharemore_friendcard")!, title: "名片")
        default:
            shareMenuItem = SCShareMenuItemView(
                image: UIImage(named: "sharemore_pic")!, title: "照片")
        }
        return shareMenuItem
    }
    
    func didSelectShareMenuItem(itemView: SCShareMenuItemView, atIndex: Int) {
        switch atIndex {
        case 0:     //点击相册按钮
            self.presentSystemAssetView(ALAssetsFilter.allPhotos(),minSelectCount: 1, maxSelectCount: 5)
        case 1:
            self.takePhoto()
        case 2:
            self.presentSystemAssetView(ALAssetsFilter.allVideos(),minSelectCount: 1, maxSelectCount: 1)
        default:break
        }
        NSLog("did select \(atIndex)")
    }
}
