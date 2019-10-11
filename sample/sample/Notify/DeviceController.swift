import SSDP
import Foundation

class DeviceController: ListenerDelegate {
    fileprivate static let ip = getAddress(for: .wifi) ?? getAddress(for: .cellular) ?? "0.0.0.0:0"
    
    fileprivate let myUuid = UUID.init().uuidString
    fileprivate let urn = Value.NT.urn(domain: "com-globo-play-receiver", type: "appletv", version: 1)
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
        if searchRequest == nil {
            searchRequest = SearchSender.Builder.init()
                .set(nt: .ssdp(ssdp: .all))
                .build()
            
            searchRequest?.listenerDelegate = self
            searchRequest?.listen()
            
            searchListener = .init()
            searchListener?.delegate = self
            searchListener?.listen(addr: .init(host: DeviceController.ip, port: Host.port))
        }
        
        searchRequest?.send()
    }
    
    func stopSearch() {
        searchRequest?.stop()
        searchListener?.stop()
        
        aliveSender?.stop()
        
        searchRequest = nil
        searchListener = nil
        aliveSender = nil
    }
    
    // MARK: - ListenerDelegate
    
    func didReceiveMessage(body: MessageBody, from addr: Address) {
        switch body.method! {
        case .notify:
            print("Received notify from: \(addr)")
            print("Conetent: \n\(body.headers[.nt])")
        case .mSearch:
            guard let aliveSender = aliveSender else { return }
            
            print("Received msearch from: \(addr)")
            print("Conetent: \n\(body.headers)")
            let rtu = SearchResponseSender.RTU.self
            let responder = rtu.response(sender: aliveSender,
                                         duration: 120,
                                         location: location,
                                         st: .nt(nt: urn),
                                         usn: .nt(uuid: myUuid, nt: urn)).build()
            responder.send(addr: addr)
        case .httpOk:
            print("Received http ok from: \(addr)")
            print("Conetent: \n\(body.headers[.st])")
        }
    }
}
