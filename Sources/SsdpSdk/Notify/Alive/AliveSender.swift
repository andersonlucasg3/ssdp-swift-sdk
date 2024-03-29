import struct Foundation.Data
import typealias Dispatch.os_block_t

public class AliveSender: Sender<AliveListener> {
    fileprivate var nt: Value.NT!
    fileprivate var usn: Value.USN!
    fileprivate var uuid: String!
    fileprivate var location: String!
    fileprivate var duration: Int = 120
    fileprivate var server: Value.Server!
    
    public func send() throws {
        try send(addr: .init(host: Host.ip, port: Host.port), body: requestBody())
    }
    
    public func listen() throws {
        try listen(addr: .init(host: Host.ip, port: Host.port))
    }
    
    private func requestBody() -> MessageBody {
        let body = MessageBody.init()
                
        body.set(method: .notify)
        body.add(header: .host, with: .host(value: .address))
        body.add(header: .cacheControl, with: .cacheControl(value: .maxAge(seconds: duration)))
        body.add(header: .location, with: .location(value: location))
        body.add(header: .nt, with: .nt(value: nt))
        body.add(header: .nts, with: .nts(value: .sspd(value: .alive)))
        body.add(header: .server, with: .server(value: server))
        body.add(header: .usn, with: .usn(value: usn))
        
        return body
    }
}

public extension AliveSender {
    class Builder {
        fileprivate var request: AliveSender
        
        public init() {
            request = .init()
        }
        
        public func set(location: String) -> Builder { request.location = location; return self }
        public func set(nt: Value.NT) -> Builder { request.nt = nt; return self }
        public func set(uuid: String) -> Builder { request.uuid = uuid; return self }
        public func set(duration: Int) -> Builder { request.duration = duration; return self }
        public func set(server: Value.Server) -> Builder { request.server = server; return self }
        public func set(usn: Value.USN) -> Builder { request.usn = usn; return self }
        
        public func build() -> AliveSender {
            return request
        }
    }
    
    enum RTU {
        case alive(location: String, nt: Value.NT, usn: Value.USN, uuid: String, duration: Int, server: Value.Server = .this)
        
        public func build() -> AliveSender {
            switch self {
            case .alive(let location, let nt, let usn, let uuid, let duration, let server):
                return Builder()
                    .set(nt: nt)
                    .set(location: location)
                    .set(uuid: uuid)
                    .set(duration: duration)
                    .set(server: server)
                    .set(usn: usn)
                    .build()
            }
        }
    }
}
