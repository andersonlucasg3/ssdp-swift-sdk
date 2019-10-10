import struct Foundation.Data

public class SearchSender: Sender<SearchListener> {
    fileprivate var nt: Value.NT!
    fileprivate var ssdp: Value.SSDP!
    
    internal init() {
        super.init()
    }
    
    public override func requestBody() -> MessageBody {
        let body = MessageBody.init()
        
        body.set(method: .mSearch)
        body.add(header: .host, with: .host(value: .address))
        body.add(header: .man, with: .man(value: .ssdp(ssdp: .discover)))
        body.add(header: .mx, with: .mx(value: .delay(seconds: 3)))
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
        
        public func build() -> SearchSender {
            return request
        }
    }
    
    enum RTU {
        case search(nt: Value.NT)
        
        public func build() -> SearchSender {
            switch self {
            case .search(let nt):
                return Builder()
                    .set(nt: nt)
                    .build()
            }
        }
    }
}
