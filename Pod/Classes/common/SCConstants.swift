//
//  Constants.swift
//  SwiftChatKit
//
//  Created by 麦志泉 on 15/10/21.
//  Copyright © 2015年 CocoaPods. All rights reserved.
//

import UIKit

class SCConstants: NSObject {
    
    static var cacheFileFolder: NSURL {
        
        let fileManager = NSFileManager.defaultManager()
        var directoryURL = fileManager.URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)[0]
        directoryURL = directoryURL.URLByAppendingPathComponent("swiftchatCache")
        if !fileManager.fileExistsAtPath(directoryURL.path!) {
            try! NSFileManager.defaultManager().createDirectoryAtURL(directoryURL, withIntermediateDirectories: true, attributes: nil)
        }
        return directoryURL
    }

    
    static var voiceFileFolder: NSURL {
        
        let fileManager = NSFileManager.defaultManager()
        let directoryURL = SCConstants.cacheFileFolder.URLByAppendingPathComponent("voice")
        
        if !fileManager.fileExistsAtPath(directoryURL.path!) {
            try! NSFileManager.defaultManager().createDirectoryAtURL(directoryURL, withIntermediateDirectories: true, attributes: nil)
        }
        
        return directoryURL
    }
    
    static var photoFileFolder: NSURL {
        
        let fileManager = NSFileManager.defaultManager()
        let directoryURL = SCConstants.cacheFileFolder.URLByAppendingPathComponent("photo")
        
        if !fileManager.fileExistsAtPath(directoryURL.path!) {
            try! NSFileManager.defaultManager().createDirectoryAtURL(directoryURL, withIntermediateDirectories: true, attributes: nil)
        }
        
        return directoryURL
    }
    
    static var videoFileFolder: NSURL {
        
        let fileManager = NSFileManager.defaultManager()
        let directoryURL = SCConstants.cacheFileFolder.URLByAppendingPathComponent("video")
        
        if !fileManager.fileExistsAtPath(directoryURL.path!) {
            try! NSFileManager.defaultManager().createDirectoryAtURL(directoryURL, withIntermediateDirectories: true, attributes: nil)
        }
        
        return directoryURL
    }
    
}
