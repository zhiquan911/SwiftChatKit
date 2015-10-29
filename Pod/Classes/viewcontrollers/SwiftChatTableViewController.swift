//
//  SwiftChatTableViewController.swift
//  Pods
//
//  Created by 麦志泉 on 15/9/1.
//
//

import UIKit
import AlamofireImage
import Alamofire
import SVProgressHUD

/// 聊天窗口控制器
public class SwiftChatTableViewController: UIViewController, SwiftChatTableViewDelegate, SCMessageTableViewCellDelegate {
    
    //常量
    let kShareMenuViewHeight: CGFloat = 216.0

    weak var delegate: SwiftChatTableViewDelegate?
    var tableView: ChatTableView!
    var shareMenuView: SCShareMenuView!
    var isShareMenuViewShow = false
    var cellCache = [Int: UITableViewCell]()
    var messageInputView: SCMessageInputView!
    var button: UIButton!
    var messages = [SCMessage]()
    
    var messageSender: String!
    var messageInputBottomConstraints: NSLayoutConstraint!
    var _shouldLoadMoreMessagesScrollToTop: Bool? = true
    var progressViewLoadMore: UIActivityIndicatorView!
    var headerView: UIView!
    var isDragging: Bool! = false
    var currentScrollViewContentOffset: CGPoint = CGPointZero
    var oldScrollViewContentSize: CGSize = CGSizeZero
    var currentSelecedCell: SCMessageTableViewCell?
    var imagePicker: UIImagePickerController!
    
