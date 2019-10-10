import Socket
import Dispatch
import struct Foundation.TimeInterval
import struct Foundation.Date
import struct Foundation.Data

open class Sender {
    fileprivate var socket: Socket?
    fileprivate var sendCount: Int
    
    internal init(sendCount: Int) {
        self.sendCount = sendCount
    }
    
    public func send(completion: @escaping os_block_t = {}) throws {
        guard socket == nil else { throw Error.alreadyRequesting }
        
        try createSocket()
        
        let port = Int32(Host.port)
        guard let address = Socket.createAddress(for: Host.ip.rawValue, on: port) else { throw Error.invalidIP(value: Host.ip.rawValue) }
        
        Log.debug(message: "Sender on address: \(Host.ip.rawValue):\(Host.port)")
        Log.debug(message: "Sender count: \(sendCount)")
        
        let body = try requestBody()
        
        multipleShots(body: body, to: address) { [weak self] in
            guard let self = self else { return }
            
            completion()
                
            self.close()
        }
    }
    
    fileprivate func close() {
        socket?.close()
        socket = nil
    }
    
    fileprivate func multipleShots(body: Data, to address: Socket.Address, completion: @escaping os_block_t) {
        let sendBlock = { [weak self] in
            // TODO: handle possibility to write partial data
            _ = try? self?.socket?.write(from: body, to: address)
        }
        
        sendBlock()
        
        let sendCount = self.sendCount
        (1..<sendCount).forEach { (index) in
            DispatchQueue.main.asyncAfter(deadline: .now() + TimeInterval(index)) {
                sendBlock()
                
                if index == sendCount - 1 {
                    DispatchQueue.main.async(execute: completion)
                }
            }
        }
    }
    
    open func requestBody() throws -> Data {
        throw Error.notImplemented(name: #function)
    }
    
    fileprivate func createSocket() throws {
        socket = try .create(type: .datagram, proto: .udp)
        try socket?.setBlocking(mode: false)
    }
}
