import SSDP
import Foundation

let uuid = UUID.init().uuidString

let alive = AliveRequest.RTU.alive(location: getAddress(for: .wifi) ?? getAddress(for: .ethernet) ?? "0.0.0.0:0",
                                   nt: .app(domain: "com-globo-tvos-receiver", name: "globo-play"),
                                   uuid: uuid,
                                   duration: 10).build()

func request() {
    do { try alive.request() }
    catch { print("Deu merda: \(error)") }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
        request()
    }
}

request()

dispatchMain()
