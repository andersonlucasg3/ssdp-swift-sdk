import struct Foundation.Data

public class ByebyeSender: Sender<Listener> {
    fileprivate var nt: Value.NT!
    fileprivate var uuid: String!
        
    public func send() throws {
        try send(addr: .init(host: Host.ip, port: Host.port), body: requestBody())
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
        private var request: ByebyeSender
        
        public init() {
            request = .init()
        }
        
        public func set(nt: Value.NT) -> Builder { request.nt = nt; return self }
        public func set(uuid: String) -> Builder { request.uuid = uuid; return self }
        
        public func build() -> ByebyeSender {
            return request
        }
    }
    
    enum RTU {
        case byebye(nt: Value.NT, uuid: String)
        
        public func build() -> ByebyeSender {
            switch self {
            case .byebye(let nt, let uuid):
                return Builder()
                    .set(nt: nt)
                    .set(uuid: uuid)
                    .build()
            }
        }
    }
}
