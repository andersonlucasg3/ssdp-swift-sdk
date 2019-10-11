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
    fileprivate let delimiterData = "\r\n\r\n".data(using: .ascii)!
        
    public weak var delegate: ListenerDelegate?
    
    public required override init() { super.init() }
    
    func listen(addr: Address) {
        guard socket == nil else { return }
                
        createSocket(addr.port, addr.host)
        
        Log.debug(message: "\(#function) port: \(addr.port), and ip: \(addr.host)")
        
        socket?.open()
    }
    
    func received(response: Data, from addr: Address) throws -> Bool {
        throw Error.notImplemented(name: #function)
    }
    
    public func stop() {
        socket?.close()
        socket = nil
    }
        
    fileprivate func read(from addr: Address) {
        repeat {
            if let bufferDelimiterRange = self.checkForDelimiter() {
                let packageData = self.packageData(from: bufferDelimiterRange)
                
                self.sliceBuffer(for: bufferDelimiterRange)
                
                if try! !received(response: packageData, from: addr) {
                    break
                }
            } else {
                break
            }
        } while buffer.count > 0
    }
    
    fileprivate func createSocket(_ port: UInt16, _ host: String) {
        socket = SocketListener.init(address: host, andPort: Int(port))
        socket?.delegate = self
    }
    
    fileprivate func checkForDelimiter() -> Range<Int>? {
        return buffer.range(of: delimiterData)
    }
    
    fileprivate func packageRange(from delimiter: Range<Int>) -> Range<Int> {
        return 0..<delimiter.endIndex
    }
    
    fileprivate func packageData(from delimiter: Range<Int>) -> Data {
        let range = packageRange(from: delimiter)
        return buffer.subdata(in: range)
    }

    fileprivate func sliceBuffer(for delimiter: Range<Int>) {
        let range = delimiter.endIndex..<buffer.count
        buffer = buffer.subdata(in: range)
    }

}

extension Listener: SocketListenerDelegate {
    public func socket(_ aSocket: SocketListener!, didReceive aData: Data!, fromAddress anAddress: String!, andPort port: UInt) {
        buffer.append(aData)
        read(from: .init(host: anAddress, port: UInt16(port)))
    }
    
    public func socket(_ aSocket: SocketListener!, didEncounterError anError: Swift.Error!) {
        guard let error = anError else { return }
        Log.debug(message: "Socket error: \(error)")
    }
}
