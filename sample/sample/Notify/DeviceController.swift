import SSDP
import Foundation

class DeviceController: ListenerDelegate {
    fileprivate static let ip = getAddress(for: .wifi) ?? getAddress(for: .cellular) ?? "0.0.0.0:0"
    
    fileprivate let myUuid = UUID.init().uuidString
    fileprivate let urn = Value.NT.urn(domain: "receiver-tvos-globo-com", type: "appletv", version: 1)
    fileprivate let location = "ws://\(ip)/receiver"
    
    fileprivate var aliveSender: AliveSender?
    fileprivate var searchRequest: SearchSender?
    fileprivate var searchListener: SearchListener?
    
    init() { }
    
    func notify() {
        if aliveSender == nil {
            let alive = AliveSender.RTU.self
            
            aliveSender = alive.alive(location: location,
                                       nt: urn,
                                       usn: .nt(uuid: myUuid, nt: urn),
                                       uuid: myUuid,
                                       duration: 10,
                                       server: .this).build()
            
            aliveSender?.listenerDelegate = self
            aliveSender?.listen(addr: .init(host: Host.ip, port: Host.port))
        }
        
        aliveSender?.send()
    }
    
    func search() {
        searchRequest?.stop()
        searchListener?.stop()
        
        searchRequest = SearchSender.Builder.init()
            .set(nt: .ssdp(ssdp: .all))
            .build()
        
        searchRequest?.listenerDelegate = self
        searchRequest?.listen(addr: .init(host: Host.ip, port: 0))
        
        searchListener = .init()
        searchListener?.delegate = self
        searchListener?.listen(on: Host.port, and: Host.ip)
        
        searchRequest?.send()
    }
    
    func stopSearch() {
        
    }
    
    // MARK: - ListenerDelegate
    
    func didReceiveMessage(body: MessageBody, from host: String) {
        switch body.method! {
        case .notify:
            print("Received notify from: \(host)")
        case .mSearch:
            let rtu = SearchResponseSender.RTU.self
            let responder = rtu.response(duration: 120,
                                         location: location,
                                         st: .nt(nt: urn),
                                         usn: .nt(uuid: myUuid, nt: urn)).build()
            responder.send(host: host, port: Host.port)
        case .httpOk:
            print("Received http ok from: \(host)")
        }
    }
}
