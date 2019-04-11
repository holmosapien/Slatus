//
//  AppDelegate.swift
//  Slatus
//
//  Created by Dan Holm on 4/6/19.
//  Copyright © 2019 Holmosapien. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let defaults = UserDefaults.standard
    var workspaces = [SlackWorkspace]()
    var notificationCenter = NotificationCenter.default

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
            self.addSlackWorkspace(token, save: false)
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    func addSlackWorkspace(_ token: String, save: Bool) {
        let workspace = SlackWorkspace(token)

        workspace.go()

        self.workspaces.append(workspace)

        //
        // Save it to UserDefaults if it's not already there.
        //

        if save == true {
            if let tokens = self.defaults.object(forKey: "SlackTokens") as? [String] {
                if tokens.index(of: token) == nil {
                    let newTokens = tokens + [token]

                    self.defaults.set(newTokens, forKey: "SlackTokens")
                }
            }
        }

        self.notificationCenter.post(name: Notification.Name("conversationListUpdate"), object: nil)
    }

    func deleteSlackWorkspace(_ workspace: SlackWorkspace) {
        let token = workspace.token

        if let index = self.workspaces.index(of: workspace) {
            self.workspaces.remove(at: index)

            if let tokens = self.defaults.object(forKey: "SlackTokens") as? [String] {
                if tokens.index(of: token) != nil {
                    let newTokens = tokens.filter { $0 != token }

                    self.defaults.set(newTokens, forKey: "SlackTokens")
                }
            }

            self.notificationCenter.post(name: Notification.Name("conversationListUpdate"), object: nil)
        }
    }
}
