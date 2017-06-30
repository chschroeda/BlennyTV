//
//  ChannelManager.swift
//  BlennyTV
//
//  Created by Christian Schroeder on 27.06.17.
//  Copyright © 2017 Christian Schroeder. All rights reserved.
//

import Cocoa
import Foundation

class ChannelManager: NSObject {
    
    static func refreshPlayer() {
        self.buildChannelMenu()
        if let videoPlayer = (NSApplication.shared().delegate as? AppDelegate)?.videoPlayer {
            videoPlayer.getChannels()
            if videoPlayer.channels.count <= videoPlayer.streamingChannel {
                videoPlayer.streamingChannel = 0
            }
        }
    }
    
    static func getChannels() -> Array<Channel> {
        if let context = (NSApplication.shared().delegate as? AppDelegate)?.persistentContainer.viewContext {
            do {
                let fec:NSFetchRequest = Channel.fetchRequest()
                let sortDescriptor = NSSortDescriptor(key: "order", ascending: true)
                fec.sortDescriptors = [sortDescriptor]
                return try context.fetch(fec)
            } catch {
                
            }
        }
        return Array()
    }
    
    static func cleanOrder() {
        let channels = self.getChannels()
            
        for i in 0 ..< channels.count  {
            if let context = (NSApplication.shared().delegate as? AppDelegate)?.persistentContainer.viewContext {
            
                channels[i].order = Int16(i)
            
                do {
                    try context.save()
                } catch let error as NSError{
                    print(error)
                }
            }
        }
    }
    
    static func addChannel(name: String, url: String) {
        if name != "" && url != "" {
            if let context = (NSApplication.shared().delegate as? AppDelegate)?.persistentContainer.viewContext {
                let channels = self.getChannels()
                
                let channel = Channel(context: context)
                channel.name = name
                channel.url = url
                channel.order = Int16(channels.count)
                
                (NSApplication.shared().delegate as? AppDelegate)?.saveAction(nil)
                self.refreshPlayer()
            }
        }
    }
    
    static func updateChannel(index: Int, name: String?, url: String?, order: Int16?) {
        if let context = (NSApplication.shared().delegate as? AppDelegate)?.persistentContainer.viewContext {
            let channels = self.getChannels()
            let channel = channels[index]
            
            if name != nil {
                channel.name = name
            }
            if url != nil {
                channel.url = url
            }
            
            if order != nil {
                channel.order = order!
            } else {
                 channel.order = Int16(index)
            }
            
            do {
                try context.save()
            } catch let error as NSError{
                print(error)
            }
            self.refreshPlayer()
        }
    }
    
    static func deleteChannel(index: Int) {
        let channels = self.getChannels()
        let channel = channels[index]
        if let context = (NSApplication.shared().delegate as? AppDelegate)?.persistentContainer.viewContext {
            context.delete(channel as NSManagedObject)
            
            (NSApplication.shared().delegate as? AppDelegate)?.saveAction(nil)
            self.refreshPlayer()
        }
    }
    
    static func buildChannelMenu() -> Void {
        let item = NSApplication.shared()
        let menuItemsCount = item.mainMenu!.items.filter(){ $0.submenu!.title == "Channel" }[0].submenu?.items.count
        if menuItemsCount! > 3 {
            for i in (3...(Int(menuItemsCount!)-1)).reversed() {
                item.mainMenu!.items.filter(){ $0.submenu!.title == "Channel" }[0].submenu?.removeItem(at: i)
            }
        }
        
        let streamItems = self.getChannels()
        for channel in streamItems {
            if let videoVC = (NSApplication.shared().delegate as? AppDelegate)?.videoVC {
                item.mainMenu!.items.filter(){ $0.submenu!.title == "Channel" }[0].submenu?.addItem(withTitle: (channel as AnyObject).name!!, action: #selector(videoVC.setChannelByMenu), keyEquivalent: "n")
            }
        }
    }
    
}
