import struct Foundation.Data

public class SearchRequest: Request {
    fileprivate var nt: Value.NT!
    fileprivate var ssdp: Value.SSDP!
    
    public override var shouldHandleResponses: Bool { return true }
    
    public override func requestBody() throws -> Data {
        let formatter = RequestBodyFormatter.init()
        
        formatter.set(method: .mSearch)
        formatter.add(header: .host, with: .host(value: .address))
        formatter.add(header: .man, with: .man(value: .ssdp(ssdp: .discover)))
        formatter.add(header: .mx, with: .mx(value: .delay(seconds: 3)))
        if let ssdp = ssdp { formatter.add(header: .st, with: .st(value: .ssdp(ssdp: ssdp))) }
        else { formatter.add(header: .st, with: .st(value: .nt(nt: nt))) }
        
        let formatted = formatter.format()
        
        Log.debug(message: "Sending request \n\(formatted)")
        
        return formatted.data(using: .utf8)!
    }
    
    public override func received(response: String, from host: String) throws {
        // TODO: implement
    }
}

public extension SearchRequest {
    class Builder {
        private var request: SearchRequest
        
        public init() { request = .init() }
        
        public func set(nt: Value.NT) -> Builder { request.nt = nt; return self }
        public func set(ssdp: Value.SSDP) -> Builder { request.ssdp = ssdp; return self }
        
        public func build() -> SearchRequest {
            return request
        }
        
        public enum RTU {
            case search(nt: Value.NT)
            
            public func build() -> SearchRequest {
                switch self {
                case .search(let nt):
                    return Builder()
                        .set(nt: nt)
                        .build()
                }
            }
        }
    }
}
