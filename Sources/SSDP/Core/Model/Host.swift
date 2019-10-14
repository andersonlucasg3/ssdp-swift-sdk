public enum Host: RawRepresentable {
    public static let ip = "239.255.255.250"
    public static let port: UInt16 = 1900
    
    case address
    case custom(address: String)
    
    public var rawValue: String {
        switch self {
        case .address: return "239.255.255.250:1900"
        case .custom(let address): return address
        }
    }
    
    public init?(rawValue: String) {
        return nil
    }
}
