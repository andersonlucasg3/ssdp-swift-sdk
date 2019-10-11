import Dispatch
import struct Foundation.Data
import struct Foundation.Date
import struct Foundation.TimeInterval
import CocoaAsyncSocket

public protocol ListenerDelegate: class {
    func didReceiveMessage(body: MessageBody, from addr: Address)
}

open class Listener: NSObject {
    fileprivate(set) internal var socket: GCDAsyncUdpSocket?
    fileprivate var buffer = Data.init()
    fileprivate let delimiterData = "\r\n\r\n".data(using: .ascii)!
        
    public weak var delegate: ListenerDelegate?
    
    public required override init() { super.init() }
    
    func listen(addr: Address) throws {
        guard socket == nil else { return }
                
        try createSocket()
        
        Log.debug(message: "\(#function) port: \(addr.port), and ip: \(addr.host)")
        
        try socket?.beginReceiving()
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
    
    fileprivate func createSocket() throws {
        socket = GCDAsyncUdpSocket.init(delegate: self, delegateQueue: .main)
        try socket?.enableBroadcast(true)
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

extension Listener: GCDAsyncUdpSocketDelegate {
    public func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data,
                          fromAddress address: Data, withFilterContext filterContext: Any?) {
        buffer.append(data)
        
        let host = GCDAsyncUdpSocket.host(fromAddress: address)
        let port = GCDAsyncUdpSocket.port(fromAddress: address)
        read(from: .init(host: host!, port: port))
    }
    
    public func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Swift.Error?) {
        print(error)
    }
    
    public func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        
    }
    
    public func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Swift.Error?) {
        print(error)
    }
    
    public func udpSocket(_ sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: Swift.Error?) {
        print(error)
    }
}
