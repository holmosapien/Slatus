//
//  AppDelegate.swift
//  Slatus
//
//  Created by Dan Holm on 4/6/19.
//  Copyright © 2019 Holmosapien. All rights reserved.
//

import Cocoa
import SlackKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let defaults   = UserDefaults.standard
    var workspaces = [SlackWorkspace]()

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        //
        // Get the list of Slack tokens from the preferences list.
        //

        let slackTokens = self.defaults.object(forKey: "SlackTokens") as? [String] ?? [String]()

        //
        // Create a SlackWorkspace instance for each Slack token. The SlackWorkspace is
        // responsible for keeping a list of all of the conversations (channels, groups, IMs)
        // within the workspace. We wrap that simple functionality in a class since class
        // instances are passed by reference, while arrays are passed by value.
        //

        for token in slackTokens {
            let workspace = SlackWorkspace()
            let bot = SlackKit()

            // The RTM API uses a webhook to get rapid updates for Slack activity.
            // SlackClient is a sub-class of the RTM client in the SlackKit library:
            // https://github.com/pvzig/SlackKit

            bot.addRTMBotWithAPIToken(token, client: SlackClient(bot, workspace))

            // The web API is useful for getting more information about channels and users
            // during webhook activity.

            bot.addWebAPIAccessWithToken(token)

            self.workspaces.append(workspace)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}
