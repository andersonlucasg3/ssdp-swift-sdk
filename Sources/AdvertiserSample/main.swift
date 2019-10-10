import SSDP
import Foundation

let uuid = UUID.init().uuidString
let urn: Value.NT = .urn(domain: "receiver-tvos-globo-com", type: "appletv", version: 1)

let address = getAddress(for: .wifi) ?? getAddress(for: .ethernet) ?? "0.0.0.0:0"
let senderRoot = AliveSender.RTU.alive(location: "ws://\(address)/receiver",
    nt: .upnp,
    usn: .nt(uuid: uuid, nt: .upnp),
    uuid: uuid,
    duration: 120).build()

let senderUuid = AliveSender.RTU.alive(location: "ws://\(address)/receiver",
    nt: .uuid(uuid: uuid),
    usn: .uuid(uuid: uuid),
    uuid: uuid,
    duration: 120).build()

let senderUrn = AliveSender.RTU.alive(location: "ws://\(address)/receiver",
    nt: urn,
    usn: .nt(uuid: uuid, nt: urn),
    uuid: uuid,
    duration: 120).build()

let listener: AliveListener
do {
    listener = try AliveListener.init()
    try listener.listen()
} catch {
    print("Deu merda receiver: \(error)")
}

func request() {
    do {
        try senderRoot.send()
        try senderUuid.send()
        try senderUrn.send()
    }
    catch { print("Deu merda: \(error)") }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
        request()
    }
}

request()

dispatchMain()
