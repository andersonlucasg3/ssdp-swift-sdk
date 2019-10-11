import struct Foundation.Data

enum Error: Swift.Error {
    case missing(header: Header)
    case notImplemented(name: String)
    case invalidPort(value: Int)
    case invalidIP(value: String)
    case invalidRepsonse(data: Data)
    case alreadyRequesting
    case noIpAvailable
    case sockOptMulticastError
}
