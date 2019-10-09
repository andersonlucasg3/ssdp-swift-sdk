enum HeaderKeys: String {
    case notify = "NOTIFY"
    case host = "HOST"
    case nt = "NT"
    case nts = "NTS"
    case location = "LOCATION"
    case usn = "USN"
    case cacheControl = "CACHE-CONTROL"
    case al = "AL"
    case server = "SERVER"
}

typealias Headers = [HeaderKeys: String]
