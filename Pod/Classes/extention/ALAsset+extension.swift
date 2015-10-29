//
//  ALAsset+extension.swift
//  SwiftChatKit
//
//  Created by 麦志泉 on 15/10/12.
//  Copyright © 2015年 CocoaPods. All rights reserved.
//

import Foundation

let BufferSize: Int = 1024 * 1024

extension ALAsset {
    
    func exportDataToURL(fileURL: NSURL, error: NSErrorPointer) -> Bool {
        NSFileManager.defaultManager().createFileAtPath(fileURL.path!, contents: nil, attributes: nil)
        let rep = self.defaultRepresentation()
        
        let sizeOfRawDataInBytes: Int = Int(rep.size())
        let rawData: NSMutableData = NSMutableData(length: sizeOfRawDataInBytes)!
        let bufferPtr: UnsafeMutablePointer<Void> = rawData.mutableBytes
        let bufferPtr8: UnsafeMutablePointer<UInt8> = UnsafeMutablePointer<UInt8>(bufferPtr)
        
        rep.getBytes(bufferPtr8, fromOffset: 0, length: sizeOfRawDataInBytes, error: error)
        
        if error == nil {
            rawData.writeToFile(fileURL.path!, atomically: true)
        } else {
            return false
        }
        
        return true
    }
}