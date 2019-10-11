import Foundation

public class SearchResponseSender {
    fileprivate var sender: AliveSender
    
    fileprivate var duration: Int = 120
    fileprivate var location: String!
    fileprivate var st: Value.ST!
    fileprivate var usn: Value.USN!
    
    internal init(sender: AliveSender) {
        self.sender = sender
    }
    
    public func send(addr: Address) throws {
        try sender.send(addr: addr, body: requestBody())
    }
    
    private func requestBody() -> MessageBody {
        let body = MessageBody.init()
        
        let fmtr = DateFormatter.init()
        
        let fmtDate = fmtr.string(from: .init())
        
        body.set(method: .httpOk)
        body.add(header: .cacheControl, with: .cacheControl(value: .maxAge(seconds: duration)))
        body.add(header: .date, with: .date(value: fmtDate))
        body.add(header: .ext, with: .ext)
        body.add(header: .location, with: .location(value: location))
        body.add(header: .server, with: .server(value: .this))
        body.add(header: .st, with: .st(value: st))
        body.add(header: .usn, with: .usn(value: usn))
        
        return body
    }
}

public extension SearchResponseSender {
    class Builder {
        private var sender: SearchResponseSender
        
        public init(sender: AliveSender) { self.sender = .init(sender: sender) }
        
        public func set(duration: Int) -> Builder { sender.duration = duration; return self }
        public func set(location: String) -> Builder { sender.location = location; return self }
        public func set(st: Value.ST) -> Builder { sender.st = st; return self }
        public func set(usn: Value.USN) -> Builder { sender.usn = usn; return self }
        
        public func build() -> SearchResponseSender {
            return sender
        }
    }
    
    enum RTU {
        case response(sender: AliveSender, duration: Int = 120, location: String, st: Value.ST, usn: Value.USN)
        
        public func build() -> SearchResponseSender {
            switch self {
            case .response(let sender, let duration, let location, let st, let usn):
                return Builder(sender: sender)
                    .set(st: st)
                    .set(usn: usn)
                    .set(duration: duration)
                    .set(location: location)
                    .build()
            }
        }
    }
}
