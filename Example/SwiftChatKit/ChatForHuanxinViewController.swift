//
//  ChatForHuanxinViewController.swift
//  SwiftChatKit
//
//  Created by 麦志泉 on 15/10/27.
//  Copyright © 2015年 CocoaPods. All rights reserved.
//

import UIKit

class ChatForHuanxinViewController: SwiftChatTableViewController {
    
    var userName: String!
    var userId: String!
    var chatToId: String!
    var chatToName: String!
    let pageSize: UInt = 7
    
    var conversation: EMConversation!    //会话管理者
    var messageQueue: dispatch_queue_t!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.shareMenuView.delegate = self
        self.messageSender = self.userId
        self.navigationItem.title = self.userName
        
        //创建对话
        self.setLoadingMore(true)
        self.initConversion()
        //通过会话管理者获取已收发消息
        let timestamp = NSDate().timeIntervalSince1970 * 1000 + 1
        self.loadMoreMessagesFrom(Int64(timestamp), count: pageSize, append: true)
    }
    
    deinit {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

// MARK: - 聊天控制器代理方法
extension ChatForHuanxinViewController {
    
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
        
        for message in messages {
            let retureMessge: EMMessage
            switch message.messageMediaType! {
            case SCMessageMediaType.Text:
                let chatText = EMChatText(text: message.text)
                let body = EMTextMessageBody(chatObject: chatText)
                retureMessge = EMMessage(receiver: self.chatToId, bodies: [body])
                break
            case SCMessageMediaType.Voice:
                
                let voice = EMChatVoice(file: SCConstants.voiceFileFolder.URLByAppendingPathComponent(message.voicePath).path!, displayName: message.voicePath)
                voice.duration = Int(message.voiceDuration)!
                let body = EMVoiceMessageBody(chatObject: voice)
                retureMessge = EMMessage(receiver: self.chatToId, bodies: [body])

            case SCMessageMediaType.Photo:
                
                let chatImage = EMChatImage(file: SCConstants.photoFileFolder.URLByAppendingPathComponent(message.originPhotoPath).path!, displayName: message.originPhotoPath)
                
                let body = EMImageMessageBody(image: chatImage, thumbnailImage: nil)
                retureMessge = EMMessage(receiver: self.chatToId, bodies: [body])

            case SCMessageMediaType.Video:
                
                let videoChat = EMChatVideo(file: SCConstants.videoFileFolder.URLByAppendingPathComponent(message.videoPath).path!, displayName: message.videoPath)
                let body = EMVideoMessageBody(chatObject: videoChat)
                // 生成message
                retureMessge = EMMessage(receiver: self.chatToId, bodies: [body])
                
            }
            
            retureMessge.requireEncryption = false
            retureMessge.messageType = EMMessageType.eMessageTypeChat
            
            EaseMob.sharedInstance().chatManager.asyncSendMessage(
                retureMessge,
                progress: nil,
                prepare: nil,
                onQueue: self.messageQueue,
                completion: {
                    (emMessage, error) -> Void in
                    if error == nil {
                        message.sended = true
                    }
                    
                    //发送完更新消息状态
                    let newIndexPath = NSIndexPath(forRow: self.messages.indexOf(message)!, inSection: 0)
                    self.tableView.reloadRowsAtIndexPaths([newIndexPath], withRowAnimation: UITableViewRowAnimation.None)
                    
                },
                onQueue: dispatch_get_main_queue()
            )
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
                let message = self.messages[0]
                self.loadMoreMessagesFrom(
                    Int64(message.timestamp.timeIntervalSince1970 * 1000),
                    count: pageSize,
                    append: true)
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
extension ChatForHuanxinViewController {
    
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
    func converMessageToSCMessage(typeMessage: EMMessage) -> SCMessage {
        
        let scMessage = SCMessage()
        let messageBody = typeMessage.messageBodies.first!
        let msgType = messageBody.messageBodyType!
        
        switch msgType {
        case MessageBodyType.eMessageBodyType_Voice:
            
            scMessage.messageMediaType = SCMessageMediaType.Voice;
            
            let voiceMessageBody = messageBody as! EMVoiceMessageBody
            let duration = voiceMessageBody.duration
            
            
            scMessage.voiceDuration = String(duration)
            
            if typeMessage.ext != nil {
                let dict = ["isPlayed": false]
                typeMessage.ext = dict
                typeMessage.updateMessageExtToDB()
            }
            
            // 本地音频路径
            let voice = NSData(contentsOfFile: voiceMessageBody.localPath)!
            let fileName = NSURL(string: voiceMessageBody.localPath)!.lastPathComponent
            let voiceFile = SCConstants.voiceFileFolder.URLByAppendingPathComponent(fileName!)
            voice.writeToURL(
                voiceFile,
                atomically: true
            )
            scMessage.voicePath = fileName
            
            break
        case MessageBodyType.eMessageBodyType_Image:
            
            scMessage.messageMediaType = SCMessageMediaType.Photo
            
            let imgMessageBody = messageBody as! EMImageMessageBody
            scMessage.originPhotoUrl = imgMessageBody.remotePath
            scMessage.photo = UIImage(contentsOfFile: imgMessageBody.localPath)
            scMessage.thumbnailPhoto = UIImage(contentsOfFile: imgMessageBody.localPath)
            
            break
        case MessageBodyType.eMessageBodyType_Video:
            let videoMessageBody = messageBody as! EMVideoMessageBody
            scMessage.messageMediaType = SCMessageMediaType.Video
            scMessage.videoUrl = videoMessageBody.remotePath
            scMessage.thumbnailUrl = videoMessageBody.thumbnailRemotePath
            break
        default:
            let textMessageBody = messageBody as! EMTextMessageBody
            scMessage.messageMediaType = SCMessageMediaType.Text;
            scMessage.text = textMessageBody.text;
            break
        }
        
        scMessage.senderId = typeMessage.from
        if typeMessage.from == self.userId {
            scMessage.messageSourceType = SCMessageSourceType.Send
            scMessage.senderName = self.userName
        } else {
            scMessage.messageSourceType = SCMessageSourceType.Receive
            scMessage.senderName = self.chatToName
        }
        
        scMessage.sended = true;
        scMessage.timestamp = NSDate(timeIntervalSince1970: NSTimeInterval(typeMessage.timestamp/1000))
        
        return scMessage
    }
    
    //读取聊天记录
    func loadMoreMessagesFrom(timestamp: Int64,count: UInt, append: Bool) {
        
        let messages = self.conversation.loadNumbersOfMessages(count, before: timestamp)
        if  messages.count > 0 {
            self.setLoadingMore(true)
        } else {
            self.setLoadingMore(false)
        }
        var chatMessages = [SCMessage]()
        for typedMessage in messages {
            let messasge = self.converMessageToSCMessage(typedMessage as! EMMessage)
            chatMessages.append(messasge)
        }
        
        self.addChatMessage(
            chatMessages,
            toPosition: "top",
            isScrollToBottom:!append,
            delayLoad: 0.4
        )
    }
}

// MARK: - 环信相关方法
extension ChatForHuanxinViewController: IChatManagerDelegate {
    
    /**
     *  初始化会话对象
     */
    func initConversion() {
        //根据接收者的username获取当前会话的管理者
        conversation = EaseMob.sharedInstance().chatManager.conversationForChatter!(self.chatToId, conversationType: EMConversationType.eConversationTypeChat)
        conversation.markAllMessagesAsRead(true)
        //以下三行代码必须写，注册为SDK的ChatManager的delegate
        EaseMob.sharedInstance().chatManager.removeDelegate(self)
        //注册为SDK的ChatManager的delegate
        EaseMob.sharedInstance().chatManager.addDelegate(self, delegateQueue: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applicationDidEnterBackground", name: "applicationDidEnterBackground", object: nil)
        
        self.messageQueue = dispatch_queue_create("chatDetailView", nil);
    }
    
    func applicationDidEnterBackground() {
        conversation.markAllMessagesAsRead(true)
    }
    
    func didReceiveMessage(message: EMMessage!) {
        let scMessage = self.converMessageToSCMessage(message)
        //插入新消息
        self.addChatMessage([scMessage], toPosition: "bottom", isScrollToBottom: true)
    }
    
}


extension ChatForHuanxinViewController: SCShareMenuViewDelegate {
    
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
