import SSDP
import Foundation

class DeviceController {
    fileprivate let myUuid = UUID.init().uuidString
    fileprivate let urn = Value.NT.urn(domain: "com-globo-globoplay-receiver", device: "appletv", type: "tv", version: 1)
    
    fileprivate var cancelRequest: NotifyRequest?
    fileprivate var notifyRequest: NotifyRequest?
    fileprivate var searchRequest: SearchRequest?
    
    init() {
        
    }
    
    func notify() {
        let rtu = NotifyRequest.Builder.RTU.self
        cancelRequest = rtu.byebye(nt: urn, uuid: myUuid).build()
        do {
            try cancelRequest?.request()
        } catch {
            print("Deu cancel merda: \(error)")
        }
        
        notifyRequest = rtu.alive(location: "192.168.0.1:3500",
                                  nt: urn,
                                  uuid: myUuid,
                                  duration: 10,
                                  server: .this).build()
        
        do {
            try notifyRequest?.request()
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