    var isTableScrollToBottom: Bool {
        let height = tableView.frame.size.height
        let contentYoffset = tableView.contentOffset.y
        let distanceFromBottom = tableView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            return true
        } else {
            return false
        }
    }
    
    
    var loadingMoreData: Bool = false
    
    var canLoadmore: Bool {
        set {
            if newValue {
                self.tableView.tableHeaderView = self.headerView
            } else {
                self.tableView.tableHeaderView = nil
            }
        }
        get {
            if self.tableView.tableHeaderView == nil {
                return false
            } else {
                return true
            }
        }
    }
    
    //多媒体工具条的底部约束，用于动态调整高度
    var shareMenuViewBottomConstraints: NSLayoutConstraint!
    
    //配置UI
    func setupUI() {
        
        //UIControlEventTouchDown 此事件是手指碰到按钮就调用了。 这样在IOS7上会有一个冲突。
        //IOS7以后增加了手势滑动返回。 在手势滑动返回的那个区域是不允许
        //有UIControlEventTouchDown事件的。 不然的话，就会有事件冲突了。
        //系统不知道是要准备返回 还是要点那个BUTTON。 。
        self.navigationController?.interactivePopGestureRecognizer?.delaysTouchesBegan = false
        
        
        self.delegate = self
        
        self.tableView = ChatTableView(frame: CGRectZero,
            style:.Plain)
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.translatesAutoresizingMaskIntoConstraints = false  //一定要设置false不然无法使用相对布局
        self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissMode.OnDrag
        //        self.tableView.rowHeight = UITableViewAutomaticDimension
        //        self.tableView.estimatedRowHeight = 90;
        self.view.addSubview(self.tableView)
        
        
        //加入loading表头
        self.headerView = UIView(frame: CGRectMake(0, 0, self.view.bounds.width, 44))
        self.headerView.backgroundColor = self.tableView.backgroundColor
        self.tableView.tableHeaderView = headerView
        
        //加入loadingView
        self.progressViewLoadMore = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        self.progressViewLoadMore.translatesAutoresizingMaskIntoConstraints = false
        self.headerView.addSubview(self.progressViewLoadMore)
        
        
        self.messageInputView = SCMessageInputView(frame: CGRectZero)
        self.messageInputView.translatesAutoresizingMaskIntoConstraints = false
        self.messageInputView.inputTextView.delegate = self
        self.messageInputView.delegate = self
        self.view.addSubview(messageInputView)
        
        
        //多媒体工具栏
        self.shareMenuView = SCShareMenuView()
        self.shareMenuView.translatesAutoresizingMaskIntoConstraints = false
        shareMenuView.backgroundColor = UIColor(white: 0.961, alpha: 1)
        self.view.addSubview(self.shareMenuView)
        
        self.setupViewConstraints();
        
        //表格注册单元格xib
        self.tableView .registerNib(UINib(nibName: "SCMessageSenderTextCell", bundle: nil), forCellReuseIdentifier: "SCMessageSenderTextCell")
        self.tableView .registerNib(UINib(nibName: "SCMessageReceiverTextCell", bundle: nil), forCellReuseIdentifier: "SCMessageReceiverTextCell")
        self.tableView .registerNib(UINib(nibName: "SCMessageReceiverVoiceCell", bundle: nil), forCellReuseIdentifier: "SCMessageReceiverVoiceCell")
        self.tableView .registerNib(UINib(nibName: "SCMessageSenderVoiceCell", bundle: nil), forCellReuseIdentifier: "SCMessageSenderVoiceCell")
        self.tableView .registerNib(UINib(nibName: "SCMessageSenderPhotoCell", bundle: nil), forCellReuseIdentifier: "SCMessageSenderPhotoCell")
        self.tableView .registerNib(UINib(nibName: "SCMessageReceiverPhotoCell", bundle: nil), forCellReuseIdentifier: "SCMessageReceiverPhotoCell")
        self.tableView .registerNib(UINib(nibName: "SCMessageSenderVideoCell", bundle: nil), forCellReuseIdentifier: "SCMessageSenderVideoCell")
        self.tableView .registerNib(UINib(nibName: "SCMessageReceiverVideoCell", bundle: nil), forCellReuseIdentifier: "SCMessageReceiverVideoCell")
        
    }
    
    /**
    配置视图组件约束
    */
    func setupViewConstraints() {
        
        let views = [
            "tableView": self.tableView,
            "messageInputView": self.messageInputView,
            "headerView": self.headerView,
            "progressViewLoadMore": self.progressViewLoadMore,
            "shareMenuView": self.shareMenuView
        ]
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[tableView]|",
            options: NSLayoutFormatOptions(),
            metrics: nil,
            views:views));
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[tableView]-0-[messageInputView]",
            options: NSLayoutFormatOptions(),
            metrics: nil,
            views:views))
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[messageInputView]|",
            options: NSLayoutFormatOptions(),
            metrics: nil,
            views:views))
        
        //输入框的高度约束
        self.messageInputBottomConstraints = NSLayoutConstraint(
            item: self.view!,
            attribute: NSLayoutAttribute.Bottom,
            relatedBy: NSLayoutRelation.Equal,
            toItem: self.messageInputView,
            attribute: NSLayoutAttribute.Bottom,
            multiplier: 1,
            constant: 0)
        
        self.view.addConstraint(self.messageInputBottomConstraints)
        
        self.headerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[progressViewLoadMore]|",
            options: NSLayoutFormatOptions(),
            metrics: nil,
            views:views))
        
        self.headerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[progressViewLoadMore]|",
            options: NSLayoutFormatOptions(),
            metrics: nil,
            views:views))
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|[shareMenuView]|",
            options: NSLayoutFormatOptions(),
            metrics: nil,
            views:views))
        
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(
            "V:[messageInputView]-0-[shareMenuView(\(kShareMenuViewHeight))]",
            options: NSLayoutFormatOptions(),
            metrics: nil,
            views:views))
        
    }
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
        
    }
    
    override public func viewDidAppear(animated: Bool) {
        
        // KVO 检查contentSize
        self.messageInputView.inputTextView.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.New, context: nil)
        
        self.messageInputView.inputTextView.editable = true
        
        //刷新多媒体菜单
        self.shareMenuView.reloadData()
    }
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        //键盘弹出时的监听，注意通过selector调用的方法不能为私有方法
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "keyboardChange:",
            name: UIKeyboardWillShowNotification,
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "keyboardChange:",
            name: UIKeyboardWillHideNotification,
            object: nil)
        
        //注册通知，当键盘弹出时把表格混会到底部
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "tableViewScrollToBottom",
            name: UIKeyboardDidShowNotification,
            object: nil)
    }
    
    override public func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // remove KVO
        self.messageInputView.inputTextView.removeObserver(self, forKeyPath: "contentSize")
        self.messageInputView.inputTextView.editable = false
        
        //注销通知
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    // MARK: 聊天UI代理方法
    
    /**
    是否显示事件
    
    - parameter indexPath:
    
    - returns:
    */
    public func shouldDisplayTimestampForRowAtIndexPath(indexPath: NSIndexPath) -> Bool {
        if indexPath.row == 0 || indexPath.row > self.messages.count {
            return true
        } else {
            let message: SCMessage = self.messages[indexPath.row]
            let previousMessage: SCMessage = self.messages[indexPath.row-1]
            let interval: NSTimeInterval = message.timestamp.timeIntervalSinceDate(previousMessage.timestamp)
            if(interval > 60 * 3){  //超过3分钟才显示
                return true;
            }else{
                return false;
            }
        }
    }
    
    /**
    动态调整textView高度
    
    - parameter textView:
    */
    func layoutAndAnimateMessageInputTextView(textView: UITextView) {
        let maxHeight = self.messageInputView.maxHeight;
        var contentH = Float(textView.sizeThatFits(textView.frame.size).height)
        contentH = ceilf(contentH)
        if contentH <= maxHeight {
            UIView.animateWithDuration(0.25,
                animations: { () -> Void in
                    //改变输入框的高度约束
                    self.messageInputView.inputTextHeightConstraints.constant = CGFloat(contentH)
                    self.messageInputView.layoutIfNeeded()
                }) { (finished Bool) -> Void in
                    self.messageInputView.currentTextHeight = contentH
            }
        }
        
    }
}

