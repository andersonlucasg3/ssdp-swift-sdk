public enum Method: RawRepresentable {
    case notify
    case mSearch
    case httpOk(method: String, status: Int)
    
    public var rawValue: String {
        switch self {
        case .notify: return "NOTIFY * HTTP/1.1"
        case .mSearch: return "M-SEARCH * HTTP/1.1"
        case .httpOk(let method, let status):
            return "\(method) \(status)"
        }
    }
    
    public init?(rawValue: String) {
        if rawValue == "NOTIFY" { self = Method.notify }
        else if rawValue == "M-SEARCH" { self = Method.mSearch }
        else if rawValue.hasPrefix("HTTP/1.1") && rawValue.contains("200") { self = Method.httpOk(method: "HTTP/1.1", status: 200) }
        else { return nil }
    }
}
