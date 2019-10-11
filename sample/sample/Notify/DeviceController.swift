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
            try! aliveSender?.listen()
        }
        
        try! aliveSender?.send()
    }
    
    func search() {
        if searchRequest == nil {
            searchRequest = SearchSender.RTU.searchAll(delay: 0).build()
            
            searchRequest?.listenerDelegate = self
            try? searchRequest?.listen()
            
//            searchListener = .init()
//            searchListener?.delegate = self
//            try? searchListener?.listen(addr: .init(host: DeviceController.ip, port: Host.port))
        }
        
        try! searchRequest?.send()
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
            if let nt = body.headers[.nt] { print("Conetent: \(nt)") }
            print()
        case .mSearch:
            guard let aliveSender = aliveSender else { return }
            
            print("Received msearch from: \(addr)")
            print("Conetent: \(body.headers)")
            print()
            let rtu = SearchResponseSender.RTU.self
            let responder = rtu.response(sender: aliveSender,
                                         duration: 120,
                                         location: location,
                                         st: .nt(nt: urn),
                                         usn: .nt(uuid: myUuid, nt: urn)).build()
            try! responder.send(addr: addr)
        case .httpOk:
            print("Received http ok from: \(addr)")
            if let st = body.headers[.st] { print("Conetent: \(st)") }
            print()
        }
    }
}