// MARK: - 控制器私有方法
extension SwiftChatTableViewController {
    
    func keyboardChange(notification: NSNotification) {
        let userInfo: NSDictionary = notification.userInfo!;
        let keyBoardInfo: AnyObject? = userInfo.objectForKey(UIKeyboardFrameEndUserInfoKey);
        let keyBoardHeight = (keyBoardInfo?.CGRectValue.size.height)!; //键盘最终的高度
        
        //        UIView.beginAnimations(nil, context: nil)
        //        UIView.setAnimationDuration(animationDuration)
        //        UIView.setAnimationCurve(animationCurve)
        
        UIView.animateWithDuration(0.25,
            animations: {
                [unowned self]() -> Void in
                
                //adjust ChatTableView's height
                if (notification.name == UIKeyboardWillShowNotification) {
                    self.isShareMenuViewShow = false    //键盘弹出后，多媒体隐藏
                    if keyBoardHeight > 0 {
                        self.messageInputBottomConstraints.constant = keyBoardHeight
                    }
                } else {
                    if !self.isShareMenuViewShow {   //如果用户不是显示多媒体菜单，才把键盘高度设为0
                        self.messageInputBottomConstraints.constant = 0
                    }
                    
                }
                
                self.view.layoutIfNeeded()
                //                self.view.setNeedsUpdateConstraints()
            }) { (Bool) -> Void in
                
        }
        
        
        
        //        UIView.commitAnimations()
        
    }
    
    /**
    切换多媒体view的可见
    
    - parameter isVisible: 有值时，把这个值设置是否显示
    */
    func toggleMediaViewVisible(isVisible: Bool? = nil) {
        if (isVisible != nil) {
            self.isShareMenuViewShow = isVisible!
        } else {
            self.isShareMenuViewShow = !self.isShareMenuViewShow
        }
        
        UIView.animateWithDuration(0.25, animations: {
            [unowned self]() -> Void in
            if self.isShareMenuViewShow {
                self.messageInputView.inputTextView.resignFirstResponder()
                self.messageInputBottomConstraints.constant = self.kShareMenuViewHeight
            } else {
                self.messageInputBottomConstraints.constant = 0
            }
            self.view.layoutIfNeeded()
            })
            {
                [unowned self](isSuccess) -> Void in
                if self.isShareMenuViewShow {
                    self.tableViewScrollToBottom(true)
                }
                
        }
    }
    
