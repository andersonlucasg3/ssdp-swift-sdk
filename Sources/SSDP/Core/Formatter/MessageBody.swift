import Foundation

public class MessageBody {
    public private(set) var method: Method!
    public private(set) var headers: Dictionary<Header, Value> = [:]
    
    public init() { }
    
    public init?(from data: Data) {
        if !inverseBuild(data: data) {
            return nil
        }
    }
    
    public func set(method: Method) {
        self.method = method
    }
    
    public func add(header key: Header, with value: Value) {
        headers[key] = value
    }
    
    // MARK: - Build
    
    public func build() -> Data {
        let request: Unmanaged<CFHTTPMessage>
        if case .httpOk = method {
            request = CFHTTPMessageCreateResponse(nil, 200,
                                                  "OK" as CFString,
                                                  kCFHTTPVersion1_1)
        } else {
            request = CFHTTPMessageCreateRequest(nil, method.rawValue as CFString,
                                                 URL.init(string: "*")! as CFURL,
                                                 kCFHTTPVersion1_1)
        }
        
        for header in headers {
            CFHTTPMessageSetHeaderFieldValue(request.takeUnretainedValue(),
                                             header.key.rawValue as CFString,
                                             value(header.value) as CFString)
        }
        
        let message = CFHTTPMessageCopySerializedMessage(request.takeUnretainedValue())
        request.release()
        let data = message!.takeUnretainedValue()
        message?.release()
        return data as Data
    }
    
    private func value(_ value: Value) -> String {
        switch value {
        case .host(let value): return value.rawValue
        case .nt(let value): return from(nt: value)
        case .nts(let value): return from(nts: value)
        case .location(let value): return value
        case .cacheControl(let value): return from(cc: value)
        case .server(let value): return value.rawValue
        case .usn(let value): return from(usn: value)
        case .man(let value): return from(man: value)
        case .mx(let value): return from(mx: value)
        case .st(let value): return from(st: value)
        case .userAgent(let value): return value.rawValue
        case .date(let value): return "\"\(value)\""
        case .ext: return ""
        }
    }
    
    fileprivate func from(nt: Value.NT) -> String {
        switch nt {
        case .upnp:
            return "upnp:rootdevice"
        case .urn(let domain, let type, let version):
            return "urn:\(domain):device:\(type):\(version)"
        case .ssdp(let ssdp):
            return "ssdp:\(ssdp.rawValue)"
        case .uuid(let uuid):
            return "uuid:\(uuid)"
        }
    }
    
    fileprivate func from(nts: Value.NTS) -> String {
        switch nts {
        case .sspd(let value): return "ssdp:\(value.rawValue)"
        }
    }
    
    fileprivate func from(cc: Value.CacheControl) -> String {
        switch cc {
        case .maxAge(let seconds): return "max-age=\(seconds)"
        }
    }
    
    fileprivate func from(usn: Value.USN) -> String {
        switch usn {
        case .nt(let uuid, let nt):
            return "uuid:\(uuid)::\(from(nt: nt))"
        case .uuid(let uuid):
            return "uuid:\(uuid)"
        }
    }
    
    fileprivate func from(man: Value.MAN) -> String {
        switch man {
        case .ssdp(let ssdp):
            return "\"\(from(nts: .sspd(value: ssdp)))\""
        }
    }
    
    fileprivate func from(mx: Value.MX) -> String {
        switch mx {
        case .delay(let seconds): return "\(seconds)"
        }
    }
    
    fileprivate func from(st: Value.ST) -> String {
        switch st {
        case .nt(let nt): return from(nt: nt)
        case .ssdp(let ssdp): return "ssdp:\(ssdp.rawValue)"
        }
    }
    
    // MARK: - Inverse build
    
