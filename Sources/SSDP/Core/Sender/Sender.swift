import Dispatch
import struct Foundation.TimeInterval
import struct Foundation.Date
import struct Foundation.Data
import Socket

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
    
    public func send(host: String = Host.ip, port: UInt16 = Host.port) {
        let addr = Address.init(host: host, port: port)
        
        Log.debug(message: "Sender on address: \(addr.host):\(addr.port)")
        Log.debug(message: "Sender count: \(sendCount)")
        
        let senderBody = requestBody()
        
        let body = senderBody.build()
        
        Log.debug(message: "Sending request \n\(String.init(data: body, encoding: .utf8) ?? "")")
        
        let data = body
        multipleShots(body: data, to: addr)
    }
    
    public func listen(addr: Address) {
        listener.listen(on: addr.port, and: addr.host)
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
        listener.socket?.send(data, toAddress: addr.host, andPort: UInt(addr.port))
    }
    
    open func requestBody() -> MessageBody { return .init() }
}