    /**
    插入单元家
    
    - parameter indexPaths: 单元格数组
    - parameter animation:  动画
    */
    private func insertRowsAtIndexPaths(indexPaths: [NSIndexPath],animation: UITableViewRowAnimation) {
        self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: animation)
    }
    
    /**
    配置显示时间戳
    
    - parameter displayTimestamp:
    - parameter timestamp:
    */
    private func configureTimestamp(indexPath: NSIndexPath,
        cell: SCMessageTableViewCell, message: SCMessage) {
            var displayTimestamp = true
            if (self.delegate != nil) {
                displayTimestamp = self.delegate!.shouldDisplayTimestampForRowAtIndexPath!(indexPath)
            }
            
            //改变时间label的高度来控制是否显示
            if displayTimestamp {
                //删除约束
                cell.viewTimeStamp.addConstraint(cell.viewTimestampLeftMarginContraints)
                cell.viewTimeStamp.addConstraint(cell.viewTimestampRightMarginContraints)
                cell.viewTimeStamp.addConstraint(cell.viewTimestampBottomMarginContraints)
                cell.viewTimeStamp.addConstraint(cell.viewTimestampTopMarginContraints)
                
                let shortTime = DateUtils.friendlyTimeForChat(message.timestamp)
                cell.labelTimeStamp.text = shortTime;
            } else {
                cell.labelTimeStamp.text = "";
                
                //删除约束
                cell.viewTimeStamp.removeConstraint(cell.viewTimestampLeftMarginContraints)
                cell.viewTimeStamp.removeConstraint(cell.viewTimestampRightMarginContraints)
                cell.viewTimeStamp.removeConstraint(cell.viewTimestampBottomMarginContraints)
                cell.viewTimeStamp.removeConstraint(cell.viewTimestampTopMarginContraints)
            }
            //刷新view的约束
            cell.viewTimeStamp.layoutIfNeeded()
    }
    
    
    
    //配置单元格
    private func configCellAtIndexPath(indexPath:NSIndexPath) -> SCMessageTableViewCell {
        let cell:SCMessageTableViewCell
        let message: SCMessage = self.messages[indexPath.row]
        switch message.messageMediaType! {
        case SCMessageMediaType.Text:        //文本消息
            cell = self.configTextCellAtIndexPath(indexPath, message: message)
            break
        case SCMessageMediaType.Voice:       //语音消息
            cell = self.configVoiceCellAtIndexPath(indexPath, message: message)
            break
        case SCMessageMediaType.Photo:       //图片消息
            cell = self.configPhotoCellAtIndexPath(indexPath, message: message)
            break
        case SCMessageMediaType.Video:       //图片消息
            cell = self.configVideoCellAtIndexPath(indexPath, message: message)
            break
        default:
            cell = self.configTextCellAtIndexPath(indexPath, message: message)
        }
        cell.delegate = self
        cell.configMessageCellTouchEvent(indexPath, message: message)
        cell.selectionStyle = UITableViewCellSelectionStyle.None
        return cell
    }
    
    /**
    配置文本的消息单元格
    
    - parameter indexPath:
    */
    private func configTextCellAtIndexPath(indexPath:NSIndexPath, message:SCMessage) -> SCMessageTableViewCell {
        var cell: SCMessageTableViewCell
        switch message.messageSourceType! {
            //发送方
        case SCMessageSourceType.Send:
            cell = self.tableView.dequeueReusableCellWithIdentifier("SCMessageSenderTextCell") as! SCMessageTableViewCell
            break;
            //接收方
        case SCMessageSourceType.Receive:
            cell = self.tableView.dequeueReusableCellWithIdentifier("SCMessageReceiverTextCell") as! SCMessageTableViewCell
            break;
        }
        
        //1.配置显示时间戳
        self.configureTimestamp(indexPath, cell: cell, message: message)
        //2.配置显示用户名
        cell.labelUserName.text = message.senderName ?? ""
        //3.配置显示消息内容
        cell.labelMessageText.text = message.text ?? ""
        
        self.configCellLoadingView(indexPath, cell: cell, message: message)
        
        return cell
    }
    
    func configCellLoadingView(indexPath: NSIndexPath,
        cell: SCMessageTableViewCell, message: SCMessage) {
            
            if message.sended {
                cell.progressView.stopAnimating()
                cell.progressView.hidden = true
            } else {
                cell.progressView.hidden = false
                cell.progressView.startAnimating()
                
            }
    }
    
    /**
    配置语音单元格
    
    - parameter indexPath:
    - parameter message:
    
    - returns:
    */
    private func configVoiceCellAtIndexPath(indexPath:NSIndexPath, message:SCMessage) -> SCMessageTableViewCell {
        
        var cell: SCMessageTableViewCell
        switch message.messageSourceType! {
            //发送方
        case SCMessageSourceType.Send:
            cell = self.tableView.dequeueReusableCellWithIdentifier("SCMessageSenderVoiceCell") as! SCMessageTableViewCell
            break;
            //接收方
        case SCMessageSourceType.Receive:
            cell = self.tableView.dequeueReusableCellWithIdentifier("SCMessageReceiverVoiceCell") as! SCMessageTableViewCell
            break;
        }
        
        //1.配置显示时间戳
        self.configureTimestamp(indexPath, cell: cell, message: message)
        //2.配置显示用户名
        cell.labelUserName.text = message.senderName ?? ""
        //3.配置显示消息内容
        cell.labelVoiceDuration.text = "\(message.voiceDuration)''" ?? "0''"
        if message.isRead {
            cell.imageViewVoicePlayed.hidden = true
        } else {
            cell.imageViewVoicePlayed.hidden = false
        }
        cell.setVoiceDurationWidth(Float(message.voiceDuration)!)
        self.configCellLoadingView(indexPath, cell: cell, message: message)
        return cell
    }
    
    /**
    配置图片媒体的单元格
    
    - parameter indexPath:
    - parameter message:
    
    - returns:
    */
    private func configPhotoCellAtIndexPath(indexPath:NSIndexPath, message:SCMessage) -> SCMessageTableViewCell {
        
        var cell: SCMessageTableViewCell
        switch message.messageSourceType! {
            //发送方
        case SCMessageSourceType.Send:
            cell = self.tableView.dequeueReusableCellWithIdentifier("SCMessageSenderPhotoCell") as! SCMessageTableViewCell
            break;
            //接收方
        case SCMessageSourceType.Receive:
            cell = self.tableView.dequeueReusableCellWithIdentifier("SCMessageReceiverPhotoCell") as! SCMessageTableViewCell
            break;
        }
        
        //1.配置显示时间戳
        self.configureTimestamp(indexPath, cell: cell, message: message)
        //2.配置显示用户名
        cell.labelUserName.text = message.senderName ?? ""
        //3.配置显示图片
        
        if message.thumbnailPhoto == nil {
            cell.imageViewPhoto.setMask(true)
            cell.imageViewPhoto.setImage(SCMessageTableViewCell.kDefaultImage)
            //下载图片
            Alamofire.request(.GET, message.originPhotoUrl)
                .responseImage(completionHandler: {
                    [unowned self](_, _, result) -> Void in
                    if let image = result.value {
                        //cell是否显示
                        //在闭包中，要重新得到单元格的位置，因为当表格动态加载了更多Cell后，原来的indexPath已经不是现在正确的了。要重新用messages计算当前的位置
                        let newIndexPath = NSIndexPath(forRow: self.messages.indexOf(message)!, inSection: 0)
                        if !self.isOutOfTableViewVisibleContent(
                            cell,
                            indexPath: newIndexPath) {
                                cell.imageViewPhoto.setMask(false)
                                cell.imageViewPhoto.setImage(image)
                        }
                        
                        message.thumbnailPhoto = image
                    }
                    })
            
        } else {
            cell.imageViewPhoto.setMask(!message.sended)
            cell.imageViewPhoto.setImage(message.thumbnailPhoto!)
        }
        
        self.configCellLoadingView(indexPath, cell: cell, message: message)
        return cell
    }
    
    /**
    配置视频单元格
    
    - parameter indexPath:
    - parameter message:
    
    - returns:
    */
    private func configVideoCellAtIndexPath(indexPath:NSIndexPath, message:SCMessage) -> SCMessageTableViewCell {
        
        var cell: SCMessageTableViewCell
        switch message.messageSourceType! {
            //发送方
        case SCMessageSourceType.Send:
            cell = self.tableView.dequeueReusableCellWithIdentifier("SCMessageSenderVideoCell") as! SCMessageTableViewCell
            break;
            //接收方
        case SCMessageSourceType.Receive:
            cell = self.tableView.dequeueReusableCellWithIdentifier("SCMessageReceiverVideoCell") as! SCMessageTableViewCell
            break;
        }
        
        //1.配置显示时间戳
        self.configureTimestamp(indexPath, cell: cell, message: message)
        //2.配置显示用户名
        cell.labelUserName.text = message.senderName ?? ""
        //3.配置显示图片
        
        if message.thumbnailPhoto == nil {
            cell.imageViewPhoto.setMask(true)
            cell.imageViewPhoto.setImage(SCMessageTableViewCell.kDefaultImage)
            
            //下载图片
            Alamofire.request(.GET, message.thumbnailUrl)
                .responseImage(completionHandler: {
                    [unowned self](_, _, result) -> Void in
                    if let image = result.value {
                        //cell是否显示
                        //在闭包中，要重新得到单元格的位置，因为当表格动态加载了更多Cell后，原来的indexPath已经不是现在正确的了。要重新用messages计算当前的位置
                        let newIndexPath = NSIndexPath(forRow: self.messages.indexOf(message)!, inSection: 0)
                        if !self.isOutOfTableViewVisibleContent(
                            cell,
                            indexPath: newIndexPath) {
                                cell.imageViewPhoto.setMask(false)
                                cell.imageViewPhoto.setImage(image)
                        }
                        
                        message.thumbnailPhoto = image
                    }
                    })
            
        
        } else {
            cell.imageViewPhoto.setMask(!message.sended)
            cell.imageViewPhoto.setImage(message.thumbnailPhoto!)
        }
        
        self.configCellLoadingView(indexPath, cell: cell, message: message)
        return cell
    }
    
    //判断indexPath是否超过表格内容可显示的区域
    func isOutOfTableViewVisibleContent(cell: UITableViewCell, indexPath: NSIndexPath) -> Bool {
        var flag = false
        let cellRect = self.tableView.rectForRowAtIndexPath(indexPath)
        let marginTop = self.tableView.contentOffset.y - cellRect.origin.y
        let marginBottom = cellRect.origin.y - self.tableView.contentOffset.y
        if (marginTop > cell.frame.size.height) || (marginBottom > self.tableView.frame.size.height) {
            flag = true
        }
        return flag
    }
}

