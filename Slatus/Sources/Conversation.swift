//
//  Conversation.swift
//  Slatus
//
//  Created by Dan Holm on 4/6/19.
//

import Cocoa
import Foundation
import SlackKit

class Conversation: NSObject {
    var id:          String
    var name:        String
    var type:        GroupType
    var members:     [UserInfo]
    var lastMessage: Date
    var lastRead:    Date
    var unread:      Int

    var _webAPI: WebAPI?

    init(webAPI: WebAPI?, id: String, name: String?, members: [UserInfo]?, type: GroupType, lastRead: Date) {
        self.id          = id
        self.type        = type
        self.lastMessage = Date(timeIntervalSince1970: 0)
        self.lastRead    = lastRead
        self.unread      = 0

        if let members = members {
            self.members = members
        } else {
            self.members = []
        }

        if let name = name {
            self.name = name
        } else {
            var name  = ""
            var index = 0

            for member in self.members {
                if index == 0 {
                    name = member.realName
                } else {
                    name += ", \(member.realName)"
                }

                index += 1
            }

            if (index > 0) {
                self.name = name
            } else {
                self.name = id
            }
        }

        self._webAPI = webAPI
    }

    func getMessages() {
        let lastRead = "\(self.lastRead.timeIntervalSince1970)"

        switch (self.type) {
        case .channel:
            self._webAPI?.channelInfo(id: self.id, success: _channelInfoSuccess, failure: _channelInfoFailure)
        case .group:
            self._webAPI?.groupInfo(id: self.id, success: _channelInfoSuccess, failure: _channelInfoFailure)
        case .im:
            self._webAPI?.imHistory(id: self.id, oldest: lastRead, success: _historySuccess, failure: _historyFailure)
        case .mpim:
            self._webAPI?.mpimHistory(id: self.id, oldest: lastRead, success: _historySuccess, failure: _historyFailure)
        }
    }

    func updateHistory() {
        if self.lastMessage > self.lastRead {
            let lastRead = "\(self.lastRead.timeIntervalSince1970)"

            self._webAPI?.channelHistory(id: self.id, oldest: lastRead, success: _historySuccess, failure: _historyFailure)
        } else {
            self.unread = 0
        }
    }

    func _channelInfoSuccess(channel: SKCore.Channel) {
        self.lastMessage = self._unwrapDate(channel.latest?.ts)

        //
        // Get all of the messages between the last read message and now,
        // so we can see how many unread messages we have now.
        //

        if self.lastMessage > self.lastRead {
            let lastRead = "\(self.lastRead.timeIntervalSince1970)"

            self._webAPI?.channelHistory(id: self.id, oldest: lastRead, success: _historySuccess, failure: _historyFailure)
        }
    }

    func _channelInfoFailure(_ error: Any) {
    }

    func _historySuccess(history: SKCore.History) {
        var latest = self.lastRead
        var unread = 0

        for message in history.messages {
            let ts = self._unwrapDate(message.ts)

            if ts > latest {
                latest = ts
            }

            unread += 1
        }

        self.lastMessage = latest
        self.unread      = unread
    }

    func _historyFailure(_ error: Any) {
    }

    func _unwrapDate(_ dateString: String?) -> Date {
        if let lastReadString = dateString {
            if let lastReadDouble = Double(lastReadString) {
                let lastRead = Date(timeIntervalSince1970: lastReadDouble)

                return lastRead
            }
        }

        return Date(timeIntervalSince1970: 0)
    }
}
