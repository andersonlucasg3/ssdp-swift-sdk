import Dispatch
import struct Foundation.TimeInterval
import struct Foundation.Date
import struct Foundation.Data

open class Sender<ListenerType> where ListenerType: Listener {
    fileprivate var listener: ListenerType
    
    public weak var listenerDelegate: ListenerDelegate? {
        get { return listener.delegate }
        set { listener.delegate = newValue }
    }
    
    internal init() {
        listener = .init()
    }
    
    func send(addr: Address, body: MessageBody) throws {
        Log.debug(message: "Sender on address: \(addr.host):\(addr.port)")
        
        let body = body.build()
        
        Log.debug(message: "Sending request \n\(String.init(data: body, encoding: .ascii) ?? "")")
        
        try send(data: body, to: addr)
    }
    
    func listen(addr: Address) throws {
        try listener.listen(addr: addr)
    }
    
    func localIP() throws -> String {
        guard let address = getAddress(for: .wifi) ??
                            getAddress(for: .ethernet) ??
                            getAddress(for: .cellular)
        else { throw Error.noIpAvailable }
        return address
    }
    
    public func stop() {
        listener.stop()
    }
    
    fileprivate func send(data: Data, to addr: Address) throws {
        try listener.send(data: data, to: addr)
    }
}