// MARK: - 控制器公共方法
extension SwiftChatTableViewController {   
    
    /**
    增加聊天消息到表格
    
    - parameter chatMessages:     消息数组
    - parameter toPosition:            添加在哪个位置
    - parameter isScrollToBottom: 是否滚动到底部
    */
    func addChatMessage(
        chatMessages: [SCMessage],
        toPosition: String,
        isScrollToBottom: Bool,
        delayLoad: Double = 0) {
            if toPosition == "top" {
                self.messages = chatMessages + self.messages
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                    Int64(delayLoad * Double(NSEC_PER_SEC))),
                    dispatch_get_main_queue(), {
                        
                        self.tableView.reloadData()
                        self.setLoadingMore(false)
                })
                
            } else {
                self.messages = self.messages + chatMessages
                
                self.tableView.reloadData()
            }
            
            if isScrollToBottom {
                self.tableViewScrollToBottom(true)
            }
    }
    
    
    func tableViewScrollToBottom() {
        self.tableViewScrollToBottom(false)
    }
    
    /**
    把表格滚回到底部
    */
    func tableViewScrollToBottom(animated: Bool) {
        if !isTableScrollToBottom {
            if self.messages.count == 0 {
                return
            }
            
            let indexPath: NSIndexPath = NSIndexPath(
                forRow: self.messages.count-1,
                inSection: 0)
            
            self.tableView .scrollToRowAtIndexPath(
                indexPath,
                atScrollPosition: UITableViewScrollPosition.Bottom,
                animated: animated)
        }
    }
    
    /**
    完成发送消息
    */
    func finishSendMessage() {
        self.messageInputView.inputTextView.text = ""
        
        self.messageInputView.inputTextView.enablesReturnKeyAutomatically = false
        
        //把发送按钮变灰
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
            Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                self.messageInputView.inputTextView.enablesReturnKeyAutomatically = true
                self.messageInputView.inputTextView.reloadInputViews()
        }
        
    }
    
    /**
    打开系统相册
    
    - parameter minSelectCount: 至少选多少
    - parameter maxSelectCount: 最多选多少
    */
    func presentSystemAssetView(type: ALAssetsFilter,minSelectCount: Int, maxSelectCount:Int) {
        let picker = ZYQAssetPickerController()
        picker.maximumNumberOfSelection = maxSelectCount
        picker.minimumNumberOfSelection = minSelectCount
        picker.assetsFilter = type
        picker.showEmptyGroups = true
        picker.delegate = self
        self.presentViewController(picker, animated: true, completion: nil)
    }
    
    
    func setLoadingMore(flag: Bool) {
        if flag {
            self.progressViewLoadMore.hidden = false
            self.progressViewLoadMore.startAnimating()
        } else {
            self.progressViewLoadMore.stopAnimating()
            self.progressViewLoadMore.hidden = true
        }
        self.loadingMoreData = flag
    }
    
    //播放语音
    func playVoiceMessage(message: SCMessage, cell: SCMessageTableViewCell) {
        message.isRead = true
        
        cell.imageViewVoicePlayed.hidden = true
        self.currentSelecedCell?.imageViewAnimationVoice.stopAnimating()
        if self.currentSelecedCell === cell {
            self.currentSelecedCell?.imageViewAnimationVoice.stopAnimating()
            AudioPlayerUtils.sharedInstance.stopAudio()
            self.currentSelecedCell = nil
        } else {
            self.currentSelecedCell = cell
            cell.imageViewAnimationVoice.startAnimating()
            let file = SCConstants.voiceFileFolder.URLByAppendingPathComponent(message.voicePath)
            AudioPlayerUtils.sharedInstance.playAudioWithFile(file.path!) {
                self.currentSelecedCell?.imageViewAnimationVoice.stopAnimating()
                self.currentSelecedCell = nil
            }
        }
    }
}