    fileprivate func inverseBuild(data: Data) -> Bool {
        let response = CFHTTPMessageCreateEmpty(kCFAllocatorDefault, true)
        CFHTTPMessageAppendBytes(response.takeUnretainedValue(), Array<UInt8>.init(data), data.count)
        
        if CFHTTPMessageIsHeaderComplete(response.takeUnretainedValue()) {
            guard let method = CFHTTPMessageCopyRequestMethod(response.takeUnretainedValue())?.autorelease().takeUnretainedValue() else { return false }
            let code = CFHTTPMessageCopyResponseStatusLine(response.takeUnretainedValue())?.autorelease().takeUnretainedValue()
            
            guard let headerDict = CFHTTPMessageCopyAllHeaderFields(response.takeUnretainedValue())?.autorelease().takeUnretainedValue() else { return false }
            
            guard let headers = headerDict as? Dictionary<String, String> else { return false }
            
            if let code = code {
                self.method = Method.init(rawValue: "\(method) \(code) OK")
            } else {
                self.method = Method.init(rawValue: method as String)
            }
            
            guard self.method != nil else { return false }
            
            for header in headers {
                guard let key = Header.init(rawValue: header.key.uppercased()) else { continue }
                guard let value = value(from: header.value, for: key) else { continue }
                self.headers[key] = value
            }
            
            return true
        }
        return false
    }
    
    private func value(from value: String, for key: Header) -> Value? {
        switch key {
        case .cacheControl: return .cacheControl(value: cacheControl(value: value))
        case .host: return .host(value: .custom(address: value))
        case .location: return .location(value: value)
        case .man: return .man(value: man(value: value))
        case .mx: return .mx(value: .delay(seconds: Int(value)!))
        case .nt: if let nt = nt(value: value) { return .nt(value: nt) }
        case .nts: return .nts(value: .sspd(value: ssdp(value: value)))
        case .server: if let server = server(value: value) { return .server(value: server) }
        case .st: return .st(value: st(value: value))
        case .userAgent: if let server = server(value: value) { return .userAgent(value: server) }
        case .usn: return .usn(value: usn(value: value))
        case .date: return .date(value: value)
        case .ext: return .ext
        }
        return nil
    }
    
    fileprivate func usn(value: String) -> Value.USN {
        if value.contains("::") {
            let comps = value.components(separatedBy: "::")
            let uuid = comps.first!
            let urn = comps.last!
            return .nt(uuid: uuid.components(separatedBy: ":").last!,
                       nt: nt(value: urn)!)
        }
        let comps = value.components(separatedBy: ":")
        return .uuid(uuid: comps.last!)
    }
    
    fileprivate func st(value: String) -> Value.ST {
        if let nt = nt(value: value) {
            return .nt(nt: nt)
        }
        return .ssdp(ssdp: ssdp(value: value))
    }
    
    fileprivate func server(value: String) -> Value.Server? {
        let comps = value.replacingOccurrences(of: ",", with: "")
            .components(separatedBy: " ")
        let osComps = comps.first!.components(separatedBy: "/")
        let prodComps = comps.last!.components(separatedBy: "/")
        
        guard osComps.count > 1 && prodComps.count > 1 else { return nil }
        
        return .custom(os: osComps[0], osv: osComps[1], p: prodComps[0], pv: prodComps[1])
    }
    
    fileprivate func nt(value: String) -> Value.NT? {
        if value.hasPrefix("upnp:") {
            return .upnp
        } else if value.hasPrefix("urn:") {
            let comps = value.components(separatedBy: ":")
            let domain = comps[1]
            let type = comps[3]
            let version = comps[4]
            return .urn(domain: domain, type: type, version: UInt16(version)!)
        } else if value.hasPrefix("ssdp:") {
            return .ssdp(ssdp: ssdp(value: value))
        } else if value.hasPrefix("uuid:") {
            let uuid = value.components(separatedBy: ":").last!
            return .uuid(uuid: uuid)
        }
        return nil
    }
    
    fileprivate func ssdp(value: String) -> Value.SSDP {
        let value = value.replacingOccurrences(of: "\"", with: "")
            .components(separatedBy: ":").last!
        return Value.SSDP.init(rawValue: value)!
    }
    
    fileprivate func man(value: String) -> Value.MAN {
        return .ssdp(ssdp: ssdp(value: value))
    }
    
    fileprivate func cacheControl(value: String) -> Value.CacheControl {
        return .maxAge(seconds: Int(value.split(separator: "=").last!)!)
    }
}
