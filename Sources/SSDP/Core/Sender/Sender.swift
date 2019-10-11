import Dispatch
import struct Foundation.TimeInterval
import struct Foundation.Date
import struct Foundation.Data
import CocoaAsyncSocket

open class Sender<ListenerType> where ListenerType: Listener {
    fileprivate var listener: ListenerType
    
    public weak var listenerDelegate: ListenerDelegate? {
        get { return listener.delegate }
        set { listener.delegate = newValue }
    }
    
    internal init() {
        listener = .init()
    }
    
    func send(addr: Address, body: MessageBody) {
        Log.debug(message: "Sender on address: \(addr.host):\(addr.port)")
        
        let body = body.build()
        
        Log.debug(message: "Sending request \n\(String.init(data: body, encoding: .ascii) ?? "")")
        
        send(data: body, to: addr)
    }
    
    func listen(addr: Address) throws {
        try listener.listen(addr: addr)
    }
    
    public func stop() {
        listener.stop()
    }
    
    fileprivate func send(data: Data, to addr: Address) {
        listener.socket?.send(data, toHost: addr.host, port: addr.port, withTimeout: -1, tag: 1)
    }
}
