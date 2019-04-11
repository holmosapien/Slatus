//
//  SlackWorkspace.swift
//  Slatus
//
//  Created by Dan Holm on 4/8/19.
//  Copyright © 2019 Holmosapien. All rights reserved.
//

import Cocoa
import SlackKit

class SlackWorkspace: NSObject {
    var bot: SlackKit
    var token: String
    var name: String
    var conversations: ConversationTracker

    override init() {
        self.bot = SlackKit()
        self.token = ""
        self.name = "Unknown"
        self.conversations = ConversationTracker()

        super.init()
    }

    init(_ token: String) {
        self.bot = SlackKit()
        self.token = token
        self.name = "Loading"
        self.conversations = ConversationTracker()
    }

    func go() {

        // The RTM API uses a webhook to get rapid updates for Slack activity.
        // SlackClient is a sub-class of the RTM client in the SlackKit library:
        // https://github.com/pvzig/SlackKit

        bot.addRTMBotWithAPIToken(token, client: SlackClient(bot, self))

        // The web API is useful for getting more information about channels and users
        // during webhook activity.

        bot.addWebAPIAccessWithToken(token)
    }
}
