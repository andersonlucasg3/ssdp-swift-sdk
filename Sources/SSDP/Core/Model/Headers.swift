public enum Header: String {
    case host = "HOST"
    case nt = "NT"
    case nts = "NTS"
    case location = "LOCATION"
    case usn = "USN"
    case cacheControl = "CACHE-CONTROL"
    case server = "SERVER"
    case man = "MAN"
    case mx = "MX"
    case st = "ST"
}

public typealias Headers = [Header: Value]
