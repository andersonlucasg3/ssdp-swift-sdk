import SSDP
import Foundation

let uuid = UUID.init().uuidString
let urn: Value.NT = .urn(domain: "receiver-tvos-globo-com", type: "appletv", version: 1)

let address = getAddress(for: .wifi) ?? getAddress(for: .ethernet) ?? "0.0.0.0:0"
let sender = AliveSender.RTU.alive(location: "ws://\(address)/receiver",
                                nt: urn,
                                usn: .nt(uuid: uuid, nt: urn),
                                uuid: uuid,
                                duration: 120).build()

sender.listen(addr: .init(host: Host.ip, port: Host.port))

func request() {
    sender.send()
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
        request()
    }
}

request()

dispatchMain()
