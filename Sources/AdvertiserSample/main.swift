import SSDP
import Foundation

let address = getAddress(for: .wifi) ?? getAddress(for: .ethernet) ?? "0.0.0.0:0"
let uuid = UUID.init().uuidString
let urn: Value.NT = .urn(domain: "com-globo-play-receiver", type: "appletv", version: 1)
let location = "ws://\(address)/receiver"

let sender = AliveSender.RTU.alive(location: location,
                                nt: urn,
                                usn: .nt(uuid: uuid, nt: urn),
                                uuid: uuid,
                                duration: 120).build()

class Del: ListenerDelegate {
    func didReceiveMessage(body: MessageBody, from addr: Address) {
        print("Received \(body.method!) ==== from \(addr)")
        if body.method == .mSearch {
            print("Received m search from host: \(addr.host), and port: \(addr.port)")
            let rtu = SearchResponseSender.RTU.self
            let respSender = rtu.response(sender: sender,
                                      duration: 120,
                                      location: location,
                                      st: .nt(nt: urn),
                                      usn: .nt(uuid: uuid, nt: urn)).build()
            respSender.send(addr: .init(host: addr.host, port: Host.port))
        }
    }
}

let del = Del.init()
sender.listenerDelegate = del
sender.listen(addr: .init(host: Host.ip, port: Host.port))

func request() {
    sender.send()
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
        request()
    }
}

request()

dispatchMain()
