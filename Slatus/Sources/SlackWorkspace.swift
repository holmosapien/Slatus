//
//  SlackWorkspace.swift
//  Slatus
//
//  Created by Dan Holm on 4/8/19.
//  Copyright © 2019 Holmosapien. All rights reserved.
//

import Cocoa

class SlackWorkspace: NSObject {
    var name = ""
    var conversations: ConversationTracker

    override init() {
        self.conversations = ConversationTracker()

        super.init()
    }
}
