//
//  AppDelegate.swift
//  SwiftChatKit
//
//  Created by 麦志泉 on 09/01/2015.
//  Copyright (c) 2015 麦志泉. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var connectionState: EMConnectionState!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        //learnCloud相关设置
        AVOSCloud.setApplicationId("3FmPGWO0SlvN0DisqdmPi7P3", clientKey: "Nj2dE5IBh7r2VSEw4z5pwbmB")
        AVAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
        
        //环信相关配置
        self.easemobApplication(application, launchOptions: launchOptions)
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

extension AppDelegate: IChatManagerDelegate {
    
    func easemobApplication(application: UIApplication, launchOptions: [NSObject: AnyObject]?) {
        EaseMob.sharedInstance().registerSDKWithAppKey("zdt#swfitchatkit", apnsCertName: nil)
        
        connectionState = EMConnectionState.eEMConnectionConnected;
        
        // 注册环信监听
        self.registerEaseMobNotification()
        EaseMob.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
    }
    
    
    func registerEaseMobNotification() {
        self.unRegisterEaseMobNotification()
        // 将self 添加到SDK回调中，以便本类可以收到SDK回调
        EaseMob.sharedInstance().chatManager.addDelegate(self, delegateQueue: nil)
    }
    
    func unRegisterEaseMobNotification() {
        EaseMob.sharedInstance().chatManager.removeDelegate(self)
    }
}

