import struct Foundation.Data

enum RequestError: Error {
    case missing(header: Header)
    case notImplemented(name: String)
    case invalidPort(value: String)
    case invalidIP(value: String)
    case invalidRepsonse(data: Data)
    case alreadyRequesting
}
