import SSDP
import Foundation

class DeviceController {
    fileprivate let myUuid = UUID.init().uuidString
    fileprivate let urn = Value.NT.urn(domain: "org-teste", type: "appletv", version: 1)
    
    fileprivate var byebyeRequest: ByebyeRequest?
    fileprivate var aliveRequest: AliveRequest?
    fileprivate var searchRequest: SearchRequest?
    
    init() {
        
    }
    
    func notify() {
//        let byebye = ByebyeRequest.RTU.self
//        byebyeRequest = byebye.byebye(nt: urn, uuid: myUuid).build()
//        do {
//            try byebyeRequest?.request()
//        } catch {
//            print("Deu cancel merda: \(error)")
//        }
        
        let alive = AliveRequest.RTU.self
        aliveRequest = alive.alive(location: getAddress(for: .wifi) ?? getAddress(for: .cellular) ?? "0.0.0.0:0",
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
            .set(ssdp: .all)
            .build()
        
        do {
            try searchRequest?.request()
        } catch {
            print("Deu search merda: \(error)")
        }
    }
    
    // MARK: - NotifyRequestDelegate
    
    
}
