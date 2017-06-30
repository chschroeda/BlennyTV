//
//  WindowController.swift
//  BlennyTV
//
//  Created by Christian Schroeder on 21.06.17.
//  Copyright © 2017 Christian Schroeder. All rights reserved.
//

import Foundation
import Cocoa
import AppKit

class WindowController: NSWindowController {
    
    let menuItemAlwaysOnTop = NSApplication.shared().mainMenu!.item(withTitle: "View")?.submenu?.item(withTitle: "Always on Top")
    let menuItemEnterFullScreen = NSApplication.shared().mainMenu!.item(withTitle: "View")?.submenu?.item(withTitle: "Enter Full Screen")
    var userSetWindowOnTop: Bool = false
    
    @IBAction func actionAlwaysOnTop(_ sender: NSMenuItem) {
        if (sender.state == NSOffState) {
            self.setWindowOnTop()
            userSetWindowOnTop = true
        } else {
            self.unsetWindowOnTop()
            userSetWindowOnTop = false
        }
    }
    
    @IBAction func actionEnterFullScreen(_ sender: NSMenuItem) {
        self.toggleFullScreen()
    }
    
    override func windowDidLoad() {
        
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            self.keyDown(with: $0)
            return $0
        }
        
        NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) {
            self.flagsChanged(with: $0)
            return $0
        }
        
        ChannelManager.buildChannelMenu()
        
        self.window?.isMovableByWindowBackground = true
        self.window?.styleMask.insert(.docModalWindow)
        self.setWindowOnTop()
        userSetWindowOnTop = true
    }
    
    fileprivate func setWindowOnTop() {
        self.window?.level = Int(CGWindowLevelForKey(.maximumWindow))
        menuItemAlwaysOnTop?.state = NSOnState
    }
    
    fileprivate func unsetWindowOnTop() {
        self.window?.level = Int(CGWindowLevelForKey(.normalWindow))
        menuItemAlwaysOnTop?.state = NSOffState
    }
    
    fileprivate func toggleFullScreen() {
        if let window = NSApp.mainWindow {
            
            if !window.styleMask.contains(NSWindowStyleMask.fullScreen) {
                if menuItemAlwaysOnTop?.state == NSOnState {
                    self.unsetWindowOnTop()
                }
            }
            
            window.collectionBehavior = NSWindowCollectionBehavior.fullScreenPrimary
            window.toggleFullScreen(nil)
            
            if !window.styleMask.contains(NSWindowStyleMask.fullScreen) {
                if userSetWindowOnTop {
                    self.setWindowOnTop()
                }
                NSCursor.setHiddenUntilMouseMoves(false)
                menuItemEnterFullScreen?.state = NSOffState
            } else {
                NSCursor.setHiddenUntilMouseMoves(true)
                menuItemEnterFullScreen?.state = NSOnState
            }
        }
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 53: // esc
            // leave fullscreen
            if let window = NSApp.mainWindow {
                let isWindowFullscreen = window.styleMask.contains(NSWindowStyleMask.fullScreen)
                if isWindowFullscreen {
                    toggleFullScreen()
                }
            }
            break
        default: break
        }
    }
    
}
