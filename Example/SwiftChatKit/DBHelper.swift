//
//  DBHelper.swift
//  SwiftChatKit
//
//  Created by 麦志泉 on 15/10/17.
//  Copyright © 2015年 CocoaPods. All rights reserved.
//

import UIKit
import RealmSwift

class DBHelper: NSObject {
    
    static let kDBVersion: UInt64 = 1
    
    //数据库路径
    static var databaseFilePath: NSURL {
        let fileManager = NSFileManager.defaultManager()
        var directoryURL = fileManager.URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)[0]
        directoryURL = directoryURL.URLByAppendingPathComponent("swiftChatKitDB")
        
        if !fileManager.fileExistsAtPath(directoryURL.path!) {
            try! fileManager.createDirectoryAtPath(directoryURL.path!, withIntermediateDirectories: true, attributes: nil)
        }
        return directoryURL
    }
    
    /// 全局唯一实例
//    class var sharedInstance: Realm {
//        struct Singleton{
//            static var predicate:dispatch_once_t = 0
//            static var instance:Realm? = nil
//        }
//        dispatch_once(&Singleton.predicate,{
//            
//            // 通过配置打开 Realm 数据库
//            var path = self.databaseFilePath.URLByAppendingPathExtension("database")
//            path = path.URLByAppendingPathExtension("realm")
//            let config = Realm.Configuration(path: path.path!)
//            let realm = try! Realm(configuration: config)
//            Singleton.instance = realm
//            }
//        )
//        return Singleton.instance!
//    }
    
    //获取某个用户独立的数据库
    class func getUserDB(userId: String) -> Realm {
        // 通过配置打开 Realm 数据库
        var path = self.databaseFilePath.URLByAppendingPathComponent("database_\(userId)")
        path = path.URLByAppendingPathExtension("realm")
        let config = Realm.Configuration(
            path: path.path!,
            schemaVersion: DBHelper.kDBVersion,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 1) {
                    }
                })
        let realm = try! Realm(configuration: config)
        return realm
    }
    
    
}
