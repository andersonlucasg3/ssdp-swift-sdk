class NotifyRequest: Request {
//    override var shouldHandleResponses: Bool { return false }
    
    weak var delegate: NotifyDelegateProtocol?
    
    override func requestBody(headers: Headers) throws -> String {
        guard let host = headers[.host]?.rawValue else { throw RequestError.missing(header: .host) }
        guard let cc = headers[.cacheControl]?.rawValue else { throw RequestError.missing(header: .cacheControl) }
        guard let loc = headers[.location]?.rawValue else { throw RequestError.missing(header: .location) }
        guard let nt = headers[.nt]?.rawValue else { throw RequestError.missing(header: .nt) }
        guard let nts = headers[.nts]?.rawValue else { throw RequestError.missing(header: .nts) }
        guard let server = headers[.server]?.rawValue else { throw RequestError.missing(header: .server) }
        guard let usn = headers[.usn]?.rawValue else { throw RequestError.missing(header: .usn) }
        
        return "NOTIFY * HTTP/1.1\r\n"
            .appending("HOST:\(host)\r\n")
            .appending("CACHE-CONTROL:\(cc)\r\n")
            .appending("LOCATION:\(loc)\r\n")
            .appending("NT:\(nt)\r\n")
            .appending("NTS:\(nts)\r\n")
            .appending("SERVER:\(server)\r\n")
            .appending("USN:\(usn)\r\n\r\n")
    }
    
    override func received(response: String, from host: String) throws {
        Log.debug(message: "Response: \(response) \n From: \(host)")
    }
}
