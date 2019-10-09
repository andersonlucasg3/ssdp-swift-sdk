import struct Foundation.Data

public class NotifyRequest: Request {
    fileprivate var nt: Value.NT!
    fileprivate var uuid: String!
    
    fileprivate var location: String?
    fileprivate var duration: UInt16?
    fileprivate var server: Value.Server?
    fileprivate var ssdp: Value.SSDP = .alive
    
    public override var shouldHandleResponses: Bool { return false }
    
    fileprivate override init() { super.init() }
    
    override open func requestBody() throws -> Data {
        let formatter = RequestBodyFormatter.init()
                
        formatter.set(method: .notify)
        formatter.add(header: .host, with: .host(value: .address))
        if let duration = duration { formatter.add(header: .cacheControl, with: .cacheControl(value: .maxAge(seconds: duration))) }
        if let location = location { formatter.add(header: .location, with: .location(value: location)) }
        if let server = server { formatter.add(header: .server, with: .server(value: server)) }
        
        formatter.add(header: .nt, with: .nt(value: nt))
        formatter.add(header: .nts, with: .nts(value: .sspd(value: ssdp)))
        formatter.add(header: .usn, with: .usn(value: .uuid(uuid: uuid, nt: nt)))
        
        let formatted = formatter.format()
        
        Log.debug(message: "Sending request \n \(formatted)")
        
        return formatted.data(using: .utf8)!
    }
}

public extension NotifyRequest {
    class Builder {
        fileprivate var request: NotifyRequest
        
        public init() {
            request = .init()
        }
        
        public func set(location: String) -> Builder { request.location = location; return self }
        public func set(nt: Value.NT) -> Builder { request.nt = nt; return self }
        public func set(ssdp: Value.SSDP) -> Builder { request.ssdp = ssdp; return self }
        public func set(uuid: String) -> Builder { request.uuid = uuid; return self }
        public func set(duration: UInt16) -> Builder { request.duration = duration; return self }
        public func set(server: Value.Server) -> Builder { request.server = server; return self }
        
        public func build() -> NotifyRequest {
            return request
        }
        
        public enum RTU {
            case alive(location: String, nt: Value.NT, uuid: String, duration: UInt16, server: Value.Server = .this)
            case byebye(nt: Value.NT, uuid: String)
            
            public func build() -> NotifyRequest {
                switch self {
                case .alive(let location, let nt, let uuid, let duration, let server):
                    return Builder()
                        .set(ssdp: .alive)
                        .set(nt: nt)
                        .set(location: location)
                        .set(uuid: uuid)
                        .set(duration: duration)
                        .set(server: server)
                        .build()
                    
                case .byebye(let nt, let uuid):
                    return Builder()
                        .set(ssdp: .byebye)
                        .set(nt: nt)
                        .set(uuid: uuid)
                        .build()
                }
            }
        }
    }
}
