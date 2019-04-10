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

    var _webAPI: WebAPI?

    init(webAPI: WebAPI?, id: String, name: String?, members: [UserInfo]?, type: GroupType, lastRead: Date) {
        self.id          = id
        self.type        = type
        self.lastMessage = Date(timeIntervalSince1970: 0)
        self.lastRead    = lastRead

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
            self._webAPI?.imHistory(id: self.id, latest: lastRead, success: _historySuccess, failure: _historyFailure)
        case .mpim:
            self._webAPI?.mpimHistory(id: self.id, latest: lastRead, success: _historySuccess, failure: _historyFailure)
        }
    }

    func _channelInfoSuccess(channel: SKCore.Channel) {
        let latestMessage = channel.latest

        if let latestTimestampString = latestMessage?.ts {
            if let latestTimestampDouble = Double(latestTimestampString) {
                let latestTimestamp = Date(timeIntervalSince1970: latestTimestampDouble)

                self.lastMessage = latestTimestamp
            }
        }
    }

    func _channelInfoFailure(_ error: Any) {
    }

    func _historySuccess(history: SKCore.History) {
        // let messages = history.messages

        if let latestTimestamp = history.latest {
            self.lastMessage = latestTimestamp
        }
    }

    func _historyFailure(_ error: Any) {
    }
}
