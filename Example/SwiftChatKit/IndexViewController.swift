//
//  IndexViewController.swift
//  SwiftChatKit
//
//  Created by 麦志泉 on 15/9/12.
//  Copyright (c) 2015年 CocoaPods. All rights reserved.
//

import UIKit
import AVOSCloudIM
import SVProgressHUD

class IndexViewController: UIViewController {
    
    var enableDBCache = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

// MARK: - 按钮方法
extension IndexViewController: AVIMClientDelegate {
    
    func loginHuanxin() {
        SVProgressHUD.show()
        
        let enterBlock =  {
            () -> Void in
            NSLog("登录环信成功")
            
            let vc = self.storyboard!.instantiateViewControllerWithIdentifier(
                "ChatForHuanxinViewController") as! ChatForHuanxinViewController
            vc.userId = "client"
            vc.userName = "麦志泉"
            vc.chatToId = "zhiquan911"
            vc.chatToName = "客服"
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        //同时登录环信
        if EaseMob.sharedInstance().chatManager.isLoggedIn {
            enterBlock()
        }
        
        EaseMob.sharedInstance().chatManager.asyncLoginWithUsername(
            "client",
            password: "123456",
            completion: {
                (loginInfo, error) -> Void in
                SVProgressHUD.dismiss()
                if loginInfo != nil {
                    enterBlock()
                } else {
                    NSLog("error = \(error.description)")
                }
            },
            onQueue: nil)
    }
    
    @IBAction func handleChatButtonPress(sender: AnyObject?) {
        let button = sender as? UIButton
        let vc = self.storyboard!.instantiateViewControllerWithIdentifier(
            "ChatViewController") as! ChatViewController
        vc.enableDBCache = self.enableDBCache
        if button?.tag == 1 {
            //我是李雷
            vc.userId = "1"
            vc.userName = "李雷"
            vc.chatToId = "2"
            vc.chatToName = "韩梅梅"
        } else {
            //我是韩梅梅
            vc.userId = "2"
            vc.userName = "韩梅梅"
            vc.chatToId = "1"
            vc.chatToName = "李雷"
        }
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @IBAction func handleEnterHuanxin(sender: AnyObject?) {
        self.loginHuanxin()
    }
    
    @IBAction func handleSwitchChange(switchDB: UISwitch) {
        self.enableDBCache = switchDB.on
    }
}
