//
//  PreferencesViewController.swift
//  BlennyTV
//
//  Created by Christian Schroeder on 21.06.17.
//  Copyright © 2017 Christian Schroeder. All rights reserved.
//

import Cocoa
import Foundation

class PreferencesViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var nameTextField: NSTextField!
    @IBOutlet weak var urlLabel: NSTextField!
    @IBOutlet weak var urlTextField: NSTextField!
    @IBOutlet weak var saveButton: NSButton!
    @IBOutlet weak var cancelButton: NSButton!
    @IBOutlet weak var orderTextField: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var deleteButton: NSButton!
    @IBOutlet weak var helpLabel: NSTextField!
    
    @IBOutlet weak var streamForm: NSTextField!
    
    var channels: [Channel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        deleteButton.isEnabled = false
        hideForm()
        tableView.headerView = nil
        tableView.register(forDraggedTypes: ["public.data"])
        getchannels()
    }
    
    func hideForm() {
        nameLabel.isHidden = true
        nameTextField.isHidden = true
        urlLabel.isHidden = true
        urlTextField.isHidden = true
        saveButton.isHidden = true
        cancelButton.isHidden = true
        helpLabel.isHidden = true
        // orderTextField.isHidden = true   // debug
    }
    
    func showForm() {
        nameLabel.isHidden = false
        nameTextField.isHidden = false
        urlLabel.isHidden = false
        urlTextField.isHidden = false
        saveButton.isHidden = false
        cancelButton.isHidden = false
//         orderTextField.isHidden = false  // debug
    }
    
    func getchannels() {
        channels = ChannelManager.getChannels()
        tableView.reloadData()
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return channels.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.make(withIdentifier: "nameCell", owner: self) as? NSTableCellView {
            let channel = channels[row]
            cell.textField?.stringValue = channel.name!
            return cell
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if tableView.selectedRow >= 0 {
            deleteButton.isEnabled = true
            saveButton.title = "Save"
            helpLabel.stringValue = "Drag & drop to sort Channels"
            helpLabel.isHidden = false
            showForm()
            
            let channel = channels[tableView.selectedRow]
            nameTextField.stringValue = channel.name!
            urlTextField.stringValue = channel.url!
            orderTextField.stringValue = String(channel.order)
        }
    }
    
    
    // MARK - Drag 'n Drop
    
    let dragDropTypeId = "public.data" // or any other UTI you want/need
    
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        let item = NSPasteboardItem()
        item.setString(String(row), forType: dragDropTypeId)
        return item
    }
    
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableViewDropOperation) -> NSDragOperation {
        if dropOperation == .above {
            return .move
        }
        return []
    }
    
    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        var oldIndexes = [Int]()
        info.enumerateDraggingItems(options: [], for: tableView, classes: [NSPasteboardItem.self], searchOptions: [:]) {
            if let str = ($0.0.item as! NSPasteboardItem).string(forType: self.dragDropTypeId), let index = Int(str) {
                oldIndexes.append(index)
            }
        }
        
        for oldIndex in oldIndexes {
            for i in row ..< channels.count  {
                ChannelManager.updateChannel(index: i, name: nil, url: nil, order: Int16(i+1))
            }
            ChannelManager.updateChannel(index: oldIndex, name: nil, url: nil, order: Int16(row))
        }
        ChannelManager.cleanOrder()
        getchannels()
        return true
    }
    
    func importJson(filePath: String) {
        let jsonData = FileManager.default.contents(atPath: filePath)
        
        do {
            let jsonResult: NSArray = try JSONSerialization.jsonObject(with: jsonData!, options: JSONSerialization.ReadingOptions.mutableContainers) as! NSArray
            
            for channel in jsonResult as Array<AnyObject> {
                let channelName: String = channel["channel"] as! String
                let channelUrl: String = channel["url"] as! String
                ChannelManager.addChannel(name: channelName, url: channelUrl)
            }
            ChannelManager.cleanOrder()
            getchannels()
        } catch {}
    }
    
    
    // MARK - action handler
    
    @IBAction func saveClicked(_ sender: Any) {
        if nameTextField.stringValue != "" && urlTextField.stringValue != "" {
            
            if tableView.selectedRow >= 0 {
                ChannelManager.updateChannel(index: tableView.selectedRow,  name: nameTextField.stringValue, url: urlTextField.stringValue, order: nil)
            } else {
                ChannelManager.addChannel(name: nameTextField.stringValue, url: urlTextField.stringValue)
            }
                
            nameTextField.stringValue = ""
            urlTextField.stringValue = ""
                
            hideForm()
            getchannels()
        }
    }
    
    @IBAction func deleteChannelClicked(_ sender: Any) {
        let alertDialog = NSAlert()
        alertDialog.messageText = "Are you sure you want to delete the channel?"
        alertDialog.informativeText = ""
        alertDialog.addButton(withTitle: "Delete")
        alertDialog.addButton(withTitle: "Cancel")
        alertDialog.alertStyle = NSAlertStyle.warning
        alertDialog.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) -> Void in
            if modalResponse == NSAlertFirstButtonReturn {
                ChannelManager.deleteChannel(index: self.tableView.selectedRow)
                self.getchannels()
                self.deleteButton.isEnabled = false
            }
            self.tableView.deselectRow(self.tableView.selectedRow)
            self.nameTextField.stringValue = ""
            self.urlTextField.stringValue = ""
            self.orderTextField.stringValue = ""
            self.hideForm()
        })
    }
    
    @IBAction func addChannelClicked(_ sender: Any) {
        tableView.deselectRow(tableView.selectedRow)
        saveButton.title = "Add"
        nameTextField.stringValue = ""
        urlTextField.stringValue = ""
        orderTextField.stringValue = ""
        helpLabel.stringValue = ""
        helpLabel.isHidden = false
        showForm()
    }
    
    @IBAction func cancelButtonClicked(_ sender: Any) {
        self.tableView.deselectRow(self.tableView.selectedRow)
        self.hideForm()
    }
    
    @IBAction func importJsonListClicked(_ sender: Any) {
        let dialog = NSOpenPanel();
        
        dialog.title                   = "Choose a .json file";
        dialog.showsResizeIndicator    = true;
        dialog.showsHiddenFiles        = false;
        dialog.canChooseDirectories    = true;
        dialog.canCreateDirectories    = false;
        dialog.allowsMultipleSelection = false;
        dialog.allowedFileTypes        = ["json"];
        
        if (dialog.runModal() == NSModalResponseOK) {
            let result = dialog.url
            
            if (result != nil) {
                let path = result!.path
                self.importJson(filePath: path)
            }
        } else {
            return
        }
    }
    
}
