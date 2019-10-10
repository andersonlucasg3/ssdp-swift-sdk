import Socket
import Dispatch
import struct Foundation.Data
import struct Foundation.Date
import struct Foundation.TimeInterval

open class Listener {
    fileprivate var socket: Socket?
        
    public init() throws {
        try createSocket()
    }
    
    func listen(on port: Int) throws {
        Log.debug(message: "\(#function) port: \(port)")
        
        try socket?.listen(on: port)
        
        readResponse()
    }
    
    func stop() {
        close()
    }
    
    func received(response: String, from host: String) throws {
        throw Error.notImplemented(name: #function)
    }
    
    fileprivate func createSocket() throws {
        socket = try .create(family: .inet, type: .datagram, proto: .udp)
        try socket?.setBlocking(mode: false)
        socket?.readBufferSize = 1024 * 10
    }
    
    fileprivate func readResponse() {
        Log.debug(message: "\(#function) launching background reading...")
        DispatchQueue.init(label: "com.response.listening", qos: .background, target: .global()).async { [weak self] in
            guard let self = self else { return }
            
            repeat {
                self.read()
            } while self.socket != nil
            
            Log.debug(message: "Finished trying do read data...")
            
            self.close()
        }
    }
    
    fileprivate func read() {
        do {
            var data = Data.init()
            let (bytesRead, address) = try self.socket!.readDatagram(into: &data)
            
            if bytesRead > 0 {
                guard let response = String.init(data: data, encoding: .utf8) else {
                    throw Error.invalidRepsonse(data: data)
                }
                let (remoteHost, _) = Socket.hostnameAndPort(from: address!)!
                Log.debug(message: "Received \n \(response) \n from \(remoteHost)")
                try received(response: response, from: remoteHost)
            }
        } catch {
            Log.debug(message: "Shitty error: \(error)")
        }
    }
    
    fileprivate func close() {
        socket?.close()
        socket = nil
    }
}
