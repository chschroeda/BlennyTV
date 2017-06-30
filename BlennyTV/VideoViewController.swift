//
//  VideoViewController.swift
//  BlennyTV
//
//  Created by Christian Schroeder on 21.06.17.
//  Copyright © 2017 Christian Schroeder. All rights reserved.
//

import Cocoa
import AVKit
import Foundation
import AVFoundation

class VideoViewController: NSViewController {
    
    static let shared = VideoViewController()
    
    @IBOutlet weak var playerView: AVPlayerView!
    @IBOutlet weak var containerView: NSView!
    
    var storyBoard: NSStoryboard?
    var overlayViewController: OverlayViewController? = nil
    var channels: [Channel] = []
    var streamingChannel = 0
    
    let videoPlayer = (NSApplication.shared().delegate as? AppDelegate)?.videoPlayer
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            self.keyDown(with: $0)
            return $0
        }
        
        storyBoard = NSStoryboard(name: "Main", bundle: nil)
        overlayViewController = storyBoard?.instantiateController(withIdentifier: "OverlayViewController") as? OverlayViewController

        videoPlayer?.initPlayer()
        playerView.player = videoPlayer?.videoPlayer
    }
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }
    
    func getStreamItems() {
        channels = ChannelManager.getChannels() 
    }
    
    func playChannel() {
        let streamUrl = videoPlayer?.channels[(videoPlayer?.streamingChannel)!].url
        let streamName = videoPlayer?.channels[(videoPlayer?.streamingChannel)!].name
        videoPlayer?.playStreamUrl(streamUrl: streamUrl!)
        setOverlay(overlayText: streamName!)
    }
    
    func setChannelByMenu(item2: NSMenuItem) -> Void {
        let item = NSApplication.shared()
        videoPlayer?.streamingChannel = (item.mainMenu!.items.filter(){ $0.submenu!.title == "Channel" }[0].submenu?.index(of: item2))!-3
        playChannel()
    }
    
    func setMute() {
        let player = playerView.player
        player?.isMuted = true
        setOverlay(overlayText: "🔇")
    }
    
    func unsetMute() {
        let player = playerView.player
        player?.isMuted = false
        setOverlay(overlayText: "🔈")
    }
    
    func setOverlay(overlayText: String) {
        overlayViewController?.view.removeFromSuperview()
        overlayViewController = storyBoard?.instantiateController(withIdentifier: "OverlayViewController") as? OverlayViewController
        
        let size = NSMakeSize(playerView.frame.width, playerView.frame.height)
        let labelText = NSMutableAttributedString(string: overlayText, attributes: [NSFontAttributeName:NSFont(name: "Helvetica-Bold",size: 64)!])
        labelText.setAlignment(NSTextAlignment.right, range: NSMakeRange(0, labelText.length))
        
        overlayViewController?.channelLabelText = labelText
        overlayViewController?.view.setFrameSize(size)
        
        playerView.contentOverlayView?.addSubview((overlayViewController?.view)!)
        containerView?.layer?.zPosition = 1
    }
    
    override func keyDown(with event: NSEvent) {
        
    }
    
    @IBAction func actionChannelUp(_ sender: NSMenuItem) {
        videoPlayer?.streamingChannel = ((videoPlayer?.streamingChannel)! == (videoPlayer?.channels.count)! - 1  ? 0 : (videoPlayer?.streamingChannel)! + 1)
        playChannel()
    }
    
    @IBAction func actionChannelDown(_ sender: NSMenuItem) {
        videoPlayer?.streamingChannel = ((videoPlayer?.streamingChannel)! == 0 ? (videoPlayer?.channels.count)! - 1 : (videoPlayer?.streamingChannel)! - 1)
        playChannel()
    }
    
    @IBAction func actionVolumeDecrease(_ sender: NSMenuItem) {
        let player = playerView.player
        player?.volume = ((player?.volume)! >= 0.01 ? (player?.volume)! - 0.01 : 0)
        let volume = String(Int((player?.volume)! * 100))
        setOverlay(overlayText: "\(volume)%")
    }
    
    @IBAction func actionVolumeIncrease(_ sender: NSMenuItem) {
        let player = playerView.player
        player?.volume = ((player?.volume)! <= 0.99 ? (player?.volume)! + 0.01 : 1.0)
        let volume = String(Int((player?.volume)! * 100))
        setOverlay(overlayText: "\(volume)%")
    }
    
    @IBAction func actionToggleMute(_ sender: NSMenuItem) {
        if (sender.state == NSOffState) {
            self.setMute()
            sender.state = NSOnState
        } else {
            self.unsetMute()
            sender.state = NSOffState
        }
    }
    
}