// MARK: - UITextView代理方法
extension SwiftChatTableViewController: UITextViewDelegate {
    
    public func textViewDidEndEditing(textView: UITextView) {
        textView.resignFirstResponder()
    }
    
    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if (text == "\n" ) {
            if textView.text != "" {
                let timestamp = NSDate()
                self.delegate?.didSendText?(textView.text, fromSender: self.messageSender, onDate: timestamp)
                
                let message = SCMessage();
                message.senderId = self.messageSender
                message.sended = false;
                message.messageMediaType = SCMessageMediaType.Text;
                message.text = textView.text;
                message.messageSourceType = SCMessageSourceType.Send;
                message.timestamp = timestamp
                
                self.delegate?.didSendMessage?([message])
                
                //完成发送
                self.finishSendMessage()
                
                return false
            } else {
                return false
            }
            
        }
        return true
    }
}

// MARK: - 使用扩展方法为控制实现代理接口
extension SwiftChatTableViewController: UITableViewDataSource {
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messages.count;
    }
    
    
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.configCellAtIndexPath(indexPath)
        self.delegate?.configureCell?(cell, indexPath: indexPath)
        return cell
    }
    
    
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //            return 100.0
        var height: CGFloat = 0.0
        height = self.calculateCellHeight(indexPath)
        
        return height
    }
    
    
    func calculateCellHeight(indexPath: NSIndexPath) -> CGFloat {
        var height: CGFloat = 0.0
        let message = self.messages[indexPath.row]
        switch message.messageMediaType! {
        case SCMessageMediaType.Text:        //文本消息
            let textHeight = message.text.textSizeWithFont(UIFont.systemFontOfSize(14), constrainedToSize: CGSizeMake(200, 400)) //计算文本高度
            //            NSLog("textHeight = \(textHeight.height)")
            height = textHeight.height + 73         //文本高度一般16，补充73的差距
            break
        case SCMessageMediaType.Voice:       //语音消息
            height = 87.0           //语音内容的行高度固定87
            break
        case SCMessageMediaType.Photo:       //图片消息
            height = 182.0           //内容的行高度固定122
            break
        case SCMessageMediaType.Video:       //视频消息
            height = 152.0           //内容的行高度固定122
            break
        default:
            height = 100
        }
        let timestampHeight = self.calculateCellTimestampHeight(indexPath)
        height = height + timestampHeight
        //        NSLog("cell height = \(height) ** timestamp = \(timestampHeight)")
        return height
    }
    
    /**
    计算时间戳的高度
    
    - parameter indexPath:
    
    - returns:
    */
    func calculateCellTimestampHeight(indexPath: NSIndexPath) -> CGFloat {
        var displayTimestamp = true
        if (self.delegate != nil) {
            displayTimestamp = self.delegate!.shouldDisplayTimestampForRowAtIndexPath!(indexPath)
        }
        if displayTimestamp {
            return 18.0     //固定18
        } else {
            return 0
        }
    }
    
}

