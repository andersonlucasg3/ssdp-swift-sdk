class RequestBodyFormatter {
    private var method: Method!
    private var headers: [Header: Value] = [:]
    
    public func set(method: Method) {
        self.method = method
    }
    
    public func add(header key: Header, with value: Value) {
        headers[key] = value
    }
    
    public func format() -> String {
        var output = "\(method.rawValue)\r\n"
        for kv in headers {
            output.append("\(kv.key.rawValue):\(value(kv.value))\r\n")
        }
        output.append("\r\n")
        return output
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
        }
    }
    
    fileprivate func from(nt: Value.NT) -> String {
        switch nt {
        case .urn(let domain, let device, let type, let version):
            return "urn:\(domain):\(device):\(type):\(version)"
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
        case .uuid(let uuid, let nt):
            return "uuid:\(uuid)::\(from(nt: nt))"
        }
    }
    
    public enum Method: String {
        case notify = "NOTIFY * HTTP/1.1"
    }
}
