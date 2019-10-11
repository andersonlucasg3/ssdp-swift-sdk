import Dispatch
import struct Foundation.Data
import struct Foundation.Date
import struct Foundation.TimeInterval
import Socket

public protocol ListenerDelegate: class {
    func didReceiveMessage(body: MessageBody, from addr: Address)
}

open class Listener: NSObject {
    fileprivate(set) internal var socket: SocketListener?
    fileprivate var buffer = Data.init()
    fileprivate let delimiterData = "\r\n\r\n".data(using: .utf8)!
        
    public weak var delegate: ListenerDelegate?
    
    public required override init() { super.init() }
    
    func listen(addr: Address) {
        guard socket == nil else { return }
                
        createSocket(addr.port, addr.host)
        
        Log.debug(message: "\(#function) port: \(addr.port), and ip: \(addr.host)")
        
        socket?.open()
    }
    
    func received(response: Data, from addr: Address) throws {
        throw Error.notImplemented(name: #function)
    }
    
    public func stop() {
        socket?.close()
        socket = nil
    }
        
    fileprivate func read(data: Data, from addr: Address) {
        if let bufferDelimiterRange = self.checkForDelimiter(in: buffer) {
            let packageData = self.packageData(from: bufferDelimiterRange)
            
            self.sliceBuffer(for: bufferDelimiterRange)
            
            try! received(response: packageData, from: addr)
        }
    }
    
    fileprivate func createSocket(_ port: UInt16, _ host: String) {
        socket = SocketListener.init(address: host, andPort: Int(port))
        socket?.delegate = self
    }
    
    fileprivate func checkForDelimiter(in data: Data) -> Range<Int>? {
        return data.range(of: delimiterData)
    }
    
    fileprivate func packageRange(from delimiter: Range<Int>) -> Range<Int> {
        return 0..<delimiter.endIndex
    }
    
    fileprivate func packageData(from delimiter: Range<Int>) -> Data {
        return buffer.subdata(in: packageRange(from: delimiter))
    }

    fileprivate func sliceBuffer(for delimiter: Range<Int>) {
        buffer = buffer.subdata(in: delimiter.endIndex..<buffer.count)
    }

}

extension Listener: SocketListenerDelegate {
    public func socket(_ aSocket: SocketListener!, didReceive aData: Data!, fromAddress anAddress: String!, andPort port: UInt) {
        buffer.append(aData)
        read(data: buffer, from: .init(host: anAddress, port: 0))
    }
    
    public func socket(_ aSocket: SocketListener!, didEncounterError anError: Swift.Error!) {
        // TODO: check for errors
    }
}
