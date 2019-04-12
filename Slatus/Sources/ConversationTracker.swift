//
//  Unread.swift
//  Slatus
//
//  Created by Dan Holm on 4/7/19.
//  Copyright © 2019 Holmosapien. All rights reserved.
//

import Foundation

class ConversationTracker {
    var conversations: [Conversation]

    var count: Int {
        get {
            var count = 0

            for conversation in self.conversations {
                if conversation.lastMessage > conversation.lastRead {
                    print("Conversation \(conversation.name) is not current.")

                    count += 1
                } else {
                    print("Conversation \(conversation.name) is caught up (\(conversation.lastRead) :: \(conversation.lastMessage)).")
                }
            }

            if count == 0 {

                //
                // If there are no conversations, return '1' anyway. This will cause the
                // view controller to fetch a NoConversations or NoUnread object, which
                // will write a "No unread messages" line in the UI.
                //
                // TODO: There's probably a less stupid way to do this.
                //

                count = 1
            }

            return count
        }
    }

    var all: [Conversation] {
        get {
            return self.conversations
        }
    }

    var unread: [Conversation] {
        get {
            var conversations = [Conversation]()

            for conversation in self.conversations {
                if conversation.lastMessage > conversation.lastRead {
                    conversations.append(conversation)
                }
            }

            return conversations
        }
    }

    init() {
        self.conversations = []
    }

    subscript(index: Int) -> Conversation? {
        let all    = self.all
        let unread = self.unread

        if all.count == 0 {
            return NoConversations()
        }

        if unread.count > index {
            return unread[index]
        }

        return NoUnread()
    }

    func watch(_ conversation: Conversation) {
        self.conversations.append(conversation)
    }
}
