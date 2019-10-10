import SSDP
import Foundation

let urn: Value.NT = .urn(domain: "receiver-tvos-globo-com", type: "appletv", version: 1)
let searcher = SearchSender.RTU.search(nt: urn, delay: 5).build()

class Del: ListenerDelegate {
    func didReceiveMessage(body: MessageBody, from host: String) {
        if body.method == .notify {
            guard let nt = body.headers[.nt] else { return }
            if nt == .nt(value: urn) {
                print("Received filtered notify from \(host)")
            }
        }
    }
}

let del  = Del.init()
searcher.listenerDelegate = del
searcher.listen(addr: Address.init(host: Host.ip, port: Host.port))

func request() {
    searcher.send()

    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
        request()
    }
}

request()

dispatchMain()
