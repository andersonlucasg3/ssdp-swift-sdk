import SSDP
import Foundation

let uuid = UUID.init().uuidString

let alive = AliveRequest.RTU.alive(location: "192.168.0.1",
                                   nt: .urn(domain: "org-teste", type: "appletv", version: 1),
                                   uuid: uuid,
                                   duration: 10).build()

do {
    try alive.request()
} catch {
    print("Deu merda: \(error)")
}
