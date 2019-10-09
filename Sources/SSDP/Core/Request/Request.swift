import Socket
import Dispatch
import struct Foundation.TimeInterval
import struct Foundation.Date
import struct Foundation.Data

open class Request {
    fileprivate let responsesDuration: TimeInterval = 10 // seconds
    
    fileprivate var socket: Socket?
    fileprivate var startTime: TimeInterval = 0
    
    open var shouldHandleResponses: Bool { return true }
    
    public init() { }
    
    public func request() throws {
        guard socket == nil else { throw RequestError.alreadyRequesting }
        
        try createSocket()
        
        try socket?.listen(on: 0)
        
        guard let port = Int32(Host.port.rawValue) else { throw RequestError.invalidPort(value: Host.port.rawValue) }
        guard let address = Socket.createAddress(for: Host.ip.rawValue, on: port) else { throw RequestError.invalidIP(value: Host.ip.rawValue) }
        
        let body = try requestBody()
        
        // TODO: handle possibility to write partial data
        try socket?.write(from: body, to: address)
        
        startTime = Date.init().timeIntervalSince1970
        
        guard shouldHandleResponses else { return }
        
        readReponse()
    }
    
    open func requestBody() throws -> Data {
        throw RequestError.notImplemented(name: #function)
    }
    
    open func received(response: String, from host: String) throws {
        throw RequestError.notImplemented(name: #function)
    }
    
    fileprivate func createSocket() throws {
        socket = try .create(family: .inet, type: .datagram, proto: .udp)
        try socket?.setBlocking(mode: false)
        socket?.readBufferSize = 1024 * 10
    }
    
    fileprivate func readReponse() {
        DispatchQueue.init(label: "com.response.listening", qos: .background).async { [weak self] in
            guard let self = self else { return }
            
            var currentTime: TimeInterval
            repeat {
                
                self.read()
                
                currentTime = Date().timeIntervalSince1970 - self.startTime
                                
            } while currentTime < self.responsesDuration
            
            self.socket?.close()
            self.socket = nil
        }
    }
    
    fileprivate func read() {
        do {
            var data = Data.init()
            let (bytesRead, address) = try self.socket!.readDatagram(into: &data)
            
            if bytesRead > 0 {
                guard let response = String.init(data: data, encoding: .utf8) else {
                    throw RequestError.invalidRepsonse(data: data)
                }
                let (remoteHost, _) = Socket.hostnameAndPort(from: address!)!
                Log.debug(message: "Received \n \(response) \n from \(remoteHost)")
                try received(response: response, from: remoteHost)
            }
        } catch {
            Log.debug(message: "Shitty error: \(error)")
        }
    }
}
