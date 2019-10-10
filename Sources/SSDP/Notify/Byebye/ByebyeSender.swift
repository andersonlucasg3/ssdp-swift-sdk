import struct Foundation.Data

public class ByebyeSender: Sender {
    fileprivate var nt: Value.NT!
    fileprivate var uuid: String!
        
    internal init() { super.init(sendCount: 1) }
    
    public override func requestBody() throws -> Data {
        let formatter = SenderBody.init()
        
        formatter.set(method: .notify)
        formatter.add(header: .host, with: .host(value: .address))
        formatter.add(header: .nt, with: .nt(value: nt))
        formatter.add(header: .nts, with: .nts(value: .sspd(value: .byebye)))
        formatter.add(header: .usn, with: .usn(value: .uuid(uuid: uuid)))
        
        let formatted = formatter.build()
        
        Log.debug(message: "Sending request \n\(formatted)")
        
        return formatted.data(using: .utf8)!
    }
}

public extension ByebyeSender {
    class Builder {
        private var request: ByebyeSender
        
        public init() {
            request = .init()
        }
        
        public func set(nt: Value.NT) -> Builder { request.nt = nt; return self }
        public func set(uuid: String) -> Builder { request.uuid = uuid; return self }
        
        public func build() -> ByebyeSender {
            return request
        }
    }
    
    enum RTU {
        case byebye(nt: Value.NT, uuid: String)
        
        public func build() -> ByebyeSender {
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
