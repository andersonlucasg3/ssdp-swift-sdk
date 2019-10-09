class RequestBodyFormatter {
    private var method: Method!
    private var headers: [(key: Header, value: Value)] = []
    
    public func set(method: Method) {
        self.method = method
    }
    
    public func add(header key: Header, with value: Value) {
        if let index = headers.firstIndex(where: { $0.key == key }) {
            headers[index] = (key, value)
        } else {
            headers.append((key, value))
        }
    }
    
    public func format() -> String {
        var output = "\(method.rawValue)\r\n"
        for kv in headers {
            output.append("\(kv.key.rawValue): \(value(kv.value))\r\n")
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
        case .man(let value): return from(man: value)
        case .mx(let value): return from(mx: value)
        case .st(let value): return from(st: value)
        }
    }
    
    fileprivate func from(nt: Value.NT) -> String {
        switch nt {
        case .urn(let domain, let device, let type, let version):
            return "urn:\(domain):\(device):\(type):\(version)"
        case .ssdp(let ssdp):
            return "ssdp:\(ssdp.rawValue)"
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
}
