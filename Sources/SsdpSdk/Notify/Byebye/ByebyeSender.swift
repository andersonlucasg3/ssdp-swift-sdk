import struct Foundation.Data

public class ByebyeSender {
    private var sender: AliveSender
    
    fileprivate var nt: Value.NT!
    fileprivate var uuid: String!
        
    internal init(sender: AliveSender) {
        self.sender = sender
    }
    
    public func send() throws {
        try sender.send(addr: .init(host: Host.ip, port: Host.port), body: requestBody())
    }
    
    private func requestBody() -> MessageBody {
        let body = MessageBody.init()
        
        body.set(method: .notify)
        body.add(header: .host, with: .host(value: .address))
        body.add(header: .nt, with: .nt(value: nt))
        body.add(header: .nts, with: .nts(value: .sspd(value: .byebye)))
        body.add(header: .usn, with: .usn(value: .uuid(uuid: uuid)))
        
        return body
    }
}

public extension ByebyeSender {
    class Builder {
        private var sender: ByebyeSender
        
        public init(sender: AliveSender) { self.sender = .init(sender: sender) }
        
        public func set(nt: Value.NT) -> Builder { sender.nt = nt; return self }
        public func set(uuid: String) -> Builder { sender.uuid = uuid; return self }
        
        public func build() -> ByebyeSender {
            return sender
        }
    }
    
    enum RTU {
        case byebye(sender: AliveSender, nt: Value.NT, uuid: String)
        
        public func build() -> ByebyeSender {
            switch self {
            case .byebye(let sender, let nt, let uuid):
                return Builder(sender: sender)
                    .set(nt: nt)
                    .set(uuid: uuid)
                    .build()
            }
        }
    }
}
