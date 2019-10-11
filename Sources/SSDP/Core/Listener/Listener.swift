import Dispatch
import struct Foundation.Data
import struct Foundation.Date
import struct Foundation.TimeInterval
import Socket
import Darwin
import Darwin.net

public protocol ListenerDelegate: class {
    func didReceiveMessage(body: MessageBody, from addr: Address)
}

open class Listener: NSObject {
    fileprivate(set) internal var socket: Socket?
    fileprivate var buffer = Data.init()
    fileprivate let delimiterData = "\r\n\r\n".data(using: .ascii)!
        
    public weak var delegate: ListenerDelegate?
    
    public required override init() { super.init() }
    
    func listen(addr: Address) throws {
        guard socket == nil else { return }
                
        try createSocket()
        
        guard let socket = socket else { return }
        
        Log.debug(message: "\(#function) port: \(addr.port), and ip: \(addr.host)")
        
        var mreq: ip_mreq = .init()
        mreq.imr_multiaddr.s_addr = inet_addr(addr.host)
        mreq.imr_interface.s_addr = INADDR_ANY.byteSwapped
        if setsockopt(
            socket.socketfd,
            IPPROTO_IP,
            IP_ADD_MEMBERSHIP,
            &mreq,
            socklen_t.init(MemoryLayout<ip_mreq>.size)) < 0 {
            throw Error.alreadyRequesting
        }
        
        try socket.listen(on: Int(addr.port))
        
        startReading()
    }
    
    func send(data: Data, to addr: Address) throws {
        try socket?.write(from: data, to: addr.toAddr())
    }
    
    func received(response: Data, from addr: Address) throws -> Bool {
        throw Error.notImplemented(name: #function)
    }
    
    public func stop() {
        socket?.close()
        socket = nil
    }
    
    fileprivate func startReading() {
        DispatchQueue.init(label: "Background reading", qos: .background, target: .global()).async { [weak self] in
            guard let self = self else { return }
            repeat {
                do {
                    var data = Data.init()
                    guard let (count, addr) = try self.socket?.readDatagram(into: &data)
                        else { continue }
                    
                    if let addr = addr, count > 0 {
                        self.buffer.append(data)
                        
                        self.read(from: .from(addr: addr))
                    }
                } catch let error as Socket.Error {
                    if error.errorCode == Socket.SOCKET_ERR_BAD_DESCRIPTOR {
                        self.stop()
                        try? self.createSocket()
                    }
                } catch {
                    print("Unknown error trying to read socket: \(error)")
                }
                
                sleep(100)
            } while self.socket != nil
        }
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
        } while buffer.count > 0 && socket != nil
    }
    
    fileprivate func createSocket() throws {
        socket = try .create(family: .inet, type: .datagram, proto: .udp)
        try socket?.setBlocking(mode: false)
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