// MARK: - 表格代理方法
extension SwiftChatTableViewController: UITableViewDelegate {
    
    
}

// MARK: - 视图滚动代理方法
extension SwiftChatTableViewController: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        
        self.isDragging = true
    }
    
    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        if self.loadingMoreData {
            return
        }
        self.isDragging = true
        if self.isShareMenuViewShow {
            self.toggleMediaViewVisible(false)
        }
    }
    
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if self.loadingMoreData {
            return
        }
        
        if (self.delegate?.shouldLoadMoreMessagesScrollToTop?() ?? true) {
            if scrollView.contentOffset.y < 0  {
                if !loadingMoreData && self.canLoadmore && self.isDragging == true {
                    
                    self.delegate?.loadMoreMessagesScrollTotop?()
                }
            }
        }
        self.isDragging = false
        self.oldScrollViewContentSize = self.tableView.contentSize
    }
    
    
}

// MARK: - Key-value Observing
extension SwiftChatTableViewController {
    
    override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if (object === self.messageInputView.inputTextView)
            && (keyPath == "contentSize") { //观测到contentSize变化就调用调整textView高度
                self.layoutAndAnimateMessageInputTextView(object as! UITextView)
        }
    }
    
}

extension SwiftChatTableViewController: SCMessageInputViewDelegate {
    
    /**
    发送语音消息
    */
    func didFinishRecoingVoiceAction(voiceData: NSData, voicePath: String, voiceDuration: Float) {
        let timestamp = NSDate()
        self.delegate?.didSendVoice?(voiceData, voicePath: voicePath, voiceDuration: String(Int(voiceDuration)), fromSender: self.messageSender, onDate: timestamp)
        
        //把语音文件保存到自己定义的音频记录路径中
        let fileName = "\(timestamp.timeIntervalSince1970).caf"
        let path = SCConstants.voiceFileFolder.URLByAppendingPathComponent(fileName).path!
        voiceData.writeToFile(path, atomically: true)
        
        let message = SCMessage();
        message.senderId = self.messageSender
        message.sended = false;
        message.isRead = true
        message.messageMediaType = SCMessageMediaType.Voice;
        message.text = fileName;
        message.voicePath = fileName
        message.voiceDuration = String(Int(voiceDuration))
        message.messageSourceType = SCMessageSourceType.Send;
        message.timestamp = timestamp
        
        self.delegate?.didSendMessage?([message])
        
        //完成发送
        self.finishSendMessage()
    }
    
    /**
    点击多媒体按钮的回调代理
    
    - parameter inputView:
    */
    func didMediaButtonPress(inputView: SCMessageInputView) {
        self.toggleMediaViewVisible()
    }
    
}


// MARK: - 实现相册多选控制器的代理方法
extension SwiftChatTableViewController: ZYQAssetPickerControllerDelegate, UINavigationControllerDelegate {
    
