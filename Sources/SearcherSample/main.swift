import SSDP
import Foundation

let address = getAddress(for: .wifi) ?? getAddress(for: .ethernet) ?? "0.0.0.0:0"
let urn: Value.NT = .urn(domain: "com-globo-play-receiver", type: "appletv", version: 1)
let searcher = SearchSender.RTU.searchAll(delay: 5).build()

class Del: ListenerDelegate {
    func didReceiveMessage(body: MessageBody, from addr: Address) {
        if body.method == .notify {
            guard let nt = body.headers[.nt] else { return }
            if nt == .nt(value: urn) {
                print("Received filtered notify from \(addr)")
                print("Content: \(nt)")
                print()
            }
        }
        if body.method == .httpOk {
            guard let st = body.headers[.st] else { return }
            if st == .st(value: .nt(nt: urn)) {
                print("Received filtered httpok from \(addr)")
                print("Content: \(st)")
                print()
            }
        }
    }
}

let del  = Del.init()
searcher.listenerDelegate = del
try searcher.listen()

func request() {
    searcher.send()

    DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
        request()
    }
}

request()

dispatchMain()
