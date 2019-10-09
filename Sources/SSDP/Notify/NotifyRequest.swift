import struct Foundation.Data

public class NotifyRequest: Request {
    public class Builder {
        fileprivate var request: NotifyRequest
        
        public init() {
            request = .init()
        }
        
        public func set(location: String) -> Builder { request.location = location; return self }
        public func set(domain: String) -> Builder { request.domain = domain; return self }
        public func set(device: String) -> Builder { request.device = device; return self }
        public func set(deviceType: String) -> Builder { request.deviceType = deviceType; return self }
        public func set(version: UInt16) -> Builder { request.version = version; return self }
        public func set(ssdp message: Value.SSDP) -> Builder { request.ssdp = message; return self }
        public func set(uuid: String) -> Builder { request.uuid = uuid; return self }
        
        public func build() -> NotifyRequest {
            return request
        }
    }
    
    fileprivate var uuid: String = ""
    fileprivate var location: String = ""
    fileprivate var domain: String = ""
    fileprivate var device: String = ""
    fileprivate var deviceType: String = ""
    fileprivate var version: UInt16 = 1
    fileprivate var ssdp: Value.SSDP = .alive
    
    public weak var delegate: NotifyRequestDelegate?
    
    fileprivate override init() { super.init() }
    
    override open func requestBody() throws -> Data {
        let formatter = RequestBodyFormatter.init()
        
        let nt = Value.NT.urn(domain: domain, device: device, type: deviceType, version: version)
        
        formatter.set(method: .notify)
        formatter.add(header: .host, with: .host(value: .address))
        formatter.add(header: .cacheControl, with: .cacheControl(value: .maxAge(seconds: 10)))
        formatter.add(header: .location, with: .location(value: location))
        formatter.add(header: .nt, with: .nt(value: nt))
        formatter.add(header: .nts, with: .nts(value: .sspd(value: ssdp)))
        formatter.add(header: .server, with: .server(value: .value))
        formatter.add(header: .usn, with: .usn(value: .uuid(uuid: uuid, nt: nt)))
        
        return formatter.format().data(using: .utf8)!
    }
    
    override open func received(response: String, from host: String) throws {
        Log.debug(message: "Response: \(response) \n From: \(host)")
    }
}
