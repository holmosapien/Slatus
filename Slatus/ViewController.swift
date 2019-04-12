//
//  ViewController.swift
//  Slatus
//
//  Created by Dan Holm on 4/6/19.
//  Copyright © 2019 Holmosapien. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    let delegate = NSApp.delegate as? AppDelegate

    @IBOutlet weak var workspaceOutlineView: ConversationOutlineView!

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadConversations), name: Notification.Name("conversationListUpdate"), object: nil)

        //
        // Set ourselves up as the delegate and data source for the outline view in the UI.
        // The UI will then call the functions in the extensions below to get the data it
        // needs to display.
        //

        workspaceOutlineView.delegate = self
        workspaceOutlineView.dataSource = self
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

    @objc func reloadConversations() {
        workspaceOutlineView.reloadData()

        // Automatically expand all of the top-level items in the outline view.

        let count = workspaceOutlineView.numberOfRows

        for index in 0 ..< count {
            let item = workspaceOutlineView.item(atRow: index)

            if let item = item as? SlackWorkspace {
                workspaceOutlineView.expandItem(item)
            }
        }
    }
}

extension ViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {

        //
        // If we've been passed a workspace, return the number of unread conversations in the workspace.
        //

        if let workspace = item as? SlackWorkspace {
            return workspace.conversations.count
        }

        //
        // Otherwise return the number of workspaces.
        //

        if let delegate = self.delegate {
            return delegate.workspaces.count
        }

        return 0
    }

    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {

        //
        // If we've been passed a workspace, return the conversation at the specified index.
        //

        if let workspace = item as? SlackWorkspace {
            if let conversation = workspace.conversations[index] {
                return conversation
            }
        }

        //
        // Otherwise return the workspace at the requested index.
        //

        if let delegate = self.delegate {
            return delegate.workspaces[index]
        }

        //
        // What should we do when the caller asks for something out of bounds?
        // For now, return a blank conversation.
        //

        return SlackWorkspace()
    }

    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        if item is SlackWorkspace {
            return true
        }

        if item is Conversation {
            return false
        }

        return false
    }
}

extension ViewController: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        var view: NSTableCellView?
        var cell: NSUserInterfaceItemIdentifier?
        var text: String?

        var color = NSColor.controlTextColor

        if let workspace = item as? SlackWorkspace {
            if tableColumn?.identifier == NSUserInterfaceItemIdentifier("ConversationColumn") {
                cell  = NSUserInterfaceItemIdentifier("ConversationCell")
                text  = workspace.name.uppercased()
                color = NSColor.tertiaryLabelColor
            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier("MessagesColumn") {
                cell = NSUserInterfaceItemIdentifier("MessagesCell")
                text = ""
            }
        } else if let conversation = item as? Conversation {
            if tableColumn?.identifier == NSUserInterfaceItemIdentifier("ConversationColumn") {
                cell = NSUserInterfaceItemIdentifier("ConversationCell")

                if conversation.type == GroupType.channel || conversation.type == GroupType.group {
                    text = "  #\(conversation.name)"
                } else if conversation.type == GroupType.im {
                    text = "  @\(conversation.name)"
                } else {
                    text = "  \(conversation.name)"
                }
            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier("MessagesColumn") {
                cell  = NSUserInterfaceItemIdentifier("MessagesCell")

                if conversation.unread > 0 {
                    text  = "\(conversation.unread)"
                    color = NSColor.systemRed
                } else {
                    text = ""
                }
            }
        }

        guard
            let viewCell = cell,
            let viewText = text
        else {
            return view
        }

        view = workspaceOutlineView.makeView(withIdentifier: viewCell, owner: nil) as? NSTableCellView

        if let textField = view?.textField {
            textField.stringValue = viewText
            textField.textColor = color
        }

        return view
    }

    // Don't show the triangle that expands/collapses the row.

    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        return false
    }
}
