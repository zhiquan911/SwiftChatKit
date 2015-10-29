//
//  AudioPlayerUtils.swift
//  SwiftChatKit
//
//  Created by 麦志泉 on 15/9/28.
//  Copyright © 2015年 CocoaPods. All rights reserved.
//

import UIKit
import AVFoundation

@objc protocol AudioPlayerUtilsDelegate {
    
    optional func didAudioPlayerBeginPlay(audioPlayer: AVAudioPlayer)
    optional func didAudioPlayerStopPlay(audioPlayer: AVAudioPlayer)
    optional func didAudioPlayerPausePlay(audioPlayer: AVAudioPlayer)
}

class AudioPlayerUtils: NSObject {
    
    var player: AVAudioPlayer?
    var playingFilePath: String?
    weak var delegate: AudioPlayerUtilsDelegate?
    typealias AudioPlayCompletion = () -> Void
    var completion: AudioPlayCompletion?
    
    convenience init(delegate: AudioPlayerUtilsDelegate) {
        self.init()
        self.delegate = delegate
    }
    
    override init() {
        super.init()
        self.changeProximityMonitorEnableState(true)
        UIDevice.currentDevice().proximityMonitoringEnabled = false
    }
    
    /// 全局唯一实例
    class var sharedInstance: AudioPlayerUtils {
        struct Singleton{
            static var predicate:dispatch_once_t = 0
            static var instance:AudioPlayerUtils? = nil
        }
        dispatch_once(&Singleton.predicate,{
            Singleton.instance = AudioPlayerUtils()
            }
        )
        return Singleton.instance!
    }
    
    /**
    根据文件路径播放语音
    
    - parameter filePath: 文件路径
    */
    func playAudioWithFile(filePath: String, completion:AudioPlayCompletion? = nil) {
        
        if filePath != "" {
            do {
                //不随着静音键和屏幕关闭而静音。
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                //上次播放的录音
                if self.playingFilePath != nil && filePath == self.playingFilePath! {
                    self.player?.play()
                    UIDevice.currentDevice().proximityMonitoringEnabled = true
                } else {
                    //不是上次播放的录音
                    self.player?.stop()
                    self.player = nil
                    
                    let pl: AVAudioPlayer = try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: filePath))
                    pl.delegate = self
                    pl.play()
                    self.player = pl
                    UIDevice.currentDevice().proximityMonitoringEnabled = true
                    self.completion = completion
                }
                self.playingFilePath = filePath
            } catch let error as NSError {
                NSLog("AudioPlayerUtils error:\(error.description)")
            }
            
        }
    }
    
    /**
    暂停
    */
    func pausePlayingAudio() {
        self.player?.pause()
    }
    
    /**
    停止播放
    */
    func stopAudio() {
        self.playingFilePath = ""
        self.player?.stop()
        UIDevice.currentDevice().proximityMonitoringEnabled = false
    }
    
    /**
    播放状态
    
    - returns:
    */
    func isPlaying() -> Bool {
        return self.player?.playing ?? false
    }
    
    
    /**
    近距离传感器
    
    - parameter enable:
    */
    func changeProximityMonitorEnableState(enable: Bool) {
        UIDevice.currentDevice().proximityMonitoringEnabled = true
        
        if UIDevice.currentDevice().proximityMonitoringEnabled {
            if enable {
                //添加近距离事件监听，添加前先设置为YES，如果设置完后还是NO的读话，说明当前设备没有近距离传感器
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "sensorStateChange:", name: UIDeviceProximityStateDidChangeNotification, object: nil)
            } else {
                //删除近距离事件监听
                NSNotificationCenter.defaultCenter().removeObserver(self, name: UIDeviceProximityStateDidChangeNotification, object: nil)
                UIDevice.currentDevice().proximityMonitoringEnabled = false
            }
        }
    }
    
    func sensorStateChange(notification: NSNotificationCenter) {
        do {
            //如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗
            if UIDevice.currentDevice().proximityState {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
            } else {
                try AVAudioSession.sharedInstance().setCategory(
                    AVAudioSessionCategoryPlayback)
                if self.player != nil || !self.player!.playing {
                    UIDevice.currentDevice().proximityMonitoringEnabled = false
                }
                //没有播放了，也没有在黑屏状态下，就可以把距离传感器关了
                //        [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
            }
            
        } catch let error as NSError {
            NSLog("AudioPlayerUtils error:\(error.description)")
        }
        
    }
}

extension AudioPlayerUtils: AVAudioPlayerDelegate {
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        self.stopAudio()
        self.completion?()
    }
    
}
