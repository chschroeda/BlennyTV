//
//  VideoPlayer.swift
//  BlennyTV
//
//  Created by Christian Schroeder on 27.06.17.
//  Copyright © 2017 Christian Schroeder. All rights reserved.
//

import Cocoa
import AVKit
import Foundation
import AVFoundation

class VideoPlayer {
    static let shared = VideoPlayer()
    
    var videoPlayer: AVPlayer?
    var channels: [Channel] = []
    var streamingChannel = 0

    func initPlayer() {
        getChannels()
        if (channels.count > 0) {
            streamingChannel = 0
            guard let url = URL(string: channels[streamingChannel].url!)
                else { return }
            
            let player = AVPlayer(url: url)
            videoPlayer = player
        }
    }
    
    func getChannels() {
        channels = ChannelManager.getChannels() 
        
    }
    
    func playStreamUrl(streamUrl: String) -> Void {
        guard let url = URL(string: (streamUrl))
            else { return }
        
        let playerItem = AVPlayerItem(url: url)
        videoPlayer?.replaceCurrentItem(with: playerItem)
        videoPlayer?.play()
    }
    
}
