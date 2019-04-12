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
}
