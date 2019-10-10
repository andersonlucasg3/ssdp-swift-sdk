import SSDP
import Foundation

let address = getAddress(for: .wifi) ?? getAddress(for: .ethernet) ?? "0.0.0.0:0"
let urn: Value.NT = .urn(domain: "receiver-tvos-globo-com", type: "appletv", version: 1)
let searcher = SearchSender.RTU.search(nt: urn, delay: 5).build()
let listener = SearchListener.init()

class Del: ListenerDelegate {
    func didReceiveMessage(body: MessageBody, from host: String) {
        if body.method == .notify {
            guard let nt = body.headers[.nt] else { return }
            if nt == .nt(value: urn) {
                print("Received filtered notify from \(host)")
            }
        }
        if body.method == .httpOk {
            print("Received filtered httpok from \(host)")
            guard let st = body.headers[.st] else { return }
            if st == .st(value: .nt(nt: urn)) {
                
            }
        }
    }
}

let del  = Del.init()
searcher.listenerDelegate = del
searcher.listen(addr: Address.init(host: Host.ip, port: 0))

listener.delegate = del
listener.listen(on: Host.port, and: Host.ip)

func request() {
    searcher.send()

    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
        request()
    }
}

request()

dispatchMain()
