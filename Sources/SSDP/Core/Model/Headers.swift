public enum Header: String {
    case host = "HOST"
    case nt = "NT"
    case nts = "NTS"
    case location = "LOCATION"
    case usn = "USN"
    case cacheControl = "CACHE-CONTROL"
    case server = "SERVER"
}

public typealias Headers = [Header: Value]
