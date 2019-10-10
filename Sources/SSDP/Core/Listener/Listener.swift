import Dispatch
import struct Foundation.Data
import struct Foundation.Date
import struct Foundation.TimeInterval
import Socket

open class Listener: NSObject {
    fileprivate(set) internal var socket: SSDPSocketListener?
        
    public required override init() { super.init() }
    
    func listen(on port: UInt16, and interface: String = "0.0.0.0") {
        guard socket == nil else { return }
                
        createSocket(port, interface)
        
        Log.debug(message: "\(#function) port: \(port), and ip: \(String.init(describing: interface))")
        
        socket?.open()
    }
    
    func received(response: String, from host: String) throws {
        throw Error.notImplemented(name: #function)
    }
    
    public func stop() {
        socket?.close()
        socket = nil
    }
        
    fileprivate func read(data: Data, from addr: Address) {
        guard let response = String.init(data: data, encoding: .utf8) else {
            Log.debug(message: "Received data is not string...")
            return
        }
        Log.debug(message: "Received \n \(response) \n from \(addr.host)")
        try! received(response: response, from: addr.host)
    }
    
    fileprivate func createSocket(_ port: UInt16, _ host: String) {
        socket = SSDPSocketListener.init(address: host, andPort: Int(port))
        socket?.delegate = self
    }
}

extension Listener: SocketListenerDelegate {
    public func socket(_ aSocket: SSDPSocketListener!, didReceive aData: Data!, fromAddress anAddress: String!) {
        read(data: aData, from: .init(host: anAddress, port: 0))
    }
    
    public func socket(_ aSocket: SSDPSocketListener!, didEncounterError anError: Swift.Error!) {
        
    }
}
