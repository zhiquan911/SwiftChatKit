//
//  SwiftChatTableViewDelegate.swift
//  SwiftChatKit
//
//  Created by 麦志泉 on 15/10/17.
//  Copyright © 2015年 CocoaPods. All rights reserved.
//

import UIKit

/**
*  聊天窗口代理
*/
@objc public protocol SwiftChatTableViewDelegate: AnyObject {
    
    /**
    获取单元格的消息
    
    - parameter indexPath:
    
    - returns:
    */
    optional func messageForRowAtIndexPath(indexPath: NSIndexPath) -> SCMessage
    
    /**
    *  是否显示时间轴Label的回调方法
    *
    *  @param indexPath 目标消息的位置IndexPath
    *
    *  @return 根据indexPath获取消息的Model的对象，从而判断返回YES or NO来控制是否显示时间轴Label
    */
    optional func shouldDisplayTimestampForRowAtIndexPath(indexPath: NSIndexPath) -> Bool
    
    /**
    *  配置Cell的样式或者字体
    *
    *  @param cell      目标Cell
    *  @param indexPath 目标Cell所在位置IndexPath
    */
    optional func configureCell(cell: SCMessageTableViewCell,indexPath: NSIndexPath)
    
    /**
    *  协议回掉是否支持用户手动滚动
    *
    *  @return 返回YES or NO
    */
    optional func shouldPreventScrollToBottomWhileUserScrolling() -> Bool
    
    /**
    *  判断是否支持下拉加载更多消息
    *
    *  @return 返回BOOL值，判定是否拥有这个功能
    */
    optional func shouldLoadMoreMessagesScrollToTop() -> Bool
    
    /**
    *  下拉加载更多消息，只有在支持下拉加载更多消息的情况下才会调用。
    */
    optional func loadMoreMessagesScrollTotop()
    
    
    /**
    *  发送文本消息的回调方法
    *
    *  @param text   目标文本字符串
    *  @param sender 发送者的名字
    *  @param date   发送时间
    */
    optional func didSendText(text: String, fromSender: String, onDate: NSDate)
    
    /**
    *  发送图片消息的回调方法
    *
    *  @param photo  目标图片对象，后续有可能会换
    *  @param sender 发送者的名字
    *  @param date   发送时间
    */
    optional func didSendPhoto(photo: UIImage, fromSender: String, onDate: NSDate)
    
    /**
    发送相册图片，可连选多张
    
    - parameter assets:     已选相册的相数组
    - parameter fromSender:
    - parameter onDate:
    */
    optional func didSendAsset(assets: [ALAsset], fromSender: String, onDate: NSDate)
    
    /**
    发送相册视频
    
    - parameter asset:     视频
    - parameter fromSender:
    - parameter onDate:
    */
    optional func didSendAssetVideo(asset: ALAsset, fromSender: String, onDate: NSDate)
    
    /**
    *  发送语音消息的回调方法
    *
    *  @param voicePath        目标语音本地路径
    *  @param voiceDuration    目标语音时长
    *  @param sender           发送者的名字
    *  @param date             发送时间
    */
    optional func didSendVoice(voiceData: NSData, voicePath: String, voiceDuration: String, fromSender: String, onDate: NSDate)
    
    /**
    发送消息
    
    - parameter message: 消息对象
    */
    optional func didSendMessage(messages: [SCMessage])
    
}
