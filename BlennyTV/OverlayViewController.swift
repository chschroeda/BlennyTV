//
//  OverlayViewController.swift
//  BlennyTV
//
//  Created by Christian Schroeder on 21.06.17.
//  Copyright © 2017 Christian Schroeder. All rights reserved.
//

import Cocoa
import Foundation

class OverlayViewController: NSViewController {
    
    @IBOutlet weak var channelLabel: NSTextField!
    var channelLabelText: NSMutableAttributedString? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        channelLabel.alphaValue = 0
        NSAnimationContext.current().duration = 0
        
        if let cltext = channelLabelText {
            channelLabel.attributedStringValue = cltext
        } else {
            channelLabel.attributedStringValue = NSMutableAttributedString(string: "", attributes: [NSFontAttributeName:NSFont(name: "Helvetica-Bold",size: 64)!])
        }
        
        channelLabel.sizeToFit()
        channelLabel.alphaValue = 0.8
        NSAnimationContext.current().duration = 0
        NSAnimationContext.runAnimationGroup({ (context) -> Void in
            context.duration = 4.0
            channelLabel.animator().alphaValue = 0
        }, completionHandler: {
            
        })
    }
    
}

