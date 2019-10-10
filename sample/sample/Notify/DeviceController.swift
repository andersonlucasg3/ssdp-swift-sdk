import SSDP
import Foundation

class DeviceController {
    fileprivate let myUuid = UUID.init().uuidString
    fileprivate let urn = Value.NT.urn(domain: "receiver-tvos-globo-com", type: "appletv", version: 1)
    
    fileprivate var byebyeRequest: ByebyeRequest?
    fileprivate var aliveRequest: AliveRequest?
    fileprivate var searchRequest: SearchRequest?
    
    init() { }
    
    func notify() {
//        let byebye = ByebyeSender.RTU.self
//        byebyeRequest = byebye.byebye(nt: urn, uuid: myUuid).build()
//        do {
//            try byebyeRequest?.send()
//        } catch {
//            print("Deu cancel merda: \(error)")
//        }
        
        let alive = AliveRequest.RTU.self
        let loc = getAddress(for: .wifi) ?? getAddress(for: .cellular) ?? "0.0.0.0:0"
        aliveRequest = alive.alive(location: "ws://\(loc):6005",
                                   nt: urn,
                                   uuid: myUuid,
                                   duration: 10,
                                   server: .this).build()
        
        do {
            try aliveRequest?.request()
        } catch {
            print("Deu notify merda: \(error)")
        }
    }
    
    func search() {
        searchRequest = SearchRequest.Builder.init()
            .set(nt: .ssdp(ssdp: .all))
            .build()
        
        doSearch()
    }
    
    fileprivate func doSearch() {
        guard searchRequest != nil else { return }
        
        do { try searchRequest?.request() }
        catch { print("Deu search merda: \(error)") }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 12) { [weak self] in
            self?.doSearch()
        }
    }
    
    func stopSearch() {
        searchRequest = nil
    }
    
    // MARK: - NotifyRequestDelegate
    
    
}
