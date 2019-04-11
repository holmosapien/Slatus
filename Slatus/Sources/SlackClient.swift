import Foundation
import SlackKit
import SKClient

enum GroupType: String {
    case channel, group, im, mpim
}

struct UserInfo {
    var id: String
    var handle: String
    var firstName: String
    var lastName: String
    var realName: String
    var displayName: String
}

class SlackClient: Client {
    private var workspace: SlackWorkspace
    private var bot: SlackKit
    private var notificationCenter: NotificationCenter
    private var userMap: [String: UserInfo]

    init(_ bot: SlackKit, _ workspace: SlackWorkspace) {
        self.workspace = workspace
        self.bot = bot
        self.notificationCenter = NotificationCenter.default
        self.userMap = [:]
    }

    override func notificationForEvent(_ event: Event, type: EventType) {
        switch type {
        case .message:
            if event.subtype == nil {
                self._receiveMessage(event)
            } else {
                self._dispatchMessage(event)
            }

            break
        case .channelMarked, .imMarked, .groupMarked:
            self._markChannel(event)

            break
        case .channelJoined:
            self._joinChannel(event, GroupType.channel)

            break
        case .groupJoined:
            self._joinChannel(event, GroupType.group)

            break
        case .hello, .pong:
            self.notificationCenter.post(name: Notification.Name("conversationListUpdate"), object: nil)

            break
        default:
            print("\(event) \(type)")
            break
        }
    }

    override func initialSetup(JSON: [String : Any]) {
        if let teamInfo = JSON["team"] as? [String: Any] {
            if let teamName = teamInfo["name"] as? String {
                self.workspace.name = teamName
            }
        }

        self._enumerateObjects(JSON["users"] as? Array) { (user) in self._addUser(user) }
        self._enumerateObjects(JSON["channels"] as? Array) { (channel) in self._addChannel(channel, GroupType.channel) }
        self._enumerateObjects(JSON["groups"] as? Array) { (group) in self._addChannel(group, GroupType.group) }
        self._enumerateObjects(JSON["ims"] as? Array) { (im) in self._addIM(im, GroupType.im) }
        self._enumerateObjects(JSON["mpims"] as? Array) { (mpim) in self._addIM(mpim, GroupType.mpim) }
    }

    func _enumerateObjects(_ array: [Any]?, initializer: ([String: Any]) -> Void) {
        if let array = array {
            for object in array {
                if let dictionary = object as? [String: Any] {
                    initializer(dictionary)
                }
            }
        }
    }

    func _addUser(_ user: [String: Any]?) {
        guard
            let id = user?["id"] as? String,
            let name = user?["name"] as? String,
            let profile = user?["profile"] as? [String: Any],
            let realName = profile["real_name"] as? String,
            let displayName = profile["display_name"] as? String
        else {
            return
        }

        var firstName = ""
        var lastName  = ""

        if let _firstName = profile["first_name"] as? String {
            if let _lastName = profile["last_name"] as? String {
                firstName = _firstName
                lastName  = _lastName
            }
        }

        print("Parsed user \(name) \(firstName) \(lastName)")

        let userInfo = UserInfo(id: id, handle: name, firstName: firstName, lastName: lastName, realName: realName, displayName: displayName)

        self.userMap[id] = userInfo
    }

    func _addChannel(_ channel: [String: Any]?, _ type: GroupType) {
        if let id = channel?["id"] as? String {
            if let name = channel?["name"] as? String {
                let lastRead = self._unwrapDate(channel?["last_read"] as? String)
                let conversation = Conversation(webAPI: self.bot.webAPI, id: id, name: name, members: nil, type: type, lastRead: lastRead)

                self.workspace.conversations.watch(conversation)

                conversation.getMessages()
            }
        }
    }

    func _addIM(_ im: [String: Any]?, _ type: GroupType) {
        if let id = im?["id"] as? String {
            let lastRead = self._unwrapDate(im?["last_read"] as? String)
            var members  = [UserInfo]()

            if type == GroupType.im {
                if let userId = im?["user"] as? String {
                    if let userInfo = self.userMap[userId] {
                        members.append(userInfo)
                    }
                }
            } else if type == GroupType.mpim {
                if let users = im?["members"] as? [String] {
                    for userId in users {
                        if let userInfo = self.userMap[userId] {
                            members.append(userInfo)
                        }
                    }
                }
            }

            let conversation = Conversation(webAPI: self.bot.webAPI, id: id, name: nil, members: members, type: type, lastRead: lastRead)

            print("Watching conversation id \(id) of type \(type): \(members)")

            self.workspace.conversations.watch(conversation)

            conversation.getMessages()
        }
    }

    func _dispatchMessage(_ event: Event) {
        guard
            let value = event.subtype,
            let subtype = MessageSubtype(rawValue:value)
        else {
            print("I don't know what to do with this dispatch.")

            return
        }

        switch subtype {
        case .messageChanged, .messageDeleted:
            break
        default:
            self._receiveMessage(event)
        }
    }

    func _receiveMessage(_ event: Event) {
        guard
            let channel = event.channel,
            let message = event.message,
            let id = channel.id,
            let ts = message.ts
        else {
            print("I don't know what to do with this message.")

            return
        }

        print("Finding conversation with id \(id)")

        for conversation in self.workspace.conversations.all {
            if conversation.id == id {
                print("Setting conversation \(id) lastMessage to \(ts)")

                conversation.lastMessage = self._unwrapDate(ts)

                //
                // Increase the unread count for the conversation.
                //

                conversation.unread += 1

                self.notificationCenter.post(name: Notification.Name("conversationListUpdate"), object: nil)
            }
        }
    }

    func _markChannel(_ event: Event) {
        guard
            let channel = event.channel,
            let id = channel.id
        else {
            print("I don't know what to do with this mark.")

            return
        }

        print("Finding conversation with id \(id)")

        for conversation in self.workspace.conversations.all {
            if conversation.id == id {
                print("Setting conversation \(id) lastRead to \(event.ts)")

                conversation.lastRead = self._unwrapDate(event.ts)

                //
                // Reset the unread count for the conversation.
                //

                conversation.updateHistory()

                self.notificationCenter.post(name: Notification.Name("conversationListUpdate"), object: nil)
            }
        }
    }

    func _joinChannel(_ event: Event, _ type: GroupType) {
        guard
            let channel = event.channel,
            let id      = channel.id,
            let name    = channel.name
        else {
            return
        }

        let lastRead     = self._unwrapDate(channel.lastRead)
        let conversation = Conversation(webAPI: self.bot.webAPI, id: id, name: name, members: nil, type: type, lastRead: lastRead)

        self.workspace.conversations.watch(conversation)

        conversation.getMessages()
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
