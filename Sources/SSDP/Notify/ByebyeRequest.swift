import struct Foundation.Data

public class ByebyeRequest: Request {
    fileprivate var nt: Value.NT!
    fileprivate var uuid: String!
    
    public override func requestBody() throws -> Data {
        let formatter = RequestBodyFormatter.init()
        
        formatter.set(method: .notify)
        formatter.add(header: .host, with: .host(value: .address))
        formatter.add(header: .nt, with: .nt(value: nt))
        formatter.add(header: .nts, with: .nts(value: .sspd(value: .byebye)))
        formatter.add(header: .usn, with: .usn(value: .uuid(uuid: uuid)))
        
        let formatted = formatter.format()
        
        Log.debug(message: "Sending request \n\(formatted)")
        
        return formatted.data(using: .utf8)!
    }
    
    public override func received(response: String, from host: String) throws {
        // TODO: implement response handling
    }
}

public extension ByebyeRequest {
    class Builder {
        private var request: ByebyeRequest
        
        public init() {
            request = .init()
        }
        
        public func set(nt: Value.NT) -> Builder { request.nt = nt; return self }
        public func set(uuid: String) -> Builder { request.uuid = uuid; return self }
        
        public func build() -> ByebyeRequest {
            return request
        }
    }
    
    enum RTU {
        case byebye(nt: Value.NT, uuid: String)
        
        public func build() -> ByebyeRequest {
            switch self {
            case .byebye(let nt, let uuid):
                return Builder()
                    .set(nt: nt)
                    .set(uuid: uuid)
                    .build()
            }
        }
    }
}
