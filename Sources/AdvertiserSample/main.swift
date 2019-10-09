import SSDP
import Foundation

let uuid = UUID.init().uuidString

let alive = AliveRequest.RTU.alive(location: getAddress(for: .wifi) ?? getAddress(for: .ethernet) ?? "0.0.0.0:0",
                                   nt: .urn(domain: "org-teste", type: "appletv", version: 1),
                                   uuid: uuid,
                                   duration: 10).build()

do {
    try alive.request()
} catch {
    print("Deu merda: \(error)")
}
