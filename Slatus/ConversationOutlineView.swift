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

    func setRowHeight() {
        // Create a button just so we can see how tall it is. This will be our row height.

        let button = NSButton(title: "X", target: nil, action: nil)

        button.bezelStyle = NSButton.BezelStyle.roundRect

        let buttonFrame = button.frame

        self.rowHeight = buttonFrame.height
    }

    func makeWorkspaceHeader(_ workspace: SlackWorkspace) -> NSTableCellView? {
        let cell  = NSUserInterfaceItemIdentifier("ConversationCell")
        let text  = NSMutableAttributedString(string: workspace.name.uppercased())
        let color = NSColor.tertiaryLabelColor

        let view = self.makeView(withIdentifier: cell, owner: nil) as? NSTableCellView

        if let view = view {
            if let textField = view.textField {
                self._centerTextField(textField)

                textField.attributedStringValue = text
                textField.textColor = color

                // view.layer?.borderWidth = 1
                // textField.layer?.borderWidth = 1
            }
        }

        return view
    }

    func makeConversationRow(_ conversation: Conversation) -> NSTableCellView? {
        let cell = NSUserInterfaceItemIdentifier("ConversationCell")

        var text: NSMutableAttributedString

        if conversation.type == GroupType.channel || conversation.type == GroupType.group {
            text = NSMutableAttributedString(string: "  #\(conversation.name)")
        } else if conversation.type == GroupType.im {
            text = NSMutableAttributedString(string: "  @\(conversation.name)")
        } else {
            text = NSMutableAttributedString(string: "  \(conversation.name)")
        }

        var unreadCount = 0

        if conversation.unread > 0 {
            unreadCount = conversation.unread
        }

        let view = self.makeView(withIdentifier: cell, owner: nil) as? NSTableCellView

        if let view = view {

            //
            // Remove any stale buttons still hanging around from the last refresh.
            //

            self._clearButtons(view)

            if let textField = view.textField {

                //
                // Center the text field in the view.
                //

                self._centerTextField(textField)

                textField.attributedStringValue = text

                if (unreadCount > 0) {
                    let button = NSButton(title: "", target: nil, action: nil)

                    var buttonFont = NSFont(name: "Lato Medium", size: 10)

                    if buttonFont == nil {
                        buttonFont = NSFont.systemFont(ofSize: 10)
                    }

                    if let buttonFont = buttonFont {
                        button.attributedTitle = NSAttributedString(string: "\(unreadCount)", attributes: [
                            NSAttributedString.Key.foregroundColor : NSColor.systemOrange,
                            NSAttributedString.Key.font : buttonFont
                        ])
                    }

                    button.bezelStyle = NSButton.BezelStyle.roundRect

                    button.sizeToFit()

                    // Calculate where to put the button.

                    let textFieldFrame = textField.frame
                    let buttonFrame = button.frame

                    let frameX   = view.frame.minX + textFieldFrame.minX + text.size().width + buttonFrame.width
                    let frameY   = (view.frame.height - buttonFrame.height) / 2
                    let newFrame = NSRect(x: frameX, y: frameY, width: buttonFrame.width + 1, height: buttonFrame.height + 1)

                    button.frame = newFrame

                    view.addSubview(button)
                }
            }
        }

        return view
    }

    func _clearButtons(_ view: NSView) {
        var remove = [NSView]()

        for subview in view.subviews {
            if subview is NSButton {
                remove.append(subview)
            }
        }

        for subview in remove {
            subview.removeFromSuperview()
        }
    }

    func _centerTextField(_ textField: NSTextField) {
        let textFieldWidth  = textField.frame.width
        let textFieldHeight = textField.frame.height
        let textFieldX      = textField.frame.minX
        let textFieldY      = (self.rowHeight - textFieldHeight) / 2

        textField.frame = NSRect(x: textFieldX, y: textFieldY, width: textFieldWidth, height: textFieldHeight)
    }
}
