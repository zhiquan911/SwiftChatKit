//
//  Array+extension.swift
//  light_guide
//
//  Created by 麦志泉 on 15/10/8.
//  Copyright © 2015年 wetasty. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    mutating func removeObject(object: Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
    
    mutating func removeObjectsInArray(array: [Element]) {
        for object in array {
            self.removeObject(object)
        }
    }
}