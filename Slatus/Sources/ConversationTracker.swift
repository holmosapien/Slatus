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
    var current = -1

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

            print("There are \(count) conversations in unread state.")

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
        var i = 0

        for conversation in self.conversations {
            if conversation.lastMessage > conversation.lastRead {
                if i == index {
                    return conversation
                }

                i += 1
            }
        }

        return nil
    }

    func watch(_ conversation: Conversation) {
        self.conversations.append(conversation)
    }
}
