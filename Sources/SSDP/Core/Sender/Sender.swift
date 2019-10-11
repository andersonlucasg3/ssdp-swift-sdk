import Dispatch
import struct Foundation.TimeInterval
import struct Foundation.Date
import struct Foundation.Data
import CocoaAsyncSocket

open class Sender<ListenerType> where ListenerType: Listener {
    fileprivate var listener: ListenerType
    
    fileprivate var sendCount: Int
    
    public weak var listenerDelegate: ListenerDelegate? {
        get { return listener.delegate }
        set { listener.delegate = newValue }
    }
    
    internal init(sendCount: Int = 1) {
        listener = .init()
        self.sendCount = sendCount
    }
    
    func send(addr: Address, body: MessageBody) {
        Log.debug(message: "Sender on address: \(addr.host):\(addr.port)")
        Log.debug(message: "Sender count: \(sendCount)")
        
        let body = body.build()
        
        Log.debug(message: "Sending request \n\(String.init(data: body, encoding: .ascii) ?? "")")
        
        let data = body
        multipleShots(body: data, to: addr)
    }
    
    func listen(addr: Address) throws {
        try listener.listen(addr: addr)
    }
    
    public func stop() {
        listener.stop()
    }
    
    fileprivate func multipleShots(body: Data, to address: Address) {
        (1..<sendCount).forEach { _ in
            send(data: body, to: address)
        }
        
        send(data: body, to: address)
    }
    
    fileprivate func send(data: Data, to addr: Address) {
        let addrData = GCDAsyncUdpSocket.convert(host: addr.host, port: addr.port)
        listener.socket?.send(data, toAddress: addrData, withTimeout: 10, tag: 1)
    }
}
