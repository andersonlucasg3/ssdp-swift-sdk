import struct Foundation.Data

public class AliveRequest: Request {
    fileprivate var nt: Value.NT!
    fileprivate var uuid: String!
    fileprivate var location: String!
    fileprivate var duration: UInt16!
    fileprivate var server: Value.Server!
    
    public override var shouldHandleResponses: Bool { return false }
    
    internal init() { super.init(sendCount: 3) }
    
    override open func requestBody() throws -> Data {
        let formatter = RequestBodyFormatter.init()
                
        formatter.set(method: .notify)
        formatter.add(header: .host, with: .host(value: .address))
        formatter.add(header: .cacheControl, with: .cacheControl(value: .maxAge(seconds: duration)))
        formatter.add(header: .location, with: .location(value: location))
        formatter.add(header: .nt, with: .nt(value: nt))
        formatter.add(header: .nts, with: .nts(value: .sspd(value: .alive)))
        formatter.add(header: .server, with: .server(value: server))
        formatter.add(header: .usn, with: .usn(value: .nt(uuid: uuid, nt: nt)))
        
        let formatted = formatter.format()
        
        Log.debug(message: "Sending request \n\(formatted)")
        
        return formatted.data(using: .utf8)!
    }
}

public extension AliveRequest {
    class Builder {
        fileprivate var request: AliveRequest
        
        public init() {
            request = .init()
        }
        
        public func set(location: String) -> Builder { request.location = location; return self }
        public func set(nt: Value.NT) -> Builder { request.nt = nt; return self }
        public func set(uuid: String) -> Builder { request.uuid = uuid; return self }
        public func set(duration: UInt16) -> Builder { request.duration = duration; return self }
        public func set(server: Value.Server) -> Builder { request.server = server; return self }
        
        public func build() -> AliveRequest {
            return request
        }
    }
    
    enum RTU {
        case alive(location: String, nt: Value.NT, uuid: String, duration: UInt16, server: Value.Server = .this)
        
        public func build() -> AliveRequest {
            switch self {
            case .alive(let location, let nt, let uuid, let duration, let server):
                return Builder()
                    .set(nt: nt)
                    .set(location: location)
                    .set(uuid: uuid)
                    .set(duration: duration)
                    .set(server: server)
                    .build()
            }
        }
    }
}
