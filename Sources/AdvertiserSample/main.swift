import SSDP
import Foundation

let address = getAddress(for: .wifi) ?? getAddress(for: .ethernet) ?? "0.0.0.0:0"
let uuid = UUID.init().uuidString
let urn: Value.NT = .urn(domain: "receiver-tvos-globo-com", type: "appletv", version: 1)
let location = "ws://\(address)/receiver"

let sender = AliveSender.RTU.alive(location: location,
                                nt: urn,
                                usn: .nt(uuid: uuid, nt: urn),
                                uuid: uuid,
                                duration: 120).build()

class Del: ListenerDelegate {
    func didReceiveMessage(body: MessageBody, from host: String) {
        if body.method == .mSearch {
            let rtu = SearchResponseSender.RTU.self
            let sender = rtu.response(duration: 120,
                                      location: location,
                                      st: .nt(nt: urn),
                                      usn: .nt(uuid: uuid, nt: urn)).build()
            sender.send(host: host, port: Host.port)
        }
    }
}

let del = Del.init()
sender.listenerDelegate = del

sender.listen(addr: .init(host: Host.ip, port: Host.port))

func request() {
    sender.send()
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 120) {
        request()
    }
}

request()

dispatchMain()
