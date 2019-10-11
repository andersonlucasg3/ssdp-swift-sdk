import struct Foundation.Data

public class SearchSender: Sender<SearchListener> {
    fileprivate var nt: Value.NT!
    fileprivate var ssdp: Value.SSDP!
    fileprivate var delay: Int = 120
    
    internal init() {
        super.init(sendCount: 5)
    }
    
    public func send() {
        send(addr: .init(host: Host.ip, port: Host.port), body: requestBody())
    }
    
    public func listen() {
        listen(addr: .init(host: Host.ip, port: Host.port))
    }
    
    private func requestBody() -> MessageBody {
        let body = MessageBody.init()
        
        body.set(method: .mSearch)
        body.add(header: .host, with: .host(value: .address))
        body.add(header: .man, with: .man(value: .ssdp(ssdp: .discover)))
        body.add(header: .mx, with: .mx(value: .delay(seconds: delay)))
        body.add(header: .userAgent, with: .userAgent(value: .this))
        if let ssdp = ssdp { body.add(header: .st, with: .st(value: .ssdp(ssdp: ssdp))) }
        else { body.add(header: .st, with: .st(value: .nt(nt: nt))) }
        
        return body
    }
}

public extension SearchSender {
    class Builder {
        private var request: SearchSender
        
        public init() { request = .init() }
        
        public func set(nt: Value.NT) -> Builder { request.nt = nt; return self }
        public func set(ssdp: Value.SSDP) -> Builder { request.ssdp = ssdp; return self }
        public func set(delay: Int) -> Builder { request.delay = delay; return self }
        
        public func build() -> SearchSender {
            return request
        }
    }
    
    enum RTU {
        case search(nt: Value.NT, delay: Int)
        case searchAll(delay: Int)
        
        public func build() -> SearchSender {
            switch self {
            case .search(let nt, let delay):
                return Builder()
                    .set(nt: nt)
                    .set(delay: delay)
                    .build()
            case .searchAll(let delay):
                return Builder()
                    .set(ssdp: .all)
                    .set(delay: delay)
                    .build()
            }
        }
    }
}
