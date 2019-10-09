import struct Foundation.Data

public class NotifyRequest: Request {
    public struct Builder {
        fileprivate var request: NotifyRequest
        
        public init() {
            request = .init()
        }
        
        public mutating func set(location: String) -> Builder { request.location = location; return self }
        public mutating func set(domain: String) -> Builder { request.domain = domain; return self }
        public mutating func set(device: String) -> Builder { request.device = device; return self }
        public mutating func set(deviceType: String) -> Builder { request.deviceType = deviceType; return self }
        public mutating func set(version: UInt16) -> Builder { request.version = version; return self }
        public mutating func set(ssdp message: Value.SSDP) -> Builder { request.ssdp = message; return self }
        public mutating func set(uuid: String) -> Builder { request.uuid = uuid; return self }
        
        func build() -> NotifyRequest {
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
    
    fileprivate func parseHeaders(headers: Headers) throws -> Data {
        guard let host = headers[.host]?.rawValue else { throw RequestError.missing(header: .host) }
        guard let cc = headers[.cacheControl]?.rawValue else { throw RequestError.missing(header: .cacheControl) }
        guard let loc = headers[.location]?.rawValue else { throw RequestError.missing(header: .location) }
        guard let nt = headers[.nt]?.rawValue else { throw RequestError.missing(header: .nt) }
        guard let nts = headers[.nts]?.rawValue else { throw RequestError.missing(header: .nts) }
        guard let server = headers[.server]?.rawValue else { throw RequestError.missing(header: .server) }
        guard let usn = headers[.usn]?.rawValue else { throw RequestError.missing(header: .usn) }
        
        return "NOTIFY * HTTP/1.1\r\n"
            .appending("HOST:\(host)\r\n")
            .appending("CACHE-CONTROL:\(cc)\r\n")
            .appending("LOCATION:\(loc)\r\n")
            .appending("NT:\(nt)\r\n")
            .appending("NTS:\(nts)\r\n")
            .appending("SERVER:\(server)\r\n")
            .appending("USN:\(usn)\r\n\r\n")
            .data(using: .utf8)!
    }
    
    override open func requestBody() throws -> Data {
        let nt = Value.NT.urn(domain: domain, device: device, type: deviceType, version: version)
        return try parseHeaders(headers: [
            .host: .host(value: .address),
            .cacheControl: .cacheControl(value: .maxAge(seconds: 10)),
            .location: .location(value: location),
            .nt: .nt(value: nt),
            .nts: .nts(value: .sspd(value: ssdp)),
            .server: .server(value: .value),
            .usn: .usn(value: .uuid(uuid: uuid, nt: nt))
        ])
    }
    
    override open func received(response: String, from host: String) throws {
        Log.debug(message: "Response: \(response) \n From: \(host)")
    }
}
