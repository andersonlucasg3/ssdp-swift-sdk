import Socket

public struct Address {
    public let host: String
    public let port: UInt16
    
    public init(host: String, port: UInt16) {
        self.host = host
        self.port = port
    }
    
    public func toAddr() -> Socket.Address {
        return Socket.createAddress(for: host, on: Int32(port))!
    }
    
    static func from(addr: Socket.Address) -> Address {
        let (host, port) = Socket.hostnameAndPort(from: addr)!
        return .init(host: host, port: UInt16(port))
    }
}
