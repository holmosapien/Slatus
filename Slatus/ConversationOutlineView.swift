//
//  ConversationOutlineView.swift
//  Slatus
//
//  Created by Dan Holm on 4/11/19.
//  Copyright © 2019 Holmosapien. All rights reserved.
//

import Cocoa

class ConversationOutlineView: NSOutlineView {
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }

    override func frameOfOutlineCell(atRow row: Int) -> NSRect {
        // Don't allocate space for the triangle that expands/collapses the row.

        return NSZeroRect
    }

    func makeWorkspaceHeader(_ workspace: SlackWorkspace) -> NSTableCellView? {
        let cell  = NSUserInterfaceItemIdentifier("ConversationCell")
        let text  = NSMutableAttributedString(string: workspace.name.uppercased())
        let color = NSColor.tertiaryLabelColor

        let view = self.makeView(withIdentifier: cell, owner: nil) as? NSTableCellView

        if let view = view {
            if let textField = view.textField {
                textField.attributedStringValue = text
                textField.textColor = color
            }
        }

        return view
    }

    func makeConversationRow(_ conversation: Conversation) -> NSTableCellView? {
        let cell  = NSUserInterfaceItemIdentifier("ConversationCell")
        let color = NSColor.textColor

        var text: NSMutableAttributedString

        if conversation.type == GroupType.channel || conversation.type == GroupType.group {
            text = NSMutableAttributedString(string: "  ")

            let prefix = NSAttributedString(string: "#", attributes: [NSAttributedString.Key.foregroundColor : NSColor.tertiaryLabelColor])

            text.append(prefix)
            text.append(NSAttributedString(string: conversation.name))
        } else if conversation.type == GroupType.im {
            text = NSMutableAttributedString(string: "  ")

            let prefix = NSAttributedString(string: "@", attributes: [NSAttributedString.Key.foregroundColor : NSColor.tertiaryLabelColor])

            text.append(prefix)
            text.append(NSAttributedString(string: conversation.name))
        } else {
            text = NSMutableAttributedString(string: "  \(conversation.name)")
        }

        var unreadCount = 0

        if conversation.unread > 0 {
            unreadCount = conversation.unread
        }

        let view = self.makeView(withIdentifier: cell, owner: nil) as? NSTableCellView

        if let view = view {
            if let textField = view.textField {
                textField.textColor = color

                if (unreadCount > 0) {
                    var unreadFont = NSFont(name: "Lato Medium", size: 10)

                    if unreadFont == nil {
                        unreadFont = NSFont.systemFont(ofSize: 10)
                    }

                    if let unreadFont = unreadFont {
                        let unread = NSAttributedString(string: "\(unreadCount)", attributes: [
                            NSAttributedString.Key.foregroundColor : NSColor.systemOrange,
                            NSAttributedString.Key.font : unreadFont
                        ])

                        text.append(NSAttributedString(string: "  "))
                        text.append(unread)
                    }
                }

                textField.attributedStringValue = text
            }
        }

        return view
    }
}
