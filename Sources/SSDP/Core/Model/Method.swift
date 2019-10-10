public enum Method: RawRepresentable {
    case notify
    case mSearch
    case httpOk
    
    public var rawValue: String {
        switch self {
        case .notify: return "NOTIFY"
        case .mSearch: return "M-SEARCH"
        case .httpOk: return "HTTP/1.1 200 OK"
        }
    }
    
    public init?(rawValue: String) {
        if rawValue == "NOTIFY" { self = Method.notify }
        else if rawValue == "M-SEARCH" { self = Method.mSearch }
        else if rawValue == "HTTP/1.1" { self = Method.httpOk }
        else { return nil }
    }
}
