import SSDP
import Foundation

class DeviceController {
    fileprivate let myUuid = UUID.init().uuidString
    fileprivate let urn = Value.NT.urn(domain: "receiver-tvos-globo-com", type: "appletv", version: 1)
    
    fileprivate var byebyeRequest: ByebyeSender?
    fileprivate var aliveSender: AliveSender?
    fileprivate var aliveListener: AliveListener?
    fileprivate var searchRequest: SearchSender?
    fileprivate var searchListener: SearchListener?
    
    init() { }
    
    func notify() {
//        let byebye = ByebyeSender.RTU.self
//        byebyeRequest = byebye.byebye(nt: urn, uuid: myUuid).build()
//        do {
//            try byebyeRequest?.send()
//        } catch {
//            print("Deu cancel merda: \(error)")
//        }
        
        let alive = AliveSender.RTU.self
        let loc = getAddress(for: .wifi) ?? getAddress(for: .cellular) ?? "0.0.0.0:0"
        aliveSender = alive.alive(location: "ws://\(loc):6005",
                                   nt: urn,
                                   usn: .nt(uuid: myUuid, nt: urn),
                                   uuid: myUuid,
                                   duration: 10,
                                   server: .this).build()
        
        aliveListener = try! .init()
        try! aliveListener?.listen()
        
        do {
            try aliveSender?.send()
        } catch {
            print("Deu notify merda: \(error)")
        }
    }
    
    func search() {
        searchRequest = SearchSender.Builder.init()
            .set(nt: .ssdp(ssdp: .all))
            .build()
        
        doSearch()
    }
    
    fileprivate func doSearch() {
        guard searchRequest != nil else { return }
        
        do { try searchRequest?.send() }
        catch { print("Deu search merda: \(error)") }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 12) { [weak self] in
            self?.doSearch()
        }
    }
    
    func stopSearch() {
        searchRequest = nil
        searchListener.stop()
        searchListener = nil
    }
    
    // MARK: - NotifyRequestDelegate
    
    
}
