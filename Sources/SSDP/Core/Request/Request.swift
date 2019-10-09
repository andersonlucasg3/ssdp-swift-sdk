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
        
        Log.debug(message: "Request on address: \(Host.ip.rawValue):\(Host.port.rawValue)")
        
        let body = try requestBody()
        
        multipleShots(body: body, to: address) { [weak self] in
            guard let self = self else { return }
            
            self.startTime = Date.init().timeIntervalSince1970
            
            guard self.shouldHandleResponses else { return }
            
            self.readReponse()
        }
    }
    
    fileprivate func multipleShots(body: Data, to address: Socket.Address, completion: @escaping os_block_t) {
        let sendBlock = { [weak self] in
            // TODO: handle possibility to write partial data
            _ = try? self?.socket?.write(from: body, to: address)
        }
        
        sendBlock()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            sendBlock()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                sendBlock()
                
                DispatchQueue.main.async(execute: completion)
            }
        }
    }
    
    open func requestBody() throws -> Data {
        throw RequestError.notImplemented(name: #function)
    }
    
    open func received(response: String, from host: String) throws {
        throw RequestError.notImplemented(name: #function)
    }
    
    fileprivate func createSocket() throws {
        socket = try .create(type: .datagram, proto: .udp)
        try socket?.setBlocking(mode: false)
        socket?.readBufferSize = 1024 * 10
    }
    
    fileprivate func readReponse() {
        DispatchQueue.init(label: "com.response.listening", qos: .background, target: .global()).async { [weak self] in
            guard let self = self else { return }
            
            var currentTime: TimeInterval
            repeat {
                
                self.read()
                
                currentTime = Date().timeIntervalSince1970 - self.startTime
                                
            } while currentTime < self.responsesDuration
            
            Log.debug(message: "Finished trying do read data...")
            
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