    //处理发送相册
    func handleSendAssets(assets: [ALAsset]) {
        let timestamp = NSDate()
        self.delegate?.didSendAsset?(assets, fromSender: self.messageSender, onDate: timestamp)
        
        var newMessages = [SCMessage]()
        var i = 0
        for asset in assets {
            
            let representation = asset.defaultRepresentation()
            let image = UIImage(CGImage:representation.fullResolutionImage().takeUnretainedValue())
            //把图片文件保存到自己定义的音频记录路径中
            let fileName = "\(NSDate().timeIntervalSince1970).jpg"
            let path = SCConstants.photoFileFolder.URLByAppendingPathComponent(fileName).path!
            let data: NSData = UIImageJPEGRepresentation(image, 0.7)!
            data.writeToFile(path, atomically: true)
            
            let message = SCMessage();
            message.senderId = self.messageSender
            message.senderName = self.messageSender
            message.sended = false;
            message.messageMediaType = SCMessageMediaType.Photo;
            message.text = fileName
            message.photo = image
            message.thumbnailPhoto = UIImage(CGImage:asset.thumbnail().takeUnretainedValue())
            message.originPhotoPath = fileName
            message.messageSourceType = SCMessageSourceType.Send;
            message.timestamp = NSDate()
            newMessages.append(message)
        }
        
        //完成发送
        self.finishSendMessage()
        
        self.delegate?.didSendMessage?(newMessages)
    }
    
    //处理发送视频
    func handleSendVideo(asset: ALAsset) {
        let timestamp = NSDate()
        //把图片文件保存到自己定义的音频记录路径中
        let fileName = "\(timestamp.timeIntervalSince1970).mov"
        let path = SCConstants.videoFileFolder.URLByAppendingPathComponent(fileName)
        asset.exportDataToURL(path, error: nil)
        
        let message = SCMessage();
        message.senderId = self.messageSender
        message.senderName = self.messageSender
        message.sended = false;
        message.messageMediaType = SCMessageMediaType.Video;
        message.text = ""
        message.videoPath = fileName
        message.thumbnailPhoto = UIImage(CGImage:asset.thumbnail().takeUnretainedValue())
        message.messageSourceType = SCMessageSourceType.Send;
        message.timestamp = timestamp
        
        //完成发送
        self.finishSendMessage()
        
        self.delegate?.didSendMessage?([message])

    }
    
    public func assetPickerController(picker: ZYQAssetPickerController!, didFinishPickingAssets assets: [AnyObject]!) {
        let asset = assets[0] as! ALAsset
        let type =  asset.valueForProperty(ALAssetPropertyType) as! String
        if type == ALAssetTypePhoto {
            self.delegate?.didSendAsset?(assets as! [ALAsset], fromSender: self.messageSender, onDate: NSDate())
            self.handleSendAssets(assets as! [ALAsset])
            
        } else {
            self.delegate?.didSendAssetVideo?(assets[0] as! ALAsset, fromSender: self.messageSender, onDate: NSDate())
            
            self.handleSendVideo(assets[0] as! ALAsset)
        }
        
        self.toggleMediaViewVisible(false)
    }
    
    public func assetPickerControllerDidMaximum(picker: ZYQAssetPickerController!) {
        SVProgressHUD.showErrorWithStatus("最多选\(picker.maximumNumberOfSelection)个")
    }
    
}

// MARK: - 系统拍照控制器代理方法
extension SwiftChatTableViewController: UIImagePickerControllerDelegate {
    
    func takePhoto() {
        self.imagePicker =  UIImagePickerController()
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = .Camera
        self.imagePicker.cameraCaptureMode = .Photo
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func takeVideo() {
        self.imagePicker =  UIImagePickerController()
        self.imagePicker.delegate = self
        self.imagePicker.sourceType = .PhotoLibrary
        self.imagePicker.cameraCaptureMode = .Video
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.imagePicker.dismissViewControllerAnimated(true, completion: nil)
        var image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        let imageOrientation=image.imageOrientation;
        if imageOrientation != UIImageOrientation.Up {
            UIGraphicsBeginImageContext(image.size);
            image.drawInRect(CGRectMake(0, 0, image.size.width, image.size.height))
            image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext();
        }
        
        let timestamp = NSDate()
        self.delegate?.didSendPhoto?(image, fromSender: self.messageSender, onDate: timestamp)
        self.toggleMediaViewVisible(false)
        
        //把图片文件保存到自己定义的音频记录路径中
        let fileName = "\(timestamp.timeIntervalSince1970).jpg"
        let path = SCConstants.photoFileFolder.URLByAppendingPathComponent(fileName).path!
        let data: NSData = UIImageJPEGRepresentation(image, 0.7)!
        data.writeToFile(path, atomically: true)
        
        let message = SCMessage();
        message.senderId = self.messageSender
        message.senderName = self.messageSender
        message.sended = false;
        message.messageMediaType = SCMessageMediaType.Photo;
        message.text = fileName
        message.originPhotoPath = fileName
        message.photo = image
        message.thumbnailPhoto = image
        message.messageSourceType = SCMessageSourceType.Send;
        message.timestamp = timestamp
        
        self.delegate?.didSendMessage?([message])
        
        //完成发送
        self.finishSendMessage()
    }
}
